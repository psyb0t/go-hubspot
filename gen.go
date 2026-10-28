// Package hubspot is a Go client for the HubSpot API, generated with
// oapi-codegen from the OpenAPI documents HubSpot publishes for each API,
// merged into one.
package hubspot

//go:generate bash scripts/fetch-spec.sh
//go:generate bash scripts/patch-spec.sh
//go:generate go tool oapi-codegen --config=config.yaml api/openapi.patched.json
//go:generate bash scripts/split-gen.sh
