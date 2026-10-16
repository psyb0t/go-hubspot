# Testing

Refines `~/.claude/rule-details/go/writing-tests.md`.

- **TST1** Tests are black-box, in package `hubspot_test`, and use only the exported API.
- **TST2** Tests never call the real HubSpot API. Each test starts an `httptest` server and checks the method, the path, the `Authorization: Bearer` header and the decoded response.
- **TST3** Use placeholder data only: `test-token`, `user@example.com`, made-up record IDs. No real tokens or account data.
- **TST4** `example_test.go` holds the README usage example. It runs against a local test server and has an `// Output:` line, so a README change goes into both files.
- **TST5** `make test` runs `go test -race` and must pass after every `make generate`.
