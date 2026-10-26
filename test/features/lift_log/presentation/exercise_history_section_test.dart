import 'dart:async';

import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/lift_log/application/workout_history_providers.dart';
import 'package:aedify/features/lift_log/domain/exercise_history_session.dart';
import 'package:aedify/features/lift_log/domain/workout_history_exercise_item.dart';
import 'package:aedify/features/lift_log/domain/workout_history_set_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/exercise_history_section.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('shows loading and empty without invented performance', (
    tester,
  ) async {
    final completer = Completer<List<ExerciseHistorySession>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          WorkoutHistoryProviders.exerciseHistoryProvider.overrideWith(
            (ref, id) => completer.future,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: ExerciseHistorySection(
              exerciseId: 7,
              emptyState: Text('Empty local history'),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('Empty local history'), findsOneWidget);
    expect(find.byKey(const Key('exercise_history_sessions')), findsNothing);
  });

  testWidgets(
    'partial exercises retain only completed logged sets in history',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            WorkoutHistoryProviders.exerciseHistoryProvider.overrideWith(
              (ref, id) async => [
                ExerciseHistorySession(
                  sessionId: 'unfinished',
                  workoutName: 'Finished session',
                  completedAt: DateTime(2026),
                  exercises: const [
                    WorkoutHistoryExerciseItem(
                      id: 'exercise',
                      exerciseId: 7,
                      exerciseName: 'Unfinished exercise',
                      sortOrder: 0,
                      sets: [
                        WorkoutHistorySetItem(
                          id: 'logged',
                          setIndex: 0,
                          setType: SetType.working,
                          completed: true,
                          skipped: false,
                          actualReps: 8,
                        ),
                        WorkoutHistorySetItem(
                          id: 'pending',
                          setIndex: 1,
                          setType: SetType.working,
                          completed: false,
                          skipped: false,
                          actualReps: 6,
                        ),
                      ],
                    ),
                    WorkoutHistoryExerciseItem(
                      id: 'empty',
                      exerciseId: 7,
                      exerciseName: 'Empty exercise',
                      sortOrder: 1,
                      sets: [
                        WorkoutHistorySetItem(
                          id: 'no-results',
                          setIndex: 0,
                          setType: SetType.working,
                          completed: true,
                          skipped: false,
                          prescribedRepsExact: 8,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: ExerciseHistorySection(
                exerciseId: 7,
                emptyState: Text('Empty local history'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Empty local history'), findsNothing);
      expect(find.text('Unfinished exercise'), findsOneWidget);
      expect(find.text('8 reps'), findsOneWidget);
      expect(find.text('6 reps'), findsNothing);
      expect(find.text('Empty exercise'), findsNothing);
      expect(
        find.byKey(const Key('exercise_history_sessions')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'retries failures, renders warmup/working logs and opens source history',
    (tester) async {
      var calls = 0;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(
              body: SingleChildScrollView(
                child: ExerciseHistorySection(
                  exerciseId: 7,
                  emptyState: Text('Empty local history'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.workoutHistoryDetail().path,
            name: AppRoutes.workoutHistoryDetail().name,
            builder: (_, state) => Scaffold(
              body: Text('Session ${state.pathParameters['sessionId']}'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            WorkoutHistoryProviders.exerciseHistoryProvider.overrideWith((
              ref,
              id,
            ) async {
              expect(id, 7);
              if (calls++ == 0) throw StateError('offline local read failure');
              return [
                ExerciseHistorySession(
                  sessionId: 'session',
                  workoutName: 'Upper strength',
                  completedAt: DateTime(2026, 10, 24),
                  exercises: const [
                    WorkoutHistoryExerciseItem(
                      id: 'exercise',
                      exerciseId: 7,
                      exerciseName: 'Bench snapshot',
                      sortOrder: 0,
                      sets: [
                        WorkoutHistorySetItem(
                          id: 'warmup',
                          setIndex: 0,
                          setType: SetType.warmup,
                          completed: true,
                          skipped: false,
                          actualReps: 12,
                          actualWeightKg: 20,
                        ),
                        WorkoutHistorySetItem(
                          id: 'working',
                          setIndex: 1,
                          setType: SetType.working,
                          completed: true,
                          skipped: false,
                          actualReps: 8,
                          actualWeightKg: 80,
                        ),
                        WorkoutHistorySetItem(
                          id: 'skipped',
                          setIndex: 2,
                          setType: SetType.working,
                          completed: false,
                          skipped: true,
                          actualReps: 99,
                        ),
                        WorkoutHistorySetItem(
                          id: 'empty',
                          setIndex: 3,
                          setType: SetType.working,
                          completed: true,
                          skipped: false,
                          prescribedRepsExact: 77,
                        ),
                      ],
                    ),
                  ],
                ),
              ];
            }),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.workoutHistoryLoadFailed), findsOneWidget);
      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();
      expect(find.text('Bench snapshot'), findsOneWidget);
      expect(find.text('12 reps'), findsOneWidget);
      expect(find.text('8 reps'), findsOneWidget);
      expect(find.text('99 reps'), findsNothing);
      expect(find.text('77 reps'), findsNothing);
      expect(find.text(AppStrings.skipped), findsNothing);
      expect(find.text(AppStrings.warmupSet), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('exercise_history_session_session')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Session session'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('history_exercise_exercise')));
      await tester.pumpAndSettle();
      expect(find.text('Session session'), findsOneWidget);
    },
  );
}
