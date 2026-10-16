# Changelog

All notable changes per release. Versions follow [semver](https://semver.org).

## v0.1.0, 2026-10-16

- Added `hubspot`, a REST client generated with oapi-codegen from HubSpot's unified OpenAPI document (HubSpot API Specification, spec version 1.0.0, OpenAPI 3.0.0), the one HubSpot's Stainless SDKs are built from. It covers all 721 paths, including CRM objects, associations, properties, marketing, automation, CMS, conversations and account endpoints.
- Number fields are `float64` instead of oapi-codegen's default `float32`.
- `make generate` looks up the current spec URL in the `.stats.yml` of HubSpot/hubspot-sdk-python, downloads the spec, regenerates the client and splits it into `client_NNN.gen.go` files. The spec is not committed.
- Added the `go-hubspot` agent skill: `claude plugin install go-hubspot@psyb0t` for Claude Code, `codex plugin add go-hubspot@psyb0t` for Codex, `openclaw skills install @psyb0t/go-hubspot` for ClawHub.
