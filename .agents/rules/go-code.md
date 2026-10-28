# Go code

Refines `~/.claude/rule-details/coding-style.md`.

- **GO1** The `client_NNN.gen.go` files are generated. Never edit them by hand. Change `config.yaml` or a script under `scripts/` and run `make generate`.
- **GO2** A spec problem that breaks oapi-codegen is fixed by a patch step under `scripts/`, run by a `//go:generate` line in `gen.go` between the fetch and oapi-codegen, never by editing the downloaded spec or the output. `scripts/patch-spec.sh` is that step today; each of its patches says why it exists and fails when the spec no longer has the problem.
- **GO3** The spec is never committed. `api/` stays gitignored, and `scripts/fetch-spec.sh` downloads the documents of one API version from HubSpot's public spec index on every run and merges them with `scripts/merge-specs.jq`. The merge fails on conflicts it cannot resolve; never make it skip one silently.
- **GO4** `scripts/split-gen.sh` keeps each generated file near 20,000 lines. Do not raise the limit: one huge file makes golangci-lint run for hours.
- **GO5** Hand-written Go (tests, examples) passes `make lint` with zero issues. Lines are at most 80 columns, the `.golangci.yml` limit; split calls one argument per line rather than adding `//nolint`.
- **GO6** Every command runs through the Makefile in the `Dockerfile.dev` image: `make dep`, `make generate`, `make lint`, `make test`, `make sec`.
