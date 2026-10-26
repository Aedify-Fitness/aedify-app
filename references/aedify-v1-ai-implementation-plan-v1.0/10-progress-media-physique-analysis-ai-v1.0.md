# 10 — Progress Media and AI Physique Analysis Plan v1.0


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

This file defines AI implementation for M13 Optional AI Physique Analysis.

Progress Media Tracking is built earlier in M6. M13 adds an explicit-consent AI layer that can analyze selected progress photos or locally extracted video frames.

---

## 2. Allowed Analysis Modes

| Mode | Operation | Input | Output |
|---|---|---|---|
| Single analysis | `PROGRESS_MEDIA_ANALYSIS_ANALYZE` | Selected media from one session | Rough body-fat range, confidence, observations, training-focused feedback. |
| Comparison | `PROGRESS_MEDIA_ANALYSIS_COMPARE` | Selected media from baseline/latest or previous/latest | Change observations, confidence, limitations, training-focused feedback. |
| Repair | `PROGRESS_MEDIA_ANALYSIS_REPAIR` | Failed/invalid analysis output | Corrected structured output. |

---

## 3. Consent Gate

Before sending media/frames to AI, show:

- selected media count and types;
- provider/model name;
- what will be sent: selected photos or extracted frames only;
- what will not be sent: full logs, API keys, unrelated media, private app database;
- warning that body-fat estimate is rough visual range only;
- statement that this is not medical diagnosis;
- provider data-processing reminder;
- cancel/continue controls.

Consent is per analysis request, not global forever consent.

---

## 4. Media Packaging

Preferred input strategy:

- photos: selected front/back/left/right images;
- video: locally extract canonical frames, preferably front/back/left/right;
- do not upload full video by default;
- include capture dates and view labels if known;
- include optional bodyweight/measurement snapshot only if user selected/allowed and useful;
- exclude workout logs unless later user asks for training recommendations and consents to context.

```text
ProgressMediaPackageDto
  operation_id
  analysis_mode
  selected_session_ids
  media_items[]
    view_type: front | back | left | right | unknown
    source_type: photo | extracted_frame
    capture_date
    quality_metadata
  comparison_metadata?
  consent_record_id
  schema
```

---

## 5. Output Requirements

AI must return structured JSON.

Required fields:

- rough body-fat range, not exact value;
- confidence level;
- limitations;
- visible physique observations;
- comparison observations if compare mode;
- training-focused feedback;
- suggested tracking consistency improvements;
- safety disclaimers where appropriate;
- no medical diagnosis;
- no precise body-composition claims;
- no attractiveness score;
- no body shaming;
- no extreme dieting advice.

---

## 6. Body-Fat Range Validation

Valid:

```text
body_fat_range:
  min_percent: 14
  max_percent: 18
confidence: medium
```

Invalid:

```text
body_fat_percent: 15.2
```

Invalid:

```text
exact_body_fat: "15%"
```

Validation should require a range width wide enough to reflect uncertainty. Implementation may set a minimum range width, such as 3–5 percentage points, unless the PRD later defines a different rule.

---

## 7. Safety Filter

Block or repair if output contains:

- diagnosis of medical condition;
- certainty about hormones, disease, eating disorders, or health status;
- precise body-fat claim;
- attractiveness rating;
- insulting/shaming language;
- extreme dieting recommendation;
- supplement/drug recommendation for rapid fat loss;
- advice to ignore pain or injury;
- false claim of measurement accuracy.

---

## 8. Comparison Mode

Comparison mode should use local media selection:

- baseline vs latest;
- previous vs latest.

AI should describe visible changes cautiously:

- “appears slightly leaner around…”;
- “lighting/pose differences limit confidence…”;
- “muscle fullness appears…”;
- “no reliable change visible from these images…”;

AI should not:

- invent exact fat/muscle mass change;
- claim precise measurements;
- overstate confidence when image conditions differ.

---

## 9. Persistence

Analysis results remain local by default.

Persist:

- analysis snapshot;
- schema version;
- provider/model metadata;
- consent timestamp;
- linked media/session IDs;
- rough range;
- confidence;
- limitations;
- observations;
- training-focused feedback;
- validation status.

Do not persist:

- raw prompt;
- raw response by default;
- provider auth headers;
- copied image bytes inside Drift;
- API key;
- Crashlytics copies of media/results.

Exclude analysis results from:

- `.aedifyplan` exports;
- PDF plan exports;
- external imports;
- Crashlytics;
- source-reference payloads.

---

## 10. Acceptance Gate

Physique analysis AI is accepted when:

- media tracking exists before analysis;
- image-capable model gate works;
- explicit consent is required every analysis request;
- video analysis uses selected/extracted frames by default;
- output is structured and validated;
- exact body-fat values are rejected;
- unsafe/medical/shaming/attractiveness outputs are rejected;
- analysis snapshots remain local;
- media/results are excluded from Crashlytics and exports.
