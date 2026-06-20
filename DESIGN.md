# Aedify Design System — Flutter Implementation

This document is the self-contained visual design system for Aedify. It is written for Flutter implementation, so all dimensions, spacing, radii, font sizes, line heights, letter spacing, and shadows use Flutter-friendly logical pixels unless explicitly stated otherwise.

## Flutter Unit Rules

- Treat every numeric size as a Flutter logical pixel value, suitable for values such as `EdgeInsets`, `SizedBox`, `BorderRadius`, `BoxConstraints`, `TextStyle.fontSize`, and `TextStyle.letterSpacing`.
- Colors are written as design hex values. In Flutter, convert `#RRGGBB` to `Color(0xFFRRGGBB)`.
- Typography includes both `lineHeight` and `height`:
  - `lineHeight` is the intended visual line box in logical pixels.
  - `height` is the Flutter `TextStyle.height` multiplier: `lineHeight / fontSize`.
- Font weights use Flutter naming: `FontWeight.w400`, `FontWeight.w500`, `FontWeight.w600`, `FontWeight.w700`.
- Letter spacing uses Flutter logical pixels. Previous relative tracking has been converted into fixed logical-pixel values.
- Radius values are numeric. `full: 9999.0` means use a pill/capsule radius large enough to fully round the shape.
- Prefer constants in code, for example `AedifySpacing.medium`, `AedifyRadius.lg`, and `AedifyTypography.bodyMd`.

---

## Theme Tokens

### Light Theme Tokens

```yaml
name: Serene Professional
colors:
  surface: '#f8f9ff'
  surfaceDim: '#cbdbf5'
  surfaceBright: '#f8f9ff'
  surfaceContainerLowest: '#ffffff'
  surfaceContainerLow: '#eff4ff'
  surfaceContainer: '#e5eeff'
  surfaceContainerHigh: '#dce9ff'
  surfaceContainerHighest: '#d3e4fe'
  onSurface: '#0b1c30'
  onSurfaceVariant: '#44474c'
  inverseSurface: '#213145'
  inverseOnSurface: '#eaf1ff'
  outline: '#75777d'
  outlineVariant: '#c5c6cd'
  surfaceTint: '#525f75'
  primary: '#000000'
  onPrimary: '#ffffff'
  primaryContainer: '#0e1c2f'
  onPrimaryContainer: '#77849c'
  inversePrimary: '#b9c7e1'
  secondary: '#0051d5'
  onSecondary: '#ffffff'
  secondaryContainer: '#316bf3'
  onSecondaryContainer: '#fefcff'
  tertiary: '#000000'
  onTertiary: '#ffffff'
  tertiaryContainer: '#191c1e'
  onTertiaryContainer: '#818486'
  error: '#ba1a1a'
  onError: '#ffffff'
  errorContainer: '#ffdad6'
  onErrorContainer: '#93000a'
  primaryFixed: '#d5e3fd'
  primaryFixedDim: '#b9c7e1'
  onPrimaryFixed: '#0e1c2f'
  onPrimaryFixedVariant: '#3a475c'
  secondaryFixed: '#dbe1ff'
  secondaryFixedDim: '#b4c5ff'
  onSecondaryFixed: '#00174b'
  onSecondaryFixedVariant: '#003ea8'
  tertiaryFixed: '#e0e3e5'
  tertiaryFixedDim: '#c4c7c9'
  onTertiaryFixed: '#191c1e'
  onTertiaryFixedVariant: '#444749'
  background: '#f8f9ff'
  onBackground: '#0b1c30'
  surfaceVariant: '#d3e4fe'

typography:
  headlineXl:
    fontFamily: Manrope
    fontSize: 40.0
    fontWeight: FontWeight.w700
    lineHeight: 48.0
    height: 1.20
    letterSpacing: -0.80
  headlineLg:
    fontFamily: Manrope
    fontSize: 32.0
    fontWeight: FontWeight.w600
    lineHeight: 40.0
    height: 1.25
    letterSpacing: -0.32
  headlineLgMobile:
    fontFamily: Manrope
    fontSize: 24.0
    fontWeight: FontWeight.w600
    lineHeight: 32.0
    height: 1.333
    letterSpacing: 0.0
  headlineMd:
    fontFamily: Manrope
    fontSize: 24.0
    fontWeight: FontWeight.w600
    lineHeight: 32.0
    height: 1.333
    letterSpacing: 0.0
  bodyLg:
    fontFamily: Manrope
    fontSize: 18.0
    fontWeight: FontWeight.w400
    lineHeight: 28.0
    height: 1.556
    letterSpacing: 0.0
  bodyMd:
    fontFamily: Manrope
    fontSize: 16.0
    fontWeight: FontWeight.w400
    lineHeight: 24.0
    height: 1.50
    letterSpacing: 0.0
  labelMd:
    fontFamily: Manrope
    fontSize: 14.0
    fontWeight: FontWeight.w600
    lineHeight: 20.0
    height: 1.429
    letterSpacing: 0.14
  labelSm:
    fontFamily: Manrope
    fontSize: 12.0
    fontWeight: FontWeight.w500
    lineHeight: 16.0
    height: 1.333
    letterSpacing: 0.24

radius:
  sm: 4.0
  default: 8.0
  md: 12.0
  lg: 16.0
  xl: 24.0
  full: 9999.0

spacing:
  baseUnit: 4.0
  gutter: 24.0
  marginMobile: 16.0
  marginDesktop: 48.0
  containerMax: 1280.0
```

