# AGENTS.md — Aedify Project Agent Guide

## Purpose

This file defines how AI coding agents should work inside the Aedify project.
It is the first file agents should read before making product, architecture,
code, test, or documentation changes.

Aedify is a Flutter-based, local-first AI gym companion for iOS and Android.
The v1 baseline is locked. Agents must implement the agreed plan; they must not
silently change product scope, architecture, privacy posture, or the validated
technology stack.

## Source-of-Truth Order

When instructions conflict, follow this order:

1. Direct user instructions in the current task.
2. This `AGENTS.md` file.
3. The locked Aedify product and implementation documents:
   - `references/PRD-Aedify-v1-FINAL-relocked.md`
   - `references/aedify-v1-architecture-implementation-plan-v1.0.md`
   - `references/aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md`
   - `references/aedify-package-validation-decision-log-v1.md`
   - `references/aedify-ai-companion-instruction-set-v1.10.md`
4. `DESIGN.md` for the approved Flutter mobile visual system, design tokens,
   component guidance, and interaction direction.
5. `rules.md` for general Flutter and Dart coding rules.
6. `skills/skills.md` for available Flutter agent skills and skill references.
7. The Flutter mobile design skill pack for mobile UI craft workflow.
8. Existing code conventions in the repository.

If generic Flutter rules conflict with the locked Aedify architecture, follow
the Aedify architecture.

## Required Project References

Agents must inspect the relevant project references before implementing,
refactoring, testing, or changing documentation.

### Core project governance

- `AGENTS.md` — agent operating rules and project workflow.
- `rules.md` — general Flutter and Dart engineering rules.
- `skills/skill.md` — Flutter agent skills reference.
- `docs/changelog.md` — living project change log maintained during implementation.
- `docs/implementation.md` — living implementation-status tracker maintained during
  implementation.

### Locked product and architecture references

- `references/PRD-Aedify-v1-FINAL-relocked.md` — locked v1 product baseline.
- `references/aedifyv1-architecture-implementation-plan-v1.0.md` — architecture source of
  truth.
- `references/aedifyv1-implementation-roadmap-tech-stack-updated-v1.3.md` — milestone
  sequence and build order.
- `references/aedifypackage-validation-decision-log-v1.md` — validated package and stack
  decisions.
- `references/aedifyai-companion-instruction-set-v1.10.md` — AI companion operating,
  prompt, schema, repair, privacy, and structured-output rules.

### Detailed implementation-plan folders

The zipped implementation packages are expected to be unzipped before or during
development. When available, agents must treat these folders as project
references:

- `references/ai_implementation_plan/` — AI implementation details, schemas, prompt flows,
  provider boundaries, repair flows, and AI validation work.
- `references/build_ticket_backlog/` — implementation tickets and build backlog.
- `references/data_model_implementation_plan/` — Drift schema, data model, migrations,
  storage ownership, validation, and persistence details.
- `references/feature_by_feature_build_plan/` — feature-level implementation plans and
  sequencing details.
- `references/testing_acceptance_plan/` — test strategy, acceptance gates, release checks,
  and QA expectations.

If an expected folder has not been unzipped yet, do not invent its contents.
Use the available locked PRD, architecture plan, roadmap, and implementation
plans already present, then note that the folder should be unzipped before the
related implementation work continues.

### Bundled AI fitness reference files

- `references/aedify00-index.md` — reference-file index and usage guidance.
- `references/aedify01-getting-started.md` — beginner mindset and fitness basics.
- `references/aedify02-weight-loss.md` — weight-loss principles and guidance.
- `references/aedify03-muscle-building.md` — muscle-building principles and guidance.
- `references/aedify04-nutrition-and-diet.md` — nutrition and diet guidance.
- `references/aedify05-exercise-programming.md` — exercise programming and routine
  selection guidance.
- `references/aedify06-faq.md` — common fitness questions and answers.
- `references/aedify07-supplements.md` — supplement guidance.
- `references/aedify08-glossary.md` — fitness glossary and terminology.
- `references/aedify09-powerbuilding-strength-hypertrophy.md` — scoped supplemental
  powerbuilding reference for eligible non-beginner strength + hypertrophy
  requests only.

## Required Project Context

Before implementing a feature or refactor, identify the relevant source files
and folders:

