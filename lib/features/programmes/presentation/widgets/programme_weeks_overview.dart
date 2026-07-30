import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_card.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
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
    this.onOpenSupersetEditor,
    this.onSetWeekType,
    this.onChangeSlotDay,
  });

  final List<ProgrammeBuilderWeekDraft> weeks;
  final VoidCallback onAddWeek;
  final void Function(int weekIndex) onRemoveWeek;
  final void Function(int weekIndex) onDuplicateWeek;
  final void Function(int weekIndex) onAddSlot;
  final void Function(int weekIndex, int slotIndex) onRemoveSlot;
  final void Function(int weekIndex, int slotIndex) onAssignTemplate;
  final void Function(int weekIndex, int slotIndex)? onOpenSupersetEditor;
  final void Function(int weekIndex, WeekType type)? onSetWeekType;
  final void Function(int weekIndex, int slotIndex)? onChangeSlotDay;

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Container(
                width: AppSizing.iconXxl,
                height: AppSizing.iconXxl,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  OutlinedSvgAssets.calendar,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              AppWhiteSpace.hMd,
              Text(
                AppStrings.noWeeksAdded,
                style: AppTextStyles.headlineMd.copyWith(
                  color: context.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              AppWhiteSpace.hSm,
              Text(
                AppStrings.noWeeksAddedHint,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              AppWhiteSpace.hLg,
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAddWeek,
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.plus,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: const Text(AppStrings.addWeek),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.programmeWeeksSectionTitle,
                style: AppTextStyles.headlineLgMobile.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ),
            AppBadge(
              label: '${weeks.length} ${AppStrings.weeks}',
              backgroundColor: context.colorScheme.surfaceContainerHigh,
              foregroundColor: context.colorScheme.onSurfaceVariant,
              borderRadius: AppRadius.full,
            ),
          ],
        ),
        AppWhiteSpace.hMd,
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
            onOpenSupersetEditor: onOpenSupersetEditor != null
                ? (slotIndex) => onOpenSupersetEditor!(entry.key, slotIndex)
                : null,
            onSetWeekType: onSetWeekType != null
                ? (type) => onSetWeekType!(entry.key, type)
                : null,
            onChangeSlotDay: onChangeSlotDay != null
                ? (slotIndex) => onChangeSlotDay!(entry.key, slotIndex)
                : null,
          ),
        ),
        AppWhiteSpace.hXs,
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAddWeek,
            icon: SvgPicture.asset(
              OutlinedSvgAssets.plus,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            label: const Text(AppStrings.addWeek),
          ),
        ),
      ],
    );
  }
}
