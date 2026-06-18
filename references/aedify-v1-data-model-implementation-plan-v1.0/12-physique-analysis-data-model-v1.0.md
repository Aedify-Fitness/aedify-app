# 12 — AI Physique Analysis Data Model v1.0

## 1. Purpose

This file defines the local data model for optional AI physique analysis on selected progress media. This feature is M13 and depends on both Progress Media Tracking (M6) and AI Infrastructure (M7).

AI physique analysis is explicit-consent only and returns rough, range-based, training-oriented feedback.

---

## 2. `progress_physique_analysis_snapshots`

```text
progress_physique_analysis_snapshots
  id text primary key
  session_id text not null
  comparison_session_id text nullable

  analysis_mode text not null              // single_session | baseline_compare | previous_compare | custom_compare
  analysis_schema_version int not null
  ai_generation_snapshot_id text nullable

  provider_name text nullable
  model_name text nullable

  estimated_body_fat_min_percent real nullable
  estimated_body_fat_max_percent real nullable
  confidence text not null                 // low | medium | high

  overall_summary text not null
  visual_observations_json text not null default '{}'
  muscularity_by_region_json text not null default '{}'
  symmetry_assessment text nullable
  conditioning_assessment text nullable

  strengths_json text not null default '[]'
  lagging_areas_json text not null default '[]'
  progress_vs_baseline text nullable
  progress_vs_last_check_in text nullable
  recommended_focus_areas_json text not null default '[]'

  disclaimer text not null
  consent_id text nullable

  created_at datetime not null
  deleted_at datetime nullable
```

### 2.1 Body-Fat Range Rule

Store:

```text
estimated_body_fat_min_percent
estimated_body_fat_max_percent
confidence
```

Do not store or display a single precise body-fat number.

---

## 3. Media References

Optional table:

```text
physique_analysis_media_refs
  id text primary key
  analysis_snapshot_id text not null
  progress_media_item_id text not null
  role text not null                    // source_photo | extracted_frame | comparison_photo
  pose text nullable
  created_at datetime not null
```

This allows an analysis result to identify which local media items were used without embedding media bytes.

---

## 4. Consent Records

```text
ai_media_processing_consents
  id text primary key
  operation_category text not null       // progress_physique_analysis | image_import
  provider_name text nullable
  model_name text nullable
  consent_text_version text not null
  user_consented_at datetime not null
  media_item_ids_json text nullable
  import_draft_id text nullable
  session_id text nullable
```

Consent records are local-only.

---

## 5. Video Frame Handling

For progress video analysis:

```text
prefer local representative frame extraction
store extracted frames as progress_media_items(type = video_frame)
link frames to parent video via source_media_item_id
send selected frames to AI after consent
avoid sending full raw video by default
```

If canonical frames cannot be detected:

```text
ask user to select representative frames
or ask for explicit confirmation before sending a short clipped segment
```

---

## 6. Deletion Behavior

When media is deleted:

Option A — delete linked analyses:

```text
delete analysis snapshots that depended on deleted media
```

Option B — mark analysis as orphaned/unviewable:

```text
analysis remains but UI states source media deleted
```

Recommendation for v1: delete linked analyses when the user deletes the full session; ask confirmation if deleting individual media that analysis depends on.

---

## 7. Safety/Privacy Exclusions

Analysis must not include:

```text
medical diagnosis
precise body composition claim
attractiveness score
body shaming
extreme dieting advice
form checking
clinical injury advice
```

Analysis snapshots are excluded from:

```text
Crashlytics
.aedifyplan
PDF exports
external imports
image import prompts
default data-sharing flows
```

---

## 8. Acceptance Tests

M13 cannot close until:

- User must explicitly consent before analysis.
- Provider/model must support image input.
- Video analysis uses extracted frames by default.
- AI output validates against `progress_physique_analysis_json`.
- Body-fat estimate stores and displays a range.
- Analysis snapshot stores locally only.
- Deleting media removes or invalidates linked analyses.
- Crashlytics contains no analysis result, media path, prompt, or response.
- Export filters exclude analysis snapshots.
