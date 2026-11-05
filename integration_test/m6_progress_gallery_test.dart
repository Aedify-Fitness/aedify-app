import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/application/progress_gallery_providers.dart';
import 'package:aedify/features/progress_media/application/progress_video_providers.dart';
import 'package:aedify/features/progress_media/data/progress_video_metadata_service.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_comparison_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_components.dart';
import 'package:aedify/features/progress_media/presentation/progress_session_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
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
    'offline saved gallery, comparisons, notes, baseline, missing files and native video playback',
    (tester) async {
      final prior = HttpOverrides.current;
      final network = _GalleryNetwork();
      HttpOverrides.global = network;
      final root = await (await getTemporaryDirectory()).createTemp(
        'm6_gallery_native_',
      );
      var db = AppDatabase(
        NativeDatabase(File(p.join(root.path, 'fixture.sqlite'))),
      );
      final files = LocalFileStore(basePath: p.join(root.path, 'sandbox'));
      var container = ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          AppProviders.localFileStoreProvider.overrideWithValue(files),
          ProgressPhotoProviders.unitsProvider.overrideWith(
            (_) async => PreferredUnit.imperial,
          ),
        ],
      );
      final repository = container.read(
        ProgressMediaProviders.repositoryProvider,
      );
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawColor(AedifyLightColors.secondary, ui.BlendMode.src);
      canvas.drawRect(
        const ui.Rect.fromLTWH(12, 16, 24, 32),
        ui.Paint()..color = AedifyLightColors.surface,
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(48, 64);
      final png = (await image.toByteData(
        format: ui.ImageByteFormat.png,
      ))!.buffer.asUint8List();
      image.dispose();
      picture.dispose();
      final videoBytes = base64Decode(_GalleryClip.base64Video);
      await files.writeManagedBytes('temp/probe.mp4', videoBytes);
      final metadata = await NativeProgressVideoMetadataService(
        files,
      ).inspect('temp/probe.mp4', const ProgressVideoLimits());
      final ids = <String>[];
      String? latestVideo;
      for (var day = 1; day <= 3; day++) {
        final id = const Uuid().v4();
        ids.add(id);
        final items = <ProgressMediaFileDraft>[];
        for (final pose
            in day == 2
                ? [ProgressMediaPose.back]
                : [ProgressMediaPose.front, ProgressMediaPose.back]) {
          final photoId = const Uuid().v4();
          final path = p.join(
            'media',
            'progress',
            'sessions',
            id,
            'originals',
            '$photoId.png',
          );
          await files.writeManagedBytes(path, png);
          items.add(
            ProgressMediaFileDraft(
              id: photoId,
              type: ProgressMediaItemType.photo,
              pose: pose,
              source: ProgressMediaSource.gallery,
              relativePath: path,
              width: 48,
              height: 64,
            ),
          );
        }
        if (day != 2) {
          final videoId = const Uuid().v4();
          final thumbId = const Uuid().v4();
          final path = p.join(
            'media',
            'progress',
            'sessions',
            id,
            'originals',
            '$videoId.mp4',
          );
          latestVideo = path;
          final thumbPath = p.join(
            'media',
            'progress',
            'sessions',
            id,
            'thumbnails',
            '$thumbId.png',
          );
          await files.writeManagedBytes(path, videoBytes);
          await files.writeManagedBytes(thumbPath, metadata.thumbnail!);
          items.add(
            ProgressMediaFileDraft(
              id: videoId,
              type: ProgressMediaItemType.video,
              pose: ProgressMediaPose.allSidesVideo,
              source: ProgressMediaSource.gallery,
              relativePath: path,
              width: 96,
              height: 128,
              durationSeconds: 2,
            ),
          );
          items.add(
            ProgressMediaFileDraft(
              id: thumbId,
              type: ProgressMediaItemType.thumbnail,
              pose: ProgressMediaPose.allSidesVideo,
              source: ProgressMediaSource.generatedThumbnail,
              sourceMediaItemId: videoId,
              relativePath: thumbPath,
              width: 96,
              height: 128,
            ),
          );
        }
        await repository.saveSession(
          ProgressMediaSessionDraft(
            id: id,
            capturedAt: DateTime.utc(2026, 10, day, 12),
            items: items,
            notes: day == 3 ? 'Synthetic check-in' : null,
            bodyweightKg: 100,
          ),
        );
      }
      final router = GoRouter(
        initialLocation: AppRoutes.progress().path,
        routes: [
          GoRoute(
            path: AppRoutes.progress().path,
            name: AppRoutes.progress().name,
            builder: (_, _) => const ProgressGalleryScreen(),
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
      var dark = false;
      Future<void> mount() => tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(
            key: _GallerySmoke.captureKey,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              routerConfig: router,
            ),
          ),
        ),
      );
      try {
        await mount();
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.progressTimeline), findsOneWidget);
        await _GallerySmoke.capture(tester, 'timeline_light');
        dark = true;
        await mount();
        await tester.pumpAndSettle();
        await _GallerySmoke.capture(tester, 'timeline_dark');
        await tester.tap(find.byKey(const ValueKey('progress_compare')));
        await tester.pumpAndSettle();
        expect(find.byType(ProgressSavedImage), findsNWidgets(6));
        await _GallerySmoke.capture(tester, 'compare_dark');
        dark = false;
        await mount();
        await tester.pumpAndSettle();
        await _GallerySmoke.capture(tester, 'compare_light');
        await tester.tap(find.byKey(const ValueKey('compare_previousLatest')));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.bodymapFront), findsNothing);
        expect(find.text(AppStrings.bodymapBack), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('compare_anyTwo')));
        await tester.pumpAndSettle();
        final selectors = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(selectors.first);
        await tester.tap(selectors.first);
        await tester.pumpAndSettle();
        await tester.tap(
          find
              .text(
                ProgressGalleryLabels.session(
                  (await repository.getSessionDetails(ids.first))!.session,
                ),
              )
              .last,
        );
        await tester.pumpAndSettle();
        expect(find.byType(ProgressSavedImage), findsNWidgets(6));
        router.goNamed(
          AppRoutes.progressSession().name,
          pathParameters: {'id': ids.last},
        );
        await tester.pumpAndSettle();
        expect(find.text('Bodyweight: 220.5 lbs'), findsOneWidget);
        await tester.tap(find.text(AppStrings.progressEditNotes));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('saved_notes')),
          'Synthetic edited note',
        );
        await tester.tap(find.text(AppStrings.save));
        await tester.pumpAndSettle();
        expect(
          (await repository.getSessionDetails(ids.last))!.session.notes,
          'Synthetic edited note',
        );
        final play = find.text(AppStrings.progressPlayVideo);
        await _GallerySmoke.reveal(tester, play);
        await tester.tap(play);
        await tester.pumpAndSettle();
        final playback = await container.read(
          ProgressVideoProviders.previewProvider(latestVideo!).future,
        );
        expect(playback.player.value.volume, 0);
        expect(playback.player.value.isPlaying, isFalse);
        await playback.player.play();
        await tester.pump(const Duration(milliseconds: 600));
        await playback.player.pause();
        expect(playback.player.value.position, greaterThan(Duration.zero));
        await _GallerySmoke.capture(tester, 'saved_video');
        router.goNamed(
          AppRoutes.progressSession().name,
          pathParameters: {'id': ids[1]},
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.progressSetBaseline));
        await tester.pumpAndSettle();
        expect((await repository.getBaselineSession())!.id, ids[1]);
        final missing = (await repository.getSessionDetails(
          ids[1],
        ))!.items.single;
        await (await files.managedFile(missing.file.relativePath)).delete();
        container.invalidate(ProgressGalleryProviders.detailProvider(ids[1]));
        await tester.pumpAndSettle();
        expect(find.text(AppErrorStrings.progressSavedMissing), findsOneWidget);
        expect(find.text(AppStrings.progressEditNotes), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        await db.close();
        db = AppDatabase(
          NativeDatabase(File(p.join(root.path, 'fixture.sqlite'))),
        );
        container = ProviderContainer(
          overrides: [
            AppProviders.appDatabaseProvider.overrideWithValue(db),
            AppProviders.localFileStoreProvider.overrideWithValue(files),
          ],
        );
        final reopened = container.read(
          ProgressMediaProviders.repositoryProvider,
        );
        expect((await reopened.getBaselineSession())!.id, ids[1]);
        expect(
          (await reopened.getSessionDetails(ids.last))!.session.notes,
          'Synthetic edited note',
        );
        expect(
          await (db.select(
            db.progressMediaItems,
          )..where((i) => i.type.equals('video_frame'))).get(),
          isEmpty,
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

abstract final class _GallerySmoke {
  static final captureKey = GlobalKey();
  static Future<void> reveal(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
  }

  static Future<void> capture(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    final image = await tester
        .renderObject<RenderRepaintBoundary>(find.byKey(captureKey))
        .toImage();
    final bytes = (await image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    final directory = await getApplicationDocumentsDirectory();
    await File(
      p.join(directory.path, 'aedify_m6_gallery_$name.png'),
    ).writeAsBytes(bytes);
    image.dispose();
  }
}

class _GalleryNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Gallery smoke must stay offline');
  }
}

abstract final class _GalleryClip {
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
