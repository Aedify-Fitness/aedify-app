import 'dart:async';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/programmes/application/programme_calendar_controller.dart';
import 'package:aedify/features/programmes/application/programme_calendar_state.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/programmes/presentation/programme_calendar_screen.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_section.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/program_workout_status.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _CalendarController extends ProgrammeCalendarController {
  _CalendarController(this.nextState, {this.initial}) : super('fixture');

  ProgrammeCalendarState nextState;
  final Future<ProgrammeCalendarState>? initial;
  int reloadCount = 0;

  @override
  Future<ProgrammeCalendarState> build() async {
    if (initial != null) return await initial!;
    return nextState;
  }

  @override
  Future<void> reload() async {
    reloadCount++;
    state = const AsyncValue.loading();
    state = AsyncValue.data(await Future.value(nextState));
  }

  void fail() {
    state = AsyncValue.error(StateError('fixture failure'), StackTrace.current);
  }
}

class _CalendarFixtures {
  _CalendarFixtures._();

  static const programmeId = 'programme-1';
  static const scrollKey = ValueKey('programme_calendar_scroll');
  static const navigationKey = ValueKey('programme_calendar_week_navigation');

  static ProgrammeCalendarState state({
    int weeks = 16,
    int? currentWeek = 12,
    List<int> omittedWeeks = const [],
    String name = 'Strength Programme',
    bool hasTodayWorkout = true,
  }) {
    return ProgrammeCalendarState(
      viewData: ProgrammeCalendarViewData(
        name: name,
        description: 'Build a steady training habit.',
        weeksTotal: weeks,
        daysPerWeek: 1,
        isActive: true,
        todayWeekNumber: currentWeek,
        todayDayIndex: 0,
        todayWorkoutId: hasTodayWorkout && currentWeek != null
            ? 'workout-$currentWeek'
            : null,
        weeks: [
          for (var number = 1; number <= weeks; number++)
            if (!omittedWeeks.contains(number))
              WeekViewData(
                weekId: 'week-$number',
                weekNumber: number,
                weekType: WeekType.normal,
                isCurrentWeek: number == currentWeek,
                isWeekCompleted: false,
                isWeekSkipped: false,
                days: [
                  DayViewData(
                    workoutId: 'workout-$number',
                    scheduledDayIndex: 0,
                    dayLabel: 'Monday',
                    title: 'Week $number strength',
                    exerciseCount: 3,
                    durationMinutes: 45,
                    status: ProgramWorkoutStatus.planned,
                    isToday: number == currentWeek,
                    isRestDay: false,
                    exercisePreview: const ['Squat', 'Row'],
                  ),
                  const DayViewData(
                    scheduledDayIndex: 1,
                    dayLabel: 'Tuesday',
                    title: AppStrings.activeRecovery,
                    exerciseCount: 0,
                    durationMinutes: 0,
                    status: ProgramWorkoutStatus.planned,
                    isToday: false,
                    isRestDay: true,
                    exercisePreview: [],
                  ),
                ],
              ),
        ],
      ),
    );
  }

  static Widget app({
    required Map<String, _CalendarController> controllers,
    Widget child = const ProgrammeCalendarScreen(programmeId: programmeId),
    GoRouter? router,
    WorkoutRunnerSessionViewData? activeSession,
    ThemeData? theme,
    double textScale = 1,
  }) {
    Widget builder(BuildContext context, Widget? child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    );
    return ProviderScope(
      overrides: [
        for (final entry in controllers.entries)
          AppProviders.programmeCalendarControllerProvider(
            entry.key,
          ).overrideWith(() => entry.value),
        AppProviders.activeWorkoutSessionProvider.overrideWith(
          (ref) async => activeSession,
        ),
      ],
      child: router == null
          ? MaterialApp(
              theme: theme ?? AppTheme.lightTheme,
              builder: builder,
              home: child,
            )
          : MaterialApp.router(
              theme: theme ?? AppTheme.lightTheme,
              builder: builder,
              routerConfig: router,
            ),
    );
  }

  static void mobile(WidgetTester tester, {double width = 390}) {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  static Finder verticalScrollable() => find
      .descendant(
        of: find.byKey(scrollKey),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        ),
      )
      .first;

  static Future<void> reveal(WidgetTester tester, Finder target) async {
    final scrollable = verticalScrollable();
    tester.state<ScrollableState>(scrollable).position.jumpTo(0);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(target, 300, scrollable: scrollable);
    await tester.pumpAndSettle();
  }

  static Future<ProgrammeWeekSection> selectedWeek(WidgetTester tester) async {
    await reveal(tester, find.byType(ProgrammeWeekSection));
    return tester.widget<ProgrammeWeekSection>(
      find.byType(ProgrammeWeekSection),
    );
  }

