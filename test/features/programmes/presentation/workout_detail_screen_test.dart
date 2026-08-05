import 'dart:convert';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/features/programmes/presentation/workout_detail_screen.dart';
import 'package:aedify/features/workout_builder/data/saved_workout_repository.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_aggregate.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_draft.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeSavedWorkoutRepository implements SavedWorkoutRepository {
  const _FakeSavedWorkoutRepository(this.aggregate);

  final SavedWorkoutAggregate aggregate;

  @override
  Future<SavedWorkoutAggregate?> getSavedWorkout(String id) async => aggregate;

  @override
  Future<List<SavedWorkoutAggregate>> listSavedWorkouts({
    String? status,
  }) async {
    return [aggregate];
  }

  @override
  Future<String> saveSavedWorkout(SavedWorkoutDraft draft) async => draft.id;

  @override
  Future<void> archiveSavedWorkout(String id) async {}

  @override
  Future<void> deleteSavedWorkout(String id) async {}
}

class _WorkoutDetailTestData {
  _WorkoutDetailTestData._();

  static final now = DateTime.utc(2026, 8, 5);

  static SavedWorkoutAggregate aggregate() {
    return SavedWorkoutAggregate(
      savedWorkout: SavedWorkout(
        id: 'legs-a',
        name: 'Legs A',
        source: 'manual',
        creationMethod: 'manual',
        status: 'active',
        estimatedDurationMinutes: 75,
        goalTagsJson: jsonEncode(['power rebuild programme']),
        equipmentJson: '[]',
        imported: false,
        createdAt: now,
        updatedAt: now,
      ),
      exercises: [
        SavedWorkoutExercise(
          id: 'plank',
          savedWorkoutId: 'legs-a',
          exerciseId: 1,
          loggingType: 'duration',
          supersetGroupId: 'superset-a',
          supersetOrder: 0,
          sortOrder: 0,
          createdAt: now,
        ),
        SavedWorkoutExercise(
          id: 'squat',
          savedWorkoutId: 'legs-a',
          exerciseId: 2,
          loggingType: 'repsWeight',
          supersetGroupId: 'superset-a',
          supersetOrder: 1,
          sortOrder: 1,
          createdAt: now,
        ),
      ],
      sets: [
        for (var index = 0; index < 2; index++)
          SavedWorkoutExerciseSet(
            id: 'plank-$index',
            savedWorkoutExerciseId: 'plank',
            setIndex: index,
            setType: 'working',
            durationSeconds: 60,
            isCalibrationEstimate: false,
            createdAt: now,
          ),
        for (var index = 0; index < 3; index++)
          SavedWorkoutExerciseSet(
            id: 'squat-$index',
            savedWorkoutExerciseId: 'squat',
            setIndex: index,
            setType: 'working',
            prescribedRepsExact: 20,
            prescribedRpeMin: 9,
            prescribedRpeMax: 9,
            isCalibrationEstimate: false,
            createdAt: now,
          ),
      ],
    );
  }

  static Future<void> seedExercises(AppDatabase database) async {
    await ExerciseDao(database).insertExercisesBulk([
      ExercisesCompanion.insert(
        id: const Value(1),
        source: 'test',
        name: 'Forearm Plank',
        nameNormalized: 'forearm plank',
        primaryMusclesJson: jsonEncode(['Core']),
        muscleGroupsJson: jsonEncode(['Core']),
        modality: 'strength',
        loggingType: const Value('duration'),
        equipment: const Value('bodyweight'),
        gripsJson: '[]',
        stepsJson: '[]',
        createdAt: now,
        updatedAt: now,
      ),
      ExercisesCompanion.insert(
        id: const Value(2),
        source: 'test',
        name: 'Bodyweight Squats',
        nameNormalized: 'bodyweight squats',
        primaryMusclesJson: jsonEncode(['Quads']),
        muscleGroupsJson: jsonEncode(['Quads']),
        modality: 'strength',
        loggingType: const Value('repsWeight'),
        equipment: const Value('bodyweight'),
        gripsJson: '[]',
        stepsJson: '[]',
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }
}

void main() {
  testWidgets('matches the supplied Workout Detail mobile hierarchy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 884);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await _WorkoutDetailTestData.seedExercises(database);
    final repository = _FakeSavedWorkoutRepository(
      _WorkoutDetailTestData.aggregate(),
    );
    final router = GoRouter(
      initialLocation: '/detail',
      routes: [
        GoRoute(
          path: '/detail',
          builder: (_, _) => const WorkoutDetailScreen(workoutId: 'legs-a'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(database),
          AppProviders.savedWorkoutRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final screen = find.byKey(const Key('workout_detail_screen'));
    final hero = find.byKey(const Key('workout_detail_hero'));
    expect(find.text(AppStrings.workoutDetailLoadError), findsNothing);
    expect(screen, findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    expect(
      find.ancestor(of: hero, matching: find.byType(SafeArea)),
      findsOneWidget,
    );
    expect(tester.getTopLeft(hero), const Offset(AppSpacing.gutter, 24));
    expect(find.text('LEGS A'), findsOneWidget);
    expect(find.text('Power Rebuild Programme'), findsOneWidget);
    expect(find.text('2 ${AppStrings.movements}'), findsOneWidget);
    expect(find.text('~75 ${AppStrings.minutes}'), findsOneWidget);

    final exercisesStatIcon = find.descendant(
      of: find.byKey(const Key('workout_detail_stat_icon_Exercises')),
      matching: find.byType(SvgPicture),
    );
    expect(
      tester.getSize(exercisesStatIcon),
      const Size.square(AppSizing.iconMd),
    );

    final flowHeading = tester.widget<Text>(
      find.byKey(const Key('workout_detail_flow_heading')),
    );
    expect(flowHeading.style?.fontSize, AppTextStyles.headlineLg.fontSize);
    expect(
      find.byKey(const Key('workout_detail_superset_group')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('workout_detail_exercise_1')), findsOneWidget);
    expect(find.text('2 x 60s'), findsOneWidget);
    expect(find.text('3 x 20'), findsOneWidget);
    expect(find.text('RPE 9'), findsOneWidget);
    expect(
      find.byKey(const Key('workout_detail_atmospheric_section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('workout_detail_primary_action')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
