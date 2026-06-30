import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_workout_slot_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeWeekCard extends StatelessWidget {
  const ProgrammeWeekCard({
    super.key,
    required this.week,
    required this.weekIndex,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onAssignTemplate,
    required this.onDuplicate,
    required this.onRemove,
  });

  final ProgrammeBuilderWeekDraft week;
  final int weekIndex;
  final VoidCallback onAddSlot;
  final void Function(int slotIndex) onRemoveSlot;
  final void Function(int slotIndex) onAssignTemplate;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final slots = week.slots ?? [];
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.clipboardDocumentList,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${AppStrings.weekLabelPrefix} ${week.weekNumber}',
                    style: context.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.documentDuplicate,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                  ),
                  onPressed: onDuplicate,
                  tooltip: AppStrings.duplicateWeek,
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.trash,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.error,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: onRemove,
                  tooltip: AppStrings.removeWeek,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...slots.asMap().entries.map(
              (entry) => ProgrammeWorkoutSlotCard(
                slot: entry.value,
                weekIndex: weekIndex,
                slotIndex: entry.key,
                onAssignTemplate: () => onAssignTemplate(entry.key),
                onRemove: () => onRemoveSlot(entry.key),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton.icon(
              onPressed: onAddSlot,
              icon: SvgPicture.asset(
                OutlinedSvgAssets.plus,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
              ),
              label: const Text(AppStrings.addWorkoutSlot),
            ),
          ],
        ),
      ),
    );
  }
}
