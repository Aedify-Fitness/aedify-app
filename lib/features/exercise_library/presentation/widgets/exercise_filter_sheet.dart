import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExerciseFilterSheet extends ConsumerWidget {
  const ExerciseFilterSheet({super.key, required this.initialFilters});

  final ExerciseFilterState initialFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: AppSizing.handleWidth,
                height: AppSpacing.xs,
                decoration: BoxDecoration(
                  color: colorScheme.brightness == Brightness.light
                      ? AedifyLightColors.surfaceVariantFaded
                      : AedifyDarkColors.surfaceVariantFaded,
                  borderRadius: BorderRadius.circular(AppRadius.xxs),
                ),
              ),
            ),
            AppWhiteSpace.hLg,
            Text(AppStrings.filters, style: context.textTheme.headlineSmall),
            AppWhiteSpace.hMd,
            _FilterSection(
              title: AppStrings.filterMuscleGroup,
              options: BodymapBucket.values.map((e) => e.label).toList(),
              selected: initialFilters.muscleGroup?.label,
              onSelected: (value) {
                final updated = initialFilters.copyWith(
                  muscleGroup: value == null
                      ? null
                      : BodymapBucket.values.firstWhere(
                          (e) => e.label == value,
                        ),
                  clearMuscleGroup: value == null,
                );
                ref
                    .read(
                      AppProviders.exerciseSearchControllerProvider.notifier,
                    )
                    .updateFilters(updated);
                context.pop();
              },
            ),
            AppWhiteSpace.hMd,
            _FilterSection(
              title: AppStrings.filterDifficulty,
              options: ExerciseDifficulty.values
                  .where((e) => e != ExerciseDifficulty.novice)
                  .map((e) => _formatLabel(e.dbValue))
                  .toList(),
              selected: initialFilters.difficulty == null
                  ? null
                  : _formatLabel(initialFilters.difficulty!.dbValue),
              onSelected: (value) {
                final updated = initialFilters.copyWith(
                  difficulty: value == null
                      ? null
                      : ExerciseDifficulty.fromDb(
                          value.toLowerCase().replaceAll(' ', '_'),
                        ),
                  clearDifficulty: value == null,
                );
                ref
                    .read(
                      AppProviders.exerciseSearchControllerProvider.notifier,
                    )
                    .updateFilters(updated);
                context.pop();
              },
            ),
            AppWhiteSpace.hMd,
            _FilterSection(
              title: AppStrings.filterModality,
              options: ExerciseModality.values
                  .map((e) => _formatLabel(e.dbValue))
                  .toList(),
              selected: initialFilters.modality == null
                  ? null
                  : _formatLabel(initialFilters.modality!.dbValue),
              onSelected: (value) {
                final updated = initialFilters.copyWith(
                  modality: value == null
                      ? null
                      : ExerciseModality.fromDb(
                          value.toLowerCase().replaceAll(' ', '_'),
                        ),
                  clearModality: value == null,
                );
                ref
                    .read(
                      AppProviders.exerciseSearchControllerProvider.notifier,
                    )
                    .updateFilters(updated);
                context.pop();
              },
            ),
            AppWhiteSpace.hMd,
            _FilterSection(
              title: AppStrings.filterEquipment,
              options: const [
                EquipmentTag.barbell,
                EquipmentTag.dumbbell,
                EquipmentTag.cable,
                EquipmentTag.machine,
                EquipmentTag.bodyweight,
                EquipmentTag.kettlebell,
                EquipmentTag.bands,
                EquipmentTag.ezBar,
                EquipmentTag.other,
              ].map((e) => _formatLabel(e.dbValue)).toList(),
              selected: initialFilters.equipment == null
                  ? null
                  : _formatLabel(initialFilters.equipment!.dbValue),
              onSelected: (value) {
                final updated = initialFilters.copyWith(
                  equipment: value == null
                      ? null
                      : EquipmentTag.fromDb(
                          value.toLowerCase().replaceAll(' ', '_'),
                        ),
                  clearEquipment: value == null,
                );
                ref
                    .read(
                      AppProviders.exerciseSearchControllerProvider.notifier,
                    )
                    .updateFilters(updated);
                context.pop();
              },
            ),
            AppWhiteSpace.hMd,
            SwitchListTile(
              title: const Text(AppStrings.favoritesOnly),
              value: initialFilters.favoritesOnly,
              onChanged: (value) {
                final updated = initialFilters.copyWith(favoritesOnly: value);
                ref
                    .read(
                      AppProviders.exerciseSearchControllerProvider.notifier,
                    )
                    .updateFilters(updated);
                context.pop();
              },
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text(AppStrings.excludeSubstituted),
              value: initialFilters.excludeSubstituted,
              onChanged: (value) {
                final updated = initialFilters.copyWith(
                  excludeSubstituted: value,
                );
                ref
                    .read(
                      AppProviders.exerciseSearchControllerProvider.notifier,
                    )
                    .updateFilters(updated);
                context.pop();
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (initialFilters.hasActiveFilters) ...[
              AppWhiteSpace.hMd,
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref
                        .read(
                          AppProviders
                              .exerciseSearchControllerProvider
                              .notifier,
                        )
                        .clearFilters();
                    context.pop();
                  },
                  child: Text(AppStrings.clearFilters),
                ),
              ),
            ],
          ],
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

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final void Function(String? value) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ChoiceChip(
              label: Text(AppStrings.filterAny),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
            ...options.map(
              (option) => ChoiceChip(
                label: Text(_formatOption(option)),
                selected: selected == option,
                onSelected: (isSelected) =>
                    onSelected(isSelected ? option : null),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatOption(String option) {
    return option
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }
}
