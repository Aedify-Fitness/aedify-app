import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/features/programmes/domain/programme_aggregate.dart';

class TodayWorkoutResolution {
  const TodayWorkoutResolution({
    this.todayWorkoutId,
    this.todayFlatIndex,
    required this.completedWorkoutIds,
  });

  final String? todayWorkoutId;
  final int? todayFlatIndex;
  final Set<String> completedWorkoutIds;
}

class TodayWorkoutResolver {
  const TodayWorkoutResolver({required WorkoutSessionDao sessionDao})
    : _sessionDao = sessionDao;

  final WorkoutSessionDao _sessionDao;

  Future<TodayWorkoutResolution> resolve({
    required ProgrammeAggregate aggregate,
    required DateTime now,
  }) async {
    final weeks = List<ProgramWeek>.from(aggregate.weeks)
      ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
    final workouts = aggregate.workouts;

    final workoutIdToFlatIndex = <String, int>{};
    final skippedUpdatedAts = <String, DateTime>{};
    var flatIdx = 0;
    for (final week in weeks) {
      final weekWorkouts = workouts
          .where((w) => w.programWeekId == week.id)
          .toList();
      for (var dayIdx = 0; dayIdx < 7; dayIdx++) {
        final w = weekWorkouts.cast<ProgramWorkout?>().firstWhere(
          (w) => w?.scheduledDayIndex == dayIdx,
          orElse: () => null,
        );
        if (w != null) {
          workoutIdToFlatIndex[w.id] = flatIdx;
          if (w.status == 'skipped') {
            skippedUpdatedAts[w.id] = w.updatedAt;
          }
        }
        flatIdx++;
      }
    }
    final totalFlatDays = flatIdx;

    final workoutIds = workouts.map((w) => w.id).toList();
    final completedSessions = await _sessionDao.getCompletedByProgramWorkoutIds(
      workoutIds,
    );

    final completedWorkoutIds = <String>{};
    final completedAtMap = <String, DateTime>{};
    for (final s in completedSessions) {
      if (s.programWorkoutId != null && s.completedAt != null) {
        completedWorkoutIds.add(s.programWorkoutId!);
        final existing = completedAtMap[s.programWorkoutId!];
        if (existing == null || s.completedAt!.isAfter(existing)) {
          completedAtMap[s.programWorkoutId!] = s.completedAt!;
        }
      }
    }

    String? boundaryWorkoutId;
    DateTime? boundaryDate;
    for (final entry in completedAtMap.entries) {
      if (boundaryDate == null || entry.value.isAfter(boundaryDate)) {
        boundaryWorkoutId = entry.key;
        boundaryDate = entry.value;
      }
    }
    for (final entry in skippedUpdatedAts.entries) {
      if (boundaryDate == null || entry.value.isAfter(boundaryDate)) {
        boundaryWorkoutId = entry.key;
        boundaryDate = entry.value;
      }
    }

    int? firstIncompleteFlatIndex;
    final flatIndexToWorkoutId = <int, String>{};
    for (final entry in workoutIdToFlatIndex.entries) {
      flatIndexToWorkoutId[entry.value] = entry.key;
    }
    for (var i = 0; i < totalFlatDays; i++) {
      final wId = flatIndexToWorkoutId[i];
      if (wId != null) {
        final isCompleted = completedWorkoutIds.contains(wId);
        final w = workouts.firstWhere((w) => w.id == wId);
        final isSkipped = w.status == 'skipped';
        if (!isCompleted && !isSkipped) {
          firstIncompleteFlatIndex = i;
          break;
        }
      }
    }

    int? todayFlatIndex;
    if (firstIncompleteFlatIndex == null) {
      todayFlatIndex = null;
    } else if (boundaryWorkoutId == null) {
      todayFlatIndex = firstIncompleteFlatIndex;
    } else {
      final boundaryFlatIdx = workoutIdToFlatIndex[boundaryWorkoutId]!;
      final bd = boundaryDate!;
      final boundaryDateOnly = DateTime(bd.year, bd.month, bd.day);
      final todayDateOnly = DateTime(now.year, now.month, now.day);
      final daysSince = todayDateOnly.difference(boundaryDateOnly).inDays;
      final candidate = boundaryFlatIdx + daysSince;
      todayFlatIndex = candidate < firstIncompleteFlatIndex
          ? candidate
          : firstIncompleteFlatIndex;
    }

    String? todayWorkoutId;
    if (todayFlatIndex != null) {
      final todayWId = flatIndexToWorkoutId[todayFlatIndex];
      if (todayWId != null) {
        final alreadyCompleted = completedWorkoutIds.contains(todayWId);
        final alreadySkipped =
            workouts.firstWhere((w) => w.id == todayWId).status == 'skipped';
        if (!alreadyCompleted && !alreadySkipped) {
          todayWorkoutId = todayWId;
        }
      }
    }

    return TodayWorkoutResolution(
      todayWorkoutId: todayWorkoutId,
      todayFlatIndex: todayFlatIndex,
      completedWorkoutIds: completedWorkoutIds,
    );
  }
}
