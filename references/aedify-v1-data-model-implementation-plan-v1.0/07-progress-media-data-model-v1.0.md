# 07 — Progress Media Tracking Data Model v1.0

## 1. Purpose

This file defines the data model for progress photos, progress videos, thumbnails, extracted frames, reminder settings, timeline views, comparison behavior, storage usage, and deletion rules.

Progress media is milestone M6 and comes before AI Infrastructure in the current roadmap.

---

## 2. Storage Split

| Item | Storage |
|---|---|
| Session metadata | Drift |
| Media item metadata | Drift |
| Photos/videos/thumbnails/frames | App sandbox files |
| Reminder cadence | Drift |
| Notification scheduling state | Drift + platform notification APIs |
| AI analysis snapshots | Separate physique analysis tables in M13 |

Media bytes must not be stored as database blobs.

---

## 3. `progress_media_sessions`

```text
progress_media_sessions
  id text primary key
  captured_at datetime not null
  media_type text not null                  // photo_set | video | both
  is_baseline bool not null default false
  is_complete_pose_set bool not null default false

  bodyweight_kg real nullable
  body_measurement_snapshot_id text nullable
  notes text nullable

  reminder_cadence_at_capture text nullable // two_weeks | monthly | three_months | off
  storage_size_bytes int nullable
  created_at datetime not null
  updated_at datetime not null
  deleted_at datetime nullable
```

### 3.1 Baseline Rule

The first saved progress media session should be marked baseline by default unless the user changes it later.

Only one active baseline should exist unless the UI explicitly supports multiple baseline types.

---

## 4. `progress_media_items`

```text
progress_media_items
  id text primary key
  session_id text not null
  type text not null                        // photo | video | video_frame | thumbnail
  pose text not null                        // front | back | left_side | right_side | all_sides_video | unknown

  local_relative_path text not null
  thumbnail_relative_path text nullable
  source text not null                      // camera | gallery | extracted_frame | generated_thumbnail

  duration_seconds int nullable
  width int nullable
  height int nullable
  file_size_bytes int nullable
  content_hash text nullable

  source_media_item_id text nullable         // frame/thumbnail parent
  captured_at datetime nullable
  created_at datetime not null
  deleted_at datetime nullable
```

### 4.1 Pose Completeness

A session is complete when it has at least one active photo for:

```text
front
back
left_side
right_side
```

Partial sessions may be saved and marked incomplete.

---

## 5. Reminder Settings

```text
progress_media_reminder_settings
  id text primary key default 'default'
  enabled bool not null default false
  cadence text nullable                    // two_weeks | monthly | three_months
  last_session_at datetime nullable
  next_reminder_at datetime nullable
  last_prompted_at datetime nullable
  created_at datetime not null
  updated_at datetime not null
```

Rules:

```text
No reminder before first saved progress media session.
After first session, ask user for cadence.
If user records a new session before reminder date, reset next reminder from new session date.
Notifications are local only.
```

---

## 6. File Paths

Recommended:

```text
media/progress/sessions/{session_id}/originals/{media_item_id}.jpg
media/progress/sessions/{session_id}/originals/{media_item_id}.mp4
media/progress/sessions/{session_id}/thumbnails/{media_item_id}.jpg
media/progress/sessions/{session_id}/frames/{frame_item_id}.jpg
```

File names should use UUIDs, not user names or descriptive body terms beyond pose metadata in Drift.

---

## 7. Video Handling

For video progress media:

- v1 recommended max duration: 30–60 seconds.
- Store duration and file size.
- Generate thumbnail.
- Do not extract AI frames unless user starts AI analysis or comparison requires it.
- Extracted frames should reference the parent video item.
- If the parent video is deleted, frames and thumbnails are deleted too.

---

## 8. Comparison Queries

Comparison UI needs:

```text
sessions by captured_at desc
session media grouped by pose
baseline session
latest session
same-pose pairs across two sessions
video thumbnail and playback refs
```

Recommended DAO methods:

```text
watchProgressTimeline()
getProgressSessionDetails(sessionId)
getBaselineSession()
getLatestSession()
getComparablePosePairs(sessionA, sessionB)
getStorageUsageSummary()
```

---

## 9. Delete Behavior

User can delete:

1. individual media item;
2. full progress session;
3. all progress media.

Deletion must:

```text
delete or mark DB rows
delete original file
delete thumbnail file
delete extracted frames
delete linked frame metadata
handle orphaned analysis snapshots according to M13 rules
```

Use file cleanup recovery on app startup.

---

## 10. Privacy Rules

Progress media:

- stays local by default;
- is not in Crashlytics;
- is not in `.aedifyplan`;
- is not in PDF export;
- is not included in external imports;
- is sent to BYOK AI only after explicit AI analysis consent;
- should not be included in app diagnostics beyond aggregate storage size.

---

## 11. Acceptance Tests

M6 cannot close until:

- Capture/import creates session + media item metadata.
- Four-pose session is marked complete.
- Partial session can save as incomplete.
- First session can become baseline.
- User can change baseline.
- Thumbnails are generated and linked.
- Deleting a media item removes the file.
- Deleting a session removes all child files.
- Reminder is not scheduled before first session.
- Reminder cadence can be changed/disabled.
- Crashlytics contains no paths or media metadata beyond redacted error code.
