import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/programmes/presentation/widgets/deload_diagonal_painter.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_day_card.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_section.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/program_workout_status.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _CalendarWidgetFixtures {
  _CalendarWidgetFixtures._();

  static Widget wrap(
    Widget child, {
    bool isDark = false,
    double textScale = 1,
  }) {
    return MaterialApp(
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
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
    String title = 'Upper Strength',
    ProgramWorkoutStatus status = ProgramWorkoutStatus.planned,
  }) {
    return DayViewData(
      workoutId: 'workout-$dayIndex',
      scheduledDayIndex: dayIndex,
      dayLabel: TrainingDay.values[dayIndex].fullDisplayLabel,
      title: title,
      exerciseCount: 4,
      durationMinutes: 45,
      status: status,
      isToday: isToday,
      isRestDay: false,
      exercisePreview: const ['Bench Press', 'Cable Row'],
    );
  }

  static DayViewData restDay({int dayIndex = 1, bool isToday = false}) {
    return DayViewData(
      scheduledDayIndex: dayIndex,
      dayLabel: TrainingDay.values[dayIndex].fullDisplayLabel,
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
      expect(find.text(AppStrings.programmeCurrentWeek), findsOneWidget);
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

    testWidgets('keeps recovery days compact and noninteractive', (
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
        find.descendant(
          of: find.byKey(const ValueKey('programme_day_rest_1')),
          matching: find.byType(InkWell),
        ),
        findsNothing,
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

    testWidgets(
      'shows in-progress text with real workout metadata and preview',
      (tester) async {
        final day = _CalendarWidgetFixtures.workoutDay(
          isToday: true,
          status: ProgramWorkoutStatus.started,
        );

        await tester.pumpWidget(
          _CalendarWidgetFixtures.wrap(ProgrammeDayCard(day: day)),
        );

        expect(find.text(AppStrings.inProgressLabel), findsOneWidget);
        expect(find.text('4 ${AppStrings.movements}'), findsOneWidget);
        expect(
          find.text('45${AppStrings.durationMinutesAbbreviation}'),
          findsOneWidget,
        );
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('Cable Row'), findsOneWidget);
      },
    );

    testWidgets('labels replaced workouts without implying completion', (
      tester,
    ) async {
      final day = _CalendarWidgetFixtures.workoutDay(
        status: ProgramWorkoutStatus.replaced,
      );

      await tester.pumpWidget(
        _CalendarWidgetFixtures.wrap(
          ProgrammeWeekSection(
            week: _CalendarWidgetFixtures.week(days: [day]),
            isExpanded: true,
            isCurrentWeek: false,
            onToggle: () {},
          ),
        ),
      );

      expect(find.text(AppStrings.replaced), findsOneWidget);
      expect(find.text(AppStrings.completed), findsNothing);
      final summary = tester.widget<Semantics>(
        find.byKey(const ValueKey('programme_day_overview_0')),
      );
      expect(summary.properties.label, 'Monday, Replaced');
    });

    testWidgets('expands the agenda and opens workouts without opening rest', (
      tester,
    ) async {
      final workout = _CalendarWidgetFixtures.workoutDay();
      final rest = _CalendarWidgetFixtures.restDay();
      final week = _CalendarWidgetFixtures.week(days: [workout, rest]);
      var isExpanded = false;
      final openedDays = <DayViewData>[];

      await tester.pumpWidget(
        _CalendarWidgetFixtures.wrap(
          StatefulBuilder(
            builder: (context, setState) => ProgrammeWeekSection(
              week: week,
              isExpanded: isExpanded,
              isCurrentWeek: true,
              onToggle: () => setState(() => isExpanded = !isExpanded),
              onDayTap: openedDays.add,
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('programme_week_overview_1')),
        findsOneWidget,
      );
      expect(find.byType(ProgrammeDayCard), findsNothing);

      await tester.tap(find.byKey(const ValueKey('programme_week_toggle_1')));
      await tester.pump();

      expect(find.byType(ProgrammeDayCard), findsNWidgets(2));
      await tester.tap(find.byKey(const ValueKey('programme_day_workout_0')));
      await tester.tap(
        find.byKey(const ValueKey('programme_day_rest_1')),
        warnIfMissed: false,
      );
      expect(openedDays, [workout]);
    });

    testWidgets('overview opens workout days and leaves recovery inert', (
      tester,
    ) async {
      final workout = _CalendarWidgetFixtures.workoutDay();
      final rest = _CalendarWidgetFixtures.restDay();
      final openedDays = <DayViewData>[];

      await tester.pumpWidget(
        _CalendarWidgetFixtures.wrap(
          ProgrammeWeekSection(
            week: _CalendarWidgetFixtures.week(days: [workout, rest]),
            isExpanded: false,
            isCurrentWeek: true,
            onToggle: () {},
            onDayTap: openedDays.add,
          ),
        ),
      );

      final workoutTile = find.byKey(
        const ValueKey('programme_day_overview_0'),
      );
      final restTile = find.byKey(const ValueKey('programme_day_overview_1'));
      expect(tester.widget<Semantics>(workoutTile).properties.button, isTrue);
      expect(tester.widget<Semantics>(restTile).properties.button, isNull);
      expect(tester.widget<Semantics>(restTile).properties.onTap, isNull);
      expect(
        tester.getSize(workoutTile).width,
        greaterThanOrEqualTo(AppProgrammeCalendarTokens.controlSize),
      );
      expect(
        tester.getSize(workoutTile).height,
        greaterThanOrEqualTo(AppProgrammeCalendarTokens.controlSize),
      );

      await tester.tap(workoutTile);
      await tester.tap(restTile);
      expect(openedDays, [workout]);
      expect(find.byType(ProgrammeDayCard), findsNothing);
    });

    testWidgets('overview describes completion, skipped, recovery and today', (
      tester,
    ) async {
      final week = _CalendarWidgetFixtures.week(
        days: [
          _CalendarWidgetFixtures.workoutDay(
            isToday: true,
            status: ProgramWorkoutStatus.completed,
          ),
          _CalendarWidgetFixtures.restDay(),
          _CalendarWidgetFixtures.workoutDay(
            dayIndex: 2,
            status: ProgramWorkoutStatus.skipped,
          ),
        ],
      );

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

      final completed = tester.widget<Semantics>(
        find.byKey(const ValueKey('programme_day_overview_0')),
      );
      final recovery = tester.widget<Semantics>(
        find.byKey(const ValueKey('programme_day_overview_1')),
      );
      final skipped = tester.widget<Semantics>(
        find.byKey(const ValueKey('programme_day_overview_2')),
      );
      expect(completed.properties.label, 'Monday, Completed, Today');
      expect(recovery.properties.label, 'Tuesday, Rest');
      expect(skipped.properties.label, 'Wednesday, Skipped');
      expect(completed.properties.button, isNull);
    });

    for (final isDark in [false, true]) {
      testWidgets(
        'supports 320px and 2x text in ${isDark ? 'dark' : 'light'} theme',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(320, 900);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          const longTitle =
              'Upper Body Strength and Controlled Hypertrophy Session';
          final days = List.generate(
            7,
            (index) => index.isEven
                ? _CalendarWidgetFixtures.workoutDay(
                    dayIndex: index,
                    isToday: index == 0,
                    title: longTitle,
                    status: index == 0
                        ? ProgramWorkoutStatus.started
                        : ProgramWorkoutStatus.planned,
                  )
                : _CalendarWidgetFixtures.restDay(dayIndex: index),
          );

          await tester.pumpWidget(
            _CalendarWidgetFixtures.wrap(
              ProgrammeWeekSection(
                week: _CalendarWidgetFixtures.week(days: days),
                isExpanded: true,
                isCurrentWeek: true,
                onToggle: () {},
                onDayTap: (_) {},
              ),
              isDark: isDark,
              textScale: 2,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(ProgrammeDayCard), findsNWidgets(7));
          final title = tester.widget<Text>(find.text(longTitle).first);
          expect(title.maxLines, isNull);
          expect(title.overflow, isNot(TextOverflow.ellipsis));

          final overview = find.byKey(
            const ValueKey('programme_week_overview_1'),
          );
          final horizontalScroll = find.descendant(
            of: overview,
            matching: find.byType(SingleChildScrollView),
          );
          expect(horizontalScroll, findsOneWidget);
          expect(
            tester
                .widget<SingleChildScrollView>(horizontalScroll)
                .scrollDirection,
            Axis.horizontal,
          );
          await tester.drag(horizontalScroll, const Offset(-600, 0));
          await tester.pumpAndSettle();
          expect(
            tester.getRect(find.text('Sun')).right,
            lessThanOrEqualTo(tester.getRect(overview).right),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
