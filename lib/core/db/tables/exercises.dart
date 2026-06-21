import 'package:drift/drift.dart';

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get difficulty => text().nullable()();
  TextColumn get primaryMuscles => text().nullable()();
  TextColumn get muscleGroups => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get modality => text().nullable()();
  TextColumn get equipment => text().nullable()();
  TextColumn get force => text().nullable()();
  TextColumn get mechanic => text().nullable()();
  TextColumn get grips => text().nullable()();
  TextColumn get steps => text().nullable()();
  TextColumn get source => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get externalId => integer().nullable()();
}
