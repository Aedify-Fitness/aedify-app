# Flutter Mobile Pattern Memory & Validation

Use this when maintaining reusable mobile design patterns for a Flutter project.

The recommended project memory file is:

```text
.interface-design/system.md
```

Use the project’s own design-system location if one already exists.

---

## When to Add Patterns

Add a pattern when:

- A widget or component is used 2+ times.
- The pattern is reusable across the project.
- It has specific measurements worth preserving.
- It defines important behavior, state, or animation.
- It maps design tokens into Flutter implementation.

Do not document one-off experiments or temporary layouts.

---

## Pattern Format

```markdown
### Primary Action Button
- Widget: AppPrimaryButton
- Height: 48 logical px
- Padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14)
- Radius: 999 logical px
- Text style: labelLarge, FontWeight.w600
- Default fill: colorScheme.primary
- Pressed state: 96% scale + darker primary container
- Disabled state: muted foreground on disabled container
- Haptics: lightImpact only on successful primary action
```

---

## Pattern Reuse

Before creating a Flutter component:

- Check `system.md` or the project design-system file.
- If a pattern exists, use it.
- If a variation is needed, extend it with parameters.
- Do not create a visually new component for the same job.

Reusable components should be real widgets, theme extensions, or style helpers — not copied `Container` trees.

---

## Validation Checks

If the system defines values, check:

**Spacing** — Are all `EdgeInsets`, gaps, and sizes on the 4 logical-pixel grid?

**Depth** — Is the declared strategy used consistently: borders, shadows, tonal surfaces, or layered shadows?

**Colors** — Do widgets use `ColorScheme` or `ThemeExtension`s instead of random `Color(0x...)` values?

**Typography** — Do text widgets use `TextTheme` or named app text styles?

**States** — Are pressed, disabled, loading, selected, empty, error, and offline states covered where relevant?

**Mobile constraints** — Are safe areas, keyboard insets, tap targets, text scaling, and platform gestures handled?

**Patterns** — Are documented patterns reused instead of reinvented?

---

## What Not to Save

Do not save:

- One-off screen-specific compositions.
- Temporary experiments.
- Hardcoded copy or sample data.
- Minor prop variations.
- Patterns that conflict with the existing design system.

Memory compounds. Each saved pattern should make future Flutter screens faster and more consistent.
