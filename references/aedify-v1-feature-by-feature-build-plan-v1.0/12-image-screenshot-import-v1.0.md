# Image/Screenshot External Import Build Plan

| Field | Value |
|---|---|
| Product | Aedify |
| Document Set | Feature-by-Feature Build Plan |
| File Version | 1.0 |
| File ID | FBP-12 |
| Milestone Coverage | M12 |
| Source Roadmap | `aedify-v1-implementation-roadmap-tech-stack-updated-v1.3.md` |
| Source Architecture Plan | `aedify-v1-architecture-implementation-plan-v1.0.md` |
| Source Baseline | PRD v1.10 / v1 Final — Re-locked after Package Validation |
| Status | Implementation Planning |
| Platforms | iOS and Android, Flutter single codebase |
| Architecture Constraint | Local-only, offline-first, BYOK AI |
| Created | 2026-06-10 |

---

## 1. Document Rule

This file breaks implementation work into buildable feature slices. It does not change product scope, product requirements, user journeys, privacy rules, or milestone ordering. If implementation reveals a product behavior that is not already covered by the locked PRD, that behavior must be handled as a formal change request or future PRD version bump.

The validated v1 stack is assumed throughout this file:

- Flutter + Dart for the iOS/Android app.
- Riverpod for dependency injection, feature controllers, and async workflow state.
- Drift / SQLite for durable structured app data and migrations.
- `shared_preferences` for simple, non-critical preferences only.
- `flutter_secure_storage` for BYOK API keys and other secrets only.
- Dio + Retrofit for HTTP, with hand-written Dio adapters for complex AI, streaming, image, multipart, or provider-specific calls.
- Firebase Storage for the exercise dataset, Firebase Auth for anonymous dataset access, and Firebase Crashlytics for crash diagnostics only.

---


## 2. Feature Objective

Extend external import to screenshots/images by adding image selection, user ordering, local readability enhancement, quality warnings, multimodal provider/model gating, AI image parse/repair, and temporary artifact cleanup.

## 3. User-Facing Outcomes

- User can select one or more screenshots/images.
- User can reorder multiple images before extraction.
- App can enhance low-quality images for readability only.
- Unsupported BYOK models are blocked before prompt assembly.
- AI image import produces the same structured draft/review flow as text import.

## 4. Scope

### 4.1 In Scope

- PNG/JPG/JPEG/WEBP and HEIC/HEIF where platform-supported
- Multi-image selection
- Drag reorder screen
- Local image quality checks
- Readability enhancement: rotation, crop, de-skew, brightness/contrast, sharpening, noise reduction, upscaling where practical
- Original vs enhanced preview
- Image-capable provider gate
- `image_parse` and `image_repair` operation subtypes
- Image import metadata
- Temporary artifact cleanup

### 4.2 Out of Scope

- OCR for scanned/image-only PDFs
- AI invention of missing content
- Automatic adaptation/personalization
- Long-term storage of original/enhanced screenshots by default

## 5. Dependencies and Unlocks

### 5.1 Required Before This Feature

- M7 AI infrastructure
- M11 external import draft/review/matching
- M1 file store
- M3 provider capabilities

### 5.2 Enables Later Work

- Users with screenshot programmes can import without manual transcription

## 6. Data Ownership and Storage Plan

- Reuse external import draft tables.
- Add metadata fields: source_input_type, source_file_types, image_count, order_source, enhancement_methods, image_quality, unreadable_regions, missing_or_unclear_content.
- Temporary file records for original/enhanced images must include expiry and cleanup status.

Storage rules for this feature:

- Durable structured records belong in Drift.
- Binary files and generated artifacts belong in the local app file store.
- Simple non-critical UI preferences may use `shared_preferences` only when explicitly allowed.
- Secrets must use `flutter_secure_storage` only.
- No feature-owned repository may bypass the wrappers created in M1.

## 7. Riverpod / Application Layer Plan

- `imageImportSelectionControllerProvider`
- `imageOrderControllerProvider`
- `imageEnhancementControllerProvider`
- `imageQualityControllerProvider`
- `imageImportParseControllerProvider`
- `imageArtifactCleanupProvider`

