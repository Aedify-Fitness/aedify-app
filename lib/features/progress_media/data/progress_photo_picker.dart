import 'dart:io';

import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_photo_draft.dart';
import 'package:aedify/features/progress_media/data/progress_video_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract interface class ProgressPhotoPicker {
  Future<SelectedProgressPhoto?> pick(ProgressMediaSource source);
  Future<RecoveredProgressPhoto> recover();
}

/// Platform picker boundary. It never requests full photo metadata or logs errors.
class ImagePickerProgressPhotoPicker implements ProgressPhotoPicker {
  ImagePickerProgressPhotoPicker({
    ImagePicker? picker,
    required LocalFileStore files,
  }) : _picker = picker ?? ImagePicker(),
       _files = files;
  final ImagePicker _picker;
  final LocalFileStore _files;

  @override
  Future<SelectedProgressPhoto?> pick(ProgressMediaSource source) async {
    if (source != ProgressMediaSource.camera &&
        source != ProgressMediaSource.gallery) {
      throw ProgressPhotoFailure.unsupported;
    }
    try {
      final file = await _picker.pickImage(
        source: source == ProgressMediaSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        requestFullMetadata: false,
      );
      return file == null ? null : _SelectedPhoto(file, _files);
    } on PlatformException catch (error) {
      throw _failure(error.code);
    } on MissingPluginException {
      throw ProgressPhotoFailure.unsupported;
    } catch (_) {
      throw ProgressPhotoFailure.invalid;
    }
  }

  @override
  Future<RecoveredProgressPhoto> recover() async {
    if (!Platform.isAndroid) return const RecoveredProgressPhoto();
    try {
      final result = await _picker.retrieveLostData();
      final files = result.files;
      if (files != null && files.isNotEmpty) {
        if (result.type == RetrieveType.video) {
          return RecoveredProgressPhoto(
            video: ImagePickerProgressVideoPicker.recovered(
              files.first,
              _files,
            ),
          );
        }
        return RecoveredProgressPhoto(
          photo: _SelectedPhoto(files.first, _files),
        );
      }
      return RecoveredProgressPhoto(
        failure: result.exception == null
            ? null
            : result.type == RetrieveType.video ||
                  result.exception!.code.startsWith('microphone_')
            ? ImagePickerProgressVideoPicker.failureFromCode(
                result.exception!.code,
              )
            : _failure(result.exception!.code),
      );
    } on MissingPluginException {
      return const RecoveredProgressPhoto();
    } catch (_) {
      return const RecoveredProgressPhoto(
        failure: ProgressPhotoFailure.invalid,
      );
    }
  }

  static ProgressPhotoFailure _failure(String code) => switch (code) {
    'camera_access_denied' ||
    'camera_access_restricted' ||
    'photo_access_denied' ||
    'photo_access_restricted' => ProgressPhotoFailure.permission,
    'no_available_camera' ||
    'invalid_source' => ProgressPhotoFailure.unsupported,
    _ => ProgressPhotoFailure.invalid,
  };
}

class _SelectedPhoto implements SelectedProgressPhoto {
  _SelectedPhoto(this._file, this._files);
  final XFile _file;
  final LocalFileStore _files;
  @override
  Future<int> length() => _file.length();
  @override
  Future<Uint8List> readBytes() => _file.readAsBytes();
  @override
  Future<void> release() async {
    // Delete only plugin-created app-cache copies, never a source library file.
    final temporary = await getTemporaryDirectory();
    if (p.isWithin(temporary.path, _file.path)) {
      await _files.deleteFile(_file.path);
    }
  }
}
