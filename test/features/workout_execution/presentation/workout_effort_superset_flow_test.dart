import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_draft.dart';
import 'package:aedify/features/workout_builder/domain/saved_workout_exercise_draft.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_mode.dart';
import 'package:aedify/features/workout_execution/presentation/workout_runner_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'RIR prescriptions populate RPE and superset type toggles retain the linked round after persistence',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
      );
      var disposed = false;
      addTearDown(() async {
        if (!disposed) {
          container.dispose();
          await db.close();
        }
      });
      final exercises = <SavedWorkoutExerciseDraft>[];
      for (var member = 0; member < 3; member++) {
        final id = await container
            .read(AppProviders.exerciseRepositoryProvider)
            .createCustomExercise(
              CustomExerciseSeed(
                name: 'Local movement $member',
                muscleGroups: const {BodymapBucket.chest},
                modality: ExerciseModality.strength,
                loggingType: ExerciseLoggingType.repsWeight,
              ),
            );
        exercises.add(
          SavedWorkoutExerciseDraft(
            id: 'source-$member',
            exerciseId: id,
            sortOrder: member,
            supersetGroupId: member < 2 ? 'paired' : null,
            supersetOrder: member,
            sets: [
              for (var index = 0; index < 2; index++)
                SetPrescriptionDraft(
                  id: 'source-set-$member-$index',
                  setIndex: index,
                  setType: SetType.working,
                  prescribedRepsExact: 8,
                  prescribedWeightKg: 40,
                  prescribedRir: 3,
                ),
            ],
          ),
        );
      }
      await container
          .read(AppProviders.savedWorkoutRepositoryProvider)
          .saveSavedWorkout(
            SavedWorkoutDraft(
              id: 'paired',
              name: 'Paired RIR prescription',
              source: WorkoutSource.manual,
              creationMethod: CreationMethod.manual,
              status: SavedWorkoutStatus.active,
              goalTags: const {},
              equipment: const {},
              exercises: exercises,
            ),
          );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const WorkoutRunnerScreen.savedWorkout(
              savedWorkoutId: 'paired',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final provider = AppProviders.workoutRunnerControllerProvider((
        mode: WorkoutRunnerMode.savedWorkout,
        savedWorkoutId: 'paired',
        programId: null,
        programWorkoutId: null,
      ));
      final controller = container.read(provider.notifier);
      final initial = container.read(provider).requireValue.session!;
      final first = initial.exercises.first;
      final firstId = first.sets.first.id;
      final partner = initial.exercises[1];
      final rpe = find.byKey(const Key('active_rpe_field'));
      expect(tester.widget<TextField>(rpe).controller!.text, '7');
      expect(find.byKey(const Key('active_rir_field')), findsNothing);
      // Effort defaults do not fabricate the required performance results.
      expect(
        tester
            .widget<IconButton>(
              find.byKey(Key('workout_runner_set_action_$firstId')),
            )
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(rpe);
      await tester.enterText(rpe, '8.5');
      await tester.pump();
      expect(
        container
            .read(provider)
            .requireValue
            .session!
            .exercises
            .first
            .sets
            .first
            .actualRir,
        2,
      );
      final toggle = find.byKey(Key('workout_runner_set_type_$firstId'));
      for (final type in [SetType.warmup, SetType.working, SetType.warmup]) {
        await tester.ensureVisible(toggle);
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        final session = container.read(provider).requireValue.session!;
        for (final member in session.exercises.take(2)) {
          expect(member.supersetGroupId, first.supersetGroupId);
          expect(member.sets.first.setType, type);
          expect(member.sets[1].setType, SetType.working);
          expect(
            find.byKey(Key('workout_runner_set_row_${member.sets.first.id}')),
            findsOneWidget,
          );
        }
        expect(
          session.exercises[2].sets.every(
            (set) => set.setType == SetType.working,
          ),
          isTrue,
        );
        expect(session.exercises.first.sets.first.actualRpe, 8.5);
        expect(session.exercises[1].sets.first.actualRpe, 7);
        expect(find.text(AppStrings.superset), findsWidgets);
        expect(tester.takeException(), isNull);
      }
      await controller.saveProgress();
      final persisted = (await container
          .read(AppProviders.workoutSessionRepositoryProvider)
          .getActiveSession())!;
      expect(
        persisted.exercises.take(2).map((item) => item.supersetGroupId).toSet(),
        {first.supersetGroupId},
      );
      for (final member in [first, partner]) {
        final logs = persisted.setLogs
            .where((set) => set.workoutSessionExerciseId == member.id)
            .toList();
        expect(logs.map((set) => set.setType), ['warmup', 'working']);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      final restored = (await container
          .read(AppProviders.loadActiveWorkoutSessionUseCaseProvider)
          .load())!;
      expect(
        restored.exercises.take(2).map((item) => item.supersetGroupId).toSet(),
        {first.supersetGroupId},
      );
      expect(restored.exercises.first.sets.first.actualRpe, 8.5);
      expect(restored.exercises.first.sets.first.actualRir, 2);
      expect(restored.exercises[1].sets.first.setType, SetType.warmup);
      expect(restored.exercises[2].sets.first.setType, SetType.working);
      await (db.update(
        db.setLogs,
      )..where((table) => table.id.equals(firstId))).write(
        const SetLogsCompanion(actualRpe: Value(null), actualRir: Value(4)),
      );
      final legacy = (await container
          .read(AppProviders.loadActiveWorkoutSessionUseCaseProvider)
          .load())!;
      expect(legacy.exercises.first.sets.first.actualRpe, 6);
      expect(legacy.exercises.first.sets.first.actualRir, 4);
      container.dispose();
      disposed = true;
      await db.close();
      await tester.pump();
    },
  );
}
