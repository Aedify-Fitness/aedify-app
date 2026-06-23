import 'package:aedify/features/onboarding/application/onboarding_state.dart';

abstract class OnboardingRepository {
  Future<bool> isOnboardingCompleted();

  Future<OnboardingDraft?> loadOnboardingDraft();

  Future<void> saveOnboardingDraft(OnboardingDraft draft);

  Future<void> completeOnboarding(OnboardingDraft draft);

  Future<void> clearOnboardingDraft();
}
