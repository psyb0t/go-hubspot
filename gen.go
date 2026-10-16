// Package hubspot is a Go client for the HubSpot API, generated with
// oapi-codegen from the unified OpenAPI document HubSpot publishes for its
// SDKs.
package hubspot

//go:generate bash scripts/fetch-spec.sh
//go:generate go tool oapi-codegen --config=config.yaml api/openapi.yml
//go:generate bash scripts/split-gen.sh