### Dark Theme Tokens

```yaml
name: Serene Professional Dark
colors:
  surface: '#11131b'
  surfaceDim: '#11131b'
  surfaceBright: '#373942'
  surfaceContainerLowest: '#0c0e16'
  surfaceContainerLow: '#191b23'
  surfaceContainer: '#1d1f27'
  surfaceContainerHigh: '#282a32'
  surfaceContainerHighest: '#32343d'
  onSurface: '#e1e2ed'
  onSurfaceVariant: '#c3c6d7'
  inverseSurface: '#e1e2ed'
  inverseOnSurface: '#2e3039'
  outline: '#8d90a0'
  outlineVariant: '#434655'
  surfaceTint: '#b4c5ff'
  primary: '#b4c5ff'
  onPrimary: '#002a78'
  primaryContainer: '#2563eb'
  onPrimaryContainer: '#eeefff'
  inversePrimary: '#0053db'
  secondary: '#b9c7e1'
  onSecondary: '#243145'
  secondaryContainer: '#3d4a5f'
  onSecondaryContainer: '#abb9d2'
  tertiary: '#ffb596'
  onTertiary: '#581e00'
  tertiaryContainer: '#bc4800'
  onTertiaryContainer: '#ffede6'
  error: '#ffb4ab'
  onError: '#690005'
  errorContainer: '#93000a'
  onErrorContainer: '#ffdad6'
  primaryFixed: '#dbe1ff'
  primaryFixedDim: '#b4c5ff'
  onPrimaryFixed: '#00174b'
  onPrimaryFixedVariant: '#003ea8'
  secondaryFixed: '#d5e3fd'
  secondaryFixedDim: '#b9c7e1'
  onSecondaryFixed: '#0e1c2f'
  onSecondaryFixedVariant: '#3a475c'
  tertiaryFixed: '#ffdbcd'
  tertiaryFixedDim: '#ffb596'
  onTertiaryFixed: '#360f00'
  onTertiaryFixedVariant: '#7d2d00'
  background: '#11131b'
  onBackground: '#e1e2ed'
  surfaceVariant: '#32343d'

typography:
  headlineXl:
    fontFamily: Manrope
    fontSize: 40.0
    fontWeight: FontWeight.w700
    lineHeight: 48.0
    height: 1.20
    letterSpacing: -0.80
  headlineLg:
    fontFamily: Manrope
    fontSize: 32.0
    fontWeight: FontWeight.w600
    lineHeight: 40.0
    height: 1.25
    letterSpacing: -0.32
  headlineLgMobile:
    fontFamily: Manrope
    fontSize: 28.0
    fontWeight: FontWeight.w600
    lineHeight: 36.0
    height: 1.286
    letterSpacing: 0.0
  headlineMd:
    fontFamily: Manrope
    fontSize: 24.0
    fontWeight: FontWeight.w600
    lineHeight: 32.0
    height: 1.333
    letterSpacing: 0.0
  bodyLg:
    fontFamily: Inter
    fontSize: 18.0
    fontWeight: FontWeight.w400
    lineHeight: 28.0
    height: 1.556
    letterSpacing: 0.0
  bodyMd:
    fontFamily: Inter
    fontSize: 16.0
    fontWeight: FontWeight.w400
    lineHeight: 24.0
    height: 1.50
    letterSpacing: 0.0
  bodySm:
    fontFamily: Inter
    fontSize: 14.0
    fontWeight: FontWeight.w400
    lineHeight: 20.0
    height: 1.429
    letterSpacing: 0.0
  labelMd:
    fontFamily: Inter
    fontSize: 14.0
    fontWeight: FontWeight.w600
    lineHeight: 16.0
    height: 1.143
    letterSpacing: 0.14
  labelSm:
    fontFamily: Inter
    fontSize: 12.0
    fontWeight: FontWeight.w500
    lineHeight: 14.0
    height: 1.167
    letterSpacing: 0.24

radius:
  sm: 4.0
  default: 8.0
  md: 12.0
  lg: 16.0
  xl: 24.0
  full: 9999.0

spacing:
  baseUnit: 4.0
  containerMax: 1280.0
  gutter: 24.0
  marginDesktop: 40.0
  marginMobile: 16.0
  stackSm: 8.0
  stackMd: 16.0
  stackLg: 32.0
```

