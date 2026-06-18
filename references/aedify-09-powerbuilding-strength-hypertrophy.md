# 09 — Powerbuilding Strength + Hypertrophy Reference

> Purpose: supplemental AI reference for the Aedify when the athlete wants a combined **build strength + build muscle** programme.
>
> Source basis: user-provided powerbuilding PDFs. This file intentionally extracts **high-level programming principles only**. It must not reproduce, reconstruct, or output the original paid programme tables, week-by-week layouts, or proprietary exercise sequences.

## Use Scope

Use this reference for:
- Intermediate and advanced athletes whose goals include both `Build Strength` and `Build Muscle`.
- Multi-week programme generation where the user wants a powerbuilding-style programme.
- Daily workout generation when the user requests a strength + hypertrophy session.
- Plateau suggestions for primary barbell lifts or closely related compound lifts.
- Deload/taper advice for strength-focused blocks.

Do not use this reference as the default for:
- Absolute beginners or users with no established training base.
- Beginner Path A, which should continue to follow the bundled wiki beginner guidance strictly.
- Users asking for general fitness, fat loss only, rehab, mobility, or casual workouts.

## Core Powerbuilding Model

Powerbuilding combines:
- Powerlifting-style strength development on major compound lifts.
- Bodybuilding-style hypertrophy work to build proportional muscle mass.
- Periodised progression so strength and size are not treated as random independent goals.

The AI should treat `Build Strength + Build Muscle` as a hybrid goal, not as two separate requests. The programme should have:
- Clear priority lifts or movement patterns.
- Supporting secondary compounds.
- Isolation/accessory work for proportional development, weak points, and volume.
- Fatigue management, because hybrid strength + size work can accumulate recovery cost quickly.

## Training Level Gate

For this reference, assume the ideal user is at least intermediate:
- Has several months to years of structured lifting.
- Can perform compound lifts safely.
- Has recent working weights, estimated 1RMs, or enough log history to anchor prescriptions.
- Can understand RPE/RIR or be coached into it.

If the user is novice/beginner:
- Keep prescriptions simpler.
- Avoid heavy singles, advanced intensity techniques, aggressive volume, or frequent exercise variation.
- Prefer beginner progression rules already defined elsewhere in the instruction set.

## Phase / Block Concepts

A strength + hypertrophy programme can be organized around these broad blocks:

### 1. Base / Balanced Powerbuilding
Use when the athlete wants an even strength-size blend.
- Main lifts appear early in relevant sessions.
- Accessories fill proportional muscle development.
- Progression can mix strength-focused and hypertrophy-focused weeks.

### 2. Accumulation / Hypertrophy-Biased Powerbuilding
Use when the athlete needs more muscle, work capacity, or volume tolerance.
- Slightly higher weekly volume.
- More exercise variation.
- More moderate loads and hypertrophy rep ranges.
- Strength work is maintained but not maximally peaked.

### 3. Transmutation / Strength-Biased Powerbuilding
Use when the athlete wants to convert muscle/work capacity into heavier lifts.
- Lower total volume than accumulation.
- Heavier top sets and more specificity to major lifts.
- Less exercise variation on primary patterns.
- Accessory work becomes more targeted and less excessive.

### 4. Peak / Test-Oriented Block
Use only for experienced athletes who explicitly want to test or peak.
- Preserve heavier practice exposures.
- Reduce volume as intensity rises.
- Use a taper week before testing.
- Offer AMRAP/e1RM testing as the safer default; true 1RM testing is only for experienced powerlifting-oriented athletes.

## Microcycle Patterns

The AI can use these as programme-design patterns without copying any source programme:

### Alternating Strength / Hypertrophy Weeks
Useful for intermediate/advanced powerbuilding:
- Strength-focused weeks: heavier primary lift exposures, lower-to-moderate volume, top-set emphasis.
- Hypertrophy-focused weeks: lighter/moderate loads, more variation, more bodybuilding accessories, technique and mind-muscle focus.

### Full-Body Strength Weeks
Useful when strength is a high priority:
- Major compounds appear more than once per week where schedule allows.
- Heavier/harder exposure comes earlier in the week.
- Later exposure can be lighter, technical, or volume-focused.

### Upper/Lower or Push/Pull/Legs Hypertrophy Weeks
Useful when the athlete has 4–6 days/week:
- Distribute volume across body parts.
- Use variations of primary patterns instead of repeating heavy competition-style lifts every day.
- Add an optional low-fatigue pump/accessory day only when recovery and schedule allow.