  static Future<void> selectWeek(WidgetTester tester, int number) async {
    await reveal(tester, find.byKey(navigationKey));
    final tile = find.byKey(ValueKey('programme_calendar_select_week_$number'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  static GoRouter router({ValueChanged<GoRouterState>? onDestination}) {
    final destinations = [
      AppRoutes.programmeBuilderEdit(),
      AppRoutes.programmeWorkoutDetail(),
      AppRoutes.workoutRunnerProgramWorkout(),
      AppRoutes.workoutRunnerActive(),
    ];
    return GoRouter(
      initialLocation: AppRoutes.programmeCalendar().path.replaceFirst(
        ':id',
        programmeId,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.programmeCalendar().path,
          name: AppRoutes.programmeCalendar().name,
          builder: (context, state) =>
              ProgrammeCalendarScreen(programmeId: state.pathParameters['id']!),
        ),
        for (final destination in destinations)
          GoRoute(
            path: destination.path,
            name: destination.name,
            builder: (context, state) {
              onDestination?.call(state);
              return Scaffold(
                body: Center(
                  child: TextButton(
                    key: const ValueKey('return_to_calendar'),
                    onPressed: context.pop,
                    child: Text(destination.name),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

void main() {
  group('ProgrammeCalendarScreen', () {
    testWidgets('reveals distant current week and can return after selection', (
      tester,
    ) async {
      _CalendarFixtures.mobile(tester);
      final controller = _CalendarController(_CalendarFixtures.state());
      await tester.pumpWidget(
        _CalendarFixtures.app(
          controllers: {_CalendarFixtures.programmeId: controller},
        ),
      );
      await tester.pumpAndSettle();

      expect(
        (await _CalendarFixtures.selectedWeek(tester)).week.weekNumber,
        12,
      );
      await _CalendarFixtures.reveal(
        tester,
        find.byKey(_CalendarFixtures.navigationKey),
      );
      await tester.pumpAndSettle();
      expect(
        find
            .byKey(const ValueKey('programme_calendar_select_week_12'))
            .hitTestable(),
        findsOneWidget,
      );
      await _CalendarFixtures.selectWeek(tester, 16);
      expect(
        (await _CalendarFixtures.selectedWeek(tester)).week.weekNumber,
        16,
      );
      expect(find.text('Week 16 strength'), findsOneWidget);
      expect((await _CalendarFixtures.selectedWeek(tester)).isExpanded, isTrue);

      final current = find.byKey(
        const ValueKey('programme_calendar_current_week'),
      );
      await _CalendarFixtures.reveal(tester, current);
      await tester.tap(current);
      await tester.pumpAndSettle();
      expect(
        (await _CalendarFixtures.selectedWeek(tester)).week.weekNumber,
        12,
      );
      expect(current, findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('retains selected week on reload and recovers when removed', (
      tester,
    ) async {
      _CalendarFixtures.mobile(tester);
      final controller = _CalendarController(_CalendarFixtures.state());
      await tester.pumpWidget(
        _CalendarFixtures.app(
          controllers: {_CalendarFixtures.programmeId: controller},
        ),
      );
      await tester.pumpAndSettle();
      await _CalendarFixtures.selectWeek(tester, 16);

      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show();
      await tester.pumpAndSettle();
      expect(controller.reloadCount, 1);
      expect(
        (await _CalendarFixtures.selectedWeek(tester)).week.weekNumber,
        16,
      );

      controller.nextState = _CalendarFixtures.state(omittedWeeks: [16]);
      await controller.reload();
      await tester.pumpAndSettle();
      expect(
        (await _CalendarFixtures.selectedWeek(tester)).week.weekNumber,
        12,
      );

      controller.nextState = _CalendarFixtures.state(
        currentWeek: null,
        omittedWeeks: [12],
      );
      await controller.reload();
      await tester.pumpAndSettle();
      expect((await _CalendarFixtures.selectedWeek(tester)).week.weekNumber, 1);
    });

    testWidgets('resets selection when programme identity changes', (
      tester,
    ) async {
      _CalendarFixtures.mobile(tester);
      final programmeId = ValueNotifier(_CalendarFixtures.programmeId);
      addTearDown(programmeId.dispose);
      await tester.pumpWidget(
        _CalendarFixtures.app(
          controllers: {
            _CalendarFixtures.programmeId: _CalendarController(
              _CalendarFixtures.state(),
            ),
            'programme-2': _CalendarController(
              _CalendarFixtures.state(currentWeek: 3, name: 'Second Programme'),
            ),
          },
          child: ValueListenableBuilder<String>(
            valueListenable: programmeId,
            builder: (context, id, child) =>
                ProgrammeCalendarScreen(programmeId: id),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _CalendarFixtures.selectWeek(tester, 16);
      programmeId.value = 'programme-2';
      await tester.pumpAndSettle();
      expect(find.text('Second Programme'), findsOneWidget);
      expect((await _CalendarFixtures.selectedWeek(tester)).week.weekNumber, 3);
    });

    testWidgets(
      'shows loading, retries both error forms and explains empty data',
      (tester) async {
        _CalendarFixtures.mobile(tester);
        final initial = Completer<ProgrammeCalendarState>();
        final controller = _CalendarController(
          _CalendarFixtures.state(),
          initial: initial.future,
        );
        await tester.pumpWidget(
          _CalendarFixtures.app(
            controllers: {_CalendarFixtures.programmeId: controller},
          ),
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        initial.complete(
          const ProgrammeCalendarState(
            errorMessage: AppStrings.programmeCalendarLoadFailed,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(AppStrings.programmeCalendarLoadFailed),
          findsOneWidget,
        );
        await tester.tap(find.text(AppStrings.retry));
        await tester.pumpAndSettle();
        expect(controller.reloadCount, 1);
        expect(
          (await _CalendarFixtures.selectedWeek(tester)).week.weekNumber,
          12,
        );

        controller.fail();
        await tester.pumpAndSettle();
        expect(
          find.text(AppStrings.programmeCalendarLoadFailed),
          findsOneWidget,
        );
        controller.nextState = _CalendarFixtures.state(
          weeks: 0,
          currentWeek: null,
          hasTodayWorkout: false,
        );
        await tester.tap(find.text(AppStrings.retry));
        await tester.pumpAndSettle();
        expect(controller.reloadCount, 2);
        await _CalendarFixtures.reveal(
          tester,
          find.text(AppStrings.noWeeksAdded),
        );
        expect(find.text(AppStrings.noWeeksAdded), findsOneWidget);
        expect(
          find.text(AppStrings.programmeEmptyScheduleHint),
          findsOneWidget,
        );
        expect(find.byType(ProgrammeWeekSection), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    for (final destination in ['edit', 'detail', 'start', 'resume']) {
      testWidgets('$destination uses its named route and reloads on return', (
        tester,
      ) async {
        _CalendarFixtures.mobile(tester);
        final controller = _CalendarController(
          _CalendarFixtures.state(weeks: 1, currentWeek: 1),
        );
        String? visitedLocation;
        final router = _CalendarFixtures.router(
          onDestination: (state) => visitedLocation = state.uri.path,
        );
        addTearDown(router.dispose);
        final active = destination == 'resume'
            ? WorkoutRunnerSessionViewData(
                sessionId: 'session-1',
                name: 'Week 1 strength',
                source: SessionSource.program,
                status: WorkoutSessionStatus.inProgress,
                startedAt: DateTime(2026, 10, 23),
                programId: _CalendarFixtures.programmeId,
                programWorkoutId: 'workout-1',
                exercises: const [],
              )
            : null;
        await tester.pumpWidget(
          _CalendarFixtures.app(
            controllers: {_CalendarFixtures.programmeId: controller},
            router: router,
            activeSession: active,
          ),
        );
        await tester.pumpAndSettle();
        final Finder action = switch (destination) {
          'edit' => find.byTooltip(AppStrings.edit),
          'detail' => find.byKey(const ValueKey('programme_day_workout_0')),
          'start' => find.text(AppStrings.startTodaysWorkout),
          _ => find.text(AppStrings.resumeWorkout),
        };
        await _CalendarFixtures.reveal(tester, action);
        await tester.tap(action);
        await tester.pumpAndSettle();

        final expected = switch (destination) {
          'edit' => '/programmes/programme-1/edit',
          'detail' => '/programmes/programme-1/workouts/workout-1',
          'start' => '/programmes/programme-1/workouts/workout-1/run',
          _ => '/workout/active',
        };
        expect(visitedLocation, expected);
        await tester.tap(find.byKey(const ValueKey('return_to_calendar')));
        await tester.pumpAndSettle();
        expect(controller.reloadCount, 1);
        expect(find.byType(ProgrammeCalendarScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    for (final dark in [false, true]) {
      testWidgets(
        'supports 320px and 2x text in ${dark ? 'dark' : 'light'} mode',
        (tester) async {
          _CalendarFixtures.mobile(tester, width: 320);
          await tester.pumpWidget(
            _CalendarFixtures.app(
              controllers: {
                _CalendarFixtures.programmeId: _CalendarController(
                  _CalendarFixtures.state(),
                ),
              },
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              textScale: 2,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await _CalendarFixtures.selectWeek(tester, 16);
          await _CalendarFixtures.reveal(
            tester,
            find.byKey(const ValueKey('programme_day_rest_1')),
          );
          await tester.pumpAndSettle();
          expect(
            (await _CalendarFixtures.selectedWeek(tester)).week.weekNumber,
            16,
          );
          expect(find.text(AppStrings.activeRecovery), findsWidgets);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
