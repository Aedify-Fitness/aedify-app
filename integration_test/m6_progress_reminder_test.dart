import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/application/progress_reminder_providers.dart';
import 'package:aedify/features/progress_media/application/progress_reminder_service.dart';
import 'package:aedify/features/progress_media/data/drift_progress_media_repository.dart';
import 'package:aedify/features/progress_media/data/progress_reminder_repository.dart';
import 'package:aedify/features/progress_media/data/progress_reminder_scheduler.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';
import 'package:aedify/features/progress_media/presentation/progress_reminder_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'offline reminder gate, native pending queue, cadence/reset/off and durable reopen',
    (tester) async {
      final prior = HttpOverrides.current;
      final network = _ReminderNetwork();
      HttpOverrides.global = network;
      final root = await (await getTemporaryDirectory()).createTemp(
        'm6_reminder_native_',
      );
      final dbFile = File(p.join(root.path, 'fixture.sqlite'));
      var db = AppDatabase(NativeDatabase(dbFile));
      final files = LocalFileStore(basePath: p.join(root.path, 'sandbox'));
      var clock = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 * 1000,
        isUtc: true,
      );
      final native = LocalProgressReminderScheduler();
      // This seam avoids OS permission dialogs. Every pending request still uses
      // the real plugin/OS adapter; authorization/delivery are separately manual.
      final scheduler = _NativeQueueProbe(native);
      var container = ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          AppProviders.localFileStoreProvider.overrideWithValue(files),
          ProgressMediaProviders.clockProvider.overrideWithValue(() => clock),
          ProgressReminderProviders.schedulerProvider.overrideWithValue(
            scheduler,
          ),
        ],
      );
      var dark = false;
      Future<void> mount() => tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(
            key: _ReminderSmoke.key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              home: const ProgressReminderScreen(),
            ),
          ),
        ),
      );
      Future<List<PendingNotificationRequest>> pending() async =>
          (await FlutterLocalNotificationsPlugin()
                  .pendingNotificationRequests())
              .where((n) => n.id >= 61000 && n.id < 61012)
              .toList();
      Future<void> save() async {
        final id = const Uuid().v4();
        final itemId = const Uuid().v4();
        final path = p.join(
          'media',
          'progress',
          'sessions',
          id,
          'originals',
          '$itemId.jpg',
        );
        await files.writeManagedBytes(path, Uint8List.fromList([1, 2, 3]));
        await DriftProgressMediaRepository(
          database: db,
          fileStore: files,
          now: () => clock,
        ).saveSession(
          ProgressMediaSessionDraft(
            id: id,
            capturedAt: clock,
            notes: 'private-reminder-fixture-note',
            items: [
              ProgressMediaFileDraft(
                id: itemId,
                type: ProgressMediaItemType.photo,
                pose: ProgressMediaPose.front,
                source: ProgressMediaSource.gallery,
                relativePath: path,
              ),
            ],
          ),
        );
      }

      try {
        await mount();
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.progressReminderNoSession), findsOneWidget);
        expect(find.byKey(const ValueKey('reminder_apply')), findsNothing);
        expect(await pending(), isEmpty);
        expect(scheduler.requests, 0);
        await save();
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.progressReminderPrompt), findsOneWidget);
        await _ReminderSmoke.capture(tester, 'prompt_light');
        dark = true;
        await mount();
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        await _ReminderSmoke.capture(tester, 'prompt_dark');
        await tester.tap(find.byKey(const ValueKey('reminder_monthly')));
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const ValueKey('reminder_apply')),
        );
        await tester.tap(find.byKey(const ValueKey('reminder_apply')));
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        expect(
          find.text(AppStrings.progressReminderPermission),
          findsOneWidget,
        );
        expect(await pending(), isEmpty);
        if (Platform.isIOS) {
          // Provisional authorization is silent and scoped to this simulator app.
          // Production only requests regular permission after explicit Apply.
          final granted = await FlutterLocalNotificationsPlugin()
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()!
              .requestPermissions(
                alert: true,
                badge: false,
                sound: false,
                provisional: true,
              );
          expect(granted, isTrue);
          expect(await native.permission(), isTrue);
        }
        scheduler.allowed = true;
        await tester.tap(find.byKey(const ValueKey('reminder_apply')));
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        var queue = await pending();
        expect(
          container
              .read(ProgressReminderProviders.controllerProvider)
              .asData
              ?.value
              .status,
          ProgressReminderStatus.scheduled,
        );
        expect(queue, hasLength(12));
        for (final notification in queue) {
          expect(notification.title, AppStrings.appTitle);
          expect(notification.body, AppStrings.progressReminderNotification);
          expect(notification.payload, startsWith('checkin:'));
          expect(
            notification.payload,
            isNot(contains('private-reminder-fixture-note')),
          );
          expect(notification.payload, isNot(contains('media/')));
        }
        await _ReminderSmoke.capture(tester, 'scheduled_dark');
        dark = false;
        await mount();
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        await _ReminderSmoke.capture(tester, 'scheduled_light');
        final old = (await ProgressReminderRepository(
          db,
        ).load()).reminder.nextReminderAt!;
        clock = clock.add(const Duration(days: 2));
        await save();
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        final reset = (await ProgressReminderRepository(
          db,
        ).load()).reminder.nextReminderAt!;
        expect(reset, isNot(old));
        queue = await pending();
        expect(queue, hasLength(12));
        expect(
          queue.every(
            (n) => n.payload!.startsWith(
              'checkin:${reset.millisecondsSinceEpoch}:',
            ),
          ),
          isTrue,
        );
        await tester.tap(find.byKey(const ValueKey('reminder_threeMonths')));
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('reminder_apply')));
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        expect(
          (await ProgressReminderRepository(db).load()).reminder.cadence,
          ProgressReminderCadence.threeMonths,
        );
        expect(await pending(), hasLength(12));
        await tester.tap(find.byKey(const ValueKey('reminder_twoWeeks')));
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('reminder_apply')));
        await tester.pumpAndSettle();
        await container
            .read(ProgressReminderProviders.controllerProvider.notifier)
            .refresh();
        await tester.pumpAndSettle();
        expect(
          (await ProgressReminderRepository(db).load()).reminder.cadence,
          ProgressReminderCadence.twoWeeks,
        );
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        await db.close();
        db = AppDatabase(NativeDatabase(dbFile));
        final repository = ProgressReminderRepository(db);
        final restored = ProgressReminderService(
          repository: repository,
          scheduler: scheduler,
          now: () => clock,
          featureAllowed: () => true,
        );
        final view = await restored.refresh();
        expect(view.context.reminder.cadence, ProgressReminderCadence.twoWeeks);
        expect(view.context.reminder.canPrompt, isFalse);
        expect(await pending(), hasLength(12));
        expect(
          (await restored.refresh(choice: ProgressReminderCadence.off)).status,
          ProgressReminderStatus.off,
        );
        expect(await pending(), isEmpty);
        await restored.dispose();
        expect(network.attempts, 0);
      } finally {
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        await native.cancel();
        await native.dispose();
        await db.close();
        await root.delete(recursive: true);
        HttpOverrides.global = prior;
      }
    },
  );
}

class _NativeQueueProbe implements ProgressReminderScheduler {
  _NativeQueueProbe(this.native);
  final LocalProgressReminderScheduler native;
  bool allowed = false;
  int requests = 0;
  @override
  Stream<ProgressReminderEvent> get events => native.events;
  @override
  Future<ProgressReminderEvent?> initialize() => native.initialize();
  @override
  Future<bool?> permission({bool request = false}) async {
    if (request) requests++;
    await native.permission();
    return allowed;
  }

  @override
  Future<void> replace(List<DateTime> dates, DateTime generation) =>
      native.replace(dates, generation);
  @override
  Future<void> cancel() => native.cancel();
}

abstract final class _ReminderSmoke {
  static final key = GlobalKey();
  static Future<void> capture(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    final image = await tester
        .renderObject<RenderRepaintBoundary>(find.byKey(key))
        .toImage();
    final bytes = (await image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    image.dispose();
    final dir = await getApplicationDocumentsDirectory();
    await File(
      p.join(dir.path, 'aedify_m6_reminder_$name.png'),
    ).writeAsBytes(bytes);
  }
}

class _ReminderNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Reminder smoke must stay offline');
  }
}
