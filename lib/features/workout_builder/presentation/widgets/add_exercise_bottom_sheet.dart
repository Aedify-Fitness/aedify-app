import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/exercise_picker_filter_sheet.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class AddExerciseBottomSheet extends ConsumerStatefulWidget {
  const AddExerciseBottomSheet({super.key, required this.onSelectExercises});

  final ValueChanged<List<ExerciseReference>> onSelectExercises;

  @override
  ConsumerState<AddExerciseBottomSheet> createState() =>
      _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState
    extends ConsumerState<AddExerciseBottomSheet> {
  late final TextEditingController _searchController;
  final _selected = <ExerciseReference>{};
  String? _selectedMuscleGroup;

  static const _filterLabels = [
    AppStrings.filterAll,
    AppStrings.filterChest,
    AppStrings.filterBack,
    AppStrings.filterLegs,
    AppStrings.filterShoulders,
    AppStrings.filterArms,
    AppStrings.filterCore,
  ];

  @override
  void initState() {
    super.initState();
    final initial = ref
        .read(AppProviders.exerciseSearchControllerProvider)
        .filters
        .searchQuery;
    _searchController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  BodymapBucket? _bucketForLabel(String label) {
    return switch (label) {
      AppStrings.filterChest => BodymapBucket.chest,
      AppStrings.filterBack => BodymapBucket.back,
      AppStrings.filterLegs => BodymapBucket.quads,
      AppStrings.filterShoulders => BodymapBucket.shoulders,
      AppStrings.filterCore => BodymapBucket.core,
      _ => null,
    };
  }

  bool _isSelected(ExerciseReference ex) {
    return _selected.any((s) => s.exerciseId == ex.exerciseId);
  }

  void _toggle(ExerciseListItem item) {
    final ex = ExerciseReference(
      exerciseId: item.id,
      name: item.name,
      modality: item.modality.dbValue,
      equipment: item.equipment?.dbValue,
      isCustom: item.isCustom,
    );
    setState(() {
      if (_isSelected(ex)) {
        _selected.remove(
          _selected.firstWhere((s) => s.exerciseId == ex.exerciseId),
        );
      } else {
        _selected.add(ex);
      }
    });
  }

  void _clearSelection() {
    setState(() => _selected.clear());
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ExercisePickerFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(
      AppProviders.exerciseSearchControllerProvider,
    );
    final searchController = ref.read(
      AppProviders.exerciseSearchControllerProvider.notifier,
    );
    final colorScheme = context.colorScheme;
    final brightness = context.theme.brightness;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Center(
              child: Container(
                width: AppSizing.handleWidth,
                height: AppSpacing.xs,
                decoration: BoxDecoration(
                  color: brightness == Brightness.light
                      ? AedifyLightColors.handleBarColor
                      : AedifyDarkColors.handleBarColor,
                  borderRadius: BorderRadius.circular(AppRadius.xxs),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.full),
              onTap: () => context.pop(),
              child: Container(
                width: AppSizing.iconXxl,
                height: AppSizing.iconXxl,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  OutlinedSvgAssets.xMark,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          AppWhiteSpace.hSm,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchExercises,
                  hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.buttonVertical,
                    ),
                    child: SvgPicture.asset(
                      OutlinedSvgAssets.magnifyingGlass,
                      width: AppSizing.iconS,
                      height: AppSizing.iconS,
                      colorFilter: ColorFilter.mode(
                        colorScheme.outline,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.buttonVertical,
                      ),
                      child: SvgPicture.asset(
                        OutlinedSvgAssets.adjustmentsHorizontal,
                        width: AppSizing.iconS,
                        height: AppSizing.iconS,
                        colorFilter: ColorFilter.mode(
                          colorScheme.outline,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.buttonVertical,
                  ),
                ),
                style: AppTextStyles.bodyMd.copyWith(
                  color: colorScheme.onSurface,
                ),
                onChanged: (query) => searchController.updateSearchQuery(query),
              ),
            ),
          ),
          AppWhiteSpace.hMd,
          SizedBox(
            height: 34,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              scrollDirection: Axis.horizontal,
              itemCount: _filterLabels.length,
              separatorBuilder: (_, _) => AppWhiteSpace.wSm,
              itemBuilder: (context, index) {
                final label = _filterLabels[index];
                final isActive = label == AppStrings.filterAll
                    ? _selectedMuscleGroup == null
                    : _selectedMuscleGroup == label;
                return _FilterChip(
                  label: label,
                  isActive: isActive,
                  onTap: () {
                    setState(() {
                      _selectedMuscleGroup = label == AppStrings.filterAll
                          ? null
                          : label;
                    });
                    final bucket = _bucketForLabel(label);
                    final updated = searchState.filters.copyWith(
                      muscleGroup: bucket,
                      clearMuscleGroup: bucket == null,
                    );
                    searchController.updateFilters(updated);
                  },
                );
              },
            ),
          ),
          AppWhiteSpace.hSm,
          Expanded(
            child: searchState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchState.errorCode != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            searchState.errorMessage ?? AppStrings.searchFailed,
                            style: AppTextStyles.labelSm.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                          AppWhiteSpace.hSm,
                          TextButton(
                            onPressed: () => searchController.reload(),
                            child: Text(AppStrings.retry),
                          ),
                        ],
                      ),
                    ),
                  )
                : searchState.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.noExercisesFound,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        AppWhiteSpace.hMd,
                        _CreateCustomExerciseTile(
                          onTap: () async {
                            final result = await context.pushNamed(
                              AppRoutes.customExerciseCreate().name,
                            );
                            if (result == true && context.mounted) {
                              searchController.reload();
                            }
                          },
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: 100,
                    ),
                    itemCount: searchState.items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == searchState.items.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: _CreateCustomExerciseTile(
                            onTap: () async {
                              final result = await context.pushNamed(
                                AppRoutes.customExerciseCreate().name,
                              );
                              if (result == true && context.mounted) {
                                searchController.reload();
                              }
                            },
                          ),
                        );
                      }
                      final item = searchState.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _ExerciseCard(
                          item: item,
                          isSelected: _isSelected(
                            ExerciseReference(
                              exerciseId: item.id,
                              name: item.name,
                              modality: item.modality.dbValue,
                              equipment: item.equipment?.dbValue,
                              isCustom: item.isCustom,
                            ),
                          ),
                          onTap: () => _toggle(item),
                        ),
                      );
                    },
                  ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.95),
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
            ),
            height: _selected.isEmpty
                ? 0
                : 72 + MediaQuery.of(context).padding.bottom,
            child: _selected.isEmpty
                ? null
                : Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: Row(
                      children: [
                        AppWhiteSpace.wSm,
                        TextButton(
                          onPressed: _clearSelection,
                          child: Text(
                            AppStrings.filterClearAll,
                            style: AppTextStyles.labelMd.copyWith(
                              color: colorScheme.secondary,
                            ),
                          ),
                        ),
                        AppWhiteSpace.wSm,
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.md,
                            ),
                            child: FilledButton(
                              onPressed: () {
                                widget.onSelectExercises(_selected.toList());
                                context.pop();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.secondary,
                                foregroundColor: colorScheme.onSecondary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.buttonVertical,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                              ),
                              child: Text(
                                AppStrings.filterConfirmSelection(
                                  _selected.length,
                                ),
                                style: AppTextStyles.labelMd.copyWith(
                                  color: colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.lg - AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.secondary : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: isActive
              ? null
              : Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: isActive
                ? colorScheme.onSecondary
                : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final ExerciseListItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          border: Border.all(
            color: isSelected ? colorScheme.secondary : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      AppRadius.defaultRadius,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppRadius.defaultRadius,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        SolidSvgAssets.checkCircle,
                        width: AppSizing.iconLg,
                        height: AppSizing.iconLg,
                        colorFilter: ColorFilter.mode(
                          colorScheme.secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AppWhiteSpace.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: isSelected
                          ? colorScheme.secondary
                          : colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppWhiteSpace.hXs,
                  Row(
                    children: [
                      _TagChip(
                        label: item.muscleGroups.isNotEmpty
                            ? item.muscleGroups.first.label
                            : item.modality.dbValue,
                      ),
                      if (item.equipment != null) ...[
                        AppWhiteSpace.wSm,
                        _TagChip(
                          label: _formatEquipment(item.equipment!.dbValue),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            AppWhiteSpace.wSm,
            _DifficultyBadge(difficulty: item.difficulty),
          ],
        ),
      ),
    );
  }

  String _formatEquipment(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTextStyles.headlineXl.copyWith(
          fontSize: AppFontSizes.xxs,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final ExerciseDifficulty? difficulty;

  @override
  Widget build(BuildContext context) {
    final brightness = context.theme.brightness;

    final (Color bg, Color text) = switch (difficulty) {
      ExerciseDifficulty.novice => (
        brightness == Brightness.light
            ? AedifyLightColors.difficultyNoviceBg
            : AedifyDarkColors.difficultyNoviceBg,
        brightness == Brightness.light
            ? AedifyLightColors.difficultyNoviceText
            : AedifyDarkColors.difficultyNoviceText,
      ),
      ExerciseDifficulty.intermediate => (
        brightness == Brightness.light
            ? AedifyLightColors.difficultyIntermediateBg
            : AedifyDarkColors.difficultyIntermediateBg,
        brightness == Brightness.light
            ? AedifyLightColors.difficultyIntermediateText
            : AedifyDarkColors.difficultyIntermediateText,
      ),
      ExerciseDifficulty.advanced => (
        brightness == Brightness.light
            ? AedifyLightColors.difficultyAdvancedBg
            : AedifyDarkColors.difficultyAdvancedBg,
        brightness == Brightness.light
            ? AedifyLightColors.difficultyAdvancedText
            : AedifyDarkColors.difficultyAdvancedText,
      ),
      _ => (
        brightness == Brightness.light
            ? AedifyLightColors.difficultyBeginnerBg
            : AedifyDarkColors.difficultyBeginnerBg,
        brightness == Brightness.light
            ? AedifyLightColors.difficultyBeginnerText
            : AedifyDarkColors.difficultyBeginnerText,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        _formatLabel(difficulty?.dbValue ?? 'beginner'),
        style: AppTextStyles.headlineXl.copyWith(
          color: text,
          letterSpacing: 0.5,
          fontSize: AppFontSizes.xxs,
        ),
      ),
    );
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _CreateCustomExerciseTile extends StatelessWidget {
  const _CreateCustomExerciseTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                OutlinedSvgAssets.plus,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(
                  colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            AppWhiteSpace.wMd,
            Text(
              AppStrings.createCustomExercise,
              style: AppTextStyles.bodyMd.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
