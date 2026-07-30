import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/programmes/presentation/widgets/deload_diagonal_painter.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_day_card.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_section.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/program_workout_status.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/widgets/dashed_border_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _CalendarWidgetFixtures {
  _CalendarWidgetFixtures._();

  static Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }

  static DayViewData workoutDay({
    int dayIndex = 0,
    bool isToday = false,
    ProgramWorkoutStatus status = ProgramWorkoutStatus.planned,
  }) {
    return DayViewData(
      workoutId: 'workout-$dayIndex',
      scheduledDayIndex: dayIndex,
      dayLabel: 'Monday',
      title: 'Upper Strength',
      exerciseCount: 4,
      durationMinutes: 45,
      status: status,
      isToday: isToday,
      isRestDay: false,
      exercisePreview: const ['Bench Press', 'Cable Row'],
    );
  }

  static DayViewData restDay({bool isToday = false}) {
    return DayViewData(
      scheduledDayIndex: 1,
      dayLabel: 'Tuesday',
      title: AppStrings.activeRecovery,
      exerciseCount: 0,
      durationMinutes: 0,
      status: ProgramWorkoutStatus.planned,
      isToday: isToday,
      isRestDay: true,
      exercisePreview: const [],
    );
  }

  static WeekViewData week({
    int weekNumber = 1,
    WeekType weekType = WeekType.normal,
    bool isCurrentWeek = false,
    bool isWeekCompleted = false,
    List<DayViewData> days = const [],
  }) {
    return WeekViewData(
      weekId: 'week-$weekNumber',
      weekNumber: weekNumber,
      weekType: weekType,
      isCurrentWeek: isCurrentWeek,
      isWeekCompleted: isWeekCompleted,
      isWeekSkipped: false,
      days: days,
    );
  }
}

void main() {
  group('Programme calendar presentation', () {
    testWidgets('marks the current week independently from expansion', (
      tester,
    ) async {
      final week = _CalendarWidgetFixtures.week(isCurrentWeek: true);

      await tester.pumpWidget(
        _CalendarWidgetFixtures.wrap(
          ProgrammeWeekSection(
            week: week,
            isExpanded: false,
            isCurrentWeek: true,
            onToggle: () {},
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('programme_week_current_1')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.today), findsOneWidget);
    });

    testWidgets('gives today workout a dedicated badge and bordered cell', (
      tester,
    ) async {
      final day = _CalendarWidgetFixtures.workoutDay(isToday: true);

      await tester.pumpWidget(
        _CalendarWidgetFixtures.wrap(ProgrammeDayCard(day: day, onTap: () {})),
      );

      expect(
        find.byKey(const ValueKey('programme_day_workout_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('programme_day_today_badge_0')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.today), findsOneWidget);
    });

    testWidgets('renders rest days with recovery copy and dashed treatment', (
      tester,
    ) async {
      final day = _CalendarWidgetFixtures.restDay();

      await tester.pumpWidget(
        _CalendarWidgetFixtures.wrap(ProgrammeDayCard(day: day)),
      );

      expect(
        find.byKey(const ValueKey('programme_day_rest_1')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.rest), findsOneWidget);
      expect(find.text(AppStrings.activeRecovery), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.foregroundPainter is DashedBorderPainter,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders deload with both label and diagonal pattern', (
      tester,
    ) async {
      final week = _CalendarWidgetFixtures.week(
        weekNumber: 4,
        weekType: WeekType.deload,
      );

      await tester.pumpWidget(
        _CalendarWidgetFixtures.wrap(
          ProgrammeWeekSection(
            week: week,
            isExpanded: false,
            isCurrentWeek: false,
            onToggle: () {},
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('programme_week_deload_4')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.weekDeload), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is DeloadDiagonalPainter,
        ),
        findsOneWidget,
      );
    });

    testWidgets('keeps completed workouts visibly complete', (tester) async {
      final day = _CalendarWidgetFixtures.workoutDay(
        status: ProgramWorkoutStatus.completed,
      );

      await tester.pumpWidget(
        _CalendarWidgetFixtures.wrap(ProgrammeDayCard(day: day)),
      );

      expect(
        find.byKey(const ValueKey('programme_day_completed_badge_0')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.completed), findsOneWidget);
    });

    testWidgets('keeps skipped workouts distinct from completed workouts', (
      tester,
    ) async {
      final day = _CalendarWidgetFixtures.workoutDay(
        status: ProgramWorkoutStatus.skipped,
      );

      await tester.pumpWidget(
        _CalendarWidgetFixtures.wrap(ProgrammeDayCard(day: day)),
      );

      expect(
        find.byKey(const ValueKey('programme_day_skipped_badge_0')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.skipped), findsOneWidget);
      expect(find.text(AppStrings.completed), findsNothing);
    });
  });
}
