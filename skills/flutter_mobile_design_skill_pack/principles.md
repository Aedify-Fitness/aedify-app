# Flutter Mobile Craft Principles

These principles apply regardless of visual direction. They are the quality floor for Flutter mobile UI.

---

## Surface & Token Architecture

Professional mobile interfaces do not pick colors, spacing, typography, or shadows randomly. They use a system.

In Flutter, that system should be expressed through:

- `ThemeData`
- `ColorScheme`
- `TextTheme`
- custom `ThemeExtension`s
- reusable widgets and style helpers

Do not scatter raw colors, text styles, radii, shadows, or edge insets throughout widget code.

---

## Primitive Token Foundation

Every visual decision should trace back to a small set of primitives:

- **Foreground** — primary, secondary, tertiary, muted, disabled text and icons.
- **Background** — base canvas, raised surfaces, overlays, inset areas.
- **Border** — default, subtle, strong, focus, destructive.
- **Brand** — the main action/accent color and its pressed/focused variants.
- **Semantic** — success, warning, error, info, and their containers.
- **Control** — input fills, selected states, toggles, switches, chips.
- **Media** — overlays, scrims, gradients, video/photo chrome when needed.

Flutter mapping:

- Put platform-level colors in `ColorScheme`.
- Put product-specific levels in `ThemeExtension`s.
- Use named extension fields instead of anonymous color constants.
- Keep light and dark values paired in the same extension.

Example token categories:

```dart
class AppSurfaces extends ThemeExtension<AppSurfaces> {
  const AppSurfaces({
    required this.canvas,
    required this.level1,
    required this.level2,
    required this.level3,
    required this.inset,
    required this.overlay,
  });

  final Color canvas;
  final Color level1;
  final Color level2;
  final Color level3;
  final Color inset;
  final Color overlay;

  @override
  AppSurfaces copyWith({
    Color? canvas,
    Color? level1,
    Color? level2,
    Color? level3,
    Color? inset,
    Color? overlay,
  }) {
    return AppSurfaces(
      canvas: canvas ?? this.canvas,
      level1: level1 ?? this.level1,
      level2: level2 ?? this.level2,
      level3: level3 ?? this.level3,
      inset: inset ?? this.inset,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppSurfaces lerp(ThemeExtension<AppSurfaces>? other, double t) {
    if (other is! AppSurfaces) return this;
    return AppSurfaces(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      level1: Color.lerp(level1, other.level1, t)!,
      level2: Color.lerp(level2, other.level2, t)!,
      level3: Color.lerp(level3, other.level3, t)!,
      inset: Color.lerp(inset, other.inset, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }
}
```

---

## Surface Elevation Hierarchy

Surfaces stack. A bottom sheet sits above a screen. A popover sits above a card. A dialog sits above the app.

Build a numbered system:

```text
Level 0: Base app canvas
Level 1: Cards, panels, grouped list sections
Level 2: Bottom sheets, menus, popovers, floating controls
Level 3: Dialogs, stacked overlays, blocking confirmation surfaces
Level 4: Highest elevation, rare critical overlays
```

In dark mode, higher elevation usually becomes slightly lighter. In light mode, higher elevation can use subtle surface shifts, borders, or restrained shadows.

The jump between levels should be quiet. Users should feel the hierarchy before they consciously see it.

---

## The Subtlety Principle

Surfaces and borders should be barely different but still distinguishable.

**For surfaces:** Shift lightness by small steps. Avoid dramatic jumps. Keep the hue family stable.

**For borders:** Define boundaries without demanding attention. On Flutter, use `BorderSide` with low-opacity colors and `DividerThemeData` for consistent dividers.

**The squint test:** Blur your eyes or look at the device from arm's length. You should still know what is above what, but no border should be the loudest thing on the screen.

Common mobile mistakes:

- Heavy `Card` shadows everywhere.
- Borders that are too visible.
- Surface jumps that make cards look pasted on.
- Different hues for adjacent surface levels.
- Default dividers in dense lists without considering hierarchy.
- Dark mode surfaces that rely on invisible shadows.

---

## Text Hierarchy

Build at least four foreground levels:

- **Primary** — core content and headings.
- **Secondary** — supporting copy.
- **Tertiary** — metadata, captions, timestamps.
- **Muted** — disabled, placeholders, low-priority labels.

Use them consistently for both text and icons.

Flutter mapping:

- Use `TextTheme` for size/weight hierarchy.
- Use color tokens for contrast hierarchy.
- Use `FontFeature.tabularFigures()` for aligned numeric data.
- Test with larger accessibility text sizes.

If the interface only uses “black text” and “gray text,” the hierarchy is too flat.

---

## Border Progression

Borders are not binary. Build a scale:

- **Subtle** — section separation, low emphasis.
- **Default** — card or control boundary.
- **Strong** — selected or emphasized state.
- **Focus** — keyboard/accessibility focus or form focus.
- **Danger** — destructive/error boundary.

Use the right intensity for the job. A disabled chip, selected workout, and focused text field should not all use the same border.

---

## Dedicated Control Tokens

Controls have their own needs. Do not blindly reuse card colors.

Define tokens for:

- input background
- input border
- input focused border
- input disabled fill
- chip fill
- chip selected fill
- switch/thumb/track states
- pressed action fill
- destructive action fill

Inputs often feel better slightly inset. Buttons often feel better slightly raised or tonally stronger.

---

## Spacing System

Use Flutter logical pixels.

Base unit: **4 logical pixels**.

Recommended scale:

