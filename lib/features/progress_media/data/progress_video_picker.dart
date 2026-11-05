import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_video_draft.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract interface class ProgressVideoPicker {
  Future<SelectedProgressVideo?> pick(
    ProgressMediaSource source,
    ProgressVideoLimits limits,
  );
}

class ImagePickerProgressVideoPicker implements ProgressVideoPicker {
  ImagePickerProgressVideoPicker({
    required LocalFileStore files,
    ImagePicker? picker,
  }) : _files = files,
       _picker = picker ?? ImagePicker();
  final LocalFileStore _files;
  final ImagePicker _picker;

  @override
  Future<SelectedProgressVideo?> pick(
    ProgressMediaSource source,
    ProgressVideoLimits limits,
  ) async {
    if (source != ProgressMediaSource.camera &&
        source != ProgressMediaSource.gallery) {
      throw ProgressVideoFailure.unsupported;
    }
    try {
      final file = await _picker.pickVideo(
        source: source == ProgressMediaSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxDuration: limits.maxDuration,
      );
      return file == null ? null : recovered(file, _files);
    } on PlatformException catch (error) {
      throw failureFromCode(error.code);
    } on MissingPluginException {
      throw ProgressVideoFailure.unsupported;
    } catch (_) {
      throw ProgressVideoFailure.invalid;
    }
  }

  static ProgressVideoFailure failureFromCode(String code) => switch (code) {
    'microphone_access_denied' ||
    'microphone_access_restricted' => ProgressVideoFailure.microphone,
    'camera_access_denied' ||
    'camera_access_restricted' ||
    'photo_access_denied' ||
    'photo_access_restricted' => ProgressVideoFailure.permission,
    'no_available_camera' ||
    'invalid_source' => ProgressVideoFailure.unsupported,
    _ => ProgressVideoFailure.invalid,
  };
  static SelectedProgressVideo recovered(XFile file, LocalFileStore files) =>
      _SelectedVideo(file, files);
}

class _SelectedVideo implements SelectedProgressVideo {
  _SelectedVideo(this._file, this._files);
  final XFile _file;
  final LocalFileStore _files;
  @override
  Future<int> length() => _file.length();
  @override
  Future<Uint8List> header() async {
    final bytes = <int>[];
    await for (final chunk in _file.openRead(0, 16)) {
      bytes.addAll(chunk);
    }
    return Uint8List.fromList(bytes);
  }

  @override
  Stream<List<int>> openRead() => _file.openRead();
  @override
  Future<void> release() async {
    final temporary = await getTemporaryDirectory();
    if (p.isWithin(temporary.path, _file.path)) {
      await _files.deleteFile(_file.path);
    }
  }
}
