# Usayd Academy — Flutter Project Bootstrap & Flavor Architecture

Documenting the implementation of **USYD-T0075** for the `usayd-flutter` repository.

---

## 1. Architecture Overview

`usayd-flutter` is an independent Flutter application targeting Android and iOS, implementing the mobile frontend for **أكاديمية أُسَيْد (Usayd Academy)**.

Key tenets:
1. **Multi-Environment Flavors**: Strict isolation between `dev`, `staging`, and `prod` with distinct bundle identifiers, app titles, and API base URLs.
2. **Age-Adaptive Interfaces**: First-class support for three interface modes:
   - **Kids (الأطفال)**: Ages 6–12 — gamified, large touch targets, high contrast.
   - **Pro (المتقدم / للبالغين)**: Ages 13–59 — full metrics, tajweed analytics, dark/light themes.
   - **Simple (البسيط / لكبار السن)**: Ages 60+ — text-first, high legibility, simplified navigation.
3. **Arabic-First RTL Foundation**: Default directionality is Right-to-Left (RTL) with Arabic locale (`ar`), accompanied by English LTR fallback (`en`).
4. **Sacred Brand Identity**: Brand name formatted strictly as **«أكاديمية أُسَيْد»** with proper diacritics and sacred tagline:
   > *«اقرأ بصوتٍ تدنو له الملائكة»* (Recite with a voice that angels draw near to hear).

---

## 2. Environments & Flavor Configuration

| Environment | Flavor | App Identifier (`applicationId`) | App Name | Default API Base URL |
|---|---|---|---|---|
| **Development** | `dev` | `academy.usayd.learner.dev` | `أكاديمية أُسَيْد (Dev)` | `http://10.0.2.2:8000/api/v1` (Android) / `http://127.0.0.1:8000/api/v1` (iOS) |
| **Staging** | `staging` | `academy.usayd.learner.stg` | `أكاديمية أُسَيْد (Staging)` | `https://staging-api.usayd.academy/api/v1` |
| **Production** | `prod` | `academy.usayd.learner` | `أكاديمية أُسَيْد` | `https://api.usayd.academy/api/v1` |

### Entrypoints
- `lib/main_dev.dart` — Initializes `FlavorConfig` with `AppFlavor.dev`.
- `lib/main_staging.dart` — Initializes `FlavorConfig` with `AppFlavor.staging`.
- `lib/main_prod.dart` — Initializes `FlavorConfig` with `AppFlavor.prod`.
- `lib/main.dart` — Default fallback launcher (defaults to `prod` if not initialized).

### Android Gradle Flavor Dimensions
Configured in `android/app/build.gradle.kts`:
```kotlin
flavorDimensions += "environment"
productFlavors {
    create("dev") {
        dimension = "environment"
        applicationIdSuffix = ".dev"
        resValue("string", "app_name", "أكاديمية أُسَيْد (Dev)")
    }
    create("staging") {
        dimension = "environment"
        applicationIdSuffix = ".stg"
        resValue("string", "app_name", "أكاديمية أُسَيْد (Staging)")
    }
    create("prod") {
        dimension = "environment"
        resValue("string", "app_name", "أكاديمية أُسَيْد")
    }
}
```

---

## 3. Age-Adaptive Mode Specifications

| Mode Key | Mode Name (AR) | Target Age | Target Audience | Key UX Characteristics |
|---|---|---|---|---|
| `kids` | الوضع الطفولي | 6–12 | الناشئة والأطفال | Gamified visual tokens, badge reward indicators, high vibrant contrast |
| `pro` | الوضع المتقدم | 13–59 | الحُفّاظ والبالغون | Full tajweed analytics, precision audio waveforms, dark/light themes |
| `simple` | الوضع البسيط | 60+ | كبار السن | Extra-large typography, clear high-contrast borders, minimal distraction |

Defined in `lib/core/config/interface_mode.dart`.

---

## 4. Verification & Testing

### Test Suite (`test/`)
- `test/unit/flavor_config_test.dart`:
  - Unit tests for singleton immutability, per-flavor API endpoints, and bundle IDs.
  - Negative tests: throws on reinitialization without override, handles null-safe lookups.
- `test/unit/interface_mode_test.dart`:
  - Unit tests for all three age-adaptive modes, string serialization, and age-based mode resolution.
  - Boundary test: handles edge ages (6, 12, 13, 59, 60) deterministically.
- `test/widget/app_widget_test.dart`:
  - Validates RTL layout direction, Arabic brand title «أكاديمية أُسَيْد», and tagline rendering.
- `test/widget/mode_toggle_test.dart`:
  - Validates interactive mode selection between Kids, Pro, and Simple modes with state preservation.

### Commands
```bash
# Format check
dart format --output=none --set-exit-if-changed .

# Static analysis
flutter analyze

# Execute test suite
flutter test
```
