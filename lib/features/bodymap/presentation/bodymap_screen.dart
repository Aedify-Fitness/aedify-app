import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/bodymap/domain/bodymap_view_side.dart';
import 'package:aedify/features/bodymap/presentation/widgets/bodymap_bucket_chip_bar.dart';
import 'package:aedify/features/bodymap/presentation/widgets/bodymap_side_selector.dart';
import 'package:aedify/features/bodymap/presentation/widgets/bodymap_svg_view.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/components/app_section_header.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class BodymapScreen extends ConsumerWidget {
  const BodymapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(AppProviders.bodymapSelectionControllerProvider);
    final selectedBucket = state.selectedBucket;
    final colorScheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final actionBackground = isDark
        ? colorScheme.primaryContainer
        : colorScheme.secondary;
    final actionForeground = isDark
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSecondary;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuietHeader(showBackButton: canPop, onBack: () => context.pop()),
              AppWhiteSpace.hLg,
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppSectionHeader(title: AppStrings.filterMuscleGroup),
              ),
              AppWhiteSpace.hSm,
              BodymapBucketChipBar(
                selectedBucket: selectedBucket,
                onSelected: (bucket) {
                  ref
                      .read(
                        AppProviders
                            .bodymapSelectionControllerProvider
                            .notifier,
                      )
                      .selectBucket(bucket);
                },
                onClear: () {
                  ref
                      .read(
                        AppProviders
                            .bodymapSelectionControllerProvider
                            .notifier,
                      )
                      .clearSelection();
                },
              ),
              AppWhiteSpace.hLg,
              ColoredBox(
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      BodymapSideSelector(
                        side: state.side,
                        onSelected: (side) {
                          ref
                              .read(
                                AppProviders
                                    .bodymapSelectionControllerProvider
                                    .notifier,
                              )
                              .setSide(side);
                        },
                      ),
                      AppWhiteSpace.hLg,
                      BodymapSvgView(
                        side: state.side,
                        selectedBucket: selectedBucket,
                        onBucketSelected: (bucket) {
                          ref
                              .read(
                                AppProviders
                                    .bodymapSelectionControllerProvider
                                    .notifier,
                              )
                              .selectBucket(bucket);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (selectedBucket != null) ...[
                AppWhiteSpace.hMd,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: _SelectionContextPanel(
                    bucket: selectedBucket,
                    side: state.side,
                    onClear: () {
                      ref
                          .read(
                            AppProviders
                                .bodymapSelectionControllerProvider
                                .notifier,
                          )
                          .clearSelection();
                    },
                  ),
                ),
                AppWhiteSpace.hMd,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: actionBackground,
                        foregroundColor: actionForeground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.buttonVertical,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        textStyle: AppTextStyles.labelMd,
                      ),
                      onPressed: () {
                        ref
                            .read(
                              AppProviders
                                  .exerciseSearchControllerProvider
                                  .notifier,
                            )
                            .updateFilters(
                              ref
                                  .read(
                                    AppProviders
                                        .exerciseSearchControllerProvider,
                                  )
                                  .filters
                                  .copyWith(
                                    muscleGroup: selectedBucket,
                                    clearMuscleGroup: false,
                                  ),
                            );
                        ref
                            .read(
                              AppProviders
                                  .bodymapSelectionControllerProvider
                                  .notifier,
                            )
                            .clearSelection();
                        context.pop();
                      },
                      icon: SvgPicture.asset(
                        OutlinedSvgAssets.magnifyingGlass,
                        width: AppSizing.iconS,
                        height: AppSizing.iconS,
                        colorFilter: ColorFilter.mode(
                          actionForeground,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: Text(AppStrings.browseByMuscle),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuietHeader extends StatelessWidget {
  const _QuietHeader({required this.showBackButton, required this.onBack});

  final bool showBackButton;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            AppIconButton(
              asset: OutlinedSvgAssets.arrowLeft,
              onPressed: onBack,
              semanticLabel: AppStrings.backLabel,
              backgroundColor: context.colorScheme.surfaceContainerLow,
            ),
            AppWhiteSpace.wSm,
          ],
          Expanded(
            child: Text(
              AppStrings.bodymap,
              style: AppTextStyles.headlineLgMobile.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionContextPanel extends StatelessWidget {
  const _SelectionContextPanel({
    required this.bucket,
    required this.side,
    required this.onClear,
  });

  final BodymapBucket bucket;
  final BodymapViewSide side;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final sideLabel = side == BodymapViewSide.front
        ? AppStrings.bodymapFront
        : AppStrings.bodymapBack;

    return Container(
      key: const ValueKey<String>('bodymap_selection_context'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionHeader(title: AppStrings.muscleFocus),
          AppWhiteSpace.hSm,
          Text(
            bucket.label,
            style: AppTextStyles.headlineMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          AppWhiteSpace.hXxs,
          Text(
            sideLabel,
            style: AppTextStyles.bodySm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          AppWhiteSpace.hSm,
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? context.colorScheme.primary
                  : context.colorScheme.secondary,
              minimumSize: const Size(AppSizing.cardBadge, AppSizing.cardBadge),
              textStyle: AppTextStyles.labelMd,
            ),
            child: Text(AppStrings.clearSelection),
          ),
        ],
      ),
    );
  }
}
