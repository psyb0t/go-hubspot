package hubspot_test

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"

	"github.com/psyb0t/go-hubspot"
)

// This is the README usage example. A local test server stands in for
// https://api.hubapi.com so the example runs without a real token.
func Example() {
	srv := httptest.NewServer(http.HandlerFunc(
		func(w http.ResponseWriter, _ *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			_, _ = w.Write([]byte(
				`{"id":"101","archived":false,` +
					`"createdAt":"2026-01-02T03:04:05Z",` +
					`"updatedAt":"2026-01-02T03:04:05Z",` +
					`"properties":{"email":"user@example.com"}}`,
			))
		},
	))
	defer srv.Close()

	auth := hubspot.WithRequestEditorFn(
		func(_ context.Context, req *http.Request) error {
			req.Header.Set(
				"Authorization",
				"Bearer "+os.Getenv("HUBSPOT_ACCESS_TOKEN"),
			)

			return nil
		},
	)

	// Use "https://api.hubapi.com" against the real API.
	client, err := hubspot.NewClientWithResponses(srv.URL, auth)
	if err != nil {
		panic(err)
	}

	res, err := client.Getcrmobjects202603contactsContactIdGetByIdWithResponse(
		context.Background(),
		"101",
		nil,
	)
	if err != nil {
		panic(err)
	}

	fmt.Println(res.JSON200.Id, res.JSON200.Properties["email"])
	// Output: 101 user@example.com
}
