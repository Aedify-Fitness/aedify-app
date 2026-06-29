import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/data/onboarding_repository.dart';
import 'package:aedify/features/onboarding/presentation/onboarding_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  bool _completed = false;
  OnboardingDraft? _saved;

  @override
  Future<bool> isOnboardingCompleted() async => _completed;

  @override
  Future<OnboardingDraft?> loadOnboardingDraft() async => _saved;

  @override
  Future<void> saveOnboardingDraft(OnboardingDraft draft) async {
    _saved = draft;
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

Widget createTestApp(OnboardingRepository repository) {
  return ProviderScope(
    overrides: [
      AppProviders.onboardingRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(home: OnboardingScreen()),
  );
}

Future<void> pumpUntilLoaded(WidgetTester tester) async {
  await tester.pumpWidget(createTestApp(_FakeOnboardingRepository()));
  await tester.pump();
  await tester.pump();
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  group('OnboardingScreen', () {
    testWidgets('fresh install shows onboarding welcome', (tester) async {
      await pumpUntilLoaded(tester);

      expect(
        find.text(AppStrings.onboardingWelcomeDescription),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.onboardingWelcomeHeroDescription),
        findsOneWidget,
      );
      expect(find.text(AppStrings.continueLabel), findsOneWidget);
    });

    testWidgets('continue advances to experience step', (tester) async {
      await pumpUntilLoaded(tester);

      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      expect(find.text(AppStrings.onboardingExperienceTitle), findsOneWidget);
    });

    testWidgets('continue blocked when experienceLevel is missing', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);

      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.pump();

      expect(
        find.text(AppStrings.onboardingValidationRequired),
        findsOneWidget,
      );
      expect(find.text(AppStrings.onboardingExperienceTitle), findsOneWidget);
    });

    testWidgets('step transitions work through full flow', (tester) async {
      await pumpUntilLoaded(tester);

      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.onboardingExperienceIntermediate));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      expect(find.text(AppStrings.onboardingReviewTitle), findsOneWidget);
    });

    testWidgets('Continue from BYOK advances to review', (tester) async {
      await pumpUntilLoaded(tester);

      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.onboardingExperienceIntermediate));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      expect(find.text(AppStrings.onboardingReviewTitle), findsOneWidget);
    });

    testWidgets('back button navigates from schedule to experience goals', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);

      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.onboardingExperienceIntermediate));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      await tester.tap(find.text(AppStrings.backLabel));
      await tester.pump();

      expect(find.text(AppStrings.onboardingExperienceTitle), findsOneWidget);
    });

    testWidgets('validation message is shown for invalid step', (tester) async {
      await pumpUntilLoaded(tester);

      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.pump();

      expect(
        find.text(AppStrings.onboardingValidationRequired),
        findsOneWidget,
      );
    });

    testWidgets('welcome step has no back button', (tester) async {
      await pumpUntilLoaded(tester);

      expect(find.text(AppStrings.backLabel), findsNothing);
    });

    testWidgets('resume opens at experienceGoals when draft has only goals', (
      tester,
    ) async {
      final repo = _FakeOnboardingRepository();
      await repo.saveOnboardingDraft(
        const OnboardingDraft(goals: {GoalTag.buildMuscle}),
      );

      await tester.pumpWidget(createTestApp(repo));
      await tester.pump();
      await tester.pump();

      expect(find.text(AppStrings.onboardingExperienceTitle), findsOneWidget);
    });

    testWidgets('resume opens at schedule when draft has experienceLevel', (
      tester,
    ) async {
      final repo = _FakeOnboardingRepository();
      await repo.saveOnboardingDraft(
        const OnboardingDraft(experienceLevel: ExperienceLevel.intermediate),
      );

      await tester.pumpWidget(createTestApp(repo));
      await tester.pump();
      await tester.pump();

      expect(find.text(AppStrings.onboardingScheduleTitle), findsOneWidget);
    });

    testWidgets('minimal onboarding completes successfully', (tester) async {
      final repo = _FakeOnboardingRepository();

      await tester.pumpWidget(createTestApp(repo));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.onboardingExperienceIntermediate));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      expect(find.text(AppStrings.onboardingReviewTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.finishSetup));
      await tester.pump();
      await tester.pump();

      expect(await repo.isOnboardingCompleted(), isTrue);
    });

    testWidgets('full onboarding with all fields completes', (tester) async {
      final repo = _FakeOnboardingRepository();

      await tester.pumpWidget(createTestApp(repo));
      await tester.pump();
      await tester.pump();

      // Welcome -> continue
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      // Experience & goals
      await tester.tap(find.text(AppStrings.onboardingExperienceIntermediate));
      await tester.pump();
      await tester.ensureVisible(
        find.text(AppStrings.onboardingGoalBuildMuscle),
      );
      await tester.pump();
      await tester.tap(find.text(AppStrings.onboardingGoalBuildMuscle));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      // Schedule
      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      // Equipment (select dumbbells)
      await tester.tap(find.text(AppStrings.onboardingEquipmentDumbbells));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      // Units & metrics (accept default metric)
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      // Limitations (select none)
      await tester.tap(find.text(AppStrings.onboardingLimitationNone));
      await tester.pump();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      // BYOK optional -> continue (skip)
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pump();

      // Review -> finish
      expect(find.text(AppStrings.onboardingReviewTitle), findsOneWidget);
      await tester.tap(find.text(AppStrings.finishSetup));
      await tester.pump();
      await tester.pump();

      expect(await repo.isOnboardingCompleted(), isTrue);
    });
  });
}
