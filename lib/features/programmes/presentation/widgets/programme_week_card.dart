import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_workout_slot_card.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_management_section.dart';
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
    this.onAddExercises,
    this.onEditExercise,
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
  final void Function(int slotIndex)? onAddExercises;
  final void Function(int slotIndex, String exerciseId)? onEditExercise;

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(
              alpha: AppProgrammeBuilderTokens.managementBorderOpacity,
            ),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: AppTextStyles.headlineLg
                                            .copyWith(
                                              fontSize: AppFontSizes.xl,
                                              color:
                                                  context.colorScheme.onSurface,
                                            ),
                                      ),
                                      AppWhiteSpace.hXs,
                                      Text(
                                        AppStrings.programmeWorkoutCount(
                                          slots.length,
                                        ),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (slots.isNotEmpty) ...[
                            _CollapsedWeekSummary(slots: slots),
                            AppWhiteSpace.hLg,
                          ],
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
                              onAddExercises: widget.onAddExercises == null
                                  ? null
                                  : () => widget.onAddExercises!(entry.key),
                              onEditExercise: widget.onEditExercise == null
                                  ? null
                                  : (exerciseId) => widget.onEditExercise!(
                                      entry.key,
                                      exerciseId,
                                    ),
                              onChangeDay: widget.onChangeSlotDay != null
                                  ? () => widget.onChangeSlotDay!(entry.key)
                                  : null,
                            ),
                          ),
                          AppWhiteSpace.hXs,
                          ProgrammeBuilderPillButton(
                            label: AppStrings.addWorkoutSlot,
                            onPressed: widget.onAddSlot,
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
        color: context.colorScheme.surfaceContainerHigh.withValues(
          alpha: AppProgrammeBuilderTokens.managementBorderOpacity,
        ),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(
            alpha: AppProgrammeBuilderTokens.borderOpacity,
          ),
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
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
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
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
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.controlGap,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(
                alpha: AppProgrammeBuilderTokens.managementDividerOpacity,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSpacing.sm,
                height: AppSpacing.sm,
                decoration: BoxDecoration(
                  color: context.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              AppWhiteSpace.wXs,
              Flexible(
                child: Text(
                  '$day - $workout',
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
