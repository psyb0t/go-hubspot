#!/bin/bash
# Fixes the merged HubSpot spec in api/ before oapi-codegen reads it. Each
# patch checks that the spec still has the problem it fixes and fails
# otherwise, so a stale patch gets noticed.
#
# 1. The HubDB document references #/components/schemas/HubDbTableRowV3Wrapper
#    from its row collection responses but never defines it, and oapi-codegen
#    stops on a dangling reference. The patch defines it as a free-form
#    object, the shape row results have when their columns are table specific.
# 2. PropertyDefinition.calculationExpression and
#    RollupExpression.conditionalExpression are a oneOf over about a hundred
#    expression schemas, each with inputs that are the same oneOf again.
#    oapi-codegen turns that into roughly 300,000 lines of union helpers,
#    doubling the generated client. The patch types both fields as free-form
#    objects and drops the schemas that only those fields reached. The
#    expression schemas reference each other, so oapi-codegen's own pruning
#    would keep them.
set -euo pipefail
trap 'on_error "$?" "$LINENO"' ERR

LOG_FILE="${LOG_FILE:-/tmp/$(basename "$0" .sh).log}"
exec > >(tee -a "$LOG_FILE") 2>&1

readonly SPEC_IN="openapi.json"
readonly SPEC_OUT="openapi.patched.json"
readonly MISSING_SCHEMA="HubDbTableRowV3Wrapper"
# Minimum oneOf size that marks the expression unions.
readonly EXPRESSION_UNION_MIN=50
readonly EXPRESSION_PATHS='[
	["components", "schemas", "PropertyDefinition", "properties", "calculationExpression"],
	["components", "schemas", "RollupExpression", "properties", "conditionalExpression"]
]'
SPEC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/api"
readonly SPEC_DIR

on_error() {
	local exit_code="$1"
	local line="$2"

	printf '{"level":"ERROR","file":"%s","line":%d,"msg":"command failed","exit_code":%d}\n' \
		"${BASH_SOURCE[1]}" "$line" "$exit_code" >&2
}

log() {
	local level="$1"
	shift

	jq -nc \
		--arg time "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
		--arg level "$level" \
		--arg file "${BASH_SOURCE[1]##*/}" \
		--arg line "${BASH_LINENO[0]}" \
		--arg func "${FUNCNAME[1]:-main}" \
		--arg msg "$*" \
		'{time:$time,level:$level,file:$file,line:($line|tonumber),func:$func,msg:$msg}' >&2
}

main() {
	if [[ ! -f "${SPEC_DIR}/${SPEC_IN}" ]]; then
		log ERROR "spec not found, run scripts/fetch-spec.sh first spec=${SPEC_IN}"
		exit 1
	fi

	# shellcheck disable=SC2016 # $name and $ref are jq variables.
	if ! jq -e --arg name "$MISSING_SCHEMA" '
		("#/components/schemas/" + $name) as $ref
		| (.components.schemas[$name] == null)
			and any(.. | objects; ."$ref"? == $ref)
	' "${SPEC_DIR}/${SPEC_IN}" >/dev/null; then
		log ERROR "schema is defined or no longer referenced; review and drop this patch schema=${MISSING_SCHEMA}"
		exit 1
	fi

	# shellcheck disable=SC2016 # $min and $paths are jq variables.
	if ! jq -e --argjson min "$EXPRESSION_UNION_MIN" --argjson paths "$EXPRESSION_PATHS" '
		. as $spec
		| all($paths[]; . as $path | ($spec | getpath($path) | (.oneOf? // []) | length) >= $min)
	' "${SPEC_DIR}/${SPEC_IN}" >/dev/null; then
		log ERROR "expression fields are no longer large oneOf unions; review and drop this patch"
		exit 1
	fi

	local tmp
	tmp="$(mktemp "${SPEC_DIR}/.${SPEC_OUT}.XXXXXX")"
	# shellcheck disable=SC2064 # expand tmp now, the local is gone when EXIT fires
	trap "rm -f -- '${tmp}'" EXIT

	# shellcheck disable=SC2016 # $name and $paths are jq variables.
	jq --arg name "$MISSING_SCHEMA" --argjson paths "$EXPRESSION_PATHS" '
		def schema_refs:
			[.. | strings | select(startswith("#/components/schemas/"))
				| ltrimstr("#/components/schemas/")] | unique;
		# Schema names reachable from the paths and the other components.
		def reachable:
			. as $spec
			| ([$spec.paths, ($spec.components | del(.schemas))] | schema_refs)
			| until(. as $set | ([$set[] as $n | $spec.components.schemas[$n]] | schema_refs) - $set == [];
				. as $set | ($set + ([$set[] as $n | $spec.components.schemas[$n]] | schema_refs)) | unique);

		reachable as $before
		| .components.schemas[$name] = {
			type: "object",
			additionalProperties: true,
			description: "A HubDB table row. Defined by scripts/patch-spec.sh: the spec references it without defining it."
		}
		| reduce $paths[] as $path (.;
			setpath($path; {
				type: "object",
				additionalProperties: true,
				description: ((getpath($path).description // "An expression.")
					+ " Typed as a free-form object by scripts/patch-spec.sh.")
			}))
		| (reachable | . - [$name]) as $after
		| .components.schemas |= with_entries(
			select(.key as $k | ($before | index($k)) == null or ($after | index($k)) != null or $k == $name))
	' "${SPEC_DIR}/${SPEC_IN}" >"$tmp"
	chmod 0644 "$tmp"
	mv -- "$tmp" "${SPEC_DIR}/${SPEC_OUT}"
	log INFO "defined missing schema=${MISSING_SCHEMA} and typed expression unions as objects spec=${SPEC_OUT}"
}

main "$@"
