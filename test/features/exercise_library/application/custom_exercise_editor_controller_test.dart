import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/application/custom_exercise_editor_phase.dart';
import 'package:aedify/features/exercise_library/application/custom_exercise_validator.dart';
import 'package:aedify/features/exercise_library/application/delete_custom_exercise_use_case.dart';
import 'package:aedify/features/exercise_library/application/load_custom_exercise_draft_use_case.dart';
import 'package:aedify/features/exercise_library/application/save_custom_exercise_use_case.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_draft.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_editor_mode.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLoadUseCase implements LoadCustomExerciseDraftUseCase {
  CustomExerciseDraft? _draft;
  bool shouldThrow = false;

  set draftToReturn(CustomExerciseDraft? d) => _draft = d;

  @override
  Future<CustomExerciseDraft> createEmptyDraft() async {
    if (shouldThrow) throw Exception('load failed');
    return _draft ??
        const CustomExerciseDraft(
          name: '',
          muscleGroups: {},
          modality: ExerciseModality.strength,
        );
  }

  @override
  Future<CustomExerciseDraft> loadForEdit(int exerciseId) async {
    if (shouldThrow) throw Exception('load failed');
    return _draft ??
        const CustomExerciseDraft(
          name: 'Existing Exercise',
          muscleGroups: {BodymapBucket.chest},
          modality: ExerciseModality.strength,
        );
  }
}

class _FakeSaveUseCase implements SaveCustomExerciseUseCase {
  int createResult = 42;
  bool shouldThrow = false;
  CustomExerciseDraft? lastCreatedDraft;
  int? lastUpdatedId;
  CustomExerciseDraft? lastUpdatedDraft;

  @override
  Future<int> create(CustomExerciseDraft draft) async {
    if (shouldThrow) throw Exception('save failed');
    lastCreatedDraft = draft;
    return createResult;
  }

  @override
  Future<void> update({
    required int exerciseId,
    required CustomExerciseDraft draft,
  }) async {
    if (shouldThrow) throw Exception('save failed');
    lastUpdatedId = exerciseId;
    lastUpdatedDraft = draft;
  }
}

class _FakeDeleteUseCase implements DeleteCustomExerciseUseCase {
  bool shouldThrow = false;
  int? lastDeletedId;

  @override
  Future<void> delete(int exerciseId) async {
    if (shouldThrow) throw Exception('delete failed');
    lastDeletedId = exerciseId;
  }
}

class _AlwaysValidValidator extends CustomExerciseValidator {
  const _AlwaysValidValidator();

  @override
  List<CustomExerciseValidationError> validate(CustomExerciseDraft draft) {
    return const [];
  }
}

class _AlwaysInvalidValidator extends CustomExerciseValidator {
  const _AlwaysInvalidValidator();

  @override
  List<CustomExerciseValidationError> validate(CustomExerciseDraft draft) {
    return const [
      CustomExerciseValidationError(
        scope: CustomExerciseValidationScope.name,
        code: AppErrorCodes.customExerciseNameRequired,
        message: 'Name is required.',
      ),
    ];
  }
}

