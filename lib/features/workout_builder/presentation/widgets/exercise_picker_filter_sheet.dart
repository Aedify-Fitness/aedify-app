import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/components/app_toggle_pill.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ExercisePickerFilterSheet extends ConsumerStatefulWidget {
  const ExercisePickerFilterSheet({super.key});

  @override
  ConsumerState<ExercisePickerFilterSheet> createState() =>
      _ExercisePickerFilterSheetState();
}

class _ExercisePickerFilterSheetState
    extends ConsumerState<ExercisePickerFilterSheet> {
  final _selectedMuscleGroups = <String>{};
  final _selectedEquipment = <String>{};
  String? _selectedDifficulty;
  final _selectedModalities = <String>{};

  static const _allMuscleGroups = [
    AppStrings.filterChest,
    AppStrings.filterBack,
    AppStrings.filterShoulders,
    AppStrings.filterTriceps,
    AppStrings.filterBiceps,
    AppStrings.filterQuads,
    AppStrings.filterHamstrings,
    AppStrings.filterGlutes,
    AppStrings.filterCore,
  ];

  static const _allEquipment = [
    (AppStrings.filterDumbbell, SolidSvgAssets.dumbbell),
    (AppStrings.filterBarbell, OutlinedSvgAssets.minus),
    (AppStrings.filterMachine, OutlinedSvgAssets.cog),
    (AppStrings.filterBodyweight, OutlinedSvgAssets.user),
  ];

  static const _allDifficulties = [
    (AppStrings.filterNovice, AppStrings.filterNoviceDesc),
    (AppStrings.filterBeginner, AppStrings.filterBeginnerDesc),
    (AppStrings.filterIntermediate, AppStrings.filterIntermediateDesc),
    (AppStrings.filterExpert, AppStrings.filterExpertDesc),
  ];

  static const _allModalities = [
    (AppStrings.filterStrength, SolidSvgAssets.dumbbell),
    (AppStrings.filterFlexibility, SolidSvgAssets.meditation),
    (AppStrings.filterCardio, OutlinedSvgAssets.heart),
  ];

  @override
  void initState() {
    super.initState();
    final filters = ref
        .read(AppProviders.exerciseSearchControllerProvider)
        .filters;

    if (filters.muscleGroup != null) {
      _selectedMuscleGroups.add(filters.muscleGroup!.label);
    }
    final equipmentLabel = _labelForEquipment(filters.equipment);
    if (equipmentLabel != null) {
      _selectedEquipment.add(equipmentLabel);
    }
    _selectedDifficulty = _labelForDifficulty(filters.difficulty);
    final modalityLabel = _labelForModality(filters.modality);
    if (modalityLabel != null) {
      _selectedModalities.add(modalityLabel);
    }
  }

  String? _labelForDifficulty(ExerciseDifficulty? difficulty) {
    return switch (difficulty) {
      ExerciseDifficulty.novice => AppStrings.filterNovice,
      ExerciseDifficulty.beginner => AppStrings.filterBeginner,
      ExerciseDifficulty.intermediate => AppStrings.filterIntermediate,
      ExerciseDifficulty.advanced => AppStrings.filterExpert,
      null => null,
    };
  }

  String? _labelForEquipment(EquipmentTag? tag) {
    return switch (tag) {
      EquipmentTag.dumbbell => AppStrings.filterDumbbell,
      EquipmentTag.barbell => AppStrings.filterBarbell,
      EquipmentTag.machine => AppStrings.filterMachine,
      EquipmentTag.bodyweight => AppStrings.filterBodyweight,
      _ => null,
    };
  }

  String? _labelForModality(ExerciseModality? modality) {
    return switch (modality) {
      ExerciseModality.strength => AppStrings.filterStrength,
      ExerciseModality.flexibility => AppStrings.filterFlexibility,
      ExerciseModality.cardio => AppStrings.filterCardio,
      _ => null,
    };
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedMuscleGroups.isNotEmpty) count++;
    if (_selectedEquipment.isNotEmpty) count++;
    if (_selectedDifficulty != null) count++;
    if (_selectedModalities.isNotEmpty) count++;
    return count;
  }

  BodymapBucket? _bucketForLabel(String label) {
    return switch (label) {
      AppStrings.filterChest => BodymapBucket.chest,
      AppStrings.filterBack => BodymapBucket.back,
      AppStrings.filterShoulders => BodymapBucket.shoulders,
      AppStrings.filterTriceps => BodymapBucket.triceps,
      AppStrings.filterBiceps => BodymapBucket.biceps,
      AppStrings.filterQuads => BodymapBucket.quads,
      AppStrings.filterHamstrings => BodymapBucket.hamstrings,
      AppStrings.filterGlutes => BodymapBucket.glutes,
      AppStrings.filterCore => BodymapBucket.core,
      _ => null,
    };
  }

  EquipmentTag? _equipmentTagForLabel(String label) {
    return switch (label) {
      AppStrings.filterDumbbell => EquipmentTag.dumbbell,
      AppStrings.filterBarbell => EquipmentTag.barbell,
      AppStrings.filterMachine => EquipmentTag.machine,
      AppStrings.filterBodyweight => EquipmentTag.bodyweight,
      _ => null,
    };
  }

  ExerciseDifficulty? _difficultyForLabel(String label) {
    return switch (label) {
      AppStrings.filterNovice => ExerciseDifficulty.novice,
      AppStrings.filterBeginner => ExerciseDifficulty.beginner,
      AppStrings.filterIntermediate => ExerciseDifficulty.intermediate,
      AppStrings.filterExpert => ExerciseDifficulty.advanced,
      _ => null,
    };
  }

  ExerciseModality? _modalityForLabel(String label) {
    return switch (label) {
      AppStrings.filterStrength => ExerciseModality.strength,
      AppStrings.filterFlexibility => ExerciseModality.flexibility,
      AppStrings.filterCardio => ExerciseModality.cardio,
      _ => null,
    };
  }

  void _applyFilters() {
    final controller = ref.read(
      AppProviders.exerciseSearchControllerProvider.notifier,
    );
    final currentFilters = ref
        .read(AppProviders.exerciseSearchControllerProvider)
        .filters;

    final bucket = _selectedMuscleGroups.isNotEmpty
        ? _bucketForLabel(_selectedMuscleGroups.first)
        : null;
    final equipment = _selectedEquipment.isNotEmpty
        ? _equipmentTagForLabel(_selectedEquipment.first)
        : null;
    final difficulty = _selectedDifficulty != null
        ? _difficultyForLabel(_selectedDifficulty!)
        : null;
    final modality = _selectedModalities.isNotEmpty
        ? _modalityForLabel(_selectedModalities.first)
        : null;

    final updated = currentFilters.copyWith(
      searchQuery: currentFilters.searchQuery,
      muscleGroup: bucket,
      clearMuscleGroup: bucket == null,
      equipment: equipment,
      clearEquipment: equipment == null,
      difficulty: difficulty,
      clearDifficulty: difficulty == null,
      modality: modality,
      clearModality: modality == null,
    );
    controller.updateFilters(updated);
    context.pop();
  }

  void _clearAll() {
    setState(() {
      _selectedMuscleGroups.clear();
      _selectedEquipment.clear();
      _selectedDifficulty = null;
      _selectedModalities.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: Container(
                width: AppSizing.iconXxl,
                height: AppSpacing.inputHorizontal,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colorScheme.surfaceContainerHigh),
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.adjustmentsVertical,
                  width: AppSizing.iconS,
                  height: AppSizing.iconS,
                  colorFilter: ColorFilter.mode(
                    colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
                AppWhiteSpace.wSm,
                Expanded(
                  child: Text(
                    AppStrings.filterRefineLibrary,
                    style: AppTextStyles.headlineMd.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _clearAll,
                  child: Text(
                    AppStrings.filterClearAll,
                    style: AppTextStyles.labelMd.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppWhiteSpace.hXl,
                  _MuscleGroupSection(
                    allGroups: _allMuscleGroups,
                    selected: _selectedMuscleGroups,
                    onToggle: (group) {
                      setState(() {
                        if (_selectedMuscleGroups.contains(group)) {
                          _selectedMuscleGroups.remove(group);
                        } else {
                          _selectedMuscleGroups.add(group);
                        }
                      });
                    },
                    colorScheme: colorScheme,
                  ),
                  AppWhiteSpace.custom(height: AppSpacing.xl + AppSpacing.sm),
                  _EquipmentSection(
                    allEquipment: _allEquipment,
                    selected: _selectedEquipment,
                    onToggle: (eq) {
                      setState(() {
                        if (_selectedEquipment.contains(eq)) {
                          _selectedEquipment.remove(eq);
                        } else {
                          _selectedEquipment.add(eq);
                        }
                      });
                    },
                    colorScheme: colorScheme,
                  ),
                  AppWhiteSpace.custom(height: AppSpacing.md),
                  _DifficultySection(
                    allDifficulties: _allDifficulties,
                    selected: _selectedDifficulty,
                    onSelect: (diff) {
                      setState(() => _selectedDifficulty = diff);
                    },
                    colorScheme: colorScheme,
                  ),
                  AppWhiteSpace.custom(height: AppSpacing.xl),
                  _ModalitySection(
                    allModalities: _allModalities,
                    selected: _selectedModalities,
                    onToggle: (mod) {
                      setState(() {
                        if (_selectedModalities.contains(mod)) {
                          _selectedModalities.remove(mod);
                        } else {
                          _selectedModalities.add(mod);
                        }
                      });
                    },
                    colorScheme: colorScheme,
                  ),
                  AppWhiteSpace.hXl,
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.surfaceContainerHigh),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                top: AppSpacing.md,
                right: AppSpacing.lg,
                bottom: AppSpacing.xl,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.filterCancel,
                          style: AppTextStyles.labelMd.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppWhiteSpace.wSm,
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _applyFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.filterApply,
                              style: AppTextStyles.labelMd.copyWith(
                                color: colorScheme.surface,
                              ),
                            ),
                            if (_activeFilterCount > 0) ...[
                              AppWhiteSpace.wSm,
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm - AppSpacing.xxs,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Text(
                                  '$_activeFilterCount',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: colorScheme.surface,
                                  ),
                                ),
                              ),
                            ],
                          ],
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

class _MuscleGroupSection extends StatelessWidget {
  const _MuscleGroupSection({
    required this.allGroups,
    required this.selected,
    required this.onToggle,
    required this.colorScheme,
  });

  final List<String> allGroups;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.filterMuscleGroup,
              style: AppTextStyles.headlineMd.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              AppStrings.filterMultiSelectEnabled,
              style: AppTextStyles.labelSm.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        AppWhiteSpace.hMd,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: allGroups.map((group) {
            final isActive = selected.contains(group);
            return GestureDetector(
              onTap: () => onToggle(group),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg - AppSpacing.xs,
                  vertical: AppSpacing.sm + AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isActive ? colorScheme.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isActive
                        ? colorScheme.secondary
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: Text(
                  group,
                  style: AppTextStyles.labelMd.copyWith(
                    color: isActive
                        ? colorScheme.onSecondary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EquipmentSection extends StatelessWidget {
  const _EquipmentSection({
    required this.allEquipment,
    required this.selected,
    required this.onToggle,
    required this.colorScheme,
  });

  final List<(String, String)> allEquipment;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.filterEquipment,
          style: AppTextStyles.headlineMd.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hMd,
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.buttonVertical,
          crossAxisSpacing: AppSpacing.buttonVertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: allEquipment.map((item) {
            final label = item.$1;
            final icon = item.$2;
            final isActive = selected.contains(label);
            return GestureDetector(
              onTap: () => onToggle(label),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.surfaceContainerLow
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isActive
                        ? colorScheme.secondary
                        : colorScheme.outlineVariant,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      icon,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(
                        isActive
                            ? colorScheme.secondary
                            : colorScheme.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                    AppWhiteSpace.hSm,
                    Text(
                      label,
                      style: AppTextStyles.labelSm.copyWith(
                        color: isActive
                            ? colorScheme.secondary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DifficultySection extends StatelessWidget {
  const _DifficultySection({
    required this.allDifficulties,
    required this.selected,
    required this.onSelect,
    required this.colorScheme,
  });

  final List<(String, String)> allDifficulties;
  final String? selected;
  final ValueChanged<String> onSelect;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.filterDifficulty,
          style: AppTextStyles.headlineMd.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hMd,
        ...allDifficulties.map((item) {
          final label = item.$1;
          final description = item.$2;
          final isActive = selected == label;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.buttonVertical),
            child: GestureDetector(
              onTap: () => onSelect(label),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.secondaryContainer.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                  border: Border.all(
                    color: isActive
                        ? colorScheme.secondary.withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1,
                          color: isActive
                              ? colorScheme.secondary
                              : colorScheme.outlineVariant,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isActive
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.secondary,
                              ),
                            )
                          : null,
                    ),
                    AppWhiteSpace.wMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: AppTextStyles.labelMd.copyWith(
                              color: isActive
                                  ? colorScheme.secondary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          AppWhiteSpace.hXxs,
                          Text(
                            description,
                            style: AppTextStyles.labelSm.copyWith(
                              color: isActive
                                  ? colorScheme.secondary.withValues(alpha: 0.8)
                                  : colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.6,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ModalitySection extends StatelessWidget {
  const _ModalitySection({
    required this.allModalities,
    required this.selected,
    required this.onToggle,
    required this.colorScheme,
  });

  final List<(String, String)> allModalities;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.filterModality,
          style: AppTextStyles.headlineMd.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hMd,
        ...allModalities.map((item) {
          final label = item.$1;
          final icon = item.$2;
          final isActive = selected.contains(label);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.buttonVertical),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    icon,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  AppWhiteSpace.custom(width: AppSpacing.buttonVertical),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.labelMd.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  AppTogglePill(
                    value: isActive,
                    semanticLabel: label,
                    onChanged: (_) => onToggle(label),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
