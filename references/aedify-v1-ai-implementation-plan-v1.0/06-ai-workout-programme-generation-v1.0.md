# 06 — AI Workout and Programme Generation Plan v1.0


| Field | Value |
|---|---|
| Document Package | AI Implementation Plan |
| Package Version | v1.0 |
| Source Baseline | PRD v1.10 Final / Re-locked after Package Validation |
| Roadmap Baseline | `aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md` |
| Architecture Baseline | `aedify-v1-architecture-implementation-plan-v1.0.md` |
| Feature Plan Baseline | `v1-feature-by-feature-build-plan-v1.0/` |
| Data Model Baseline | `v1-data-model-implementation-plan-v1.0/` |
| Status | Implementation Planning |
| Scope Rule | No product scope change; implementation-only breakdown |
| Platforms | iOS and Android |
| App Architecture | Local-only, offline-first, BYOK AI |
| State Management | Riverpod, latest validated stable version |
| Durable Data | Drift / SQLite |
| Simple Preferences | `shared_preferences` only for non-critical values |
| Secrets | `flutter_secure_storage` only |
| Networking | Dio + Retrofit, with hand-written Dio adapters for complex AI calls |
| Created | 2026-06-14 |


---

## 1. Purpose

This file defines implementation for M8 AI Workout + Programme Generation.

It covers:

- today-only workout generation;
- multi-week programme generation;
- beginner choice flow;
- Beginner Path A strict wiki-derived programme generation;
- Beginner Path B user-configured programme generation;
- non-beginner generation;
- strength-anchor handling;
- warm-up/working set rules;
- superset rules;
- powerbuilding routing;
- validation and review before save.

---

## 2. Generation Flow Overview

```text
User requests workout/programme
  → collect generation config
  → check BYOK provider configured
  → check provider supports text
  → build profile + log + working-weight DTOs
  → build candidate exercise list
  → select reference files if needed
  → select schema
  → build prompt
  → provider call
  → validate structured output
  → repair once if eligible
  → show review draft
  → user edits/accepts/cancels
  → app persists transactionally
```

---

## 3. Daily Workout Generation

### Inputs

- user profile;
- requested focus or goal;
- session length;
- available equipment;
- training experience;
- injuries/substitutions;
- recent lift log slice;
- current working weights where relevant;
- optional active programme context;
- user note/context for today;
- warm-up/cooldown preference.

### Output requirements

- structured JSON only;
- valid response envelope;
- workout title;
- workout intent;
- exercise list using candidate exercise IDs;
- set-level prescriptions;
- each prescribed set marked `warmup` or `working` where required;
- rest guidance where available;
- optional RPE/RIR targets;
- notes/cues where useful;
- supersets only when allowed;
- clear calibration notes where loads are estimates;
- no direct persistence until review.

### Validation blockers

- unknown exercise ID;
- exercise outside candidate list;
- missing required set prescription;
- forbidden beginner superset;
- warm-up set invalid;
- strength prescription missing needed anchor and status is not `needs_input`;
- injury/substitution conflict;
- malformed duration/session structure.

---

## 4. Multi-Week Programme Generation

### Inputs

- goal(s);
- training days/week;
- preferred days;
- target session duration;
- experience level;
- equipment;
- known 1RMs;
- recent working weights;
- recent lift log;
- injuries/substitutions/favorites;
- periodization preference if provided;
- user request text;
- candidate programme list;
- selected reference files.

### Output requirements

- structured JSON only;
- template-based programme by default;
- minimum 8 weeks for AI-generated programmes except external imports preserving source duration;
- weekly schedule;
- reusable workout templates;
- set-level prescriptions;
- warm-up policy;
- progression rules;
- deload rules;
- calibration week where required;
- exercise IDs from candidate list;
- programme can be expanded locally before save;
- review draft before persistence.

---

## 5. Beginner Choice Flow

Beginner programme generation starts with a choice-first flow.

| Path | Meaning | AI Behavior |
|---|---|---|
| Path A | Strict beginner routine inferred from wiki guidance | AI follows bundled wiki beginner guidance strictly and maps to local exercise IDs. |
| Path B | Custom beginner programme based on user choices | AI may personalize within beginner-safe rules but still excludes advanced elements. |

Path A rules:

- follow beginner guidance strictly;
- keep programme simple;
- no powerbuilding reference;
- no AI advanced elements;
- no AI-generated supersets;
- no AI-generated beginner warm-up sets if locked beginner rule says excluded;
- use candidate IDs only;
- return structured JSON;
- app validates and saves only after review.

