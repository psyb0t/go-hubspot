# Changelog

All notable changes per release. Versions follow [semver](https://semver.org).

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
