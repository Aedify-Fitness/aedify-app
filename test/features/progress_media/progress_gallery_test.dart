import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/application/progress_gallery_providers.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/data/progress_gallery_file_service.dart';
import 'package:path/path.dart' as p;
import 'package:aedify/features/progress_media/data/progress_media_repository.dart';
import 'package:aedify/features/progress_media/domain/progress_gallery.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_comparison_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_session_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_components.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _GalleryFixture fixture;
  setUp(() async {
    fixture = await _GalleryFixture.create();
  });
  tearDown(() => fixture.dispose());

  test(
    'comparison presets follow capture order and reject same or stale sessions',
    () async {
      final a = await fixture.save(1, [ProgressMediaPose.front]);
      final b = await fixture.save(2, [ProgressMediaPose.back]);
      final c = await fixture.save(3, [ProgressMediaPose.front]);
      final sessions = await fixture.repository.loadTimeline();
      expect(
        ProgressComparisonPolicy.select(
          sessions,
          ProgressComparisonMode.baselineLatest,
        ),
        (first: a, second: c),
      );
      expect(
        ProgressComparisonPolicy.select(
          sessions,
          ProgressComparisonMode.previousLatest,
        ),
        (first: b, second: c),
      );
      expect(
        ProgressComparisonPolicy.select(
          sessions,
          ProgressComparisonMode.anyTwo,
          first: c,
          second: a,
        ),
        (first: c, second: a),
      );
      expect(
        ProgressComparisonPolicy.select(
          sessions,
          ProgressComparisonMode.anyTwo,
          first: a,
          second: a,
        ),
        isNull,
      );
      expect(
        ProgressComparisonPolicy.select(
          sessions,
          ProgressComparisonMode.anyTwo,
          first: 'removed',
          second: c,
        ),
        isNull,
      );
      await fixture.repository.setBaseline(c);
      expect(
        ProgressComparisonPolicy.select(
          await fixture.repository.loadTimeline(),
          ProgressComparisonMode.baselineLatest,
        ),
        isNull,
      );
    },
  );
  test(
    'timeline cover and angle labels follow pose order, independent of UUIDs',
    () async {
      final id = await fixture.save(1, [
        ProgressMediaPose.rightSide,
        ProgressMediaPose.back,
        ProgressMediaPose.front,
        ProgressMediaPose.leftSide,
      ], video: true);
      final details = (await fixture.repository.getSessionDetails(id))!;
      expect(ProgressGalleryPolicy.originals(details).map((i) => i.file.pose), [
        ProgressMediaPose.front,
        ProgressMediaPose.back,
        ProgressMediaPose.leftSide,
        ProgressMediaPose.rightSide,
        ProgressMediaPose.allSidesVideo,
      ]);
    },
  );
  test(
    'same-pose comparison never pairs different views or video frames',
    () async {
      final a = await fixture.save(1, [
        ProgressMediaPose.front,
        ProgressMediaPose.back,
      ]);
      final b = await fixture.save(2, [
        ProgressMediaPose.front,
        ProgressMediaPose.leftSide,
      ], video: true);
      final first = (await fixture.repository.getSessionDetails(a))!;
      final second = (await fixture.repository.getSessionDetails(b))!;
      final pairs = ProgressComparisonPolicy.photoPairs(first, second);
      expect(pairs.map((p) => p.pose), [ProgressMediaPose.front]);
      expect(pairs.single.first.file.id, isNot(pairs.single.second.file.id));
    },
  );
  test(
    'media, pose and inclusive local-date filters combine without changing records',
    () async {
      await fixture.save(1, [ProgressMediaPose.front]);
      final mixed = await fixture.save(2, [
        ProgressMediaPose.back,
      ], video: true);
      await fixture.save(3, [], video: true);
      final before = await fixture.repository.getStorageUsage();
      const filter = ProgressGalleryFilter(
        type: ProgressMediaType.video,
        pose: ProgressMediaPose.back,
      );
      final sub = fixture.container.listen(
        ProgressGalleryProviders.filteredProvider(filter),
        (_, _) {},
      );
      expect(
        (await fixture.container.read(
          ProgressGalleryProviders.filteredProvider(filter).future,
        )).map((s) => s.id),
        [mixed],
      );
      final session = (await fixture.repository.getSessionDetails(
        mixed,
      ))!.session;
      final local = session.capturedAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      expect(
        ProgressGalleryFilter(from: day, through: day).matches(session),
        isTrue,
      );
      expect(
        ProgressGalleryFilter(
          through: day.subtract(const Duration(days: 1)),
        ).matches(session),
        isFalse,
      );
      expect(
        (await fixture.repository.getStorageUsage()).totalBytes,
        before.totalBytes,
      );
      sub.close();
    },
  );
  test(
    'live baseline and note edits refresh open details and preserve media',
    () async {
      final a = await fixture.save(1, [ProgressMediaPose.front]);
      final b = await fixture.save(2, [ProgressMediaPose.back]);
      final provider = ProgressGalleryProviders.detailProvider(b);
      final sub = fixture.container.listen(provider, (_, _) {});
      await fixture.container.read(provider.future);
      final actions = fixture.container.read(
        ProgressGalleryProviders.actionsProvider,
      );
      expect(await actions.setBaseline(b), isNull);
      expect(await actions.updateNotes(b, 'local-note-sentinel'), isNull);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final details = await fixture.container.read(provider.future);
      expect(details!.session.isBaseline, isTrue);
      expect(details.session.notes, 'local-note-sentinel');
      expect(
        (await fixture.repository.getSessionDetails(a))!.session.isBaseline,
        isFalse,
      );
      expect(details.items, hasLength(1));
      sub.close();
    },
  );
  test(
    'missing/corrupt thumbnail falls back to bounded original without writing files',
    () async {
      final id = await fixture.save(1, [ProgressMediaPose.front]);
      final item = (await fixture.repository.getSessionDetails(
        id,
      ))!.items.single;
      final original = await fixture.files.managedFile(item.file.relativePath);
      final bytes = await original.readAsBytes();
      final service = ProgressGalleryFileService(fixture.files);
      final preview = await service.preview(
        ProgressMediaItem(
          file: item.file,
          fileSizeBytes: bytes.length,
          isFileAvailable: true,
          thumbnailRelativePath: 'temp/no-preview.png',
        ),
      );
      expect(preview, isNotEmpty);
      await original.delete();
      final missing = (await fixture.repository.getSessionDetails(
        id,
      ))!.items.single;
      expect(missing.isFileAvailable, isFalse);
      expect(await service.preview(missing), isNull);
      expect((await fixture.repository.getStorageUsage()).sessionCount, 1);
    },
  );
  test(
    'unsafe and corrupt image reads fail closed with no raw error',
    () async {
      final id = await fixture.save(1, [ProgressMediaPose.front]);
      final item = (await fixture.repository.getSessionDetails(
        id,
      ))!.items.single;
      await fixture.files.writeManagedBytes(
        item.file.relativePath,
        Uint8List.fromList([1, 2, 3]),
      );
      expect(
        await ProgressGalleryFileService(fixture.files).preview(item),
        isNull,
      );
      expect(
        await ProgressGalleryFileService(fixture.files).preview(
          ProgressMediaItem(
            file: item.file,
            fileSizeBytes: 3,
            isFileAvailable: false,
            thumbnailRelativePath: '../private-sentinel',
          ),
        ),
        isNull,
      );
    },
  );
  testWidgets('empty timeline offers capture and disables comparison', (
    tester,
  ) async {
    await fixture.mount(tester);
    expect(find.text(AppStrings.progressEmpty), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey('progress_compare')),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('progress_new')));
    await tester.pumpAndSettle();
    expect(find.byType(ProgressGalleryScreen), findsNothing);
  });
  testWidgets(
    'timeline opens angle-labelled details, imperial snapshot and saved notes',
    (tester) async {
      final id = await tester.runAsync(
        () => fixture.save(1, [
          ProgressMediaPose.front,
          ProgressMediaPose.back,
        ], weight: 100),
      );
      await fixture.mount(tester);
      final card = find.byKey(ValueKey('progress_session_$id'));
      await tester.ensureVisible(card);
      await tester.tap(
        find.descendant(of: card, matching: find.byType(Text)).first,
      );
      await fixture.settle(tester);
      expect(find.text('Bodyweight: 220.5 lbs'), findsOneWidget);
      expect(find.text(AppStrings.progressPhotoDetails), findsOneWidget);
      await tester.tap(find.text(AppStrings.progressEditNotes));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('saved_notes')),
        'my local check-in',
      );
      await tester.tap(find.text(AppStrings.save));
      await fixture.settle(tester);
      expect(find.text('my local check-in'), findsOneWidget);
      expect(
        (await tester.runAsync(
          () => fixture.repository.getSessionDetails(id!),
        ))!.session.notes,
        'my local check-in',
      );
    },
  );
  testWidgets('failed notes save preserves text and exposes safe retry', (
    tester,
  ) async {
    final id = await tester.runAsync(
      () => fixture.save(1, [ProgressMediaPose.front]),
    );
    await fixture.mount(
      tester,
      location: AppRoutes.progressSession().path.replaceFirst(':id', id!),
    );
    await tester.tap(find.text(AppStrings.progressEditNotes));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('saved_notes')),
      'retry-local-note',
    );
    fixture.uiRepository!.failNotes = true;
    await tester.tap(find.text(AppStrings.save));
    await fixture.settle(tester);
    expect(find.text(AppErrorStrings.progressMediaUnavailable), findsOneWidget);
    expect(find.textContaining('private-sql-sentinel'), findsNothing);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('saved_notes')))
          .controller!
          .text,
      'retry-local-note',
    );
    fixture.uiRepository!.failNotes = false;
    await tester.tap(find.text(AppStrings.save));
    await fixture.settle(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('retry-local-note'), findsOneWidget);
  });
  testWidgets(
    'comparison switches presets and arbitrary sessions without cross-pose fallback',
    (tester) async {
      await tester.runAsync(() => fixture.save(1, [ProgressMediaPose.front]));
      await tester.runAsync(() => fixture.save(2, [ProgressMediaPose.back]));
      await tester.runAsync(() => fixture.save(3, [ProgressMediaPose.front]));
      await fixture.mount(tester, location: AppRoutes.progressCompare().path);
      expect(find.byType(ProgressSavedImage), findsNWidgets(2));
      await tester.tap(find.byKey(const ValueKey('compare_previousLatest')));
      await fixture.settle(tester);
      expect(find.text(AppStrings.progressNoMatchingPose), findsOneWidget);
      expect(find.byType(ProgressSavedImage), findsNothing);
      await tester.tap(find.byKey(const ValueKey('compare_anyTwo')));
      await fixture.settle(tester);
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
    },
  );
  testWidgets('missing original keeps date and notes accessible', (
    tester,
  ) async {
    final id = await tester.runAsync(
      () => fixture.save(1, [ProgressMediaPose.front]),
    );
    final detail = (await tester.runAsync(
      () => fixture.repository.getSessionDetails(id!),
    ))!;
    await tester.runAsync(
      () async => (await fixture.files.managedFile(
        detail.items.single.file.relativePath,
      )).delete(),
    );
    await fixture.mount(
      tester,
      location: AppRoutes.progressSession().path.replaceFirst(':id', id!),
    );
    expect(find.text(AppErrorStrings.progressSavedMissing), findsOneWidget);
    expect(find.text(AppStrings.progressEditNotes), findsOneWidget);
  });
  testWidgets('pose filter shows no matches and clears back to the timeline', (
    tester,
  ) async {
    await tester.runAsync(() => fixture.save(1, [ProgressMediaPose.front]));
    await fixture.mount(tester);
    await tester.tap(find.text(AppStrings.filters));
    await tester.pumpAndSettle();
    final pose = find.byType(DropdownButtonFormField<ProgressMediaPose>);
    await tester.ensureVisible(pose);
    await tester.tap(pose);
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.progressPhotoLeft).last);
    await fixture.settle(tester);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.progressNoMatches), findsOneWidget);
    await tester.ensureVisible(find.text(AppStrings.clearFilters));
    await tester.tap(find.text(AppStrings.clearFilters));
    await fixture.settle(tester);
    expect(find.text(AppStrings.progressNoMatches), findsNothing);
  });
  testWidgets('gallery stream error hides private details and retry recovers', (
    tester,
  ) async {
    await fixture.mount(tester);
    fixture.uiRepository!.failTimeline = true;
    fixture.uiRepository!._changes.add(null);
    await fixture.settle(tester);
    expect(find.text(AppErrorStrings.progressMediaUnavailable), findsOneWidget);
    expect(find.textContaining('private-error-sentinel'), findsNothing);
    fixture.uiRepository!.failTimeline = false;
    await tester.tap(find.text(AppStrings.retry));
    await fixture.settle(tester);
    expect(find.text(AppStrings.progressEmpty), findsOneWidget);
  });
  for (final screen in ['gallery', 'detail', 'compare']) {
    for (final dark in [false, true]) {
      testWidgets(
        '320px large-text ${dark ? 'dark' : 'light'} $screen has no overflow',
        (tester) async {
          await tester.runAsync(
            () => fixture.save(1, [ProgressMediaPose.front]),
          );
          final latest = await tester.runAsync(
            () => fixture.save(2, [ProgressMediaPose.front]),
          );
          tester.view.physicalSize = const Size(320, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await fixture.mount(
            tester,
            location: screen == 'gallery'
                ? AppRoutes.progress().path
                : screen == 'detail'
                ? AppRoutes.progressSession().path.replaceFirst(':id', latest!)
                : AppRoutes.progressCompare().path,
            dark: dark,
            textScale: 2,
          );
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -500),
          );
          await fixture.settle(tester);
          expect(tester.takeException(), isNull);
          if (screen == 'compare') {
            expect(find.byType(ProgressSavedImage), findsNWidgets(2));
          }
        },
      );
    }
  }
}

