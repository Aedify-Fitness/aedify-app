import 'package:aedify/shared/domain/program_workout_status.dart';
import 'package:aedify/shared/domain/week_type.dart';

class ProgrammeCalendarViewData {
  const ProgrammeCalendarViewData({
    required this.name,
    this.description,
    this.blockType,
    required this.weeksTotal,
    this.daysPerWeek,
    required this.isActive,
    required this.weeks,
    required this.todayWeekNumber,
    required this.todayDayIndex,
    this.todayWorkoutId,
  });

  final String name;
  final String? description;
  final String? blockType;
  final int weeksTotal;
  final int? daysPerWeek;
  final bool isActive;
  final List<WeekViewData> weeks;
  final int? todayWeekNumber;
  final int todayDayIndex;
  final String? todayWorkoutId;
}

class WeekViewData {
  const WeekViewData({
    required this.weekId,
    required this.weekNumber,
    required this.weekType,
    required this.isCurrentWeek,
    required this.isWeekCompleted,
    required this.isWeekSkipped,
    this.name,
    required this.days,
  });

  final String weekId;
  final int weekNumber;
  final WeekType weekType;
  final bool isCurrentWeek;
  final bool isWeekCompleted;
  final bool isWeekSkipped;
  final String? name;
  final List<DayViewData> days;

  bool get isDeload => weekType == WeekType.deload;
  bool get isPastWeek => isWeekCompleted || isWeekSkipped;
}

class DayViewData {
  const DayViewData({
    this.workoutId,
    required this.scheduledDayIndex,
    required this.dayLabel,
    required this.title,
    required this.exerciseCount,
    required this.durationMinutes,
    required this.status,
    required this.isToday,
    required this.isRestDay,
    required this.exercisePreview,
  });

  final String? workoutId;
  final int scheduledDayIndex;
  final String dayLabel;
  final String title;
  final int exerciseCount;
  final int durationMinutes;
  final ProgramWorkoutStatus status;
  final bool isToday;
  final bool isRestDay;
  final List<String> exercisePreview;

  bool get isCompleted => status == ProgramWorkoutStatus.completed;
}
