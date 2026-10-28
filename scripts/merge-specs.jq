# Merges HubSpot's per-API OpenAPI documents into one document for
# oapi-codegen. Run as `jq -s --arg version <api version> -f merge-specs.jq`
# on the downloaded documents, in a fixed order; the first document wins
# wherever two documents carry the same thing.
#
# HubSpot publishes one document per API. Several documents define the same
# component or the same operation, so a plain merge would silently keep one
# definition and point other documents' references at a schema they did not
# define. The merge is deterministic and fails instead of guessing:
#
# - Schemas with one name are compared by structure. Descriptions, titles,
#   examples and x- extensions do not count, references are compared by what
#   they point to, through the whole reference graph. When the structures
#   differ, the variant most documents use keeps the name (ties go to the
#   variant of the earliest document) and every other variant is renamed to
#   the PascalCase title of its first document plus the name. A rename that
#   hits an existing name fails the merge.
# - Other components with one name must be equal apart from descriptions;
#   security schemes may differ only in their OAuth scope lists, which are
#   merged.
# - An operation defined by several documents (same path and method) must be
#   equal apart from operationId, tags, summary and descriptions, comparing
#   referenced schemas by structure. The copy with the shortest operationId
#   is kept (the earliest document's on a tie): documents that share an
#   operation often append another path to its operationId, which would end
#   up in the generated method name.
# - Every document must name the same servers, and every operationId must be
#   unique in the result.

def cosmetic_keys:
  ["description", "title", "summary", "example", "examples", "externalDocs",
    "operationId", "tags"];

# Drops the keys that do not change the generated code. Keys inside
# properties maps are property names, so they are kept whatever they are.
def norm:
  if type == "object" then
    with_entries(
      select((.key | startswith("x-")) or (.key as $k | cosmetic_keys | index($k)) | not)
      | if (.key == "properties" or .key == "patternProperties") and (.value | type) == "object"
        then .value |= map_values(norm)
        else .value |= norm
        end
    )
  elif type == "array" then map(norm)
  else .
  end;

def schema_ref_prefix: "#/components/schemas/";

