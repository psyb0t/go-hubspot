#!/bin/bash
# Downloads the HubSpot OpenAPI spec into api/. The spec is not committed;
# `go generate` fetches it as its first step.
#
# HubSpot publishes one OpenAPI document per API, listed by its public spec
# index. The client covers one API version, so the script downloads every
# document of that version from the index and merges them into one document
# with scripts/merge-specs.jq, which fails on conflicts it cannot resolve
# safely.
set -euo pipefail
trap 'on_error "$?" "$LINENO"' ERR

LOG_FILE="${LOG_FILE:-/tmp/$(basename "$0" .sh).log}"
exec > >(tee -a "$LOG_FILE") 2>&1

readonly INDEX_URL="https://api.hubspot.com/public/api/spec/v1/specs"
readonly SPEC_URL_PREFIX="https://api.hubspot.com/public/api/spec/"
readonly API_VERSION="2026-03"
readonly DOWNLOAD_TIMEOUT_SECONDS=120
readonly SPEC_NAME="openapi.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly MERGE_FILTER="${SCRIPT_DIR}/merge-specs.jq"
SPEC_DIR="$(dirname "$SCRIPT_DIR")/api"
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

# Prints the document URLs of API_VERSION from the index, one per line,
# sorted by API name and URL so the merge order is stable.
version_urls() {
	local index="$1"

	jq -r --arg version "$API_VERSION" '
		[.results[] | .name as $name | .versions[]
			| select(.version == $version) | {name: $name, url: .openApi}]
		| sort_by(.name, .url) | .[].url
	' "$index"
}

main() {
	mkdir -p "$SPEC_DIR"
	local work
	work="$(mktemp -d "${SPEC_DIR}/.${SPEC_NAME}.XXXXXX")"
	# shellcheck disable=SC2064 # expand work now, the local is gone when EXIT fires
	trap "rm -rf -- '${work}'" EXIT
	mkdir -p "${work}/parts"

	log INFO "downloading spec index url=${INDEX_URL}"
	wget -q \
		-T "$DOWNLOAD_TIMEOUT_SECONDS" \
		-O "${work}/index.json" \
		"$INDEX_URL"

	if ! jq -e '.results | arrays' "${work}/index.json" >/dev/null; then
		log ERROR "spec index has no results array url=${INDEX_URL}"
		exit 1
	fi

	local urls
	mapfile -t urls < <(version_urls "${work}/index.json")
	if ((${#urls[@]} == 0)); then
		log ERROR "spec index lists no documents version=${API_VERSION}"
		exit 1
	fi

	local i part
	for ((i = 0; i < ${#urls[@]}; i++)); do
		if [[ "${urls[i]}" != "$SPEC_URL_PREFIX"* ]]; then
			log ERROR "unexpected document url in spec index url=${urls[i]}"
			exit 1
		fi

		part="$(printf '%s/parts/%03d.json' "$work" "$i")"
		wget -q \
			-T "$DOWNLOAD_TIMEOUT_SECONDS" \
			-O "$part" \
			"${urls[i]}"

		if ! jq -e '(.openapi | strings | startswith("3.")) and (.paths | objects)' "$part" >/dev/null; then
			log ERROR "downloaded file is not an OpenAPI 3.x document url=${urls[i]}"
			exit 1
		fi
	done
	log INFO "downloaded documents version=${API_VERSION} count=${#urls[@]}"

	jq -s --arg version "$API_VERSION" -f "$MERGE_FILTER" \
		"${work}"/parts/*.json >"${work}/${SPEC_NAME}"

	chmod 0644 "${work}/${SPEC_NAME}"
	mv -- "${work}/${SPEC_NAME}" "${SPEC_DIR}/${SPEC_NAME}"
	log INFO "saved merged spec=${SPEC_NAME} paths=$(jq '.paths | length' "${SPEC_DIR}/${SPEC_NAME}") schemas=$(jq '.components.schemas | length' "${SPEC_DIR}/${SPEC_NAME}")"
}

main "$@"