---

## Overview

Aedify’s design direction is a serene, premium, visual-first product interface: calm, highly structured, and intentionally restrained. The interface should feel like a high-trust training companion where content, progress, exercises, programmes, and user decisions take focus while UI chrome recedes.

The system uses:

- full-bleed content sections;
- alternating light and dark canvases;
- centered headline-led sections;
- minimal borders and minimal decorative effects;
- pill-shaped primary actions;
- product/media imagery treated as the main visual artifact;
- clear hierarchy through spacing, surface contrast, and typography rather than visual noise.

All colors and typography must come from the tokens in this document.

## Colors

### Color Source of Truth

Use the color tokens declared in this document. Do not introduce untracked brand colors, one-off blues, decorative gradients, or hard-coded component colors outside the token set.

### Light Mode Color Mapping

| Role | Token | Use |
|---|---|---|
| Page canvas | `{light.colors.background}` / `{light.colors.surface}` | Default app background and full-page surfaces |
| Lowest elevated surface | `{light.colors.surfaceContainerLowest}` | Cards and high-emphasis panels that need clean contrast |
| Tonal sections | `{light.colors.surfaceContainerLow}`, `{light.colors.surfaceContainer}`, `{light.colors.surfaceContainerHigh}`, `{light.colors.surfaceContainerHighest}` | Alternating section rhythm and nested surface hierarchy |
| Primary text | `{light.colors.onSurface}` | Main headings and body text |
| Secondary text | `{light.colors.onSurfaceVariant}` | Supporting copy, labels, muted explanations |
| Brand anchor | `{light.colors.primary}` / `{light.colors.primaryContainer}` | Brand-heavy surfaces, navigation anchors, high-integrity headers |
| Interactive action | `{light.colors.secondary}` / `{light.colors.secondaryContainer}` | Primary CTAs, active states, links, focus accents |
| Borders / dividers | `{light.colors.outline}`, `{light.colors.outlineVariant}` | Hairlines and subtle dividers only when tonal separation is insufficient |
| Error | `{light.colors.error}`, `{light.colors.errorContainer}` | Validation, destructive states, safety warnings |

### Dark Mode Color Mapping

| Role | Token | Use |
|---|---|---|
| Page canvas | `{dark.colors.background}` / `{dark.colors.surface}` | Default low-light background |
| Deepest layer | `{dark.colors.surfaceContainerLowest}` | Base layer behind cards or full-screen panels |
| Elevated surfaces | `{dark.colors.surfaceContainerLow}`, `{dark.colors.surfaceContainer}`, `{dark.colors.surfaceContainerHigh}`, `{dark.colors.surfaceContainerHighest}` | Tonal elevation steps |
| Primary text | `{dark.colors.onSurface}` | Main headings and body text |
| Secondary text | `{dark.colors.onSurfaceVariant}` | Supporting copy, labels, muted explanations |
| Interactive action | `{dark.colors.primary}` / `{dark.colors.primaryContainer}` | Links, focus states, primary CTAs, active states |
| Secondary surfaces | `{dark.colors.secondaryContainer}` | Secondary buttons, inactive chips, grouped controls |
| Borders / dividers | `{dark.colors.outline}`, `{dark.colors.outlineVariant}` | Hairlines and subtle surface boundaries |
| Error | `{dark.colors.error}`, `{dark.colors.errorContainer}` | Validation, destructive states, safety warnings |

