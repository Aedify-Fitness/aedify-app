import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/firebase/crashlytics_service.dart';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/network/interceptors/redacted_logging_interceptor.dart';
import 'package:aedify/core/privacy/privacy_classifier.dart';
import 'package:aedify/core/privacy/redaction.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/data/drift_progress_media_repository.dart';
import 'package:aedify/features/progress_media/data/progress_media_deletion_service.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'M6 diagnostics exclude media metadata, bytes, nested payloads and errors',
    () {
      final capture = _DiagnosticCapture();
      final metadata = <String, Object?>{
        'progress_media_path': _MediaSentinels.path,
        'session_notes': _MediaSentinels.notes,
        'thumbnail': _MediaSentinels.thumbnail,
        'extracted_frames': [_MediaSentinels.frame],
        'physique_analysis_result': {'summary': _MediaSentinels.analysis},
        'media_bytes': _MediaSentinels.bytes,
        'future_private_field': {'nested': _MediaSentinels.name},
        _MediaSentinels.name: _MediaSentinels.notes,
        // An allowlisted key must not admit arbitrary objects or byte arrays.
        'device_model': _MediaSentinels.bytes,
        'screen_name': {'notes': _MediaSentinels.notes},
        'redacted_stack_trace': _MediaSentinels.path,
        'error_code': 'progress_media_unavailable',
      };
      final stack = StackTrace.fromString(
        'FileSystemException: ${_MediaSentinels.path}',
      );
      capture.logger.error(
        'progress_media_failed',
        metadata: metadata,
        error: FileSystemException(_MediaSentinels.notes, _MediaSentinels.path),
        stackTrace: stack,
      );
      capture.crash.logSafe('progress_media_failed', metadata: metadata);
      capture.crash.recordErrorSafe(
        StateError(_MediaSentinels.analysis),
        stack,
        reason: _MediaSentinels.notes,
        metadata: metadata,
      );
      for (final entry in metadata.entries) {
        if (entry.value != null) {
          capture.crash.setCustomKeySafe(entry.key, entry.value!);
        }
      }
      _MediaSentinels.expectAbsent(capture.output);
      expect(capture.output, contains('progress_media_unavailable'));
      expect(capture.output, contains(Redaction.redactedPlaceholder));
    },
  );

  test(
    'M6 HTTP success and failure diagnostics exclude URL, body and attachment names',
    () async {
      final capture = _DiagnosticCapture();
      final adapter = _SyntheticHttpAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      addTearDown(() => dio.close(force: true));
      dio.interceptors.add(RedactedLoggingInterceptor(logger: capture.logger));
      final response = await dio.post<String>(
        'https://example.invalid/${_MediaSentinels.name}',
        queryParameters: {'notes': _MediaSentinels.notes},
        data: FormData.fromMap({
          'image': MultipartFile.fromBytes(
            _MediaSentinels.bytes,
            filename: _MediaSentinels.name,
          ),
        }),
        options: Options(
          headers: {'X-Media-Name': _MediaSentinels.thumbnail},
          responseType: ResponseType.plain,
        ),
      );
      expect(response.data, _MediaSentinels.analysis);
      adapter.fail = true;
      await expectLater(
        dio.get<String>(
          'https://example.invalid/${_MediaSentinels.frame}',
          options: Options(responseType: ResponseType.plain),
        ),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 2);
      _MediaSentinels.expectAbsent(capture.output);
      expect(capture.output, contains('[HTTP]'));
    },
  );

  test(
    'M6 filenames are fully redacted including basename and Windows paths',
    () {
      for (final path in [
        _MediaSentinels.path,
        _MediaSentinels.name,
        'C:\\private\\${_MediaSentinels.name}',
        null,
      ]) {
        expect(Redaction.filePath(path), Redaction.redactedPlaceholder);
      }
    },
  );

  test('M6 diagnostic filters preserve safe scalars and null stack state', () {
    expect(Redaction.stackTrace(null), isNull);
    final safe = Redaction.diagnosticMetadata({
      'app_version': '1.0.0',
      'drift_schema_version': 20,
      'non_sensitive_feature_flag': true,
    });
    expect(safe, {
      'app_version': '1.0.0',
      'drift_schema_version': 20,
      'non_sensitive_feature_flag': true,
    });
  });

  for (final field in [
    'progress_media_path',
    'progressMedia',
    'media_bytes',
    'thumbnailRelativePath',
    'extracted_frames',
    'video_frames',
    'physique_analysis_result',
    'localRelativePath',
  ]) {
    test('M6 $field is private in classification and redaction', () {
      const classifier = PrivacyClassifier();
      final category = classifier.classifyField(field);
      expect(classifier.isAllowedInExport(category), isFalse);
      expect(classifier.isAllowedInCrashlytics(category), isFalse);
      expect(classifier.isAllowedInLog(category), isFalse);
      expect(
        Redaction.valueForField(field, _MediaSentinels.analysis),
        Redaction.redactedPlaceholder,
      );
    });
  }

  test(
    'M6 future/unrecognized media fields cannot become public export content',
    () {
      const classifier = PrivacyClassifier();
      for (final field in [
        'future_checkin_payload',
        'new_analysis_summary',
        'session_notes',
      ]) {
        expect(
          classifier.isAllowedInExport(classifier.classifyField(field)),
          isFalse,
        );
      }
      expect(classifier.isAllowedInExport(PrivacyClass.localMedia), isFalse);
      expect(classifier.isAllowedInExport(PrivacyClass.aiInternal), isFalse);
      expect(
        classifier.isAllowedInExport(PrivacyClass.exportablePlanContent),
        isTrue,
      );
    },
  );

  test(
    'M6 local save, compare, missing-file recovery and deletion stay offline and private',
    () async {
      final root = await Directory.systemTemp.createTemp('m6_privacy_');
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() async {
        await db.close();
        await root.delete(recursive: true);
      });
      final capture = _DiagnosticCapture();
      final files = LocalFileStore(basePath: root.path, logger: capture.logger);
      final repository = DriftProgressMediaRepository(
        database: db,
        fileStore: files,
      );
      final blocked = _BlockedNetwork();
      await HttpOverrides.runWithHttpOverrides(() async {
        final first = await _MediaSentinels.save(repository, files, 1);
        final latest = await _MediaSentinels.save(repository, files, 2);
        expect(await repository.loadTimeline(), hasLength(2));
        await repository.setBaseline(first);
        await repository.updateNotes(latest, _MediaSentinels.notes);
        final details = (await repository.getSessionDetails(latest))!;
        expect(details.session.notes, _MediaSentinels.notes);
        expect(details.measurements?.waistCm, 81);
        expect(details.items, hasLength(4));
        await db.customStatement(
          "CREATE TRIGGER reject_notes BEFORE UPDATE OF notes ON progress_media_sessions BEGIN SELECT RAISE(ABORT, 'M6_PRIVATE_SQL_NOTES'); END",
        );
        try {
          await repository.updateNotes(latest, _MediaSentinels.notes);
          fail('Expected a recoverable repository failure');
        } on ProgressMediaFailure catch (error, stack) {
          expect(error, ProgressMediaFailure.unavailable);
          capture.logger.error(
            'progress_media_failed',
            error: error,
            stackTrace: stack,
          );
          capture.crash.recordErrorSafe(error, stack);
        } finally {
          await db.customStatement('DROP TRIGGER reject_notes');
        }
        expect(
          await repository.getComparablePosePairs(first, latest),
          hasLength(1),
        );
        final photo = details.items.firstWhere(
          (item) => item.file.type == ProgressMediaItemType.photo,
        );
        expect(
          await files.readManagedBytes(photo.file.relativePath),
          _MediaSentinels.bytes,
        );
        // Local DTOs are not general-purpose JSON/export/AI payloads.
        for (final value in [
          details,
          details.session,
          details.measurements,
          photo,
          photo.file,
        ]) {
          expect(
            () => jsonEncode(value),
            throwsA(isA<JsonUnsupportedObjectError>()),
          );
        }
        await files.deleteManagedRelativeFile(photo.file.relativePath);
        final missing = (await repository.getSessionDetails(latest))!;
        expect(
          missing.items
              .firstWhere((item) => item.file.id == photo.file.id)
              .isFileAvailable,
          isFalse,
        );
        final deletion = ProgressMediaDeletionService(
          database: db,
          files: files,
          now: () => DateTime.utc(2026, 11, 6),
        );
        expect((await deletion.deleteAll()).pending, isFalse);
        expect(await repository.loadTimeline(), isEmpty);
        expect(await db.select(db.localFileRecords).get(), isEmpty);
        capture.crash.recordErrorSafe(
          FileSystemException(_MediaSentinels.notes, photo.file.relativePath),
          StackTrace.fromString(_MediaSentinels.path),
          metadata: {'notes': details.session.notes},
        );
        for (final privateValue in [
          first,
          latest,
          root.path,
          for (final item in details.items) ...[
            item.file.id,
            item.file.relativePath,
          ],
        ]) {
          expect(capture.output, isNot(contains(privateValue)));
        }
      }, blocked);
      expect(blocked.attempts, 0);
      _MediaSentinels.expectAbsent(capture.output);
    },
  );
}

