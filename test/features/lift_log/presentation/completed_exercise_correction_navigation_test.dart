import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_correction_sheet.dart';
import 'package:aedify/features/lift_log/presentation/workout_history_detail_screen.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/features/workout_execution/application/workout_runner_mapper.dart';
import 'package:aedify/features/workout_execution/presentation/finish_early_session_complete_screen.dart';
import 'package:aedify/features/workout_execution/presentation/workout_complete_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

abstract final class _CorrectionFixture {
  static Future<void> seed(
    AppDatabase db, {
    ExerciseLoggingType type = ExerciseLoggingType.repsWeight,
    bool mixed = false,
  }) async {
    final at = DateTime(2026, 10, 25, 10);
    await db
        .into(db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            id: 'session',
            source: 'standalone',
            name: 'Saved local workout',
            startedAt: at,
            completedAt: Value(at.add(const Duration(hours: 1))),
            status: 'completed',
            createdAt: at,
            updatedAt: at,
          ),
        );
    for (final name
        in mixed ? ['complete', 'partial', 'skipped'] : ['complete']) {
      await db
          .into(db.workoutSessionExercises)
          .insert(
            WorkoutSessionExercisesCompanion.insert(
              id: name,
              workoutSessionId: 'session',
              exerciseId: 7,
              exerciseNameSnapshot: '$name movement',
              sortOrder: name == 'complete'
                  ? 0
                  : name == 'partial'
                  ? 1
                  : 2,
              loggingType: Value(type.dbValue),
              supersetGroupId: mixed
                  ? const Value('paired')
                  : const Value.absent(),
            ),
          );
      for (var index = 0; index < (name == 'partial' ? 2 : 1); index++) {
        await db
            .into(db.setLogs)
            .insert(
              SetLogsCompanion.insert(
                id: '$name-$index',
                workoutSessionExerciseId: name,
                exerciseId: 7,
                performedAt: at,
                setIndex: index,
                actualReps: const Value(8),
                actualWeightKg: const Value(40),
                actualDurationSeconds: type == ExerciseLoggingType.duration
                    ? const Value(60)
                    : const Value.absent(),
                actualDistanceMeters: type == ExerciseLoggingType.duration
                    ? const Value(200)
                    : const Value.absent(),
                actualRpe: const Value(8),
                actualRir: const Value(2),
                completed: Value(
                  name == 'complete' || name == 'partial' && index == 0,
                ),
                skipped: Value(name == 'skipped'),
                createdAt: at,
                updatedAt: at,
              ),
            );
      }
    }
  }

  static Future<void> pumpFrames(WidgetTester tester) async {
    for (var frame = 0; frame < 8; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  static Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await pumpFrames(tester);
    await tester.tap(finder);
    await pumpFrames(tester);
  }
}

