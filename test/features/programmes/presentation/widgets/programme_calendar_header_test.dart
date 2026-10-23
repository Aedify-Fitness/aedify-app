import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_calendar_header.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/program_workout_status.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

abstract final class _HeaderFixtures {
  static DayViewData day({
    String? id = 'workout-today',
    bool isRestDay = false,
    ProgramWorkoutStatus status = ProgramWorkoutStatus.planned,
  }) => DayViewData(
    workoutId: id,
    scheduledDayIndex: 0,
    dayLabel: 'Monday',
    title: isRestDay ? AppStrings.activeRecovery : 'Upper Body Strength',
    exerciseCount: isRestDay ? 0 : 4,
    durationMinutes: isRestDay ? 0 : 45,
    status: status,
    isToday: id == 'workout-today',
    isRestDay: isRestDay,
    exercisePreview: const [],
  );

  static WeekViewData week(int number, List<DayViewData> days) => WeekViewData(
    weekId: 'week-$number',
    weekNumber: number,
    weekType: WeekType.normal,
    isCurrentWeek: number == 1,
    isWeekCompleted: false,
    isWeekSkipped: false,
    days: days,
  );

  static ProgrammeCalendarViewData viewData({
    String? todayWorkoutId = 'workout-today',
    List<WeekViewData>? weeks,
    bool isActive = true,
    String name = 'Strength Foundation',
  }) => ProgrammeCalendarViewData(
    name: name,
    description: 'A focused training block with room for recovery.',
    blockType: 'Base',
    weeksTotal: 4,
    daysPerWeek: 3,
    isActive: isActive,
    weeks:
        weeks ??
        [
          week(1, [day()]),
        ],
    todayWeekNumber: 1,
    todayDayIndex: 0,
    todayWorkoutId: todayWorkoutId,
  );

  static WorkoutRunnerSessionViewData session({
    String? programId = 'programme-1',
    String? workoutId = 'workout-today',
  }) => WorkoutRunnerSessionViewData(
    sessionId: 'active-session',
    name: 'Active workout',
    source: SessionSource.program,
    status: WorkoutSessionStatus.inProgress,
    startedAt: DateTime(2026, 10, 23),
    exercises: const [],
    programId: programId,
    programWorkoutId: workoutId,
  );

  static Widget app({
    ProgrammeCalendarViewData? data,
    WorkoutRunnerSessionViewData? activeSession,
    ThemeData? theme,
    double textScale = 1,
    VoidCallback? onStart,
    VoidCallback? onResume,
    VoidCallback? onBack,
    VoidCallback? onEdit,
  }) => MaterialApp(
    theme: theme ?? AppTheme.lightTheme,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ProgrammeCalendarHeader(
            viewData: data ?? viewData(),
            activeSession: activeSession,
            programId: 'programme-1',
            onStartTodayWorkout: onStart,
            onResumeTodayWorkout: onResume ?? () {},
            onBack: onBack ?? () {},
            onEdit: onEdit ?? () {},
          ),
        ),
      ),
    ),
  );

  static void mobileSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
}

