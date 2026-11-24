# Usayd Academy — Flutter Responsive Shell & Navigation Architecture

Documenting the implementation of **USYD-T0078** for the `usayd-flutter` repository.

---

## 1. Overview & Canon References

The navigation architecture of the Usayd Academy mobile application is age-adaptive and responsive, conforming to:
- `02_design_system/AGE_ADAPTIVE_UI.md`: Screen counts, tab identifiers, and visual density rules per interface mode.
- `03_screens/SCREEN_INVENTORY.csv`: Screen definitions across Kids, Professional, and Simple modes.
- Material Design 3 guidelines: Adaptive bottom navigation with safe-area and virtual keyboard handling.

---

## 2. Age-Adaptive Navigation Shells (`ShellTab` & `AdaptiveShell`)

Implemented in `lib/features/shell/domain/shell_tab.dart` and `lib/features/shell/presentation/adaptive_shell.dart`.

### Per-Mode Navigation Matrix
| Interface Mode | Tab Count | Tabs (IDs) | Arabic Labels | English Labels | Height | Touch Target |
|---|---|---|---|---|---|---|
| **Kids (6–12)** | 4 | `mission`, `path`, `stars`, `me` | مهمتي، طريقي، نجومي، أنا | Mission, Path, Stars, Me | 70 px | 56 px |
| **Professional (13–59)** | 5 | `home`, `lessons`, `recite`, `progress`, `profile` | الرئيسية، الدروس، التلاوة، تقدمي، حسابي | Home, Lessons, Recite, Progress, Profile | 64 px | 44 px |
| **Simple (60+)** | 3 | `today`, `lessons`, `help` | ورد اليوم، الدروس، المساعدة | Today, Lessons, Help | 76 px | 60 px |

---

## 3. Keyboard Handling & Safe Area Invariants

1. **`resizeToAvoidBottomInset: true`**:
   - Ensures that when software keyboards (IME) are displayed, the bottom navigation bar is cleanly pushed or hidden without obscuring active form inputs or triggering `RenderFlex` overflow errors.
2. **Safe Area Discipline**:
   - `SafeArea` protects against hardware notches, rounded display corners, and device home indicators on Android and iOS.
3. **Safe Mode-Switch Clamping**:
   - When a user changes their interface mode (e.g. from Professional with 5 tabs to Simple with 3 tabs), `_selectedIndex` is safely clamped to 0 to prevent index-out-of-bounds exceptions.

---

## 4. Verification Matrix

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```
- Total test coverage: **47 tests** passing across:
  - `shell_tabs_test.dart`
  - `shell_widget_test.dart`
  - `localization_independence_test.dart`
  - `localization_widget_test.dart`
  - `theme_tokens_test.dart`
  - `theme_widget_test.dart`
  - `assets_test.dart`
  - `flavor_config_test.dart`
  - `interface_mode_test.dart`
  - `app_widget_test.dart`
  - `mode_toggle_test.dart`
