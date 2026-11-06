import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/application/progress_deletion_providers.dart';
import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/application/progress_video_providers.dart';
import 'package:aedify/features/progress_media/application/progress_reminder_providers.dart';
import 'package:aedify/features/progress_media/data/drift_progress_media_repository.dart';
import 'package:aedify/features/progress_media/data/progress_reminder_repository.dart';
import 'package:aedify/features/progress_media/data/progress_reminder_scheduler.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_session_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_storage_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'offline confirmed deletion, native playing-video disposal, pending cleanup and restart recovery',
    (tester) async {
      final prior = HttpOverrides.current;
      final network = _DeleteNetwork();
      HttpOverrides.global = network;
      final root = await (await getTemporaryDirectory()).createTemp(
        'm6_deletion_native_',
      );
      final file = File(p.join(root.path, 'fixture.sqlite'));
      var db = AppDatabase(NativeDatabase(file));
      final files = _NativeDeletionFiles(p.join(root.path, 'sandbox'));
      final clock = DateTime.now().toUtc();
      final recorder = ui.PictureRecorder();
      ui.Canvas(
        recorder,
      ).drawColor(AedifyLightColors.secondary, ui.BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(48, 64);
      final png = (await image.toByteData(
        format: ui.ImageByteFormat.png,
      ))!.buffer.asUint8List();
      image.dispose();
      picture.dispose();
      Future<String> seed(bool mixed, DateTime captured) async {
        final session = const Uuid().v4();
        final items = <ProgressMediaFileDraft>[];
        Future<String> add(
          ProgressMediaItemType type,
          ProgressMediaPose pose, {
          String? parent,
        }) async {
          final id = const Uuid().v4();
          final folder = type.isOriginal
              ? 'originals'
              : type == ProgressMediaItemType.videoFrame
              ? 'frames'
              : 'thumbnails';
          final path = p.posix.join(
            'media',
            'progress',
            'sessions',
            session,
            folder,
            '$id${type == ProgressMediaItemType.video ? '.mp4' : '.png'}',
          );
          await files.writeManagedBytes(
            path,
            type == ProgressMediaItemType.video
                ? base64Decode(_DeletionClip.base64Video)
                : png,
          );
          items.add(
            ProgressMediaFileDraft(
              id: id,
              type: type,
              pose: pose,
              source: type.isOriginal
                  ? ProgressMediaSource.gallery
                  : type == ProgressMediaItemType.videoFrame
                  ? ProgressMediaSource.extractedFrame
                  : ProgressMediaSource.generatedThumbnail,
              sourceMediaItemId: parent,
              relativePath: path,
              durationSeconds: type == ProgressMediaItemType.video ? 2 : null,
              width: 48,
              height: 64,
            ),
          );
          return id;
        }

        final photo = await add(
          ProgressMediaItemType.photo,
          ProgressMediaPose.front,
        );
        await add(
          ProgressMediaItemType.thumbnail,
          ProgressMediaPose.front,
          parent: photo,
        );
        if (mixed) {
          final video = await add(
            ProgressMediaItemType.video,
            ProgressMediaPose.allSidesVideo,
          );
          await add(
            ProgressMediaItemType.thumbnail,
            ProgressMediaPose.allSidesVideo,
            parent: video,
          );
          final frame = await add(
            ProgressMediaItemType.videoFrame,
            ProgressMediaPose.front,
            parent: video,
          );
          await add(
            ProgressMediaItemType.thumbnail,
            ProgressMediaPose.front,
            parent: frame,
          );
        }
        await DriftProgressMediaRepository(
          database: db,
          fileStore: files,
          now: () => clock,
        ).saveSession(
          ProgressMediaSessionDraft(
            id: session,
            capturedAt: captured,
            notes: 'private-native-delete-note',
            measurements: ProgressMeasurementSnapshot(
              measuredAt: captured,
              waistCm: 80,
            ),
            items: items,
          ),
        );
        return session;
      }

      final mixed = await seed(true, clock);
      final other = await seed(false, clock.subtract(const Duration(days: 14)));
      await ProgressReminderRepository(
        db,
      ).choose(ProgressReminderCadence.monthly, clock);
      final repository = DriftProgressMediaRepository(
        database: db,
        fileStore: files,
      );
      final details = (await repository.getSessionDetails(mixed))!;
      final video = details.items.firstWhere(
        (i) => i.file.type == ProgressMediaItemType.video,
      );
      final photo = details.items.firstWhere(
        (i) => i.file.type == ProgressMediaItemType.photo,
      );
      await files.writeManagedBytes(
        'media/unrelated-fixture.bin',
        Uint8List.fromList([9, 8, 7]),
      );
      ProviderContainer makeContainer() => ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          AppProviders.localFileStoreProvider.overrideWithValue(files),
          ProgressPhotoProviders.unitsProvider.overrideWith(
            (_) async => PreferredUnit.metric,
          ),
          ProgressReminderProviders.schedulerProvider.overrideWithValue(
            _DeleteReminderScheduler(),
          ),
        ],
      );
      var container = makeContainer();
      final router = GoRouter(
        initialLocation: AppRoutes.progressSession().path.replaceFirst(
          ':id',
          mixed,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.progress().path,
            name: AppRoutes.progress().name,
            builder: (_, _) => const ProgressGalleryScreen(),
          ),
          GoRoute(
            path: AppRoutes.progressSession().path,
            name: AppRoutes.progressSession().name,
            builder: (_, s) =>
                ProgressSessionScreen(sessionId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: AppRoutes.progressStorage().path,
            name: AppRoutes.progressStorage().name,
            builder: (_, _) => const ProgressStorageScreen(),
          ),
        ],
      );
      var dark = false;
      Future<void> mount() => tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(
            key: _DeletionSmoke.key,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              routerConfig: router,
            ),
          ),
        ),
      );
      Future<void> settle() async {
        await container
            .read(ProgressDeletionProviders.serviceProvider)
            .status();
        await tester.pumpAndSettle();
      }

      try {
        await mount();
        await tester.pumpAndSettle();
        final play = find.byKey(ValueKey('saved_video_${video.file.id}'));
        await _DeletionSmoke.reveal(tester, play);
        await tester.tap(play);
        await tester.pumpAndSettle();
        final playback = await container.read(
          ProgressVideoProviders.previewProvider(
            video.file.relativePath,
          ).future,
        );
        await playback.player.play();
        await tester.pump(const Duration(milliseconds: 400));
        final deleteVideo = find.byKey(
          ValueKey('progress_delete_${video.file.id}'),
        );
        await _DeletionSmoke.reveal(tester, deleteVideo);
        await tester.tap(deleteVideo);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        await _DeletionSmoke.capture(tester, 'video_confirm_light');
        await tester.tap(find.text(AppStrings.cancel));
        await tester.pumpAndSettle();
        expect(await files.statManagedFile(video.file.relativePath), isNotNull);
        await tester.tap(deleteVideo);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('progress_confirm_delete')));
        await settle();
        expect(await files.statManagedFile(video.file.relativePath), isNull);
        final remaining = (await repository.getSessionDetails(mixed))!;
        expect(remaining.items, hasLength(2));
        expect(remaining.session.mediaType, ProgressMediaType.photoSet);
        expect(find.text(AppStrings.progressVideoTitle), findsNothing);
        expect(tester.takeException(), isNull);
        files.failPaths.add(photo.file.relativePath);
        final deleteSession = find.byKey(ValueKey('progress_delete_$mixed'));
        await _DeletionSmoke.reveal(tester, deleteSession);
        await tester.tap(deleteSession);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('progress_confirm_delete')));
        await settle();
        expect(await repository.getSessionDetails(mixed), isNull);
        expect((await repository.getBaselineSession())!.id, other);
        expect(
          (await ProgressReminderRepository(db).load()).reminder.lastSessionAt,
          (await repository.getSessionDetails(other))!.session.capturedAt,
        );
        router.goNamed(AppRoutes.progressStorage().name);
        await tester.pumpAndSettle();
        await settle();
        expect(
          find.text(AppErrorStrings.progressCleanupPending),
          findsOneWidget,
        );
        await _DeletionSmoke.capture(tester, 'pending_light');
        dark = true;
        await mount();
        await tester.pumpAndSettle();
        await _DeletionSmoke.capture(tester, 'pending_dark');
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        await db.close();
        db = AppDatabase(NativeDatabase(file));
        files.failPaths.clear();
        container = makeContainer();
        final recovered = await container
            .read(ProgressDeletionProviders.serviceProvider)
            .recover();
        expect(recovered.pending, isFalse);
        expect(await files.statManagedFile(photo.file.relativePath), isNull);
        await mount();
        await tester.pumpAndSettle();
        await settle();
        expect(find.text(AppErrorStrings.progressCleanupPending), findsNothing);
        final all = find.byKey(const ValueKey('progress_delete_all'));
        await _DeletionSmoke.reveal(tester, all);
        await tester.tap(all);
        await tester.pumpAndSettle();
        await _DeletionSmoke.capture(tester, 'all_confirm_dark');
        await tester.tap(find.byKey(const ValueKey('progress_confirm_delete')));
        await settle();
        expect(await db.select(db.progressMediaSessions).get(), isEmpty);
        expect(await db.select(db.progressMediaItems).get(), isEmpty);
        expect(await db.select(db.progressMeasurementSnapshots).get(), isEmpty);
        expect(await db.select(db.localFileRecords).get(), isEmpty);
        expect(
          await db.select(db.progressMediaReminderSettings).get(),
          isEmpty,
        );
        expect(await files.readManagedBytes('media/unrelated-fixture.bin'), [
          9,
          8,
          7,
        ]);
        expect(
          (await container
                  .read(ProgressDeletionProviders.serviceProvider)
                  .recover())
              .pending,
          isFalse,
        );
        expect(network.attempts, 0);
      } finally {
        await tester.pumpWidget(const SizedBox());
        router.dispose();
        container.dispose();
        await db.close();
        await root.delete(recursive: true);
        HttpOverrides.global = prior;
      }
    },
  );
}

class _NativeDeletionFiles extends LocalFileStore {
  _NativeDeletionFiles(String path) : super(basePath: path);
  final failPaths = <String>{};
  @override
  Future<void> deleteManagedRelativeFile(String path) async {
    if (failPaths.contains(path)) {
      throw FileSystemException('private-native-delete-failure', path);
    }
    await super.deleteManagedRelativeFile(path);
  }
}

class _DeleteReminderScheduler implements ProgressReminderScheduler {
  @override
  Stream<ProgressReminderEvent> get events => const Stream.empty();
  @override
  Future<ProgressReminderEvent?> initialize() async => null;
  @override
  Future<bool?> permission({bool request = false}) async => true;
  @override
  Future<void> cancel() async {}
  @override
  Future<void> replace(List<DateTime> dates, DateTime generation) async {}
}

abstract final class _DeletionSmoke {
  static final key = GlobalKey();
  static Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

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
      p.join(dir.path, 'aedify_m6_delete_$name.png'),
    ).writeAsBytes(bytes);
  }
}

class _DeleteNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Deletion smoke stays offline');
  }
}

abstract final class _DeletionClip {
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