Controller rules:

- Controllers expose explicit state objects, not loose nullable fields.
- Controllers do not directly write to Drift; they call use cases or repositories.
- Controllers must expose validation errors separately from provider/network/storage failures.
- Long-running flows must support cancellation where possible.
- Feature controllers must be testable with fake repositories/services.

## 8. Screens and UX States

- Image import source picker
- Image selection screen
- Reorder screen
- Enhancement preview
- Provider unsupported blocker
- Image import progress
- Import review with image metadata and unclear fields

Every screen in this feature must define:

- loading state;
- empty state;
- validation-error state;
- blocked/unsupported state where relevant;
- retryable failure state;
- user-cancelled state where relevant;
- success/confirmation state.

## 9. Core User and System Flows

- Select images, validate formats/count, reorder if multiple, run local quality/enhancement if needed, show preview, check image-capable provider, ask AI consent, send selected original/enhanced images plus metadata, validate draft, reuse M11 resolution/review/save.

## 10. Validation Rules

- User-defined order becomes source order.
- Enhancement must not alter programme content.
- AI must not invent missing text, complete cropped tables, change numbers, or alter programme content.
- Poor quality lowers confidence and flags limitations.
- Unreadable content returns needs-input/blocked.

Validation should happen before persistence. When validation fails, the UI should show actionable errors and preserve user input where possible.

## 11. Privacy and Security Rules

- Original screenshots, enhanced screenshots, image-processing artifacts, and source excerpts are excluded from Crashlytics, exports, `.aedifyplan`, PDFs, and default sharing.
- Temporary artifacts cleaned after import completion/cancel/expiry.
- Selected images sent to AI only after explicit consent.

Privacy checks are part of the acceptance gate, not polish.

## 12. Error and Edge States

- Unsupported image format
- Too many images for provider
- Image unreadable
- Provider/model lacks image support
- Enhancement failed
- AI parse failed
- Artifact cleanup failed

Each error state must map to a safe user-facing message and a redacted internal error code.

## 13. Ticket Breakdown

| Ticket | Title | Implementation Note |
|---|---|---|
| M12-T01 | Build image selection UI | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M12-T02 | Build reorder UI | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M12-T03 | Implement image temp file records | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M12-T04 | Implement readability enhancement pipeline | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M12-T05 | Build enhancement preview | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M12-T06 | Implement image-capability gate | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M12-T07 | Implement image_parse operation | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M12-T08 | Extend import review metadata | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M12-T09 | Implement cleanup jobs | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |
| M12-T10 | Add M12 tests | Create implementation ticket with user story, implementation notes, data/privacy impact, acceptance criteria, and QA steps. |

## 14. Acceptance Criteria

- Multiple images can be selected and reordered.
- Unsupported provider is blocked before prompt assembly.
- Enhancement preview allows originals/enhanced/reselect/cancel.
- Unreadable regions appear in review.
- Temporary artifacts are cleaned.
- No image artifacts appear in exports/logs.

## 15. Manual QA Checklist

- Import single screenshot.
- Import multi-screenshot plan and reorder.
- Use enhanced images.
- Use originals.
- Try unsupported model.
- Try blurry/cropped image.
- Cancel midway and verify cleanup.

## 16. Automated Test Coverage

- Image format validation tests
- Order metadata tests
- Capability gate tests
- Quality warning tests
- Artifact cleanup tests
- Image import schema tests

## 17. Handoff Notes

- M14 must audit temporary image artifact cleanup and privacy exclusions.

## 15. Implementation Exit Standard

A feature slice is not complete until all of the following are true:

- The UI path works on both iOS and Android.
- All durable writes are transactional where multiple records must stay consistent.
- Riverpod controllers expose explicit loading, success, empty, validation-error, blocked, and failure states where relevant.
- Drift migrations or schema-version checks are covered by tests when durable tables are added or changed.
- Sensitive fields are not written to `shared_preferences`, logs, Crashlytics, exports, or temporary artifacts.
- Error messages tell the user what happened and what they can do next.
- The feature still works offline unless the locked PRD explicitly requires network or AI access.
- Manual QA steps have been executed and captured before moving to the next dependent feature.
