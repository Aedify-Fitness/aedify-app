# M1–M4 gap closure

Date: 2026-10-25. Status: identified implementation gaps fixed; deterministic/native acceptance passed; live-service acceptance pending.

This pass addresses the gaps found after M4 closure. M5 remains planned and has not been started. No database schema, dependency or locked product-scope changes were required.

## Implementation

- M1: global Flutter/platform errors now use `CrashlyticsService` redaction instead of calling Firebase directly. Crash collection honors the feature flag. Unexpected startup errors use a safe recoverable message. Secure key rotation overwrites the existing value without deleting it first. Google API-key headers and query-key values are redacted. Disposed network monitors do not emit into closed streams.
- M2: failed first syncs cannot become a successful offline library merely because a metadata row exists. Dismissing failure cannot manufacture an imported dataset. Refresh rechecks connectivity instead of trusting a stale offline state. Schema compatibility is checked before the unchanged-version shortcut. Unexpected sync failures no longer persist arbitrary exception text.
- M3: connection tests use provider-specific metadata endpoints, authentication and bounded requests without sending user content or following redirects. Selected-model access is checked against a conservative capability registry; unknown models remain disabled. Anthropic IDs now match the displayed models, and Haiku/Opus/Gemini Flash price estimates were corrected.
- M3: saving or replacing a key populates the capability cache and validation metadata. Config/capability/activation writes are transactional; failed metadata writes compensate the secure-store change. Invalid replacements preserve the previous key. Stale responses cannot recreate deleted configurations or invalidate a newly rotated key.
- M3: saved providers have Edit and Provider Capability controls. Editing reuses the secure key when no replacement is entered. The capability screen has a named route, real Retry and Refresh controls. Refresh retains cached metadata on transport failure and clears invalid access safely.
- M3: onboarding profile/strength-anchor/completion writes are transactional. Training changes report their impact on an active programme. Profile editing retains the actual training days; identity/unit-only edits do not trigger a programme warning.
- M4: the existing runner/history/correction implementation is retained. Prior implementation and process-recovery evidence is in [m4-closure.md](m4-closure.md).

## Verification boundaries

The user confirmed Firebase is currently down and no provider test keys are configured. Initial native live-sync attempts reached manifest access and failed; those results are not a passing live acceptance check. No Firebase rules, remote dataset, production data or real provider key was changed.

`integration_test/m1_m3_acceptance_test.dart` uses real native secure storage, preferences, filesystem, SQLite, onboarding UI, provider repositories and capability gates. Its M2 test replaces only Firebase transport with a synthetic manifest/dataset; checksum validation, parsing, import, unchanged-manifest handling, disk reopening, offline search/filter/detail and the exercise detail screen remain real.

`integration_test/m3_byok_ui_acceptance_test.dart` uses production BYOK/capability screens and native storage with synthetic provider metadata transport. It exercises key save, existing-model edit without key re-entry, named capability navigation, refresh and deletion in light/dark themes. Synthetic keys are cleaned up. Physical phones and existing app databases are not used.

`integration_test/m2_live_firebase_acceptance_test.dart` remains a separate, strict live Firebase check. It is not skipped or weakened to make the offline suite green. Run it on both simulators when Firebase is restored:

```sh
flutter test integration_test/m2_live_firebase_acceptance_test.dart -d DEVICE_ID --no-uninstall
```

Live successful BYOK authentication still needs a user-owned test key. Synthetic transport acceptance does not establish that a provider currently grants a real account access to the selected model.

## Results

- `dart format .`: 791 Dart files checked after the final code/test changes.
- `flutter analyze`: no issues.
- Full `flutter test`: **1,630 passed, zero failures or skips**. This adds 34 regressions over the previous 1,596-test baseline.
- Native M1/M3 storage, preferences, filesystem, onboarding without AI, synthetic BYOK save/rotation/rejection/delete and persisted profile: **passed on iOS and Android**.
- Native M2 fixture-based checksum/download/import, unchanged-version no rewrite/redownload, database reopen, offline modality filters/search/detail and detail-screen render: **passed on iOS and Android**.
- Native BYOK UI save, stored-key model edit, named capability navigation, real refresh and delete in light/dark themes: **passed on iOS and Android**.
- M4 native offline regression (standalone logging, disk recovery, completion, correction and repeat): **passed on iOS and Android**. Normal `lib/main.dart` entrypoints restored and launched successfully on both platforms.
- Live Firebase first-sync acceptance: **not passed** during the confirmed outage. Live successful BYOK authentication: **not run**, no real test keys configured.

The native fixture tests do not contact Firebase or AI services. Initial live attempts were kept as failed external checks; no existing regression was deleted or skipped. The earlier OS-process termination/recovery evidence in `m4-closure.md` still applies; no schema/native dependency change was made in this pass.