void main() {
  group('Programme calendar header', () {
    testWidgets('shows the actual scheduled workout and starts it', (
      tester,
    ) async {
      var startCount = 0;
      await tester.pumpWidget(_HeaderFixtures.app(onStart: () => startCount++));

      expect(find.text('Upper Body Strength'), findsOneWidget);
      expect(find.text('4 ${AppStrings.movements}'), findsOneWidget);
      expect(
        find.text('45${AppStrings.durationMinutesAbbreviation}'),
        findsOneWidget,
      );
      expect(find.text(AppStrings.scheduledToday), findsOneWidget);
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      expect(startCount, 1);
    });

    testWidgets('resumes only the matching programme occurrence', (
      tester,
    ) async {
      var startCount = 0;
      var resumeCount = 0;
      await tester.pumpWidget(
        _HeaderFixtures.app(
          activeSession: _HeaderFixtures.session(),
          onStart: () => startCount++,
          onResume: () => resumeCount++,
        ),
      );

      expect(find.text(AppStrings.resumeWorkout), findsOneWidget);
      expect(find.text(AppStrings.sessionInProgress), findsOneWidget);
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      expect(resumeCount, 1);
      expect(startCount, 0);
    });

    for (final mismatch in [
      (programId: 'other-programme', workoutId: 'workout-today'),
      (programId: 'programme-1', workoutId: 'other-workout'),
      (programId: null, workoutId: null),
    ]) {
      testWidgets('blocks another active session $mismatch', (tester) async {
        var startCount = 0;
        var resumeCount = 0;
        await tester.pumpWidget(
          _HeaderFixtures.app(
            activeSession: _HeaderFixtures.session(
              programId: mismatch.programId,
              workoutId: mismatch.workoutId,
            ),
            onStart: () => startCount++,
            onResume: () => resumeCount++,
          ),
        );

        expect(find.text(AppStrings.workoutInProgress), findsOneWidget);
        expect(find.text(AppStrings.resumeWorkout), findsNothing);
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        await tester.ensureVisible(find.byType(FilledButton));
        await tester.tap(find.byType(FilledButton));
        expect(startCount, 0);
        expect(resumeCount, 0);
      });
    }

    testWidgets('preserves an unavailable start action', (tester) async {
      await tester.pumpWidget(_HeaderFixtures.app());
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets(
      'counts completed workouts across weeks without rest or skips',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          _HeaderFixtures.app(
            data: _HeaderFixtures.viewData(
              weeks: [
                _HeaderFixtures.week(1, [
                  _HeaderFixtures.day(
                    id: 'completed',
                    status: ProgramWorkoutStatus.completed,
                  ),
                  _HeaderFixtures.day(
                    id: null,
                    isRestDay: true,
                    status: ProgramWorkoutStatus.completed,
                  ),
                ]),
                _HeaderFixtures.week(2, [
                  _HeaderFixtures.day(
                    id: 'skipped',
                    status: ProgramWorkoutStatus.skipped,
                  ),
                  _HeaderFixtures.day(),
                ]),
              ],
            ),
          ),
        );

        expect(
          find.text(AppStrings.programmeWorkoutCompletion(1, 3)),
          findsOneWidget,
        );
        final progress = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progress.value, closeTo(1 / 3, 0.001));
        final progressSemantics = tester
            .getSemantics(
              find.byKey(const ValueKey('programme_calendar_progress')),
            )
            .getSemanticsData();
        expect(
          progressSemantics.label,
          AppStrings.programmeWorkoutCompletion(1, 3),
        );
        expect(progressSemantics.value, '33');
        semantics.dispose();
      },
    );

    testWidgets('omits completion metrics when no workouts are scheduled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _HeaderFixtures.app(
          data: _HeaderFixtures.viewData(
            todayWorkoutId: null,
            weeks: [
              _HeaderFixtures.week(1, [
                _HeaderFixtures.day(id: null, isRestDay: true),
              ]),
            ],
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text(AppStrings.activeRecovery), findsOneWidget);
      expect(find.text(AppStrings.noWorkoutToday), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets(
      'keeps recovery actionless even with a same-programme session',
      (tester) async {
        await tester.pumpWidget(
          _HeaderFixtures.app(
            data: _HeaderFixtures.viewData(todayWorkoutId: null),
            activeSession: _HeaderFixtures.session(workoutId: null),
            onStart: () =>
                fail('No workout should be started on a recovery day.'),
            onResume: () => fail('No scheduled workout exists to resume.'),
          ),
        );

        expect(find.text(AppStrings.workoutInProgress), findsOneWidget);
        expect(find.byType(FilledButton), findsNothing);
        expect(find.text(AppStrings.resumeWorkout), findsNothing);
      },
    );

    testWidgets('labels navigation controls and keeps 48px hit targets', (
      tester,
    ) async {
      var backCount = 0;
      var editCount = 0;
      await tester.pumpWidget(
        _HeaderFixtures.app(
          onBack: () => backCount++,
          onEdit: () => editCount++,
        ),
      );

      for (final label in [AppStrings.backLabel, AppStrings.edit]) {
        final button = find.byTooltip(label);
        final size = tester.getSize(button);
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
        await tester.tap(button);
      }
      expect(backCount, 1);
      expect(editCount, 1);
    });

    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      testWidgets('supports 320px and 2x text in ${theme.brightness.name}', (
        tester,
      ) async {
        _HeaderFixtures.mobileSurface(tester);
        var startCount = 0;
        await tester.pumpWidget(
          _HeaderFixtures.app(
            theme: theme,
            textScale: 2,
            data: _HeaderFixtures.viewData(
              name: 'A long programme title for a focused training season',
            ),
            onStart: () => startCount++,
          ),
        );

        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final button = tester.getRect(find.byType(FilledButton));
        expect(button.left, greaterThanOrEqualTo(0));
        expect(button.right, lessThanOrEqualTo(320));
        await tester.tap(find.byType(FilledButton));
        expect(startCount, 1);

        await tester.pumpWidget(
          _HeaderFixtures.app(
            theme: theme,
            textScale: 2,
            activeSession: _HeaderFixtures.session(),
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.resumeWorkout), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          _HeaderFixtures.app(
            theme: theme,
            textScale: 2,
            data: _HeaderFixtures.viewData(
              todayWorkoutId: null,
              isActive: false,
            ),
          ),
        );
        await tester.ensureVisible(find.text(AppStrings.activeRecovery));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.programmeInactive), findsOneWidget);
        expect(find.byType(FilledButton), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
