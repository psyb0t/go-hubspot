package hubspot_test

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/psyb0t/go-hubspot"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const testToken = "test-token"

func newTestClient(
	t *testing.T,
	handler http.HandlerFunc,
) *hubspot.ClientWithResponses {
	t.Helper()

	srv := httptest.NewServer(handler)
	t.Cleanup(srv.Close)

	auth := hubspot.WithRequestEditorFn(
		func(_ context.Context, req *http.Request) error {
			req.Header.Set("Authorization", "Bearer "+testToken)

			return nil
		},
	)

	client, err := hubspot.NewClientWithResponses(srv.URL, auth)
	require.NoError(t, err)

	return client
}

func assertBearer(t *testing.T, r *http.Request) {
	t.Helper()

	assert.Equal(t, "Bearer "+testToken, r.Header.Get("Authorization"))
}

func TestGetContactByID(t *testing.T) {
	t.Parallel()

	client := newTestClient(t, func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, http.MethodGet, r.Method)
		assert.Equal(t, "/crm/objects/2026-03/contacts/101", r.URL.Path)
		assert.Equal(t, "email", r.URL.Query().Get("properties"))
		assertBearer(t, r)

		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(
			`{"id":"101","archived":false,` +
				`"createdAt":"2026-01-02T03:04:05Z",` +
				`"updatedAt":"2026-01-02T03:04:05Z",` +
				`"properties":{"email":"user@example.com"}}`,
		))
	})

	props := []string{"email"}

	res, err := client.Getcrmobjects202603contactsContactIdGetByIdWithResponse(
		context.Background(),
		"101",
		&hubspot.Getcrmobjects202603contactsContactIdGetByIdParams{
			Properties: &props,
		},
	)
	require.NoError(t, err)
	require.Equal(t, http.StatusOK, res.StatusCode())
	require.NotNil(t, res.JSON200)

	assert.Equal(t, "101", res.JSON200.Id)
	assert.False(t, res.JSON200.Archived)
	assert.Equal(t, "user@example.com", res.JSON200.Properties["email"])
	assert.Equal(t, 2026, res.JSON200.CreatedAt.Year())
}

func TestCreateContact(t *testing.T) {
	t.Parallel()

	client := newTestClient(t, func(w http.ResponseWriter, r *http.Request) {
		assert.Equal(t, http.MethodPost, r.Method)
		assert.Equal(t, "/crm/objects/2026-03/contacts", r.URL.Path)
		assert.Equal(t, "application/json", r.Header.Get("Content-Type"))
		assertBearer(t, r)

		var body hubspot.SimplePublicObjectInputForCreate

		assert.NoError(t, json.NewDecoder(r.Body).Decode(&body))
		assert.Equal(t, "user@example.com", body.Properties["email"])

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		_, _ = w.Write([]byte(
			`{"id":"202","archived":false,` +
				`"createdAt":"2026-01-02T03:04:05Z",` +
				`"updatedAt":"2026-01-02T03:04:05Z",` +
				`"properties":{"email":"user@example.com"}}`,
		))
	})

	res, err := client.Postcrmobjects202603contactsCreateWithResponse(
		context.Background(),
		hubspot.SimplePublicObjectInputForCreate{
			Associations: []hubspot.PublicAssociationsForObject{},
			Properties:   map[string]string{"email": "user@example.com"},
		},
	)
	require.NoError(t, err)
	require.Equal(t, http.StatusCreated, res.StatusCode())
	require.NotNil(t, res.JSON201)

	assert.Equal(t, "202", res.JSON201.Id)
	assert.Equal(t, "user@example.com", res.JSON201.Properties["email"])
}
