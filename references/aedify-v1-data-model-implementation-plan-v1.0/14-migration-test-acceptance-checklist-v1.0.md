# 14 — Migration, Data Tests, and Acceptance Checklist v1.0

## 1. Purpose

This file defines the data-model testing plan and the acceptance criteria required before implementation can be considered safe for v1 private release.

---

## 2. Migration Test Matrix

| Test ID | Scenario | Expected Result |
|---|---|---|
| MIG-001 | Fresh install opens database | All base tables created. |
| MIG-002 | Upgrade from schema N to N+1 | User data preserved. |
| MIG-003 | Failed migration simulation | App reports recoverable redacted error. |
| MIG-004 | JSON converter reads old nullable field | No crash; default value applied. |
| MIG-005 | Unknown enum from old data | Graceful fallback or migration. |
| MIG-006 | Exercise dataset refresh | Custom exercises and user flags preserved. |
| MIG-007 | Unsupported dataset schema | User sees update-required state. |
| MIG-008 | Compatible dataset schema | Local migration + atomic write. |
| MIG-009 | File path root changes | Relative paths still resolvable. |
| MIG-010 | Shared preferences wiped | Core app data still intact. |
| MIG-011 | Secure storage key deleted | Provider config shows key missing; no crash. |
| MIG-012 | App startup cleanup | Temp artifacts removed; user media preserved. |

---

## 3. Domain Test Matrix

### 3.1 Exercise Library

```text
first sync success
sync failure leaves old DB untouched
manual refresh does not delete custom exercises
candidate DTO excludes forbidden data
bodymap buckets match dataset buckets
```

### 3.2 Profile and Settings

```text
canonical unit storage
display unit conversion
secure API key storage
provider capability cache
shared preferences wipe resilience
```

### 3.3 Programmes and Logging

```text
manual programme save transaction
AI programme validation then save
template expansion
warm-up exclusion from analytics
completed logs immutable under programme revisions
superset validation
```

### 3.4 Analytics

```text
e1RM calculation only for eligible working sets
PR detection
plateau flag creation
cache invalidation
analytics available offline
```

### 3.5 Progress Media

```text
media capture/import
thumbnail generation
baseline assignment
partial session handling
reminder scheduling after first session only
file deletion
```

### 3.6 AI

```text
provider config without key blocks calls
structured output validation
repair attempt limit
snapshot sanitization
Crashlytics redaction
```

### 3.7 Sharing

```text
.aedifyplan export/import
custom exercise remapping
PDF export
privacy mode warning
export sanitizer
```

### 3.8 External Import

```text
draft creation
exercise matching
custom exercise draft confirmation
save inactive by default
source file exclusion
```

### 3.9 Image Import

```text
supported file validation
multi-image ordering
provider image capability gate
enhancement metadata
artifact cleanup
export exclusion
```

### 3.10 Physique Analysis

```text
explicit consent
image-capable provider check
frame extraction
range-based body-fat result
snapshot local-only
delete dependency handling
```

---

## 4. Data Model Acceptance Gate

Before private release:

- All Drift migrations pass from every released schema.
- All tables have indexes for expected high-volume queries.
- All file-backed tables have deletion tests.
- All AI-facing DTOs are allowlist-based.
- All export DTOs are sanitizer-tested.
- All Crashlytics contexts are generated through redaction utility.
- All secure storage tests prove API keys never enter Drift/shared prefs/files/logs.
- All temporary artifact cleanup jobs pass.
- All import save flows validate before DB writes.
- All programme/workout save flows are transactional.
- All progress media file operations handle partial failure.
- All schema version tracks are independent.

---

## 5. Seed Backlog Tickets

| Ticket | Title |
|---|---|
| DMP-T01 | Implement Drift base schema, schema meta, and migration harness. |
| DMP-T02 | Implement storage boundary wrappers for Drift, secure storage, shared prefs, and app files. |
| DMP-T03 | Implement exercise library tables and atomic Firebase dataset replacement. |
| DMP-T04 | Implement profile, settings, provider metadata, and secure key aliasing. |
| DMP-T05 | Implement programme/workout template, expansion, and logging tables. |
| DMP-T06 | Implement analytics, PR, e1RM, and plateau tables. |
| DMP-T07 | Implement progress media tables and file lifecycle coordination. |
| DMP-T08 | Implement AI snapshot, validation event, and chat tables. |
| DMP-T09 | Implement share/export DTOs and export event metadata. |
| DMP-T10 | Implement external import draft and exercise matching tables. |
| DMP-T11 | Implement image import artifact metadata and cleanup. |
| DMP-T12 | Implement physique analysis snapshot and consent tables. |
| DMP-T13 | Implement redaction, export sanitizer, and AI payload sanitizer tests. |
| DMP-T14 | Implement full migration and startup cleanup test suite. |

---

## 6. Final Implementation Readiness Checklist

```text
[ ] Drift schema generated and committed
[ ] Migration tests passing
[ ] Database open tested on iOS
[ ] Database open tested on Android
[ ] Secure storage wrapper tested
[ ] Shared preferences boundary tested
[ ] File store paths tested
[ ] Exercise sync transaction tested
[ ] Programme save transaction tested
[ ] Workout completion transaction tested
[ ] Progress media deletion tested
[ ] AI snapshot sanitizer tested
[ ] Export sanitizer tested
[ ] Import validation tested
[ ] Crashlytics redaction tested
[ ] Startup cleanup tested
```
