import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_workout_slot_card.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/week_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeWeekCard extends StatefulWidget {
  const ProgrammeWeekCard({
    super.key,
    required this.week,
    required this.weekIndex,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onAssignTemplate,
    required this.onDuplicate,
    required this.onRemove,
    this.onOpenSupersetEditor,
    this.onSetWeekType,
    this.onChangeSlotDay,
  });

  final ProgrammeBuilderWeekDraft week;
  final int weekIndex;
  final VoidCallback onAddSlot;
  final void Function(int slotIndex) onRemoveSlot;
  final void Function(int slotIndex) onAssignTemplate;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;
  final void Function(int slotIndex)? onOpenSupersetEditor;
  final void Function(WeekType type)? onSetWeekType;
  final void Function(int slotIndex)? onChangeSlotDay;

  @override
  State<ProgrammeWeekCard> createState() => _ProgrammeWeekCardState();
}

class _ProgrammeWeekCardState extends State<ProgrammeWeekCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final slots = widget.week.slots ?? [];
    final title = '${AppStrings.weekLabelPrefix} ${widget.week.weekNumber}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      expanded: _isExpanded,
                      label: title,
                      child: InkWell(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: AppSizing.iconXxl,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: AppSizing.iconXxl,
                                  height: AppSizing.iconXxl,
                                  decoration: BoxDecoration(
                                    color: context
                                        .colorScheme
                                        .surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    OutlinedSvgAssets.clipboardDocumentList,
                                    width: AppSizing.iconMd,
                                    height: AppSizing.iconMd,
                                    colorFilter: ColorFilter.mode(
                                      context.colorScheme.secondary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                AppWhiteSpace.wMd,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: AppTextStyles.headlineMd
                                            .copyWith(
                                              color:
                                                  context.colorScheme.onSurface,
                                            ),
                                      ),
                                      AppWhiteSpace.hXs,
                                      Text(
                                        '${slots.length} ${AppStrings.programmeWorkoutSlotsTitle}',
                                        style: AppTextStyles.bodySm.copyWith(
                                          color: context
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: _isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutCubic,
                                  child: SvgPicture.asset(
                                    OutlinedSvgAssets.chevronDown,
                                    width: AppSizing.iconSm,
                                    height: AppSizing.iconSm,
                                    colorFilter: ColorFilter.mode(
                                      context.colorScheme.onSurfaceVariant,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppWhiteSpace.wXs,
                  Tooltip(
                    message: AppStrings.duplicateWeek,
                    child: AppIconButton(
                      asset: OutlinedSvgAssets.documentDuplicate,
                      onPressed: widget.onDuplicate,
                      semanticLabel: AppStrings.duplicateWeek,
                      backgroundColor: context.colorScheme.surfaceContainerHigh,
                    ),
                  ),
                  Tooltip(
                    message: AppStrings.removeWeek,
                    child: AppIconButton(
                      asset: OutlinedSvgAssets.trash,
                      onPressed: widget.onRemove,
                      semanticLabel: AppStrings.removeWeek,
                      color: context.colorScheme.error,
                      backgroundColor: context.colorScheme.errorContainer,
                    ),
                  ),
                ],
              ),
              if (widget.onSetWeekType != null) ...[
                AppWhiteSpace.hMd,
                _WeekTypeSelector(
                  value: widget.week.weekType ?? WeekType.normal,
                  onChanged: widget.onSetWeekType!,
                ),
              ],
              AppWhiteSpace.hMd,
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _isExpanded
                    ? Column(
                        children: [
                          ...slots.asMap().entries.map(
                            (entry) => ProgrammeWorkoutSlotCard(
                              slot: entry.value,
                              weekIndex: widget.weekIndex,
                              slotIndex: entry.key,
                              onAssignTemplate: () =>
                                  widget.onAssignTemplate(entry.key),
                              onRemove: () => widget.onRemoveSlot(entry.key),
                              onOpenSupersetEditor:
                                  widget.onOpenSupersetEditor != null
                                  ? () =>
                                        widget.onOpenSupersetEditor!(entry.key)
                                  : null,
                              onChangeDay: widget.onChangeSlotDay != null
                                  ? () => widget.onChangeSlotDay!(entry.key)
                                  : null,
                            ),
                          ),
                          AppWhiteSpace.hXs,
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: widget.onAddSlot,
                              icon: SvgPicture.asset(
                                OutlinedSvgAssets.plus,
                                width: AppSizing.iconSm,
                                height: AppSizing.iconSm,
                                colorFilter: ColorFilter.mode(
                                  context.colorScheme.secondary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              label: const Text(AppStrings.addWorkoutSlot),
                            ),
                          ),
                        ],
                      )
                    : _CollapsedWeekSummary(slots: slots),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekTypeSelector extends StatelessWidget {
  const _WeekTypeSelector({required this.value, required this.onChanged});

  final WeekType value;
  final ValueChanged<WeekType> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.weekTypeLabel,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<WeekType>(
                  value: value,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.chevronDown,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  items: WeekType.values
                      .map(
                        (type) => DropdownMenuItem<WeekType>(
                          value: type,
                          child: Text(
                            type.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (type) {
                    if (type != null) onChanged(type);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedWeekSummary extends StatelessWidget {
  const _CollapsedWeekSummary({required this.slots});

  final List<ProgrammeBuilderWorkoutSlotDraft> slots;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Text(
        AppStrings.noWorkoutsInWeek,
        style: AppTextStyles.bodySm.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: slots.map((slot) {
        final day =
            slot.scheduledDay?.displayLabel ??
            '${AppStrings.onboardingDaySingle} ${slot.scheduledDayIndex + 1}';
        final workout = slot.template?.name ?? AppStrings.weekTemplateEmpty;
        return AppBadge(
          label: '$day - $workout',
          backgroundColor: context.colorScheme.surfaceContainerHigh,
          foregroundColor: context.colorScheme.onSurfaceVariant,
          borderRadius: AppRadius.full,
        );
      }).toList(),
    );
  }
}
