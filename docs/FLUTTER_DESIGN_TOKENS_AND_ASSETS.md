# Usayd Academy — Flutter Design Tokens, Theme Extensions & Asset Architecture

Documenting the implementation of **USYD-T0076** for the `usayd-flutter` repository.

---

## 1. Overview & Canon References

The design system for Usayd Academy mobile app adheres strictly to:
- `02_design_system/tokens.color.v0.4.json`: Authoritative light and dark color values.
- `02_design_system/tokens.json`: Primitives for spacing, radii, typography, and elevation.
- `02_design_system/BRAND.md`: Brand identity, ratio rules (~60% parchment, 30% night, 10% lamp gold), sacred name («أُسَيْد») and tagline («اقرأ بصوتٍ تدنو له الملائكة»).
- `02_design_system/AGE_ADAPTIVE_UI.md`: Specifications for Kids (6–12), Professional (13–59), and Simple (60+) modes.

---

## 2. Color System (`UsaydColorScheme`)

Implemented as a `ThemeExtension<UsaydColorScheme>` in `lib/core/theme/usayd_colors.dart`.

### Sacred Palette & Accessibility Rules
- **Brand Ratio**: ~60% parchment surface, 30% night brand, 10% lamp gold.
- **Lamp Contrast Rule**: Lamp gold (`#E8B04B`) is an accent glow and is **never** used as text on parchment. On light backgrounds, Brass (`#8A5F12`) provides accessible high-contrast text.
- **Prohibited**: Purple/blue gradients, neon colors, and anthropomorphic face depictions on educational components.

### Core Hex Mapping
| Token | Role | Light Theme (`tokens.color.v0.4.json`) | Dark Theme (`tokens.color.v0.4.json`) |
|---|---|---|---|
| `bgPage` | Page background | `#FBF7EE` (Parchment) | `#0A1B1E` (Night Deep) |
| `bgRaised` | Card / surface | `#FFFDF8` | `#11282C` |
| `bgSubtle` | Subtle container | `#F4ECDC` | `#173237` |
| `bgBrand` | Primary brand surface | `#0F2529` (Night Forest) | `#06141A` |
| `tx` | Primary text | `#1A1814` (Ink) | `#F4EDDF` (Parchment Text) |
| `tx2` | Secondary text | `#57524A` | `#BFB8A9` |
| `act` | Primary interactive | `#0F2529` | `#E8B04B` (Lamp Gold) |
| `lamp` | Accent glow | `#E8B04B` | `#E8B04B` |
| `brass` | High-contrast accessible gold | `#8A5F12` | `#F0C25F` |
| `ok` | Success | `#2A6448` | `#7DCBA3` |
| `err` | Error | `#A33725` | `#F29C87` |
| `warn` | Warning | `#835A10` | `#EDC26C` |
| `info` | Informational | `#285876` | `#92C3DF` |

---

## 3. Spacing & Radii (`UsaydSpacing` & `UsaydRadii`)

- **Spacing** (`lib/core/theme/usayd_spacing.dart`):
  - `xxs`: 2px, `xs`: 4px, `sm`: 8px, `smPlus`: 12px
  - `md`: 16px (base unit), `mdPlus`: 20px
  - `lg`: 24px, `xl`: 32px, `xlPlus`: 40px
  - `xxl`: 48px, `xxxl`: 64px, `xxxxl`: 80px, `xxxxxl`: 96px
- **Radii** (`lib/core/theme/usayd_radii.dart`):
  - `xs`: 4px, `sm`: 6px, `md`: 14px, `lg`: 20px, `xl`: 28px
  - `full`: 999px (pills, round badges)
  - `arch`: 999px top radius with flat bottom for architectural Quranic frames.

---

## 4. Typography (`UsaydTypography`)

- **Heading & Display Font**: `Reem Kufi` (with fallbacks `Noto Sans Arabic`, `sans-serif`)
- **Body & Content Font**: `IBM Plex Sans Arabic` (with fallbacks `Noto Sans Arabic`, `sans-serif`)
- **Type Scale**:
  - `displayL` (56/68 SemiBold), `displayM` (44/58 SemiBold), `displayS` (36/48 SemiBold)
  - `headingL` (26/38 Medium), `headingM` (20/32 SemiBold), `headingS` (17/28 SemiBold)
  - `bodyL` (19/33 Regular), `bodyM` (17/30 Regular), `bodyS` (14/24 Regular)
  - `caption` (12/20 Regular)

---

## 5. Age-Adaptive Theme Extension (`UsaydModeTheme`)

Implemented in `lib/core/theme/usayd_mode_theme.dart` conforming to `AGE_ADAPTIVE_UI.md`:

| Attribute | Kids Mode (6–12 yrs) | Professional Mode (13–59 yrs) | Simple Mode (60+ yrs) |
|---|---|---|---|
| `bodyTextSize` | 16.0 px | 15.5 px | 19.5 px |
| `buttonHeight` | 56.0 px | 48.0 px | 60.0 px |
| `cardRadius` | 24.0 px | 20.0 px | 20.0 px |
| `cardBorderWidth` | 0.0 px | 0.0 px | 1.5 px (high contrast) |
| `tabCount` | 4 (Mission, Path, Stars, Me) | 5 (Home, Study, Recite, Progress, Profile) | 3 (Today, Lessons, Help) |
| `hasMotion` | `true` (gentle animation) | `true` (standard) | `false` (motion disabled) |
| `minTouchTarget` | 56.0 px | 44.0 px | 60.0 px |

---

## 6. Asset Ownership & Linking (`UsaydAssets`)

Located under `assets/` and declared in `pubspec.yaml`:
- **Brand Marks**: `assets/icons/usayd-mark-color.svg`, `usayd-mark-reverse.svg`, `usayd-app-icon.svg`.
- **Illustrations**:
  - Kids medals & rewards: `kids-badge-crown.svg`, `kids-badge-book-open.svg`, `kids-badge-flame.svg`, etc.
  - Kids lantern avatars: `kids-lantern-coral.svg`, `kids-lantern-gold.svg`, `kids-lantern-mint.svg`, `kids-lantern-sky.svg`.
  - Educational & status spots: `spot-foundations.svg`, `spot-tajweed.svg`, `spot-memorize.svg`, `spot-success.svg`, `spot-error.svg`, `spot-ai.svg`.
- **Cultural Safeguard**: All illustrations are strictly vector, geometric, and object-based (lanterns, mushafs, stars). No faces of living beings or depictions of Sahaba are included.

---

## 7. Verification Matrix

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```
- Total test coverage: 29 tests passing across `theme_tokens_test.dart`, `assets_test.dart`, `flavor_config_test.dart`, `interface_mode_test.dart`, `app_widget_test.dart`, `mode_toggle_test.dart`, and `theme_widget_test.dart`.
