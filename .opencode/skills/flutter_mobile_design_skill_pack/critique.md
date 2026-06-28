# Flutter Mobile Design Critique

Your first build may be correct. Now review it as a mobile design lead: not “does it work?” but “would I ship this to users?”

---

## The Gap

Correct means the widget tree builds, the layout does not overflow, the colors do not clash, and the screen responds to taps.

Crafted means every visual, spatial, and interaction decision feels intentional on a real phone.

A crafted Flutter screen respects the device, the user's thumb, the platform gestures, the product identity, and the emotional weight of the task.

---

## See the Composition

Step back and look at the whole screen.

Ask:

- Does the layout have a clear focal point?
- Is there one obvious primary action?
- Does the eye travel in the order the user needs?
- Are dense areas balanced by breathing room?
- Does the screen feel native to a phone, or like a desktop layout squeezed down?
- Are bottom actions reachable?
- Is the app bar/header doing useful orientation work?

If everything has the same weight, nothing wins.

---

## See the Mobile Structure

Review the widget structure.

Look for:

- Large build methods that should be composed into widgets.
- Copied `Container` decorations instead of reusable components.
- Raw `Color(0x...)`, `TextStyle`, `EdgeInsets`, and `BorderRadius` values scattered throughout.
- Fixed heights that break with text scaling.
- Nested scroll views that fight each other.
- Layouts that ignore `SafeArea`, keyboard insets, or bottom system gestures.
- Gesture areas smaller than 44 logical pixels.

The correct answer is usually simpler and more systemized.

---

## See the Craft

Move close. Pixel-close.

### Spacing

Every visible value should sit on the spacing system. A 4 logical-pixel grid is the floor, not the whole craft. A compact action row may need `12`; a breathable card may need `24`; a major section may need `40` or `48`.

### Typography

If size is the only difference between headline, body, label, and metadata, the hierarchy is weak. Use weight, letter spacing, line height, and contrast hierarchy.

### Surfaces

Surfaces should show depth without shouting. Remove every border mentally. Can you still perceive hierarchy through surface levels? If not, the surfaces are not doing enough work.

### States

Every tappable element should feel alive:

- pressed state
- disabled state
- loading state
- selected state where relevant
- semantic label for custom or icon-only controls

A missing state makes the UI feel like a screenshot, not software.

### Motion

Transitions should explain spatial movement. A card that opens into a detail screen should use shared-element logic when possible. A bottom sheet should come from the bottom. A step forward should move forward.

---

## See the Content

Read the screen as a real user.

Ask:

- Does every label help the user act?
- Is empty-state copy useful and specific?
- Are error messages recoverable?
- Does loading copy set expectations?
- Does the visible data belong to one coherent product story?

A beautiful mobile UI with incoherent content is still broken.

---

## See Accessibility

Test the screen under pressure:

- Large text.
- Dark mode.
- Small phone.
- Keyboard open.
- Screen reader semantics.
- Low contrast environment.
- Slow network or offline state.

If the design only works in the default simulator configuration, it is not done.

---

## Again

Look one final time and ask:

> If someone said this lacks craft, what would they point to?

Fix that thing before shipping.

The first build is the draft. The critique is the design.