- Use the PRD for product behavior and scope boundaries.
- Use the architecture plan for module boundaries, storage ownership,
  dependency direction, privacy rules, and package responsibilities.
- Use the roadmap for milestone sequencing and dependency order.
- Use the detailed implementation-plan folders when the task touches their area.
- Use the AI companion instruction set for AI prompt, schema, privacy, repair,
  and structured-output behavior.
- Use the bundled reference files for AI coaching knowledge and source-gated
  fitness behavior.
- Use `DESIGN.md` for user-facing Flutter mobile UI, design tokens, component
  feel, typography, spacing, shape, depth, and interaction direction.
- Use the Flutter mobile design skill pack when creating, modifying, critiquing,
  or validating mobile screens, widgets, flows, empty states, loading states,
  motion, or reusable UI patterns.
- Use `rules.md` for general Dart and Flutter style, testing, formatting, and
  coding practices.
- Use `skills/skills.md` to identify the correct Flutter skill workflow when a task
  matches one of the listed skills.

Do not invent a new architecture. The project uses the architecture already
written down in `references/aedify-v1-architecture-implementation-plan-v1.0.md`.

## Design System and Mobile UI References

`DESIGN.md` is the approved design-system source for Aedify's Flutter mobile
application. It is self-contained and replaces earlier design-input files.
Agents must not depend on `apple-DESIGN.md`, `DESIGN_DARK.md`, or
`DESIGN_LIGHT.md` being present in the codebase.

Use `DESIGN.md` for:

- light and dark color tokens;
- typography tokens and Flutter text-style mapping;
- spacing and radius tokens in Flutter logical pixels;
- elevation, tonal layering, surface hierarchy, and shadows;
- shapes, cards, buttons, inputs, chips, navigation, empty states, and other
  reusable UI patterns;
- UI do's and don'ts;
- design iteration guidance.

The Flutter mobile design skill pack is the supporting workflow for mobile
interface craft. When unzipped, it should be available as
`skills/flutter_mobile_design_skill_pack/` and contain:

- `SKILL.md` — primary mobile design skill instructions;
- `principles.md` — Flutter mobile craft principles;
- `example.md` — applied examples and decision-making guidance;
- `validation.md` — pattern memory and consistency checks;
- `critique.md` — post-build craft critique workflow;
- `LICENSE.txt` — license terms.

If only `flutter_mobile_design_skill_pack.zip` is present, unzip it before using
the pack as a repository reference. If the pack is installed under a different
agent-skills folder, treat that installed folder as the mobile design skill
pack and apply the same files.

Rules:

- Read `DESIGN.md` before building or changing user-facing UI.
- Apply the mobile design skill pack before creating, modifying, or critiquing
  Flutter mobile screens and shared UI components.
- Build for iOS and Android mobile first, respecting safe areas, touch targets,
  gestures, accessibility settings, text scaling, and small-screen constraints.
- Prefer reusable theme tokens and shared components over one-off visual values.
- Do not introduce random hex colors, spacing values, radii, shadows, fonts, or
  animation curves when a `DESIGN.md` token or pattern exists.
- If `DESIGN.md` conflicts with the locked PRD, architecture plan, privacy
  rules, platform constraints, or direct user instructions, the higher-priority
  source wins.

## Project Constraints

Aedify v1 must remain:

- Flutter single codebase for iOS and Android.
- Local-only and offline-first.
- BYOK for AI providers.
- Private release only, with a maximum of 5 users.
- Useful without AI.
- Privacy-first, with redaction and local validation treated as build gates.

Do not add these unless the user explicitly approves a formal scope change:

- Custom backend service.
- Cloud sync.
- User accounts.
- Hosted plan-sharing links.
- Remote storage of user progress media.
- Behavioral analytics or ad tracking.
- App-managed AI billing.
- Public marketplace or community features.
- Custom user-authored prompt systems.
- OCR pipeline for scanned or image-only PDFs.
- Computer-vision form checking.

## Validated v1 Stack

Use the validated stack from the architecture plan and package validation log:

| Area                                | Decision                                                |
| ----------------------------------- | ------------------------------------------------------- |
| Framework                           | Flutter, latest stable                                  |
| Language                            | Dart                                                    |
| State management                    | Riverpod, latest validated stable version               |
| Durable relational data             | Drift / SQLite                                          |
| Simple preferences                  | `shared_preferences` for non-critical preferences only  |
| Secrets                             | `flutter_secure_storage` for BYOK keys and secrets only |
| HTTP                                | Dio + Retrofit                                          |
| Complex AI/multipart/streaming HTTP | Hand-written Dio adapters                               |
| Firebase                            | Core, Storage, Auth, Crashlytics                        |
| Charts                              | `fl_chart`                                              |
| TTS                                 | `flutter_tts`                                           |
| Notifications                       | `flutter_local_notifications`                           |
| Health integration                  | `health`                                                |
| Video playback                      | `video_player` + `chewie`                               |
| DB encryption support               | `sqlcipher_flutter_libs` where implemented              |
| SVG rendering                       | `flutter_svg`                                           |

Storage boundaries are strict:

- Drift owns durable structured app data and migrations.
- `shared_preferences` is only for simple, non-critical preferences.
- `flutter_secure_storage` is only for API keys and secrets.
- Never store secrets in Drift, shared preferences, logs, Crashlytics, files,
  exports, or share payloads.

## Architecture Rules

Use the modular, local-first, feature-oriented architecture already defined for
Aedify.

Recommended layer shape:

```text
Presentation layer
  Flutter screens, widgets, routing, user interaction

Application layer
  Riverpod controllers, feature coordinators, use cases, validation orchestration

Domain layer
  Plain Dart models, enums, policies, validators, business rules

Data layer
  Drift DAOs, repositories, file-store services, secure storage, preferences,
  network clients

Platform/infrastructure layer
  Firebase, health, notifications, media/camera/gallery, TTS, share sheet,
  PDF/file tooling
```

Dependency direction:

```text
UI widgets
  -> Riverpod controllers
    -> use cases / coordinators
      -> repositories / services
        -> Drift / files / secure storage / network / platform APIs
```

Rules:

- `core/` contains reusable infrastructure with no feature-specific UI
  assumptions.
- `features/` contains product modules and user journeys.
- `ai/` contains AI prompt, provider, schema, validation, repair, reference,
  and candidate-selection infrastructure.
- Feature modules may depend on `core/`, `shared/`, and `ai/` where needed.
- `core/` must not depend on `features/`.
- `ai/` may depend on validation, privacy, networking, and local-data
  abstractions, but must not depend on presentation widgets.
- Do not let UI widgets directly call Drift, Firebase, secure storage,
  file-system services, AI providers, or platform APIs.

## Recommended Project Structure

Follow the structure in the architecture implementation plan:

```text
lib/
  main.dart

  app/
    app.dart
    router/
    theme/
    localization/
    bootstrap/
    feature_flags/

  core/
    db/
      app_database.dart
      migrations/
      tables/
      daos/
      converters/
    storage/
      app_file_paths.dart
      secure_storage_service.dart
      preferences_service.dart
      local_file_store.dart
      temporary_artifact_store.dart
    network/
      dio_client.dart
      network_status.dart
      interceptors/
      retry_policy.dart
      error_mapper.dart
    firebase/
      firebase_bootstrap.dart
      firebase_auth_service.dart
      firebase_storage_client.dart
      crashlytics_service.dart
      crash_redaction.dart
    validation/
    privacy/
    logging/
    errors/
    utils/

  shared/
    widgets/
    components/
    models/
    formatters/
    units/

  features/
    onboarding/
    profile/
    settings/
    exercise_library/
    bodymap/
    workout_builder/
    workout_execution/
    programmes/
    lift_log/
    analytics/
    plateau_detection/
    progress_media/
    ai_infrastructure/
    ai_generation/
    ai_trainer_chat/
    sharing/
    external_import/
    image_import/
    physique_analysis/
    health_integration/
    notifications/

  ai/
    instruction_set/
    prompts/
    schemas/
    providers/
    prompt_builder/
    validation/
    repair/
    reference/
    candidate_selection/
```

Add new files to the closest existing module. Do not create broad catch-all
folders when a feature-owned or core-owned location exists.

## Rules File Boundary

`rules.md` is the general Flutter/Dart project rules file.

Do not add or restore a `Data Handling & Serialization` section to `rules.md`.
Data ownership, persistence, validation, import/export behavior, schema
versioning, AI structured output, and serialization decisions are governed by
the Aedify PRD, architecture plan, data-model implementation plan, and AI
implementation plan, not by generic Flutter rules.