### Color Principles

- Use one main interactive accent per mode:
  - Light mode: `{light.colors.secondary}` for links and primary interactions.
  - Dark mode: `{dark.colors.primaryContainer}` for solid CTAs and `{dark.colors.primary}` for links/focus.
- Let surface alternation create section separation before adding borders.
- Prefer tonal shifts over decorative gradients.
- Use strong contrast only where action or readability requires it.
- Do not introduce non-theme blues or extra accent colors.

## Typography

### Type Role Mapping

| Product Role | Light Theme Token | Dark Theme Token | Use |
|---|---|---|---|
| Hero headline | `headlineXl` | `headlineXl` | Large marketing-style section headers, onboarding hero copy, major empty states |
| Section headline | `headlineLg` | `headlineLg` | Dashboard sections, programme headers, feature entry points |
| Mobile headline | `headlineLgMobile` | `headlineLgMobile` | Compact hero or section titles on constrained surfaces |
| Card headline | `headlineMd` | `headlineMd` | Cards, workout summary titles, modal titles |
| Large body / lead | `bodyLg` | `bodyLg` | Lead paragraphs, explanatory text, high-emphasis descriptions |
| Standard body | `bodyMd` | `bodyMd` | Default readable body copy |
| Small body | Use `labelMd` or define a light `bodySm` token if needed | `bodySm` | Dense metadata, helper text, supporting details |
| Medium label | `labelMd` | `labelMd` | Buttons, tabs, nav labels, form labels |
| Small label | `labelSm` | `labelSm` | Chips, metadata tags, compact annotations |

### Typography Principles

- Use the Aedify typography tokens as declared in this document.
- Preserve each mode’s declared font families:
  - Light mode uses Manrope across its typography scale.
  - Dark mode uses Manrope for headings and Inter for body/labels.
- Use weight and spacing before adding decorative hierarchy.
- Keep line heights generous for readability.
- Avoid unnecessary all-caps labels unless the product context demands it.
- When implementing in Flutter, set both `fontSize` and `height` from the token.

## Layout

Aedify’s layout should feel like a sequence of carefully staged scenes, not a dense stack of panels.

### Layout Model

- **Full-bleed sections:** Major product moments, onboarding screens, progress summaries, programme summaries, and feature entry surfaces can use edge-to-edge tiles.
- **Centered hero stack:** Important sections should use a centered vertical stack:
  1. headline;
  2. short supporting line;
  3. primary/secondary action row;
  4. visual, preview, chart, media, or card group.
- **Alternating canvases:** Use light/dark or tonal surface alternation to separate major sections. The surface change acts as the divider.
- **Visual-first hierarchy:** When a section has a meaningful visual artifact, such as a progress image, exercise video, bodymap, chart, programme timeline, or workout summary card, let that artifact carry the section. Keep surrounding UI minimal.
- **Low chrome:** Avoid decorative frames, excessive card borders, heavy app bars, or ornamental gradients.
- **Dense areas are intentional:** Data-heavy surfaces such as logs, exercise lists, import reviews, and settings may use tighter density, but they should still rely on clean grouping, typography, and tonal layers.

### Spacing System

- Use the active theme’s spacing tokens as Flutter constants.
- Use the 4.0 logical-pixel base unit where the theme defines it.
- Snap component spacing to 8.0 logical-pixel multiples whenever practical.
- Use large vertical spacing between major sections, typically 64.0–96.0 logical pixels depending on screen density.
- Use `gutter`, `marginMobile`, `marginDesktop`, and `containerMax` from the active theme.
- Keep card and utility group padding consistent, usually 16.0–24.0 logical pixels.
- Let empty space create premium calm; do not fill every viewport with controls.

### Grid & Container

- Use a maximum content container for dense app content.
- Let hero and visual-first sections stretch full-bleed when the section benefits from immersion.
- Use multi-column layouts for utility grids, cards, exercise categories, and programme previews where space allows.
- Use centered single-column layout for focused decision flows, onboarding steps, AI consent screens, import review confirmations, and privacy-sensitive actions.
- In Flutter, prefer `LayoutBuilder`, `Sliver` layouts, `CustomScrollView`, `GridView`, and reusable breakpoint helpers over hard-coded screen assumptions.

