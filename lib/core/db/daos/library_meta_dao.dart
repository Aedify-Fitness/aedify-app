import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/enums/library_sync_status.dart';
import 'package:aedify/core/db/tables/library_meta.dart';

part 'library_meta_dao.g.dart';

@DriftAccessor(tables: [LibraryMeta])
class LibraryMetaDao extends DatabaseAccessor<AppDatabase>
    with _$LibraryMetaDaoMixin {
  LibraryMetaDao(super.db);

  Future<LibraryMetaData?> getLibraryMeta() {
    return (select(
      libraryMeta,
    )..where((t) => t.id.equals('exercise_library'))).getSingleOrNull();
  }

  Future<void> upsertLibraryMeta(LibraryMetaCompanion entry) {
    return into(libraryMeta).insertOnConflictUpdate(entry);
  }

  Future<void> setSyncStatus({
    required LibrarySyncStatus syncStatus,
    String? errorCode,
    String? errorMessage,
  }) async {
    final now = DateTime.now();
    final existing = await getLibraryMeta();
    await upsertLibraryMeta(
      LibraryMetaCompanion(
        id: Value(existing?.id ?? 'exercise_library'),
        source: Value(existing?.source ?? ''),
        schemaVersion: Value(existing?.schemaVersion ?? 0),
        syncStatus: Value(syncStatus.value),
        lastSyncErrorCode: Value(errorCode),
        lastSyncErrorMessage: Value(errorMessage),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> clearSyncFailure() async {
    final existing = await getLibraryMeta();
    if (existing == null) return;
    await upsertLibraryMeta(
      LibraryMetaCompanion(
        id: Value(existing.id),
        source: Value(existing.source),
        schemaVersion: Value(existing.schemaVersion),
        libraryVersion: Value(existing.libraryVersion),
        generatedAt: Value(existing.generatedAt),
        downloadedAt: Value(existing.downloadedAt),
        exerciseCount: Value(existing.exerciseCount),
        manifestLastUpdatedAt: Value(existing.manifestLastUpdatedAt),
        manifestFilePath: Value(existing.manifestFilePath),
        minAppSchemaVersion: Value(existing.minAppSchemaVersion),
        syncStatus: Value(LibrarySyncStatus.synced.value),
        lastSyncErrorCode: const Value(null),
        lastSyncErrorMessage: const Value(null),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateManifestMetadata({
    required String libraryVersion,
    required int schemaVersion,
    required int exerciseCount,
    required DateTime downloadedAt,
    DateTime? generatedAt,
    DateTime? manifestLastUpdatedAt,
    String? manifestFilePath,
    int? minAppSchemaVersion,
  }) async {
    final now = DateTime.now();
    final existing = await getLibraryMeta();
    await upsertLibraryMeta(
      LibraryMetaCompanion(
        id: Value(existing?.id ?? 'exercise_library'),
        source: Value(existing?.source ?? ''),
        schemaVersion: Value(schemaVersion),
        libraryVersion: Value(libraryVersion),
        generatedAt: Value(generatedAt),
        downloadedAt: Value(downloadedAt),
        exerciseCount: Value(exerciseCount),
        manifestLastUpdatedAt: Value(manifestLastUpdatedAt),
        manifestFilePath: Value(manifestFilePath),
        minAppSchemaVersion: Value(minAppSchemaVersion),
        syncStatus: Value(
          existing?.syncStatus ?? LibrarySyncStatus.neverSynced.value,
        ),
        lastSyncErrorCode: const Value(null),
        lastSyncErrorMessage: const Value(null),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }
}
