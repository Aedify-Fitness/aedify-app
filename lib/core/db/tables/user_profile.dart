import 'package:drift/drift.dart';

class UserProfile extends Table {
  TextColumn get id => text().withDefault(const Constant('default'))();
  TextColumn get name => text().nullable()();
  TextColumn get sex => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get bodyweightKg => real().nullable()();
  DateTimeColumn get bodyweightLoggedAt => dateTime().nullable()();
  TextColumn get preferredUnits =>
      text().withDefault(const Constant('metric'))();
  TextColumn get experienceLevel => text()();
  IntColumn get targetSessionLengthMinutes => integer().nullable()();
  IntColumn get trainingDaysPerWeek => integer().nullable()();
  TextColumn get trainingDayNamesJson =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get onboardingCompletedAt => dateTime().nullable()();
  TextColumn get goalsJson => text().withDefault(const Constant('[]'))();
  TextColumn get equipmentAccessJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get favoriteExerciseIdsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get substitutedExerciseIdsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get injuriesLimitationsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get otherNotes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