### Consistent Strength-Specific Full-Body Block
Useful for peaking strength:
- Squat/bench/deadlift or close variations receive consistent weekly practice.
- Deadlift exposure should be more conservative because it is highly fatiguing.
- Accessory volume is trimmed as peak intensity rises.

## Exercise Role Classification

When generating workouts/programmes, classify every exercise internally:

- `primary`: main heavy compound patterns with high systemic fatigue and high strength relevance, such as squat, bench, deadlift, overhead press, or close variations.
- `secondary`: compound accessories that support primary lifts or build major muscle groups with less systemic fatigue than the primary lift.
- `tertiary`: isolation/accessory movements for local hypertrophy, weak points, joint balance, pump work, or smaller muscles.
- `conditioning`: cardio or conditioning work.
- `mobility_recovery`: warm-up, mobility, cooldown, rehab-like, or recovery work.

Suggested schema impact:
- Add `exercise_role` or `programme_role` to generated exercise prescriptions.
- Add `set_intent` for each set: `warmup`, `top_set`, `backoff`, `volume`, `technique`, `pump`, `test`, `taper_practice`, or `working`.
- Keep the app's existing `set_type` as `warmup | working`; `set_intent` is an optional richer subtype.

## Loading Models

Support multiple loading methods instead of forcing one weight model everywhere:

### Primary lifts
May use:
- Fixed %1RM.
- %1RM intensity brackets.
- RPE/RIR targets.
- Top set + back-off sets.
- Conservative e1RM-derived anchors if recent log data exists.

### Secondary / tertiary exercises
Prefer:
- Rep ranges.
- RPE/RIR targets.
- Double progression.
- Technique/tempo/mind-muscle improvements when reps or load cannot increase.

Suggested schema impact:
- Add `loading_model`: `fixed_percent_1rm`, `percent_1rm_bracket`, `rpe_target`, `rpe_range`, `double_progression`, `calibration`, `bodyweight`, `time_based`.
- Add optional `percent_1rm_min`, `percent_1rm_max`, `rpe_min`, `rpe_max`.
- Add `load_selection_note` for user-facing explanation.

## Autoregulation Rules

The AI should not treat prescribed loads as rigid when RPE/RIR or brackets are provided.

For primary lifts:
- If the athlete feels strong and warm-ups move well, choose the higher end of the bracket.
- If warm-ups feel heavy, sleep/recovery is poor, or form degrades, choose the lower end.
- A successful session is hitting the intended effort and technique, not always the top of the range.
- If a set overshoots the target RPE, reduce load or volume for the next set.
- If a set undershoots RPE substantially, allow a conservative load increase on the next set.

For multi-set RPE prescriptions:
- The last working set may be the one that reaches the target RPE.
- Earlier sets can feel easier, especially when the same load is used across sets.

## Warm-Up Model

Use two layers:

### General warm-up
Optional but recommended before heavy or early-morning lifting:
- 5–10 minutes low-to-moderate cardio.
- Brief dynamic movement prep.
- Optional light foam rolling for tight areas.

### Specific pyramid warm-up
Use before primary loaded exercises:
- 3–4 progressively heavier warm-up sets.
- Keep reps low enough to avoid fatigue.
- Warm-up sets should prepare the movement and help the athlete judge readiness.
- Extensive pyramid warm-ups are not required for every isolation/accessory lift.

Interaction with app v1.5 rule:
- The app already caps generated warm-up sets at 80% of the associated working weight.
- This reference supports progressive warm-ups for primary lifts but should not force percentage-based warm-ups on bodyweight, cardio, mobility, or unclear-load exercises.

## Progression Rules

### Primary lifts
- Progress via planned load/reps/intensity changes across the programme.
- Use fixed percentages or brackets when a reliable 1RM/e1RM exists.
- Use top sets to expose the athlete to heavier loads.
- Use back-off sets for volume, technique practice, and hypertrophy support.
- Avoid routine failure on primary lifts because recovery cost is high.

### Secondary and tertiary work
Use double progression:
1. Keep the same load while adding reps toward the top of the rep range.
2. Once the top of the range is achieved at the target RPE with good form, add a small amount of load.
3. Return to the lower end of the rep range.
4. If neither load nor reps can progress, aim to improve technique, tempo control, range of motion, or mind-muscle connection.

