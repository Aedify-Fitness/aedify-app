import 'dart:async';

import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_resume_banner.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_session_status.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ResumeBannerFixture {
  _ResumeBannerFixture._();

  static WorkoutRunnerSessionViewData session() => WorkoutRunnerSessionViewData(
    sessionId: 'recovered-session',
    name: 'Upper body training',
    source: SessionSource.savedWorkout,
    status: WorkoutSessionStatus.inProgress,
    startedAt: DateTime.utc(2026, 10, 24),
    durationSeconds: 630,
    exercises: [
      for (var index = 0; index < 2; index++)
        WorkoutRunnerExerciseItem(
          id: 'exercise-$index',
          exerciseId: index + 1,
          exerciseName: index == 0
              ? 'Bench press'
              : 'Chest-supported single-arm dumbbell row',
          sortOrder: index,
          sets: [
            WorkoutRunnerSetItem(
              id: 'set-$index',
              exerciseId: index + 1,
              setIndex: 0,
              setType: SetType.working,
              performedAt: DateTime.utc(2026, 10, 24),
              completed: index == 0,
              skipped: false,
              prescribedRepsExact: 10,
              prescribedWeightKg: 20,
            ),
          ],
        ),
    ],
  );

  static Finder get resume =>
      find.widgetWithText(FilledButton, AppStrings.resumeWorkout);

  static Finder get abandon =>
      find.widgetWithText(OutlinedButton, AppStrings.abandonWorkout);

  static Future<void> pump(
    WidgetTester tester, {
    Future<void> Function()? onResume,
    Future<void> Function()? onDiscard,
    Future<void> Function()? onRetry,
    String? error,
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        home: MediaQuery(
          data: MediaQueryData(
            size: tester.view.physicalSize / tester.view.devicePixelRatio,
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: Scaffold(
            body: SafeArea(
              child: WorkoutRunnerResumeBanner(
                session: session(),
                onResume: onResume ?? () async {},
                onDiscard: onDiscard ?? () async {},
                errorMessage: error,
                onRetry: onRetry,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  static Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
  }
}

void main() {
  testWidgets('restores the saved session context and Resume/Abandon actions', (
    tester,
  ) async {
    var resumed = 0;
    var discarded = 0;
    await _ResumeBannerFixture.pump(
      tester,
      onResume: () async => resumed++,
      onDiscard: () async => discarded++,
    );
    for (final label in [
      AppStrings.sessionInProgress,
      AppStrings.resumeSessionSubtitle,
      'Upper body training',
      AppStrings.inProgressLabel.toUpperCase(),
      AppStrings.timeElapsed,
      '10:30',
      AppStrings.exercisesCompleted,
      AppStrings.currentExercise,
      'Chest-supported single-arm dumbbell row',
      AppStrings.runnerProgressPercent(50),
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(
      find.text(AppStrings.runnerExerciseFraction(1, 2), findRichText: true),
      findsOneWidget,
    );
    await _ResumeBannerFixture.tap(tester, _ResumeBannerFixture.resume);
    await tester.pumpAndSettle();
    expect(resumed, 1);
    await _ResumeBannerFixture.tap(tester, _ResumeBannerFixture.abandon);
    await tester.pumpAndSettle();
    expect(discarded, 1);
  });

  testWidgets(
    'pending resume or abandon prevents duplicate and competing actions',
    (tester) async {
      for (final resumeFirst in [true, false]) {
        final pending = Completer<void>();
        var resumed = 0;
        var discarded = 0;
        var retried = 0;
        await _ResumeBannerFixture.pump(
          tester,
          error: AppStrings.workoutRunnerSaveFailed,
          onResume: () async {
            resumed++;
            await pending.future;
          },
          onDiscard: () async {
            discarded++;
            await pending.future;
          },
          onRetry: () async => retried++,
        );
        final resume = tester
            .widget<FilledButton>(_ResumeBannerFixture.resume)
            .onPressed!;
        final discard = tester
            .widget<OutlinedButton>(_ResumeBannerFixture.abandon)
            .onPressed!;
        final retry = tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, AppStrings.retry),
            )
            .onPressed!;
        await _ResumeBannerFixture.tap(
          tester,
          resumeFirst
              ? _ResumeBannerFixture.resume
              : _ResumeBannerFixture.abandon,
        );
        resume();
        discard();
        retry();
        await tester.pump();
        expect(resumed, resumeFirst ? 1 : 0);
        expect(discarded, resumeFirst ? 0 : 1);
        expect(retried, 0);
        expect(
          tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
          isNull,
        );
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        pending.complete();
        await tester.pumpAndSettle();
        expect(
          tester.widget<FilledButton>(_ResumeBannerFixture.resume).onPressed,
          isNotNull,
        );
        expect(
          tester.widget<OutlinedButton>(_ResumeBannerFixture.abandon).onPressed,
          isNotNull,
        );
      }
    },
  );

  testWidgets(
    'pending retry keeps the saved session visible and guards actions',
    (tester) async {
      final pending = Completer<void>();
      var retried = 0;
      var resumed = 0;
      var discarded = 0;
      await _ResumeBannerFixture.pump(
        tester,
        error: AppStrings.workoutRunnerSaveFailed,
        onResume: () async => resumed++,
        onDiscard: () async => discarded++,
        onRetry: () async {
          retried++;
          await pending.future;
        },
      );
      final resume = tester
          .widget<FilledButton>(_ResumeBannerFixture.resume)
          .onPressed!;
      final discard = tester
          .widget<OutlinedButton>(_ResumeBannerFixture.abandon)
          .onPressed!;
      final retryFinder = find.widgetWithText(TextButton, AppStrings.retry);
      final retry = tester.widget<TextButton>(retryFinder).onPressed!;
      await _ResumeBannerFixture.tap(tester, retryFinder);
      retry();
      resume();
      discard();
      await tester.pump();
      expect(retried, 1);
      expect(resumed, 0);
      expect(discarded, 0);
      expect(find.text('Upper body training'), findsOneWidget);
      expect(find.text(AppStrings.workoutRunnerSaveFailed), findsOneWidget);
      pending.complete();
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(_ResumeBannerFixture.resume).onPressed,
        isNotNull,
      );
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      '320px and 2x text preserve both actions in ${brightness.name}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var resumed = 0;
        var discarded = 0;
        await _ResumeBannerFixture.pump(
          tester,
          brightness: brightness,
          textScale: 2,
          onResume: () async => resumed++,
          onDiscard: () async => discarded++,
        );
        expect(tester.takeException(), isNull);
        for (final action in [
          _ResumeBannerFixture.resume,
          _ResumeBannerFixture.abandon,
        ]) {
          await tester.ensureVisible(action);
          await tester.pumpAndSettle();
          expect(action.hitTestable(), findsOneWidget);
          expect(
            tester.getSize(action).height,
            greaterThanOrEqualTo(AppWorkoutRunnerTokens.controlSize),
          );
          await tester.tap(action);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(resumed, 1);
        expect(discarded, 1);
      },
    );
  }
}
