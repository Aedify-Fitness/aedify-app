import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/local_file_record_dao.dart';
import 'package:aedify/core/storage/local_file_store.dart';

class LocalFileRecordService {
  LocalFileRecordService({
    required LocalFileRecordDao dao,
    required LocalFileStore fileStore,
  }) : _dao = dao,
       _fileStore = fileStore;

  final LocalFileRecordDao _dao;
  final LocalFileStore _fileStore;

  Future<LocalFileRecord> registerManagedFile({
    required FileCategory category,
    required String ownerType,
    String? ownerId,
    required String relativePath,
    required int fileSizeBytes,
    String? contentHash,
    String? mimeType,
    int? width,
    int? height,
    int? durationSeconds,
  }) async {
    final now = DateTime.now();
    await _dao.insertFileRecord(
      LocalFileRecordsCompanion.insert(
        category: category.path,
        ownerType: ownerType,
        ownerId: Value<String?>(ownerId),
        localRelativePath: relativePath,
        fileSizeBytes: fileSizeBytes,
        contentHash: Value<String?>(contentHash),
        mimeType: Value<String?>(mimeType),
        width: Value<int?>(width),
        height: Value<int?>(height),
        durationSeconds: Value<int?>(durationSeconds),
        createdAt: now,
      ),
    );
    return (await _dao.getByRelativePath(relativePath))!;
  }

  Future<LocalFileRecord?> getByRelativePath(String relativePath) =>
      _dao.getByRelativePath(relativePath);

  Future<List<LocalFileRecord>> getByOwner(
    String ownerType, {
    String? ownerId,
  }) => _dao.getByOwner(ownerType, ownerId: ownerId);

  Future<void> deleteManagedFile(String relativePath) async {
    await _dao.deleteByRelativePath(relativePath);
    final absolutePath = await _fileStore.toAbsolutePath(relativePath);
    await _fileStore.deleteFile(absolutePath);
  }

  Future<void> deleteManagedFilesForOwner(
    String ownerType, {
    String? ownerId,
  }) async {
    final records = await _dao.getByOwner(ownerType, ownerId: ownerId);
    for (final record in records) {
      await _fileStore.deleteFile(
        await _fileStore.toAbsolutePath(record.localRelativePath),
      );
    }
    await _dao.deleteByOwner(ownerType, ownerId: ownerId);
  }

  Future<void> verifyManagedFile(String relativePath) async {
    await _dao.markVerified(relativePath);
  }
}
