import 'package:aedify/shared/constants/app_strings.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/presentation/workout_runner_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'local weight suggestion, manual acceptance, next-set adjustment and correction refresh',
    (tester) async {
      final previousHttp = HttpOverrides.current;
      final network = _WeightBlockedNetwork();
      HttpOverrides.global = network;
      addTearDown(() => HttpOverrides.global = previousHttp);
      final root = await Directory(
        (await getTemporaryDirectory()).path,
      ).createTemp('aedify_weight_');
      final db = AppDatabase(
        NativeDatabase(File(p.join(root.path, 'workout.sqlite'))),
      );
      final container = ProviderContainer(
        overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
      );
      final exerciseId = await container
          .read(AppProviders.exerciseRepositoryProvider)
          .createCustomExercise(
            const CustomExerciseSeed(
              name: 'Device bench press',
              muscleGroups: {BodymapBucket.chest},
              modality: ExerciseModality.strength,
              loggingType: ExerciseLoggingType.repsWeight,
              steps: ['Press smoothly.'],
            ),
          );
      final now = DateTime.now().subtract(const Duration(days: 1));
      await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              id: 'history',
              source: 'standalone',
              name: 'Synthetic history',
              startedAt: now,
              status: 'completed',
              completedAt: Value(now),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.workoutSessionExercises)
          .insert(
            WorkoutSessionExercisesCompanion.insert(
              id: 'history-member',
              workoutSessionId: 'history',
              exerciseId: exerciseId,
              exerciseNameSnapshot: 'Device bench press',
              sortOrder: 0,
              loggingType: const Value('repsWeight'),
            ),
          );
      await db
          .into(db.setLogs)
          .insert(
            SetLogsCompanion.insert(
              id: 'history-set',
              workoutSessionExerciseId: 'history-member',
              exerciseId: exerciseId,
              performedAt: now,
              setIndex: 0,
              createdAt: now,
              updatedAt: now,
              completed: const Value(true),
              actualWeightKg: const Value(100),
              actualReps: const Value(5),
              actualRpe: const Value(9),
            ),
          );
      final session = await container
          .read(AppProviders.startWorkoutSessionUseCaseProvider)
          .startStandalone();
      final argument = (
        mode: WorkoutRunnerMode.resume,
        savedWorkoutId: null as String?,
        programId: null as String?,
        programWorkoutId: null as String?,
      );
      final provider = AppProviders.workoutRunnerControllerProvider(argument);
      final runnerSubscription = container.listen(provider, (_, _) {});
      await container.read(provider.future);
      final controller = container.read(provider.notifier);
      await controller.resumeRecoveredSession();
      await controller.addExercises([
        ExerciseReference(
          exerciseId: exerciseId,
          name: 'Device bench press',
          modality: 'strength',
          loggingType: 'repsWeight',
          isCustom: true,
        ),
      ]);
      final memberId = container
          .read(provider)
          .requireValue
          .session!
          .exercises
          .single
          .id;
      await controller.addSet(exerciseId: memberId);
      await controller.saveProgress();
      expect(
        container.read(provider).requireValue.session!.exercises.single.sets,
        hasLength(2),
      );
      final router = GoRouter(
        initialLocation: AppRoutes.workoutRunnerActive().path,
        routes: [
          GoRoute(
            path: AppRoutes.workoutRunnerActive().path,
            name: AppRoutes.workoutRunnerActive().name,
            builder: (_, _) => WorkoutRunnerScreen.resume(
              launchedSessionId: session.sessionId,
            ),
          ),
        ],
      );
      addTearDown(() async {
        router.dispose();
        runnerSubscription.close();
        container.dispose();
        await db.close();
        await root.delete(recursive: true);
      });
      Widget app(bool dark) => UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(
          key: const Key('weight_preview'),
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
          ),
        ),
      );
      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(app(false));
      await tester.pumpAndSettle();
      await tap(find.byKey(const Key('runner_choose_weight_target')));
      await tap(find.byKey(const Key('weight_estimate_calculate')));
      await _WeightPreview.waitFor(tester, find.text('Suggested 95 kg'));
      final activeBefore = container
          .read(provider)
          .requireValue
          .session!
          .exercises
          .single
          .sets
          .first;
      expect(activeBefore.actualWeightKg, isNull);
      expect(activeBefore.completed, isFalse);
      await _WeightPreview.capture(tester, 'aedify_weight_light.png');
      // A history correction refreshes the suggestion without re-opening the runner.
      await (db.update(db.setLogs)
            ..where((row) => row.id.equals('history-set')))
          .write(const SetLogsCompanion(actualWeightKg: Value(110)));
      await tester.pumpAndSettle();
      await _WeightPreview.waitFor(tester, find.text('Suggested 105 kg'));
      await tap(find.byKey(const Key('runner_use_suggested_weight')));
      var active = container
          .read(provider)
          .requireValue
          .session!
          .exercises
          .single
          .sets
          .first;
      expect(active.actualWeightKg, 105);
      expect(active.actualReps, isNull);
      expect(active.completed, isFalse);
      final reps = find.byKey(const Key('active_reps_field'));
      await tester.ensureVisible(reps);
      await tester.enterText(reps, '5');
      await tester.pumpAndSettle();
      final rpe = find.byKey(const Key('active_rpe_field'));
      await tester.ensureVisible(rpe);
      await tester.enterText(rpe, '10');
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      active = container
          .read(provider)
          .requireValue
          .session!
          .exercises
          .single
          .sets
          .first;
      expect(active.actualReps, 5);
      expect(active.actualRpe, 10);
      expect(active.actualWeightKg, 105);
      await tap(find.byKey(ValueKey('workout_runner_set_action_${active.id}')));
      expect(
        container
            .read(provider)
            .requireValue
            .session!
            .exercises
            .single
            .sets
            .first
            .completed,
        isTrue,
      );
      if (find.text(AppStrings.skipRest).evaluate().isNotEmpty) {
        await tap(find.text(AppStrings.skipRest));
      }
      // Standalone target is retained; the latest logged working set now anchors it.
      await _WeightPreview.waitFor(tester, find.text('Suggested 97.5 kg'));
      await tester.pumpWidget(app(true));
      await tester.pumpAndSettle();
      await _WeightPreview.capture(tester, 'aedify_weight_dark.png');
      await tap(find.byKey(const Key('runner_weight_suggestion_reason')));
      expect(find.textContaining('latest logged working set'), findsOneWidget);
      expect(find.textContaining('105 kg × 5 @ RPE 10'), findsOneWidget);
      await _WeightPreview.capture(tester, 'aedify_weight_reason_dark.png');
      router.pop();
      await tester.pumpAndSettle();
      await controller.saveProgress();
      final records = await db.select(db.setLogs).get();
      expect(
        records.every((row) => row.estimated1rmKg == null && !row.isPr),
        isTrue,
      );
      expect(
        records
            .where((row) => row.id != 'history-set' && !row.completed)
            .single
            .actualWeightKg,
        isNull,
      );
      expect(network.attempts, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}

abstract final class _WeightPreview {
  static Future<void> waitFor(WidgetTester tester, Finder finder) async {
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finder, findsOneWidget);
  }

  static Future<void> capture(WidgetTester tester, String name) async {
    await tester.pump();
    final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
      find.byKey(const Key('weight_preview')),
    );
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = await getTemporaryDirectory();
    await File(
      p.join(directory.path, name),
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  }
}

class _WeightBlockedNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError(
      'Network disabled during local weight-suggestion acceptance',
    );
  }
}
