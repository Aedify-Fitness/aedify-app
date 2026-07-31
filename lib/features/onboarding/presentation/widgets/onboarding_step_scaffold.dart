import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingStepScaffold extends StatefulWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.onBack,
    required this.onNext,
    required this.scrollResetKey,
    this.isPrimaryLoading = false,
    this.primaryLabel,
    this.secondaryLabel,
    this.description,
    this.header,
    this.hero,
    this.bodyFooterLabel,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final Object scrollResetKey;
  final bool isPrimaryLoading;
  final String? primaryLabel;
  final String? secondaryLabel;
  final String? description;
  final Widget? header;
  final Widget? hero;
  final String? bodyFooterLabel;

  @override
  State<OnboardingStepScaffold> createState() => _OnboardingStepScaffoldState();
}

class _OnboardingStepScaffoldState extends State<OnboardingStepScaffold> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(OnboardingStepScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollResetKey != widget.scrollResetKey) {
      _resetScrollPosition();
    }
  }

  void _resetScrollPosition() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final child = widget.child;
    final onBack = widget.onBack;
    final onNext = widget.onNext;
    final isPrimaryLoading = widget.isPrimaryLoading;
    final primaryLabel = widget.primaryLabel;
    final secondaryLabel = widget.secondaryLabel;
    final description = widget.description;
    final header = widget.header;
    final hero = widget.hero;
    final bodyFooterLabel = widget.bodyFooterLabel;
    final isDark = context.theme.brightness == Brightness.dark;
    final primaryBackground = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondary;
    final primaryForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondary;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              ?header,
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey<String>('onboarding_step_scroll_view'),
                  controller: _scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hero != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xl,
                          ),
                          color: context.colorScheme.surface,
                          child: hero,
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title.isNotEmpty)
                              Text(
                                title,
                                style: AppTextStyles.headlineLgMobile.copyWith(
                                  color: context.colorScheme.onSurface,
                                ),
                              ),
                            if (description != null) ...[
                              AppWhiteSpace.hSm,
                              Text(
                                description,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            if (title.isNotEmpty) AppWhiteSpace.hXl,
                            child,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: context.colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: AppSizing.iconXxl,
                      child: FilledButton(
                        onPressed: onNext,
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryBackground,
                          foregroundColor: primaryForeground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.defaultRadius,
                            ),
                          ),
                        ),
                        child: isPrimaryLoading
                            ? SizedBox(
                                width: AppSizing.iconSm,
                                height: AppSizing.iconSm,
                                child: CircularProgressIndicator(
                                  strokeWidth: AppSizing.strokeWidth,
                                  color: primaryForeground,
                                ),
                              )
                            : Text(
                                primaryLabel ?? AppStrings.continueLabel,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ),
                    if (onBack != null) ...[
                      AppWhiteSpace.hSm,
                      SizedBox(
                        width: double.infinity,
                        height: AppSizing.iconXxl,
                        child: TextButton(
                          onPressed: onBack,
                          style: TextButton.styleFrom(
                            foregroundColor:
                                context.colorScheme.onSurfaceVariant,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.defaultRadius,
                              ),
                            ),
                          ),
                          child: Text(secondaryLabel ?? AppStrings.backLabel),
                        ),
                      ),
                    ],
                    if (bodyFooterLabel != null) ...[
                      AppWhiteSpace.hSm,
                      Container(
                        alignment: Alignment.center,
                        height: AppSizing.iconXxl,
                        child: Text(
                          bodyFooterLabel,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelSm.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
