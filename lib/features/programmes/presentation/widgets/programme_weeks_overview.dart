import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeWeeksOverview extends StatelessWidget {
  const ProgrammeWeeksOverview({
    super.key,
    required this.weeks,
    required this.onAddWeek,
    required this.onRemoveWeek,
    required this.onDuplicateWeek,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onAssignTemplate,
  });

  final List<ProgrammeBuilderWeekDraft> weeks;
  final VoidCallback onAddWeek;
  final void Function(int weekIndex) onRemoveWeek;
  final void Function(int weekIndex) onDuplicateWeek;
  final void Function(int weekIndex) onAddSlot;
  final void Function(int weekIndex, int slotIndex) onRemoveSlot;
  final void Function(int weekIndex, int slotIndex) onAssignTemplate;

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.calendar,
              width: AppSizing.iconLg,
              height: AppSizing.iconLg,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(AppStrings.noWeeksAdded, style: context.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.noWeeksAddedHint,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.programmeWeeksSectionTitle,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...weeks.asMap().entries.map(
          (entry) => ProgrammeWeekCard(
            week: entry.value,
            weekIndex: entry.key,
            onAddSlot: () => onAddSlot(entry.key),
            onRemoveSlot: (slotIndex) => onRemoveSlot(entry.key, slotIndex),
            onAssignTemplate: (slotIndex) =>
                onAssignTemplate(entry.key, slotIndex),
            onDuplicate: () => onDuplicateWeek(entry.key),
            onRemove: () => onRemoveWeek(entry.key),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: onAddWeek,
          icon: SvgPicture.asset(
            OutlinedSvgAssets.plus,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
          ),
          label: const Text(AppStrings.addWeek),
        ),
      ],
    );
  }
}
