import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/presentation/widgets/bodymap_bucket_chip_bar.dart';
import 'package:aedify/features/bodymap/presentation/widgets/bodymap_svg_view.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
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
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.bodymap),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              OutlinedSvgAssets.arrowsRightLeft,
              width: AppSpacing.lg,
              height: AppSpacing.lg,
              colorFilter: ColorFilter.mode(
                colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            tooltip: state.side.name,
            onPressed: () {
              ref
                  .read(
                    AppProviders.bodymapSelectionControllerProvider.notifier,
                  )
                  .toggleSide();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSpacing.md),
            BodymapSvgView(
              side: state.side,
              selectedBucket: state.selectedBucket,
              onBucketSelected: (bucket) {
                ref
                    .read(
                      AppProviders.bodymapSelectionControllerProvider.notifier,
                    )
                    .selectBucket(bucket);
              },
            ),
            SizedBox(height: AppSpacing.md),
            BodymapBucketChipBar(
              selectedBucket: state.selectedBucket,
              onSelected: (bucket) {
                ref
                    .read(
                      AppProviders.bodymapSelectionControllerProvider.notifier,
                    )
                    .selectBucket(bucket);
              },
              onClear: () {
                ref
                    .read(
                      AppProviders.bodymapSelectionControllerProvider.notifier,
                    )
                    .clearSelection();
              },
            ),
            SizedBox(height: AppSpacing.md),
            if (state.selectedBucket != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
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
                                  AppProviders.exerciseSearchControllerProvider,
                                )
                                .filters
                                .copyWith(
                                  muscleGroup: state.selectedBucket!.label,
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
                      width: AppSizing.iconXs,
                      height: AppSizing.iconXs,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(AppStrings.browseByMuscle),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
