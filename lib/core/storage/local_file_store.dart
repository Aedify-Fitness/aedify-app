import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:aedify/shared/constants/directory_constants.dart';

enum FileCategory {
  media(DirectoryConstants.media),
  imports(DirectoryConstants.imports),
  exports(DirectoryConstants.exports),
  audioCache(DirectoryConstants.audioCache),
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
}
