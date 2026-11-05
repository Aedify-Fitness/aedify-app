import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/data/progress_photo_picker.dart';
import 'package:aedify/features/progress_media/data/progress_video_metadata_service.dart';
import 'package:aedify/features/progress_media/data/progress_video_picker.dart';
import 'package:aedify/features/progress_media/application/progress_video_providers.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:aedify/features/progress_media/presentation/progress_media_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'offline native video metadata, bounded thumbnail, playback and mixed/video-only saves',
    (tester) async {
      final prior = HttpOverrides.current;
      final network = _BlockedNetwork();
      HttpOverrides.global = network;
      addTearDown(() => HttpOverrides.global = prior);
      final root = await (await getTemporaryDirectory()).createTemp(
        'm6_video_smoke_',
      );
      final dbFile = File(p.join(root.path, 'fixture.sqlite'));
      var db = AppDatabase(NativeDatabase(dbFile));
      final files = LocalFileStore(basePath: p.join(root.path, 'sandbox'));
      final picker = _VideoSmokePicker(root);
      await files.writeManagedBytes(
        'temp/probe.mp4',
        base64Decode(_ClipFixture.base64Video),
      );
      final metadata = NativeProgressVideoMetadataService(files);
      final probe = await metadata.inspect(
        'temp/probe.mp4',
        const ProgressVideoLimits(),
      );
      expect(probe.duration.inMilliseconds, inInclusiveRange(1900, 2100));
      expect(probe.width, 96);
      expect(probe.height, 128);
      expect(probe.thumbnail, isNotNull);
      expect(probe.thumbnail, isNotEmpty);
      final codec = await ui.instantiateImageCodec(probe.thumbnail!);
      final image = (await codec.getNextFrame()).image;
      expect(image.width, lessThanOrEqualTo(512));
      expect(image.height, lessThanOrEqualTo(512));
      image.dispose();
      codec.dispose();
      await expectLater(
        metadata.inspect(
          'temp/probe.mp4',
          const ProgressVideoLimits(maxDuration: Duration(seconds: 1)),
        ),
        throwsA(ProgressVideoFailure.tooLong),
      );
      await expectLater(
        metadata.inspect(
          'temp/probe.mp4',
          const ProgressVideoLimits(maxBytes: 1),
        ),
        throwsA(ProgressVideoFailure.tooLarge),
      );
      try {
        await NativeProgressVideoMetadataService.channel
            .invokeMethod('inspect', {
              'path': 'https://private-sentinel.invalid/video.mp4',
              'maxDurationMs': 60000,
              'maxBytes': 104857600,
              'thumbnailEdge': 512,
            });
        fail('Remote input must be rejected');
      } on PlatformException catch (error) {
        expect(error.code, 'invalid');
        expect(error.message, isNull);
        expect(error.details, isNull);
      }

      for (final mixed in [false, true]) {
        final container = ProviderContainer(
          overrides: [
            AppProviders.appDatabaseProvider.overrideWithValue(db),
            AppProviders.localFileStoreProvider.overrideWithValue(files),
            ProgressPhotoProviders.unitsProvider.overrideWith(
              (ref) async => PreferredUnit.metric,
            ),
            ProgressPhotoProviders.pickerProvider.overrideWithValue(
              ImagePickerProgressPhotoPicker(files: files, picker: picker),
            ),
            ProgressVideoProviders.pickerProvider.overrideWithValue(
              ImagePickerProgressVideoPicker(files: files, picker: picker),
            ),
          ],
        );
        final router = GoRouter(
          initialLocation: AppRoutes.progress().path,
          routes: [
            GoRoute(
              path: AppRoutes.home().path,
              name: AppRoutes.home().name,
              builder: (_, _) => const Scaffold(),
            ),
            GoRoute(
              path: AppRoutes.progress().path,
              name: AppRoutes.progress().name,
              builder: (_, _) => const ProgressMediaScreen(),
            ),
          ],
        );
        var dark = false;
        Future<void> mount() => tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: RepaintBoundary(
              key: _VideoSmoke.captureKey,
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                routerConfig: router,
              ),
            ),
          ),
        );
        await mount();
        await tester.pumpAndSettle();
        if (mixed) {
          await _VideoSmoke.reveal(
            tester,
            find.byKey(const ValueKey('photo_action_front')),
          );
          await tester.tap(find.byKey(const ValueKey('photo_action_front')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('photo_source_camera')));
          await tester.pumpAndSettle();
        }
        await _VideoSmoke.reveal(
          tester,
          find.byKey(const ValueKey('video_limit_30')),
        );
        await tester.tap(find.byKey(const ValueKey('video_limit_30')));
        await tester.pumpAndSettle();
        await _VideoSmoke.choose(tester);
        final state = container
            .read(ProgressPhotoProviders.controllerProvider)
            .requireValue;
        expect(state.videoPreviewReady, isTrue);
        final playback = container
            .read(
              ProgressVideoProviders.previewProvider(
                state.video!.originalStagingPath,
              ),
            )
            .requireValue;
        expect(playback.player.value.volume, 0);
        expect(playback.player.value.isPlaying, isFalse);
        await playback.player.play();
        for (var tick = 0; tick < 30; tick++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (playback.player.value.position > Duration.zero) break;
        }
        expect(playback.player.value.position, greaterThan(Duration.zero));
        await playback.player.pause();
        await playback.player.seekTo(const Duration(milliseconds: 500));
        expect(playback.player.value.isPlaying, isFalse);
        expect(
          state.video!.duration.inMilliseconds,
          inInclusiveRange(1900, 2100),
        );
        expect(state.video!.preview, isNotEmpty);
        expect(picker.lastMaxDuration, const Duration(seconds: 30));
        expect(
          (await db.select(db.progressMediaSessions).get()).length,
          mixed ? 1 : 0,
        );
        final selectedId = state.video!.original.id;
        picker.cancelNext = true;
        await _VideoSmoke.choose(tester);
        expect(
          container
              .read(ProgressPhotoProviders.controllerProvider)
              .requireValue
              .video!
              .original
              .id,
          selectedId,
        );
        await _VideoSmoke.choose(tester);
        expect(
          container
              .read(ProgressPhotoProviders.controllerProvider)
              .requireValue
              .video!
              .original
              .id,
          isNot(selectedId),
        );
        await _VideoSmoke.reveal(
          tester,
          find.byKey(const ValueKey('video_choose')),
        );
        await _VideoSmoke.capture(
          tester,
          mixed ? 'mixed_light' : 'video_light',
        );
        dark = true;
        await mount();
        await tester.pumpAndSettle();
        await _VideoSmoke.capture(tester, mixed ? 'mixed_dark' : 'video_dark');
        await _VideoSmoke.reveal(
          tester,
          find.byKey(const ValueKey('photo_notes')),
        );
        await tester.enterText(
          find.byKey(const ValueKey('photo_notes')),
          mixed ? 'Synthetic mixed session' : 'Synthetic video session',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await _VideoSmoke.reveal(
          tester,
          find.byKey(const ValueKey('photo_save')),
        );
        await tester.tap(find.byKey(const ValueKey('photo_save')));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.progressPhotoSaved), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        router.dispose();
      }
      final sessions = await db.select(db.progressMediaSessions).get();
      expect(sessions.map((s) => s.mediaType).toSet(), {'video', 'both'});
      final items = await db.select(db.progressMediaItems).get();
      expect(items.length, 6);
      expect(items.where((i) => i.type == 'video_frame'), isEmpty);
      expect((await db.select(db.localFileRecords).get()).length, 6);
      for (final item in items) {
        expect(await files.statManagedFile(item.localRelativePath), isNotNull);
      }
      expect(network.attempts, 0);
      await db.close();
      db = AppDatabase(NativeDatabase(dbFile));
      expect((await db.select(db.progressMediaSessions).get()).length, 2);
      expect((await db.select(db.progressMediaItems).get()).length, 6);
      await db.close();
      await root.delete(recursive: true);
    },
  );
}

