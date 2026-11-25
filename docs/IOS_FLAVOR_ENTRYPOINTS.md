# iOS flavor entrypoint policy

The native iOS scheme is authoritative. All nine flavor-specific xcconfig files intentionally assign FLUTTER_TARGET after including Generated.xcconfig, pinning the matching Dart entrypoint for Debug, Profile and Release.

An explicit Flutter CLI `-t` cannot override the pinned entrypoint on iOS. Always pass the matching target when using the CLI:

- `flutter run --flavor dev -t lib/main_dev.dart`
- `flutter run --flavor staging -t lib/main_staging.dart`
- `flutter run --flavor prod -t lib/main_prod.dart`

Use the same matching target for builds. Do not use a mismatched target to test runtime rejection on iOS: Xcode selects the pinned entrypoint before compilation. Test the Dart mismatch guard independently. Android uses the Flutter CLI target; explicit native/Dart flavor mismatches are rejected by the centralized bootstrap after the full foundation promotion.

This policy applies to native build configuration, not signed release readiness. Changes to target precedence require a separate reviewed change covering all nine configurations and the environment isolation tests.
