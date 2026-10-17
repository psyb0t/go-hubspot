# go-hubspot

[![Go Reference](https://pkg.go.dev/badge/github.com/psyb0t/go-hubspot.svg)](https://pkg.go.dev/github.com/psyb0t/go-hubspot)
[![CI](https://github.com/psyb0t/go-hubspot/actions/workflows/pipeline.yml/badge.svg?branch=main)](https://github.com/psyb0t/go-hubspot/actions/workflows/pipeline.yml)
[![version](https://raw.githubusercontent.com/psyb0t/go-hubspot/badges/version.svg)](https://github.com/psyb0t/go-hubspot/tags)
[![license](https://raw.githubusercontent.com/psyb0t/go-hubspot/badges/license.svg)](LICENSE)
[![imported by](https://raw.githubusercontent.com/psyb0t/go-hubspot/badges/importers.svg)](https://github.com/psyb0t/go-hubspot/blob/badges/importers.md)

Unofficial Go client for the [HubSpot API](https://developers.hubspot.com/docs/api-reference), generated with [oapi-codegen](https://github.com/oapi-codegen/oapi-codegen) from the unified OpenAPI document HubSpot publishes for its SDKs. I am not affiliated with HubSpot.

The package is `hubspot`, in the repository root. Everything in the `client_NNN.gen.go` files is generated. Don't edit them by hand, regenerate them.

## Install

```sh
go get github.com/psyb0t/go-hubspot
```

## Usage

Every endpoint in the spec has a typed method on `ClientWithResponses`. Responses decode into `JSON200` and the other status fields.

```go
package main

import (
	"context"
	"fmt"
	"net/http"
	"os"

	"github.com/psyb0t/go-hubspot"
)

func main() {
	auth := hubspot.WithRequestEditorFn(func(_ context.Context, req *http.Request) error {
		req.Header.Set("Authorization", "Bearer "+os.Getenv("HUBSPOT_ACCESS_TOKEN"))

		return nil
	})

	client, err := hubspot.NewClientWithResponses("https://api.hubapi.com", auth)
	if err != nil {
		panic(err)
	}

	res, err := client.Getcrmobjects202603contactsContactIdGetByIdWithResponse(context.Background(), "101", nil)
	if err != nil {
		panic(err)
	}

	fmt.Println(res.JSON200.Id, res.JSON200.Properties["email"])
}
```

The same code is in `example_test.go`, where it runs against a local test server, so `make test` checks it.

Method names come from the spec's operation IDs, which embed the HTTP method, the path and the API version date, so they are long (`Getcrmobjects202603contactsContactIdGetById` is `GET /crm/objects/2026-03/contacts/{contactId}`). Search the generated files for the path you want.

The full API, with the spec's descriptions as doc comments, is in the [Go reference](https://pkg.go.dev/github.com/psyb0t/go-hubspot) and in `go doc github.com/psyb0t/go-hubspot`.

## Auth

HubSpot takes a Bearer access token in the `Authorization` header. That is either a private app access token or an OAuth access token; both go in the request editor shown above.

A few developer endpoints use the `hapikey` query parameter with a developer API key instead. To call those, add it in the request editor:

```go
q := req.URL.Query()
q.Set("hapikey", os.Getenv("HUBSPOT_DEVELOPER_API_KEY"))
req.URL.RawQuery = q.Encode()
```

## Regenerating

The spec is not committed. `make generate` downloads the current OpenAPI document into the gitignored `api/` directory and regenerates the client:

```sh
make generate
```

`gen.go` declares the steps, so `make generate` is just `go generate ./...`:

- `scripts/fetch-spec.sh` reads `openapi_spec_url` from `.stats.yml` in [HubSpot/hubspot-sdk-python](https://github.com/HubSpot/hubspot-sdk-python) and downloads that URL to `api/openapi.yml`. The spec is hosted by Stainless under a URL that changes with every update, so the script looks it up each time.
- oapi-codegen runs with `config.yaml` and writes `client.gen.go`. The config maps `number` to `float64`, because the spec gives many numbers no format and oapi-codegen would otherwise use `float32`.
- `scripts/split-gen.sh` splits `client.gen.go` into `client_NNN.gen.go` files of about 20,000 lines each, at top-level declarations. One file of close to 300,000 lines makes golangci-lint very slow.

`.github/workflows/regen.yml` does the same every day in CI. When the new spec changes the client, it runs `make lint`, `make test` and `make sec`. If a check fails, Claude edits the code and the checks run again, up to three times, and a review step reads the result. A passing change is committed with a CHANGELOG entry and tagged as the next release: a patch version for fixes and additions, a minor version for breaking changes.

## Agent integrations

The [skill](.agents/skills/go-hubspot) teaches a coding agent how to use go-hubspot when it writes Go. It works in any agent that reads `.agents/skills/`, and installs natively in the clients below.

### Claude Code

```bash
claude plugin marketplace add psyb0t/agents
claude plugin install go-hubspot@psyb0t
```

### Codex

```bash
codex plugin marketplace add psyb0t/agents
codex plugin add go-hubspot@psyb0t
```

Codex also picks the skill up with no install in any checkout of this repo.

### OpenClaw

The skill is published to ClawHub on every release:

```bash
openclaw skills install @psyb0t/go-hubspot
```

## Development

Every command runs in the `Dockerfile.dev` image. The host needs only Docker and Make.

```sh
make help      # list targets
make dep       # go mod tidy + vendor
make lint      # shellcheck, shfmt, go fix, golangci-lint
make test      # go test -race
make sec       # gitleaks, govulncheck, semgrep
make generate  # download the spec and regenerate
```

## License

[MIT](LICENSE). The generated code comes from HubSpot's published API specification. The specification itself is not redistributed here.
