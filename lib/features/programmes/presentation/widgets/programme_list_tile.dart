import 'package:flutter/material.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeListTile extends StatelessWidget {
  const ProgrammeListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActive,
    required this.onArchive,
    required this.onDelete,
  });

  final ProgrammeListItem item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  String _sourceLabel() {
    if (item.imported) return AppStrings.imported;
    if (item.source == 'ai_generated') return AppStrings.aiGenerated;
    return AppStrings.custom;
  }

  String _goalLabel() {
    if (item.goalTags.isEmpty) return '\u2014';
    final goal = item.goalTags.first;
    return switch (goal) {
      GoalTag.buildMuscle => AppStrings.onboardingGoalBuildMuscle,
      GoalTag.loseWeight => AppStrings.onboardingGoalLoseWeight,
      GoalTag.increaseStrength => AppStrings.onboardingGoalIncreaseStrength,
      GoalTag.improveEndurance => AppStrings.onboardingGoalImproveEndurance,
      GoalTag.generalFitness => AppStrings.onboardingGoalGeneralFitness,
      GoalTag.flexibility => AppStrings.onboardingGoalFlexibility,
    };
  }

  String _statusLabel() {
    switch (item.status) {
      case ProgramStatus.active:
        return AppStrings.programmeActive;
      case ProgramStatus.completed:
        return AppStrings.completed;
      default:
        return AppStrings.programmeInactive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = item.active;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withAlpha(77),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isActive)
              Container(
                height: AppSizing.activeIndicatorHeight,
                width: double.infinity,
                color: context.colorScheme.secondary,
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppBadge(
                        label: _statusLabel().toUpperCase(),
                        backgroundColor: isActive
                            ? context.colorScheme.secondaryContainer
                            : context.colorScheme.surfaceContainer,
                        foregroundColor: isActive
                            ? context.colorScheme.onSecondaryContainer
                            : context.colorScheme.onSurfaceVariant,
                      ),
                      AppWhiteSpace.wXs,
                      AppBadge(
                        label: _sourceLabel(),
                        backgroundColor: context.colorScheme.surfaceContainer,
                        foregroundColor: context.colorScheme.onSurfaceVariant,
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(
                              isActive
                                  ? AppStrings.deactivateProgramme
                                  : AppStrings.activateProgramme,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'archive',
                            child: const Text(AppStrings.archiveProgramme),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: const Text(AppStrings.editProgramme),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              AppStrings.deleteProgramme,
                              style: context.textTheme.labelLarge?.copyWith(
                                color: context.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case 'toggle':
                              onToggleActive();
                            case 'archive':
                              onArchive();
                            case 'edit':
                              onEdit();
                            case 'delete':
                              onDelete();
                          }
                        },
                      ),
                    ],
                  ),
                  AppWhiteSpace.hSm,
                  Text(item.name, style: context.textTheme.titleMedium),
                  AppWhiteSpace.hMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(
                        value: '${item.weeksTotal ?? 0}',
                        label: AppStrings.weeks,
                      ),
                      _Stat(
                        value: '${item.daysPerWeek ?? 0}',
                        label: AppStrings.daysPerWeek,
                      ),
                      _Stat(value: _goalLabel(), label: AppStrings.goal),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