## Elevation & Depth

Aedify uses restrained depth. Depth should be felt through tonal layering, surface transitions, borders, and occasional media shadows, not through heavy UI shadows.

### Elevation Model

| Level | Light Mode Treatment | Dark Mode Treatment | Use |
|---|---|---|---|
| Level 0 — Canvas | `{light.colors.background}` / `{light.colors.surface}` | `{dark.colors.background}` / `{dark.colors.surface}` | App background and full-bleed base sections |
| Level 1 — Section / Card | `{light.colors.surfaceContainerLowest}` or `{light.colors.surfaceContainerLow}` | `{dark.colors.surfaceContainerLow}` or `{dark.colors.surfaceContainer}` | Cards, panels, dashboard sections, list containers |
| Level 2 — Raised Surface | `{light.colors.surfaceContainer}` / `{light.colors.surfaceContainerHigh}` | `{dark.colors.surfaceContainerHigh}` | Modals, popovers, selected panels, focused utility cards |
| Level 3 — Highest Surface | `{light.colors.surfaceContainerHighest}` | `{dark.colors.surfaceContainerHighest}` | Floating sheets, high-priority overlays, active selection surfaces |
| Hairline | `{light.colors.outlineVariant}` | `{dark.colors.outlineVariant}` | Subtle borders where tonal contrast is insufficient |
| Active / Focus Glow | `{light.colors.secondary}` with low opacity | `{dark.colors.primary}` or `{dark.colors.primaryContainer}` with low opacity | Focused inputs, selected chips, important active states |
| Media Shadow | Theme-tinted soft shadow only | Theme-tinted soft glow or soft shadow only | Progress media, exercise media, hero visuals, product-like previews |

### Flutter Shadow Guidance

Use Flutter `BoxShadow` sparingly. Prefer tonal surface changes first.

```dart
const aedifySoftMediaShadow = BoxShadow(
  color: Color(0x33000000),
  offset: Offset(0.0, 8.0),
  blurRadius: 30.0,
  spreadRadius: 0.0,
);
```

For dark mode, prefer a low-opacity glow from the active accent or a slightly lighter surface instead of a black shadow.

### Depth Principles

- Use tonal surfaces before shadows.
- Use hairlines only when whitespace and tonal contrast are not enough.
- Avoid heavy black shadows, especially in dark mode.
- Cards should feel calm and placed, not floating aggressively.
- Progress photos, exercise videos, bodymaps, and hero visuals may receive a soft shadow/glow because they function as the artifact of the section.
- Do not apply dramatic shadows to text, buttons, navigation, or routine UI chrome.
- Sticky bars, modals, and bottom sheets may use tonal elevation. Backdrop blur can be used where Flutter platform support is stable and the effect remains subtle.

## Shapes

Aedify merges rectangular full-bleed section logic with a disciplined rounded token scale.

### Shape Rules

| Shape Role | Token | Flutter Value | Use |
|---|---|---:|---|
| No rounding | none | `0.0` | Full-bleed hero sections, edge-to-edge tiles, large page bands |
| Small rounding | `radius.sm` | `4.0` | Compact buttons, inline images, small utility controls |
| Default rounding | `radius.default` | `8.0` | Standard buttons, inputs, smaller cards |
| Medium rounding | `radius.md` | `12.0` | Form controls, filter panels, medium cards |
| Large rounding | `radius.lg` | `16.0` | Modals, sheets, large containers |
| Extra-large rounding | `radius.xl` | `24.0` | High-emphasis cards, dashboard panels, visual cards |
| Pill / Full | `radius.full` | `9999.0` | Primary action pills, chips, tags, tab pills, search inputs, filter chips |

### Shape Principles

- Full-bleed sections should remain rectangular. Do not round the outer edges of major page bands.
- Primary actions should use the pill grammar when they need to feel premium, focused, and clearly tappable.
- Cards and app containers should use the theme radius scale, not arbitrary radii.
- Use larger radii for large surfaces and smaller radii for compact utility controls.
- Keep shape language consistent across light and dark mode.
- Do not mix many radii in one component group.

## Components

### Navigation

Navigation should feel stable and quiet.

