import 'package:drift/drift.dart';

class ProgramRevisions extends Table {
  TextColumn get id => text()();
  TextColumn get programId => text()();
  IntColumn get revisionNumber => integer()();
  TextColumn get changeType => text()();
  TextColumn get updateScope => text().nullable()();
  TextColumn get affectedRefsJson => text().nullable()();
  TextColumn get summary => text()();
  TextColumn get aiGenerationSnapshotId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
