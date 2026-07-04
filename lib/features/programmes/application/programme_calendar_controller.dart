import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/features/programmes/application/programme_calendar_state.dart';
import 'package:aedify/features/programmes/application/today_workout_resolver.dart';
import 'package:aedify/features/programmes/domain/programme_aggregate.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/shared/domain/program_workout_status.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgrammeCalendarController
    extends AsyncNotifier<ProgrammeCalendarState> {
  ProgrammeCalendarController(this._programmeId);

  final String _programmeId;

  @override
  Future<ProgrammeCalendarState> build() async {
    return _loadCalendar();
  }

  Future<ProgrammeCalendarState> _loadCalendar() async {
    final repo = ref.read(AppProviders.programmeRepositoryProvider);
    final aggregate = await repo.getProgramme(_programmeId);
    if (aggregate == null) {
      return ProgrammeCalendarState(
        isLoading: false,
        errorMessage: 'Programme not found.',
      );
    }

    final viewData = await _buildViewData(aggregate);
    return ProgrammeCalendarState(isLoading: false, viewData: viewData);
  }

  Future<ProgrammeCalendarViewData> _buildViewData(
    ProgrammeAggregate aggregate,
  ) async {
    final program = aggregate.program;
    final weeks = aggregate.weeks;
    final workouts = aggregate.workouts;
    final exercises = aggregate.exercises;
    final templates = aggregate.templates;

    weeks.sort((a, b) => a.weekNumber.compareTo(b.weekNumber));

    final exerciseIds = exercises.map((e) => e.exerciseId).toSet().toList();
    final exerciseNames = await _resolveExerciseNames(exerciseIds);

    final templateMap = <String, ProgramWorkoutTemplate>{};
    for (final t in templates) {
      templateMap[t.id] = t;
    }

    final today = DateTime.now();
    final todayWeekNumber = _computeTodayWeekNumber(
      program.startDateLocal,
      weeks,
      today,
    );
    final weekViewDataList = <WeekViewData>[];

    final sessionDao = ref.read(AppProviders.workoutSessionDaoProvider);
    final resolver = TodayWorkoutResolver(sessionDao: sessionDao);
    final resolution = await resolver.resolve(aggregate: aggregate, now: today);

    // Build day view data
    var currentFlatIndex = 0;
    for (final week in weeks) {
      final weekWorkouts = workouts
          .where((w) => w.programWeekId == week.id)
          .toList();

      final isCurrentWeek =
          todayWeekNumber != null && week.weekNumber == todayWeekNumber;

      final dayViewDataList = <DayViewData>[];

      for (var dayIdx = 0; dayIdx < 7; dayIdx++) {
        final workout = weekWorkouts.cast<ProgramWorkout?>().firstWhere(
          (w) => w?.scheduledDayIndex == dayIdx,
          orElse: () => null,
        );

        final dayLabel = TrainingDay.values[dayIdx].fullDisplayLabel;
        final isToday =
            resolution.todayFlatIndex != null &&
            currentFlatIndex == resolution.todayFlatIndex;

        if (workout == null) {
          dayViewDataList.add(
            DayViewData(
              scheduledDayIndex: dayIdx,
              dayLabel: dayLabel,
              title: AppStrings.activeRecovery,
              exerciseCount: 0,
              durationMinutes: 0,
              status: ProgramWorkoutStatus.planned,
              isToday: isToday,
              isRestDay: true,
              exercisePreview: const [],
            ),
          );
          currentFlatIndex++;
          continue;
        }

        final workoutExercises = exercises
            .where((e) => e.programWorkoutId == workout.id)
            .toList();

        final durationMinutes =
            templateMap[workout.workoutTemplateId]?.estimatedDurationMinutes ??
            0;

        final status = resolution.completedWorkoutIds.contains(workout.id)
            ? ProgramWorkoutStatus.completed
            : ProgramWorkoutStatus.fromDb(workout.status);

        final previewNames = <String>[];
        for (var i = 0; i < workoutExercises.length && i < 3; i++) {
          final name = exerciseNames[workoutExercises[i].exerciseId];
          if (name != null) {
            previewNames.add(name);
          }
        }

        dayViewDataList.add(
          DayViewData(
            workoutId: workout.id,
            scheduledDayIndex: dayIdx,
            dayLabel: dayLabel,
            title: workout.name,
            exerciseCount: workoutExercises.length,
            durationMinutes: durationMinutes,
            status: status,
            isToday: isToday,
            isRestDay: false,
            exercisePreview: previewNames,
          ),
        );
        currentFlatIndex++;
      }

      final nonRestDays = dayViewDataList.where((d) => !d.isRestDay).toList();
      final isWeekCompleted =
          nonRestDays.isNotEmpty && nonRestDays.every((d) => d.isCompleted);
      final isWeekSkipped =
          nonRestDays.isNotEmpty &&
          nonRestDays.every((d) => d.status == ProgramWorkoutStatus.skipped);

      weekViewDataList.add(
        WeekViewData(
          weekId: week.id,
          weekNumber: week.weekNumber,
          weekType: WeekType.fromDb(week.weekType) ?? WeekType.normal,
          isCurrentWeek: isCurrentWeek,
          isWeekCompleted: isWeekCompleted,
          isWeekSkipped: isWeekSkipped,
          name: week.notes,
          days: dayViewDataList,
        ),
      );
    }

    final progressionTodayDayIndex = resolution.todayFlatIndex != null
        ? resolution.todayFlatIndex! % 7
        : 0;

    return ProgrammeCalendarViewData(
      name: program.name,
      description: program.description,
      blockType: program.blockType,
      weeksTotal: program.weeksTotal ?? weeks.length,
      daysPerWeek: program.daysPerWeek,
      isActive: program.active,
      weeks: weekViewDataList,
      todayWeekNumber: todayWeekNumber,
      todayDayIndex: progressionTodayDayIndex,
      todayWorkoutId: resolution.todayWorkoutId,
    );
  }

  Future<Map<int, String>> _resolveExerciseNames(List<int> ids) async {
    if (ids.isEmpty) return {};
    final dao = ref.read(AppProviders.exerciseDaoProvider);
    final nameMap = <int, String>{};
    for (final id in ids) {
      final row = await dao.getExerciseById(id);
      if (row != null) {
        nameMap[id] = row.name;
      }
    }
    return nameMap;
  }

  int? _computeTodayWeekNumber(
    String? startDateLocal,
    List<ProgramWeek> weeks,
    DateTime today,
  ) {
    if (weeks.isEmpty) return null;
    if (startDateLocal == null) return weeks.first.weekNumber;
    final startDate = DateTime.tryParse(startDateLocal);
    if (startDate != null) {
      final diffDays = today.difference(startDate).inDays;
      if (diffDays < 0) return null;
      final weekNum = (diffDays ~/ 7) + 1;
      if (weekNum > weeks.length) return null;
      return weekNum;
    }
    return null;
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadCalendar());
  }
}
