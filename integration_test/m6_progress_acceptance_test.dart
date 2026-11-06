import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/application/progress_deletion_providers.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/application/progress_reminder_providers.dart';
import 'package:aedify/features/progress_media/application/progress_video_providers.dart';
import 'package:aedify/features/progress_media/data/progress_photo_picker.dart';
import 'package:aedify/features/progress_media/data/progress_media_repository.dart';
import 'package:aedify/features/progress_media/data/progress_reminder_scheduler.dart';
import 'package:aedify/features/progress_media/data/progress_video_metadata_service.dart';
import 'package:aedify/features/progress_media/data/progress_video_picker.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:aedify/features/progress_media/presentation/progress_comparison_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_components.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_media_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_reminder_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_session_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_storage_screen.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'M6 offline photo/video, reminders, comparison, restart, cleanup and privacy acceptance',
    (tester) async {
      final prior = HttpOverrides.current;
      final network = _AcceptanceNetwork();
      HttpOverrides.global = network;
      addTearDown(() => HttpOverrides.global = prior);
      final fixture = await _AcceptanceFixture.create();
      try {
        await fixture.mount(tester);
        await fixture.go(tester, AppRoutes.progressReminders());
        await fixture.refreshReminders(tester);
        expect(find.text(AppStrings.progressReminderNoSession), findsOneWidget);
        expect(await fixture.pending(), isEmpty);
        expect(fixture.scheduler.requests, 0);

        await fixture.go(tester, AppRoutes.progress());
        await _AcceptanceUi.tap(tester, 'progress_new');
        fixture.picker.cancelNext = true;
        await _AcceptanceUi.photo(tester, 'front');
        expect(find.text(AppStrings.progressPhotoCancelled), findsOneWidget);
        expect(
          await fixture.db.select(fixture.db.progressMediaSessions).get(),
          isEmpty,
        );
        for (final pose in ['front', 'back', 'leftSide', 'rightSide']) {
          await _AcceptanceUi.photo(tester, pose);
        }
        expect(
          await fixture.db.select(fixture.db.localFileRecords).get(),
          isEmpty,
        );
        await _AcceptanceUi.save(tester, _AcceptanceFixture.notes);
        final first = (await fixture.repository.loadTimeline()).single;
        expect(first.isCompletePoseSet, isTrue);
        expect(first.isBaseline, isTrue);
        expect(first.bodyweightKg, 75);
        final firstFiles = (await fixture.repository.getSessionDetails(
          first.id,
        ))!.items;
        expect(firstFiles, hasLength(8));
        expect(
          firstFiles.where(
            (item) => item.file.type == ProgressMediaItemType.videoFrame,
          ),
          isEmpty,
        );

        await fixture.go(tester, AppRoutes.progressReminders());
        await fixture.refreshReminders(tester);
        expect(find.text(AppStrings.progressReminderPrompt), findsOneWidget);
        await _AcceptanceUi.tap(tester, 'reminder_monthly');
        await _AcceptanceUi.tap(tester, 'reminder_apply');
        await fixture.refreshReminders(tester);
        expect(
          find.text(AppStrings.progressReminderPermission),
          findsOneWidget,
        );
        expect(await fixture.pending(), isEmpty);
        if (Platform.isIOS) {
          // Silent provisional authorization is test-only; regular permission UI
          // and OS delivery still require physical-device acceptance.
          expect(
            await FlutterLocalNotificationsPlugin()
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()!
                .requestPermissions(
                  alert: true,
                  badge: false,
                  sound: false,
                  provisional: true,
                ),
            isTrue,
          );
        }
        fixture.scheduler.allowed = true;
        await _AcceptanceUi.tap(tester, 'reminder_apply');
        await fixture.refreshReminders(tester);
        expect(await fixture.pending(), hasLength(12));
        for (final cadence in ['threeMonths', 'off', 'twoWeeks']) {
          await _AcceptanceUi.tap(tester, 'reminder_$cadence');
          await _AcceptanceUi.tap(tester, 'reminder_apply');
          await fixture.refreshReminders(tester);
          expect(await fixture.pending(), hasLength(cadence == 'off' ? 0 : 12));
        }
        final oldDue =
            (await fixture.repository.getReminderState()).nextReminderAt;

        fixture.clock = fixture.clock.add(const Duration(days: 2));
        await fixture.go(tester, AppRoutes.progress());
        await _AcceptanceUi.tap(tester, 'progress_new');
        await _AcceptanceUi.photo(tester, 'front');
        await _AcceptanceUi.tap(tester, 'video_choose');
        await _AcceptanceUi.tap(tester, 'photo_source_gallery');
        final draft = fixture.container
            .read(ProgressPhotoProviders.controllerProvider)
            .requireValue;
        expect(draft.videoPreviewReady, isTrue);
        await expectLater(
          NativeProgressVideoMetadataService(fixture.files).inspect(
            draft.video!.originalStagingPath,
            const ProgressVideoLimits(maxDuration: Duration(seconds: 1)),
          ),
          throwsA(ProgressVideoFailure.tooLong),
        );
        await _AcceptanceUi.save(tester, _AcceptanceFixture.notes);
        final latest = (await fixture.repository.loadTimeline()).first;
        expect(latest.mediaType, ProgressMediaType.both);
        expect(latest.id, isNot(first.id));
        await fixture.refreshReminders(tester);
        expect(
          (await fixture.repository.getReminderState()).nextReminderAt,
          isNot(oldDue),
        );
        final latestDetail = (await fixture.repository.getSessionDetails(
          latest.id,
        ))!;
        expect(latestDetail.items, hasLength(4));
        final video = latestDetail.items.firstWhere(
          (item) => item.file.type == ProgressMediaItemType.video,
        );

        await fixture.go(tester, AppRoutes.progress());
        await _AcceptanceUi.tap(tester, 'progress_compare');
        expect(_AcceptanceUi.comparedPhotos, findsNWidgets(2));
        await fixture.capture(tester, 'compare_light');
        fixture.dark = true;
        await fixture.mount(tester);
        await fixture.capture(tester, 'compare_dark');
        for (final mode in ['previousLatest', 'anyTwo']) {
          await _AcceptanceUi.tap(tester, 'compare_$mode');
          expect(_AcceptanceUi.comparedPhotos, findsNWidgets(2));
        }

        await fixture.goSession(tester, latest.id);
        await _AcceptanceUi.tapText(tester, AppStrings.progressSetBaseline);
        expect((await fixture.repository.getBaselineSession())!.id, latest.id);
        await _AcceptanceUi.tapText(tester, AppStrings.progressEditNotes);
        await tester.enterText(
          find.byKey(const ValueKey('saved_notes')),
          _AcceptanceFixture.editedNotes,
        );
        await tester.tap(find.text(AppStrings.save));
        await tester.pumpAndSettle();
        await _AcceptanceUi.tapText(tester, AppStrings.progressPlayVideo);
        final playback = await fixture.container.read(
          ProgressVideoProviders.previewProvider(
            video.file.relativePath,
          ).future,
        );
        expect(playback.player.value.volume, 0);
        await playback.player.play();
        await tester.pump(const Duration(milliseconds: 700));
        await playback.player.pause();
        expect(playback.player.value.position, greaterThan(Duration.zero));
        await fixture.reopen(tester);
        expect((await fixture.repository.loadTimeline()), hasLength(2));
        expect(
          (await fixture.repository.getSessionDetails(
            latest.id,
          ))!.session.notes,
          _AcceptanceFixture.editedNotes,
        );
        expect((await fixture.repository.getBaselineSession())!.id, latest.id);
        await fixture.refreshReminders(tester);
        expect(await fixture.pending(), hasLength(12));

        final photo = latestDetail.items.firstWhere(
          (item) => item.file.type == ProgressMediaItemType.photo,
        );
        await fixture.files.deleteManagedRelativeFile(photo.file.relativePath);
        // Model an original disappearing while the app is closed. A fresh
        // scope must re-stat it rather than reuse an already loaded preview.
        await fixture.reopen(tester);
        await fixture.goSession(tester, latest.id);
        expect(find.text(AppErrorStrings.progressSavedMissing), findsOneWidget);
        await _AcceptanceUi.tap(tester, 'progress_delete_${latest.id}');
        await tester.tap(find.text(AppStrings.cancel));
        await tester.pumpAndSettle();
        expect(
          await fixture.repository.getSessionDetails(latest.id),
          isNotNull,
        );
        fixture.files.blocked = video.file.relativePath;
        await _AcceptanceUi.tap(tester, 'progress_delete_${latest.id}');
        await _AcceptanceUi.tap(tester, 'progress_confirm_delete');
        expect(await fixture.repository.getSessionDetails(latest.id), isNull);
        expect((await fixture.repository.getBaselineSession())!.id, first.id);
        expect(
          (await fixture.container
                  .read(ProgressDeletionProviders.serviceProvider)
                  .status())
              .pending,
          isTrue,
        );
        await fixture.reopen(tester);
        expect(
          (await fixture.container
                  .read(ProgressDeletionProviders.serviceProvider)
                  .status())
              .pending,
          isTrue,
        );
        await fixture.go(tester, AppRoutes.progressStorage());
        expect(
          find.text(AppErrorStrings.progressCleanupPending),
          findsOneWidget,
        );
        await fixture.capture(tester, 'pending_cleanup');
        fixture.files.blocked = null;
        await _AcceptanceUi.tap(tester, 'progress_retry_cleanup');
        expect(find.text(AppErrorStrings.progressCleanupPending), findsNothing);
        for (final item in latestDetail.items) {
          expect(
            await fixture.files.statManagedFile(item.file.relativePath),
            isNull,
          );
        }
        for (final item in firstFiles) {
          expect(
            await fixture.files.statManagedFile(item.file.relativePath),
            isNotNull,
          );
        }

        final orphan = p.posix.join(
          'media',
          'progress',
          'sessions',
          const Uuid().v4(),
          'originals',
          '${const Uuid().v4()}.png',
        );
        await fixture.files.writeManagedBytes(
          orphan,
          Uint8List.fromList([1, 2, 3]),
        );
        await (await fixture.files.managedFile(
          orphan,
        )).setLastModified(fixture.clock.subtract(const Duration(days: 2)));
        await fixture.files.writeManagedBytes(
          'media/m6_acceptance_unrelated.bin',
          Uint8List.fromList([9, 8, 7]),
        );
        await _AcceptanceUi.tap(tester, 'progress_delete_all');
        await _AcceptanceUi.tap(tester, 'progress_confirm_delete');
        await fixture.container
            .read(ProgressDeletionProviders.controllerProvider.notifier)
            .recover();
        expect(await fixture.repository.loadTimeline(), isEmpty);
        expect(
          await fixture.db.select(fixture.db.progressMediaSessions).get(),
          isEmpty,
        );
        expect(
          await fixture.db.select(fixture.db.progressMediaItems).get(),
          isEmpty,
        );
        expect(
          await fixture.db
              .select(fixture.db.progressMeasurementSnapshots)
              .get(),
          isEmpty,
        );
        expect(
          await fixture.db.select(fixture.db.localFileRecords).get(),
          isEmpty,
        );
        expect(
          await fixture.db
              .select(fixture.db.progressMediaReminderSettings)
              .get(),
          isEmpty,
        );
        expect(await fixture.pending(), isEmpty);
        expect(await fixture.files.statManagedFile(orphan), isNull);
        expect(
          await fixture.files.readManagedBytes(
            'media/m6_acceptance_unrelated.bin',
          ),
          [9, 8, 7],
        );
        await fixture.go(tester, AppRoutes.progress());
        expect(
          find.byKey(ValueKey('progress_session_${first.id}')),
          findsNothing,
        );

        final crash = CrashlyticsService(client: fixture.diagnostics);
        final privateMetadata = <String, Object?>{
          'session_notes': _AcceptanceFixture.editedNotes,
          'progress_media_path': video.file.relativePath,
          'thumbnail': latestDetail.items.last.file.relativePath,
          'media_bytes': base64Decode(_AcceptanceClip.base64Video),
          'physique_analysis_result': 'M6_ACCEPTANCE_PRIVATE_ANALYSIS',
          'error_code': 'progress_media_unavailable',
        };
        fixture.diagnostics.logger.error(
          'progress_media_failed',
          metadata: privateMetadata,
          error: FileSystemException(
            _AcceptanceFixture.notes,
            video.file.relativePath,
          ),
          stackTrace: StackTrace.fromString(video.file.relativePath),
        );
        crash.logSafe('progress_media_failed', metadata: privateMetadata);
        crash.recordErrorSafe(
          StateError(_AcceptanceFixture.notes),
          StackTrace.fromString(video.file.relativePath),
          reason: _AcceptanceFixture.editedNotes,
          metadata: privateMetadata,
        );
        final output = fixture.diagnostics.events.join('\n');
        for (final sentinel in [
          first.id,
          latest.id,
          fixture.root.path,
          _AcceptanceFixture.notes,
          _AcceptanceFixture.editedNotes,
          'M6_ACCEPTANCE_PRIVATE_ANALYSIS',
          _AcceptanceClip.base64Video,
          base64Decode(_AcceptanceClip.base64Video).toString(),
          _AcceptancePicker.name,
          for (final item in [...firstFiles, ...latestDetail.items])
            item.file.relativePath,
        ]) {
          expect(output, isNot(contains(sentinel)));
        }
        expect(output, contains('progress_media_unavailable'));
        expect(network.attempts, 0);
        expect(tester.takeException(), isNull);
      } finally {
        await fixture.dispose(tester);
        HttpOverrides.global = prior;
      }
    },
  );
}

