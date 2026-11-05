import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/application/progress_photo_controller.dart';
import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/application/progress_video_providers.dart';
import 'package:aedify/features/progress_media/data/progress_video_metadata_service.dart';
import 'package:aedify/features/progress_media/data/progress_video_picker.dart';
import 'package:aedify/features/progress_media/data/progress_video_playback.dart';
import 'package:video_player/video_player.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:aedify/features/progress_media/data/progress_photo_file_service.dart';
import 'package:aedify/features/progress_media/data/progress_media_repository.dart';
import 'package:aedify/features/progress_media/data/progress_photo_picker.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_photo_draft.dart';
import 'package:aedify/features/progress_media/presentation/progress_media_screen.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Uint8List png;
  setUpAll(() async {
    png = await _PhotoFixtures.png();
  });

  test(
    'platform adapter selects source without requesting full metadata and treats cancel as null',
    () async {
      final picker = _PlatformPicker();
      final adapter = ImagePickerProgressPhotoPicker(
        picker: picker,
        files: LocalFileStore(),
      );
      expect(await adapter.pick(ProgressMediaSource.gallery), isNull);
      expect(picker.lastSource, ImageSource.gallery);
      expect(picker.fullMetadata, isFalse);
      await adapter.pick(ProgressMediaSource.camera);
      expect(picker.lastSource, ImageSource.camera);
    },
  );

  for (final code in [
    'camera_access_denied',
    'photo_access_restricted',
    'no_available_camera',
    'private-error',
  ]) {
    test('platform failure $code is sanitized', () async {
      final picker = _PlatformPicker()
        ..error = PlatformException(
          code: code,
          message: 'private-path-sentinel',
          details: {'notes': 'private-notes'},
        );
      final adapter = ImagePickerProgressPhotoPicker(
        picker: picker,
        files: LocalFileStore(),
      );
      try {
        await adapter.pick(ProgressMediaSource.camera);
        fail('Expected safe failure');
      } catch (error) {
        expect(error, isA<ProgressPhotoFailure>());
        expect(error.toString(), isNot(contains('private')));
        expect(
          (error as ProgressPhotoFailure).message,
          isNot(contains('sentinel')),
        );
      }
    });
  }

  test(
    'four camera/gallery poses stay temporary until save, then persist with thumbnails and notes',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      for (final pose in _PhotoFixtures.poses) {
        await f.controller.pick(
          pose,
          pose == ProgressMediaPose.front
              ? ProgressMediaSource.camera
              : ProgressMediaSource.gallery,
        );
      }
      expect((await f.db.select(f.db.progressMediaSessions).get()), isEmpty);
      expect(await f.db.select(f.db.localFileRecords).get(), isEmpty);
      expect(await f.filesIn('media'), isEmpty);
      expect((await f.filesIn('temp')).length, 8);
      f.controller.updateFields(
        notes: 'synthetic private note',
        bodyweight: '75.5',
      );
      expect(await f.controller.save(), isTrue);
      final row = (await f.db.select(f.db.progressMediaSessions).get()).single;
      expect(row.isCompletePoseSet, isTrue);
      expect(row.isBaseline, isTrue);
      expect(row.bodyweightKg, 75.5);
      expect(row.notes, 'synthetic private note');
      expect((await f.db.select(f.db.progressMediaItems).get()).length, 8);
      expect((await f.db.select(f.db.localFileRecords).get()).length, 8);
      expect((await f.filesIn('media')).length, 8);
      expect(await f.filesIn('temp'), isEmpty);
      expect(f.value.saved, isTrue);
      expect((await f.repository.getReminderState()).enabled, isFalse);
      expect((await f.repository.getReminderState()).nextReminderAt, isNull);
      expect(f.picker.released, 4);
      await f.controller.save();
      expect((await f.db.select(f.db.progressMediaSessions).get()).length, 1);
    },
  );

  test(
    'partial set saves with canonical imperial bodyweight and no extra schema',
    () async {
      final f = await _PhotoFixtures.create(png, units: PreferredUnit.imperial);
      addTearDown(f.close);
      await f.controller.pick(
        ProgressMediaPose.leftSide,
        ProgressMediaSource.gallery,
      );
      f.controller.updateFields(bodyweight: '165.3467');
      expect(await f.controller.save(), isTrue);
      final row = (await f.db.select(f.db.progressMediaSessions).get()).single;
      expect(row.isCompletePoseSet, isFalse);
      expect(row.bodyweightKg, closeTo(75, 0.001));
      expect(f.db.schemaVersion, 20);
    },
  );

  test(
    'cancel preserves prior photo, replacement cleans old files and remove cleans new ones',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.camera,
      );
      final old = f.value.photos[ProgressMediaPose.front]!;
      f.picker.cancel = true;
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.gallery,
      );
      expect(f.value.photos[ProgressMediaPose.front], same(old));
      expect(f.value.cancelled, isTrue);
      f.picker.cancel = false;
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.gallery,
      );
      expect(
        f.value.photos[ProgressMediaPose.front]!.original.id,
        isNot(old.original.id),
      );
      expect(await f.files.statManagedFile(old.originalStagingPath), isNull);
      expect((await f.filesIn('temp')).length, 2);
      await f.controller.remove(ProgressMediaPose.front);
      expect(f.value.photos, isEmpty);
      expect(await f.filesIn('temp'), isEmpty);
      expect(await f.db.select(f.db.progressMediaSessions).get(), isEmpty);
    },
  );

  test(
    'invalid and oversized images are rejected and platform copies released',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      f.picker.bytes = Uint8List.fromList([1, 2, 3]);
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.gallery,
      );
      expect(f.value.failure, ProgressPhotoFailure.invalid);
      f.picker.reportedLength = ProgressPhotoLimits.maxBytes + 1;
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.gallery,
      );
      expect(f.value.failure, ProgressPhotoFailure.tooLarge);
      expect(f.value.photos, isEmpty);
      expect(f.picker.released, 2);
      expect(await f.filesIn('temp'), isEmpty);
    },
  );

  test(
    'bad bodyweight cannot persist and correction retains all draft fields',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.gallery,
      );
      f.controller.updateFields(notes: 'retained');
      for (final value in ['NaN', 'Infinity', '-1', '0', 'bad']) {
        f.controller.updateFields(bodyweight: value);
        expect(await f.controller.save(), isFalse);
        expect(f.value.failure, ProgressPhotoFailure.bodyweight);
        expect(f.value.notes, 'retained');
        expect(f.value.photos.length, 1);
      }
      f.controller.updateFields(bodyweight: '70,5');
      expect(await f.controller.save(), isTrue);
      expect(
        (await f.db.select(f.db.progressMediaSessions).get())
            .single
            .bodyweightKg,
        70.5,
      );
    },
  );

  test(
    'late SQL failure compensates durable copies and keeps draft for retry',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.camera,
      );
      await f.db.customStatement(
        "CREATE TRIGGER reject_media BEFORE INSERT ON progress_media_reminder_settings BEGIN SELECT RAISE(ABORT, 'private-sql-sentinel'); END",
      );
      expect(await f.controller.save(), isFalse);
      expect(f.value.failure, ProgressPhotoFailure.storage);
      expect(f.value.photos.length, 1);
      expect(await f.filesIn('media'), isEmpty);
      expect((await f.filesIn('temp')).length, 2);
      expect(await f.db.select(f.db.progressMediaItems).get(), isEmpty);
      expect(await f.db.select(f.db.localFileRecords).get(), isEmpty);
      await f.db.customStatement('DROP TRIGGER reject_media');
      expect(await f.controller.save(), isTrue);
    },
  );

  test('low storage keeps retryable state and writes no session', () async {
    final f = await _PhotoFixtures.create(png);
    addTearDown(f.close);
    f.files.failWrites = true;
    await f.controller.pick(
      ProgressMediaPose.front,
      ProgressMediaSource.gallery,
    );
    expect(f.value.failure, ProgressPhotoFailure.storage);
    expect(f.value.photos, isEmpty);
    expect(await f.filesIn('temp'), isEmpty);
    expect(await f.db.select(f.db.progressMediaSessions).get(), isEmpty);
  });

  test(
    'thumbnail storage failure preserves original and permits fallback save',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      f.files.failThumbnail = true;
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.gallery,
      );
      expect(f.value.photos[ProgressMediaPose.front]!.thumbnail, isNull);
      expect(await f.controller.save(), isTrue);
      expect((await f.db.select(f.db.progressMediaItems).get()).length, 1);
      expect((await f.filesIn('media')).length, 1);
    },
  );

  test(
    'interrupted selection requires explicit pose/source review before save',
    () async {
      final f = await _PhotoFixtures.create(png, recover: true);
      addTearDown(f.close);
      expect(f.value.recovered, isNotNull);
      expect(f.value.canSave, isFalse);
      expect(await f.controller.save(), isFalse);
      f.controller.assignRecovered(
        ProgressMediaPose.back,
        ProgressMediaSource.camera,
      );
      expect(f.value.recovered, isNull);
      expect(await f.controller.save(), isTrue);
      final original = (await f.db.select(f.db.progressMediaItems).get())
          .firstWhere((i) => i.type == 'photo');
      expect(original.pose, 'back');
      expect(original.source, 'camera');
    },
  );

  test(
    'duplicate actions while picker is pending are ignored and late dispose cleans files',
    () async {
      final f = await _PhotoFixtures.create(png);
      f.picker.pending = Completer<void>();
      final pick = f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.camera,
      );
      await Future<void>.delayed(Duration.zero);
      await f.controller.pick(
        ProgressMediaPose.back,
        ProgressMediaSource.gallery,
      );
      expect(f.picker.calls, 1);
      expect(await f.controller.save(), isFalse);
      f.subscription.close();
      f.container.dispose();
      f.picker.pending!.complete();
      await pick;
      expect(await f.filesIn('temp'), isEmpty);
      await f.db.close();
      await f.root.delete(recursive: true);
    },
  );

  test(
    'discard failure is visible and retry removes every staged file',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.gallery,
      );
      f.files.failDeletes = true;
      expect(await f.controller.discard(), isFalse);
      expect(f.value.failure, ProgressPhotoFailure.cleanup);
      f.files.failDeletes = false;
      expect(await f.controller.discard(), isTrue);
      expect(await f.filesIn('temp'), isEmpty);
      expect(f.value.dirty, isFalse);
    },
  );

  test(
    'startup removes only unsaved drafts and retains committed media',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.gallery,
      );
      final original = f.value.photos.values.single.original.relativePath;
      await f.files.writeManagedBytes(original, png);
      await f.files.cleanupProgressPhotoDrafts();
      expect(await f.filesIn('temp'), isEmpty);
      expect(await f.files.statManagedFile(original), isNotNull);
    },
  );

  test(
    'video-only save requires a playable preview and records metadata/thumbnail locally',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      expect(f.value.video, isNotNull);
      expect(f.value.canSave, isFalse);
      expect(await f.controller.save(), isFalse);
      expect(await f.db.select(f.db.progressMediaSessions).get(), isEmpty);
      f.controller.videoPreviewResult(f.value.video!.original.id, ready: true);
      expect(await f.controller.save(), isTrue);
      final session =
          (await f.db.select(f.db.progressMediaSessions).get()).single;
      expect(session.mediaType, 'video');
      expect(session.isBaseline, isTrue);
      expect(session.isCompletePoseSet, isFalse);
      final items = await f.db.select(f.db.progressMediaItems).get();
      expect(items.map((i) => i.type).toSet(), {'video', 'thumbnail'});
      final video = items.singleWhere((i) => i.type == 'video');
      expect(video.pose, 'all_sides_video');
      expect(video.source, 'gallery');
      expect(video.durationSeconds, 2);
      expect(video.width, 96);
      expect(video.height, 128);
      expect(
        items.singleWhere((i) => i.type == 'thumbnail').sourceMediaItemId,
        video.id,
      );
      expect((await f.db.select(f.db.localFileRecords).get()).length, 2);
      expect(await f.filesIn('temp'), isEmpty);
      expect(f.videoPicker.released, 1);
      expect(f.db.schemaVersion, 20);
    },
  );

  test('photos and video share a single atomic mixed-session save', () async {
    final f = await _PhotoFixtures.create(png);
    addTearDown(f.close);
    await f.controller.pick(
      ProgressMediaPose.front,
      ProgressMediaSource.camera,
    );
    await f.controller.pickVideo(ProgressMediaSource.gallery);
    f.controller.videoPreviewResult(f.value.video!.original.id, ready: true);
    f.controller.updateFields(notes: 'mixed sentinel', bodyweight: '70');
    expect(await f.controller.save(), isTrue);
    final session =
        (await f.db.select(f.db.progressMediaSessions).get()).single;
    expect(session.mediaType, 'both');
    expect(session.notes, 'mixed sentinel');
    expect(session.bodyweightKg, 70);
    expect((await f.db.select(f.db.progressMediaItems).get()).length, 4);
  });

  test(
    'duration cap is inclusive, respects selection, and cannot save after a tighter limit',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      f.metadata.duration = const Duration(milliseconds: 60001);
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      expect(f.value.failure, ProgressVideoFailure.tooLong);
      expect(f.value.video, isNull);
      expect(await f.filesIn('temp'), isEmpty);
      f.metadata.duration = const Duration(seconds: 60);
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      f.controller.videoPreviewResult(f.value.video!.original.id, ready: true);
      f.controller.setVideoLimit(30);
      expect(f.value.videoLimitSeconds, 30);
      expect(f.value.canSave, isFalse);
      expect(await f.controller.save(), isFalse);
      f.controller.setVideoLimit(60);
      expect(f.value.canSave, isTrue);
      expect(await f.controller.save(), isTrue);
      expect(
        (await f.db.select(f.db.progressMediaItems).get())
            .singleWhere((i) => i.type == 'video')
            .durationSeconds,
        60,
      );
    },
  );

  test(
    'capture cap is passed to the picker and over-limit imports cannot bypass validation',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      f.controller.setVideoLimit(30);
      f.metadata.duration = const Duration(seconds: 31);
      await f.controller.pickVideo(ProgressMediaSource.camera);
      expect(f.videoPicker.lastLimit, const Duration(seconds: 30));
      expect(f.value.failure, ProgressVideoFailure.tooLong);
      expect(await f.filesIn('temp'), isEmpty);
    },
  );

  test(
    'size cap rejects reported and streamed overflow without leftover files',
    () async {
      final f = await _PhotoFixtures.create(
        png,
        limits: const ProgressVideoLimits(maxBytes: 16),
      );
      addTearDown(f.close);
      f.videoPicker.reportedLength = 17;
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      expect(f.value.failure, ProgressVideoFailure.tooLarge);
      f.videoPicker.reportedLength = 16;
      f.videoPicker.bytes = Uint8List.fromList([
        ..._VideoPicker.headerBytes,
        1,
      ]);
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      expect(f.value.failure, ProgressVideoFailure.tooLarge);
      expect(await f.filesIn('temp'), isEmpty);
      expect(await f.db.select(f.db.progressMediaSessions).get(), isEmpty);
      expect(f.videoPicker.released, 2);
    },
  );

  test(
    'cancel/replacement preserve existing selection and remove cleans staged video',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      await f.controller.pickVideo(ProgressMediaSource.camera);
      final previous = f.value.video!;
      f.videoPicker.cancel = true;
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      expect(f.value.video, same(previous));
      expect(f.value.cancelled, isTrue);
      f.videoPicker.cancel = false;
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      expect(f.value.video!.original.id, isNot(previous.original.id));
      expect(
        await f.files.statManagedFile(previous.originalStagingPath),
        isNull,
      );
      f.controller.videoPreviewResult(previous.original.id, ready: true);
      expect(f.value.videoPreviewReady, isFalse);
      await f.controller.removeVideo();
      expect(f.value.video, isNull);
      expect(await f.filesIn('temp'), isEmpty);
    },
  );

  test(
    'preview failure blocks mixed save until video is removed or preview succeeds',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.camera,
      );
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      f.controller.videoPreviewResult(f.value.video!.original.id, ready: false);
      expect(f.value.failure, ProgressVideoFailure.preview);
      expect(await f.controller.save(), isFalse);
      await f.controller.removeVideo();
      expect(await f.controller.save(), isTrue);
      expect(
        (await f.db.select(f.db.progressMediaSessions).get()).single.mediaType,
        'photo_set',
      );
    },
  );

  test(
    'invalid video/container and native failures are safe and keep draft recoverable',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      f.videoPicker.bytes = Uint8List.fromList([1, 2, 3]);
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      expect(f.value.failure, ProgressVideoFailure.unsupported);
      f.videoPicker.bytes = Uint8List.fromList(_VideoPicker.headerBytes);
      f.metadata.failure = ProgressVideoFailure.invalid;
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      expect(f.value.failure, ProgressVideoFailure.invalid);
      expect(await f.filesIn('temp'), isEmpty);
    },
  );

  test(
    'mixed late SQL failure compensates all durable files and can retry',
    () async {
      final f = await _PhotoFixtures.create(png);
      addTearDown(f.close);
      await f.controller.pick(
        ProgressMediaPose.front,
        ProgressMediaSource.camera,
      );
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      f.controller.videoPreviewResult(f.value.video!.original.id, ready: true);
      await f.db.customStatement(
        "CREATE TRIGGER reject_video BEFORE INSERT ON progress_media_reminder_settings BEGIN SELECT RAISE(ABORT, 'private-video-sentinel'); END",
      );
      expect(await f.controller.save(), isFalse);
      expect(await f.filesIn('media'), isEmpty);
      expect((await f.filesIn('temp')).length, 4);
      expect(await f.db.select(f.db.localFileRecords).get(), isEmpty);
      await f.db.customStatement('DROP TRIGGER reject_video');
      expect(await f.controller.save(), isTrue);
    },
  );

  test(
    'video thumbnail fallback can save after preview and recovery requires source review',
    () async {
      final f = await _PhotoFixtures.create(png, recoverVideo: true);
      addTearDown(f.close);
      expect(f.value.recoveredVideo, isNotNull);
      expect(f.value.canSave, isFalse);
      f.controller.assignRecoveredVideo(ProgressMediaSource.camera);
      expect(f.value.video!.original.source, ProgressMediaSource.camera);
      expect(f.value.canSave, isFalse);
      await f.controller.removeVideo();
      f.metadata.thumbnail = null;
      await f.controller.pickVideo(ProgressMediaSource.gallery);
      expect(f.value.video!.thumbnail, isNull);
      f.controller.videoPreviewResult(f.value.video!.original.id, ready: true);
      expect(await f.controller.save(), isTrue);
      expect(
        (await f.db.select(f.db.progressMediaItems).get()).single.type,
        'video',
      );
    },
  );

  test(
    'native metadata channel receives only verified local paths and sanitizes platform errors',
    () async {
      final root = await Directory.systemTemp.createTemp('video_channel_');
      addTearDown(() => root.delete(recursive: true));
      final files = LocalFileStore(basePath: root.path);
      await files.writeManagedBytes(
        'temp/clip.mp4',
        Uint8List.fromList(_VideoPicker.headerBytes),
      );
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      addTearDown(
        () => messenger.setMockMethodCallHandler(
          NativeProgressVideoMetadataService.channel,
          null,
        ),
      );
      messenger.setMockMethodCallHandler(
        NativeProgressVideoMetadataService.channel,
        (call) async {
          expect(call.method, 'inspect');
          expect(call.arguments['path'], p.join(root.path, 'temp/clip.mp4'));
          expect(call.arguments['maxDurationMs'], 60000);
          throw PlatformException(
            code: 'too_long',
            message: 'private-video-path-sentinel',
          );
        },
      );
      final service = NativeProgressVideoMetadataService(files);
      await expectLater(
        service.inspect('temp/clip.mp4', const ProgressVideoLimits()),
        throwsA(ProgressVideoFailure.tooLong),
      );
      messenger.setMockMethodCallHandler(
        NativeProgressVideoMetadataService.channel,
        (_) async => {'durationMs': 'private', 'width': 1, 'height': 1},
      );
      await expectLater(
        service.inspect('temp/clip.mp4', const ProgressVideoLimits()),
        throwsA(ProgressVideoFailure.invalid),
      );
      await expectLater(
        service.inspect('../outside.mp4', const ProgressVideoLimits()),
        throwsA(ProgressVideoFailure.invalid),
      );
    },
  );

  test(
    'video picker configures camera duration and sanitizes microphone permission denial',
    () async {
      final picker = _PlatformVideoPicker();
      final service = ImagePickerProgressVideoPicker(
        files: LocalFileStore(),
        picker: picker,
      );
      expect(
        await service.pick(
          ProgressMediaSource.camera,
          const ProgressVideoLimits(maxDuration: Duration(seconds: 30)),
        ),
        isNull,
      );
      expect(picker.maxDuration, const Duration(seconds: 30));
      picker.failure = PlatformException(
        code: 'microphone_access_denied',
        message: 'private-platform-sentinel',
      );
      await expectLater(
        service.pick(ProgressMediaSource.camera, const ProgressVideoLimits()),
        throwsA(ProgressVideoFailure.microphone),
      );
      expect(
        ProgressVideoFailure.microphone.message,
        isNot(contains('sentinel')),
      );
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'selected video preview and limit controls fit small 2x-text ${dark ? 'dark' : 'light'} layout',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final video = PreparedProgressVideo(
          original: const ProgressMediaFileDraft(
            id: 'video-widget',
            type: ProgressMediaItemType.video,
            pose: ProgressMediaPose.allSidesVideo,
            source: ProgressMediaSource.gallery,
            relativePath: 'synthetic.mp4',
            durationSeconds: 2,
          ),
          originalStagingPath: 'synthetic.mp4',
          duration: const Duration(seconds: 2),
          preview: png,
        );
        final controller = _WidgetPhotoController(png)..initialVideo = video;
        final playback = _WidgetPlayback();
        final container = ProviderContainer(
          overrides: [
            ProgressPhotoProviders.controllerProvider.overrideWith(
              () => controller,
            ),
            ProgressVideoProviders.previewProvider.overrideWith(
              (ref, path) async => playback,
            ),
          ],
        );
        final router = _PhotoFixtures.router();
        addTearDown(() {
          container.dispose();
          router.dispose();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              routerConfig: router,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(2)),
                child: child!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const ValueKey('video_choose')));
        await tester.pumpAndSettle();
        expect(
          container
              .read(ProgressPhotoProviders.controllerProvider)
              .requireValue
              .videoPreviewReady,
          isTrue,
        );
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byKey(const ValueKey('photo_save')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<FilledButton>(find.byKey(const ValueKey('photo_save')))
              .onPressed,
          isNotNull,
        );
        expect(find.text(AppStrings.progressMediaSave), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  for (final dark in [false, true]) {
    testWidgets(
      'photo form supports small screen, large text, source sheet and keyboard (${dark ? 'dark' : 'light'})',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = _WidgetPhotoController(png);
        final container = ProviderContainer(
          overrides: [
            ProgressPhotoProviders.controllerProvider.overrideWith(
              () => controller,
            ),
          ],
        );
        final router = _PhotoFixtures.router();
        addTearDown(() {
          container.dispose();
          router.dispose();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              routerConfig: router,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(2)),
                child: child!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.progressPhotoIntroduction), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const ValueKey('photo_action_front')),
        );
        await tester.tap(find.byKey(const ValueKey('photo_action_front')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('photo_source_gallery')));
        await tester.pumpAndSettle();
        expect(
          container
              .read(ProgressPhotoProviders.controllerProvider)
              .requireValue
              .photos
              .length,
          1,
        );
        await tester.ensureVisible(find.byKey(const ValueKey('photo_notes')));
        await tester.enterText(
          find.byKey(const ValueKey('photo_notes')),
          'private draft',
        );
        await tester.pump();
        await tester.ensureVisible(find.byKey(const ValueKey('photo_save')));
        expect(tester.takeException(), isNull);
        controller.nextSaveFailure = ProgressPhotoFailure.storage;
        await tester.tap(find.byKey(const ValueKey('photo_save')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('photo_error')), findsOneWidget);
        expect(
          tester.getRect(find.byKey(const ValueKey('photo_error'))).top,
          lessThan(700),
        );
        expect(
          container
              .read(ProgressPhotoProviders.controllerProvider)
              .requireValue
              .notes,
          'private draft',
        );
        controller.nextSaveFailure = null;
        await tester.ensureVisible(find.byKey(const ValueKey('photo_save')));
        await tester.tap(find.byKey(const ValueKey('photo_save')));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.progressPhotoSaved), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'permission failure retains draft and discard confirmation respects cancel',
    (tester) async {
      final controller = _WidgetPhotoController(png)
        ..nextFailure = ProgressPhotoFailure.permission;
      final container = ProviderContainer(
        overrides: [
          ProgressPhotoProviders.controllerProvider.overrideWith(
            () => controller,
          ),
        ],
      );
      final router = _PhotoFixtures.router();
      addTearDown(() {
        container.dispose();
        router.dispose();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('photo_action_front')),
      );
      await tester.tap(find.byKey(const ValueKey('photo_action_front')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('photo_source_camera')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('photo_error')));
      expect(
        find.text(AppErrorStrings.progressPhotoPermission),
        findsOneWidget,
      );
      controller.updateFields(notes: 'draft');
      await tester.pump();
      await tester.tap(find.byTooltip(AppStrings.backLabel));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.progressPhotoDiscard), findsOneWidget);
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();
      expect(find.byType(ProgressMediaScreen), findsOneWidget);
      await tester.tap(find.byTooltip(AppStrings.backLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.discardChanges));
      await tester.pumpAndSettle();
      expect(controller.discarded, isTrue);
      expect(find.byType(ProgressMediaScreen), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

class _PhotoFixtures {
  _PhotoFixtures(
    this.root,
    this.db,
    this.files,
    this.picker,
    this.videoPicker,
    this.metadata,
  );
  final Directory root;
  final AppDatabase db;
  final _FaultFiles files;
  final _PhotoPicker picker;
  final _VideoPicker videoPicker;
  final _VideoMetadata metadata;
  late ProviderContainer container;
  late ProviderSubscription<AsyncValue<ProgressPhotoState>> subscription;
  int counter = 1;
  static const poses = [
    ProgressMediaPose.front,
    ProgressMediaPose.back,
    ProgressMediaPose.leftSide,
    ProgressMediaPose.rightSide,
  ];
  ProgressPhotoController get controller =>
      container.read(ProgressPhotoProviders.controllerProvider.notifier);
  ProgressPhotoState get value =>
      container.read(ProgressPhotoProviders.controllerProvider).requireValue;
  ProgressMediaRepository get repository =>
      container.read(ProgressMediaProviders.repositoryProvider);
  static Future<_PhotoFixtures> create(
    Uint8List bytes, {
    PreferredUnit units = PreferredUnit.metric,
    bool recover = false,
    bool recoverVideo = false,
    ProgressVideoLimits limits = const ProgressVideoLimits(),
  }) async {
    final root = await Directory.systemTemp.createTemp('progress_photos_');
    final f = _PhotoFixtures(
      root,
      AppDatabase(NativeDatabase.memory()),
      _FaultFiles(root.path),
      _PhotoPicker(bytes)..recoverPhoto = recover,
      _VideoPicker(),
      _VideoMetadata(bytes),
    );
    if (recoverVideo) f.picker.recoveredVideo = _VideoSelection(f.videoPicker);
    f.container = ProviderContainer(
      overrides: [
        AppProviders.appDatabaseProvider.overrideWithValue(f.db),
        AppProviders.localFileStoreProvider.overrideWithValue(f.files),
        ProgressPhotoProviders.unitsProvider.overrideWith((ref) async => units),
        ProgressPhotoProviders.pickerProvider.overrideWithValue(f.picker),
        ProgressVideoProviders.pickerProvider.overrideWithValue(f.videoPicker),
        ProgressVideoProviders.metadataProvider.overrideWithValue(f.metadata),
        ProgressVideoProviders.limitsProvider.overrideWithValue(limits),
        ProgressPhotoProviders.idProvider.overrideWithValue(
          () =>
              '00000000-0000-4000-8000-${(f.counter++).toString().padLeft(12, '0')}',
        ),
      ],
    );
    f.subscription = f.container.listen(
      ProgressPhotoProviders.controllerProvider,
      (_, _) {},
    );
    await f.container.read(ProgressPhotoProviders.controllerProvider.future);
    return f;
  }

  Future<List<File>> filesIn(String category) async {
    final directory = Directory(p.join(root.path, category));
    if (!await directory.exists()) return [];
    return directory
        .list(recursive: true, followLinks: false)
        .where((e) => e is File)
        .cast<File>()
        .toList();
  }

  Future<void> close() async {
    await controller.discard();
    subscription.close();
    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await db.close();
    await root.delete(recursive: true);
  }

  static Future<Uint8List> png() async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawColor(AedifyLightColors.secondary, ui.BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(48, 64);
    final bytes = (await image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    image.dispose();
    picture.dispose();
    return bytes;
  }

  static GoRouter router() => GoRouter(
    initialLocation: AppRoutes.progress().path,
    routes: [
      GoRoute(
        path: AppRoutes.home().path,
        name: AppRoutes.home().name,
        builder: (_, _) => const Scaffold(body: Text(AppStrings.home)),
      ),
      GoRoute(
        path: AppRoutes.progress().path,
        name: AppRoutes.progress().name,
        builder: (_, _) => const ProgressMediaScreen(),
      ),
    ],
  );
}

class _FaultFiles extends LocalFileStore {
  _FaultFiles(String path) : super(basePath: path);
  bool failWrites = false;
  bool failDeletes = false;
  bool failThumbnail = false;
  int writes = 0;
  @override
  Future<void> writeManagedBytes(String path, Uint8List bytes) async {
    writes++;
    if (failWrites || (failThumbnail && writes == 2)) {
      throw const FileSystemException('private-storage-sentinel');
    }
    return super.writeManagedBytes(path, bytes);
  }

  @override
  Future<void> deleteManagedRelativeFile(String path) async {
    if (failDeletes) throw const FileSystemException('private-delete-sentinel');
    return super.deleteManagedRelativeFile(path);
  }
}

class _PhotoPicker implements ProgressPhotoPicker {
  _PhotoPicker(this.bytes);
  Uint8List bytes;
  int? reportedLength;
  bool cancel = false;
  bool recoverPhoto = false;
  SelectedProgressVideo? recoveredVideo;
  int released = 0;
  int calls = 0;
  Completer<void>? pending;
  @override
  Future<SelectedProgressPhoto?> pick(ProgressMediaSource source) async {
    calls++;
    await pending?.future;
    return cancel ? null : _Selection(this);
  }

  @override
  Future<RecoveredProgressPhoto> recover() async => RecoveredProgressPhoto(
    photo: recoverPhoto ? _Selection(this) : null,
    video: recoveredVideo,
  );
}

class _Selection implements SelectedProgressPhoto {
  _Selection(this.owner);
  final _PhotoPicker owner;
  @override
  Future<int> length() async => owner.reportedLength ?? owner.bytes.length;
  @override
  Future<Uint8List> readBytes() async => owner.bytes;
  @override
  Future<void> release() async {
    owner.released++;
  }
}

class _PlatformPicker extends ImagePicker {
  ImageSource? lastSource;
  bool? fullMetadata;
  PlatformException? error;
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    lastSource = source;
    fullMetadata = requestFullMetadata;
    if (error != null) throw error!;
    return null;
  }
}

class _WidgetPhotoController extends ProgressPhotoController {
  _WidgetPhotoController(this.png);
  final Uint8List png;
  ProgressPhotoFailure? nextFailure;
  bool discarded = false;
  PreparedProgressVideo? initialVideo;
  ProgressPhotoFailure? nextSaveFailure;
  @override
  Future<ProgressPhotoState> build() async =>
      ProgressPhotoState(units: PreferredUnit.metric, video: initialVideo);
  @override
  Future<void> pick(ProgressMediaPose pose, ProgressMediaSource source) async {
    if (nextFailure != null) {
      state = AsyncData(state.requireValue.copyWith(failure: nextFailure));
      return;
    }
    state = AsyncData(
      state.requireValue.copyWith(
        photos: {
          pose: PreparedProgressPhoto(
            original: ProgressMediaFileDraft(
              id: 'test',
              type: ProgressMediaItemType.photo,
              pose: pose,
              source: source,
              relativePath: 'test',
            ),
            originalStagingPath: 'test',
            preview: png,
          ),
        },
      ),
    );
  }

  @override
  Future<bool> save() async {
    if (nextSaveFailure != null) {
      state = AsyncData(state.requireValue.copyWith(failure: nextSaveFailure));
      return false;
    }
    state = AsyncData(state.requireValue.copyWith(saved: true));
    return true;
  }

  @override
  Future<bool> discard() async {
    discarded = true;
    state = AsyncData(ProgressPhotoState(units: PreferredUnit.metric));
    return true;
  }
}

class _VideoPicker implements ProgressVideoPicker {
  static const headerBytes = [
    0,
    0,
    0,
    16,
    102,
    116,
    121,
    112,
    105,
    115,
    111,
    109,
    0,
    0,
    0,
    0,
  ];
  Uint8List bytes = Uint8List.fromList(headerBytes);
  int? reportedLength;
  int released = 0;
  bool cancel = false;
  Duration? lastLimit;
  @override
  Future<SelectedProgressVideo?> pick(
    ProgressMediaSource source,
    ProgressVideoLimits limits,
  ) async {
    lastLimit = limits.maxDuration;
    return cancel ? null : _VideoSelection(this);
  }
}

class _VideoSelection implements SelectedProgressVideo {
  _VideoSelection(this.owner);
  final _VideoPicker owner;
  @override
  Future<int> length() async => owner.reportedLength ?? owner.bytes.length;
  @override
  Future<Uint8List> header() async => owner.bytes;
  @override
  Stream<List<int>> openRead() => Stream.value(owner.bytes);
  @override
  Future<void> release() async {
    owner.released++;
  }
}

class _VideoMetadata implements ProgressVideoMetadataService {
  _VideoMetadata(this.thumbnail);
  Duration duration = const Duration(seconds: 2);
  Uint8List? thumbnail;
  ProgressVideoFailure? failure;
  @override
  Future<ProgressVideoMetadata> inspect(
    String path,
    ProgressVideoLimits limits,
  ) async {
    if (failure != null) throw failure!;
    return ProgressVideoMetadata(
      duration: duration,
      width: 96,
      height: 128,
      thumbnail: thumbnail,
    );
  }
}

class _PlatformVideoPicker extends ImagePicker {
  Duration? maxDuration;
  PlatformException? failure;
  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    this.maxDuration = maxDuration;
    if (failure != null) throw failure!;
    return null;
  }
}

class _WidgetPlayback
    with WidgetsBindingObserver
    implements ProgressVideoPlayback {
  @override
  final VideoPlayerController player = _WidgetPlayer();
  @override
  Future<void> dispose() async {}
}

class _WidgetPlayer extends VideoPlayerController {
  _WidgetPlayer() : super.file(File('synthetic.mp4')) {
    value = VideoPlayerValue(
      duration: const Duration(seconds: 2),
      size: const Size(96, 128),
      isInitialized: true,
    );
  }
  @override
  Future<void> setLooping(bool looping) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> seekTo(Duration position) async {}
}