void main() {
  late _FakeLoadUseCase fakeLoadUseCase;
  late _FakeSaveUseCase fakeSaveUseCase;
  late _FakeDeleteUseCase fakeDeleteUseCase;

  ProviderContainer createContainer({CustomExerciseValidator? validator}) {
    return ProviderContainer(
      overrides: [
        AppProviders.loadCustomExerciseDraftUseCaseProvider.overrideWithValue(
          fakeLoadUseCase,
        ),
        AppProviders.saveCustomExerciseUseCaseProvider.overrideWithValue(
          fakeSaveUseCase,
        ),
        AppProviders.customExerciseValidatorProvider.overrideWithValue(
          validator ?? const _AlwaysValidValidator(),
        ),
        AppProviders.deleteCustomExerciseUseCaseProvider.overrideWithValue(
          fakeDeleteUseCase,
        ),
      ],
    );
  }

  setUp(() {
    fakeLoadUseCase = _FakeLoadUseCase();
    fakeSaveUseCase = _FakeSaveUseCase();
    fakeDeleteUseCase = _FakeDeleteUseCase();
  });

  group('CustomExerciseEditorController (create mode)', () {
    test('initial build returns editing state with empty draft', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      final state = await controller.future;

      expect(state.phase, CustomExerciseEditorPhase.editing);
      expect(state.mode, CustomExerciseEditorMode.create);
      expect(state.draft.name, '');
      expect(state.draft.muscleGroups, isEmpty);
      expect(state.draft.modality, ExerciseModality.strength);
      expect(state.isDirty, isFalse);
      expect(state.exerciseId, isNull);
    });

    test('initial build has error when loading fails', () async {
      fakeLoadUseCase.shouldThrow = true;
      final container = createContainer();
      final provider = AppProviders.customExerciseEditorControllerProvider((
        mode: CustomExerciseEditorMode.create,
        exerciseId: null,
      ));

      container.read(provider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(provider);
      expect(state.hasError, isTrue);
    });

    test('rename sets name and marks dirty', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;

      await controller.rename('New Exercise');

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.name, 'New Exercise');
      expect(state.isDirty, isTrue);
    });

    test('setModality updates modality and marks dirty', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;

      await controller.setModality(ExerciseModality.cardio);

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.modality, ExerciseModality.cardio);
      expect(state.isDirty, isTrue);
    });

    test('setEquipment updates equipment and marks dirty', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;

      await controller.setEquipment(EquipmentTag.dumbbell);

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.equipment, EquipmentTag.dumbbell);
      expect(state.isDirty, isTrue);
    });

    test('setEquipment retains previous equipment when setting null', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;

      await controller.setEquipment(EquipmentTag.dumbbell);
      await controller.setEquipment(null);

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.equipment, EquipmentTag.dumbbell);
    });

    test('setDifficulty updates difficulty and marks dirty', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;

      await controller.setDifficulty(ExerciseDifficulty.intermediate);

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.difficulty, ExerciseDifficulty.intermediate);
      expect(state.isDirty, isTrue);
    });

    test('toggleMuscleGroup adds a new group', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;

      await controller.toggleMuscleGroup(BodymapBucket.chest);

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.muscleGroups, {BodymapBucket.chest});
      expect(state.isDirty, isTrue);
    });

    test('toggleMuscleGroup removes an existing group', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;
      await controller.toggleMuscleGroup(BodymapBucket.chest);
      await controller.toggleMuscleGroup(BodymapBucket.chest);

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.muscleGroups, isEmpty);
    });

    test('addStep adds an empty step', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;

      await controller.addStep();
      await controller.addStep();

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.steps, hasLength(2));
      expect(state.draft.steps[0], '');
      expect(state.draft.steps[1], '');
    });

    test('updateStep updates step at given index', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;
      await controller.addStep();
      await controller.addStep();

      await controller.updateStep(index: 1, value: 'Lower down');

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.steps[1], 'Lower down');
    });

    test('updateStep does nothing for out-of-range index', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;

      await controller.updateStep(index: 5, value: 'Should not appear');

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.steps, isEmpty);
    });

    test('removeStep removes step at given index', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;
      await controller.addStep();
      await controller.addStep();
      await controller.addStep();

      await controller.removeStep(1);

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.steps, hasLength(2));
    });

    test('removeStep does nothing for out-of-range index', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;

      await controller.removeStep(5);

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.create,
              exerciseId: null,
            )),
          )
          .requireValue;
      expect(state.draft.steps, isEmpty);
    });

    group('save', () {
      test('save (create) transitions to saved with exerciseId', () async {
        final container = createContainer();
        final controller = container.read(
          AppProviders.customExerciseEditorControllerProvider((
            mode: CustomExerciseEditorMode.create,
            exerciseId: null,
          )).notifier,
        );
        await controller.future;

        await controller.save();

        final state = container
            .read(
              AppProviders.customExerciseEditorControllerProvider((
                mode: CustomExerciseEditorMode.create,
                exerciseId: null,
              )),
            )
            .requireValue;
        expect(state.phase, CustomExerciseEditorPhase.saved);
        expect(state.exerciseId, 42);
        expect(state.isDirty, isFalse);
        expect(fakeSaveUseCase.lastCreatedDraft, isNotNull);
      });

      test('save sets validation errors when draft is invalid', () async {
        final container = createContainer(
          validator: const _AlwaysInvalidValidator(),
        );
        final controller = container.read(
          AppProviders.customExerciseEditorControllerProvider((
            mode: CustomExerciseEditorMode.create,
            exerciseId: null,
          )).notifier,
        );
        await controller.future;

        await controller.save();

        final state = container
            .read(
              AppProviders.customExerciseEditorControllerProvider((
                mode: CustomExerciseEditorMode.create,
                exerciseId: null,
              )),
            )
            .requireValue;
        expect(state.phase, CustomExerciseEditorPhase.editing);
        expect(state.validationErrors, isNotEmpty);
        expect(fakeSaveUseCase.lastCreatedDraft, isNull);
      });

      test('save sets failure phase when save throws', () async {
        fakeSaveUseCase.shouldThrow = true;
        final container = createContainer();
        final controller = container.read(
          AppProviders.customExerciseEditorControllerProvider((
            mode: CustomExerciseEditorMode.create,
            exerciseId: null,
          )).notifier,
        );
        await controller.future;

        await controller.save();

        final state = container
            .read(
              AppProviders.customExerciseEditorControllerProvider((
                mode: CustomExerciseEditorMode.create,
                exerciseId: null,
              )),
            )
            .requireValue;
        expect(state.phase, CustomExerciseEditorPhase.failure);
        expect(state.errorCode, 'save_failed');
      });
    });
  });

  group('CustomExerciseEditorController (edit mode)', () {
    test('initial build loads draft for given exerciseId', () async {
      fakeLoadUseCase.draftToReturn = const CustomExerciseDraft(
        name: 'Custom Curl',
        muscleGroups: {BodymapBucket.biceps},
        modality: ExerciseModality.strength,
      );
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.edit,
          exerciseId: 99,
        )).notifier,
      );
      final state = await controller.future;

      expect(state.mode, CustomExerciseEditorMode.edit);
      expect(state.draft.name, 'Custom Curl');
      expect(state.exerciseId, 99);
    });

    test('initial build has error when loading fails', () async {
      fakeLoadUseCase.shouldThrow = true;
      final container = createContainer();
      final provider = AppProviders.customExerciseEditorControllerProvider((
        mode: CustomExerciseEditorMode.edit,
        exerciseId: 99,
      ));

      container.read(provider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(provider);
      expect(state.hasError, isTrue);
    });

    test('save (edit) calls update with correct exerciseId', () async {
      fakeLoadUseCase.draftToReturn = const CustomExerciseDraft(
        name: 'Custom Curl',
        muscleGroups: {BodymapBucket.biceps},
        modality: ExerciseModality.strength,
      );
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.edit,
          exerciseId: 99,
        )).notifier,
      );
      await controller.future;

      await controller.save();

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.edit,
              exerciseId: 99,
            )),
          )
          .requireValue;
      expect(state.phase, CustomExerciseEditorPhase.saved);
      expect(state.isDirty, isFalse);
      expect(fakeSaveUseCase.lastUpdatedId, 99);
      expect(fakeSaveUseCase.lastUpdatedDraft, isNotNull);
    });
  });

  group('delete', () {
    test('delete transitions to deleted phase', () async {
      fakeLoadUseCase.draftToReturn = const CustomExerciseDraft(
        name: 'To Delete',
        muscleGroups: {BodymapBucket.chest},
        modality: ExerciseModality.strength,
      );
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.edit,
          exerciseId: 42,
        )).notifier,
      );
      await controller.future;

      await controller.delete();

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.edit,
              exerciseId: 42,
            )),
          )
          .requireValue;
      expect(state.phase, CustomExerciseEditorPhase.deleted);
      expect(fakeDeleteUseCase.lastDeletedId, 42);
    });

    test('delete does nothing when exerciseId is null (create mode)', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;

      await controller.delete();

      expect(fakeDeleteUseCase.lastDeletedId, isNull);
    });

    test('delete sets failure phase when delete throws', () async {
      fakeLoadUseCase.draftToReturn = const CustomExerciseDraft(
        name: 'Fail Delete',
        muscleGroups: {BodymapBucket.chest},
        modality: ExerciseModality.strength,
      );
      fakeDeleteUseCase.shouldThrow = true;
      final container = createContainer();
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.edit,
          exerciseId: 42,
        )).notifier,
      );
      await controller.future;

      await controller.delete();

      final state = container
          .read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: CustomExerciseEditorMode.edit,
              exerciseId: 42,
            )),
          )
          .requireValue;
      expect(state.phase, CustomExerciseEditorPhase.failure);
      expect(state.errorCode, 'delete_failed');
    });
  });

  group('clearValidationErrors', () {
    test('clears validation errors from state', () async {
      final container = createContainer(
        validator: const _AlwaysInvalidValidator(),
      );
      final controller = container.read(
        AppProviders.customExerciseEditorControllerProvider((
          mode: CustomExerciseEditorMode.create,
          exerciseId: null,
        )).notifier,
      );
      await controller.future;

      await controller.save();
      expect(
        container
            .read(
              AppProviders.customExerciseEditorControllerProvider((
                mode: CustomExerciseEditorMode.create,
                exerciseId: null,
              )),
            )
            .requireValue
            .validationErrors,
        isNotEmpty,
      );

      controller.clearValidationErrors();
      expect(
        container
            .read(
              AppProviders.customExerciseEditorControllerProvider((
                mode: CustomExerciseEditorMode.create,
                exerciseId: null,
              )),
            )
            .requireValue
            .validationErrors,
        isEmpty,
      );
    });
  });
}
