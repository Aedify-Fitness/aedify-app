import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/workout_execution/data/weight_suggestion_repository.dart';
import 'package:aedify/features/workout_execution/domain/weight_suggestion.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late DriftWeightSuggestionRepository repository;
  late int exerciseId;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
    );
    exerciseId = await container
        .read(AppProviders.exerciseRepositoryProvider)
        .createCustomExercise(
          const CustomExerciseSeed(
            name: 'Local bench press',
            muscleGroups: {BodymapBucket.chest},
            modality: ExerciseModality.strength,
            loggingType: ExerciseLoggingType.repsWeight,
            steps: [],
          ),
        );
    repository = DriftWeightSuggestionRepository(db);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> seed(
    String id, {
    String status = 'completed',
    String type = 'working',
    bool completed = true,
    bool skipped = false,
    int? logExerciseId,
    double? rpe = 9,
    int? rir,
    String? snapshot = 'repsWeight',
  }) async {
    final now = DateTime.now();
    await db
        .into(db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            id: id,
            source: 'standalone',
            name: 'Local workout',
            startedAt: now,
            status: status,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.workoutSessionExercises)
        .insert(
          WorkoutSessionExercisesCompanion.insert(
            id: 'member-$id',
            workoutSessionId: id,
            exerciseId: exerciseId,
            exerciseNameSnapshot: 'Local press',
            sortOrder: 0,
            loggingType: Value(snapshot),
          ),
        );
    await db
        .into(db.setLogs)
        .insert(
          SetLogsCompanion.insert(
            id: 'set-$id',
            workoutSessionExerciseId: 'member-$id',
            exerciseId: logExerciseId ?? exerciseId,
            performedAt: now,
            setIndex: 0,
            createdAt: now,
            updatedAt: now,
            setType: Value(type),
            completed: Value(completed),
            skipped: Value(skipped),
            actualWeightKg: const Value(100),
            actualReps: const Value(5),
            actualRpe: Value(rpe),
            actualRir: Value(rir),
          ),
        );
  }

  test(
    'only completed working logs from completed sessions and matching exercise qualify',
    () async {
      await seed('valid');
      await seed('warmup', type: 'warmup');
      await seed('active', status: 'in_progress');
      await seed('abandoned', status: 'abandoned');
      await seed('deleted', status: 'deleted');
      await seed('pending', completed: false);
      await seed('skipped', skipped: true);
      await seed('different', logExerciseId: exerciseId + 1);
      await seed('duration', snapshot: 'duration');
      final evidence = await repository.loadEvidence(exerciseId);
      expect(evidence.supported, isTrue);
      expect(evidence.references.map((reference) => reference.id), [
        'set-valid',
      ]);
    },
  );

  test(
    'legacy actual RIR can supply effort but missing effort is never guessed',
    () async {
      await seed('rir', rpe: null, rir: 2);
      final evidence = await repository.loadEvidence(exerciseId);
      expect(evidence.references.single.rpe, 8);
    },
  );

  test('only user-entered known max anchors provide the fallback', () async {
    final now = DateTime.now();
    for (final source in ['user_entered', 'ai_seeded', 'log_derived']) {
      await db
          .into(db.strengthAnchors)
          .insert(
            StrengthAnchorsCompanion.insert(
              id: source,
              exerciseId: exerciseId,
              anchorType: 'known_1rm',
              weightKg: const Value(120),
              source: source,
              loggedAt: Value(now),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    final evidence = await repository.loadEvidence(exerciseId);
    expect(evidence.references, hasLength(1));
    expect(evidence.references.single.source, LoadReferenceSource.knownMax);
  });

  test(
    'corrections and deleted sessions refresh the stream without a manual invalidation',
    () async {
      await seed('valid');
      final events = <WeightSuggestionEvidence>[];
      final subscription = repository
          .watchEvidence(exerciseId)
          .listen(events.add);
      addTearDown(subscription.cancel);
      Future<void> until(bool Function() condition) async {
        for (var attempt = 0; attempt < 100 && !condition(); attempt++) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
        expect(condition(), isTrue);
      }

      await until(() => events.isNotEmpty);
      await (db.update(db.setLogs)..where((row) => row.id.equals('set-valid')))
          .write(const SetLogsCompanion(actualWeightKg: Value(110)));
      await until(() => events.last.references.single.weightKg == 110);
      await (db.update(db.workoutSessions)
            ..where((row) => row.id.equals('valid')))
          .write(const WorkoutSessionsCompanion(status: Value('deleted')));
      await until(() => events.last.references.isEmpty);
      expect((await db.select(db.setLogs).get()).single.estimated1rmKg, isNull);
    },
  );

  test(
    'archived or unsupported exercise metadata does not produce suggestions',
    () async {
      await (db.update(db.exercises)..where((row) => row.id.equals(exerciseId)))
          .write(const ExercisesCompanion(equipment: Value('bodyweight')));
      expect((await repository.loadEvidence(exerciseId)).supported, isFalse);
    },
  );
}
