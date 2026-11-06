# M6 acceptance smoke — V1-M6-008

Date: 2026-11-06. **M6, including ticket 008, is complete and approved by the user.** The user explicitly instructed not to start M7; it remains unstarted. This evidence connects the completed M6 slices in one isolated native acceptance journey. Manual verification boundaries remain recorded below; user approval does not represent additional test execution.

## Scope

`integration_test/m6_progress_acceptance_test.dart` mounts the real Progress capture, gallery, reminder, comparison, session and storage screens with their existing controllers/services. It uses file-backed schema-v20 SQLite, real sandbox files, native image decoding/video metadata/thumbnail/playback and the real local-notification pending queue. Reopening disposes the widget/provider/router scope and database connection before rebuilding against the same files.

Synthetic picker results replace camera/gallery hardware selection. A permission seam first denies reminders, then permits scheduling; iOS uses silent provisional authorization for the test. This does not automate the regular OS permission dialogs or notification delivery. The fixture has no AI keys, real photos, user database or Firebase setup. Dart HTTP client creation is blocked and counted.

The fixture uses existing module boundaries without new persistence, schema, dependency, native or product changes. It has a dedicated temporary database/sandbox, cancels only the reserved progress notification IDs, and deletes its fixture tree after the run. Synthetic comparison/pending-cleanup captures are written separately for host-side visual inspection and removed from the app after collection.

## Connected coverage

| Stage | Assertions |
|---|---|
| Empty/cancelled | No reminder prompt or queue before a saved check-in; cancelled selection persists nothing. |
| Four-pose save | Front/back/left/right photos pass through real preparation and explicit Save; eight originals/thumbnails registered, complete baseline, bodyweight and notes preserved; no frames extracted for AI. |
| Reminder choices | Post-save prompt, denied state without scheduling, monthly/quarterly/off/two-week transitions, fixed notification copy/token format and twelve pending entries when enabled. |
| Mixed save | Second check-in contains photo plus video with native metadata/thumbnail/preview; too-long limit rejects the same native clip; the new check-in resets the reminder date. |
| Compare/detail | Baseline/latest, previous/latest and any-two modes show the matching front photos; video thumbnail is separate. Light/dark captures, notes edit, baseline change and muted native playback. |
| Reopen/missing file | Notes, baseline, sessions and reminders survive database/provider reopen. A removed original presents the recoverable missing-file state. |
| Delete/recover | Cancel preserves a session. Confirm hides it, repairs baseline and retains failed video unlink as pending intent. A second reopen retains pending work; storage Retry removes the dependent files while keeping the other session. |
| Final cleanup | Delete-all leaves session/item/snapshot/file-registration/reminder tables and native queue empty. Aged UUID-owned orphan is removed; unrelated managed file remains. |
| Privacy/offline | Logger and fake Crashlytics captures exclude fixture notes, selection name, session IDs, sandbox paths, saved paths, video bytes/base64 and synthetic analysis marker. Notification payloads stay fixed-format. Zero Dart HTTP client creation attempts. |

The unit/widget regression suite supplies the broader boundary cases from tickets 001–007, including permission/invalid/corrupt/oversize inputs, rollback, traversal, cleanup ownership, safe diagnostics, 320px/2× text and feature/route guards. The smoke does not duplicate every negative case.

## Verification

The connected native scenario passed on iPhone 18 Pro/iOS 27 (45s) and the Pixel 10 Pro/API 36 emulator (47s), zero Dart HTTP attempts. Light/dark comparison and pending-cleanup captures from both platforms were inspected: pose/date labels, media sizing and retry controls were readable without clipping. Generated on-device captures were removed after preserving host copies under `/private/tmp/aedify-m6-008-{ios,android}-previews/`.

Normal `lib/main.dart` entrypoints were restored/launched on both platforms and their app processes verified. Restore output was discarded to avoid collecting unrelated Android app logs. The headless emulator started for this ticket was then closed; the previously booted iOS simulator was left running.

Final gates: format checked 897 files; analysis found no issues; **1,984/1,984 host tests passed** in 2m30s with zero failures/skips. The one new integration journey passed separately on both platforms. `git diff --check` passed. Commands:

```sh
dart format .
flutter analyze
flutter test --concurrency=2 --reporter expanded
flutter test integration_test/m6_progress_acceptance_test.dart -d 79A92AEE-989A-46CD-BB27-F3F69EC9943E --no-uninstall --reporter expanded
flutter test integration_test/m6_progress_acceptance_test.dart -d emulator-5554 --no-uninstall --reporter expanded
```

Evidence uses `/private/tmp/aedify-m6-008-{format,analyze,tests,ios-final,android}.log`. No code generation is needed. The existing SDK warnings about `flutter_tts` Swift Package Manager support and Android Kotlin/Gradle migration are separate from test assertions.

## Remaining acceptance boundaries

- Physical iOS/Android camera/gallery selection, limited-library access, regular permission dialogs, notification action/delivery/reboot/focus/battery behavior, accessibility/gestures and real storage pressure are **on hold by user instruction dated 2026-11-06**. Simulator/emulator evidence does not satisfy the testing plan's real-device media gate.
- Real `.aedifyplan`/PDF/export/import serializers and AI provider/physique-analysis consent transport belong to later milestones. Their actual outbound artifacts must rerun the [privacy sentinels](m6-privacy-exclusions.md). None are introduced or certified by this smoke.
- The previously recorded Android Health activity-registration error is fixed by the FlutterFragmentActivity change. The SDK-status probe and repeated M6 media acceptance passed; see [gap closure](m0-m6-gap-closure.md). Actual Health data/permissions integration remains future work.
- Existing M1–M4 live Firebase/BYOK checks are on hold by user instruction; [closure evidence](m1-m4-gap-closure.md) preserves the earlier failed/unrun live results.

## Changed files

- `integration_test/m6_progress_acceptance_test.dart`: connected isolated native flow and synthetic test seams/clip.
- `docs/m6-acceptance.md`, `docs/implementation.md`, `docs/changelog.md`: acceptance map, verification, boundaries and review handoff.

Sources: locked PRD progress-media requirements and FR-12.34–39; roadmap M6; architecture storage/privacy boundaries; M6 ticket 008; progress-media feature/data-model/testing plans. No locked source plan changes.
