import 'dart:typed_data';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/data/progress_photo_file_service.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';

/// Reads only bounded sandbox images; video bytes are never loaded for a preview.
class ProgressGalleryFileService {
  ProgressGalleryFileService(this._files);
  final LocalFileStore _files;
  Future<Uint8List?> preview(ProgressMediaItem item) async {
    final paths = [
      if (item.thumbnailRelativePath != null) item.thumbnailRelativePath!,
      if (item.isFileAvailable && item.file.type == ProgressMediaItemType.photo)
        item.file.relativePath,
    ];
    for (final path in paths) {
      try {
        final file = await _files.managedFile(path);
        final bytes = BytesBuilder(copy: false);
        await for (final chunk in file.openRead()) {
          if (bytes.length + chunk.length > ProgressPhotoLimits.maxBytes) {
            throw ProgressMediaFailure.invalid;
          }
          bytes.add(chunk);
        }
        return (await ProgressPhotoProcessor().decode(
          bytes.takeBytes(),
        )).preview;
      } catch (_) {
        // Try the original photo if its thumbnail is missing or corrupt.
      }
    }
    return null;
  }
}
