# Usayd Flutter — Engineering Foundation / Developer Handoff

Status: incremental foundation, not a production release. Canonical source specs and Jira acceptance criteria still govern each feature.

## Architecture

Feature-first modular Clean Architecture with MVVM, explicit constructor injection and unidirectional state flow. Start small; add use cases when orchestration or domain rules justify them.

```text
lib/
  main.dart / main_dev.dart / main_staging.dart / main_prod.dart
  app.dart                      # composition root and application lifecycle
  core/
    config/ routing/ localization/ theme/ constants/ widgets/
    network/                    # HTTP transport and protocol boundaries
    offline/                    # encrypted local persistence and sync
  features/
    <feature>/
      domain/                   # pure Dart entities, value objects, ports
      application/              # use cases, orchestration, domain failures
      data/                     # DTOs, mappers, data sources, repository adapters
      presentation/
        screens/ widgets/ view_models/ states/
test/
  architecture/                 # import boundaries
  unit/ widget/ helpers/
```

These are feature templates, not a claim that all layers already exist. Do not create empty directories or generic base classes merely to satisfy a diagram. Existing core routing and UI utilities are preserved while migrating incrementally. The shell tab metadata currently depends on Flutter IconData in a legacy domain file; it is the explicit exception in the boundary test and should move to presentation when that feature is refactored.

## Dependency rules

- Domain: no Flutter, HTTP, storage, platform APIs or feature data/presentation imports. Repository contracts belong here. Use Dart SDK types and explicitly reviewed pure abstractions.
- Application: depends on domain ports; orchestrates workflows and returns explicit outcomes, not UI strings.
- Data: implements domain ports; owns serialization, API DTOs, cache and mapping. Server contract is authoritative; do not invent API endpoints or persist fabricated successes.
- Presentation: renders immutable view state, sends commands to a view model, never calls HTTP or secure storage directly. State management may use ChangeNotifier initially; no framework dependency in domain. Inject dependencies in the composition root.
- Core: reusable technical capabilities, not a dumping ground for feature business logic. Cross-feature interaction through explicit public contracts. Keep navigation and platform services at application edges.
- Tests: fixtures belong in test/; legacy mock implementation must never be imported by production call sites.

The import test is a lightweight guard, not a full Dart AST or transitive dependency proof. Keep analyzer and review enabled. No new exemptions without documented justification.

## Feature implementation checklist

1. Read Jira task, source UI, acceptance criteria, permission matrix, and published OpenAPI version.
2. Define domain model and repository port only as needed; implement DTO and mapping in data.
3. Compose dependencies once; ensure explicit lifecycles and cancellation; do not use global mutable service locators inside widgets.
4. Implement view model and immutable loading/data/empty/error/offline states. Keep screens thin.
5. Localize every user-facing string in Arabic and English, RTL/LTR and dark/light. Existing localization dictionary is transitional; adopt generated ARB localization in a separately tested migration. Do not translate sacred Quran text.
6. Require real authenticated account identity for private offline data, preserve idempotency keys, and never automatically replay an uncertain mutation. Backend authorization remains mandatory.
7. Test use cases, data mapping and negative paths; widget tests for UI, responsive/accessibility checks; real device and API integration tests before release. Mock-based tests are not live integrations.
8. Run the quality commands below, open one focused Jira-linked PR, and fix all review findings. Never disable checks to merge.

## Commands

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test test/architecture/dependency_boundaries_test.dart
flutter test
flutter run -t lib/main_dev.dart --flavor dev
```

## Release blockers / technical debt

- Real sign-in, token restoration, session-bound transport and session change cancellation need verified Laravel integration.
- Offline retry/backoff persistence, atomic enqueue, storage migration and account switching require dedicated tests.
- Secure storage hardware protection must be verified on target devices; no blanket hardware-backed guarantee.
- Generated OpenAPI models, dependency composition, localization migration and physical device builds remain incremental work.
- No real login, payment, recording or production integration may be claimed based solely on fixtures and green unit tests.

References: https://docs.flutter.dev/app-architecture/recommendations and https://docs.flutter.dev/app-architecture/guide
