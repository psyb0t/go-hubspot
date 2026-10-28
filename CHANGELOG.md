# Changelog

All notable changes per release. Versions follow [semver](https://semver.org).

## v0.2.0, 2026-10-28

- The client is generated from HubSpot's public spec index at `https://api.hubspot.com/public/api/spec/v1/specs`. The Stainless-hosted copy of the spec it used before is no longer publicly readable, so scheduled regeneration had stopped. `scripts/fetch-spec.sh` downloads every document for API version 2026-03 and merges them with `scripts/merge-specs.jq`. Schemas that share a name but differ in shape get their API's title as a prefix, such as `CMSMediaBridgeProperty`, and the merge fails on any conflict it cannot resolve.
- Breaking: type names lose the prefixes the Stainless spec added. For example, `CrmObjectsSimplePublicObjectInputForCreate` is now `SimplePublicObjectInputForCreate` and `CrmFilter` is now `Filter`, and enum constants are renamed the same way. 20 operations are renamed, mostly the generic `{objectType}` CRM, association, URL mapping and partner services ones, such as `Getcrmobjects202603ObjectType`. Per-object methods for contacts, deals and the other CRM objects keep their names.
- `scripts/patch-spec.sh` defines `HubDbTableRowV3Wrapper`, which the HubDB document references but does not define, and keeps the property calculation and rollup expression fields as free-form objects like before. Each step fails when the spec no longer needs it.
- Updated Semgrep in the development image to 1.182.1 and refreshed its locked dependencies. certifi 2026.10.23 drops the emSign root CAs whose intermediate keys were compromised (GHSA-6q48-6c7w-9gw2).
- Dependabot no longer opens pull requests for `mcp` or the OpenTelemetry packages in `requirements-semgrep.txt`. Semgrep pins their versions itself, so bumping one of them on its own cannot install.
- Updated kin-openapi, which the code generator uses, from 0.142.0 to 0.149.0. The newer version fixes several panics on malformed specs reported in GitHub security advisories.
- The security scan merges its two gitleaks runs into one SARIF run. GitHub code scanning rejects a report with two runs from the same tool, so no scan results had been uploaded.

## v0.1.3, 2026-10-27

- The development image is based on Debian (`golang:1.26.10-trixie`) instead of Alpine. Alpine keeps only the latest build of each package, so the exact pins broke the image build whenever a package was updated. System packages now come from the snapshot.debian.org date the base image was built from, which keeps them fixed for a given base image digest. jq 1.8.2, shellcheck 0.11.0 and shfmt 3.13.1 keep their versions, and Semgrep runs in its own virtual environment.
- Raised the minimum Go version in `go.mod` from 1.26.9 to 1.26.10, which fixes the `crypto/x509` vulnerability GO-2026-6809 found by govulncheck.
- The issue-pull workflow runs at hours derived from the repository name instead of the same four hours as every other repository.

## v0.1.2, 2026-10-17

- Documentation only. The agent skill explains how to look up every endpoint, parameter and model with `go doc` or on pkg.go.dev, and declares its license.
- The skill no longer lists the API credentials under OpenClaw's `requires.env`, which kept OpenClaw from loading it until they were set. It requires only `go`; the credentials are still documented as what your program reads.
- The README points to the full API reference, and the examples in the README and the skill were checked against the current code.
- The setup reference's lookup example uses a path that exists in the spec, and the skill description no longer suggests the spec can list or create deals; it covers single-deal reads and updates.

## v0.1.1, 2026-10-17

- Documentation only. The README and `AGENTS.md` describe the daily regeneration workflow: what it checks, how it fixes failing checks, how it picks the next version and which paths a fix may not touch.

## v0.1.0, 2026-10-16

- Added `hubspot`, a REST client generated with oapi-codegen from HubSpot's unified OpenAPI document (HubSpot API Specification, spec version 1.0.0, OpenAPI 3.0.0), the one HubSpot's Stainless SDKs are built from. It covers all 721 paths, including CRM objects, associations, properties, marketing, automation, CMS, conversations and account endpoints.
- Number fields are `float64` instead of oapi-codegen's default `float32`.
- `make generate` looks up the current spec URL in the `.stats.yml` of HubSpot/hubspot-sdk-python, downloads the spec, regenerates the client and splits it into `client_NNN.gen.go` files. The spec is not committed.
- Added the `go-hubspot` agent skill: `claude plugin install go-hubspot@psyb0t` for Claude Code, `codex plugin add go-hubspot@psyb0t` for Codex, `openclaw skills install @psyb0t/go-hubspot` for ClawHub.