- Use strong brand anchoring sparingly.
- In light mode, brand-heavy navigation can use `{light.colors.primary}` or `{light.colors.primaryContainer}`.
- In dark mode, navigation should sit on tonal surfaces such as `{dark.colors.surfaceContainerLowest}`, `{dark.colors.surfaceContainerLow}`, or `{dark.colors.surfaceContainer}`.
- Active items should use the mode’s interactive accent:
  - Light: `{light.colors.secondary}` / `{light.colors.secondaryContainer}`
  - Dark: `{dark.colors.primary}` / `{dark.colors.primaryContainer}`
- Avoid loud nav borders unless the surface contrast needs help.

### Buttons

#### Primary Button

- Light mode:
  - Fill: `{light.colors.secondary}` or `{light.colors.secondaryContainer}`.
  - Text: `{light.colors.onSecondary}` or `{light.colors.onSecondaryContainer}`.
- Dark mode:
  - Fill: `{dark.colors.primaryContainer}`.
  - Text: `{dark.colors.onPrimaryContainer}`.
- Shape: `radius.full` for premium action CTAs, `radius.default` where compact utility is more appropriate.
- Typography: `labelMd`.
- Typical padding: horizontal 20.0–24.0, vertical 10.0–12.0.
- Minimum tap target: 44.0 × 44.0.

#### Secondary Button

- Light mode:
  - Fill: `{light.colors.surfaceContainerLow}` or transparent.
  - Text: `{light.colors.onSurface}` or `{light.colors.secondary}`.
  - Border: `{light.colors.outlineVariant}` when required.
- Dark mode:
  - Fill: `{dark.colors.surfaceContainerHigh}` or transparent.
  - Text: `{dark.colors.onSurface}` or `{dark.colors.primary}`.
  - Border: `{dark.colors.outlineVariant}` when required.
- Typical padding: horizontal 18.0–22.0, vertical 10.0–12.0.

#### Pressed / Active State

- Use a small scale reduction, typically `Transform.scale(scale: 0.98)`, or a tonal state shift.
- Do not introduce a separate active color outside the theme.
- Keep motion subtle and fast.

### Text Links

- Light mode links use `{light.colors.secondary}`.
- Dark mode links use `{dark.colors.primary}`.
- Use links for inline navigation and secondary actions.
- Do not add a second link color.

### Cards & Containers

#### Full-Bleed Feature Tile

- Shape: no outer rounding.
- Background:
  - Light: `{light.colors.surface}`, `{light.colors.surfaceContainerLow}`, or `{light.colors.surfaceContainer}`.
  - Dark: `{dark.colors.surface}`, `{dark.colors.surfaceContainerLow}`, or `{dark.colors.surfaceContainer}`.
- Text:
  - Light: `{light.colors.onSurface}`.
  - Dark: `{dark.colors.onSurface}`.
- Layout:
  - Centered headline.
  - Short supporting copy.
  - Action row.
  - Visual artifact or preview.
- Use for onboarding, AI feature education, progress summary moments, and programme highlights.

#### Utility Card

- Shape: `radius.lg` or `radius.xl`.
- Padding: theme spacing scale, usually 16.0–24.0.
- Light mode:
  - Fill: `{light.colors.surfaceContainerLowest}`.
  - Optional border: `{light.colors.outlineVariant}`.
- Dark mode:
  - Fill: `{dark.colors.surfaceContainerLow}` or `{dark.colors.surfaceContainer}`.
  - Optional border: `{dark.colors.outlineVariant}`.
- Avoid heavy shadows. Use a soft tonal shift or hairline.

### Inputs & Forms

- Shape: `radius.default`, `radius.md`, or `radius.full` for search.
- Light mode:
  - Default fill: `{light.colors.surfaceContainerLow}` or `{light.colors.surfaceContainerLowest}`.
  - Focus border/glow: `{light.colors.secondary}`.
  - Text: `{light.colors.onSurface}`.
- Dark mode:
  - Default fill: `{dark.colors.surfaceContainerLow}` or `{dark.colors.surfaceContainer}`.
  - Focus border/glow: `{dark.colors.primary}`.
  - Text: `{dark.colors.onSurface}`.
- Error states must use the mode’s error tokens.
- Avoid silent validation failures.
- Typical input height: 48.0–56.0.
- Typical horizontal padding: 16.0.

### Chips & Tags

