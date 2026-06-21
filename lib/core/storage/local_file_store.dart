import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:aedify/shared/constants/directory_constants.dart';

enum FileCategory {
  media(DirectoryConstants.media),
  progress(DirectoryConstants.progress),
  sessions(DirectoryConstants.sessions),
  originals(DirectoryConstants.originals),
  thumbnails(DirectoryConstants.thumbnails),
  frames(DirectoryConstants.frames),
  extracted(DirectoryConstants.extracted),
  imagesOriginal(DirectoryConstants.imagesOriginal),
  imagesEnhanced(DirectoryConstants.imagesEnhanced),
  imports(DirectoryConstants.imports),
  exports(DirectoryConstants.exports),
  aedifyPlan(DirectoryConstants.aedifyPlan),
  pdf(DirectoryConstants.pdf),
  audioCache(DirectoryConstants.audioCache),
  exerciseSteps(DirectoryConstants.exerciseSteps),
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
    for (final category in FileCategory.values) {
      await categoryDir(category);
    }
  }

  Future<Directory> progressSessionOriginalsDir(String sessionId) => subDir(
    FileCategory.progress,
    p.join(
      DirectoryConstants.sessions,
      sessionId,
      DirectoryConstants.originals,
    ),
  );

  Future<Directory> progressSessionThumbnailsDir(String sessionId) => subDir(
    FileCategory.progress,
    p.join(
      DirectoryConstants.sessions,
      sessionId,
      DirectoryConstants.thumbnails,
    ),
  );

  Future<Directory> progressSessionFramesDir(String sessionId) => subDir(
    FileCategory.progress,
    p.join(DirectoryConstants.sessions, sessionId, DirectoryConstants.frames),
  );

  Future<Directory> importExtractedDir(String draftId) => subDir(
    FileCategory.imports,
    p.join(DirectoryConstants.extracted, draftId),
  );

  Future<Directory> importImagesOriginalDir(String draftId) => subDir(
    FileCategory.imports,
    p.join(DirectoryConstants.imagesOriginal, draftId),
  );

  Future<Directory> importImagesEnhancedDir(String draftId) => subDir(
    FileCategory.imports,
    p.join(DirectoryConstants.imagesEnhanced, draftId),
  );

  Future<Directory> aedifyPlanExportDir() =>
      subDir(FileCategory.exports, DirectoryConstants.aedifyPlan);

  Future<Directory> pdfExportDir() =>
      subDir(FileCategory.exports, DirectoryConstants.pdf);

  Future<Directory> exerciseAudioCacheDir(String exerciseId) =>
      subDir(FileCategory.audioCache, exerciseId);

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
