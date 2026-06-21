import 'package:drift/drift.dart';

class SchemaMigrationsLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fromVersion => integer()();
  IntColumn get toVersion => integer()();
  DateTimeColumn get appliedAt => dateTime()();
  TextColumn get notes => text().nullable()();
}
