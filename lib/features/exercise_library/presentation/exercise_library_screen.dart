import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_card.dart';
import 'package:aedify/shared/components/create_action_fab.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_bodymap.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/widgets/dashed_border_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  bool _isListView = true;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(
      AppProviders.exerciseSearchControllerProvider,
    );
    final colorScheme = context.colorScheme;

    _syncSearchController(searchState.filters.searchQuery);

    return Scaffold(
      body: searchState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchState.errorCode != null
          ? _ErrorView(
              errorMessage: searchState.errorMessage,
              colorScheme: colorScheme,
              onRetry: () {
                ref
                    .read(
                      AppProviders.exerciseSearchControllerProvider.notifier,
                    )
                    .reload();
              },
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppWhiteSpace.hLg,
                        _SearchBar(
                          controller: _searchController,
                          onChanged: (query) {
                            ref
                                .read(
                                  AppProviders
                                      .exerciseSearchControllerProvider
                                      .notifier,
                                )
                                .updateSearchQuery(query);
                          },
                        ),
                        AppWhiteSpace.hMd,
                        _ViewToggle(
                          isListView: _isListView,
                          onToggle: (isListView) {
                            setState(() => _isListView = isListView);
                          },
                        ),
                        AppWhiteSpace.hXl,
                        _MuscleGroupChips(
                          selectedBucket: searchState.filters.muscleGroup,
                          selectedModality: searchState.filters.modality,
                          onSelected: (bucket, modality) {
                            final updatedFilters = searchState.filters.copyWith(
                              muscleGroup: bucket,
                              modality: modality,
                              clearMuscleGroup: bucket == null,
                              clearModality: modality == null,
                            );
                            ref
                                .read(
                                  AppProviders
                                      .exerciseSearchControllerProvider
                                      .notifier,
                                )
                                .updateFilters(updatedFilters);
                          },
                        ),
                        AppWhiteSpace.hLg,
                      ],
                    ),
                  ),
                ),
                if (searchState.isEmpty)
                  SliverToBoxAdapter(child: _EmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    sliver: SliverList.separated(
                      itemCount: searchState.items.length,
                      separatorBuilder: (_, _) => AppWhiteSpace.hLg,
                      itemBuilder: (context, index) {
                        return ExerciseCard(
                          item: searchState.items[index],
                          onTap: () {
                            context.pushNamed(
                              AppRoutes.exerciseDetail().name,
                              pathParameters: {
                                'id': '${searchState.items[index].id}',
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxxl * 2),
                ),
              ],
            ),
      floatingActionButton: CreateActionFab(
        onPressed: () {
          context.pushNamed(AppRoutes.customExerciseCreate().name);
        },
      ),
    );
  }

  void _syncSearchController(String query) {
    final current = _searchController.text;
    if (current != query) {
      _searchController.text = query;
    }
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.isListView, required this.onToggle});

  final bool isListView;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TogglePill(
              label: AppStrings.exerciseLibrary,
              iconAsset: OutlinedSvgAssets.listBullet,
              isSelected: isListView,
              onTap: () => onToggle(true),
            ),
            _TogglePill(
              label: AppStrings.bodymap,
              iconAsset: BodymapSvgAssets.front,
              isSelected: !isListView,
              onTap: () => onToggle(false),
            ),
          ],
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.iconAsset,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.secondary.withValues(alpha: 0.3),
                    blurRadius: AppSpacing.sm,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? colorScheme.onSecondary
                    : colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: isSelected
                    ? colorScheme.onSecondary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: AppSpacing.sm,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: AppStrings.searchExercises,
          hintStyle: AppTextStyles.bodyMd.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.sm,
            ),
            child: SvgPicture.asset(
              OutlinedSvgAssets.magnifyingGlass,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                colorScheme.outline,
                BlendMode.srcIn,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(
              color: colorScheme.secondary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

class _FilterChipData {
  const _FilterChipData({
    required this.label,
    this.muscleBucket,
    this.modality,
  });

  final String label;
  final BodymapBucket? muscleBucket;
  final ExerciseModality? modality;

  static const List<_FilterChipData> items = [
    _FilterChipData(label: 'All'),
    _FilterChipData(label: 'Chest', muscleBucket: BodymapBucket.chest),
    _FilterChipData(label: 'Back', muscleBucket: BodymapBucket.back),
    _FilterChipData(label: 'Legs', muscleBucket: BodymapBucket.quads),
    _FilterChipData(label: 'Shoulders', muscleBucket: BodymapBucket.shoulders),
    _FilterChipData(label: 'Arms', muscleBucket: BodymapBucket.biceps),
    _FilterChipData(label: 'Core', muscleBucket: BodymapBucket.core),
    _FilterChipData(label: 'Cardio', modality: ExerciseModality.cardio),
  ];
}

class _MuscleGroupChips extends StatelessWidget {
  const _MuscleGroupChips({
    required this.selectedBucket,
    required this.selectedModality,
    required this.onSelected,
  });

  final BodymapBucket? selectedBucket;
  final ExerciseModality? selectedModality;
  final void Function(BodymapBucket?, ExerciseModality?) onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return SizedBox(
      height: AppSpacing.xl + AppSpacing.sm,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
        itemCount: _FilterChipData.items.length,
        separatorBuilder: (_, _) => AppWhiteSpace.wSm,
        itemBuilder: (context, index) {
          final chip = _FilterChipData.items[index];
          final isSelected = chip.muscleBucket == null && chip.modality == null
              ? selectedBucket == null && selectedModality == null
              : chip.muscleBucket == selectedBucket &&
                    chip.modality == selectedModality;

          return GestureDetector(
            onTap: () => onSelected(chip.muscleBucket, chip.modality),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.secondary
                    : colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: isSelected
                    ? null
                    : Border.all(color: colorScheme.outlineVariant),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colorScheme.secondary.withValues(alpha: 0.3),
                          blurRadius: AppSpacing.sm,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                chip.label,
                style: AppTextStyles.labelMd.copyWith(
                  color: isSelected
                      ? colorScheme.onSecondary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        height: AppSizing.emptyStateHeight,
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: colorScheme.outlineVariant,
            strokeWidth: 2,
            dashWidth: AppSpacing.sm,
            gapWidth: AppSpacing.sm,
            borderRadius: AppRadius.md,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSpacing.xxl,
                  height: AppSpacing.xxl,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      OutlinedSvgAssets.plusSmall,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(
                        colorScheme.outline,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                AppWhiteSpace.hMd,
                Text(
                  AppStrings.noExercisesFound,
                  style: AppTextStyles.labelMd.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                AppWhiteSpace.hXs,
                Text(
                  AppStrings.noCustomExercisesYetHint,
                  style: AppTextStyles.labelSm.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.errorMessage,
    required this.colorScheme,
    required this.onRetry,
  });

  final String? errorMessage;
  final ColorScheme colorScheme;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSpacing.xxl,
              height: AppSpacing.xxl,
              colorFilter: ColorFilter.mode(colorScheme.error, BlendMode.srcIn),
            ),
            AppWhiteSpace.hMd,
            Text(
              errorMessage ?? AppStrings.exerciseLibraryLoadFailed,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
            AppWhiteSpace.hMd,
            FilledButton(onPressed: onRetry, child: Text(AppStrings.tryAgain)),
          ],
        ),
      ),
    );
  }
}
