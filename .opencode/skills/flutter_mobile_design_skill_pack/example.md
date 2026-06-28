# Flutter Mobile Craft in Action

This shows how the subtle layering principle translates to Flutter mobile decisions. Learn the thinking, not the exact values.

---

## The Subtle Layering Mindset

You should barely notice the system working.

On a crafted mobile screen, users do not think “nice borders.” They simply understand where the primary content is, what is tappable, what is above what, and what to do next.

---

## Example: Mobile Dashboard With Bottom Sheet Filter

### The Scenario

A user opens a mobile dashboard, checks their current status, then filters the visible data. The filter is temporary context, not a destination.

### The Surface Decisions

Use three surface levels:

```text
Level 0: screen canvas
Level 1: dashboard cards and grouped sections
Level 2: filter bottom sheet
```

The filter sheet should be visibly above the dashboard, but not dramatically different. In dark mode, use a slightly lighter sheet surface. In light mode, use a slightly brighter surface or a restrained shadow.

### The Navigation Decision

Filtering does not deserve a full-screen route unless the filter flow is complex. A modal bottom sheet preserves the dashboard behind it, so the user remembers what they are filtering.

Flutter approach:

```dart
showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) {
    return SafeArea(
      top: false,
      child: _FilterSheet(),
    );
  },
);
```

The sheet itself should have:

- a title
- a dismiss path
- one primary action
- selected states
- clear reset behavior if needed

### The Border Decisions

The sheet may need a subtle top border in dark mode because shadows will not read clearly. The card below should not use the same border intensity as the sheet.

### The Motion Decision

The sheet enters from the bottom because it physically emerges from the lower mobile control area. Do not fade a centered modal in for this task; it disconnects the action from the thumb interaction.

---

## Example: Form Flow

### The Scenario

A user creates a new item from their phone. The form has twelve fields, but only four are needed to begin.

### The Simplicity Decision

Do not show all twelve fields at once. Split into steps or reveal advanced fields after the core fields are complete.

Flutter approach:

- `PageView` or route steps for high-focus flows.
- `AnimatedSize` for inline progressive disclosure.
- `Stepper` only if it is customized enough to match the product and does not feel like a default demo.

### The Input Decision

Inputs are content receivers. They can use an inset token: slightly darker in light mode or slightly deeper in dark mode, with a stronger border only on focus.

```dart
InputDecorationTheme(
  filled: true,
  fillColor: controlTokens.inputFill,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: borderTokens.subtle),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
  ),
)
```

### The Keyboard Decision

Primary actions must remain reachable when the keyboard is open. Use scroll padding, keyboard insets, or a bottom action area that moves above the keyboard.

---

## Example: Workout Card / Data Card

### The Scenario

A mobile card summarizes a workout, programme, metric, or progress entry.

### The Card Decision

Do not make every card a generic icon-left / title / subtitle / chevron row.

Ask what the card means:

- Is it a resume action?
- Is it a comparison?
- Is it a warning?
- Is it a historical record?
- Is it media-first?

The card structure should follow that purpose while keeping the same tokenized surface treatment.

### The Tap Decision

If the full card is tappable:

- Use a pressed-state tonal shift or slight scale.
- Keep the hit target generous.
- Add semantics describing the action.
- Use `Hero` when the card expands into detail.

---

## Example: Empty State

### The Scenario

A user opens a feature before adding content.

### The Craft Decision

Avoid: “No items yet.”

Better:

- Explain what will appear here.
- Show a small visual or icon that belongs to the feature.
- Point to the primary action.
- Keep one clear CTA.

Flutter approach:

```dart
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FloatingEmptyIcon(),
          const SizedBox(height: 20),
          Text('Nothing here yet', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Create your first entry and it will appear here.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onCreate,
            child: const Text('Create entry'),
          ),
        ],
      ),
    );
  }
}
```

---

## Adapt to Context

The same principles can produce different Flutter mobile UI:

- A finance tool may be dense, crisp, and border-led.
- A fitness app may be energetic, tactile, and card-led.
- A journal app may be quiet, text-led, and spacious.
- A media app may be dark, immersive, and image-led.

The principle is constant: barely different, still distinguishable. The values adapt to context.

---

## The Craft Check

Run this on a real phone or mobile simulator:

1. Can the user tell what to do within one second?
2. Is the primary action reachable by thumb?
3. Does the screen respect safe areas and keyboard insets?
4. Can you perceive hierarchy when squinting?
5. Are any borders, shadows, or colors shouting?
6. Does the screen still work in dark mode and large text?
7. Are loading, empty, and error states designed?

If hierarchy is visible, touch feels responsive, and nothing is harsh, the subtle layering is working.