Path B rules:

- user configuration may shape schedule/equipment/goals;
- still beginner-safe;
- no powerbuilding reference;
- no advanced intensity techniques;
- no aggressive volume;
- no supersets for AI-generated beginner outputs;
- calibration estimates must be conservative.

---

## 6. Strength Anchors

For Build Strength and strength-biased requests, the AI should anchor prescriptions in this priority order:

1. recent working weights from logs;
2. known 1RMs;
3. bodyweight-relative conservative estimates;
4. `needs_input` if no useful anchor exists.

Implementation details:

- app computes working weights locally;
- prompt passes working weights in a compact table;
- AI may flag calibration estimates;
- app validates warm-up calculations where absolute working weights exist;
- app should not let AI silently invent heavy loads without context;
- missing strength anchors should become a review warning or `needs_input` depending goal.

---

## 7. Warm-Up and Working Set Rules

Set-level prescription is required.

Rules:

- every prescribed set that matters to tracking must have `set_type = warmup | working`;
- warm-up sets for non-beginner strength-focused AI outputs precede working sets on relevant loaded strength exercises;
- warm-up load must not exceed 80% of associated working weight;
- warm-up calculations should be locally checkable;
- warm-ups are excluded from PR/e1RM/plateau/progression/default analytics;
- working sets drive progression.

Validation examples:

- warm-up after working set → blocker;
- warm-up weight higher than working weight → blocker;
- warm-up above 80% associated working set → blocker;
- missing `set_type` → blocker;
- beginner AI-generated warm-up set where forbidden → blocker.

---

## 8. Superset Rules

Superset rules depend on source and experience.

| Context | Supersets Allowed? |
|---|---|
| Manual custom workout/programme | Yes, all levels. |
| AI-generated beginner workout/programme | No. |
| AI-generated non-beginner workout/programme | Yes. |
| Imported source contains supersets | Preserve if source clearly includes them and user resolves review. |

Validation:

- superset group IDs must be coherent;
- group must contain at least two exercises;
- set order must be clear;
- beginner AI-generated output with supersets blocks save;
- imported supersets require source clarity or review warning.

---

## 9. Powerbuilding Generation

Eligible only for non-beginner users with both Build Strength and Build Muscle goals.

Implementation checks before prompt:

```text
is_non_beginner == true
AND goals include Build Strength
AND goals include Build Muscle
AND operation allows generation/advice
AND request is not beginner path
AND request is not extract-only import
```

If eligible:

- include `aedify-aedify-09-powerbuilding-strength-hypertrophy.md` as supplemental reference;
- include candidate list with primary/secondary/tertiary potential;
- allow optional metadata: `training_style`, `reference_strategy`, `exercise_role`, `set_intent`, `loading_model`, `block_type`;
- require fatigue management;
- forbid reconstruction of paid/source programme tables;
- validate beginner exclusion.

---

## 10. Review Draft UX Requirements

Review screen must show:

- generated programme/workout title;
- goal and rationale summary;
- provider/model used;
- validation status;
- blockers/warnings;
- exercises and set prescriptions;
- warm-up vs working labels;
- progression rules;
- deload rules;
- schedule preview;
- calibration notes;
- supersets;
- save/cancel controls.

The user should be able to:

- edit title;
- inspect exercise details;
- substitute exercises;
- adjust simple prescriptions before save where supported;
- discard draft;
- save to library.

---

## 11. Persistence After Save

After user accepts:

- app generates local IDs;
- writes programme/workout/template rows in a Drift transaction;
- links sanitized AI generation snapshot if needed;
- stores source as `ai-generated` or `ai-chat` depending flow;
- stores schema version and provider/model metadata;
- does not store raw prompt/response;
- does not store candidate list;
- does not write to shared preferences.

---

## 12. Acceptance Gate

AI generation is accepted when:

- daily workout generation validates and saves through review;
- multi-week programme generation validates, expands, and saves through review;
- beginner Path A excludes powerbuilding and advanced features;
- beginner outputs reject supersets;
- non-beginner strength outputs validate warm-up/working set rules;
- unknown exercises are rejected;
- powerbuilding routing only activates for eligible users;
- provider errors and repair failures are recoverable;
- no raw prompt/response/candidate list is stored or sent to Crashlytics.
