import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_section.dart';
import 'package:aedify/shared/components/app_toggle_pill.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Seven-day schedule backed by the selected week's actual workout slots.
class ProgrammeBuilderSchedule extends StatelessWidget {
  const ProgrammeBuilderSchedule({
    super.key,
    required this.weeks,
    this.blockLabel,
    required this.weekIndex,
    required this.onWeekChanged,
    required this.onToggleDay,
    required this.onAssignDay,
    required this.onClearTemplate,
    this.onRepeatTemplate,
    this.repeatedSlotIndices = const {},
  });
  final List<ProgrammeBuilderWeekDraft> weeks;
  final String? blockLabel;
  final int weekIndex;
  final ValueChanged<int> onWeekChanged;
  final void Function(TrainingDay day, bool enabled) onToggleDay;
  final void Function(TrainingDay day, int? slotIndex) onAssignDay;
  final ValueChanged<int> onClearTemplate;
  final ValueChanged<int>? onRepeatTemplate;
  final Set<int> repeatedSlotIndices;

  @override
  Widget build(BuildContext context) {
    final slots = weeks.isEmpty
        ? <ProgrammeBuilderWorkoutSlotDraft>[]
        : weeks[weekIndex].slots ?? <ProgrammeBuilderWorkoutSlotDraft>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Text(
        //   AppStrings.planYourWeek,
        //   style: AppTextStyles.headlineLgMobile.copyWith(
        //     color: context.colorScheme.onSurface,
        //   ),
        // ),
        // AppWhiteSpace.hSm,
        // Text(
        //   AppStrings.planYourWeekHint,
        //   style: AppTextStyles.bodyMd.copyWith(
        //     color: context.colorScheme.onSurfaceVariant,
        //   ),
        // ),
        // AppWhiteSpace.hMd,
        if (blockLabel != null) ...[
          Text(
            blockLabel!,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.secondary,
            ),
          ),
          AppWhiteSpace.hMd,
        ],
        if (weeks.length > 1) ...[
          DropdownButtonFormField<int>(
            key: ValueKey('programme_schedule_week_$weekIndex'),
            initialValue: weekIndex,
            isExpanded: true,
            icon: SvgPicture.asset(
              OutlinedSvgAssets.chevronDown,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
            items: List.generate(
              weeks.length,
              (index) => DropdownMenuItem(
                value: index,
                child: Text(
                  '${AppStrings.weekLabelPrefix} ${weeks[index].weekNumber}',
                ),
              ),
            ),
            onChanged: (index) {
              if (index != null) onWeekChanged(index);
            },
          ),
          AppWhiteSpace.hLg,
        ],
        for (final day in TrainingDay.values) ...[
          _DayScheduleCard(
            key: ValueKey('programme_schedule_${weekIndex}_${day.name}'),
            day: day,
            slots: slots
                .asMap()
                .entries
                .where(
                  (entry) =>
                      entry.value.scheduledDayIndex ==
                      TrainingDay.values.indexOf(day),
                )
                .toList(),
            onToggle: (enabled) => onToggleDay(day, enabled),
            onAssign: (index) => onAssignDay(day, index),
            onClearTemplate: onClearTemplate,
            onRepeatTemplate: onRepeatTemplate,
            repeatedSlotIndices: repeatedSlotIndices,
          ),
          AppWhiteSpace.hMd,
        ],
      ],
    );
  }
}

class _DayScheduleCard extends StatefulWidget {
  const _DayScheduleCard({
    super.key,
    required this.day,
    required this.slots,
    required this.onToggle,
    required this.onAssign,
    required this.onClearTemplate,
    this.onRepeatTemplate,
    this.repeatedSlotIndices = const {},
  });
  final TrainingDay day;
  final List<MapEntry<int, ProgrammeBuilderWorkoutSlotDraft>> slots;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int?> onAssign;
  final ValueChanged<int> onClearTemplate;
  final ValueChanged<int>? onRepeatTemplate;
  final Set<int> repeatedSlotIndices;
  @override
  State<_DayScheduleCard> createState() => _DayScheduleCardState();
}

