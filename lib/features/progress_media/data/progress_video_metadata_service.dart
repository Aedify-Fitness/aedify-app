import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:flutter/services.dart';

abstract interface class ProgressVideoMetadataService {
  Future<ProgressVideoMetadata> inspect(
    String relativePath,
    ProgressVideoLimits limits,
  );
}

/// Reads only a verified app-owned file. Native failures never retain a path.
class NativeProgressVideoMetadataService
    implements ProgressVideoMetadataService {
  NativeProgressVideoMetadataService(this._files);
  final LocalFileStore _files;
  static const channel = MethodChannel('aedify/progress_video');
  @override
  Future<ProgressVideoMetadata> inspect(
    String relativePath,
    ProgressVideoLimits limits,
  ) async {
    try {
      final file = await _files.managedFile(relativePath);
      final data = await channel
          .invokeMapMethod<String, dynamic>('inspect', {
            'path': file.path,
            'maxDurationMs': limits.maxDuration.inMilliseconds,
            'maxBytes': limits.maxBytes,
            'thumbnailEdge': ProgressVideoLimits.thumbnailEdge,
          })
          .timeout(ProgressVideoLimits.probeTimeout);
      final milliseconds = data?['durationMs'];
      final width = data?['width'];
      final height = data?['height'];
      final thumbnail = data?['thumbnail'];
      if (milliseconds is! int ||
          width is! int ||
          height is! int ||
          milliseconds <= 0 ||
          width <= 0 ||
          height <= 0 ||
          (thumbnail != null && thumbnail is! Uint8List)) {
        throw ProgressVideoFailure.invalid;
      }
      return ProgressVideoMetadata(
        duration: Duration(milliseconds: milliseconds),
        width: width,
        height: height,
        thumbnail: thumbnail as Uint8List?,
      );
    } on ProgressVideoFailure {
      rethrow;
    } on MissingPluginException {
      throw ProgressVideoFailure.unsupported;
    } on PlatformException catch (error) {
      throw switch (error.code) {
        'too_long' => ProgressVideoFailure.tooLong,
        'too_large' => ProgressVideoFailure.tooLarge,
        'unsupported' => ProgressVideoFailure.unsupported,
        _ => ProgressVideoFailure.invalid,
      };
    } catch (_) {
      throw ProgressVideoFailure.invalid;
    }
  }
}
