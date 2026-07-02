import 'package:flutter/material.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeListTile extends StatelessWidget {
  const ProgrammeListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleActive,
    required this.onArchive,
    required this.onDelete,
  });

  final ProgrammeListItem item;
  final VoidCallback onTap;
  final VoidCallback onToggleActive;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  String _sourceLabel() {
    if (item.imported) return AppStrings.imported;
    if (item.source == 'ai_generated') return AppStrings.aiGenerated;
    return AppStrings.custom;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isActive)
            Container(
              height: 4,
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
                    _Badge(
                      label: _statusLabel().toUpperCase(),
                      backgroundColor: isActive
                          ? context.colorScheme.secondaryContainer
                          : context.colorScheme.surfaceContainer,
                      textColor: isActive
                          ? context.colorScheme.onSecondaryContainer
                          : context.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _Badge(
                      label: _sourceLabel(),
                      backgroundColor: context.colorScheme.surfaceContainer,
                      textColor: context.colorScheme.onSurfaceVariant,
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
                          value: 'delete',
                          child: Text(
                            AppStrings.deleteProgramme,
                            style: TextStyle(color: context.colorScheme.error),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'toggle':
                            onToggleActive();
                          case 'archive':
                            onArchive();
                          case 'delete':
                            onDelete();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: onTap,
                  child: Text(item.name, style: context.textTheme.titleMedium),
                ),
                const SizedBox(height: AppSpacing.md),
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
                    _Stat(value: '—', label: AppStrings.goal),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(color: textColor),
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