class _AcceptanceFixture {
  _AcceptanceFixture(this.root) {
    db = AppDatabase(NativeDatabase(File(p.join(root.path, 'fixture.sqlite'))));
    files = _AcceptanceFiles(p.join(root.path, 'sandbox'), diagnostics.logger);
    picker = _AcceptancePicker(root);
    _createScope();
  }
  static const notes = 'M6_ACCEPTANCE_PRIVATE_NOTES';
  static const editedNotes = 'M6_ACCEPTANCE_PRIVATE_EDITED_NOTES';
  static final captureKey = GlobalKey();
  final Directory root;
  final diagnostics = _AcceptanceDiagnostics();
  final native = LocalProgressReminderScheduler();
  late final scheduler = _AcceptanceQueue(native);
  late final _AcceptanceFiles files;
  late final _AcceptancePicker picker;
  late AppDatabase db;
  late ProviderContainer container;
  late GoRouter router;
  DateTime clock = DateTime.fromMillisecondsSinceEpoch(
    DateTime.now().millisecondsSinceEpoch ~/ 1000 * 1000,
    isUtc: true,
  );
  bool dark = false;
  static Future<_AcceptanceFixture> create() async => _AcceptanceFixture(
    await (await getTemporaryDirectory()).createTemp('m6_acceptance_'),
  );
  ProgressMediaRepository get repository =>
      container.read(ProgressMediaProviders.repositoryProvider);
  void _createScope() {
    container = ProviderContainer(
      overrides: [
        AppProviders.appDatabaseProvider.overrideWithValue(db),
        AppProviders.localFileStoreProvider.overrideWithValue(files),
        ProgressMediaProviders.clockProvider.overrideWithValue(() => clock),
        ProgressPhotoProviders.unitsProvider.overrideWith(
          (_) async => PreferredUnit.metric,
        ),
        ProgressPhotoProviders.pickerProvider.overrideWithValue(
          ImagePickerProgressPhotoPicker(files: files, picker: picker),
        ),
        ProgressVideoProviders.pickerProvider.overrideWithValue(
          ImagePickerProgressVideoPicker(files: files, picker: picker),
        ),
        ProgressReminderProviders.schedulerProvider.overrideWithValue(
          scheduler,
        ),
      ],
    );
    router = GoRouter(
      initialLocation: AppRoutes.progress().path,
      routes: [
        GoRoute(
          path: AppRoutes.progress().path,
          name: AppRoutes.progress().name,
          builder: (_, _) => const ProgressGalleryScreen(),
        ),
        GoRoute(
          path: AppRoutes.progressCapture().path,
          name: AppRoutes.progressCapture().name,
          builder: (_, _) => const ProgressMediaScreen(),
        ),
        GoRoute(
          path: AppRoutes.progressReminders().path,
          name: AppRoutes.progressReminders().name,
          builder: (_, _) => const ProgressReminderScreen(),
        ),
        GoRoute(
          path: AppRoutes.progressCompare().path,
          name: AppRoutes.progressCompare().name,
          builder: (_, _) => const ProgressComparisonScreen(),
        ),
        GoRoute(
          path: AppRoutes.progressStorage().path,
          name: AppRoutes.progressStorage().name,
          builder: (_, _) => const ProgressStorageScreen(),
        ),
        GoRoute(
          path: AppRoutes.progressSession().path,
          name: AppRoutes.progressSession().name,
          builder: (_, state) =>
              ProgressSessionScreen(sessionId: state.pathParameters['id']!),
        ),
      ],
    );
  }

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(
          key: captureKey,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> go(WidgetTester tester, AppRoutes route) async {
    router.goNamed(route.name);
    await tester.pumpAndSettle();
  }

  Future<void> goSession(WidgetTester tester, String id) async {
    router.goNamed(
      AppRoutes.progressSession().name,
      pathParameters: {'id': id},
    );
    await tester.pumpAndSettle();
  }

  Future<void> refreshReminders(WidgetTester tester) async {
    await container
        .read(ProgressReminderProviders.controllerProvider.notifier)
        .refresh();
    await tester.pumpAndSettle();
  }

  Future<List<PendingNotificationRequest>> pending() async {
    final values =
        (await FlutterLocalNotificationsPlugin().pendingNotificationRequests())
            .where((n) => n.id >= 61000 && n.id < 61012)
            .toList();
    for (final value in values) {
      expect(value.title, AppStrings.appTitle);
      expect(value.body, AppStrings.progressReminderNotification);
      expect(value.payload, matches(RegExp(r'^checkin:\d+:\d+$')));
      diagnostics.events.add('${value.title} ${value.body} ${value.payload}');
    }
    return values;
  }

  Future<void> reopen(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    router.dispose();
    await tester.pumpAndSettle();
    await db.close();
    db = AppDatabase(NativeDatabase(File(p.join(root.path, 'fixture.sqlite'))));
    _createScope();
    await mount(tester);
  }

  Future<void> capture(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    final image = await tester
        .renderObject<RenderRepaintBoundary>(find.byKey(captureKey))
        .toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      p.join(
        (await getApplicationDocumentsDirectory()).path,
        'aedify_m6_acceptance_$name.png',
      ),
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    router.dispose();
    await native.cancel();
    await native.dispose();
    await db.close();
    await root.delete(recursive: true);
  }
}

abstract final class _AcceptanceUi {
  static Finder get comparedPhotos => find.byWidgetPredicate(
    (widget) =>
        widget is ProgressSavedImage &&
        widget.item.file.type == ProgressMediaItemType.photo &&
        widget.item.file.pose == ProgressMediaPose.front,
  );
  static Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  static Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(ValueKey(key));
    await reveal(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  static Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text);
    await reveal(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  static Future<void> photo(WidgetTester tester, String pose) async {
    await tap(tester, 'photo_action_$pose');
    await tap(tester, 'photo_source_gallery');
  }

  static Future<void> save(WidgetTester tester, String notes) async {
    await reveal(tester, find.byKey(const ValueKey('photo_bodyweight')));
    await tester.enterText(
      find.byKey(const ValueKey('photo_bodyweight')),
      '75',
    );
    await reveal(tester, find.byKey(const ValueKey('photo_notes')));
    await tester.enterText(find.byKey(const ValueKey('photo_notes')), notes);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tap(tester, 'photo_save');
    expect(find.text(AppStrings.progressPhotoSaved), findsOneWidget);
  }
}

class _AcceptancePicker extends ImagePicker {
  _AcceptancePicker(this.root);
  static const name = 'M6_ACCEPTANCE_PRIVATE_SELECTION';
  final Directory root;
  int count = 0;
  bool cancelNext = false;
  @override
  Future<LostDataResponse> retrieveLostData() async => LostDataResponse.empty();
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    expect(requestFullMetadata, isFalse);
    if (cancelNext) {
      cancelNext = false;
      return null;
    }
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawColor(AedifyLightColors.secondary, ui.BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(96, 128);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(p.join(root.path, '${name}_${count++}.png'));
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
    picture.dispose();
    return XFile(file.path);
  }

  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final file = File(p.join(root.path, '${name}_${count++}.mp4'));
    await file.writeAsBytes(base64Decode(_AcceptanceClip.base64Video));
    return XFile(file.path);
  }
}

class _AcceptanceFiles extends LocalFileStore {
  _AcceptanceFiles(String base, AppLogger logger)
    : super(basePath: base, logger: logger);
  String? blocked;
  @override
  Future<void> deleteManagedRelativeFile(String path) async {
    if (path == blocked) {
      throw FileSystemException('M6_ACCEPTANCE_PRIVATE_UNLINK', path);
    }
    return super.deleteManagedRelativeFile(path);
  }
}

class _AcceptanceQueue implements ProgressReminderScheduler {
  _AcceptanceQueue(this.native);
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

class _AcceptanceDiagnostics implements CrashlyticsClient {
  final events = <String>[];
  late final logger = AppLogger(
    sink: (message, {required name, required level, error, stackTrace}) {
      events.add('$name $message $error $stackTrace');
    },
  );
  @override
  void log(String message) => events.add(message);
  @override
  void setCustomKey(String key, String value) => events.add('$key $value');
  @override
  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
  }) async => events.add('$exception $stack $reason');
}

