import 'package:drift/drift.dart';
import 'package:aedify/core/db/tables/exercises.dart';

class ExerciseAudioCache extends Table {
  TextColumn get id => text()();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get stepIndex => integer()();
  TextColumn get textHash => text()();
  TextColumn get localRelativePath => text()();
  IntColumn get fileSizeBytes => integer().nullable()();
  TextColumn get voiceId => text().nullable()();
  DateTimeColumn get generatedAt => dateTime()();
  DateTimeColumn get lastAccessedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