void main() {
  for (final early in [false, true]) {
    testWidgets(
      '${early ? 'early' : 'full'} summary opens completed exercise logs and refreshes corrected results',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = AppDatabase(NativeDatabase.memory());
        final container = ProviderContainer(
          overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
        );
        addTearDown(() async {
          container.dispose();
          await db.close();
        });
        await _CorrectionFixture.seed(db, mixed: true);
        final aggregate = (await container
            .read(AppProviders.workoutSessionRepositoryProvider)
            .getSession('session'))!;
        final session = const WorkoutRunnerMapper().toViewData(aggregate);
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => early
                  ? FinishEarlySessionCompleteScreen(session: session)
                  : WorkoutCompleteScreen(session: session),
            ),
            GoRoute(
              path: AppRoutes.workoutHistoryDetail().path,
              name: AppRoutes.workoutHistoryDetail().name,
              builder: (_, _) =>
                  const WorkoutHistoryDetailScreen(sessionId: 'session'),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: AppTheme.lightTheme,
              routerConfig: router,
            ),
          ),
        );
        await _CorrectionFixture.pumpFrames(tester);
        final completed = find.byKey(
          const ValueKey('completion_exercise_complete'),
        );
        final partial = find.byKey(
          const ValueKey('completion_exercise_partial'),
        );
        expect(tester.widget<InkWell>(completed).onTap, isNotNull);
        expect(tester.widget<InkWell>(partial).onTap, isNotNull);
        if (!early) {
          expect(
            tester
                .widget<InkWell>(
                  find.byKey(const ValueKey('completion_exercise_skipped')),
                )
                .onTap,
            isNull,
          );
        }
        await _CorrectionFixture.tap(tester, partial);
        expect(find.byType(WorkoutHistoryDetailScreen), findsOneWidget);
        router.pop();
        await _CorrectionFixture.pumpFrames(tester);
        await _CorrectionFixture.tap(tester, completed);
        expect(find.byType(WorkoutHistoryDetailScreen), findsOneWidget);
        expect(
          find.byKey(const ValueKey('history_correct_partial-0')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('history_correct_partial-1')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('history_correct_skipped-0')),
          findsNothing,
        );
        await _CorrectionFixture.tap(
          tester,
          find.byKey(const ValueKey('history_correct_complete-0')),
        );
        expect(
          find.byKey(
            ValueKey('history_correction_${WorkoutHistoryStrings.seconds}'),
          ),
          findsNothing,
        );
        expect(
          find.byKey(
            ValueKey('history_correction_${WorkoutHistoryStrings.meters}'),
          ),
          findsNothing,
        );
        expect(
          find.byKey(ValueKey('history_correction_${AppStrings.actualRir}')),
          findsNothing,
        );
        final reps = find.byKey(
          ValueKey('history_correction_${AppStrings.actualReps}'),
        );
        await tester.ensureVisible(reps);
        await tester.enterText(reps, '10');
        FocusManager.instance.primaryFocus?.unfocus();
        await _CorrectionFixture.pumpFrames(tester);
        await _CorrectionFixture.tap(
          tester,
          find.byKey(const Key('history_save_correction')),
        );
        final saved = (await container
            .read(AppProviders.workoutHistoryRepositoryProvider)
            .getSessionDetail('session'))!;
        expect(saved.exercises.first.sets.single.actualReps, 10);
        router.pop();
        await _CorrectionFixture.pumpFrames(tester);
        expect(find.text('720'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      },
    );
  }

  for (final type in [
    ExerciseLoggingType.repsOnly,
    ExerciseLoggingType.duration,
  ]) {
    testWidgets(
      '${type.name} correction shows only relevant metrics and preserves hidden results',
      (tester) async {
        final db = AppDatabase(NativeDatabase.memory());
        final container = ProviderContainer(
          overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
        );
        addTearDown(() async {
          container.dispose();
          await db.close();
        });
        await _CorrectionFixture.seed(db, type: type);
        final history = container.read(
          AppProviders.workoutHistoryRepositoryProvider,
        );
        final item = (await history.getSessionDetail(
          'session',
        ))!.exercises.single.sets.single;
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: Text('Saved')),
            ),
            GoRoute(
              path: '/edit',
              builder: (_, _) => Scaffold(
                body: WorkoutHistoryCorrectionSheet(
                  sessionId: 'session',
                  item: item,
                ),
              ),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: AppTheme.darkTheme,
              routerConfig: router,
            ),
          ),
        );
        router.push('/edit');
        await tester.pumpAndSettle();
        expect(
          find.byKey(ValueKey('history_correction_${AppStrings.actualWeight}')),
          findsNothing,
        );
        expect(
          find.byKey(ValueKey('history_correction_${AppStrings.actualReps}')),
          type == ExerciseLoggingType.repsOnly ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(
            ValueKey('history_correction_${WorkoutHistoryStrings.seconds}'),
          ),
          type == ExerciseLoggingType.duration ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(ValueKey('history_correction_${AppStrings.actualRpe}')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('history_correction_${AppStrings.setNotes}')),
          findsOneWidget,
        );
        if (type == ExerciseLoggingType.duration) {
          final distance = find.byKey(
            ValueKey('history_correction_${WorkoutHistoryStrings.meters}'),
          );
          await tester.ensureVisible(distance);
          await tester.enterText(distance, '');
        }
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await _CorrectionFixture.tap(
          tester,
          find.byKey(const Key('history_save_correction')),
        );
        expect(find.text('Saved'), findsOneWidget);
        final saved = (await history.getSessionDetail(
          'session',
        ))!.exercises.single.sets.single;
        expect(saved.actualWeightKg, 40);
        expect(saved.actualReps, 8);
        if (type == ExerciseLoggingType.duration) {
          expect(saved.actualDurationSeconds, 60);
          expect(saved.actualDistanceMeters, isNull);
        }
      },
    );
  }
}