The Flutter skill reference `flutter-implement-json-serialization` may still be
used when explicitly useful, but it must not override Aedify-specific Drift,
schema validation, import/export, privacy, or AI structured-output decisions.

## Required Change and Implementation Tracking

Agents must keep track of project changes and implementation progress by
maintaining two root-level tracking files during development:

- `docs/changelog.md` — records meaningful project changes in reverse chronological
  order.
- `docs/implementation.md` — records implementation progress, current status,
  completed work, active work, blockers, and verification notes.

This is a rule for agents to follow during development. Do not create or update
these files just because `AGENTS.md`, `rules.md`, or `skills/skill.md` is being edited
unless the user explicitly asks for that. During implementation work, if either
tracking file is missing, create it before recording the change.

Agents must update these files whenever they make or materially affect:

- product behavior;
- architecture or module boundaries;
- dependency or configuration choices;
- database, storage, validation, import/export, AI, or privacy behavior;
- feature implementation status;
- tests, quality gates, or release-readiness status;
- documentation that changes how the project should be built or maintained.

Use `docs/changelog.md` for what changed and why it matters. Use
`docs/implementation.md` for how the project currently stands and what was actually
implemented.

Do not treat either file as permission to change product scope. If a change
conflicts with the locked PRD, roadmap, architecture plan, instruction set, or
implementation-plan folders, stop and request explicit approval for a formal
change request or version bump.

Update rules:

1. Add the date of the update.
2. Link or name the affected milestone, feature, module, or file when known.
3. Separate completed work from planned or blocked work.
4. Record verification honestly: tests run, checks skipped, and why.
5. Keep entries concise but specific enough for another agent to continue.
6. Never include secrets, private user data, raw prompts, raw AI responses,
   progress media, source-file extraction artifacts, or sensitive logs.

## Skill Reference Usage

`skills/skills.md` is the reference index for Flutter skills. The Flutter mobile
design skill pack is the supporting design-craft workflow for mobile UI tasks.

When a task matches a listed skill, use that skill workflow as supporting
guidance. When a task touches user-facing UI, also apply `DESIGN.md` and the
Flutter mobile design skill pack. Examples:

- Use widget-test guidance when adding or changing component-level UI behavior.
- Use integration-test guidance for end-to-end app flows.
- Use responsive-layout guidance for adaptive mobile/tablet layouts.
- Use layout-fix guidance for overflow, constraints, and rendering bugs.
- Use declarative-routing guidance only within Aedify's selected routing
  approach.
- Use architecture best-practice guidance only where it does not conflict with
  the Aedify architecture plan.
- Use the Flutter mobile design skill pack when designing or refining screens,
  components, interaction states, motion, empty states, onboarding flows,
  dashboards, settings surfaces, or reusable UI patterns.

Skills are helpers, not source-of-truth documents. `DESIGN.md` is the UI design
system source of truth; the mobile design skill pack explains how to apply it
well in Flutter.

## Implementation Workflow

For every code task:

1. Read the relevant product, architecture, and implementation context.
2. Review `docs/implementation.md` for current status and recent progress when it
   exists.
3. Review `docs/changelog.md` for recent project changes when it exists and the task
   may build on prior work.
4. For user-facing UI work, read `DESIGN.md` and apply the Flutter mobile
   design skill pack before changing widgets, screens, or shared components.
5. Identify the owning feature/module before editing.
6. Make the smallest complete change that satisfies the task.
7. Keep product behavior within the locked v1 scope.
8. Preserve local-first behavior and privacy boundaries.
9. Add or update tests when behavior changes.
10. Run `dart format .` after every implementation change set before any verification. If code generation is involved, run code generation first, then run `dart format .` again, then run `flutter analyze` and `flutter test`.
11. Update `docs/changelog.md` and `docs/implementation.md` whenever the change is
    meaningful or affects project status.
12. Summarize what changed and call out any files or checks that could not be
    completed.

Avoid broad rewrites unless the task explicitly asks for one.

## Coding Rules

Follow `rules.md` for Flutter and Dart coding style, including:

- Clear naming.
- Small, single-purpose functions.
- Immutable widgets and models where practical.
- Composition over inheritance.
- Separation of UI from business logic.
- `const` constructors where possible.
- No expensive work inside `build()`.
- Robust async error handling.
- Public API documentation where appropriate.
- `logging` or the project logging abstraction instead of `print`.

Prefer simple, readable code over clever code.