```text
2  — hairline optical adjustment only
4  — micro gap
8  — tight pair gap
12 — compact component padding
16 — standard mobile margin/padding
20 — comfortable inline spacing
24 — card or section padding
32 — group separation
40 — large mobile section gap
48 — major separation / minimum large control height
64 — hero or major vertical rhythm
```

Every spacing value should be explainable as part of the scale. Random `EdgeInsets` values signal no system.

---

## Padding

Padding should usually be symmetrical.

Good Flutter patterns:

```dart
const EdgeInsets.all(16)
const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
const EdgeInsets.fromLTRB(16, 12, 16, 12)
```

Avoid arbitrary asymmetry unless content naturally creates visual balance, such as list rows with trailing actions or leading icons.

---

## Border Radius

Pick a radius scale and use it consistently.

A practical mobile scale:

```text
4  — tiny badges, compact indicators
8  — small controls, inner media
12 — buttons, chips, text fields
16 — cards and grouped list containers
20 — large cards and sheets
24 — prominent panels
999 — pills and circular controls
```

Do not mix sharp and soft randomly. Radius communicates personality.

---

## Depth Strategy

Choose one dominant strategy for a screen or product area:

### Borders-only

Best for dense tools and technical screens. Use subtle borders, tonal surfaces, and no heavy shadows.

### Subtle shadows

Best for approachable cards and floating controls. Use one restrained shadow style.

### Layered shadows

Best for premium, dimensional cards. Use rarely and consistently.

### Surface color shifts

Best for calm mobile apps and dark mode. The hierarchy comes from surface levels.

Do not mix heavy shadows, thick borders, gradients, and dramatic surface shifts on the same component family.

Flutter mapping:

- Use `BoxShadow` sparingly.
- Use `PhysicalModel`/`Material` elevation only when Material behavior is desired.
- Prefer explicit `BoxDecoration` for exact design-system control.

---

## Card Layouts

A workout card, metric card, media card, and settings card do not need identical internal layouts. Design the internal structure for the content.

Keep these consistent across card families:

- surface level
- radius
- border/shadow treatment
- padding scale
- typography hierarchy
- tap/pressed behavior

Cards should be reusable widgets with named parameters, not copied `Container` blocks.

---

## Controls

Flutter gives styled controls, but defaults are starting points.

For production mobile UI:

- Customize `ButtonStyle` instead of repeating button containers.
- Use `TextField` and `InputDecorationTheme` consistently.
- Use `DropdownMenu`, custom pickers, or bottom sheets when native dropdown behavior feels awkward on mobile.
- Prefer bottom-sheet pickers for long option lists.
- Use date/time pickers that match the app's platform and task context.
- Always handle disabled and loading states.

---

## Iconography

Icons clarify, not decorate. If removing an icon changes nothing, remove it.

Rules:

- Use one icon family per product area.
- Align icons optically with labels.
- Give standalone icons a visible hit target and semantic label.
- Use icon containers only when the icon is an action or major identifier.

Flutter mapping:

- `IconButton` with `tooltip` for accessible labels.
- `Semantics(label: ...)` for custom tappables.
- `SvgPicture` only when the project uses custom SVG icons.

---

## Motion

Mobile motion should be fast, physical, and useful.

Use motion to:

- preserve context
- confirm touch
- show hierarchy changes
- reveal content progressively
- celebrate meaningful completions

Avoid motion that:

- delays repeated tasks
- animates persistent elements unnecessarily
- hides layout problems
- fights platform navigation gestures

Recommended curves:

- Enter/reveal: `Curves.easeOutCubic`
- Exit: `Curves.easeInCubic`
- Local state: `Curves.easeInOutCubic`
- Press: `Curves.easeOut`

---

## States

Every mobile screen needs state design.

Data states:

- loading
- empty
- error
- offline
- stale/syncing
- success/completed

Control states:

- default
- pressed
- focused
- selected
- disabled
- loading
- destructive

Do not use generic snackbars for everything. Important outcomes should appear where the user expects the result.

---

## Navigation Context

Mobile screens need grounding.

Use:

- clear app bars or contextual headers
- active tab/bottom-nav state
- breadcrumbs only when the hierarchy truly needs it
- persistent bottom navigation for top-level destinations
- back navigation that matches platform expectations
- clear titles in sheets and dialogs

Avoid screens that feel like isolated component demos.

---

## Safe Areas, Keyboard, and Gestures

Mobile UI must respect the physical device.

- Wrap full-screen content with `SafeArea` or intentionally manage insets.
- Handle `MediaQuery.viewInsets.bottom` when the keyboard appears.
- Keep primary actions visible when forms are active.
- Avoid placing critical controls too close to the home indicator.
- Do not conflict with system back gestures.
- Support one-handed reach for high-frequency actions.

---

## Accessibility

Accessibility is not polish. It is part of the component contract.

Check:

- minimum tap targets
- text scaling
- contrast in light and dark mode
- semantic labels for icons and custom controls
- logical focus order
- screen-reader-friendly state labels
- reduced motion when appropriate

Flutter tools:

- `Semantics`
- `MergeSemantics`
- `ExcludeSemantics`
- `MediaQuery.textScalerOf(context)`
- `Tooltip` for icon buttons
- `FocusTraversalGroup` when needed

---

## Dark Mode

Dark mode is not just inverted light mode.

- Use borders and tonal layers more than shadows.
- Desaturate semantic colors slightly.
- Increase contrast where small text needs it.
- Avoid pure black unless the brand or OLED media viewing requires it.
- Check disabled and placeholder states carefully.

The structure should stay the same; the values change.