class _AcceptanceNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('M6 acceptance is offline');
  }
}

abstract final class _AcceptanceClip {
  // Synthetic 96x128 H.264, 2 seconds, silent, generated for native codec QA.
  static const base64Video =
      'AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAQhbW9vdgAAAGxtdmhkAAAAAAAAAAAA'
      'AAAAAAAD6AAAB9AAAQAAAQAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA'
      'AABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAA0x0cmFrAAAAXHRraGQAAAADAAAA'
      'AAAAAAAAAAABAAAAAAAAB9AAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABAAAAAAAA'
      'AAAAAAAAAABAAAAAAGAAAACAAAAAAAAkZWR0cwAAABxlbHN0AAAAAAAAAAEAAAfQAAAIAAABAAAA'
      'AALEbWRpYQAAACBtZGhkAAAAAAAAAAAAAAAAAAAoAAAAUABVxAAAAAAALWhkbHIAAAAAAAAAAHZp'
      'ZGUAAAAAAAAAAAAAAABWaWRlb0hhbmRsZXIAAAACb21pbmYAAAAUdm1oZAAAAAEAAAAAAAAAAAAA'
      'ACRkaW5mAAAAHGRyZWYAAAAAAAAAAQAAAAx1cmwgAAAAAQAAAi9zdGJsAAAAv3N0c2QAAAAAAAAA'
      'AQAAAK9hdmMxAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAGAAgABIAAAASAAAAAAAAAABFUxhdmM2'
      'MS4xOS4xMDEgbGlieDI2NAAAAAAAAAAAAAAAGP//AAAANWF2Y0MBZAAK/+EAGGdkAAqs2UYRsBEA'
      'AAMAAQAAAwAUDxIllgEABmjr48siwP34+AAAAAAQcGFzcAAAAAEAAAABAAAAFGJ0cnQAAAAAAAAQ'
      'MAAAAAAAAAAYc3R0cwAAAAAAAAABAAAAFAAABAAAAAAUc3RzcwAAAAAAAAABAAAAAQAAAKhjdHRz'
      'AAAAAAAAABMAAAABAAAIAAAAAAEAABQAAAAAAQAACAAAAAABAAAAAAAAAAEAAAQAAAAAAQAAFAAA'
      'AAABAAAIAAAAAAEAAAAAAAAAAQAABAAAAAABAAAUAAAAAAEAAAgAAAAAAQAAAAAAAAABAAAEAAAA'
      'AAEAABQAAAAAAQAACAAAAAABAAAAAAAAAAEAAAQAAAAAAQAAEAAAAAACAAAEAAAAABxzdHNjAAAA'
      'AAAAAAEAAAABAAAAFAAAAAEAAABkc3RzegAAAAAAAAAAAAAAFAAAAugAAAAQAAAADQAAAA0AAAAN'
      'AAAAFgAAAA8AAAANAAAADQAAABYAAAAPAAAADQAAAA0AAAAVAAAADwAAAA0AAAANAAAAFQAAAA8A'
      'AAANAAAAFHN0Y28AAAAAAAAAAQAABFEAAABhdWR0YQAAAFltZXRhAAAAAAAAACFoZGxyAAAAAAAA'
      'AABtZGlyYXBwbAAAAAAAAAAAAAAAACxpbHN0AAAAJKl0b28AAAAcZGF0YQAAAAEAAAAATGF2ZjYx'
      'LjcuMTAwAAAACGZyZWUAAAQUbWRhdAAAAq4GBf//qtxF6b3m2Ui3lizYINkj7u94MjY0IC0gY29y'
      'ZSAxNjQgcjMxMDggMzFlMTlmOSAtIEguMjY0L01QRUctNCBBVkMgY29kZWMgLSBDb3B5bGVmdCAy'
      'MDAzLTIwMjMgLSBodHRwOi8vd3d3LnZpZGVvbGFuLm9yZy94MjY0Lmh0bWwgLSBvcHRpb25zOiBj'
      'YWJhYz0xIHJlZj0zIGRlYmxvY2s9MTowOjAgYW5hbHlzZT0weDM6MHgxMTMgbWU9aGV4IHN1Ym1l'
      'PTcgcHN5PTEgcHN5X3JkPTEuMDA6MC4wMCBtaXhlZF9yZWY9MSBtZV9yYW5nZT0xNiBjaHJvbWFf'
      'bWU9MSB0cmVsbGlzPTEgOHg4ZGN0PTEgY3FtPTAgZGVhZHpvbmU9MjEsMTEgZmFzdF9wc2tpcD0x'
      'IGNocm9tYV9xcF9vZmZzZXQ9LTIgdGhyZWFkcz00IGxvb2thaGVhZF90aHJlYWRzPTEgc2xpY2Vk'
      'X3RocmVhZHM9MCBucj0wIGRlY2ltYXRlPTEgaW50ZXJsYWNlZD0wIGJsdXJheV9jb21wYXQ9MCBj'
      'b25zdHJhaW5lZF9pbnRyYT0wIGJmcmFtZXM9MyBiX3B5cmFtaWQ9MiBiX2FkYXB0PTEgYl9iaWFz'
      'PTAgZGlyZWN0PTEgd2VpZ2h0Yj0xIG9wZW5fZ29wPTAgd2VpZ2h0cD0yIGtleWludD0yNTAga2V5'
      'aW50X21pbj0xMCBzY2VuZWN1dD00MCBpbnRyYV9yZWZyZXNoPTAgcmNfbG9va2FoZWFkPTQwIHJj'
      'PWNyZiBtYnRyZWU9MSBjcmY9MjMuMCBxY29tcD0wLjYwIHFwbWluPTAgcXBtYXg9NjkgcXBzdGVw'
      'PTQgaXBfcmF0aW89MS40MCBhcT0xOjEuMDAAgAAAADJliIQAEf/+5+P8Cm18xHE6dhj699bXcqLo'
      '14dXFcDFdwx6fsgerNmalyvtjQBnAtSpOwAAAAxBmiRsQR/+tSqAQEAAAAAJQZ5CeId/AI6BAAAA'
      'CQGeYXRDfwDMgAAAAAkBnmNqQ38AzIEAAAASQZpoSahBaJlMCCP//rUqgEBBAAAAC0GehkURLDv/'
      'AI6BAAAACQGepXRDfwDMgQAAAAkBnqdqQ38AzIAAAAASQZqsSahBbJlMCCH//qpVAICAAAAAC0Ge'
      'ykUVLDv/AI6BAAAACQGe6XRDfwDMgAAAAAkBnutqQ38AzIAAAAARQZrwSahBbJlMCH///qmWAdcA'
      'AAALQZ8ORRUsO/8AjoEAAAAJAZ8tdEN/AMyBAAAACQGfL2pDfwDMgAAAABFBmzNJqEFsmUwIb//+'
      'p4QDpgAAAAtBn1FFFSw3/wDMgQAAAAkBn3JqQ38AzIA=';
}
