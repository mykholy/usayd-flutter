# Flutter Architecture Specification: Typed API Client, Token Storage & Refresh Contracts

## Status
- **Status:** Approved & Implemented
- **Date:** 2026-11-24
- **Owning Component:** `usayd-flutter`
- **Issue Reference:** `USYD-T0079` (Sprint S01)

## Architecture Overview
The Usayd Mobile client interacts with the Usayd Laravel 13 backend using a contract-first, typed HTTP client.
It strictly adheres to:
1. **RFC 7807 / RFC 9457 Problem Details** for all error classifications (401, 403, 404, 409, 422, 429, 500).
2. **Dual Token Bearer Authentication:** Short-lived access tokens paired with single-use rotating refresh tokens.
3. **Hardware-Backed Secure Storage:** Using `flutter_secure_storage` on iOS Keychain and Android Keystore.
4. **Transparent Automatic Token Refresh Interceptor:** Retrying failed 401 requests with backoff and single-flight execution.
5. **Separation of Preferences:** Client locale (`ar` / `en`) sent via `Accept-Language` without modifying user country, currency, or timezone.

## Core Modules
- `lib/core/network/models/auth_tokens.dart`: Typed representation of token envelope.
- `lib/core/network/models/user_profile.dart`: User profile model matching `/api/v1/auth/me`.
- `lib/core/network/problem_details_exception.dart`: Typed RFC 7807 parser extracting `traceId`, `code`, and `invalidParams`.
- `lib/core/network/token_storage.dart`: `AuthTokenStorage` abstraction with `SecureAuthTokenStorage` and `InMemoryAuthTokenStorage`.
- `lib/core/network/api_client.dart`: Production API client with automatic 401 token refresh interceptor.
- `lib/core/network/mock/mock_api_client.dart`: Explicitly flagged test fixture for offline unit and widget testing.
