---
name: flutter-mobile-design
variant: interface-design
platform: Flutter mobile
description: Create distinctive, production-grade Flutter mobile interfaces with high craft. Use this skill when designing or implementing iOS/Android app screens, Flutter widgets, flows, design systems, dashboards, forms, onboarding, settings, or any user-facing mobile UI. It preserves the core craft principles of intentional design, subtle layering, strong token architecture, clear hierarchy, and polished interaction while adapting them to Flutter, Dart, touch input, safe areas, mobile navigation, accessibility, and platform conventions.
license: Complete terms in LICENSE.txt
---

# Flutter Mobile Interface Design

This skill guides creation of distinctive, production-grade **Flutter mobile** interfaces. It is for real app screens, flows, and reusable widgets, not web pages or marketing sites.

Build UI that feels intentionally designed for a phone: thumb-friendly, context-aware, responsive to touch, respectful of safe areas, readable in motion, and polished without becoming noisy.

The goal is not merely to assemble widgets. The goal is to make the product feel crafted.

---

## Scope

Use this skill for:

- Flutter iOS and Android app screens
- Mobile dashboards and tool screens
- Forms, setup flows, onboarding, settings, and account screens
- Reusable Flutter widgets and component systems
- Mobile-first interaction, navigation, motion, and state design
- Adapting a design system into `ThemeData`, `ColorScheme`, `TextTheme`, and custom `ThemeExtension`s

Do not use this as a landing-page or web-marketing design guide. Mobile app UI has different constraints: small screens, touch input, safe areas, platform gestures, keyboard behavior, offline states, and performance budgets.

---

## Design Thinking Before Building

Before writing Flutter code, answer these:

- **User:** Who is holding the phone, where are they, and what are they trying to do in the next 30 seconds?
- **Primary action:** What is the one action this screen should make obvious?
- **Context:** Is this a quick-use screen, a focused task, a review step, or a persistent destination?
- **Tone:** Should the screen feel calm, precise, athletic, editorial, playful, premium, utilitarian, or something else?
- **Constraint:** What does mobile change here — thumb reach, scroll length, keyboard, offline state, camera/media, haptics, one-handed use, or interrupted sessions?
- **Signature:** What one visual, structural, or interaction detail makes this screen feel specific to the product?

If you cannot answer these, ask for clarification or make the smallest grounded assumption and state it in the work notes.

---

## Core Mobile Principles

### 1. Intent Over Defaults

Flutter makes it easy to ship familiar Material layouts. Familiar is not the same as designed.

Every widget choice should have a reason:

- Why this layout and not another?
- Why this hierarchy?
- Why this surface level?
- Why this transition?
- Why this component instead of a platform default?

Use platform conventions where they help users feel oriented. Customize where the product needs a stronger identity. Do not fight the platform for novelty alone.

### 2. Simplicity Through Progressive Disclosure

Mobile screens collapse complexity. Never dump everything at once.

- One primary action per screen.
- Break long forms into short steps when the task is cognitively heavy.
- Prefer bottom sheets, inline expansion, and review screens for transient decisions.
- Use full screens for persistent destinations, deep creation flows, and tasks needing concentration.
- Every modal, bottom sheet, dialog, and nested flow needs a clear title and dismiss/back path.
- Keep the user's previous context visible when a decision is temporary.

Flutter tools:

- `showModalBottomSheet` for contextual actions.
- `DraggableScrollableSheet` for layered or progressive content.
- `ExpansionTile`, `AnimatedSize`, or custom implicit animation for reveal.
- `Navigator`, `go_router`, or typed routes for persistent destinations.

### 3. Subtle Layering

Surfaces should whisper hierarchy. Elevated UI should be clear without harsh borders or heavy shadows.

- In light mode, use tonal surface shifts and restrained shadows.
- In dark mode, use lighter surface levels and subtle borders because shadows are less visible.
- Keep surface hue consistent; shift lightness/value, not random color families.
- Inputs should often feel slightly inset relative to their parent surface.
- Overlays should sit one level above the surface that launched them.

Flutter tools:

- `ColorScheme` for primitives.
- `ThemeExtension` for custom surface, border, control, and semantic tokens.
- `DecoratedBox`, `Container`, `Card`, and `Material` only when their visual behavior is intentional.
- Prefer explicit decoration over default `Card` styling when the design system needs precise control.

### 4. Mobile Spatial Rhythm

Flutter uses logical pixels. Treat spacing as a system.