## Failure / Effort Rules

- Primary compounds should generally stop short of failure.
- Secondary and tertiary work can use higher effort.
- Last set to failure is acceptable only for safer accessory/isolation exercises when appropriate.
- Do not prescribe failure when fatigue, pain, poor sleep, injury risk, or technique breakdown is present.
- High effort is a tool, not a constant setting.

## Volume and Fatigue Rules

- Count tough working sets, but do not treat every set as equal.
- A hard squat set and a leg-extension set should not be treated as identical fatigue/stimulus units.
- Indirect volume matters: pressing contributes to triceps/front delts; rows/pulls contribute to biceps/rear delts.
- More volume is not automatically better.
- Programme quality depends on volume, effort, recovery, exercise selection, technique, and progression fitting together.

Suggested analytics impact:
- Continue counting sets for simple volume charts.
- Add future optional `fatigue_weight` or `stimulus_weight` for more nuanced analytics.
- Keep v1 simple unless needed.

## Recovery Management

When the athlete reports poor recovery or the log shows regression:
- Reduce load to the lower end of brackets.
- Reduce accessory volume first before cutting primary practice entirely.
- Preserve movement patterns where possible.
- Consider a deload or technique week if fatigue is persistent.

Watch for:
- Continued strength/size regression.
- Disturbed sleep.
- Persistent joint or muscle aches.
- Extreme lack of motivation to train.
- RPE drift upward at normal loads.

## Deload and Taper Distinction

### Deload
Use for recovery and technique consolidation.
- Reduce volume and/or intensity.
- Cap effort.
- Keep familiar movements.
- Emphasize form, movement quality, and mind-muscle connection.

### Taper
Use before peak/testing blocks.
- Reduce volume more aggressively.
- Keep selected heavier practice exposures.
- Minimize accessory fatigue.
- Prepare the athlete for max or AMRAP testing.

Suggested schema impact:
- Add week emphasis values: `strength`, `hypertrophy`, `technique`, `deload`, `taper`, `test`, `recovery`.
- Add `testing_method`: `none`, `amrap_e1rm`, `heavy_single_estimate`, `true_1rm`.

## Supersets / Circuits

Use supersets mainly for:
- Accessory work.
- Antagonist pairings.
- Pump work.
- Time efficiency.

Avoid supersets for:
- Heavy primary compounds.
- High-skill top sets.
- Any movement where performance, safety, or technique will suffer.

The existing `execution_group` design fits this well:
- `A1`, `A2`, etc. can be represented as shared `execution_group`.
- AI-generated non-beginner supersets should remain simple and symmetric.
- Beginner AI programmes should still avoid supersets per existing product decision.

## Exercise Substitution Rules

Do not copy source substitution lists directly.

Generate substitutions from the app's local exercise library using:
- Same or close primary muscle group.
- Same movement pattern where possible.
- Compatible equipment.
- Compatible difficulty.
- Similar fatigue profile.
- Respect injuries and user substitutions.
- For primary lifts, prefer close variations before unrelated accessories.

Examples of substitution logic:
- Squat pattern → squat variation, leg press, split squat depending on equipment and goal.
- Horizontal press → bench variation, dumbbell press, machine press.
- Hip hinge → deadlift/RDL/hip hinge variation, but manage fatigue.
- Pull-up/vertical pull → assisted pull-up, pulldown, machine vertical pull.

## AI Prompting Rules

When this reference is active, the prompt should ask the AI to:
- Declare the programme emphasis: balanced, hypertrophy-biased, strength-biased, peak/test.
- Classify exercises by role.
- Put compounds before isolation unless there is a deliberate reason not to.
- Use warm-up sets for primary strength lifts.
- Use top sets and back-off sets where appropriate for primary lifts.
- Use rep ranges and double progression for accessories.
- Add deload or taper weeks according to the selected block.
- Avoid copying any source programme table or exact weekly sequence.
- Return valid structured output only for app-actionable generations.

## What Not To Do

- Do not reproduce the original programme tables.
- Do not claim the generated programme is a Jeff Nippard programme.
- Do not use this as a beginner default.
- Do not prescribe true 1RM testing for users without appropriate experience.
- Do not let volume climb without recovery checks.
- Do not use advanced intensity techniques unless the user is non-beginner and the goal/context warrants them.
- Do not replace the bundled wiki beginner path with powerbuilding logic.
