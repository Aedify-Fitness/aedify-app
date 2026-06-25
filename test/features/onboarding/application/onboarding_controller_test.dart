import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/onboarding/application/onboarding_controller.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/data/onboarding_repository.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  bool _completed = false;
  OnboardingDraft? _saved;
  int saveCallCount = 0;

  @override
  Future<bool> isOnboardingCompleted() async => _completed;

  @override
  Future<OnboardingDraft?> loadOnboardingDraft() async => _saved;

  @override
  Future<void> saveOnboardingDraft(OnboardingDraft draft) async {
    _saved = draft;
    saveCallCount++;
  }

  @override
  Future<void> completeOnboarding(OnboardingDraft draft) async {
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

    test('build resumes at correct step from saved draft', () async {
      await repository.saveOnboardingDraft(
        const OnboardingDraft(
          experienceLevel: 'Intermediate',
          goals: ['Build muscle'],
          trainingDaysPerWeek: 4,
          equipmentAccess: ['Dumbbells'],
          preferredUnits: PreferredUnit.metric,
          limitations: ['None'],
          byokSkipped: false,
        ),
      );
      container.invalidate(AppProviders.onboardingControllerProvider);
      await container.read(AppProviders.onboardingControllerProvider.future);
      expect(readState().currentStep, OnboardingStep.review);
    });

    test(
      'build resumes at experienceGoals when draft lacks experienceLevel',
      () async {
        await repository.saveOnboardingDraft(
          const OnboardingDraft(goals: ['Build muscle']),
        );
        container.invalidate(AppProviders.onboardingControllerProvider);
        await container.read(AppProviders.onboardingControllerProvider.future);
        expect(readState().currentStep, OnboardingStep.experienceGoals);
      },
    );

    test(
      'build resumes at schedule when draft has experienceLevel but no days',
      () async {
        await repository.saveOnboardingDraft(
          const OnboardingDraft(experienceLevel: 'Intermediate'),
        );
        container.invalidate(AppProviders.onboardingControllerProvider);
        await container.read(AppProviders.onboardingControllerProvider.future);
        expect(readState().currentStep, OnboardingStep.schedule);
      },
    );

    test('nextStep advances from welcome to experienceGoals', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);
      await controller.nextStep();
      expect(readState().currentStep, OnboardingStep.experienceGoals);
    });

    test(
      'nextStep blocks when experienceLevel is missing on experienceGoals',
      () async {
        await container.read(AppProviders.onboardingControllerProvider.future);
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
        controller.updateDraft(
          const OnboardingDraft(experienceLevel: 'Intermediate'),
        );
        await controller.nextStep();

        final state = readState();
        expect(state.currentStep, OnboardingStep.schedule);
        expect(state.hasValidationMessage, isFalse);
      },
    );

    test(
      'nextStep blocks at schedule when trainingDaysPerWeek is missing',
      () async {
        await container.read(AppProviders.onboardingControllerProvider.future);
        await controller.nextStep();
        controller.updateDraft(
          const OnboardingDraft(experienceLevel: 'Intermediate'),
        );
        await controller.nextStep();
        controller.updateDraft(
          const OnboardingDraft(
            experienceLevel: 'Intermediate',
            trainingDaysPerWeek: 0,
          ),
        );
        await controller.nextStep();

        final state = readState();
        expect(state.currentStep, OnboardingStep.schedule);
        expect(state.hasValidationMessage, isTrue);
      },
    );

    test('nextStep advances through all steps to review', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      await controller.nextStep();
      controller.updateDraft(
        const OnboardingDraft(
          experienceLevel: 'Intermediate',
          goals: ['Build muscle'],
        ),
      );
      await controller.nextStep();
      controller.updateDraft(
        const OnboardingDraft(
          experienceLevel: 'Intermediate',
          goals: ['Build muscle'],
          trainingDaysPerWeek: 4,
        ),
      );
      await controller.nextStep();
      await controller.nextStep();
      await controller.nextStep();
      await controller.nextStep();
      await controller.nextStep();

      expect(readState().currentStep, OnboardingStep.review);
    });

    test('nextStep stops at review', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      await controller.nextStep();
      controller.updateDraft(
        const OnboardingDraft(experienceLevel: 'Intermediate'),
      );
      await controller.nextStep();
      controller.updateDraft(
        const OnboardingDraft(
          experienceLevel: 'Intermediate',
          trainingDaysPerWeek: 4,
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
      expect(readState().currentStep, OnboardingStep.experienceGoals);

      controller.previousStep();
      expect(readState().currentStep, OnboardingStep.welcome);
    });

    test('previousStep does not go before welcome', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      controller.previousStep();
      expect(readState().currentStep, OnboardingStep.welcome);
    });

    test('updateDraft updates state immediately', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      controller.updateDraft(
        const OnboardingDraft(experienceLevel: 'Beginner'),
      );
      expect(readState().draft.experienceLevel, 'Beginner');
    });

    test(
      'updateDraft does not save immediately (deferred by debounce)',
      () async {
        await container.read(AppProviders.onboardingControllerProvider.future);

        expect(repository.saveCallCount, 0);
        controller.updateDraft(
          const OnboardingDraft(experienceLevel: 'Beginner'),
        );
        expect(repository.saveCallCount, 0);
      },
    );

    test('rapid consecutive updates collapse into one save', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      controller.updateDraft(
        const OnboardingDraft(experienceLevel: 'Beginner'),
      );
      controller.updateDraft(
        const OnboardingDraft(experienceLevel: 'Intermediate'),
      );
      controller.updateDraft(
        const OnboardingDraft(experienceLevel: 'Advanced'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(repository.saveCallCount, 1);
      expect(await repository.loadOnboardingDraft(), isNotNull);
      expect(
        (await repository.loadOnboardingDraft())!.experienceLevel,
        'Advanced',
      );
    });

    test('nextStep flushes pending save on advance', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      await controller.nextStep();
      controller.updateDraft(
        const OnboardingDraft(experienceLevel: 'Intermediate'),
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
        controller.updateDraft(
          const OnboardingDraft(
            experienceLevel: 'Advanced',
            goals: ['Build muscle'],
          ),
        );
        await controller.nextStep();
        controller.updateDraft(
          const OnboardingDraft(
            experienceLevel: 'Advanced',
            goals: ['Build muscle'],
            trainingDaysPerWeek: 5,
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
        await controller.completeOnboarding();

        expect(await repository.isOnboardingCompleted(), isFalse);
      },
    );

    test('restartOnboarding clears draft and resets state', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      controller.updateDraft(
        const OnboardingDraft(experienceLevel: 'Intermediate'),
      );
      await controller.restartOnboarding();

      final state = readState();
      expect(state.currentStep, OnboardingStep.welcome);
      expect(state.draft.experienceLevel, isNull);
    });

    test('loadExistingDraft restores and resumes at correct step', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      await repository.saveOnboardingDraft(
        const OnboardingDraft(experienceLevel: 'Beginner'),
      );
      await controller.loadExistingDraft();

      final state = readState();
      expect(state.currentStep, OnboardingStep.schedule);
      expect(state.draft.experienceLevel, 'Beginner');
    });

    test('loadExistingDraft does nothing when no draft exists', () async {
      await container.read(AppProviders.onboardingControllerProvider.future);

      await controller.loadExistingDraft();

      final state = readState();
      expect(state.currentStep, OnboardingStep.welcome);
      expect(state.draft.experienceLevel, isNull);
    });
  });
}
