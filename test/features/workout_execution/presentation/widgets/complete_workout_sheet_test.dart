import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_completion_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/complete_workout_sheet.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';

Widget _wrapApp(Widget body) {
  return MaterialApp(
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    home: Scaffold(body: body),
  );
}

void main() {
  final session = WorkoutRunnerSessionViewData(
    sessionId: 'session-1',
    name: 'Morning Push',
    source: SessionSource.savedWorkout,
    status: WorkoutSessionStatus.inProgress,
    startedAt: DateTime(2025, 6, 1, 10, 0, 0),
    exercises: [],
  );

  group('CompleteWorkoutSheet', () {
    testWidgets('renders session name and duration', (tester) async {
      await tester.pumpWidget(
        _wrapApp(CompleteWorkoutSheet(session: session, onComplete: (_) {})),
      );

      expect(find.text(AppStrings.finishWorkoutSummary), findsOneWidget);
      expect(find.text('Morning Push'), findsOneWidget);
      expect(find.textContaining('min'), findsOneWidget);
    });

    testWidgets('calls onComplete with draft when button is tapped', (
      tester,
    ) async {
      WorkoutRunnerCompletionDraft? capturedDraft;
      await tester.pumpWidget(
        _wrapApp(
          CompleteWorkoutSheet(
            session: session,
            onComplete: (draft) => capturedDraft = draft,
          ),
        ),
      );

      await tester.tap(find.text(AppStrings.completeWorkout));

      expect(capturedDraft, isNotNull);
      expect(capturedDraft!.sessionId, 'session-1');
      expect(capturedDraft!.notes, isNull);
    });

    testWidgets('includes notes and ratings when present in session', (
      tester,
    ) async {
      final sessionWithDetails = session.copyWith(
        notes: 'Great workout',
        energyLevel: 8,
        perceivedDifficulty: 6,
      );

      WorkoutRunnerCompletionDraft? capturedDraft;
      await tester.pumpWidget(
        _wrapApp(
          CompleteWorkoutSheet(
            session: sessionWithDetails,
            onComplete: (draft) => capturedDraft = draft,
          ),
        ),
      );

      await tester.tap(find.text(AppStrings.completeWorkout));

      expect(capturedDraft!.notes, 'Great workout');
      expect(capturedDraft!.energyLevel, 8);
      expect(capturedDraft!.perceivedDifficulty, 6);
    });

    testWidgets(
      'renders volume, sets, and exercises summary with logged data',
      (tester) async {
        final sessionWithData = session.copyWith(
          exercises: [
            WorkoutRunnerExerciseItem(
              id: 'ex-1',
              exerciseId: 1,
              exerciseName: 'Bench Press',
              sortOrder: 0,
              sets: [
                WorkoutRunnerSetItem(
                  id: 's1',
                  exerciseId: 1,
                  setIndex: 0,
                  setType: SetType.working,
                  performedAt: DateTime(2025, 6, 1),
                  completed: true,
                  skipped: false,
                  actualWeightKg: 60.0,
                  actualReps: 10,
                ),
                WorkoutRunnerSetItem(
                  id: 's2',
                  exerciseId: 1,
                  setIndex: 1,
                  setType: SetType.working,
                  performedAt: DateTime(2025, 6, 1),
                  completed: true,
                  skipped: false,
                  actualWeightKg: 60.0,
                  actualReps: 8,
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          _wrapApp(
            CompleteWorkoutSheet(session: sessionWithData, onComplete: (_) {}),
          ),
        );

        // Total volume: 60*10 + 60*8 = 1080 kg
        expect(find.textContaining('1080'), findsOneWidget);
        // 2/2 sets completed
        expect(find.text('2 / 2'), findsOneWidget);
        // 1/1 exercises completed
        expect(find.text('1 / 1'), findsOneWidget);
      },
    );

    testWidgets('shows zero values when no logged data', (tester) async {
      await tester.pumpWidget(
        _wrapApp(CompleteWorkoutSheet(session: session, onComplete: (_) {})),
      );

      expect(find.text('0 kg'), findsOneWidget);
      expect(find.text('0 / 0'), findsNWidgets(2));
    });

    testWidgets('uses duration from session when available', (tester) async {
      final sessionWithDuration = session.copyWith(durationSeconds: 3600);
      await tester.pumpWidget(
        _wrapApp(
          CompleteWorkoutSheet(
            session: sessionWithDuration,
            onComplete: (_) {},
          ),
        ),
      );

      expect(find.text('60 min'), findsOneWidget);
    });
  });
}