class _DayScheduleCardState extends State<_DayScheduleCard> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final training = widget.slots.isNotEmpty;
    final names = widget.slots
        .map((entry) => entry.value.template?.name)
        .whereType<String>()
        .join(', ');
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: AppProgrammeBuilderTokens.sectionIconSize,
                    height: AppProgrammeBuilderTokens.sectionIconSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: training
                          ? context.colorScheme.secondaryContainer
                          : context.colorScheme.surfaceContainer,
                    ),
                    child: Text(
                      widget.day.fullDisplayLabel.substring(0, 1),
                      style: AppTextStyles.labelMd.copyWith(
                        color: training
                            ? context.colorScheme.onSecondaryContainer
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  AppWhiteSpace.wMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.day.fullDisplayLabel,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          !training
                              ? AppStrings.programmeRestDay
                              : names.isEmpty
                              ? AppStrings.programmeTrainingDay
                              : AppStrings.trainingWithWorkout(names),
                          style: AppTextStyles.labelSm.copyWith(
                            color: training
                                ? context.colorScheme.secondary
                                : context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppTogglePill(
                    value: training,
                    semanticLabel: widget.day.fullDisplayLabel,
                    onChanged: (enabled) {
                      widget.onToggle(enabled);
                      setState(() => _expanded = enabled);
                    },
                  ),
                  AppWhiteSpace.wXs,
                  SvgPicture.asset(
                    _expanded
                        ? OutlinedSvgAssets.chevronUp
                        : OutlinedSvgAssets.chevronDown,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.outline,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              color: context.colorScheme.surfaceContainerLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.assignWorkoutTemplate,
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppWhiteSpace.hSm,
                  if (widget.slots.isEmpty)
                    _TemplateButton(
                      label: AppStrings.selectWorkoutTemplate,
                      onTap: () => widget.onAssign(null),
                    ),
                  for (final entry in widget.slots) ...[
                    _TemplateButton(
                      label:
                          entry.value.template?.name ??
                          AppStrings.selectWorkoutTemplate,
                      onTap: () => widget.onAssign(entry.key),
                    ),
                    if (entry.value.template?.description?.isNotEmpty ==
                        true) ...[
                      AppWhiteSpace.hSm,
                      Text(
                        entry.value.template!.description!,
                        style: AppTextStyles.bodySm.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (entry.value.template != null &&
                        widget.onRepeatTemplate != null &&
                        !widget.repeatedSlotIndices.contains(entry.key))
                      TextButton(
                        onPressed: () => widget.onRepeatTemplate!(entry.key),
                        child: const Text(AppStrings.programmeRepeatInBlock),
                      ),
                    if (entry.value.template != null)
                      TextButton(
                        onPressed: () => widget.onClearTemplate(entry.key),
                        child: const Text(AppStrings.clearSelection),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TemplateButton extends StatelessWidget {
  const _TemplateButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      foregroundColor: context.colorScheme.onSurface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.controlGap,
        vertical: AppSpacing.controlGap,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      side: BorderSide.none,
    ),
    child: Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
        SvgPicture.asset(
          OutlinedSvgAssets.chevronDown,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
      ],
    ),
  );
}

/// A compact overview of the typical week used on the details page.
class ProgrammeBuilderTrainingDays extends StatelessWidget {
  const ProgrammeBuilderTrainingDays({
    super.key,
    required this.selectedDays,
    required this.onToggle,
  });
  final Set<TrainingDay> selectedDays;
  final ValueChanged<TrainingDay> onToggle;
  @override
  Widget build(BuildContext context) => ProgrammeBuilderSection(
    title: AppStrings.weeklySchedule,
    asset: OutlinedSvgAssets.calendarDays,
    child: ProgrammeBuilderPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.typicalTrainingWeek,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          AppWhiteSpace.hLg,
          Wrap(
            spacing: AppProgrammeBuilderTokens.dayGap,
            runSpacing: AppSpacing.sm,
            children: TrainingDay.values.map((day) {
              final selected = selectedDays.contains(day);
              return SizedBox(
                width: AppSizing.iconXxl,
                child: Column(
                  children: [
                    Text(
                      day.displayLabel,
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.colorScheme.outline,
                      ),
                    ),
                    AppWhiteSpace.hSm,
                    Semantics(
                      button: true,
                      selected: selected,
                      label: day.fullDisplayLabel,
                      child: Material(
                        color: selected
                            ? context.colorScheme.secondaryContainer
                            : context.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: InkWell(
                          onTap: () => onToggle(day),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: SizedBox(
                            width: AppSizing.iconXxl,
                            height: AppSizing.iconXxl,
                            child: Center(
                              child: SvgPicture.asset(
                                selected
                                    ? OutlinedSvgAssets.materialFitnessCenter
                                    : OutlinedSvgAssets.materialBedtime,
                                width: AppSizing.iconMd,
                                height: AppSizing.iconMd,
                                colorFilter: ColorFilter.mode(
                                  selected
                                      ? context.colorScheme.onSecondaryContainer
                                      : context.colorScheme.onSurfaceVariant,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.typicalWeekChangesHint,
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
