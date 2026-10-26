import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'dart:async';

import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/workout_execution/domain/weight_suggestion.dart';
import 'package:aedify/shared/domain/set_effort.dart';
import 'package:drift/drift.dart';

abstract interface class WeightSuggestionRepository {
  Stream<WeightSuggestionEvidence> watchEvidence(int exerciseId);
}

/// Reads completed local performances. Watches all source tables so corrections,
/// deletions and changed anchors invalidate estimates without a manual refresh.
class DriftWeightSuggestionRepository implements WeightSuggestionRepository {
  DriftWeightSuggestionRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<WeightSuggestionEvidence> watchEvidence(int exerciseId) {
    StreamSubscription<Set<TableUpdate>>? updates;
    late StreamController<void> triggers;
    triggers = StreamController<void>(
      onListen: () {
        updates = _db
            .tableUpdates(
              TableUpdateQuery.onAllTables([
                _db.exercises,
                _db.setLogs,
                _db.workoutSessionExercises,
                _db.workoutSessions,
                _db.strengthAnchors,
              ]),
            )
            .listen((_) => triggers.add(null), onError: triggers.addError);
        triggers.add(null);
      },
      onCancel: () => updates?.cancel(),
    );
    return triggers.stream.asyncMap((_) => loadEvidence(exerciseId));
  }

  Future<WeightSuggestionEvidence> loadEvidence(int exerciseId) async {
    final exercise = await (_db.select(
      _db.exercises,
    )..where((row) => row.id.equals(exerciseId))).getSingleOrNull();
    if (exercise == null ||
        exercise.deletedAt != null ||
        !WeightSuggestionPolicy.supportsExercise(
          name: exercise.name,
          modality: exercise.modality,
          equipment: exercise.equipment,
          loggingType: exercise.loggingType,
        )) {
      return const WeightSuggestionEvidence(supported: false);
    }
    final query =
        _db.select(_db.setLogs).join([
            innerJoin(
              _db.workoutSessionExercises,
              _db.workoutSessionExercises.id.equalsExp(
                _db.setLogs.workoutSessionExerciseId,
              ),
            ),
            innerJoin(
              _db.workoutSessions,
              _db.workoutSessions.id.equalsExp(
                _db.workoutSessionExercises.workoutSessionId,
              ),
            ),
          ])
          ..where(
            _db.setLogs.exerciseId.equals(exerciseId) &
                _db.setLogs.completed.equals(true) &
                _db.setLogs.skipped.equals(false) &
                _db.setLogs.setType.equals('working') &
                _db.workoutSessions.status.equals('completed'),
          )
          ..orderBy([
            OrderingTerm.desc(_db.setLogs.performedAt),
            OrderingTerm.desc(_db.setLogs.updatedAt),
          ])
          ..limit(50);
    final rows = await query.get();
    final references = <LoadReference>[];
    for (final row in rows) {
      final log = row.readTable(_db.setLogs);
      final member = row.readTable(_db.workoutSessionExercises);
      if (log.actualWeightKg == null ||
          log.actualReps == null ||
          (member.exerciseId == exerciseId &&
              member.loggingType != null &&
              member.loggingType != ExerciseLoggingType.repsWeight.dbValue)) {
        continue;
      }
      references.add(
        LoadReference(
          id: log.id,
          exerciseId: exerciseId,
          weightKg: log.actualWeightKg!,
          reps: log.actualReps,
          rpe: log.actualRpe ?? SetEffort.rpeFromRir(log.actualRir),
          performedAt: log.performedAt,
          source: LoadReferenceSource.history,
        ),
      );
    }
    final anchors =
        await (_db.select(_db.strengthAnchors)..where(
              (row) =>
                  row.exerciseId.equals(exerciseId) &
                  row.anchorType.equals('known_1rm') &
                  row.source.equals('user_entered'),
            ))
            .get();
    for (final anchor in anchors) {
      if (anchor.weightKg == null || anchor.loggedAt == null) continue;
      references.add(
        LoadReference(
          id: anchor.id,
          exerciseId: exerciseId,
          weightKg: anchor.weightKg!,
          performedAt: anchor.loggedAt!,
          source: LoadReferenceSource.knownMax,
        ),
      );
    }
    return WeightSuggestionEvidence(supported: true, references: references);
  }
}
