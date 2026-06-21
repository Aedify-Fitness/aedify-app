import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(AppBootstrap.controllerProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(AppStrings.onboardingTitle),
            if (bootstrap.isOffline) ...[
              AppWhiteSpace.hMd,
              Text(
                AppStrings.offlineModeInfo,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            AppWhiteSpace.hMd,
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home().path),
              child: const Text(AppStrings.getStarted),
            ),
          ],
        ),
      ),
    );
  }
}
