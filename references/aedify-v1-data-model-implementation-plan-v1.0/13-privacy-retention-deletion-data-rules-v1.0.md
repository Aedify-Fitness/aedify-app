# 13 — Privacy, Retention, Deletion, and Redaction Data Rules v1.0

## 1. Purpose

This file defines cross-domain privacy rules for local data, AI payloads, Crashlytics, exports, deletion, cleanup, and retention. These rules apply across all milestones.

---

## 2. Deny-by-Default Policy

For any new field, assume it is forbidden from:

```text
Crashlytics
exports
AI prompts
logs
debug traces
temporary files
```

Then explicitly allow it only where required.

---

## 3. Crashlytics Redaction Service

Implement a single redaction utility used by all error reporting.

Required API shape:

```text
RedactedErrorContext buildCrashContext({
  required String operation,
  required String errorCode,
  String? screenName,
  Map<String, Object?> nonSensitiveMetadata = const {},
})
```

The utility must drop or replace:

```text
API-like strings
file paths
prompt-looking strings
JSON payloads
free-form notes
body measurements
exercise logs
chat messages
media paths
source excerpts
```

---

## 4. Export Filtering

Before generating `.aedifyplan` or PDF, run through an export sanitizer.

Forbidden export classes:

```text
profile
injuries
body measurements
progress media
AI physique analysis
logs
PRs
plateau flags
API keys
chat history
AI prompts
AI responses
candidate lists
AI snapshots
source file excerpts
original screenshots
enhanced screenshots
temporary artifacts
absolute local paths
```

---

## 5. AI Payload Filtering

Every AI operation has an allowlist.

### 5.1 Programme/Workout Generation

May include:

```text
profile summary
goals
equipment
experience
schedule
recent log summary
working weights
candidate exercises
selected reference files
structured schema
```

Must exclude:

```text
API keys
full DB
progress media
unrelated import artifacts
Crashlytics metadata
```

### 5.2 External Text Import Parse

May include:

```text
file type
extracted programme-relevant content
schema
```

Must exclude:

```text
profile
logs
injuries
measurements
chat history
progress media
```

### 5.3 Image Import Parse

May include:

```text
selected/enhanced images
image order metadata
image quality metadata
import instructions
schema
```

Must exclude:

```text
full profile
logs
injuries
measurements
chat history
progress media unrelated to import
```

### 5.4 Progress Physique Analysis

May include:

```text
selected media or extracted frames
minimal comparison metadata
```

Must exclude:

```text
logs
programmes
API keys
unrelated profile data
external import source data
```

---

## 6. Deletion Rules

| User Action | Required Data Impact |
|---|---|
| Delete workout session | Delete session exercises and set logs; recalc PRs/analytics. |
| Archive programme | Hide programme; preserve completed logs. |
| Delete programme | Soft delete if logs reference it; preserve logs. |
| Delete saved workout | Archive/soft delete; preserve sessions already completed. |
| Delete custom exercise | Soft delete if referenced by logs/plans; hard delete if unused. |
| Delete progress media item | Delete file, thumbnail, frame refs, DB row; handle analysis dependency. |
| Delete progress media session | Delete all media files, rows, linked frames, linked analyses or mark orphaned. |
| Delete import draft | Delete draft rows and temp artifacts. |
| Delete chat thread | Delete or soft-delete local chat messages; unlink snapshots where needed. |
| Delete provider config | Delete secure key and metadata; preserve generated content but remove provider secret. |
| Clear export temp files | Delete files only; keep export event metadata if used. |

---

## 7. Retention Rules

| Data | Default Retention |
|---|---|
| Exercise dataset | Until replaced by newer compatible dataset. |
| Custom exercises | Until user deletes; soft delete if referenced. |
| Programmes/workouts/logs | Until user deletes/archives. |
| Analytics cache | Rebuildable; may be purged. |
| Progress media | Until user deletes. |
| Progress thumbnails/frames | Until parent media deleted or cache purged if regenerable. |
| AI chats | Until user deletes. |
| AI snapshots | Until parent deleted or privacy cleanup. |
| External import drafts | Until saved/cancelled/expired. |
| Image import artifacts | Temporary; delete after save/cancel/expiry. |
| Export temp files | Temporary; delete after share/startup cleanup. |
| API keys | Until user deletes provider config or clears key. |

---

## 8. Startup Cleanup Jobs

Run safe cleanup on app startup:

```text
delete expired import temp files
delete expired image import artifacts
delete stale export temp files
delete orphan thumbnails without media item
detect media DB rows whose files are missing and mark unavailable
detect files without DB refs and queue deletion
compact analytics cache if needed
```

Cleanup must be conservative: never delete user progress media unless there is a clear DB-backed reason or user action.

---

## 9. Privacy Acceptance Gate

M14 cannot close until:

- Crashlytics allowlist tests pass.
- Export sanitizer tests pass.
- AI payload sanitizer tests pass.
- API key storage tests pass.
- Deletion tests pass for every file-backed domain.
- Startup cleanup handles orphan temp artifacts.
- No raw prompts/responses are persisted.
- No local absolute paths appear in exports.
- No progress media appears in exports or Crashlytics.
