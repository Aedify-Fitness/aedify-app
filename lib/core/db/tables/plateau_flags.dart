import 'package:drift/drift.dart';

/// Durable local plateau lifecycle; evidence contains derived metrics only.
class PlateauFlags extends Table {
  TextColumn get id => text()();
  IntColumn get exerciseId => integer().unique()();
  TextColumn get status => text()();
  TextColumn get plateauType =>
      text().withDefault(const Constant('e1rm_stall'))();
  TextColumn get basisJson => text()();
  DateTimeColumn get firstDetectedAt => dateTime()();
  DateTimeColumn get lastDetectedAt => dateTime()();
  DateTimeColumn get dismissedAt => dateTime().nullable()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
