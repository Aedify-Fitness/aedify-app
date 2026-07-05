# 08 — External Text File Import AI Plan v1.0


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

This file defines the AI implementation for M11 External Text File Import.

The app imports supported text-based sources, extracts programme/workout content locally, asks for AI-processing consent, sends only programme-relevant extracted content to the user's BYOK provider, and receives a structured draft.

---

## 2. Supported Inputs

AI text import works after local extraction from:

- text-based PDF;
- TXT;
- MD;
- XLSX;
- CSV.

Out of scope for this flow:

- scanned/image-only PDFs;
- encrypted PDFs;
- corrupted files;
- cloud-hosted imports;
- direct screenshot/image imports, which belong to M12 image import.

---

## 3. Import Pipeline

```text
User selects file
  → local file validation
  → local text/table extraction
  → programme/workout relevance filter
  → extraction preview
  → AI-processing consent
  → prompt builder creates import parse request
  → provider call
  → structured draft validation
  → repair once if eligible
  → exercise matching/resolution
  → review draft
  → save inactive by default
```

---

## 4. Consent Gate

Before sending extracted content to AI, show:

- selected file name/type;
- what will be sent: programme/workout-relevant extracted text/tables;
- what will not be sent: API key, unrelated profile/log data, original file by default;
- provider/model selected;
- reminder that provider may process/store data under their own terms;
- cancel/continue options.

Consent result should be stored as local metadata for the import session.

---

## 5. Prompt Context for Import Parse

Include:

- operation ID;
- import mode: extract/normalize/structure only;
- source file type;
- extracted programme-relevant text/tables;
- unit hints if detected;
- schema;
- instruction not to adapt or personalize;
- instruction to flag missing/unclear data;
- instruction to preserve source duration;
- instruction to preserve visible supersets/warm-up labels when clear.

Exclude:

- full user profile;
- lift logs;
- injuries;
- goals;
- media;
- source file path;
- API key;
- raw app database data.

Profile/log data may be included only in a later explicit adaptation flow, not default import parse.

---

## 6. Import Output Requirements

AI must return structured JSON for either:

- external programme import; or
- external workout import.

Required draft concepts:

- detected source type;
- programme/workout title if visible or inferred cautiously;
- source duration if visible;
- days/weeks/sessions;
- exercises as source names;
- sets/reps/weights/rest/RPE where visible;
- units and ambiguity flags;
- supersets if visible;
- warm-up/working labels if visible;
- missing/unclear content list;
- extraction assumptions;
- no adaptation unless explicitly requested.

---

## 7. Exercise Resolution

The AI parse output may contain source exercise names. The app resolves them locally.

Resolution statuses:

| Status | Meaning |
|---|---|
| `auto_matched` | Exact/alias high-confidence local match. |
| `needs_confirmation` | Ambiguous match requiring user selection. |
| `unmatched` | No safe match. |
| `custom_draft` | User may create custom exercise. |
| `removed` | User chooses to remove exercise from import. |
| `resolved` | User confirmed a match/custom/removal. |

AI match assist can help rank ambiguous choices, but user confirmation is required where confidence is insufficient.

---

## 8. Import Repair

Repair is allowed when:

- JSON invalid;
- envelope missing;
- source duration omitted despite visible data;
- units marked inconsistently;
- sessions malformed;
- set/reps malformed;
- missing required import metadata;
- AI adapted source despite extract-only instruction.

Repair must not invent missing source content.

---

## 9. Save Behavior

Imported programmes/workouts are saved inactive by default.

Before save:

- all blockers resolved;
- exercise matches resolved;
- custom exercise required fields confirmed;
- units clear or user confirms ambiguity;
- source content stripped from exportable fields;
- user reviews final draft.

After save:

- app generates local IDs;
- records import provenance;
- links custom exercises if created;
- does not store original source file by default;
- does not export source content later.

---

## 10. Acceptance Gate

External text import AI is accepted when:

- unsupported files are blocked before AI;
- consent is required before provider call;
- prompt excludes profile/log data by default;
- AI output is extract/normalize/structure only;
- imported duration can be shorter than AI-generated minimum when source is shorter;
- exercise matching requires confirmation where ambiguous;
- unresolved exercises block save;
- original source text/raw AI internals are not persisted/exported;
- import draft saves inactive by default.
