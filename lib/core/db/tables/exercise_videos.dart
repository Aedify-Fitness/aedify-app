import 'package:drift/drift.dart';
import 'package:aedify/core/db/tables/exercises.dart';

class ExerciseVideos extends Table {
  TextColumn get id => text()();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  TextColumn get url => text()();
  TextColumn get angle => text().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get ogImageUrl => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
