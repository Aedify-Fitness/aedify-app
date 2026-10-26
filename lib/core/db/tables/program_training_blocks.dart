import 'package:drift/drift.dart';

class ProgramTrainingBlocks extends Table {
  TextColumn get id => text()();
  TextColumn get programId => text()();
  IntColumn get sortOrder => integer()();
  TextColumn get name => text()();
  IntColumn get weekCount => integer()();
  TextColumn get focus => text()();
  TextColumn get trainingDaysJson => text().withDefault(const Constant('[]'))();
  TextColumn get progressionNotes => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
