# Package Validation Decision Log
## Aedify — v1 Final PRD Relock

| Area | Original Candidate | Final Decision | Status | Rationale | Boundary |
|---|---|---|---|---|---|
| State management | Riverpod 2.x | Riverpod, latest validated stable version | Accepted | Chosen over Provider because the app has app-wide async workflows, AI/import lifecycles, local DB streams, provider capability checks, and feature-level controllers that benefit from provider-based dependency injection and testing without tying business logic to `BuildContext`. | Provider remains valid, but is not selected for v1. |
| Local relational DB | Drift / SQLite | Drift / SQLite | Accepted | Durable app data is relational: exercises, programmes, templates, set prescriptions, set logs, imports, progress media sessions, share/import metadata, and schema versions. | Drift owns durable structured app data and migrations. |
| Local KV | Hive | `shared_preferences` | Replaced | v1 only needs simple non-critical local preferences outside Drift and secure storage. Hive is unnecessary as a required core dependency. | `shared_preferences` must not store secrets, logs, programmes, import drafts, AI outputs, progress media records, or other critical data. |
| Secure secrets | `flutter_secure_storage` | `flutter_secure_storage` | Accepted | BYOK API keys and sensitive values require platform-secure storage. | Secrets only; never write API keys to Drift, shared preferences, files, logs, Crashlytics, or exports. |
| HTTP | Dio + Retrofit | Dio + Retrofit | Accepted | Dio provides the required HTTP engine capabilities; Retrofit is useful for stable typed REST clients. | Use hand-written Dio adapters for complex AI provider payloads, streaming, or multipart cases. |

## Relock Statement

The v1 PRD was temporarily unlocked only for package validation. No product scope changed. The final implementation stack correction is now re-locked into the v1 PRD baseline.
