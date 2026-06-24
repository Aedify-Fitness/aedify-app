import 'package:drift/drift.dart';

class StrengthAnchors extends Table {
  TextColumn get id => text()();
  IntColumn get exerciseId => integer()();
  TextColumn get anchorType => text()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get reps => integer().nullable()();
  RealColumn get rpe => real().nullable()();
  IntColumn get rir => integer().nullable()();
  TextColumn get source => text()();
  TextColumn get sourceSetLogId => text().nullable()();
  TextColumn get confidence => text().nullable()();
  DateTimeColumn get loggedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
