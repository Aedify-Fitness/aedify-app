import 'dart:io';
import 'dart:ui' as ui;

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_detail_screen.dart';
import 'package:aedify/features/lift_log/presentation/lift_log_screen.dart';
import 'package:aedify/features/home/presentation/home_screen.dart';
import 'package:aedify/features/lift_log/presentation/workout_history_detail_screen.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/features/workout_execution/domain/workout_launch_strings.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/presentation/workout_complete_screen.dart';
import 'package:aedify/features/workout_execution/presentation/finish_early_session_complete_screen.dart';
import 'package:aedify/features/workout_execution/presentation/workout_launch_screen.dart';
import 'package:aedify/features/workout_execution/presentation/workout_runner_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
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
    'offline standalone UI, disk recovery, history correction and repeat',
    (tester) async {
      final originalHttp = HttpOverrides.current;
      final blockedNetwork = _M4BlockedNetwork();
      HttpOverrides.global = blockedNetwork;
      addTearDown(() {
        HttpOverrides.global = originalHttp;
      });
      final directory = await getTemporaryDirectory();
      final file = File(p.join(directory.path, 'aedify_m4_smoke.sqlite'));
      if (await file.exists()) {
        await file.delete();
      }
      var db = AppDatabase(NativeDatabase(file));
      var container = ProviderContainer(
        overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
      );
      final exerciseId = await container
          .read(AppProviders.exerciseRepositoryProvider)
          .createCustomExercise(
            const CustomExerciseSeed(
              name: 'Device push-up',
              muscleGroups: {BodymapBucket.chest},
              modality: ExerciseModality.strength,
              loggingType: ExerciseLoggingType.repsOnly,
              steps: ['Lower and press smoothly.'],
            ),
          );
      var router = _M4DeviceHarness.router();
      await _M4DeviceHarness.pump(tester, container, router);
      final manualLog = find.byKey(const Key('home_manual_log_action'));
      await tester.scrollUntilVisible(
        manualLog,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(manualLog);
      await tester.pumpAndSettle();
      await tester.tap(manualLog);
      await tester.pumpAndSettle();
      expect(find.text(WorkoutLaunchStrings.emptyTitle), findsOneWidget);
      await tester.tap(find.text(WorkoutLaunchStrings.addExercises));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Device push-up'));
      await tester.pumpAndSettle();
      final add = find.text(AppStrings.filterConfirmSelection(1));
      await tester.tap(add);
      await tester.pumpAndSettle();
      final reps = find.byKey(const Key('active_reps_field'));
      await tester.ensureVisible(reps);
      await tester.enterText(reps, '12');
      final rpe = find.byKey(const Key('active_rpe_field'));
      await tester.ensureVisible(rpe);
      await tester.enterText(rpe, '8.5');
      expect(find.byKey(const Key('active_rir_field')), findsNothing);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await _M4DeviceHarness.capture(tester, 'aedify_m4_standalone_light.png');
      final provider = AppProviders.workoutRunnerControllerProvider((
        mode: WorkoutRunnerMode.resume,
        savedWorkoutId: null,
        programId: null,
        programWorkoutId: null,
      ));
      final sessionId = container
          .read(provider)
          .requireValue
          .session!
          .sessionId;
      final controller = container.read(provider.notifier);
      await controller.saveProgress();
      await controller.pauseWorkout();
      expect(
        (await container
                .read(AppProviders.workoutSessionRepositoryProvider)
                .getActiveSession())!
            .setLogs
            .single
            .actualReps,
        12,
      );

      // Dispose the entire UI/provider graph and close the SQLite connection.
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      container.dispose();
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      container = ProviderContainer(
        overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
      );
      router = _M4DeviceHarness.router();
      await _M4DeviceHarness.pump(tester, container, router, dark: true);
      // Cold recovery starts at the local home surface, then pushes the runner.
      // Keep that return route beneath the completion summary, as the app does.
      router.pushNamed(AppRoutes.workoutRunnerActive().name);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.sessionInProgress), findsWidgets);
      await tester.tap(find.text(AppStrings.resumeWorkout));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('active_reps_field')), findsOneWidget);
      final recovered = container.read(provider.notifier);
      final exercise = container
          .read(provider)
          .requireValue
          .session!
          .exercises
          .single;
      expect(exercise.sets.single.actualReps, 12);
      expect(exercise.sets.single.actualRpe, 8.5);
      expect(exercise.sets.single.actualRir, 2);
      await _M4DeviceHarness.capture(tester, 'aedify_m4_recovered_dark.png');
      await recovered.toggleSetCompleted(
        exerciseId: exercise.id,
        setId: exercise.sets.single.id,
        completed: true,
      );
      await recovered.completeWorkout();
      // Completion intentionally animates continuously. Navigate as a user
      // would before waiting for an idle history screen.
      for (
        var frame = 0;
        frame < 100 && find.byType(WorkoutCompleteScreen).evaluate().isEmpty;
        frame++
      ) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      if (find.byType(WorkoutCompleteScreen).evaluate().isEmpty) {
        await _M4DeviceHarness.capture(
          tester,
          'aedify_m4_completion_pending.png',
        );
      }
      expect(find.byType(WorkoutCompleteScreen), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      final completedExercise = find.byKey(
        ValueKey('completion_exercise_${exercise.id}'),
      );
      await tester.ensureVisible(completedExercise);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(completedExercise);
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutHistoryDetailScreen), findsOneWidget);
      expect(find.text('Device push-up'), findsOneWidget);
      expect(find.text(WorkoutHistoryStrings.repeatWorkout), findsOneWidget);
      final history = container.read(
        AppProviders.workoutHistoryRepositoryProvider,
      );
      expect(
        (await history.listExerciseHistory(exerciseId)).single.sessionId,
        sessionId,
      );
      await tester.ensureVisible(
        find.text(WorkoutHistoryStrings.correctSet).first,
      );
      await tester.tap(find.text(WorkoutHistoryStrings.correctSet).first);
      await tester.pumpAndSettle();
      expect(
        find.byKey(ValueKey('history_correction_${AppStrings.actualWeight}')),
        findsNothing,
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
      await _M4DeviceHarness.capture(tester, 'aedify_m4_correction_editor.png');
      final actualReps = find.byKey(
        ValueKey('history_correction_${AppStrings.actualReps}'),
      );
      await tester.enterText(actualReps, '14');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.ensureVisible(
        find.text(WorkoutHistoryStrings.saveCorrection),
      );
      await tester.tap(find.text(WorkoutHistoryStrings.saveCorrection));
      await tester.pumpAndSettle();
      expect(
        (await history.getSessionDetail(
          sessionId,
        ))!.exercises.single.sets.single.actualReps,
        14,
      );
      await _M4DeviceHarness.capture(tester, 'aedify_m4_history_dark.png');
      await tester.ensureVisible(
        find.text(WorkoutHistoryStrings.repeatWorkout),
      );
      await tester.tap(find.text(WorkoutHistoryStrings.repeatWorkout));
      await tester.pumpAndSettle();
      final repeated = await container
          .read(AppProviders.workoutSessionRepositoryProvider)
          .getActiveSession();
      expect(repeated!.session.id, isNot(sessionId));
      expect(repeated.setLogs.single.actualReps, isNull);
      expect(repeated.setLogs.single.prescribedRepsExact, 14);
      expect(
        (await history.getSessionDetail(
          sessionId,
        ))!.exercises.single.sets.single.actualReps,
        14,
      );
      expect(tester.takeException(), isNull);
      expect(blockedNetwork.attempts, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      container.dispose();
      await db.close();
      await file.delete();
    },
  );
}

