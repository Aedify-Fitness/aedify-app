import 'package:drift/drift.dart';

class SetLogs extends Table {
  TextColumn get id => text()();
  TextColumn get workoutSessionExerciseId => text()();
  IntColumn get exerciseId => integer()();
  DateTimeColumn get performedAt => dateTime()();
  IntColumn get setIndex => integer()();
  TextColumn get setType => text().withDefault(const Constant('working'))();
  TextColumn get setIntent => text().nullable()();
  IntColumn get prescribedRepsMin => integer().nullable()();
  IntColumn get prescribedRepsMax => integer().nullable()();
  RealColumn get prescribedWeightKg => real().nullable()();
  RealColumn get prescribedRpeMin => real().nullable()();
  RealColumn get prescribedRpeMax => real().nullable()();
  IntColumn get actualReps => integer().nullable()();
  RealColumn get actualWeightKg => real().nullable()();
  IntColumn get actualDurationSeconds => integer().nullable()();
  RealColumn get actualDistanceMeters => real().nullable()();
  RealColumn get actualRpe => real().nullable()();
  IntColumn get actualRir => integer().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
  BoolColumn get isPr => boolean().withDefault(const Constant(false))();
  RealColumn get estimated1rmKg => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
