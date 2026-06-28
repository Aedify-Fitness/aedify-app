import 'package:drift/drift.dart';

class AppSettings extends Table {
  TextColumn get id => text().withDefault(const Constant('default'))();
  TextColumn get preferredUnits =>
      text().withDefault(const Constant('metric'))();
  TextColumn get themeMode => text().nullable()();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get workoutTimerSoundEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get exerciseAudioEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get crashlyticsEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get redactionStrictMode =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
