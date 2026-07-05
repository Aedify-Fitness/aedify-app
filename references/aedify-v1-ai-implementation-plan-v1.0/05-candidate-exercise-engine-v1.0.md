# 05 — Candidate Exercise Engine Plan v1.0


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

This file defines how the app builds candidate exercise lists for AI prompts.

Candidate lists are the primary anti-hallucination control for exercise selection. The AI must choose canonical exercises only from the supplied candidates.

---

## 2. Candidate Engine Inputs

| Input | Source | Used For |
|---|---|---|
| Exercise catalog | Drift, synced from Firebase Storage | Canonical exercises and metadata. |
| User equipment | Profile/settings in Drift | Hard equipment filter. |
| User experience | Profile in Drift | Hard difficulty/complexity filter. |
| User goals | Profile/request | Soft ranking. |
| Session length | Request/profile | Candidate count and movement priority. |
| Training days | Profile/programme config | Programme distribution. |
| Injuries/limitations | Profile | Exclusion/substitution filter. |
| User substitutions/avoid list | Profile | Exclusion filter. |
| Favorites | Profile | Soft boost where appropriate. |
| Recent logs | Lift log | Strength anchors, fatigue, movement recency. |
| Active programme | Programmes module | Context-aware swaps or session generation. |
| Import exercise names | Import extraction | Match-assist candidate generation. |

---

## 3. Hard Filters

Hard filters remove exercises before ranking.

| Filter | Rule |
|---|---|
| Equipment | Exercise equipment must be available to user/request, except bodyweight where generally available. |
| Experience | Exercise difficulty must be compatible with user level and operation rules. |
| Injury/limitation | Exclude movements loading restricted area unless explicitly allowed. |
| Avoid/substitution list | Exclude user-marked exercises unless user explicitly overrides. |
| Modality | Strength generation should mostly use strength modality; conditioning/mobility only when requested/appropriate. |
| Canonical dataset status | Exclude deprecated/unavailable exercises. |
| Operation constraints | Beginner AI outputs exclude supersets and advanced elements; import match may include broader candidates for resolution. |

---

## 4. Experience Compatibility

Suggested compatibility policy:

| User Experience | Allowed Exercise Difficulties by Default |
|---|---|
| novice / brand-new | novice, selected beginner only when safe and equipment-appropriate. |
| beginner | novice, beginner, selected intermediate if safe and common. |
| intermediate | novice, beginner, intermediate, selected advanced if appropriate. |
| advanced | all difficulties, still filtered by equipment/injury. |

Final rules should match the local product taxonomy and PRD terms. The engine should store the reason an exercise was excluded when needed for debugging or user explanation.

---

## 5. Soft Ranking Signals

Soft ranking orders candidates after hard filtering.

| Signal | Example |
|---|---|
| Goal match | Build Strength boosts compounds; Build Muscle boosts hypertrophy accessories after compounds. |
| Muscle group priority | Chest day boosts chest/triceps/shoulders. |
| Movement pattern balance | Push/pull/squat/hinge/core distribution. |
| Recent log continuity | Prefer exercises user has logged recently when progression is useful. |
| Favorite exercise | Boost if goal-compatible. |
| Substitution adjacency | For swap, rank close alternatives to original movement. |
| Fatigue management | Avoid too many high-fatigue compounds in one session. |
| Equipment simplicity | For beginners, prefer simpler setup. |
| Exercise metadata completeness | Prefer exercises with clear instructions/videos. |
| Import name similarity | For import matching, rank normalized string/alias/fuzzy metadata matches. |

---

## 6. Candidate Payload Shape

Prompt payload should be compact but rich enough to prevent hallucination.

```text
CandidateExerciseDto
  id: source exercise id or local custom id namespace
  name: string
  difficulty: novice | beginner | intermediate | advanced
  muscle_groups: string[]
  primary_muscles: string[] optional
  modality: strength | flexibility | cardio | recovery
  equipment: string?  // null for non-strength where appropriate
  mechanic: Compound | Isolation | null
  force: Push | Pull | Hold | null
  grips: string[] optional
  substitution_tags: string[] optional
  recent_working_weight: string? optional
  favorite: bool optional
  notes_for_ai: string? optional, sanitized
```

Do not include:

- full exercise instructions unless needed;
- video URLs unless needed;
- Firebase URLs when not needed;
- local DB IDs where source ID is enough;
- user logs unrelated to exercise selection;
- internal ranking scores unless useful and safe.

