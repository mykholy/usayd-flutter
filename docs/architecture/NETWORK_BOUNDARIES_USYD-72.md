# Network boundaries — USYD-72 / USYD-T0079

Status: proposed, pending CI, independent review and canonical source verification.

## Scope
Keep existing routes, token storage API and public ApiClient methods. Extract URL resolution and response decoding into independently testable classes. Deduplicate the version prefix when both flavor configuration and a contract path specify /api/v1. Reject malformed non-empty 2xx JSON instead of silently returning an empty map. No new endpoints or package dependencies.

## Boundaries
- ApiEndpointResolver: pure endpoint composition, no I/O.
- ApiResponseDecoder: transport envelope parsing and typed problem details.
- ApiClient: existing HTTP orchestration and token refresh (compatibility facade).
- AuthTokenStorage: existing injected persistence port.

## Remaining work (not part of this PR)
- Verify published OpenAPI and use versioned generated DTOs.
- Extract refresh coordination and session lifecycle into separately injected components; test logout/login/refresh interleavings and account switching.
- Define timeout, cancellation, retry and idempotency policy without blind mutation replay.
- Validate endpoint origins and protected custom headers; map transport failures to localized AR/EN presentation errors.
- Verify real backend and full Flutter CI. Do not claim fixtures are integrations.
- Security-sensitive changes require independent approval. Never bypass CI or merge a failing check.

Reference: https://docs.flutter.dev/app-architecture/recommendations
