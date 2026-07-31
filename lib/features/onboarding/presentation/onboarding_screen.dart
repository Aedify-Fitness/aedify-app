import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_widgets.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(
      AppProviders.onboardingControllerProvider,
    );

    return onboardingAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.onboardingLoadFailed,
                style: AppTextStyles.bodyMd,
              ),
              AppWhiteSpace.hMd,
              FilledButton(
                onPressed: () => ref
                    .read(AppProviders.onboardingControllerProvider.notifier)
                    .loadExistingDraft(),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
      data: (state) => OnboardingStepView(state: state),
    );
  }
}
