# 11 — Image/Screenshot Import Data Model v1.0

## 1. Purpose

This file defines the additional data model for AI-assisted import from screenshots/images. Image import extends the external import draft model and adds image ordering, readability metadata, temporary artifact tracking, provider capability gating, and cleanup rules.

Image import is M12 in the current roadmap.

---

## 2. Source Input Type

Image import uses:

```text
import_drafts.source_input_type = image_screenshot
```

It reuses the same final draft schemas as external text import:

```text
external_program_import_json
external_workout_import_json
external_exercise_match_json
```

---

## 3. Image-Specific Fields on `import_drafts`

Add nullable columns or store inside `image_import_metadata_json`.

Recommended first-class fields:

```text
import_drafts
  source_file_types_json text nullable       // ["png", "jpg"]
  image_count int nullable
  image_order_source text nullable           // user_defined | file_picker_order
  image_quality_summary text nullable        // good | mixed | poor | unreadable
  enhancement_applied bool nullable
  enhancement_methods_json text nullable
  unreadable_regions_json text nullable
  missing_or_unclear_content_json text nullable
  provider_image_capability_status text nullable // supported | unsupported | unknown
```

---

## 4. `image_import_artifacts`

```text
image_import_artifacts
  id text primary key
  import_draft_id text not null

  artifact_type text not null                // original | enhanced | thumbnail
  user_order_index int not null
  original_file_name text nullable
  file_type text not null                    // png | jpg | jpeg | webp | heic | heif

  local_relative_path text not null
  width int nullable
  height int nullable
  file_size_bytes int nullable
  content_hash text nullable

  quality_score real nullable
  quality_label text nullable                // good | acceptable | poor | unreadable
  enhancement_methods_json text nullable
  unreadable_regions_json text nullable

  sent_to_ai bool not null default false
  created_at datetime not null
  expires_at datetime nullable
  deleted_at datetime nullable
```

Artifacts are temporary. They are not progress media.

---

## 5. Enhancement Method Vocabulary

Allowed values:

```text
orientation_correction
rotation
crop_empty_borders
deskew
brightness_contrast
sharpening
noise_reduction
upscaling
format_conversion
```

Enhancement must be readability-only and must not alter programme content.

---

## 6. Provider Capability Gating

Before prompt assembly:

```text
load active provider config
check supports_image_input
check model image count/size limits if available
if unsupported:
  block flow
  show clear fallback message
  do not assemble prompt
  do not send images
```

Do not rely on AI to reject unsupported image mode after upload.

---

## 7. Image Import Package

May include after explicit consent:

```text
selected original images
enhanced images where needed
image order metadata
quality metadata
enhancement methods applied
import instructions
schema
```

Must not include:

```text
API keys
lift logs
injuries
body measurements
chat history
full user profile
progress media unrelated to import
unrelated private app data
```

---

## 8. Cleanup Rules

Delete image import artifacts when:

```text
user cancels import
draft is saved
draft expires
import fails and user discards
startup cleanup finds expired temp artifacts
```

If user leaves and later resumes import, artifacts may persist until `expires_at`.

Recommended expiry:

```text
24-72 hours for unfinished image import drafts
immediate cleanup after successful save
```

---

## 9. User Ordering

For multi-image imports:

```text
user_order_index determines prompt/source order
user-defined order becomes source order
AI must preserve the visible source order
```

If user changes order, update `image_import_artifacts.user_order_index`.

---

## 10. Quality and Unreadable Regions

Store AI- and app-facing metadata:

```json
{
  "overall": "mixed",
  "images": [
    {
      "artifact_id": "uuid",
      "quality": "poor",
      "issues": ["blur", "cropped_right_edge"],
      "unreadable_regions": [
        {"label": "week 3 row", "reason": "cropped"}
      ]
    }
  ]
}
```

This metadata lets the app warn the user and prevents the AI from being asked to invent missing content.

---

## 11. Save Flow

Image import ultimately follows external import save flow:

```text
image artifacts selected and ordered
provider image support checked
quality assessed/enhanced
consent shown
AI returns structured draft
schema validation and repair
exercise matching
user review
save inactive programme/workout
delete temporary artifacts
```

---

## 12. Acceptance Tests

M12 cannot close until:

- PNG/JPG/WEBP and supported HEIC/HEIF are accepted.
- Unsupported image type is rejected.
- Multi-image reorder updates source order.
- Unsupported image-capable provider blocks before prompt assembly.
- Enhancement metadata is stored.
- AI prompt package excludes forbidden private data.
- Unreadable/cropped regions appear in review.
- Save deletes temporary original/enhanced artifacts.
- Cancel deletes or expires temporary artifacts.
- `.aedifyplan` and PDF exports never include original/enhanced screenshots.
