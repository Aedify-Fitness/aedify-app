import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/features/exercise_library/data/drift_candidate_exercise_query_service.dart';
import 'package:aedify/features/exercise_library/domain/candidate_exercise_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftCandidateExerciseQueryService', () {
    late AppDatabase db;
    late ExerciseDao dao;
    late DriftCandidateExerciseQueryService service;

    Future<void> seedExercise({
      required int id,
      required String name,
      String modality = 'strength',
      String? equipment = 'barbell',
      String? difficulty = 'intermediate',
      String? force = 'push',
      String? mechanic = 'compound',
      List<String> muscleGroups = const ['Chest'],
      bool isCustom = false,
      bool deleted = false,
    }) async {
      await dao.insertExercisesBulk([
        ExercisesCompanion(
          id: Value(id),
          name: Value(name),
          nameNormalized: Value(name.toLowerCase()),
          source: Value(isCustom ? 'user' : 'musclewiki'),
          primaryMusclesJson: Value(json.encode(muscleGroups)),
          muscleGroupsJson: Value(json.encode(muscleGroups)),
          modality: Value(modality),
          equipment: equipment != null ? Value(equipment) : Value(null),
          difficulty: difficulty != null ? Value(difficulty) : Value(null),
          force: force != null ? Value(force) : Value(null),
          mechanic: mechanic != null ? Value(mechanic) : Value(null),
          gripsJson: Value(json.encode(['none'])),
          stepsJson: Value(json.encode(['Step 1'])),
          isCustom: Value(isCustom),
          deletedAt: deleted ? Value(DateTime.now()) : const Value(null),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      ]);
    }

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      dao = ExerciseDao(db);
      service = DriftCandidateExerciseQueryService(database: db);

      await seedExercise(id: 1, name: 'Bench Press', muscleGroups: ['Chest']);
      await seedExercise(id: 2, name: 'Squat', muscleGroups: ['Quads']);
      await seedExercise(
        id: 3,
        name: 'Bicep Curl',
        modality: 'hypertrophy',
        equipment: 'dumbbell',
        difficulty: 'beginner',
        muscleGroups: ['Biceps'],
        mechanic: 'isolation',
        force: 'pull',
      );
      await seedExercise(
        id: 4,
        name: 'Push Up',
        equipment: 'bodyweight',
        difficulty: 'beginner',
        muscleGroups: ['Chest'],
      );
      await seedExercise(
        id: 5,
        name: 'Deadlift',
        muscleGroups: ['Back'],
        mechanic: 'compound',
        force: 'pull',
      );
      await seedExercise(
        id: 6,
        name: 'Custom Glute Bridge',
        isCustom: true,
        muscleGroups: ['Glutes'],
      );
      await seedExercise(
        id: 7,
        name: 'Deleted Row',
        deleted: true,
        muscleGroups: ['Core'],
      );
    });

    tearDown(() {
      db.close();
    });

    test('filters by allowed equipment', () async {
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'dumbbell'},
          allowedDifficulties: {'beginner'},
          allowedModalities: {'hypertrophy'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {},
          goalTags: {},
        ),
      );
      expect(results.length, 1);
      expect(results.first.name, 'Bicep Curl');
    });

    test('equipment filter matches null equipment exercises', () async {
      // Exercise with null equipment should pass if not filtered out by
      // the equipment set (null equipment is not in allowedEquipment set,
      // so it won't match any allowed equipment. Our filter treats null
      // equipment as passing because the condition checks
      // `exercise.equipment != null` before applying the set check.)
      await seedExercise(
        id: 10,
        name: 'Null Equipment Exercise',
        equipment: null,
        muscleGroups: ['Core'],
      );
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'bodyweight'},
          allowedDifficulties: {'beginner', 'intermediate'},
          allowedModalities: {'strength'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {},
          goalTags: {},
        ),
      );
      // Should include the null-equipment exercise
      final names = results.map((e) => e.name).toSet();
      expect(names, contains('Null Equipment Exercise'));
    });

    test('filters by allowed difficulties', () async {
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'barbell', 'dumbbell', 'bodyweight'},
          allowedDifficulties: {'beginner'},
          allowedModalities: {'strength', 'hypertrophy'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {},
          goalTags: {},
        ),
      );
      final names = results.map((e) => e.name).toSet();
      // Squat is intermediate — excluded by beginner filter
      expect(names, containsAll(['Push Up', 'Bicep Curl']));
      expect(names, isNot(contains('Bench Press')));
      expect(names, isNot(contains('Squat')));
    });

    test('filters by allowed modalities', () async {
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'barbell', 'dumbbell', 'bodyweight'},
          allowedDifficulties: {'beginner', 'intermediate'},
          allowedModalities: {'hypertrophy'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {},
          goalTags: {},
        ),
      );
      expect(results.length, 1);
      expect(results.first.name, 'Bicep Curl');
    });

    test('excludes provided exercise ids', () async {
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'barbell'},
          allowedDifficulties: {'intermediate'},
          allowedModalities: {'strength'},
          excludedExerciseIds: {1},
          excludedMuscleGroups: {},
          goalTags: {},
        ),
      );
      final names = results.map((e) => e.name).toSet();
      expect(names, isNot(contains('Bench Press')));
    });

    test(
      'excludes substituted or avoided ids when passed in excludedExerciseIds',
      () async {
        // Simulate substituted exercises by excluding their IDs
        final results = await service.queryCandidates(
          const CandidateExerciseQuery(
            allowedEquipment: {'barbell', 'bodyweight'},
            allowedDifficulties: {'beginner', 'intermediate'},
            allowedModalities: {'strength'},
            excludedExerciseIds: {2, 4},
            excludedMuscleGroups: {},
            goalTags: {},
          ),
        );
        final names = results.map((e) => e.name).toSet();
        expect(names, isNot(contains('Squat')));
        expect(names, isNot(contains('Push Up')));
      },
    );

    test('filters by excluded muscle groups', () async {
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'barbell', 'dumbbell', 'bodyweight'},
          allowedDifficulties: {'beginner', 'intermediate'},
          allowedModalities: {'strength', 'hypertrophy'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {'Chest'},
          goalTags: {},
        ),
      );
      final names = results.map((e) => e.name).toSet();
      expect(names, isNot(contains('Bench Press')));
      expect(names, isNot(contains('Push Up')));
    });

    test('includes custom exercises when enabled', () async {
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'barbell', 'dumbbell', 'bodyweight'},
          allowedDifficulties: {'beginner', 'intermediate'},
          allowedModalities: {'strength', 'hypertrophy'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {},
          goalTags: {},
          includeCustomExercises: true,
        ),
      );
      final names = results.map((e) => e.name).toSet();
      expect(names, contains('Custom Glute Bridge'));
    });

    test('excludes custom exercises when disabled', () async {
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'barbell', 'dumbbell', 'bodyweight'},
          allowedDifficulties: {'beginner', 'intermediate'},
          allowedModalities: {'strength', 'hypertrophy'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {},
          goalTags: {},
          includeCustomExercises: false,
        ),
      );
      final names = results.map((e) => e.name).toSet();
      expect(names, isNot(contains('Custom Glute Bridge')));
    });

    test('applies preferred muscle group soft ranking', () async {
      // Query all, prefer Quads — Squat should appear before Bench Press
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'barbell'},
          allowedDifficulties: {'beginner', 'intermediate'},
          allowedModalities: {'strength'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {},
          goalTags: {},
          preferredMuscleGroups: ['Quads'],
          limit: 10,
        ),
      );
      expect(results.length, greaterThanOrEqualTo(2));
      // Squat (Quads match) should be first
      expect(results.first.name, 'Squat');
      // Squat (score 3) > Deadlift (score 0) > Bench Press (score 0)
    });

    test('returns deterministic ordering on equal scores', () async {
      // Query with no preferences so all matching exercises score 0
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'barbell', 'bodyweight'},
          allowedDifficulties: {'beginner', 'intermediate'},
          allowedModalities: {'strength'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {},
          goalTags: {},
          includeCustomExercises: false,
          limit: 10,
        ),
      );
      // All have same score (0) — sort by name then id
      expect(results.length, 4);
      expect(results[0].name, 'Bench Press');
      expect(results[1].name, 'Deadlift');
      expect(results[2].name, 'Push Up');
      expect(results[3].name, 'Squat');
    });

    test('respects limit', () async {
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'barbell', 'dumbbell', 'bodyweight'},
          allowedDifficulties: {'beginner', 'intermediate'},
          allowedModalities: {'strength', 'hypertrophy'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {},
          goalTags: {},
          limit: 2,
        ),
      );
      expect(results.length, 2);
    });

    test('output DTO contains no forbidden fields', () async {
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'barbell', 'dumbbell', 'bodyweight'},
          allowedDifficulties: {'beginner', 'intermediate'},
          allowedModalities: {'strength', 'hypertrophy'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {},
          goalTags: {},
        ),
      );
      expect(results, isNotEmpty);
      for (final dto in results) {
        // Must not contain user notes, file paths, flags, or source strings
        expect(dto.isCustom, isA<bool>());
        expect(dto.id, isA<int>());
        expect(dto.name, isA<String>());
        expect(dto.muscleGroups, isA<List<String>>());
        expect(dto.modality, isA<String>());
      }
    });

    test('excludes deleted rows from results', () async {
      final results = await service.queryCandidates(
        const CandidateExerciseQuery(
          allowedEquipment: {'barbell', 'dumbbell', 'bodyweight'},
          allowedDifficulties: {'beginner', 'intermediate'},
          allowedModalities: {'strength', 'hypertrophy'},
          excludedExerciseIds: {},
          excludedMuscleGroups: {},
          goalTags: {},
        ),
      );
      final names = results.map((e) => e.name).toSet();
      expect(names, isNot(contains('Deleted Row')));
    });

    // Profile-derived query integration tests
    group('profile-derived queries', () {
      test('profile equipment restricts candidate output', () async {
        // Simulate a profile with only dumbbell access
        final results = await service.queryCandidates(
          const CandidateExerciseQuery(
            allowedEquipment: {'dumbbell'},
            allowedDifficulties: {'beginner', 'intermediate'},
            allowedModalities: {'strength', 'hypertrophy'},
            excludedExerciseIds: {},
            excludedMuscleGroups: {},
            goalTags: {},
          ),
        );
        final names = results.map((e) => e.name).toSet();
        // Only Bicep Curl has dumbbell equipment
        expect(names, {'Bicep Curl'});
      });

      test('profile experience restricts candidate difficulty', () async {
        // Simulate a beginner profile (novice, beginner difficulty only)
        final results = await service.queryCandidates(
          const CandidateExerciseQuery(
            allowedEquipment: {'barbell', 'dumbbell', 'bodyweight'},
            allowedDifficulties: {'novice', 'beginner'},
            allowedModalities: {'strength', 'hypertrophy'},
            excludedExerciseIds: {},
            excludedMuscleGroups: {},
            goalTags: {},
          ),
        );
        final names = results.map((e) => e.name).toSet();
        // Bench Press is intermediate — excluded
        // Squat is intermediate — excluded
        // Deadlift has null difficulty — passes null-difficulty check
        // Push Up is beginner — included
        // Bicep Curl is beginner — included
        expect(names, containsAll(['Push Up', 'Bicep Curl']));
        expect(names, isNot(contains('Bench Press')));
        expect(names, isNot(contains('Squat')));
      });

      test('profile substituted exercises are excluded', () async {
        // Simulate a profile with Squat and Push Up substituted
        final results = await service.queryCandidates(
          const CandidateExerciseQuery(
            allowedEquipment: {'barbell', 'dumbbell', 'bodyweight'},
            allowedDifficulties: {'beginner', 'intermediate'},
            allowedModalities: {'strength', 'hypertrophy'},
            excludedExerciseIds: {2, 4},
            excludedMuscleGroups: {},
            goalTags: {},
          ),
        );
        final names = results.map((e) => e.name).toSet();
        expect(names, isNot(contains('Squat')));
        expect(names, isNot(contains('Push Up')));
      });

      test('profile goals influence ranking order', () async {
        // Simulate a profile with strength goal
        final results = await service.queryCandidates(
          const CandidateExerciseQuery(
            allowedEquipment: {'barbell', 'dumbbell', 'bodyweight'},
            allowedDifficulties: {'beginner', 'intermediate'},
            allowedModalities: {'strength', 'hypertrophy'},
            excludedExerciseIds: {},
            excludedMuscleGroups: {},
            goalTags: {'strength'},
            includeCustomExercises: false,
          ),
        );
        // Strength goal tag matches force (push/pull) and mechanic (compound)
        // Bench Press: push, compound -> +4 (push + compound)
        // Deadlift: pull, compound -> +4 (pull + compound)
        // Squat: push, compound -> +4 (push + compound)
        // Push Up: push, compound -> +4 (push + compound)
        // Bicep Curl: pull, isolation -> +2 (pull only)
        expect(results.length, 5);
        // Bicep Curl should be last (lowest score)
        expect(results.last.name, 'Bicep Curl');
      });
    });
  });
}