- Use a 4 logical-pixel base grid.
- Common spacing: `4`, `8`, `12`, `16`, `20`, `24`, `32`, `40`, `48`, `64`.
- Tap targets should be at least `44 × 44` logical pixels, preferably `48 × 48` for primary controls.
- Keep horizontal margins comfortable: `16` on compact phones, `20–24` when the layout allows.
- Respect safe areas with `SafeArea`, `MediaQuery.padding`, and keyboard insets.
- Use `Sliver` layouts for long, scrolling mobile surfaces instead of deeply nested scroll views.

### 5. Typography Is the Interface

Typography defines the product's feel before the user reads the words.

- Build a clear `TextTheme` hierarchy.
- Use weight, color, and line-height in addition to size.
- Body text must remain readable on a phone in motion.
- Use tabular figures for repeated numeric values when the font supports them.
- Do not rely on oversized text alone to create hierarchy.
- Avoid random one-off text styles inside widgets; route them through the theme.

Flutter tools:

- `TextTheme` for standard styles.
- `DefaultTextStyle.merge` sparingly for local context.
- `FontFeature.tabularFigures()` for aligned numbers.
- `MediaQuery.textScalerOf(context)` awareness for accessibility.

### 6. Touch States Matter

Mobile has no hover. Interaction feedback comes from touch, pressed state, focus, loading state, disabled state, haptics, and motion.

Every tappable element needs:

- Default state
- Pressed state
- Disabled state
- Loading/progress state when asynchronous
- Focus/semantics state where relevant
- Accessible label when icon-only

Flutter tools:

- `InkWell`, `InkResponse`, `GestureDetector`, and `FocusableActionDetector` deliberately.
- `WidgetStateProperty` for buttons and controls.
- `Semantics` for non-text or custom interactions.
- `HapticFeedback.selectionClick`, `lightImpact`, or `mediumImpact` for meaningful moments only.

### 7. Fluidity With Physical Logic

The app should not teleport. Movement must explain where things came from and where they went.

- Use directional transitions for forward/back navigation.
- Use `Hero` when a card, image, or avatar expands into a detail screen.
- Use implicit animations for local state changes.
- Use explicit animation controllers only when choreography is necessary.
- Animate only what changes; persistent elements should stay visually stable.
- Honor reduce-motion preferences where applicable.

Flutter tools:

- `AnimatedContainer`, `AnimatedOpacity`, `AnimatedAlign`, `AnimatedSwitcher`, `AnimatedSize`.
- `Hero` for shared element transitions.
- `PageRouteBuilder` or custom transition pages in `go_router` for route motion.
- `TweenAnimationBuilder` for values.
- `ListenableBuilder` or `AnimatedBuilder` for performance-sensitive animations.

### 8. Delight Through Selective Emphasis

Delight should match frequency.

- Daily actions get subtle micro-interactions.
- Occasional actions get memorable tactile feedback.
- Rare milestones can be more expressive.
- Empty states are designed moments, not blank placeholders.
- Completion states should be contextual, not generic toasts.
- Destructive actions should feel clear, reversible where possible, and intentional.

Use haptics and sound sparingly. Never make high-frequency flows feel slow for the sake of animation.

---

## Flutter Aesthetic Guidelines

### Typography

Use the project's approved type system. If no type system exists, choose fonts that fit the product's world and define them in `pubspec.yaml` and `TextTheme`.

Avoid generic choices unless the product intentionally calls for platform-native neutrality. If the project already has a design system, obey it instead of inventing a new type direction.

### Color and Theme

Use `ThemeData` as the integration point, but do not limit the design system to Material defaults.

Define:

- `ColorScheme` for platform-level colors.
- Custom `ThemeExtension`s for product-specific tokens such as surface levels, control fills, borders, chart colors, workout intensity colors, or media overlays.
- Light and dark values for every token.
- Semantic colors that remain accessible in both themes.

Never scatter raw `Color(0x...)` values through widgets unless defining tokens.

### Layout

Flutter mobile layouts should feel native to a phone:

- Use `SafeArea` for top/bottom system regions.
- Use `CustomScrollView` and slivers for long screens with sticky headers or collapsing sections.
- Avoid fixed heights unless the component truly requires one.
- Use `LayoutBuilder` only when a component has meaningful breakpoint behavior.
- Prefer composition of small widgets over large monolithic build methods.

### Components

A component is done only when it has:

- The intended visual treatment.
- All interactive states.
- Empty/loading/error variants when data-driven.
- Accessibility semantics.
- Tokenized colors, type, spacing, and radius.
- A preview or test when the project supports it.

### Motion

Use fast, useful motion:

| Use case | Flutter guidance | Duration |
|---|---|---|
| Press feedback | scale, opacity, or tonal shift | 80–140ms |
| Local reveal | `AnimatedSize`, `AnimatedOpacity`, slide | 180–260ms |
| Bottom sheet | platform sheet motion | platform/default or 250–350ms |
| Route transition | directional slide/fade or shared element | 250–350ms |
| Hero morph | `Hero` with stable tags | 300–450ms |
| Number change | `TweenAnimationBuilder` | 300–700ms |

Use curves like `Curves.easeOutCubic`, `Curves.easeInCubic`, `Curves.easeInOutCubic`, or a project-defined cubic curve. Avoid bouncy motion unless the product intentionally feels playful.

---

## Mobile Anti-Patterns

Avoid:

1. Screens with multiple competing primary CTAs.
2. Long, undifferentiated forms with no grouping or progression.
3. Raw `Color(0x...)`, `EdgeInsets`, and `TextStyle` values scattered everywhere.
4. Default `Card`, `ListTile`, or `ElevatedButton` usage that has not been shaped by the design system.
5. Tiny tap targets or icon buttons without semantic labels.
6. Ignoring notches, home indicators, status bars, and keyboard insets.
7. Heavy shadows in dark mode.
8. Toasts/snackbars for important completion or failure states that deserve inline context.
9. Skeleton loaders that do not match the final layout.
10. Nested scroll views that fight gesture physics.
11. Unanimated state swaps that cause visual jumps.
12. Animations that block high-frequency workflows.
13. Platform-inappropriate gestures with no fallback.
14. Components that look good in one theme but break in dark mode or large text.
15. Empty states that say only “No data” without guidance.

---

## Flutter Implementation Checklist

Before considering a mobile UI complete:

### Intent

- [ ] Screen has one obvious primary action.
- [ ] The visual hierarchy matches the user's immediate task.
- [ ] The screen has a product-specific signature, not a template layout.

### Tokens

- [ ] Colors come from `ColorScheme` or custom theme extensions.
- [ ] Text styles come from `TextTheme` or named app text tokens.
- [ ] Spacing follows the 4 logical-pixel grid.
- [ ] Radius and borders follow the project scale.

### Layout

- [ ] Safe areas and keyboard insets are handled.
- [ ] Tap targets are at least 44 logical pixels.
- [ ] Long content scrolls naturally and does not overflow.
- [ ] Layout works on small phones and larger devices.

### States

- [ ] Loading, empty, error, disabled, pressed, and success states are designed.
- [ ] Icon-only controls have semantics labels.
- [ ] Async actions show progress at the point where users expect the result.

### Motion

- [ ] No important state appears/disappears instantly.
- [ ] Route direction matches navigation meaning.
- [ ] Shared elements use `Hero` where appropriate.
- [ ] Motion is fast enough for mobile productivity.

### Craft

- [ ] Surfaces show hierarchy without harsh borders.
- [ ] Typography hierarchy is visible when squinting.
- [ ] Empty states guide the next action.
- [ ] The screen still feels polished in dark mode.
- [ ] The implementation uses small, reusable widgets.

---

## Workflow

1. Read the relevant design system before building.
2. Identify intent, primary action, state model, and navigation context.
3. Define or reuse tokens before creating widget styles.
4. Build the smallest complete screen state first.
5. Add loading, empty, error, and disabled states.
6. Add motion and haptics only where they clarify or reward.
7. Review on mobile constraints: safe area, keyboard, scrolling, large text, dark mode.
8. Refactor repeated patterns into reusable widgets or theme extensions.

---

## Deep Dives

For more detail:

- `principles.md` — Flutter mobile craft principles, tokens, layout, controls, motion, accessibility.
- `example.md` — Applied mobile examples and reasoning.
- `validation.md` — How to maintain reusable design patterns in a Flutter project.
- `critique.md` — Mobile design critique protocol.

---

## Commands

- `/flutter-mobile-design:status` — Summarize known design system state.
- `/flutter-mobile-design:audit` — Check Flutter UI code against the design system.
- `/flutter-mobile-design:extract` — Extract reusable Flutter component patterns.
- `/flutter-mobile-design:critique` — Critique a Flutter screen for craft and rebuild what defaulted.