class _MediaSentinels {
  const _MediaSentinels._();
  static const name = 'M6_PRIVATE_MEDIA_NAME.jpg';
  static const path = '/private/progress/$name';
  static const notes = 'M6_PRIVATE_SESSION_NOTES';
  static const thumbnail = 'M6_PRIVATE_THUMBNAIL.png';
  static const frame = 'M6_PRIVATE_FRAME.jpg';
  static const analysis = 'M6_PRIVATE_ANALYSIS_RESULT';
  static final bytes = Uint8List.fromList(
    utf8.encode('M6_PRIVATE_MEDIA_BYTES'),
  );
  static void expectAbsent(String output) {
    for (final sentinel in [
      name,
      path,
      notes,
      thumbnail,
      frame,
      analysis,
      'M6_PRIVATE_VIDEO',
      'M6_PRIVATE_SQL_NOTES',
      utf8.decode(bytes),
      bytes.toString(),
      base64Encode(bytes),
    ]) {
      expect(
        output,
        isNot(contains(sentinel)),
        reason: 'Private progress sentinel escaped',
      );
    }
  }

  static Future<String> save(
    DriftProgressMediaRepository repository,
    LocalFileStore files,
    int day,
  ) async {
    final session = const Uuid().v4();
    final photo = const Uuid().v4();
    final video = const Uuid().v4();
    final items = <ProgressMediaFileDraft>[];
    for (final type in ProgressMediaItemType.values) {
      final id = type == ProgressMediaItemType.photo
          ? photo
          : type == ProgressMediaItemType.video
          ? video
          : const Uuid().v4();
      final filename = switch (type) {
        ProgressMediaItemType.photo => name,
        ProgressMediaItemType.video => 'M6_PRIVATE_VIDEO.mp4',
        ProgressMediaItemType.thumbnail => thumbnail,
        ProgressMediaItemType.videoFrame => frame,
      };
      final relativePath = p.posix.join(
        'media',
        'progress',
        'sessions',
        session,
        type.isOriginal
            ? 'originals'
            : type == ProgressMediaItemType.thumbnail
            ? 'thumbnails'
            : 'frames',
        '$id${p.posix.extension(filename)}',
      );
      await files.writeManagedBytes(relativePath, bytes);
      items.add(
        ProgressMediaFileDraft(
          id: id,
          type: type,
          pose: type == ProgressMediaItemType.video
              ? ProgressMediaPose.allSidesVideo
              : ProgressMediaPose.front,
          source: type.isOriginal
              ? ProgressMediaSource.gallery
              : type == ProgressMediaItemType.thumbnail
              ? ProgressMediaSource.generatedThumbnail
              : ProgressMediaSource.extractedFrame,
          relativePath: relativePath,
          sourceMediaItemId: type == ProgressMediaItemType.thumbnail
              ? photo
              : type == ProgressMediaItemType.videoFrame
              ? video
              : null,
          durationSeconds: type == ProgressMediaItemType.video ? 2 : null,
        ),
      );
    }
    await repository.saveSession(
      ProgressMediaSessionDraft(
        id: session,
        capturedAt: DateTime.utc(2026, 11, day),
        items: items,
        notes: notes,
        measurements: ProgressMeasurementSnapshot(
          measuredAt: DateTime.utc(2026, 11, day),
          waistCm: 81,
        ),
      ),
    );
    return session;
  }
}

class _DiagnosticCapture implements CrashlyticsClient {
  final events = <String>[];
  late final crash = CrashlyticsService(client: this);
  late final logger = AppLogger(
    sink: (message, {required name, required level, error, stackTrace}) {
      events.add('$name $message $error $stackTrace');
    },
  );
  String get output => events.join('\n');
  @override
  void log(String message) => events.add(message);
  @override
  void setCustomKey(String key, String value) => events.add('$key $value');
  @override
  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    events.add('$exception $stack $reason');
  }
}

class _SyntheticHttpAdapter implements HttpClientAdapter {
  bool fail = false;
  int calls = 0;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (requestStream != null) await requestStream.drain<void>();
    return ResponseBody.fromString(_MediaSentinels.analysis, fail ? 500 : 200);
  }

  @override
  void close({bool force = false}) {}
}

class _BlockedNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('M6 must remain offline');
  }
}
