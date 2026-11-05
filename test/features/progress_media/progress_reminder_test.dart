import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/bootstrap/progress_reminder_job.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/application/progress_reminder_providers.dart';
import 'package:aedify/features/progress_media/presentation/progress_reminder_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/application/progress_reminder_service.dart';
import 'package:aedify/features/progress_media/data/drift_progress_media_repository.dart';
import 'package:aedify/features/progress_media/data/progress_reminder_repository.dart';
import 'package:aedify/features/progress_media/data/progress_reminder_scheduler.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

void main() {
  late _ReminderFixture f;
  setUp(() async {
    f = await _ReminderFixture.create();
  });
  tearDown(() => f.dispose());
  test(
    'no permission request or schedule before a committed first check-in',
    () async {
      final view = await f.service.refresh();
      expect(view.status, ProgressReminderStatus.noSession);
      expect(f.scheduler.requests, 0);
      expect(f.scheduler.probes, 0);
      expect(f.scheduler.dates, isEmpty);
      await expectLater(
        f.repository.choose(ProgressReminderCadence.monthly, f.clock),
        throwsA(ProgressReminderFailure.storage),
      );
      expect((await f.repository.load()).reminder.lastPromptedAt, isNull);
    },
  );
  test(
    'first save prompts once, default remains off, explicit off is durable',
    () async {
      await f.save();
      expect((await f.repository.load()).reminder.canPrompt, isTrue);
      expect((await f.service.refresh()).status, ProgressReminderStatus.off);
      expect(f.scheduler.requests, 0);
      final view = await f.service.refresh(choice: ProgressReminderCadence.off);
      expect(view.context.reminder.canPrompt, isFalse);
      expect(view.context.reminder.enabled, isFalse);
      expect(view.context.reminder.nextReminderAt, isNull);
      await f.save();
      expect((await f.repository.load()).reminder.canPrompt, isFalse);
    },
  );
  for (final cadence in [
    ProgressReminderCadence.twoWeeks,
    ProgressReminderCadence.monthly,
    ProgressReminderCadence.threeMonths,
  ]) {
    test(
      'explicit ${cadence.name} persists and replaces a bounded local window',
      () async {
        await f.save();
        final view = await f.service.refresh(choice: cadence, request: true);
        expect(view.status, ProgressReminderStatus.scheduled);
        expect(f.scheduler.requests, 1);
        expect(f.scheduler.dates, hasLength(12));
        expect(f.scheduler.dates.first, view.context.reminder.nextReminderAt);
        expect(f.scheduler.dates.every((d) => d.isAfter(f.clock)), isTrue);
        expect(view.context.reminder.cadence, cadence);
        final before = [...f.scheduler.dates];
        await f.service.refresh();
        expect(f.scheduler.requests, 1);
        expect(f.scheduler.dates, before);
      },
    );
  }
  test(
    'calendar months clamp month-end without cumulative drift and handle leap year',
    () {
      final january = DateTime.utc(2028, 1, 31, 9);
      expect(
        ProgressReminderPolicy.advance(
          january,
          ProgressReminderCadence.monthly,
          1,
        ),
        DateTime.utc(2028, 2, 29, 9),
      );
      expect(
        ProgressReminderPolicy.advance(
          january,
          ProgressReminderCadence.monthly,
          2,
        ),
        DateTime.utc(2028, 3, 31, 9),
      );
      expect(
        ProgressReminderPolicy.advance(
          DateTime.utc(2027, 11, 30, 9),
          ProgressReminderCadence.threeMonths,
          1,
        ),
        DateTime.utc(2028, 2, 29, 9),
      );
      expect(
        ProgressReminderPolicy.next(
          january,
          ProgressReminderCadence.monthly,
          DateTime.utc(2028, 3, 31, 9),
        ),
        DateTime.utc(2028, 4, 30, 9),
      );
    },
  );
  test(
    'two weeks preserves local wall clock across a daylight-saving transition',
    () {
      final anchor = DateTime(2026, 3, 1, 9);
      final next = ProgressReminderPolicy.advance(
        anchor,
        ProgressReminderCadence.twoWeeks,
        1,
      );
      expect(next, DateTime(2026, 3, 15, 9));
      expect(
        next.difference(anchor).inHours,
        14 * 24 - (next.timeZoneOffset - anchor.timeZoneOffset).inHours,
      );
    },
  );
  test(
    'permission denied/unsupported preserve intent without claiming scheduled',
    () async {
      await f.save();
      f.scheduler.allowed = false;
      var view = await f.service.refresh(
        choice: ProgressReminderCadence.monthly,
        request: true,
      );
      expect(view.status, ProgressReminderStatus.permissionDenied);
      expect(view.context.reminder.enabled, isTrue);
      expect(f.scheduler.dates, isEmpty);
      f.scheduler.allowed = null;
      view = await f.service.refresh();
      expect(view.status, ProgressReminderStatus.unsupported);
      f.scheduler.allowed = true;
      view = await f.service.refresh();
      expect(view.status, ProgressReminderStatus.scheduled);
      expect(f.scheduler.requests, 1);
    },
  );
  test(
    'global notification switch pauses and resumes without re-prompting permission',
    () async {
      await f.save();
      await f.service.refresh(
        choice: ProgressReminderCadence.monthly,
        request: true,
      );
      await f.global(false);
      expect(
        (await f.service.refresh()).status,
        ProgressReminderStatus.appDisabled,
      );
      expect(f.scheduler.dates, isEmpty);
      expect((await f.repository.load()).reminder.enabled, isTrue);
      await f.global(true);
      expect(
        (await f.service.refresh()).status,
        ProgressReminderStatus.scheduled,
      );
      expect(f.scheduler.requests, 1);
    },
  );
  test(
    'feature disabled and last session removed cancel pending reminders',
    () async {
      await f.save();
      await f.service.refresh(
        choice: ProgressReminderCadence.monthly,
        request: true,
      );
      f.featureAllowed = false;
      expect(
        (await f.service.refresh()).status,
        ProgressReminderStatus.appDisabled,
      );
      expect(f.scheduler.dates, isEmpty);
      f.featureAllowed = true;
      await f.service.refresh();
      await f.db.customStatement(
        'UPDATE progress_media_sessions SET deleted_at = 1',
      );
      expect(
        (await f.service.refresh()).status,
        ProgressReminderStatus.noSession,
      );
      expect(f.scheduler.dates, isEmpty);
    },
  );
  test(
    'a new check-in resets due date atomically, older imported check-ins do not',
    () async {
      await f.save();
      await f.service.refresh(
        choice: ProgressReminderCadence.monthly,
        request: true,
      );
      f.clock = DateTime.utc(2026, 11, 20, 12);
      await f.save();
      final state = (await f.repository.load()).reminder;
      expect(state.nextReminderAt, DateTime.utc(2026, 12, 20, 12));
      await f.save(capturedAt: DateTime.utc(2026, 10, 1));
      expect(
        (await f.repository.load()).reminder.nextReminderAt,
        state.nextReminderAt,
      );
      await f.service.refresh();
      expect(f.scheduler.dates.first, state.nextReminderAt);
    },
  );
  test(
    'failed preference write rolls back and retains a safe retry state',
    () async {
      await f.save();
      await f.db.customStatement(
        "CREATE TRIGGER reject_reminders BEFORE UPDATE ON progress_media_reminder_settings BEGIN SELECT RAISE(ABORT, 'private-reminder-sentinel'); END",
      );
      final view = await f.service.refresh(
        choice: ProgressReminderCadence.monthly,
        request: true,
      );
      expect(view.status, ProgressReminderStatus.failed);
      expect(view.failure, ProgressReminderFailure.storage);
      expect(view.context.reminder.canPrompt, isTrue);
      expect(f.scheduler.requests, 0);
      expect(f.scheduler.dates, isEmpty);
      await f.db.customStatement('DROP TRIGGER reject_reminders');
      expect(
        (await f.service.refresh(
          choice: ProgressReminderCadence.monthly,
          request: true,
        )).status,
        ProgressReminderStatus.scheduled,
      );
    },
  );
  test(
    'platform partial failure retains intent and retries; failed off cancellation is visible',
    () async {
      await f.save();
      f.scheduler.failReplace = true;
      final view = await f.service.refresh(
        choice: ProgressReminderCadence.monthly,
        request: true,
      );
      expect(view.failure, ProgressReminderFailure.platform);
      expect(view.context.reminder.enabled, isTrue);
      expect(f.scheduler.dates, isEmpty);
      f.scheduler.failReplace = false;
      expect(
        (await f.service.refresh()).status,
        ProgressReminderStatus.scheduled,
      );
      f.scheduler.failCancel = true;
      expect(
        (await f.service.refresh(choice: ProgressReminderCadence.off)).status,
        ProgressReminderStatus.failed,
      );
      expect((await f.repository.load()).reminder.enabled, isFalse);
      f.scheduler.failCancel = false;
      expect((await f.service.refresh()).status, ProgressReminderStatus.off);
      expect(f.scheduler.dates, isEmpty);
    },
  );
  test(
    'new check-in during permission await cannot leave a stale OS schedule',
    () async {
      await f.save();
      f.scheduler.permissionGate = Completer<bool?>();
      final refreshing = f.service.refresh(
        choice: ProgressReminderCadence.monthly,
        request: true,
      );
      await _ReminderFixture.waitUntil(() => f.scheduler.requests == 1);
      f.clock = DateTime.utc(2026, 11, 20, 12);
      await f.save();
      f.scheduler.permissionGate!.complete(true);
      final view = await refreshing;
      expect(
        view.context.reminder.nextReminderAt,
        DateTime.utc(2026, 12, 20, 12),
      );
      expect(f.scheduler.dates.first, view.context.reminder.nextReminderAt);
    },
  );
  test(
    'snooze and skip update durable due dates; duplicate/stale actions do nothing',
    () async {
      await f.save();
      var view = await f.service.refresh(
        choice: ProgressReminderCadence.twoWeeks,
        request: true,
      );
      final original = view.context.reminder.nextReminderAt!;
      f.clock = original;
      final event = ProgressReminderEvent(
        action: ProgressReminderAction.snooze,
        generation: original,
        due: original,
      );
      view = await f.service.refresh(event: event);
      expect(
        view.context.reminder.nextReminderAt,
        original.add(const Duration(days: 1)),
      );
      f.clock = f.clock.add(const Duration(hours: 1));
      expect(
        (await f.service.refresh(event: event)).context.reminder.nextReminderAt,
        view.context.reminder.nextReminderAt,
      );
      final snoozed = view.context.reminder.nextReminderAt!;
      f.clock = snoozed;
      view = await f.service.refresh(
        event: ProgressReminderEvent(
          action: ProgressReminderAction.skip,
          generation: snoozed,
          due: snoozed,
        ),
      );
      expect(
        view.context.reminder.nextReminderAt,
        original.add(const Duration(days: 14)),
      );
    },
  );
  test(
    'cold-start Take action is handled before overdue reconciliation',
    () async {
      await f.save();
      final first = await f.service.refresh(
        choice: ProgressReminderCadence.twoWeeks,
        request: true,
      );
      final due = first.context.reminder.nextReminderAt!;
      f.clock = due.add(const Duration(minutes: 1));
      f.scheduler.launch = ProgressReminderEvent(
        action: ProgressReminderAction.take,
        generation: due,
        due: due,
      );
      var captures = 0;
      final sub = f.service.captureRequests.listen((_) => captures++);
      await f.service.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(captures, 1);
      expect(f.scheduler.dates.first.isAfter(f.clock), isTrue);
      await sub.cancel();
    },
  );
  test(
    'reopen retains choice and reconstructs schedule without another prompt',
    () async {
      await f.save();
      await f.service.refresh(
        choice: ProgressReminderCadence.threeMonths,
        request: true,
      );
      final state = (await f.repository.load()).reminder;
      final replacement = ProgressReminderService(
        repository: ProgressReminderRepository(f.db),
        scheduler: _ReminderScheduler(),
        now: () => f.clock,
        featureAllowed: () => true,
      );
      final view = await replacement.refresh();
      expect(view.context.reminder.cadence, state.cadence);
      expect(view.context.reminder.canPrompt, isFalse);
      expect(view.context.reminder.nextReminderAt, state.nextReminderAt);
      await replacement.dispose();
    },
  );
  test(
    'notification parser allowlists IDs/actions and rejects raw/malformed payloads',
    () {
      const kind = NotificationResponseType.selectedNotificationAction;
      for (final payload in [
        null,
        '/private/media-sentinel',
        'checkin:x:1',
        'checkin:1:0',
        'checkin:1:9999999999999999',
      ]) {
        expect(
          LocalProgressReminderScheduler.decode(
            NotificationResponse(
              id: 61000,
              notificationResponseType: kind,
              payload: payload,
            ),
          ),
          isNull,
        );
      }
      expect(
        LocalProgressReminderScheduler.decode(
          const NotificationResponse(
            id: 1,
            notificationResponseType: kind,
            payload: 'checkin:1:2',
          ),
        ),
        isNull,
      );
      expect(
        LocalProgressReminderScheduler.decode(
          const NotificationResponse(
            id: 61000,
            notificationResponseType: kind,
            actionId: 'private-unknown',
            payload: 'checkin:1:2',
          ),
        ),
        isNull,
      );
      expect(
        LocalProgressReminderScheduler.decode(
          const NotificationResponse(
            id: 61000,
            notificationResponseType: kind,
            actionId: 'skip',
            payload: 'checkin:1:2',
          ),
        )!.action,
        ProgressReminderAction.skip,
      );
    },
  );
  test(
    'app job waits for bootstrap and reacts to global settings with no media screen open',
    () async {
      await f.save();
      await f.repository.choose(ProgressReminderCadence.monthly, f.clock);
      final container = ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(f.db),
          AppBootstrap.controllerProvider.overrideWith(_ReminderBootstrap.new),
          AppProviders.onboardingStatusProvider.overrideWithValue(
            const AsyncData(OnboardingStatus.complete),
          ),
          ProgressReminderProviders.repositoryProvider.overrideWithValue(
            f.repository,
          ),
          ProgressReminderProviders.schedulerProvider.overrideWithValue(
            f.scheduler,
          ),
          ProgressMediaProviders.clockProvider.overrideWithValue(() => f.clock),
        ],
      );
      final sub = container.listen(ProgressReminderJob.provider, (_, _) {});
      expect(f.scheduler.initializations, 0);
      container.read(AppBootstrap.controllerProvider.notifier).state =
          const BootstrapState.success();
      await _ReminderFixture.waitUntil(
        () =>
            container
                .read(ProgressReminderProviders.controllerProvider)
                .asData
                ?.value
                .status ==
            ProgressReminderStatus.scheduled,
        reason: 'scheduled',
      );
      expect(f.scheduler.requests, 0);
      await f.global(false);
      await _ReminderFixture.waitUntil(
        () =>
            container
                .read(ProgressReminderProviders.controllerProvider)
                .asData
                ?.value
                .status ==
            ProgressReminderStatus.appDisabled,
        reason: 'global off',
      );
      expect(f.scheduler.dates, isEmpty);
      await f.global(true);
      await _ReminderFixture.waitUntil(
        () =>
            container
                .read(ProgressReminderProviders.controllerProvider)
                .asData
                ?.value
                .status ==
            ProgressReminderStatus.scheduled,
        reason: 'scheduled',
      );
      expect(f.scheduler.requests, 0);
      sub.close();
      container.dispose();
    },
  );
  test(
    'controller coalesces refreshes and prevents overlapping permission choices',
    () async {
      await f.save();
      final container = ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(f.db),
          ProgressReminderProviders.schedulerProvider.overrideWithValue(
            f.scheduler,
          ),
          ProgressMediaProviders.clockProvider.overrideWithValue(() => f.clock),
        ],
      );
      final sub = container.listen(
        ProgressReminderProviders.controllerProvider,
        (_, _) {},
      );
      await container.read(ProgressReminderProviders.controllerProvider.future);
      f.scheduler.permissionGate = Completer<bool?>();
      final controller = container.read(
        ProgressReminderProviders.controllerProvider.notifier,
      );
      final choosing = controller.choose(ProgressReminderCadence.monthly);
      await _ReminderFixture.waitUntil(() => f.scheduler.requests == 1);
      await controller.refresh();
      await controller.choose(ProgressReminderCadence.off);
      expect(
        container
            .read(ProgressReminderProviders.controllerProvider)
            .asData!
            .value
            .busy,
        isTrue,
      );
      f.scheduler.permissionGate!.complete(true);
      await choosing;
      expect(
        (await f.repository.load()).reminder.cadence,
        ProgressReminderCadence.monthly,
      );
      expect(
        container
            .read(ProgressReminderProviders.controllerProvider)
            .asData!
            .value
            .busy,
        isFalse,
      );
      sub.close();
      container.dispose();
    },
  );
  testWidgets(
    'before first session there is no cadence choice or permission action',
    (tester) async {
      final controller = _ReminderUiController(
        _ReminderUiController.view(hasSession: false),
      );
      await _ReminderUiController.mount(tester, controller);
      expect(find.text(AppStrings.progressReminderNoSession), findsOneWidget);
      expect(find.byKey(const ValueKey('reminder_apply')), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
    },
  );
  testWidgets(
    'prompt edits remain ephemeral until explicit apply and off is a valid answer',
    (tester) async {
      final controller = _ReminderUiController(_ReminderUiController.view());
      await _ReminderUiController.mount(tester, controller);
      expect(find.text(AppStrings.progressReminderPrompt), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('reminder_monthly')));
      await tester.pumpAndSettle();
      expect(controller.choices, isEmpty);
      await tester.tap(find.byKey(const ValueKey('reminder_apply')));
      await tester.pumpAndSettle();
      expect(controller.choices, [ProgressReminderCadence.monthly]);
      await tester.tap(find.byKey(const ValueKey('reminder_off')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('reminder_apply')));
      expect(controller.choices.last, ProgressReminderCadence.off);
    },
  );
  testWidgets(
    'permission-denied feedback and retry preserve the selected cadence',
    (tester) async {
      final controller = _ReminderUiController(
        _ReminderUiController.view(
          status: ProgressReminderStatus.permissionDenied,
        ),
      );
      await _ReminderUiController.mount(tester, controller);
      expect(find.text(AppStrings.progressReminderPermission), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('reminder_threeMonths')));
      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();
      expect(controller.refreshes, 1);
      expect(
        tester
            .widget<ChoiceChip>(
              find.byKey(const ValueKey('reminder_threeMonths')),
            )
            .selected,
        isTrue,
      );
    },
  );
  testWidgets('storage failure has safe retry and never exposes SQL details', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        ProgressReminderProviders.controllerProvider.overrideWith(
          _BrokenReminderController.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProgressReminderScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppErrorStrings.progressReminderStorage), findsOneWidget);
    expect(find.textContaining('private-sql-sentinel'), findsNothing);
  });
  for (final dark in [false, true]) {
    testWidgets(
      'reminder choices remain reachable at 320px/2x text in ${dark ? 'dark' : 'light'}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = _ReminderUiController(
          _ReminderUiController.view(
            status: ProgressReminderStatus.permissionDenied,
          ),
        );
        await _ReminderUiController.mount(
          tester,
          controller,
          dark: dark,
          scale: 2,
        );
        final button = find.byKey(const ValueKey('reminder_apply'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(controller.choices, hasLength(1));
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _ReminderScheduler implements ProgressReminderScheduler {
  bool? allowed = true;
  int initializations = 0;
  int requests = 0;
  int probes = 0;
  bool failCancel = false;
  bool failReplace = false;
  Completer<bool?>? permissionGate;
  List<DateTime> dates = [];
  ProgressReminderEvent? launch;
  @override
  Stream<ProgressReminderEvent> get events => const Stream.empty();
  @override
  Future<ProgressReminderEvent?> initialize() async {
    initializations++;
    final result = launch;
    launch = null;
    return result;
  }

  @override
  Future<bool?> permission({bool request = false}) async {
    probes++;
    if (request) requests++;
    return permissionGate == null ? allowed : await permissionGate!.future;
  }

  @override
  Future<void> cancel() async {
    if (failCancel) throw StateError('private-platform-sentinel');
    dates = [];
  }

  @override
  Future<void> replace(List<DateTime> values, DateTime generation) async {
    if (failReplace) throw StateError('private-platform-sentinel');
    dates = values;
  }
}

class _ReminderFixture {
  _ReminderFixture(this.root, this.db) {
    repository = ProgressReminderRepository(db);
    service = ProgressReminderService(
      repository: repository,
      scheduler: scheduler,
      now: () => clock,
      featureAllowed: () => featureAllowed,
    );
  }
  final Directory root;
  final AppDatabase db;
  late final ProgressReminderRepository repository;
  late final ProgressReminderService service;
  final scheduler = _ReminderScheduler();
  DateTime clock = DateTime.utc(2026, 11, 5, 12);
  bool featureAllowed = true;
  static Future<_ReminderFixture> create() async => _ReminderFixture(
    await Directory.systemTemp.createTemp('m6_reminder_'),
    AppDatabase(NativeDatabase.memory()),
  );
  Future<void> save({DateTime? capturedAt}) async {
    final session = const Uuid().v4();
    final item = const Uuid().v4();
    final files = LocalFileStore(basePath: root.path);
    final path = p.posix.join(
      'media',
      'progress',
      'sessions',
      session,
      'originals',
      '$item.jpg',
    );
    await files.writeManagedBytes(path, Uint8List.fromList([1, 2, 3]));
    await DriftProgressMediaRepository(
      database: db,
      fileStore: files,
      now: () => clock,
    ).saveSession(
      ProgressMediaSessionDraft(
        id: session,
        capturedAt: capturedAt ?? clock,
        items: [
          ProgressMediaFileDraft(
            id: item,
            type: ProgressMediaItemType.photo,
            pose: ProgressMediaPose.front,
            source: ProgressMediaSource.gallery,
            relativePath: path,
          ),
        ],
      ),
    );
  }

  Future<void> global(bool enabled) async {
    await db
        .into(db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion(
            id: const Value('default'),
            notificationsEnabled: Value(enabled),
            createdAt: Value(clock),
            updatedAt: Value(clock),
          ),
        );
  }

  Future<void> dispose() async {
    await service.dispose();
    await db.close();
    await root.delete(recursive: true);
  }

  static Future<void> waitUntil(
    bool Function() condition, {
    String reason = 'permission gate',
  }) async {
    for (var i = 0; i < 100; i++) {
      if (condition()) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('Timed out waiting for $reason');
  }
}

class _ReminderBootstrap extends BootstrapController {
  @override
  BootstrapState build() => const BootstrapState.initializing();
}

class _BrokenReminderController extends ProgressReminderController {
  @override
  Future<ProgressReminderView> build() async =>
      throw StateError('private-sql-sentinel');
}

class _ReminderUiController extends ProgressReminderController {
  _ReminderUiController(this.initial);
  final ProgressReminderView initial;
  final choices = <ProgressReminderCadence>[];
  int refreshes = 0;
  @override
  Future<ProgressReminderView> build() async => initial;
  @override
  Future<void> choose(ProgressReminderCadence cadence) async {
    choices.add(cadence);
  }

  @override
  Future<void> refresh() async {
    refreshes++;
  }

  static ProgressReminderView view({
    bool hasSession = true,
    ProgressReminderStatus status = ProgressReminderStatus.off,
  }) => ProgressReminderView(
    context: ProgressReminderContext(
      reminder: ProgressMediaReminderState(
        lastSessionAt: hasSession ? DateTime.utc(2026, 11, 5) : null,
      ),
      hasSessions: hasSession,
      notificationsAllowed: true,
    ),
    status: hasSession ? status : ProgressReminderStatus.noSession,
  );
  static Future<void> mount(
    WidgetTester tester,
    _ReminderUiController controller, {
    bool dark = false,
    double scale = 1,
  }) async {
    final container = ProviderContainer(
      overrides: [
        ProgressReminderProviders.controllerProvider.overrideWith(
          () => controller,
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const ProgressReminderScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}