class _M4DeviceHarness {
  const _M4DeviceHarness._();

  static GoRouter router() => GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.home().path,
        name: AppRoutes.home().name,
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.liftLog().path,
        name: AppRoutes.liftLog().name,
        builder: (_, _) => const LiftLogScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutRunnerStandalone().path,
        name: AppRoutes.workoutRunnerStandalone().name,
        builder: (_, _) => const WorkoutLaunchScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutRunnerRepeat().path,
        name: AppRoutes.workoutRunnerRepeat().name,
        builder: (_, state) => WorkoutLaunchScreen(
          sourceSessionId: state.pathParameters['sessionId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.workoutRunnerActive().path,
        name: AppRoutes.workoutRunnerActive().name,
        builder: (_, state) => WorkoutRunnerScreen.resume(
          launchedSessionId: state.extra as String?,
        ),
      ),
      GoRoute(
        path: AppRoutes.workoutHistoryDetail().path,
        name: AppRoutes.workoutHistoryDetail().name,
        builder: (_, state) => WorkoutHistoryDetailScreen(
          sessionId: state.pathParameters['sessionId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.exerciseDetail().path,
        name: AppRoutes.exerciseDetail().name,
        builder: (_, state) => ExerciseDetailScreen(
          exerciseId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.sessionComplete().path,
        name: AppRoutes.sessionComplete().name,
        builder: (_, state) => WorkoutCompleteScreen(
          session: state.extra! as WorkoutRunnerSessionViewData,
        ),
      ),
      GoRoute(
        path: AppRoutes.finishEarlySummary().path,
        name: AppRoutes.finishEarlySummary().name,
        builder: (_, state) => FinishEarlySessionCompleteScreen(
          session: state.extra! as WorkoutRunnerSessionViewData,
        ),
      ),
    ],
  );

  static Future<void> pump(
    WidgetTester tester,
    ProviderContainer container,
    GoRouter router, {
    bool dark = false,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(
          key: const Key('m4_capture'),
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  static Future<void> capture(WidgetTester tester, String name) async {
    await tester.pump();
    final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
      find.byKey(const Key('m4_capture')),
    );
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final directory = await getTemporaryDirectory();
    await File(
      p.join(directory.path, name),
    ).writeAsBytes(bytes!.buffer.asUint8List());
  }
}

class _M4BlockedNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Network is blocked during M4 offline acceptance.');
  }
}
