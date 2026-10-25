import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/set_log_dao.dart';
import 'package:aedify/core/db/daos/workout_session_dao.dart';
import 'package:aedify/core/db/daos/workout_session_exercise_dao.dart';
import 'package:aedify/features/lift_log/data/drift_workout_history_repository.dart';
import 'package:aedify/features/lift_log/presentation/workout_history_detail_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'history correction validates, persists actuals and refreshes detail',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final date = DateTime(2026, 10, 24);
      await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              id: 'session',
              source: 'standalone',
              name: 'Local workout',
              startedAt: date,
              completedAt: Value(date.add(const Duration(hours: 1))),
              status: 'completed',
              createdAt: date,
              updatedAt: date,
            ),
          );
      await db
          .into(db.workoutSessionExercises)
          .insert(
            WorkoutSessionExercisesCompanion.insert(
              id: 'exercise',
              workoutSessionId: 'session',
              exerciseId: 7,
              exerciseNameSnapshot: 'Squat snapshot',
              sortOrder: 0,
            ),
          );
      await db
          .into(db.setLogs)
          .insert(
            SetLogsCompanion.insert(
              id: 'set',
              workoutSessionExerciseId: 'exercise',
              exerciseId: 7,
              performedAt: date,
              setIndex: 0,
              actualReps: const Value(8),
              actualWeightKg: const Value(90),
              actualRir: const Value(3),
              completed: const Value(true),
              createdAt: date,
              updatedAt: date,
            ),
          );
      final repository = DriftWorkoutHistoryRepository(
        workoutSessionDao: WorkoutSessionDao(db),
        workoutSessionExerciseDao: WorkoutSessionExerciseDao(db),
        setLogDao: SetLogDao(db),
      );
      final router = GoRouter(
        initialLocation: '/history',
        routes: [
          GoRoute(
            path: '/history',
            builder: (_, _) =>
                const WorkoutHistoryDetailScreen(sessionId: 'session'),
          ),
          GoRoute(
            path: AppRoutes.workoutRunnerRepeat().path,
            name: AppRoutes.workoutRunnerRepeat().name,
            builder: (_, _) => const Scaffold(body: Text('Repeat started')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            AppProviders.workoutHistoryRepositoryProvider.overrideWithValue(
              repository,
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('history_correct_set')));
      await tester.pumpAndSettle();
      final effort = find.byKey(
        ValueKey('history_correction_${AppStrings.actualRpe}'),
      );
      expect(
        tester
            .widget<TextField>(
              find.descendant(of: effort, matching: find.byType(TextField)),
            )
            .controller!
            .text,
        '7.0',
      );
      expect(
        find.byKey(ValueKey('history_correction_${AppStrings.actualRir}')),
        findsNothing,
      );
      await tester.enterText(
        find.byKey(const ValueKey('history_correction_Actual reps')),
        '0',
      );
      await tester.ensureVisible(
        find.byKey(const Key('history_save_correction')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('history_save_correction')));
      await tester.pumpAndSettle();
      expect(
        find.text(AppErrorStrings.workoutHistoryCorrectionInvalid),
        findsOneWidget,
      );
      expect(
        (await repository.getSessionDetail(
          'session',
        ))!.exercises.single.sets.single.actualReps,
        8,
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey('history_correction_Actual reps')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('history_correction_Actual reps')),
        '10',
      );
      await tester.ensureVisible(effort);
      await tester.enterText(effort, '9');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await db.customStatement('''
      CREATE TRIGGER reject_correction BEFORE UPDATE ON set_logs
      BEGIN SELECT RAISE(ABORT, 'injected correction failure'); END
    ''');
      await tester.ensureVisible(
        find.byKey(const Key('history_save_correction')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('history_save_correction')));
      await tester.pumpAndSettle();
      expect(
        find.text(AppErrorStrings.workoutHistoryCorrectionFailed),
        findsOneWidget,
      );
      expect(
        (await repository.getSessionDetail(
          'session',
        ))!.exercises.single.sets.single.actualReps,
        8,
      );
      await db.customStatement('DROP TRIGGER reject_correction');
      await tester.ensureVisible(
        find.byKey(const Key('history_save_correction')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('history_save_correction')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('history_save_correction')), findsNothing);
      expect(find.text('10 reps'), findsOneWidget);
      final corrected = (await repository.getSessionDetail(
        'session',
      ))!.exercises.single.sets.single;
      expect(corrected.actualRpe, 9);
      expect(corrected.actualRir, 1);
      expect(find.text('Squat snapshot'), findsOneWidget);
      expect(
        (await repository.getSessionDetail(
          'session',
        ))!.exercises.single.sets.single.actualReps,
        10,
      );
      await tester.ensureVisible(
        find.byKey(const Key('history_repeat_workout')),
      );
      await tester.tap(find.byKey(const Key('history_repeat_workout')));
      await tester.pumpAndSettle();
      expect(find.text('Repeat started'), findsOneWidget);
    },
  );
}
