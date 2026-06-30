import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeWorkoutSlotCard extends StatelessWidget {
  const ProgrammeWorkoutSlotCard({
    super.key,
    required this.slot,
    required this.onAssignTemplate,
    required this.onRemove,
    this.weekIndex,
    this.slotIndex,
  });

  final ProgrammeBuilderWorkoutSlotDraft slot;
  final VoidCallback onAssignTemplate;
  final VoidCallback onRemove;
  final int? weekIndex;
  final int? slotIndex;

  @override
  Widget build(BuildContext context) {
    final hasTemplate = slot.template != null;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.sparkles,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasTemplate
                        ? slot.template!.name
                        : AppStrings.weekTemplateEmpty,
                    style: context.textTheme.bodyMedium,
                  ),
                  if (hasTemplate && slot.template!.description != null)
                    Text(
                      slot.template!.description!,
                      style: context.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                OutlinedSvgAssets.arrowsRightLeft,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
              ),
              onPressed: onAssignTemplate,
              tooltip: AppStrings.assignTemplate,
            ),
            IconButton(
              icon: SvgPicture.asset(
                OutlinedSvgAssets.xMark,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.error,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onRemove,
              tooltip: AppStrings.removeSlot,
            ),
          ],
        ),
      ),
    );
  }
}
