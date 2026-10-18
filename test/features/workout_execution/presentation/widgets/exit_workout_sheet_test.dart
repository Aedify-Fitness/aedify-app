import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/exit_workout_sheet.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _SheetActions {
  int dismissals = 0;
  int finishes = 0;
  int pauses = 0;
  int abandons = 0;

  void expectNoWorkoutActions() {
    expect(finishes, 0);
    expect(pauses, 0);
    expect(abandons, 0);
  }
}

class _ExitSheetFixture {
  _ExitSheetFixture._();

  static Future<_SheetActions> open(
    WidgetTester tester, {
    bool withCloseCallback = true,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final actions = _SheetActions();
    final session = WorkoutRunnerSessionViewData(
      sessionId: 'session',
      name: 'Push workout',
      source: SessionSource.savedWorkout,
      status: WorkoutSessionStatus.inProgress,
      startedAt: DateTime(2026, 10, 17),
      durationSeconds: 120,
      exercises: const [],
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (sheetContext) => ExitWorkoutSheet(
                    session: session,
                    onClose: withCloseCallback
                        ? () {
                            actions.dismissals++;
                            sheetContext.pop();
                          }
                        : null,
                    onFinishAndSave: () => actions.finishes++,
                    onPause: () => actions.pauses++,
                    onAbandon: () => actions.abandons++,
                  ),
                ),
                child: const Text(AppStrings.exitWorkout),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.lightTheme),
    );
    await tester.tap(find.text(AppStrings.exitWorkout));
    await tester.pumpAndSettle();
    expect(find.byType(ExitWorkoutSheet), findsOneWidget);
    return actions;
  }
}

void main() {
  testWidgets('close dismisses the sheet without changing the workout', (
    tester,
  ) async {
    final actions = await _ExitSheetFixture.open(tester);

    await tester.tap(find.byTooltip(AppStrings.close));
    await tester.pumpAndSettle();

    expect(find.byType(ExitWorkoutSheet), findsNothing);
    expect(find.text(AppStrings.exitWorkout), findsOneWidget);
    expect(actions.dismissals, 1);
    actions.expectNoWorkoutActions();
  });

  testWidgets('close dismisses when no close callback is supplied', (
    tester,
  ) async {
    final actions = await _ExitSheetFixture.open(
      tester,
      withCloseCallback: false,
    );

    await tester.tap(find.byTooltip(AppStrings.close));
    await tester.pumpAndSettle();

    expect(find.byType(ExitWorkoutSheet), findsNothing);
    actions.expectNoWorkoutActions();
  });

  testWidgets('tapping the backdrop dismisses without changing the workout', (
    tester,
  ) async {
    final actions = await _ExitSheetFixture.open(tester);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(find.byType(ExitWorkoutSheet), findsNothing);
    actions.expectNoWorkoutActions();
  });

  testWidgets('tapping beside the card dismisses the sheet', (tester) async {
    final actions = await _ExitSheetFixture.open(tester);
    final titleCenter = tester.getCenter(
      find.text(AppStrings.exitWorkoutTitle),
    );

    await tester.tapAt(Offset(4, titleCenter.dy));
    await tester.pumpAndSettle();

    expect(find.byType(ExitWorkoutSheet), findsNothing);
    expect(actions.dismissals, 1);
    actions.expectNoWorkoutActions();
  });

  testWidgets('tapping card content keeps the exit choices visible', (
    tester,
  ) async {
    final actions = await _ExitSheetFixture.open(tester);

    await tester.tap(find.text(AppStrings.exitWorkoutMessage));
    await tester.pumpAndSettle();

    expect(find.byType(ExitWorkoutSheet), findsOneWidget);
    expect(actions.dismissals, 0);
    actions.expectNoWorkoutActions();
  });

  testWidgets('system back dismisses only the exit sheet', (tester) async {
    final actions = await _ExitSheetFixture.open(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(ExitWorkoutSheet), findsNothing);
    expect(find.text(AppStrings.exitWorkout), findsOneWidget);
    actions.expectNoWorkoutActions();
  });

  for (final label in [
    AppStrings.finishAndSave,
    AppStrings.pauseWorkout,
    AppStrings.abandonSession,
  ]) {
    testWidgets('$label invokes only its workout action', (tester) async {
      final actions = await _ExitSheetFixture.open(tester);

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(actions.finishes, label == AppStrings.finishAndSave ? 1 : 0);
      expect(actions.pauses, label == AppStrings.pauseWorkout ? 1 : 0);
      expect(actions.abandons, label == AppStrings.abandonSession ? 1 : 0);
      expect(actions.dismissals, 0);
      expect(find.byType(ExitWorkoutSheet), findsOneWidget);
    });
  }
}
