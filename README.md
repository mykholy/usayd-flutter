# Usayd Academy — Mobile Application (Flutter)

Independent Flutter mobile application for **أكاديمية أُسَيْد (Usayd Academy)** supporting Android and iOS with age-adaptive interfaces (Kids, Pro, Simple) and offline-first synchronization.

---

## Features
- **Multi-Environment Flavors**: Separate configurations for `dev`, `staging`, and `prod`.
- **Age-Adaptive Interfaces**:
  - `kids` (6–12 years): Gamified, high-contrast, playful rewards.
  - `pro` (13–59 years): Advanced tajweed analysis, detailed progress, dark/light modes.
  - `simple` (60+ years): High legibility, large touch targets, simplified flows.
- **RTL Arabic First**: Deep Arabic RTL integration with authentic typography and diacritics.
- **Contract-Driven**: Aligned with versioned OpenAPI 3.1 contracts from `usayd-api`.

---

## Local Development & Running

### Prerequisites
- Flutter SDK 3.x+ (`flutter --version`)
- Dart SDK 3.x+
- Android Studio / Xcode configured

### Run by Flavor
```bash
# Development flavor
flutter run -t lib/main_dev.dart --flavor dev

# Staging flavor
flutter run -t lib/main_staging.dart --flavor staging

# Production flavor
flutter run -t lib/main_prod.dart --flavor prod
```

### Quality & Test Suite
```bash
# Format code
dart format .

# Check formatting without modifying
dart format --output=none --set-exit-if-changed .

# Static analysis
flutter analyze

# Run all unit and widget tests
flutter test
```

---

## Documentation
- [Flutter Bootstrap & Flavors Guide](docs/FLUTTER_BOOTSTRAP_AND_FLAVORS.md)
- [Design Tokens & Asset Architecture](docs/FLUTTER_DESIGN_TOKENS_AND_ASSETS.md)
- [RTL/LTR Localization & Theme Architecture](docs/FLUTTER_LOCALIZATION_AND_THEMES.md)
- [Architecture & Governance](AGENTS.md)