abstract final class _VideoSmoke {
  static const captureKey = ValueKey('video_smoke_capture');
  static Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  static Future<void> choose(WidgetTester tester) async {
    await reveal(tester, find.byKey(const ValueKey('video_choose')));
    await tester.tap(find.byKey(const ValueKey('video_choose')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('photo_source_gallery')));
    await tester.pumpAndSettle();
  }

  static Future<void> capture(WidgetTester tester, String name) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(captureKey),
    );
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = await getApplicationDocumentsDirectory();
    await File(
      p.join(directory.path, 'aedify_m6_video_$name.png'),
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  }
}

class _VideoSmokePicker extends ImagePicker {
  _VideoSmokePicker(this.root);
  final Directory root;
  bool cancelNext = false;
  int count = 0;
  Duration? lastMaxDuration;
  @override
  Future<LostDataResponse> retrieveLostData() async => LostDataResponse.empty();
  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    lastMaxDuration = maxDuration;
    if (cancelNext) {
      cancelNext = false;
      return null;
    }
    final file = File(p.join(root.path, 'selection_${count++}.mp4'));
    await file.writeAsBytes(base64Decode(_ClipFixture.base64Video));
    return XFile(file.path);
  }

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawColor(AedifyLightColors.secondary, ui.BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(48, 64);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(p.join(root.path, 'selection_${count++}.png'));
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
    picture.dispose();
    return XFile(file.path);
  }
}

class _BlockedNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Video smoke must stay offline');
  }
}

abstract final class _ClipFixture {
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
