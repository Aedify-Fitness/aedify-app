import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/superset_grouping_policy.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class ProgrammeSupersetEditorSheet extends StatelessWidget {
  const ProgrammeSupersetEditorSheet({
    super.key,
    required this.exercises,
    required this.selectedExerciseIds,
    required this.onToggleSelection,
    required this.onCreateSuperset,
    this.activeGroupId,
    this.onRemoveMember,
    this.onDeleteGroup,
  });

  final List<ProgrammeExerciseDraft> exercises;
  final Set<String> selectedExerciseIds;
  final ValueChanged<String> onToggleSelection;
  final VoidCallback onCreateSuperset;
  final String? activeGroupId;
  final ValueChanged<String>? onRemoveMember;
  final VoidCallback? onDeleteGroup;

  @override
  Widget build(BuildContext context) {
    final policy = const SupersetGroupingPolicy();
    final canCreate = policy.canCreateGroup(selectedExerciseIds.length);
    final hasActiveGroup = activeGroupId != null;
    final groupMembers = hasActiveGroup
        ? exercises.where((e) => e.supersetGroupId == activeGroupId).toList()
        : <ProgrammeExerciseDraft>[];

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hasActiveGroup
                ? AppStrings.editSuperset
                : AppStrings.createSuperset,
            style: AppTextStyles.headlineMd,
          ),
          AppWhiteSpace.hSm,
          if (!hasActiveGroup)
            Text(
              AppStrings.supersetInvalidSelection,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          if (hasActiveGroup) ...[
            Text(
              AppStrings.groupedExercises,
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            AppWhiteSpace.hXs,
            ...groupMembers.map((ex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        ex.exerciseRef ?? 'Exercise ${ex.exerciseId}',
                        style: AppTextStyles.bodyMd,
                      ),
                    ),
                    if (onRemoveMember != null)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => onRemoveMember!(ex.id),
                        tooltip: AppStrings.removeFromSuperset,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              );
            }),
          ],
          AppWhiteSpace.hMd,
          if (!hasActiveGroup && exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                AppStrings.noExercisesAdded,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else if (!hasActiveGroup)
            ...exercises.map((exercise) {
              final isSelected = selectedExerciseIds.contains(exercise.id);
              return CheckboxListTile(
                title: Text(
                  exercise.exerciseRef ?? 'Exercise ${exercise.exerciseId}',
                ),
                value: isSelected,
                onChanged: (_) => onToggleSelection(exercise.id),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
          AppWhiteSpace.hSm,
          if (!hasActiveGroup)
            FilledButton(
              onPressed: canCreate ? onCreateSuperset : null,
              child: Text(AppStrings.createSuperset),
            ),
          if (hasActiveGroup && onDeleteGroup != null) ...[
            AppWhiteSpace.hXs,
            OutlinedButton(
              onPressed: onDeleteGroup,
              child: Text(AppStrings.deleteSuperset),
            ),
          ],
        ],
      ),
    );
  }
}
