import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class BootstrapScreen extends ConsumerStatefulWidget {
  const BootstrapScreen({super.key});

  @override
  ConsumerState<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends ConsumerState<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(AppBootstrap.controllerProvider.notifier).start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(AppBootstrap.controllerProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state.phase == StartupPhase.initializing)
                _LoadingContent(isOffline: state.isOffline),
              if (state.phase == StartupPhase.failure)
                _FailureContent(
                  failure: state.failure!,
                  onRetry: () => ref
                      .read(AppBootstrap.controllerProvider.notifier)
                      .retry(),
                ),
              if (state.phase == StartupPhase.success)
                const Text(AppStrings.startupComplete),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  final bool isOffline;

  const _LoadingContent({required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        AppWhiteSpace.hXl,
        Text(
          AppStrings.startingApp,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        if (isOffline) ...[
          AppWhiteSpace.hMd,
          Text(
            AppStrings.offlineModeInfo,
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _FailureContent extends StatelessWidget {
  final BootstrapFailure failure;
  final VoidCallback onRetry;

  const _FailureContent({required this.failure, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          OutlinedSvgAssets.exclamationCircle,
          width: AppSpacing.xxl,
          height: AppSpacing.xxl,
          colorFilter: ColorFilter.mode(
            context.colorScheme.error,
            BlendMode.srcIn,
          ),
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.startupFailed,
          style: AppTextStyles.headlineMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        AppWhiteSpace.hSm,
        Text(
          failure.message,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (failure.retryable) ...[
          AppWhiteSpace.hLg,
          FilledButton(onPressed: onRetry, child: const Text(AppStrings.retry)),
        ],
      ],
    );
  }
}