Local reproduction logs are outside versioned source: `/private/tmp/aedify-m1-m4-full-suite.json`, `/private/tmp/aedify-m1-m4-analyze.log`, `/private/tmp/aedify-m1-m3-{ios,android}-offline.log`, `/private/tmp/aedify-m3-ui-{ios,android}.log` and `/private/tmp/aedify-m1-m4-{ios,android}-regression.log`.

## Reproduction

```sh
dart format .
flutter analyze
flutter test
flutter test integration_test/m1_m3_acceptance_test.dart -d DEVICE_ID --no-uninstall
flutter test integration_test/m3_byok_ui_acceptance_test.dart -d DEVICE_ID --no-uninstall
flutter test integration_test/m4_offline_smoke_test.dart -d DEVICE_ID --no-uninstall
```

Both native targets were simulators/emulators: iPhone 18 Pro / iOS 27 and Android API 36 (`emulator-5554`). Restore the ordinary app after integration runs with `flutter run --debug --no-resident -t lib/main.dart -d DEVICE_ID`. No physical phone was used. Restoration logs are `/private/tmp/aedify-m1-m4-{ios,android}-restore.log`.

## Provider contract sources

The registry describes the picker models, not a recommendation to switch providers or models. Authenticated model metadata checks availability; documented model capabilities provide conservative operation gates. Provider-reported unsupported image/schema capabilities override registry defaults. No generation prompts or media are sent by connection/capability checks.

- [Anthropic model metadata](https://platform.claude.com/docs/en/api/models/retrieve), [Haiku 4.5 IDs/pricing](https://platform.claude.com/docs/en/models/haiku-4-5/overview), [Opus 4.7](https://www.anthropic.com/research/claude-opus-4-7).
- [Gemini model metadata](https://ai.google.dev/api/models), [authentication](https://ai.google.dev/gemini-api/docs/api-key), [pricing](https://ai.google.dev/gemini-api/docs/pricing).
- [OpenAI GPT-4o](https://developers.openai.com/api/docs/models/gpt-4o), [o1](https://developers.openai.com/api/docs/models/o1), [o1-mini](https://developers.openai.com/api/docs/models/o1-mini).

## Changed files

```text
docs/changelog.md
docs/implementation.md
docs/m1-m4-gap-closure.md
integration_test/m1_m3_acceptance_test.dart
integration_test/m2_live_firebase_acceptance_test.dart
integration_test/m3_byok_ui_acceptance_test.dart
lib/app/bootstrap/controllers/bootstrap_controller.dart
lib/app/providers/providers.dart
lib/app/router/app_router.dart
lib/core/firebase/firebase_bootstrap.dart
lib/core/firebase/firebase_error_handlers.dart
lib/core/network/network_status.dart
lib/core/privacy/redaction.dart
lib/core/storage/secure_storage_service.dart
lib/features/exercise_library/application/exercise_dataset_sync_controller.dart
lib/features/onboarding/data/drift_onboarding_repository.dart
lib/features/profile/application/profile_controller.dart
lib/features/profile/data/drift_profile_repository.dart
lib/features/settings/application/byok_setup_controller.dart
lib/features/settings/application/provider_capability_controller.dart
lib/features/settings/data/default_provider_gate_service.dart
lib/features/settings/data/drift_byok_repository.dart
lib/features/settings/data/provider_capability_refresh_service.dart
lib/features/settings/data/provider_key_validator.dart
lib/features/settings/domain/provider_model_capabilities.dart
lib/features/settings/presentation/byok_settings_screen.dart
lib/features/settings/presentation/provider_capability_screen.dart
lib/shared/constants/app_error_codes.dart
lib/shared/constants/app_error_strings.dart
lib/shared/constants/app_routes.dart
lib/shared/constants/app_strings.dart
test/core/firebase/firebase_error_handlers_test.dart
test/core/privacy/redaction_test.dart
test/core/storage/secure_storage_service_test.dart
test/features/exercise_library/application/exercise_dataset_sync_controller_test.dart
test/features/onboarding/data/drift_onboarding_repository_test.dart
test/features/profile/data/drift_profile_repository_test.dart
test/features/settings/application/byok_setup_controller_test.dart
test/features/settings/application/provider_capability_controller_test.dart
test/features/settings/data/byok_real_storage_acceptance_test.dart
test/features/settings/data/drift_byok_repository_test.dart
test/features/settings/data/fake_dependencies.dart
test/features/settings/data/provider_key_validator_test.dart
test/features/settings/presentation/byok_settings_screen_test.dart
test/support/exercise_library/native_dataset_fixture.dart
test/support/settings/provider_metadata_adapter.dart
```