# Schema names referenced from the input, in document order.
def schema_refs:
  [
    .. | objects
    | (."$ref"? // empty), (.discriminator?.mapping? // {} | .[]?)
    | select(type == "string" and startswith(schema_ref_prefix))
    | ltrimstr(schema_ref_prefix)
  ];

# The input with every schema reference blanked, so its structure can be
# compared without the names it points to.
def blank_refs:
  walk(
    if type == "object" and (."$ref"? | type) == "string" then ."$ref" = "#"
    elif type == "object" and (.propertyName? | type) == "string" and (.mapping? | type) == "object"
    then .mapping |= map_values("#")
    else .
    end
  );

def pascal_case:
  [scan("[A-Za-z0-9]+") | (.[:1] | ascii_upcase) + .[1:]] | join("");

# Maps each {id, key} entry to the index of its key among the sorted unique
# keys, so equal keys get equal class numbers.
def classify($entries):
  ($entries | map(.key) | unique) as $keys
  | reduce $entries[] as $e ({}; .[$e.id] = ($keys | bsearch($e.key)));

# Replaces every schema reference in the input with the structural class of
# its target in document $i, so equal shapes compare equal whatever the
# referenced schemas are called.
def class_refs($classes; $i):
  walk(
    if type == "string" and startswith(schema_ref_prefix) then
      ltrimstr(schema_ref_prefix) as $name
      | "class:\($classes["\($i)/\($name)"] // "missing:\($name)")"
    else .
    end
  );

# Rewrites schema references through $renames ({old: new}).
def rename_refs($renames):
  walk(
    if type == "string" and startswith(schema_ref_prefix)
      and $renames[ltrimstr(schema_ref_prefix)] != null
    then schema_ref_prefix + $renames[ltrimstr(schema_ref_prefix)]
    else .
    end
  );

. as $docs
| $docs as $originals
| ($docs | map(.info.title | pascal_case)) as $prefixes

# Structural class of every (document, schema) pair, by partition refinement:
# start from the structure without reference targets, then add the classes of
# the referenced schemas until the number of classes stops growing.
| [
    $docs | to_entries[] | .key as $i
    | .value.components.schemas // {} | to_entries[]
    | {id: "\($i)/\(.key)", i: $i, name: .key,
        base: (.value | norm | blank_refs | tojson), refs: (.value | schema_refs)}
  ] as $schemas
| (classify([$schemas[] | {id, key: .base}])) as $initial
| {classes: $initial, count: ($initial | [.[]] | unique | length), done: false}
| until(.done;
    .classes as $c
    | classify([
        $schemas[]
        | . as $s
        | {id, key: ([$c[$s.id], [$s.refs[] | $c["\($s.i)/\(.)"] // "missing:\(.)"]] | tojson)}
      ]) as $next
    | ($next | [.[]] | unique | length) as $n
    | if $n == .count then .done = true else {classes: $next, count: $n, done: false} end
  )
| .classes as $classes

# Renames: per schema name, every class but the most used one gets the
# prefix of its first document.
| (
    $schemas | group_by(.name) | map(
      .[0].name as $name
      | group_by($classes[.id])
      | select(length > 1)
      | sort_by(-length, (map(.i) | min))
      | .[1:][]
      | (map(.i) | min) as $first
      | {name: $name, new: ($prefixes[$first] + $name), docs: map(.i)}
    )
  ) as $renames
| ([$schemas[].name] | unique) as $names
| if ([$renames[].new] | unique | length) != ($renames | length) then
    error("merge: two schema renames produce the same name: \([$renames[].new] | group_by(.) | map(select(length > 1)[0]))")
  elif any($renames[]; .new as $new | $names | index($new)) then
    error("merge: a schema rename hits an existing schema name: \([$renames[] | select(.new as $new | $names | index($new)) | .new])")
  else . end
| [
    range($docs | length) as $i
    | ($renames | map(select(.docs | index($i))) | map({(.name): .new}) | add // {}) as $map
    | $docs[$i]
    | rename_refs($map)
    | .components.schemas |= ((. // {}) | with_entries(.key = ($map[.key] // .key)))
  ] as $docs

# Components: first definition wins, after checking that the others agree.
| (
    [$docs[].components | keys[]] | unique
    | map(
        . as $type
        | {
            key: $type,
            value: (
              reduce ($docs[] | .components[$type] // {} | to_entries[]) as $e ({};
                if has($e.key) | not then .[$e.key] = $e.value
                elif (.[$e.key] | norm) == ($e.value | norm) then .
                elif $type == "securitySchemes"
                  and (.[$e.key] | del(.flows[]?.scopes) | norm) == ($e.value | del(.flows[]?.scopes) | norm)
                then .[$e.key].flows |= with_entries(
                    .key as $flow | .value.scopes = ($e.value.flows[$flow].scopes + .value.scopes)
                  )
                elif $type == "schemas" then .
                else error("merge: component \($type)/\($e.key) differs between documents")
                end
              )
            )
          }
      )
    | from_entries
  ) as $components

# Paths: an operation in several documents must be the same everywhere.
| (
    reduce (
      range($docs | length) as $i
      | $docs[$i].paths | to_entries[] | .key as $path
      | .value | to_entries[]
      | {
          path: $path, method: .key, value, title: $docs[$i].info.title,
          shape: ($originals[$i].paths[$path][.key] | class_refs($classes; $i) | norm)
        }
    ) as $op ({paths: {}, shapes: {}};
      if .paths[$op.path][$op.method] == null then
        .paths[$op.path][$op.method] = $op.value
        | .shapes[$op.path][$op.method] = $op.shape
      elif .shapes[$op.path][$op.method] == $op.shape then
        if ($op.value.operationId // "" | length) < (.paths[$op.path][$op.method].operationId // "" | length)
        then .paths[$op.path][$op.method] = $op.value
        else .
        end
      else error("merge: \($op.method) \($op.path) from \($op.title) differs from an earlier document")
      end
    )
    | .paths
  ) as $paths
| ([$paths[][] | objects | .operationId // empty] | group_by(.) | map(select(length > 1)[0])) as $dupes
| if $dupes != [] then error("merge: duplicate operationIds \($dupes)") else . end
| ([$docs[].servers] | unique) as $servers
| if ($servers | length) != 1 then error("merge: documents name different servers \($servers)") else . end
| ([$docs[].openapi] | unique) as $openapi
| if ($openapi | length) != 1 then error("merge: documents use different OpenAPI versions \($openapi)") else . end
| {
    openapi: $openapi[0],
    info: {title: "HubSpot API", version: $version},
    servers: $servers[0],
    tags: ([$docs[].tags // [] | .[]] | unique_by(.name)),
    paths: $paths,
    components: $components
  }