- Shape: `radius.full`.
- Typography: `labelSm`.
- Minimum tap target: 44.0 × 44.0 when interactive.
- Light inactive:
  - Fill: `{light.colors.surfaceContainerLow}`.
  - Text: `{light.colors.onSurfaceVariant}`.
- Light active:
  - Fill: `{light.colors.secondaryContainer}` or a low-opacity tint of `{light.colors.secondary}`.
  - Text: `{light.colors.onSecondaryContainer}` or `{light.colors.secondary}`.
- Dark inactive:
  - Fill: `{dark.colors.surfaceContainerHigh}`.
  - Text: `{dark.colors.onSurfaceVariant}`.
- Dark active:
  - Fill: low-opacity tint of `{dark.colors.primaryContainer}`.
  - Text: `{dark.colors.primary}`.

### Media & Visual Artifacts

Progress media, exercise videos, bodymaps, programme previews, and charts should be treated like product imagery: they are the focal artifact, not decoration.

- Give visuals enough breathing room.
- Avoid crowding visuals with controls.
- Use soft shadows/glows only when the visual needs separation.
- Use tonal backgrounds to stage media clearly.
- Keep captions short and functional.
- Use `ClipRRect`, `DecoratedBox`, `AspectRatio`, and `FittedBox` deliberately so media remains stable across device sizes.

## Do’s and Don’ts

### Do

- Use the light/dark color tokens in this document as the only color source.
- Use `{light.colors.secondary}` for light-mode interactive actions.
- Use `{dark.colors.primary}` and `{dark.colors.primaryContainer}` for dark-mode interactive actions.
- Use the typography tokens exactly as declared in each theme.
- Build sections with visual hierarchy: headline, supporting copy, actions, visual artifact.
- Alternate major surfaces using theme surface tokens instead of adding decorative dividers.
- Use pill CTAs for high-emphasis actions.
- Use tonal layering for elevation before using shadows.
- Use soft media shadows/glows only for progress photos, exercise videos, bodymaps, charts, and other visual artifacts.
- Keep UI chrome quiet so the user’s programme, workout, progress, and decisions remain central.
- Keep active and pressed states subtle.
- Use Flutter logical pixels directly; do not paste CSS units into Dart.

### Don’t

- Don’t introduce one-off blues or extra accent colors outside the active theme.
- Don’t replace Manrope or Inter with another font family without a design-system update.
- Don’t add decorative gradients.
- Don’t use heavy shadows on cards, buttons, navigation, text, or routine app chrome.
- Don’t round full-bleed section tiles.
- Don’t use arbitrary border radii outside the theme scale.
- Don’t overuse borders when whitespace or tonal surfaces can separate content.
- Don’t make dense screens feel visually noisy; group, layer, and label instead.
- Don’t document or implement hover as a primary mobile design state. Default, focus, active/pressed, selected, disabled, and error states are enough.
- Don’t leave `px`, `rem`, `em`, or CSS-style measurements in Flutter implementation tokens.

## Iteration Guide

1. Work on one component or surface at a time.
2. Reference components and tokens directly, using token paths such as `{light.colors.secondary}`, `{dark.colors.primaryContainer}`, `{light.typography.headlineLg}`, and `{dark.typography.bodyMd}`.
3. Never inline hex values in component specs except inside the theme token definitions.
4. Preserve the color and typography tokens in this document unless a formal design-system update is made.
5. Do not substitute unrelated typography or color tokens.
6. Keep the layout rhythm: full-bleed sections, centered content stacks, generous spacing, minimal chrome, and visual-first hierarchy.
7. When emphasis is needed, change surface level before adding borders or shadows.
8. Use default, focus, active/pressed, selected, disabled, and error states. Do not document hover as a primary mobile state.
9. Variants of an existing component should live as named variants, not as one-off exceptions.
10. Use `radius.full` for pills and high-emphasis action controls.
11. Use `radius.lg` / `radius.xl` for large cards and panels.
12. Use no rounding on full-bleed section tiles.
13. Use shadows sparingly and reserve stronger depth for visual artifacts, not general UI chrome.
14. For dark mode, communicate depth primarily through luminance and tonal layers.
15. For light mode, communicate depth through tonal surface shifts, clean white cards, subtle borders, and restrained ambient shadows.
16. When in doubt, remove visual decoration and let spacing, typography, and content do the work.
17. Before implementation, translate the tokens into Dart constants or generated theme extensions.
18. Keep Flutter token names camelCase to match Dart style.
