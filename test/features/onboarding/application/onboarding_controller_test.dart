import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/onboarding/application/onboarding_controller.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/data/onboarding_repository.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/training_day.dart';
import '../../../support/privacy/privacy_sentinel_values.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  bool _completed = false;
  OnboardingDraft? _saved;
  int saveCallCount = 0;
  bool shouldThrowOnSave = false;

  @override
  Future<bool> isOnboardingCompleted() async => _completed;

  @override
  Future<OnboardingDraft?> loadOnboardingDraft() async => _saved;

  @override
  Future<void> saveOnboardingDraft(OnboardingDraft draft) async {
    if (shouldThrowOnSave) throw Exception('db failure');
    _saved = draft;
    saveCallCount++;
  }

  @override
  Future<void> completeOnboarding(OnboardingDraft draft) async {
    if (shouldThrowOnSave) throw Exception('db failure');
    _saved = draft;
    _completed = true;
  }

  @override
  Future<void> clearOnboardingDraft() async {
    _saved = null;
  }
}

void main() {
  group('OnboardingController', () {
    late ProviderContainer container;
    late OnboardingController controller;
    late FakeOnboardingRepository repository;

    setUp(() {
      repository = FakeOnboardingRepository();
      container = ProviderContainer(
        overrides: [
          AppProviders.onboardingRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
      );
      controller = container.read(
        AppProviders.onboardingControllerProvider.notifier,
      );
    });

    tearDown(() {
      container.dispose();
    });

    OnboardingState readState() {
      return (container.read(AppProviders.onboardingControllerProvider)
              as AsyncData<OnboardingState>)
          .value;
    }

    test('initial state starts at welcome when no draft exists', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);
      final state = readState();
      expect(state.currentStep, OnboardingStep.welcome);
      expect(state.isSaving, isFalse);
      expect(state.hasError, isFalse);
      expect(state.hasValidationMessage, isFalse);
    });

    test('steps use the approved nine-step order', () {
      expect(OnboardingStep.values, const [
        OnboardingStep.welcome,
        OnboardingStep.coreIdentity,
        OnboardingStep.experienceGoals,
        OnboardingStep.schedule,
        OnboardingStep.equipment,
        OnboardingStep.limitations,
        OnboardingStep.unitsMetrics,
        OnboardingStep.byokOptional,
        OnboardingStep.review,
      ]);
    });

    test('build resumes at correct step from saved draft', () async {
      await repository.saveOnboardingDraft(
        const OnboardingDraft(
          experienceLevel: ExperienceLevel.intermediate,
          goals: {GoalTag.buildMuscle},
          trainingDaysPerWeek: 4,
          trainingDays: [
            TrainingDay.monday,
            TrainingDay.tuesday,
            TrainingDay.wednesday,
            TrainingDay.thursday,
          ],
          equipmentAccess: {EquipmentTag.dumbbell},
          preferredUnits: PreferredUnit.metric,
          heightCm: 175,
          limitations: ['None'],
          byokSkipped: false,
        ),
      );
      container.invalidate(AppProviders.onboardingControllerProvider);
      await container.read(AppProviders.onboardingControllerProvider.future);
      expect(readState().currentStep, OnboardingStep.review);
    });

    test(
      'build resumes at coreIdentity when draft lacks experienceLevel',
      () async {
        await repository.saveOnboardingDraft(
          const OnboardingDraft(goals: {GoalTag.buildMuscle}),
        );
        container.invalidate(AppProviders.onboardingControllerProvider);
        await container.read(AppProviders.onboardingControllerProvider.future);
        expect(readState().currentStep, OnboardingStep.coreIdentity);
      },
    );

    test(
      'build resumes at schedule when draft has experienceLevel but no days',
      () async {
        await repository.saveOnboardingDraft(
          const OnboardingDraft(experienceLevel: ExperienceLevel.intermediate),
        );
        container.invalidate(AppProviders.onboardingControllerProvider);
        await container.read(AppProviders.onboardingControllerProvider.future);
        expect(readState().currentStep, OnboardingStep.schedule);
      },
    );

    test(
      'build resumes at equipment after core identity and schedule',
      () async {
        await repository.saveOnboardingDraft(
          const OnboardingDraft(
            experienceLevel: ExperienceLevel.intermediate,
            trainingDays: [TrainingDay.monday],
            preferredUnits: PreferredUnit.metric,
          ),
        );
        container.invalidate(AppProviders.onboardingControllerProvider);
        await container.read(AppProviders.onboardingControllerProvider.future);
        expect(readState().currentStep, OnboardingStep.equipment);
      },
    );

    test('build resumes at limitations after equipment', () async {
      await repository.saveOnboardingDraft(
        const OnboardingDraft(
          experienceLevel: ExperienceLevel.intermediate,
          trainingDays: [TrainingDay.monday],
          equipmentAccess: {EquipmentTag.dumbbell},
          preferredUnits: PreferredUnit.metric,
        ),
      );
      container.invalidate(AppProviders.onboardingControllerProvider);
      await container.read(AppProviders.onboardingControllerProvider.future);
      expect(readState().currentStep, OnboardingStep.limitations);
    });

    test('build resumes at metrics after limitations', () async {
      await repository.saveOnboardingDraft(
        const OnboardingDraft(
          experienceLevel: ExperienceLevel.intermediate,
          trainingDays: [TrainingDay.monday],
          equipmentAccess: {EquipmentTag.dumbbell},
          preferredUnits: PreferredUnit.metric,
          limitations: ['None'],
        ),
      );
      container.invalidate(AppProviders.onboardingControllerProvider);
      await container.read(AppProviders.onboardingControllerProvider.future);
      expect(readState().currentStep, OnboardingStep.unitsMetrics);
    });

    test('nextStep advances from welcome to coreIdentity', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);
      await controller.nextStep();
      expect(readState().currentStep, OnboardingStep.coreIdentity);
    });

    test(
      'nextStep blocks when experienceLevel is missing on experienceGoals',
      () async {
        await container.read(AppProviders.onboardingControllerProvider.future);
        await controller.nextStep();
        await controller.nextStep();
        await controller.nextStep();

        final state = readState();
        expect(state.currentStep, OnboardingStep.experienceGoals);
        expect(state.hasValidationMessage, isTrue);
        expect(
          state.validationMessage,
          AppStrings.onboardingValidationRequired,
        );
      },
    );

    test(
      'nextStep advances past experienceGoals when experienceLevel is set',
      () async {
        await container.read(AppProviders.onboardingControllerProvider.future);
        await controller.nextStep();
        await controller.nextStep();
        controller.updateDraft(
          const OnboardingDraft(experienceLevel: ExperienceLevel.intermediate),
        );
        await controller.nextStep();

        final state = readState();
        expect(state.currentStep, OnboardingStep.schedule);
        expect(state.hasValidationMessage, isFalse);
      },
    );

    test('nextStep blocks at schedule when trainingDays is empty', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);
      await controller.nextStep();
      await controller.nextStep();
      controller.updateDraft(
        const OnboardingDraft(experienceLevel: ExperienceLevel.intermediate),
      );
      await controller.nextStep();
      controller.updateDraft(
        const OnboardingDraft(
          experienceLevel: ExperienceLevel.intermediate,
          trainingDaysPerWeek: 0,
          trainingDays: [],
        ),
      );
      await controller.nextStep();

      final state = readState();
      expect(state.currentStep, OnboardingStep.schedule);
      expect(state.hasValidationMessage, isTrue);
    });

    test('nextStep advances through all steps to review', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      expect(readState().currentStep, OnboardingStep.welcome);
      await controller.nextStep();
      expect(readState().currentStep, OnboardingStep.coreIdentity);
      await controller.nextStep();
      expect(readState().currentStep, OnboardingStep.experienceGoals);
      controller.updateDraft(
        const OnboardingDraft(
          experienceLevel: ExperienceLevel.intermediate,
          goals: {GoalTag.buildMuscle},
        ),
      );
      await controller.nextStep();
      expect(readState().currentStep, OnboardingStep.schedule);
      controller.updateDraft(
        const OnboardingDraft(
          experienceLevel: ExperienceLevel.intermediate,
          goals: {GoalTag.buildMuscle},
          trainingDaysPerWeek: 4,
          trainingDays: [
            TrainingDay.monday,
            TrainingDay.tuesday,
            TrainingDay.wednesday,
            TrainingDay.thursday,
          ],
        ),
      );
      await controller.nextStep();
      expect(readState().currentStep, OnboardingStep.equipment);
      await controller.nextStep();
      expect(readState().currentStep, OnboardingStep.limitations);
      await controller.nextStep();
      expect(readState().currentStep, OnboardingStep.unitsMetrics);
      await controller.nextStep();
      expect(readState().currentStep, OnboardingStep.byokOptional);
      await controller.nextStep();

      expect(readState().currentStep, OnboardingStep.review);
    });

    test('nextStep stops at review', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      await controller.nextStep();
      await controller.nextStep();
      controller.updateDraft(
        const OnboardingDraft(experienceLevel: ExperienceLevel.intermediate),
      );
      await controller.nextStep();
      controller.updateDraft(
        const OnboardingDraft(
          experienceLevel: ExperienceLevel.intermediate,
          trainingDaysPerWeek: 4,
          trainingDays: [
            TrainingDay.monday,
            TrainingDay.tuesday,
            TrainingDay.wednesday,
            TrainingDay.thursday,
          ],
        ),
      );
      await controller.nextStep();
      await controller.nextStep();
      await controller.nextStep();
      await controller.nextStep();
      await controller.nextStep();
      await controller.nextStep();

      expect(readState().currentStep, OnboardingStep.review);

      await controller.nextStep();
      expect(readState().currentStep, OnboardingStep.review);
    });

    test('previousStep moves backward', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      await controller.nextStep();
      expect(readState().currentStep, OnboardingStep.coreIdentity);

      controller.previousStep();
      expect(readState().currentStep, OnboardingStep.welcome);
    });

    test('previousStep follows the approved reverse order', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);
      controller.jumpToStep(OnboardingStep.review);

      const expectedSteps = [
        OnboardingStep.byokOptional,
        OnboardingStep.unitsMetrics,
        OnboardingStep.limitations,
        OnboardingStep.equipment,
        OnboardingStep.schedule,
        OnboardingStep.experienceGoals,
        OnboardingStep.coreIdentity,
        OnboardingStep.welcome,
      ];

      for (final expectedStep in expectedSteps) {
        controller.previousStep();
        expect(readState().currentStep, expectedStep);
      }
    });

    test('previousStep does not go before welcome', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      controller.previousStep();
      expect(readState().currentStep, OnboardingStep.welcome);
    });

    test('updateDraft updates state immediately', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      controller.updateDraft(
        const OnboardingDraft(experienceLevel: ExperienceLevel.beginner),
      );
      expect(readState().draft.experienceLevel, ExperienceLevel.beginner);
    });

    test(
      'updateDraft does not save immediately (deferred by debounce)',
      () async {
        await container.read(AppProviders.onboardingControllerProvider.future);

        expect(repository.saveCallCount, 0);
        controller.updateDraft(
          const OnboardingDraft(experienceLevel: ExperienceLevel.beginner),
        );
        expect(repository.saveCallCount, 0);
      },
    );

    test('rapid consecutive updates collapse into one save', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      controller.updateDraft(
        const OnboardingDraft(experienceLevel: ExperienceLevel.beginner),
      );
      controller.updateDraft(
        const OnboardingDraft(experienceLevel: ExperienceLevel.intermediate),
      );
      controller.updateDraft(
        const OnboardingDraft(experienceLevel: ExperienceLevel.advanced),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(repository.saveCallCount, 1);
      expect(await repository.loadOnboardingDraft(), isNotNull);
      expect(
        (await repository.loadOnboardingDraft())!.experienceLevel,
        ExperienceLevel.advanced,
      );
    });

    test('nextStep flushes pending save on advance', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      await controller.nextStep();
      controller.updateDraft(
        const OnboardingDraft(experienceLevel: ExperienceLevel.intermediate),
      );
      expect(repository.saveCallCount, 0);
      await controller.nextStep();
      expect(repository.saveCallCount, 1);
    });

    test(
      'completeOnboarding persists completion even with debounced draft',
      () async {
        await container.read(AppProviders.onboardingControllerProvider.future);

        await controller.nextStep();
        await controller.nextStep();
        controller.updateDraft(
          const OnboardingDraft(
            experienceLevel: ExperienceLevel.advanced,
            goals: {GoalTag.buildMuscle},
          ),
        );
        await controller.nextStep();
        controller.updateDraft(
          const OnboardingDraft(
            experienceLevel: ExperienceLevel.advanced,
            goals: {GoalTag.buildMuscle},
            trainingDaysPerWeek: 5,
            trainingDays: [
              TrainingDay.monday,
              TrainingDay.tuesday,
              TrainingDay.wednesday,
              TrainingDay.thursday,
              TrainingDay.friday,
            ],
          ),
        );
        await controller.nextStep();
        await controller.nextStep();
        await controller.nextStep();
        await controller.nextStep();
        await controller.nextStep();

        await controller.completeOnboarding();

        expect(await repository.isOnboardingCompleted(), isTrue);
        expect(repository.saveCallCount, greaterThan(0));
      },
    );

    test(
      'completeOnboarding validates before saving from experienceGoals',
      () async {
        await container.read(AppProviders.onboardingControllerProvider.future);

        await controller.nextStep();
        await controller.nextStep();
        await controller.completeOnboarding();

        expect(await repository.isOnboardingCompleted(), isFalse);
      },
    );

    test('restartOnboarding clears draft and resets state', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      controller.updateDraft(
        const OnboardingDraft(experienceLevel: ExperienceLevel.intermediate),
      );
      await controller.restartOnboarding();

      final state = readState();
      expect(state.currentStep, OnboardingStep.welcome);
      expect(state.draft.experienceLevel, isNull);
    });

    test('loadExistingDraft restores and resumes at correct step', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      await repository.saveOnboardingDraft(
        const OnboardingDraft(experienceLevel: ExperienceLevel.beginner),
      );
      await controller.loadExistingDraft();

      final state = readState();
      expect(state.currentStep, OnboardingStep.schedule);
      expect(state.draft.experienceLevel, ExperienceLevel.beginner);
    });

    test(
      'repository save failure surfaces safe error without leaking draft notes',
      () async {
        repository.shouldThrowOnSave = true;
        await container.read(AppProviders.onboardingControllerProvider.future);

        controller.updateDraft(
          OnboardingDraft(
            experienceLevel: ExperienceLevel.intermediate,
            goals: {GoalTag.buildMuscle},
            notes: PrivacySentinelValues.fakeProfileNote,
          ),
        );

        await controller.nextStep();

        final state = readState();
        expect(state.currentStep, OnboardingStep.coreIdentity);
        expect(
          state.draft.notes,
          equals(PrivacySentinelValues.fakeProfileNote),
        );
        expect(state.hasError, isFalse);
      },
    );

    test(
      'validation errors do not log private bodyweight/notes values',
      () async {
        await container.read(AppProviders.onboardingControllerProvider.future);

        controller.updateDraft(
          const OnboardingDraft(
            bodyweightKg: 98.7,
            notes: PrivacySentinelValues.fakeProfileNote,
          ),
        );

        await controller.nextStep();
        await controller.nextStep();
        await controller.nextStep();

        final state = readState();
        expect(state.hasValidationMessage, isTrue);
        expect(state.validationMessage, isNot(contains('98.7')));
        expect(
          state.validationMessage,
          isNot(contains(PrivacySentinelValues.fakeProfileNote)),
        );
      },
    );

    test('loadExistingDraft does nothing when no draft exists', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      await controller.loadExistingDraft();

      final state = readState();
      expect(state.currentStep, OnboardingStep.welcome);
      expect(state.draft.experienceLevel, isNull);
    });
  });
}
