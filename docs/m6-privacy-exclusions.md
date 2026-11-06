# M6 privacy exclusions — V1-M6-007

Date: 2026-11-06. Ticket 006 was approved in conversation. This ticket covers the current progress-media privacy boundaries and the shared diagnostic gaps exposed by synthetic sentinels. Ticket 008 acceptance smoke remains separate and requires the next user review.

## Implemented

- Added a synthetic sentinel gate for media names, notes, paths, thumbnails, extracted frames, analysis results, raw byte lists, UTF-8 and base64 representations. Captured output includes logger messages/names/errors/stacks and Crashlytics logs/custom keys/errors/reasons/stacks.
- Closed reproduced leaks through HTTP request paths, arbitrary stack text, private metadata key names, and maps/byte arrays supplied under diagnostic allowlisted keys. HTTP events now use fixed identifiers and never inspect URLs, headers, query values or bodies for diagnostics. Real request/response processing is preserved.
- Unified logger/Crashlytics metadata filtering. Unknown keys and values are replaced; allowlisted fields accept scalar diagnostic metadata only. Stack text, including caller-supplied `redacted_stack_trace` metadata, is fully replaced. Safe error types and codes remain available. This deliberately reduces stack-level diagnostic detail until a separately verified frame sanitizer exists.
- Fully redacted file paths, including basenames. Recognized snake/camel-case media field families as local media; unrecognized fields now default to local personal data instead of public content. Public/reference and exportable plan content must be classified explicitly by its owner.
- Exercised the existing schema-v20 repository and file store with photo/video/thumbnail/frame registrations, private notes and a measurement snapshot: save, timeline, baseline, comparison, note updates, SQL failure, missing-file recovery and deletion. Verified locally readable bytes, safe recoverable failures, no leaked identifiers/paths and zero Dart HTTP client creation attempts.

No schema, dependency, native setup, UI, consent behavior or persistence ownership changed. Fixtures use UUID-owned sandbox paths required by the existing storage policy; original-name sentinels are injected into diagnostic/HTTP inputs separately. Synthetic file contents test storage/privacy boundaries and are not claimed to be decodable media.

## Verification and limits

Final gate: `dart format .` checked 896 files; `flutter analyze` found no issues; `flutter test --concurrency=2 --reporter expanded` passed **1,984/1,984 tests** in 5m29s, zero failures/skips. The 14 new privacy cases all passed in this run. An earlier focused privacy/network/diagnostic/M4/M5 run passed 99/99 before the final safe-scalar control was added. Two initial analyzer brace-style findings were corrected before clean analysis. `git diff --check` passed. No code generation was required.

Evidence logs are local synthetic artifacts:

- `/private/tmp/aedify-m6-007-before.log`: 12 sentinel failures reproduced before the fixes; one private-field case already passed.
- `/private/tmp/aedify-m6-007-format.log`, `aedify-m6-007-analyze.log`, `aedify-m6-007-focused.log`, `aedify-m6-007-tests.log`: formatting, analysis and regression results.

The existing sharing and chat screens are placeholders. `.aedifyplan`/PDF serializers, external import payloads, AI prompt/provider context and physique-analysis transport do not exist yet. This ticket verifies classification denial and that private progress DTOs cannot be implicitly JSON encoded; it does **not** certify nonexistent generated artifacts or future consent flows. M7/M9/import/M13 must rerun these sentinels against their actual serializers and outbound payloads before those features pass their gates. No new exporter/provider or test-only serializer was introduced.

Diagnostic event strings and logger names remain static-identifier caller contracts. Allowlisted scalar values must contain non-sensitive diagnostic metadata; field allowlisting cannot make arbitrary user text safe. All current progress-media and file-store calls were inspected for this contract. The HTTP path interpolation was removed from the shared interceptor.

Native integration was not repeated because this change has no native/UI/media-codec behavior. Existing reminder notification privacy and progress-media capture/deletion regressions run in the full suite. Prior native evidence remains in [deletion/recovery](m6-deletion.md) and [reminders](m6-reminders.md). The previously recorded Android Health registration issue remains outside this ticket. Physical-device accessibility, OS delivery and storage-pressure checks remain manual.

## Changed files

- `lib/core/privacy/privacy_classifier.dart`: local-media field recognition and private default classification.
- `lib/core/privacy/redaction.dart`: diagnostic metadata filtering, complete path and stack redaction.
- `lib/core/logging/app_logger.dart`, `lib/core/firebase/crashlytics_service.dart`: shared guards and documented caller contracts.
- `lib/core/network/interceptors/redacted_logging_interceptor.dart`: fixed HTTP diagnostic events without private URL interpolation.
- `test/app/m6/m6_privacy_exclusion_test.dart`: sentinel, synthetic HTTP and real local repository/file lifecycle regressions.
- `test/core/privacy/privacy_classifier_test.dart`, `test/core/privacy/redaction_test.dart`: updated expectations for stricter defaults and basename exclusion.
- `docs/changelog.md`, `docs/implementation.md`, this file: status, evidence and review handoff.

Sources: PRD FR-12.34–39; architecture §28; roadmap M6 acceptance gate; M6 ticket 007; progress-media feature/data-model/testing plans; M13 AI implementation consent/privacy boundaries. Locked source plans are unchanged.