class _GalleryFixture {
  _GalleryFixture(this.root, this.db, this.files, this.container);
  final Directory root;
  final AppDatabase db;
  final LocalFileStore files;
  ProviderContainer container;
  _UiRepository? uiRepository;
  GoRouter? router;
  ProgressMediaRepository get repository =>
      container.read(ProgressMediaProviders.repositoryProvider);
  static Future<_GalleryFixture> create() async {
    final root = await Directory.systemTemp.createTemp('m6_gallery_');
    final db = AppDatabase(NativeDatabase.memory());
    final files = LocalFileStore(basePath: root.path);
    final container = ProviderContainer(
      overrides: [
        AppProviders.appDatabaseProvider.overrideWithValue(db),
        AppProviders.localFileStoreProvider.overrideWithValue(files),
        ProgressPhotoProviders.unitsProvider.overrideWith(
          (_) async => PreferredUnit.imperial,
        ),
      ],
    );
    return _GalleryFixture(root, db, files, container);
  }

  Future<String> save(
    int day,
    List<ProgressMediaPose> poses, {
    bool video = false,
    double? weight,
  }) async {
    final id = const Uuid().v4();
    final items = <ProgressMediaFileDraft>[];
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawColor(AedifyLightColors.secondary, ui.BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(48, 64);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    for (final pose in [...poses, if (video) ProgressMediaPose.allSidesVideo]) {
      final itemId = const Uuid().v4();
      final path = p.join(
        'media',
        'progress',
        'sessions',
        id,
        'originals',
        '$itemId${pose == ProgressMediaPose.allSidesVideo ? '.mp4' : '.png'}',
      );
      await files.writeManagedBytes(path, data!.buffer.asUint8List());
      items.add(
        ProgressMediaFileDraft(
          id: itemId,
          type: pose == ProgressMediaPose.allSidesVideo
              ? ProgressMediaItemType.video
              : ProgressMediaItemType.photo,
          pose: pose,
          source: ProgressMediaSource.gallery,
          relativePath: path,
          durationSeconds: pose == ProgressMediaPose.allSidesVideo ? 2 : null,
          width: 48,
          height: 64,
        ),
      );
    }
    await repository.saveSession(
      ProgressMediaSessionDraft(
        id: id,
        capturedAt: DateTime.utc(2026, 10, day, 12),
        items: items,
        bodyweightKg: weight,
      ),
    );
    return id;
  }

  Future<void> mount(
    WidgetTester tester, {
    String? location,
    bool dark = false,
    double textScale = 1,
  }) async {
    final details = await tester.runAsync(() async {
      final sessions = await repository.loadTimeline();
      return [
        for (final session in sessions)
          (await repository.getSessionDetails(session.id))!,
      ];
    });
    final png = await tester.runAsync(() async {
      final all = details!
          .expand((d) => d.items)
          .where(
            (i) =>
                i.file.type == ProgressMediaItemType.photo && i.isFileAvailable,
          );
      if (all.isEmpty) return null;
      return (await files.managedFile(
        all.first.file.relativePath,
      )).readAsBytes();
    });
    uiRepository = _UiRepository(details!);
    container.dispose();
    container = ProviderContainer(
      overrides: [
        ProgressMediaProviders.repositoryProvider.overrideWithValue(
          uiRepository!,
        ),
        ProgressGalleryProviders.imageProvider.overrideWith(
          (_, _) async => png,
        ),
        ProgressPhotoProviders.unitsProvider.overrideWith(
          (_) async => PreferredUnit.imperial,
        ),
      ],
    );
    router = GoRouter(
      initialLocation: location ?? AppRoutes.progress().path,
      routes: [
        GoRoute(
          path: AppRoutes.progress().path,
          name: AppRoutes.progress().name,
          builder: (_, _) => const ProgressGalleryScreen(),
        ),
        GoRoute(
          path: AppRoutes.progressCapture().path,
          name: AppRoutes.progressCapture().name,
          builder: (_, _) =>
              const Scaffold(body: Text(AppStrings.progressNewSession)),
        ),
        GoRoute(
          path: AppRoutes.progressCompare().path,
          name: AppRoutes.progressCompare().name,
          builder: (_, _) => const ProgressComparisonScreen(),
        ),
        GoRoute(
          path: AppRoutes.progressSession().path,
          name: AppRoutes.progressSession().name,
          builder: (_, state) =>
              ProgressSessionScreen(sessionId: state.pathParameters['id']!),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> dispose() async {
    router?.dispose();
    container.dispose();
    await uiRepository?._changes.close();
    await db.close();
    await root.delete(recursive: true);
  }
}

/// UI tests use deterministic memory state; real SQLite and file behavior is covered above and in the native smoke.
class _UiRepository implements ProgressMediaRepository {
  _UiRepository(List<ProgressMediaSessionDetails> initial)
    : details = {for (final d in initial) d.session.id: d};
  final Map<String, ProgressMediaSessionDetails> details;
  final _changes = StreamController<void>.broadcast(sync: true);
  bool failNotes = false;
  bool failTimeline = false;
  @override
  Future<List<ProgressMediaSession>> loadTimeline() async =>
      details.values.map((d) => d.session).toList()
        ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
  @override
  Stream<List<ProgressMediaSession>> watchTimeline() async* {
    if (failTimeline) throw StateError('private-error-sentinel');
    yield await loadTimeline();
    await for (final _ in _changes.stream) {
      if (failTimeline) throw StateError('private-error-sentinel');
      yield await loadTimeline();
    }
  }

  @override
  Future<ProgressMediaSessionDetails?> getSessionDetails(String id) async =>
      details[id];
  @override
  Future<void> updateNotes(String id, String? notes) async {
    if (failNotes) throw StateError('private-sql-sentinel');
    _replace(id, notes: notes);
    _changes.add(null);
  }

  @override
  Future<void> setBaseline(String id) async {
    for (final key in details.keys.toList()) {
      _replace(key, baseline: key == id);
    }
    _changes.add(null);
  }

  void _replace(String id, {String? notes, bool? baseline}) {
    final d = details[id]!;
    final s = d.session;
    details[id] = ProgressMediaSessionDetails(
      session: ProgressMediaSession(
        id: s.id,
        capturedAt: s.capturedAt,
        mediaType: s.mediaType,
        isBaseline: baseline ?? s.isBaseline,
        isCompletePoseSet: s.isCompletePoseSet,
        storageSizeBytes: s.storageSizeBytes,
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
        notes: notes ?? s.notes,
        bodyweightKg: s.bodyweightKg,
      ),
      items: d.items,
      measurements: d.measurements,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
