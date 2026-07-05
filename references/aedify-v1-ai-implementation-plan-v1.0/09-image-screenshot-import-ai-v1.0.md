# 09 — Image and Screenshot Import AI Plan v1.0


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

This file defines AI implementation for M12 Image/Screenshot External Import.

This flow converts selected screenshots/images into structured local programme/workout drafts using an image-capable BYOK provider/model after explicit consent.

---

## 2. Supported Image Inputs

Supported where platform/package support exists:

- PNG;
- JPG/JPEG;
- WEBP;
- HEIC/HEIF where platform-supported.

The app should support multi-image selection and user-defined ordering. User order becomes the source order for extraction.

---

## 3. Capability Gate

Before image import AI call:

1. selected provider exists;
2. selected model exists;
3. API key is valid or previously validated;
4. `supports_image_input = true`;
5. selected image count fits provider/app constraints;
6. selected images fit size/dimension constraints or can be locally compressed/enhanced safely;
7. user has accepted image import AI consent.

If not supported, show a blocked state:

> “Screenshot import requires an image-capable AI model. Choose a compatible model or import a text-based file instead.”

---

## 4. Local Readability Enhancement

Local preprocessing is readability-only.

Allowed:

- orientation correction;
- crop;
- de-skew;
- brightness/contrast adjustment;
- sharpening;
- noise reduction;
- upscaling where practical;
- file format conversion for provider compatibility;
- image size reduction for provider limits.

Forbidden:

- changing numbers;
- filling missing table cells;
- inventing cropped text;
- altering exercise names;
- changing programme content;
- using enhancement as a source of new programme meaning.

The image import metadata must record which enhancement methods were applied.

---

## 5. Image Import Consent

Consent screen must explain:

- selected original/enhanced images may be sent to provider;
- provider/model name;
- purpose: extract visible programme/workout content;
- local enhancement is readability-only;
- AI may be wrong and user must review;
- unreadable/cropped content should be flagged, not guessed;
- images and artifacts are not included in exports or Crashlytics;
- user can cancel.

---

## 6. Image Prompt Package

Prompt package includes:

```text
ImageImportPackageDto
  operation_id
  source_input_type: image | screenshot_set
  image_count
  image_order_source: user_defined | file_picker_order
  images: provider attachments or content parts
  image_metadata[]
    file_type
    original_dimensions
    enhanced_dimensions?
    enhancement_methods[]
    quality_score?
    order_index
  user_instruction
  schema
  extraction_mode: extract_only
```

Exclude:

- full user profile;
- lift logs;
- progress media unrelated to import;
- API key;
- local absolute paths in prompt text;
- original images from Crashlytics/export;
- source reference corpus.

---

## 7. Image Parse Output Requirements

AI output must:

- return structured JSON only;
- preserve visible source programme/workout content;
- use existing external import schema;
- include image import metadata;
- list unreadable regions;
- list missing/unclear content;
- flag low confidence fields;
- not invent cropped/missing text;
- not complete invisible table cells;
- not change numbers;
- not adapt/personalize source plan;
- leave unresolved exercise names for local matching.

---

## 8. Unreadable Content Handling

The schema should capture:

```text
UnreadableRegion
  image_order_index
  approximate_location: top | middle | bottom | left | right | table_row | unknown
  reason: blurry | cropped | obscured | low_resolution | glare | handwriting_unclear | unknown
  affected_content_type: exercise_name | sets | reps | load | rest | notes | schedule | unknown
  ai_action: omitted | partial_extraction | needs_user_review
```

Validation should block or warn when image quality metadata indicates low readability but AI reports no uncertainty.

---

## 9. Image Repair

Image repair can be used when:

- structured JSON invalid;
- metadata missing;
- unreadable regions missing despite obvious low quality;
- source order ignored;
- schema mismatch;
- response adapts rather than extracts;
- AI produces exact invented details for unclear areas.

Repair prompt must restate:

- preserve visible content only;
- mark unclear content;
- do not invent;
- follow schema.

If repair fails, show user manual correction/retry options.

---

## 10. Temporary Artifact Cleanup

Original imported screenshots and enhanced images are temporary by default.

Cleanup triggers:

- user cancels import;
- draft saved and source retention not enabled;
- import session expires;
- app cleanup job runs;
- user deletes import draft;
- validation permanently fails and user discards.

Never include original/enhanced screenshots in:

- `.aedifyplan`;
- PDF export;
- Crashlytics;
- plan sharing;
- external import exports;
- prompt/response debug logs.

---

## 11. Acceptance Gate

Image import AI is accepted when:

- image capability gate blocks unsupported models;
- consent is required before images are sent;
- user-defined order is preserved;
- local enhancement metadata is captured;
- prompt excludes profile/log data by default;
- AI is instructed and validated not to invent unreadable content;
- unreadable regions are represented;
- exercise matching uses existing import resolution flow;
- artifacts are deleted after save/cancel/expiry;
- screenshots/artifacts never reach Crashlytics or exports.
