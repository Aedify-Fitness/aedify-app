import 'package:drift/drift.dart';

class ProgramWeeks extends Table {
  TextColumn get id => text()();
  TextColumn get programId => text()();
  IntColumn get weekNumber => integer()();
  TextColumn get weekType => text().nullable()();
  TextColumn get startsOnLocal => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
