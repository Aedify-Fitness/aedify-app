import 'package:drift/drift.dart';

class ProgramExercises extends Table {
  TextColumn get id => text()();
  TextColumn get programWorkoutId => text()();
  TextColumn get sourceTemplateExerciseId => text().nullable()();
  IntColumn get exerciseId => integer()();
  TextColumn get exerciseRole => text().nullable()();
  TextColumn get supersetGroupId => text().nullable()();
  IntColumn get supersetOrder => integer().nullable()();
  IntColumn get sortOrder => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
