import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:aedify/shared/constants/directory_constants.dart';

enum FileCategory {
  media(DirectoryConstants.media),
  imports(DirectoryConstants.imports),
  exports(DirectoryConstants.exports),
  audioCache(DirectoryConstants.audioCache),
  db(DirectoryConstants.db),
  temp(DirectoryConstants.temp);

  final String path;
  const FileCategory(this.path);
}

class LocalFileStore {
  LocalFileStore({String? basePath}) : _basePath = basePath;

  String? _basePath;

  Future<String> get basePath async {
    if (_basePath != null) return _basePath!;
    final appDir = await getApplicationSupportDirectory();
    _basePath = appDir.path;
    return _basePath!;
  }

  Future<Directory> _ensureDir(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> categoryDir(FileCategory category) async {
    final base = await basePath;
    final dir = p.join(base, category.path);
    return _ensureDir(dir);
  }

  Future<Directory> subDir(FileCategory category, String subPath) async {
    final base = await basePath;
    final dir = p.join(base, category.path, subPath);
    return _ensureDir(dir);
  }

  Future<File> fileAt(FileCategory category, String fileName) async {
    final dir = await categoryDir(category);
    return File(p.join(dir.path, fileName));
  }

  Future<void> clearCategory(FileCategory category) async {
    final dir = await categoryDir(category);
    await dir.delete(recursive: true);
    await _ensureDir(dir.path);
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> ensureCoreDirectories() async {
    await categoryDir(FileCategory.db);
    await categoryDir(FileCategory.media);
    await categoryDir(FileCategory.imports);
    await categoryDir(FileCategory.exports);
    await categoryDir(FileCategory.audioCache);
    await categoryDir(FileCategory.temp);
    await progressSessionOriginalsDir('bootstrap');
    await progressSessionThumbnailsDir('bootstrap');
    await progressSessionFramesDir('bootstrap');
    await importExtractedDir('bootstrap');
    await importImagesOriginalDir('bootstrap');
    await importImagesEnhancedDir('bootstrap');
    await aedifyPlanExportDir();
    await pdfExportDir();
    await exerciseAudioCacheDir('bootstrap');
  }

  Future<Directory> progressSessionOriginalsDir(String sessionId) => subDir(
    FileCategory.media,
    p.join(
      DirectoryConstants.progress,
      DirectoryConstants.sessions,
      sessionId,
      DirectoryConstants.originals,
    ),
  );

  Future<Directory> progressSessionThumbnailsDir(String sessionId) => subDir(
    FileCategory.media,
    p.join(
      DirectoryConstants.progress,
      DirectoryConstants.sessions,
      sessionId,
      DirectoryConstants.thumbnails,
    ),
  );

  Future<Directory> progressSessionFramesDir(String sessionId) => subDir(
    FileCategory.media,
    p.join(
      DirectoryConstants.progress,
      DirectoryConstants.sessions,
      sessionId,
      DirectoryConstants.frames,
    ),
  );

  Future<Directory> importExtractedDir(String draftId) => subDir(
    FileCategory.imports,
    p.join(DirectoryConstants.temp, draftId, DirectoryConstants.extracted),
  );

  Future<Directory> importImagesOriginalDir(String draftId) => subDir(
    FileCategory.imports,
    p.join(DirectoryConstants.temp, draftId, DirectoryConstants.imagesOriginal),
  );

  Future<Directory> importImagesEnhancedDir(String draftId) => subDir(
    FileCategory.imports,
    p.join(DirectoryConstants.temp, draftId, DirectoryConstants.imagesEnhanced),
  );

  Future<Directory> aedifyPlanExportDir() => subDir(
    FileCategory.exports,
    p.join(DirectoryConstants.temp, DirectoryConstants.aedifyPlan),
  );

  Future<Directory> pdfExportDir() => subDir(
    FileCategory.exports,
    p.join(DirectoryConstants.temp, DirectoryConstants.pdf),
  );

  Future<Directory> exerciseAudioCacheDir(String exerciseId) => subDir(
    FileCategory.audioCache,
    p.join(DirectoryConstants.exerciseSteps, exerciseId),
  );

  Future<Directory> exerciseDatasetTempDir() =>
      subDir(FileCategory.temp, DirectoryConstants.exerciseDataset);

  Future<File> exerciseDatasetTempFile(String datasetVersion) async {
    final dir = await exerciseDatasetTempDir();
    return File(p.join(dir.path, '$datasetVersion.json'));
  }

  Future<void> cleanupTemporaryImports() async {
    await clearCategory(FileCategory.imports);
  }

  Future<void> cleanupTemporaryExports() async {
    final dir = await categoryDir(FileCategory.exports);
    final children = dir.listSync(followLinks: false);
    for (final child in children) {
      if (child is Directory) {
        await child.delete(recursive: true);
      }
    }
  }

  Future<void> cleanupStartupTemporaryArtifacts() async {
    await cleanupTemporaryImports();
    await cleanupTemporaryExports();
  }

  Future<String> toRelativePath(String absolutePath) async {
    final base = await basePath;
    return p.relative(absolutePath, from: base);
  }

  Future<String> toAbsolutePath(String relativePath) async {
    final base = await basePath;
    return p.join(base, relativePath);
  }
}
