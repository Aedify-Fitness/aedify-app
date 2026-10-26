import 'package:drift/drift.dart';

class SavedWorkoutExerciseSets extends Table {
  TextColumn get id => text()();
  TextColumn get savedWorkoutExerciseId => text()();
  IntColumn get setIndex => integer()();
  TextColumn get setType => text()();
  TextColumn get setIntent => text().nullable()();
  IntColumn get prescribedRepsMin => integer().nullable()();
  IntColumn get prescribedRepsMax => integer().nullable()();
  IntColumn get prescribedRepsExact => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  RealColumn get distanceMeters => real().nullable()();
  TextColumn get weightPrescriptionType => text().nullable()();
  RealColumn get prescribedWeightKg => real().nullable()();
  RealColumn get prescribedWeightPct1rm => real().nullable()();
  RealColumn get prescribedWeightPctWorking => real().nullable()();
  RealColumn get bodyweightMultiplier => real().nullable()();
  RealColumn get prescribedRpeMin => real().nullable()();
  RealColumn get prescribedRpeMax => real().nullable()();
  IntColumn get prescribedRir => integer().nullable()();
  IntColumn get restSeconds => integer().nullable()();
  TextColumn get loadingModel => text().nullable()();
  RealColumn get percent1rmMin => real().nullable()();
  RealColumn get percent1rmMax => real().nullable()();
  RealColumn get rpeMin => real().nullable()();
  RealColumn get rpeMax => real().nullable()();
  TextColumn get loadSelectionNote => text().nullable()();
  BoolColumn get isCalibrationEstimate =>
      boolean().withDefault(const Constant(false))();
  IntColumn get derivedFromWorkingSetIndex => integer().nullable()();
  TextColumn get warmupWeightRuleJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