## Aedify-Specific Conventions

### Colors

- **DO** define all colors in `app_colors.dart` (`AedifyLightColors` / `AedifyDarkColors`) and reference them from there.
- **DON'T** use hardcoded `Color(0x...)` values anywhere outside `app_colors.dart`.
- **DO** populate every `ColorScheme` slot explicitly via `const ColorScheme(...)` — don't rely on `ColorScheme.fromSeed()`.

### Text Styles

- **DO** use `AppTextStyles.*` constants for text styles.
- **DO** use `.copyWith()` when you need to override specific properties of a text style.
- **DON'T** use inline `TextStyle(...)` in widget or theme code.
- **DON'T** hardcode user-facing strings in widgets or feature code; all user-facing
  strings must live in `AppStrings` or a dedicated constants class.
- **DO** allow null-coalescing to an empty string (`?? ''`) for optional data-display
  fields when the intent is to render nothing. Do not treat `''` null-fallbacks as a
  required `AppStrings` constant.
- **DO** move any non-empty user-facing fallback, label, message, or placeholder string
  into `AppStrings` or the appropriate constants file.

### Navigation

- **DO** put route paths and names in `AppRoutes` class (in `app_routes.dart`) using factory constructors with `.path` / `.name` accessors.
- **DON'T** scatter route strings in feature files or `AppStrings`.
- **DO** use `context.pushNamed(AppRoutes.{route}().name)` / `context.goNamed(AppRoutes.{route}().name)`
  for navigation — never `Navigator.pop(context)`, `context.push('/path')`, or
  `context.go('/path')`.
- **DO** use `context.pop()` (from go_router) instead of `Navigator.pop(context)`.

### Constants Organization

- **DO** keep constants in dedicated files by concern (e.g. `db_constants.dart`, `directory_constants.dart`, `app_routes.dart`, `app_strings.dart`).
- **DON'T** put unrelated constant categories in a single monolithic file.
- **DO** put SVG asset paths in `svg_assets_outlined.dart` (`OulinedSvgAssets`) or
  `svg_assets_solid.dart` (`SolidSvgAssets`). Never reference SVG files by raw path.
- **DO** put all layout and sizing tokens (spacing, radius, icon size, divider,
  font size) in `lib/shared/theme/app_spacing.dart` using `AppSpacing`, `AppRadius`,
  `AppSizing`, `AppFontSizes`, and `AppWhiteSpace`.

### Imports

- **DO** use package imports (`package:aedify/...`).
- **DON'T** use relative imports (`../../`).

### Architecture

- **DO** use the context extension `ThemeX` on `BuildContext` for `context.theme`, `context.colorScheme`, `context.textTheme`.
  **DON'T** use `Theme.of(context).colorScheme` or `Theme.of(context).textTheme`.
- **DO** encapsulate all top-level functions, variables, and constants inside classes
  with private constructors and static members. No top-level declarations outside
  `main()` in `main.dart`.
- **DO** use token constants (`AppSpacing.*`, `AppWhiteSpace.*`, `AppRadius.*`) for layout values — no raw numbers.
- **DO** use `EdgeInsets.symmetric(...)` or `EdgeInsets.only(...)`.
  **DON'T** use `EdgeInsets.fromLTRB(...)`.

### SVG Assets

- **DO** use `SvgPicture.asset` from `flutter_svg` instead of Material `Icons.*`.
- **DO** reference SVGs via `OulinedSvgAssets.{camelCaseName}` / `SolidSvgAssets.{camelCaseName}`.
- **DO** store SVGs in `assets/svgs/outline/` (outlined style) and `assets/svgs/solid/` (filled style).
- **DO** use snake_case for SVG filenames. Constants are camelCase.
- **DON'T** reference SVG files by raw asset path strings.

### Strings and Error Messages

- **DO** put all user-facing strings in `AppStrings` (`app_strings.dart`).
- **DO** put error, network, storage, and firebase failure messages in
  `AppErrorStrings` (`app_error_strings.dart`).
- **DON'T** hardcode strings in widgets, features, or core services.
- **DO** allow null-coalescing to an empty string (`?? ''`) for optional data-display
  fields when the intent is to render nothing. See Text Styles section for the full
  rule.
- **DO** search `AppStrings` and `AppErrorStrings` for an existing constant
  before adding a new one — reuse any semantically equivalent string instead
  of duplicating.