---

## 7. Candidate List Types

| Type | Used By | Candidate Strategy |
|---|---|---|
| `daily_workout_candidates` | Daily generation | Balanced list by requested focus, session length, equipment, experience. |
| `programme_candidates` | Multi-week programmes | Wider list across required movement patterns and muscle groups. |
| `beginner_filtered` | Beginner Path A/B | Conservative beginner-safe candidates, strict wiki rules, no advanced elements. |
| `swap_candidates` | Exercise swap | Close alternatives by movement, muscles, equipment, fatigue profile. |
| `deload_candidates` | Deload | Usually same exercises; alternatives only if deload requires substitution. |
| `plateau_candidates` | Plateau suggestion | Original lift + accessories/variations that address likely bottleneck. |
| `import_match_candidates` | External import match assist | Name/alias/fuzzy candidates for imported exercise names. |
| `chat_context_candidates` | Chat when user asks exercise-specific action | Small operation-specific set only. |

---

## 8. Candidate Count Caps

Candidate lists must be capped to control BYOK cost and reduce hallucination.

Suggested default caps:

| Operation | Default Cap | Notes |
|---|---:|---|
| Daily workout | 40–80 | Depends on focus breadth. |
| Multi-week programme | 100–160 | Needs enough coverage for weekly templates. |
| Beginner Path A | 40–80 | Conservative, routine-specific. |
| Beginner Path B | 60–100 | Still beginner-safe. |
| Swap | 8–20 per exercise | Better to be focused. |
| Plateau suggestion | 20–50 | Include primary lift context and relevant variations. |
| Import exercise match | 5–12 per source exercise | Keep per-name options concise. |
| Chat | 0–30 | Only include if chat task requires it. |

If cap truncates results, rank by hard suitability first, then goal match.

---

## 9. Strength + Hypertrophy Candidate Routing

For eligible non-beginner strength + hypertrophy requests:

- include primary compound options for main patterns;
- include secondary compounds that support primaries;
- include tertiary accessories for hypertrophy and weak points;
- include enough alternatives for fatigue management;
- include recent working weights where available;
- include exercise role hints only if deterministic locally;
- avoid source programme reconstruction.

For beginners:

- do not include powerbuilding metadata;
- do not encourage heavy singles, frequent variation, aggressive volume, or advanced intensity techniques;
- do not prescribe supersets in AI-generated beginner outputs.

---

## 10. Import Exercise Matching

Import match candidates use a different strategy from generation candidates.

Local matching pipeline:

1. Normalize source exercise name.
2. Check exact normalized match.
3. Check alias table.
4. Check known common synonyms.
5. Fuzzy match by name.
6. Re-rank by source context: equipment, muscles, movement, programme day.
7. Mark high-confidence exact/alias matches.
8. Mark ambiguous matches for user confirmation.
9. Send top ambiguous groups to AI match assist only if needed.
10. Never auto-create custom exercises without user confirmation.

AI match assist may suggest likely matches, but user confirms ambiguous matches.

---

## 11. Candidate Validation Against Output

After AI returns output:

- every canonical exercise ID must exist in the candidate list for that operation;
- custom exercises are only allowed in import/custom draft contexts;
- exercise names must match candidate ID or be treated as display labels only;
- exercise IDs must not be local DB primary keys unless the DTO deliberately uses custom namespaced IDs;
- removed/unmatched import exercises must be explicitly marked;
- output cannot introduce a hidden exercise not shown in candidates.

---

## 12. Debugging and Explainability

Candidate engine should support local debug summaries:

```text
CandidateBuildSummary
  operation_id
  total_exercises_available
  excluded_by_equipment_count
  excluded_by_experience_count
  excluded_by_injury_count
  excluded_by_substitution_count
  ranked_count
  sent_count
  cap_applied: bool
```

This summary is local diagnostic data. Do not send full candidate list to Crashlytics.

---

## 13. Acceptance Gate

Candidate engine is accepted when:

- hard filters are deterministic;
- equipment + experience filters are tested;
- injury/substitution exclusions are tested;
- beginner candidates exclude advanced/powerbuilding-inappropriate choices;
- generation outputs cannot reference exercises outside candidate list;
- import match outputs cannot auto-save ambiguous matches;
- candidate payloads do not include sensitive private data;
- cap behavior is tested and deterministic;
- candidate list never goes to Crashlytics.
