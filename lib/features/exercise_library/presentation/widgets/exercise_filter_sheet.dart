import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseFilterSheet extends ConsumerWidget {
  const ExerciseFilterSheet({super.key, required this.initialFilters});

  final ExerciseFilterState initialFilters;

  static const List<String> difficultyOptions = [
    'beginner',
    'intermediate',
    'advanced',
  ];

  static const List<String> modalityOptions = [
    'strength',
    'hypertrophy',
    'endurance',
    'power',
    'olympic_weightlifting',
    'cardio',
    'flexibility',
    'plyometrics',
    'strongman',
  ];

  static const List<String> equipmentOptions = [
    'barbell',
    'dumbbell',
    'cable',
    'machine',
    'bodyweight',
    'kettlebell',
    'bands',
    'ez_bar',
    'other',
  ];

  static const List<String> muscleGroupOptions = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Forearms',
    'Quadriceps',
    'Hamstrings',
    'Glutes',
    'Calves',
    'Abdominals',
    'Obliques',
    'Lower Back',
    'Traps',
    'Neck',
  ];

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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(AppStrings.filters, style: context.textTheme.headlineSmall),
            SizedBox(height: AppSpacing.md),
            _FilterSection(
              title: AppStrings.filterMuscleGroup,
              options: muscleGroupOptions,
              selected: initialFilters.muscleGroup,
              onSelected: (value) {
                final updated = initialFilters.copyWith(
                  muscleGroup: value,
                  clearMuscleGroup: value == null,
                );
                ref
                    .read(
                      AppProviders.exerciseSearchControllerProvider.notifier,
                    )
                    .updateFilters(updated);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: AppSpacing.md),
            _FilterSection(
              title: AppStrings.filterDifficulty,
              options: difficultyOptions,
              selected: initialFilters.difficulty,
              onSelected: (value) {
                final updated = initialFilters.copyWith(
                  difficulty: value,
                  clearDifficulty: value == null,
                );
                ref
                    .read(
                      AppProviders.exerciseSearchControllerProvider.notifier,
                    )
                    .updateFilters(updated);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: AppSpacing.md),
            _FilterSection(
              title: AppStrings.filterModality,
              options: modalityOptions,
              selected: initialFilters.modality,
              onSelected: (value) {
                final updated = initialFilters.copyWith(
                  modality: value,
                  clearModality: value == null,
                );
                ref
                    .read(
                      AppProviders.exerciseSearchControllerProvider.notifier,
                    )
                    .updateFilters(updated);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: AppSpacing.md),
            _FilterSection(
              title: AppStrings.filterEquipment,
              options: equipmentOptions,
              selected: initialFilters.equipment,
              onSelected: (value) {
                final updated = initialFilters.copyWith(
                  equipment: value,
                  clearEquipment: value == null,
                );
                ref
                    .read(
                      AppProviders.exerciseSearchControllerProvider.notifier,
                    )
                    .updateFilters(updated);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: AppSpacing.md),
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
                Navigator.pop(context);
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
                Navigator.pop(context);
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (initialFilters.hasActiveFilters) ...[
              SizedBox(height: AppSpacing.md),
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
                    Navigator.pop(context);
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
        SizedBox(height: AppSpacing.sm),
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
