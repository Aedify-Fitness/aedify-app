# Optional runner weight suggestions — v1.0

Date: 2026-10-25. User-approved extension: “Let's go ahead with this. Implement the weight suggestion.” This adds an optional local runner aid. It does not change the locked analytics e1RM formula, PR rules, progression rules or programme prescriptions.

## Workout flow

- For a supported weighted-rep working set, the runner shows a compact suggestion above the existing logging grid. No columns or RIR inputs are added.
- Planned sets use exact reps, otherwise the lower rep-range bound (or the available bound). The lower RPE-range bound is used when both bounds exist. RIR-only targets are converted to RPE internally. The exact target used is visible.
- If no supported target is supplied, Estimate weight opens a small reps/RPE picker. A standalone exercise's chosen target carries forward within the open runner, including between superset rounds. Choosing an estimate target does not edit the workout's prescribed target. These choices are ephemeral; returning after leaving the runner may require selecting them again.
- Use weight fills only an empty active weight input. It never fills repetitions or effort, completes a set, changes another member, or counts a draft value as a completed performance. Existing entered weights, paused states, inactive sets and mismatched session identities are protected. The user can edit the accepted weight before logging.
- Logging a working set with valid actuals supplies current-session evidence for the next suggestion. How this was estimated shows the reference set/date or known maximum, the effort-adjusted strength estimate, unrounded target load and rounding rationale.
- Missing/failed evidence leaves manual logging usable. There is no AI key, Firebase or network dependency.

## Calculation and eligibility

This feature uses a separate RPE-adjusted Epley heuristic:

```text
effective reps = reps + (10 − RPE)
suggestion strength estimate = weight × (1 + effective reps / 30)
unrounded target load = strength estimate / (1 + target effective reps / 30)
```

A single repetition at RPE 10 is treated as a maximum directly, avoiding an artificial increase when converting a true known 1RM. Fractional RPE is used directly; the integer stored RIR approximation is not used when actual RPE exists.

- Supported input/target range: 1–10 reps, RPE 6–10, finite positive loads.
- History age limit: 90 days, excluding future timestamps. These are conservative product parameters, not claims of scientifically validated cutoffs.
- First preference: the most recent eligible completed working set in this workout for the same exercise.
- Otherwise: take the five most recent eligible historical sets and choose their lower-median strength estimate. The chosen reference and number of source sets are disclosed. This avoids selecting an all-time maximum or a lone high outlier when multiple recent sets exist.
- Last fallback: a recent user-entered `known_1rm` strength anchor. AI-seeded, imported and log-derived maxima are not silently treated as user-confirmed maxima.
- Historical sessions must be completed; source sets must be completed, unskipped working sets. Original set-level exercise attribution is retained across swaps. Other active sessions, abandoned/deleted sessions and warm-ups do not contribute.
- Standard weighted-rep strength exercises are supported. Bodyweight equipment, assisted movements and common weighted calisthenics are excluded because their stored added/assisted load can have a different meaning. Duration/reps-only logging is unchanged. Missing/deleted exercise metadata produces no suggestion.
- Loads of at least 2.5 kg round down to 2.5 kg increments; lighter loads round down to 0.1 kg. The runner currently logs kilograms, so suggestions use kilograms too. This is not equipment-inventory detection; accepted weights remain editable.

The result is a starting estimate, not a guaranteed effort level. RIR accuracy varies by loading condition, and individual relationships can differ from general prediction models: [Hughes et al.](https://pubmed.ncbi.nlm.nih.gov/33337690/), [Balsalobre-Fernández et al.](https://pubmed.ncbi.nlm.nih.gov/30312197/). These studies support treating effort-based guidance cautiously; they do not validate this exact adjusted-Epley algorithm.

## Ownership and data boundaries

- `shared/domain/rpe_load_estimator.dart`: reusable, pure suggestion-only arithmetic.
- `workout_execution/domain/weight_suggestion.dart`: target resolution, eligibility, evidence selection and proposal models.
- `workout_execution/data/weight_suggestion_repository.dart`: local read-only history/anchor query and table-change stream.
- `workout_execution/application/weight_suggestion_providers.dart`: Riverpod orchestration and ephemeral standalone targets.
- `WorkoutRunnerController.useWeightSuggestion`: rechecks active session/set identity and applies only actual weight through the existing draft update/autosave path.
- `WorkoutRunnerWeightSuggestion`: optional hint, target picker and provenance sheet, using existing design tokens/components.

History corrections, deletions, changed exercise metadata and updated strength anchors invalidate evidence through Drift table updates. No schema migration or dependency was added. Suggestions never write `estimated1rmKg`, PR flags, source workouts/programmes, or analytics. No history, notes or weights are sent to external services or logged.

## Verification

Completed on 2026-10-26:

- `dart format .`: checked 802 Dart files.
- `flutter analyze`: no issues.
- `flutter test`: 1,659 passing tests, zero failures or skips, including the existing programme-day follow-up. The weight-suggestion change adds 22 domain, real-SQLite, controller and widget regressions.
- `integration_test/weight_suggestion_smoke_test.dart`: passed on Android `emulator-5554` and iOS simulator `79A92AEE-989A-46CD-BB27-F3F69EC9943E`. No real provider key or Firebase connection was needed.
- Synthetic light/dark runner and source-explanation renders were reviewed on both platforms. The existing logging table retains horizontal scrolling on narrow screens; the suggestion actions remain outside that grid. Widget coverage also exercises 320px width and 2× text scaling.
- Restored and launched the normal `lib/main.dart` entrypoint on both simulators after acceptance testing.

No schema migration, dependency change or code generation was required. M5 analytics, PR and plateau implementation remains planned. Live Firebase/BYOK acceptance recorded separately for M1–M4 is unchanged by this offline feature.

```sh
dart format .
flutter analyze
flutter test
flutter test integration_test/weight_suggestion_smoke_test.dart -d DEVICE_ID --no-uninstall
```

The native harness uses synthetic local records and an isolated SQLite file with Dart HTTP creation blocked. It exercises the visible target picker, explicit Use weight, correction-triggered refresh, actual reps/RPE entry, Log, subsequent-set adjustment and source explanation. It checks that analytics fields remain untouched. Synthetic light/dark previews are saved in the simulator/emulator temporary directory as `aedify_weight_{light,dark,reason_dark}.png`.
