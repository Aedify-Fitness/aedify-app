import 'dart:async';
import 'dart:convert';

import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/analytics/data/analytics_repository.dart';
import 'package:aedify/features/plateau_detection/data/plateau_repository.dart';
import 'package:aedify/features/plateau_detection/domain/plateau_detection_service.dart';
import 'package:aedify/features/plateau_detection/domain/plateau_evaluation.dart';
import 'package:drift/drift.dart';

/// Rebuilds derived flags atomically; no source records or raw notes are written.
class DriftPlateauRepository implements PlateauRepository {
  DriftPlateauRepository(this._db, this._analytics);
  final AppDatabase _db;
  final AnalyticsRepository _analytics;
  static const _detector = PlateauDetectionService();
  static const _refreshInterval = Duration(minutes: 1);

  @override
  Future<List<PlateauEvaluation>> recompute({required DateTime now}) async {
    try {
      return await _db.transaction(() async {
        final sources = await _analytics.loadCompletedWorkingSets();
        final flags = await _db.select(_db.plateauFlags).get();
        final evaluations = _detector.evaluate(
          sources,
          now: now,
          dismissedAt: {
            for (final flag in flags)
              if (flag.dismissedAt != null) flag.exerciseId: flag.dismissedAt!,
          },
        );
        final existing = {for (final flag in flags) flag.exerciseId: flag};
        for (final evaluation in evaluations) {
          final previous = existing.remove(evaluation.exerciseId);
          final candidate =
              evaluation.outcome == PlateauOutcome.plateau ||
              evaluation.outcome == PlateauOutcome.dismissed;
          if (!candidate && previous == null) continue;
          final status = candidate
              ? evaluation.outcome == PlateauOutcome.dismissed
                    ? 'dismissed'
                    : 'open'
              : 'resolved';
          final basis = _basis(evaluation);
          if (previous == null) {
            await _db
                .into(_db.plateauFlags)
                .insert(
                  PlateauFlagsCompanion.insert(
                    id: 'plateau:e1rm:${evaluation.exerciseId}',
                    exerciseId: evaluation.exerciseId,
                    status: status,
                    basisJson: basis,
                    firstDetectedAt: now,
                    lastDetectedAt: now,
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
          } else if (previous.status != status || previous.basisJson != basis) {
            await (_db.update(
              _db.plateauFlags,
            )..where((row) => row.id.equals(previous.id))).write(
              PlateauFlagsCompanion(
                status: Value(status),
                basisJson: Value(basis),
                updatedAt: Value(now),
                lastDetectedAt: candidate ? Value(now) : const Value.absent(),
                resolvedAt: Value(
                  status == 'resolved' ? previous.resolvedAt ?? now : null,
                ),
              ),
            );
          }
        }
        // Deleted/expired evidence must not leave an open flag or stale metrics.
        for (final previous in existing.values) {
          if (previous.status == 'resolved' && previous.basisJson == '{}') {
            continue;
          }
          await (_db.update(
            _db.plateauFlags,
          )..where((row) => row.id.equals(previous.id))).write(
            PlateauFlagsCompanion(
              status: const Value('resolved'),
              basisJson: const Value('{}'),
              resolvedAt: Value(previous.resolvedAt ?? now),
              updatedAt: Value(now),
            ),
          );
        }
        return evaluations;
      });
    } catch (_) {
      throw PlateauFailure.unavailable;
    }
  }

  @override
  Future<void> dismiss(int exerciseId, {required DateTime now}) async {
    try {
      await _db.transaction(() async {
        final flag = await (_db.select(
          _db.plateauFlags,
        )..where((row) => row.exerciseId.equals(exerciseId))).getSingleOrNull();
        if (flag == null || flag.status == 'resolved') {
          throw PlateauFailure.missing;
        }
        // Repeated taps must not silently extend the user's cooldown.
        if (flag.status == 'dismissed') return;
        await (_db.update(
          _db.plateauFlags,
        )..where((row) => row.id.equals(flag.id))).write(
          PlateauFlagsCompanion(
            status: const Value('dismissed'),
            dismissedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      });
    } on PlateauFailure {
      rethrow;
    } catch (_) {
      throw PlateauFailure.unavailable;
    }
  }

  @override
  Stream<List<PlateauEvaluation>> watchEvaluations({
    required DateTime Function() now,
  }) async* {
    StreamSubscription<Set<TableUpdate>>? updates;
    Timer? refresh;
    late StreamController<void> triggers;
    triggers = StreamController<void>(
      onListen: () {
        updates = _db
            .tableUpdates(
              TableUpdateQuery.onAllTables([
                _db.setLogs,
                _db.workoutSessions,
                _db.workoutSessionExercises,
                _db.exercises,
                _db.programWorkouts,
                _db.programWeeks,
                _db.plateauFlags,
              ]),
            )
            .listen((_) => triggers.add(null), onError: triggers.addError);
        refresh = Timer.periodic(_refreshInterval, (_) => triggers.add(null));
        triggers.add(null);
      },
      onCancel: () async {
        refresh?.cancel();
        await updates?.cancel();
      },
    );
    try {
      await for (final _ in triggers.stream) {
        yield await recompute(now: now());
      }
    } catch (_) {
      throw PlateauFailure.unavailable;
    }
  }

  static String _basis(PlateauEvaluation evaluation) => jsonEncode({
    'exercise_id': evaluation.exerciseId,
    'sessions_considered': evaluation.qualifyingSessions,
    'slope_kg_per_session': evaluation.slopeKgPerSession,
    'reason_codes': evaluation.reasons.map((reason) => reason.name).toList(),
    'recent_sessions': [
      for (final session in evaluation.recentSessions)
        {
          'performed_at': session.performedAt.toUtc().toIso8601String(),
          'top_estimated_1rm_kg': session.topEstimatedKg,
          'working_set_count': session.workingSets,
          'missed_targets': session.missedTargets,
          'high_effort_sets': session.highEffortSets,
          'is_deload': session.isDeload,
        },
    ],
  });
}