- **DON'T** add a new string constant when a matching or equivalent one
  already exists in `AppStrings` or `AppErrorStrings`.

### Spacing and Sizing

- **DO** use `AppSpacing.*`, `AppWhiteSpace.*`, `AppRadius.*`, `AppSizing.*`, and
  `AppFontSizes.*` for all layout values — no raw numbers.
- **DO** define new sizing tokens in `lib/shared/theme/app_spacing.dart` as needed.
- **DON'T** use raw doubles for padding, margin, width, height, icon size, border
  radius, divider height, or inline font sizes.

## State Management Rules

Use Riverpod for:

- App-wide state.
- Async workflows.
- Dependency injection.
- Feature controllers.
- Testable access to repositories and services.

Keep ephemeral widget-only state inside widgets when it does not need to leave
the widget subtree. Keep durable state in Drift or the appropriate storage
service. Do not use `BuildContext` as a dependency container.

## Routing Rules

Use the routing approach selected by the project architecture and app shell.
Routes should be declarative, typed where practical, and owned by the app/router
module. Do not scatter navigation constants through feature widgets.

Use temporary navigation APIs only for short-lived UI such as dialogs, sheets,
and local flows that do not need deep links.

## Privacy and Safety Rules

Privacy is a build gate.

Agents must not send, log, export, or persist sensitive material outside its
approved boundary. This includes:

- BYOK provider keys.
- Raw prompts and raw AI responses.
- Progress media.
- AI physique-analysis payloads and results unless explicitly saved locally.
- Imported source files and extraction artifacts unless the PRD says they are
  saved.
- Crashlytics payloads containing private data.
- `.aedifyplan` exports containing private logs, source files, AI internals, or
  progress media.

Crashlytics must be aggressively redacted. Exports and sharing flows must pass
privacy filters before leaving the app.

## AI Feature Rules

AI is optional and BYOK-only.

For app-actionable AI responses:

- Use the correct prompt module and operation subtype.
- Return and consume structured JSON only when the schema requires it.
- Validate all AI output locally before persistence.
- Repair invalid output through the approved repair flow rather than saving it.
- Require user review before saving generated/imported programmes or workouts
  where the PRD requires review.
- Do not let AI decide persistence, schema validity, privacy eligibility,
  provider support, or exercise ID correctness.

The app owns validation, persistence, privacy filtering, and user confirmation.

## Exercise Dataset Rules

The MuscleWiki-derived exercise dataset is a versioned app dataset. Treat it as
reference data, not user-authored data.

Rules:

- Validate dataset schema versions before import.
- Keep exercise IDs stable.
- Do not silently mutate source exercise records during feature work.
- Use the transformed Firebase-ready dataset shape expected by the app.
- Use generated bodymap assets for bodymap behavior; do not rely on removed
  MuscleWiki bodymap fields.

## Testing and Quality Gates

Formatting is a required quality gate. Agents must run `dart format .` before
analysis and tests, and must run `dart format .` again after code generation
when code generation is involved. If formatting is skipped, the task is not
complete.

When relevant, run:

```bash
dart format .
flutter analyze
flutter test
```

When code generation is involved, run the project-approved build runner command,
then re-run format/analyze/tests:

```bash
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
```

Add tests at the correct level:

- Unit tests for domain policies, validators, repositories, and services.
- Widget tests for reusable widgets and screen behavior.
- Integration tests for full user journeys and critical flows.

If a check cannot be run, state that clearly and explain why.

## Documentation Rules

Update documentation when implementation decisions, commands, or project
structure change.

During implementation, keep `docs/changelog.md` and `docs/implementation.md` in sync with
meaningful implementation or project-status changes. These files are operational
tracking records; they do not replace the PRD, roadmap, architecture plan,
instruction set, implementation-plan folders, or formal change-request process.

Do not silently update the PRD, roadmap, architecture plan, instruction set, or
detailed implementation plans for new product behavior. Product changes require
explicit user approval and a version bump/change request.

## Agent Response Rules

When reporting back:

- Be direct and concise.
- List changed files.
- Mention tests/checks run.
- Mention known limitations or follow-up work.
- Do not claim a check passed unless it was actually run and passed.

When uncertain, inspect the project files first. If the task is still ambiguous,
ask a focused clarifying question unless a reasonable, low-risk implementation
path is obvious.
