# Changelog

All notable changes per release. Versions follow [semver](https://semver.org).

## v0.5.5, 2026-11-12

- Added doc comments from the spec for API version 2026-03 on `PublicComparativeNumberPropertyOperation`, its fields `ComparisonPropertyName`, `DefaultComparisonValue`, `IncludeObjectsWithNoValueSet`, `OperationType` and `Operator`, and the type `PublicComparativeNumberPropertyOperationOperationType`. They replace "defines model for".
- Generated code changed only in comments and file placement. The parameter type `Getcrmobjects202603discountsDiscountIdParams` moved from `client_004.gen.go` to `client_005.gen.go`. No exported identifier or signature changed.

## v0.5.4, 2026-11-11

- Added the constant `PreResolvedContactContactPropertiesLeadingToMatchHsGeocodeMappingId` for the contact property `hs_geocode_mapping_id`. The `Valid` method of `PreResolvedContactContactPropertiesLeadingToMatch` accepts it.
- Raised the minimum Go version in `go.mod` from 1.26.10 to 1.26.11, to pick up the `net/http` fix for GO-2026-6859 that `govulncheck` reported. The development image `Dockerfile.dev` and the setup notes use the same version.

## v0.5.3, 2026-11-10

- Added the optional field `AllowedObjectTypeIds` (`*[]string`, JSON name `allowedObjectTypeIds`) on `StringFieldSchema`. Existing callers compile and behave the same.

## v0.5.2, 2026-11-10

- Rewrote doc comments on many `Public...` filter types from the spec for API version 2026-03, such as `PublicAbsoluteComparativeTimestampRefineBy`, `PublicAbsoluteRangedTimestampRefineBy`, `PublicAdsSearchFilter`, `PublicAdsTimeFilter`, `PublicAllHistoryRefineBy`, `PublicAllPropertyTypesOperation` and `PublicAndFilterBranch`. They replace "defines model for" with a description of what the type filters.
- Added doc comments on fields that had none, such as `SearchTerms` on `PublicAdsSearchFilter` and `FilterBranches` on `PublicAndFilterBranch`.
- Generated code changed only in comments and file placement. The parameter types `Patchcrmobjects202603discountsDiscountIdParams`, `Getcrmobjects202603emailsGetPageParams` and the other `...202603emails...Params` types moved from `client_004.gen.go` to `client_005.gen.go`. No exported identifier or signature changed.

## v0.5.1, 2026-11-05

- Rewrote the doc comments on the webhooks journal operations for API version 2026-03, both the `GetwebhooksJournaljournal202603...` and `GetwebhooksJournaljournalLocal202603...` variants. They now describe `count`, offsets and `currentOffset` paging, `errors` and `numErrors` in batch reads, and snapshot status lookups.
- Rewrote the doc comment on the `InstallPortalId` field of the journal parameter types, such as `GetwebhooksJournaljournalLocal202603batchlatestCountParams`. It now says the field limits results to one account that has installed the app.
- The title in the comment for `GetwebhooksJournaljournal202603batchlatestCount` is now "Retrieve latest batch".
- Generated code changed only in comments. No exported identifier or signature changed.

## v0.5.0, 2026-11-04

- Breaking: renamed the webhooks journal subscription response type `SubscriptionResponseMarch2027` to `SubscriptionResponse1`. The spec dropped the `March2027` suffix and the name `SubscriptionResponse` is already taken, so the generator added `1`.
- Breaking: renamed the matching enum types and constants. `SubscriptionResponseMarch2027Actions` and `SubscriptionResponseMarch2027SubscriptionType` are now `SubscriptionResponse1Actions` and `SubscriptionResponse1SubscriptionType`, and each constant such as `SubscriptionResponseMarch2027ActionsCREATE` is now `SubscriptionResponse1ActionsCREATE`.
- Breaking: renamed `CollectionResponseSubscriptionResponseMarch2027NoPaging` to `CollectionResponseSubscriptionResponseNoPaging`. This changes the type of `JSON200` and the return type of `GetJSON200` on `GetwebhooksJournalsubscriptions202603Response`.
- Breaking: removed the field `IncludeSensitivePropertiesChanged` from the subscription response type, now `SubscriptionResponse1`.
- The fields of `SubscriptionResponse1` now carry doc comments from the spec.
- Generated code moved between `client_NNN.gen.go` files. This has no effect on callers.

## v0.4.1, 2026-11-03

- Added the CMS site search operation for spec version 2026-03 back, under a longer name: `GetcmssiteSearch202603searchcmssiteSearch202603search` and `GetcmssiteSearch202603searchcmssiteSearch202603searchWithResponse` on `Client` and `ClientWithResponses`, and the matching methods on `ClientInterface` and `ClientWithResponsesInterface`. The request builder is `NewGetcmssiteSearch202603searchcmssiteSearch202603searchRequest` and the response parser is `ParseGetcmssiteSearch202603searchcmssiteSearch202603searchResponse`.
- Added the types for that operation: `GetcmssiteSearch202603searchcmssiteSearch202603searchParams`, `GetcmssiteSearch202603searchcmssiteSearch202603searchResponse`, the `...ParamsLanguage` enum (one constant per language code), `...ParamsLength` (`SHORT`, `LONG`) and `...ParamsTypes` (`BLOGPOST`, `KNOWLEDGEARTICLE`, `LANDINGPAGE`, `LISTINGPAGE`, `SITEPAGE`, `STRUCTUREDCONTENT`).
- Added the result types `PublicSearchResults`, `ContentSearchResult`, `ContentSearchResultLanguage` and `ContentSearchResultType`, with their constants. The regeneration removes no exported identifier.
- Added the URL mappings create operation: `PosturlMappings202603urlMappingsurlMappingsv3urlMappings` and `PosturlMappings202603urlMappingsurlMappingsv3urlMappingsWithResponse`, with `NewPosturlMappings202603urlMappingsurlMappingsv3urlMappingsRequest` and the request body type `PosturlMappings202603urlMappingsurlMappingsv3urlMappingsJSONRequestBody`.
- Added the field `JSON200` and the method `GetJSON200` on `GeturlMappings202603urlMappingsurlMappingsv3urlMappingsResponse` and `GeturlMappings202603urlMappingsIdurlMappingsv3urlMappingsIdResponse`.
- Types that implement `ClientInterface` or `ClientWithResponsesInterface`, such as test mocks, need the four new methods.
- Generated code moved between `client_NNN.gen.go` files, and a new `client_005.gen.go` file was added. This has no effect on callers.

## v0.4.0, 2026-11-02

- Breaking: removed the CMS site search operation for spec version 2026-03: `GetcmssiteSearch202603search` on `Client`, `GetcmssiteSearch202603searchWithResponse` on `ClientWithResponses`, and the matching methods on `ClientInterface` and `ClientWithResponsesInterface`. The spec no longer has this endpoint.
- Breaking: removed the types that belonged to that operation: `PublicSearchResults`, `ContentSearchResult`, `ContentSearchResultLanguage` and its language constants, and `ContentSearchResultType` with its constants (`ContentSearchResultTypeBLOGPOST` and the others).
- Added CMS blog write operations for authors, posts and tags, for example `Postcmsblogs202603postsCreate`, `Patchcmsblogs202603postsObjectIdUpdate`, `Postcmsblogs202603postsscheduleSchedule` and `Postcmsblogs202603postscloneClone`. Each has a `WithResponse` variant, a `NewPost...Request` or `NewPatch...Request` builder and a parser. Posts also get `Patchcmsblogs202603postsObjectIddraftUpdateDraft`.
- Added CMS pages write operations for landing pages, site pages and landing page folders, for example `Postcmspages202603landingPagesCreate`, `Patchcmspages202603sitePagesObjectIdUpdate`, `Postcmspages202603sitePagesscheduleSchedule` and `Postcmspages202603landingPagesfoldersCreateFolder`. The A/B test operations are `...abTestcreateVariationCreateABTestVariation`, `...abTestendEndActiveABTest` and `...abTestrerunRerunPreviousABTest`.
- Added batch operations (`...batchcreate...`, `...batchread...`, `...batchupdate...`, `...batcharchive...`) and multi-language operations (attach to and detach from a language group, create a language variation, update languages, and `Putcms...multiLanguagesetNewLangPrimarySetLangPrimary`) for the same blog and page resources.
- Added the fields `JSON200` and the methods `GetJSON200` on the response types of the CMS blog author, post and tag read operations, such as `Getcmsblogs202603postsGetPageResponse` and `Getcmsblogs202603tagsObjectIdGetByIdResponse`.
- Types that implement `ClientInterface` or `ClientWithResponsesInterface`, such as test mocks, need the new methods.
- Generated code moved between `client_NNN.gen.go` files, and a new `client_015.gen.go` file was added. This has no effect on callers.

## v0.3.4, 2026-11-01

- Added the CMS site search operation for spec version 2026-03: `GetcmssiteSearch202603search` and `GetcmssiteSearch202603searchWithResponse` on `Client`, `ClientWithResponses`, `ClientInterface` and `ClientWithResponsesInterface`. The request builder is `NewGetcmssiteSearch202603searchRequest` and the response parser is `ParseGetcmssiteSearch202603searchResponse`.
- Added the types `GetcmssiteSearch202603searchParams` and `GetcmssiteSearch202603searchResponse` for the new operation.
- Added the query parameter enums `GetcmssiteSearch202603searchParamsLanguage` (one constant per language code), `GetcmssiteSearch202603searchParamsLength` (`SHORT`, `LONG`) and `GetcmssiteSearch202603searchParamsTypes` (`BLOGPOST`, `KNOWLEDGEARTICLE`, `LANDINGPAGE`, `LISTINGPAGE`, `SITEPAGE`, `STRUCTUREDCONTENT`).
- Added the result types `PublicSearchResults`, `ContentSearchResult`, `ContentSearchResultLanguage` and `ContentSearchResultType`, with the same language and content type constants.
- Types that implement `ClientInterface` or `ClientWithResponsesInterface`, such as test mocks, need the two new methods.
- Generated code moved between `client_NNN.gen.go` files, and a new `client_005.gen.go` file was added. This has no effect on callers.

## v0.3.3, 2026-10-30

- Added the constant `EmailSendStatusViewSendResultRECIPIENTSENDLIMITEXCEEDED` for the send result `RECIPIENT_SEND_LIMIT_EXCEEDED`.
- Added the constant `UrlMappingCosObjectTypeSTAGEDCONTENT` for the URL mapping object type `STAGED_CONTENT`.
- Added the field `JSON200` and the method `GetJSON200` on the response types of the webhooks journal `earliest`, `latest` and `offset/next` operations, both the `GetwebhooksJournaljournal202603...` and `GetwebhooksJournaljournalLocal202603...` variants. They return a `*JournalFetchResponse`.
- Some generated code moved between `client_NNN.gen.go` files. This has no effect on callers.

## v0.3.2, 2026-10-29

- Added the constant `PublicImportErrorErrorTypeMANYDUPLICATEERRORS` for the import error type `MANY_DUPLICATE_ERRORS`. The `Valid` method of `PublicImportErrorErrorType` accepts it.

## v0.3.1, 2026-10-29

- Added the constants `PreResolvedContactContactPropertiesLeadingToMatchHsSmsMobilephoneCommunicationSubscriptionsOptedIn`, `PreResolvedContactContactPropertiesLeadingToMatchHsSmsMobilephoneCommunicationSubscriptionsOptedOut`, `PreResolvedContactContactPropertiesLeadingToMatchHsSmsPhoneCommunicationSubscriptionsOptedIn` and `PreResolvedContactContactPropertiesLeadingToMatchHsSmsPhoneCommunicationSubscriptionsOptedOut` for new contact properties. The `Valid` method of `PreResolvedContactContactPropertiesLeadingToMatch` accepts them.
- The generated code moved between `client_NNN.gen.go` files. This has no effect on callers.

## v0.3.0, 2026-10-28

- Breaking: removed the CMS site search operation `GetcmssiteSearch202603searchcmssiteSearch202603search`, along with `(*ClientWithResponses).GetcmssiteSearch202603searchcmssiteSearch202603searchWithResponse` and the matching methods on `ClientInterface` and `ClientWithResponsesInterface`. The spec for API version 2026-03 no longer has this endpoint.
- Breaking: removed the types that belonged to that operation: `GetcmssiteSearch202603searchcmssiteSearch202603searchParams`, its `Language` type and constants, `ContentSearchResult`, its `Type` type and constants (`ContentSearchResultTypeBLOGPOST` and the others), and `PublicSearchResults`.
- Added the types `PreResolvedContactContactPropertiesLeadingToMatchHsCrossAccountDataMirroringSourceAccountIds`, `PreResolvedContactContactPropertiesLeadingToMatchHsWhatsappCommunicationSubscriptionsOptedIn` and `PreResolvedContactContactPropertiesLeadingToMatchHsWhatsappCommunicationSubscriptionsOptedOut` for new contact properties.
- The generated client files are split differently, so `client_005.gen.go` and `client_015.gen.go` no longer exist and the other `client_NNN.gen.go` files changed. This has no effect on callers.

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
