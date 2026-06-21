import 'package:drift/drift.dart';

class LocalFileRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  TextColumn get ownerType => text()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get localRelativePath => text()();
  IntColumn get fileSizeBytes => integer()();
  TextColumn get contentHash => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastVerifiedAt => dateTime().nullable()();
}
