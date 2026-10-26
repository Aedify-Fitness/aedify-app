import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Mobile editor for sequential training phases and their programme weeks.
class ProgrammeBuilderTrainingBlocks extends StatelessWidget {
  const ProgrammeBuilderTrainingBlocks({
    super.key,
    required this.blocks,
    required this.onAdd,
    required this.onUpdate,
    required this.onResize,
    required this.onRemove,
    required this.onToggleTrainingDay,
  });

  final List<ProgrammeTrainingBlockDraft> blocks;
  final VoidCallback onAdd;
  final void Function(
    String id, {
    String? name,
    TrainingBlockFocus? focus,
    String? progressionNotes,
  })
  onUpdate;
  final void Function(ProgrammeTrainingBlockDraft block, int weeks) onResize;
  final ValueChanged<ProgrammeTrainingBlockDraft> onRemove;
  final void Function(ProgrammeTrainingBlockDraft block, TrainingDay day)
  onToggleTrainingDay;

  @override
  Widget build(BuildContext context) {
    var nextWeek = 1;
    final startWeeks = <int>[];
    for (final block in blocks) {
      startWeeks.add(nextWeek);
      nextWeek += block.weekCount;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Text(
        //   AppStrings.trainingBlocks,
        //   style: AppTextStyles.headlineLgMobile.copyWith(
        //     color: context.colorScheme.onSurface,
        //   ),
        // ),
        // AppWhiteSpace.hSm,
        // Text(
        //   AppStrings.trainingBlocksHint,
        //   style: AppTextStyles.bodyMd.copyWith(
        //     color: context.colorScheme.onSurfaceVariant,
        //   ),
        // ),
        // AppWhiteSpace.hLg,
        Align(
          alignment: Alignment.centerLeft,
          child: AppBadge(
            label: AppStrings.programmeDurationWeeks(
              blocks.fold<int>(0, (sum, block) => sum + block.weekCount),
            ),
            borderRadius: AppRadius.full,
            backgroundColor: context.colorScheme.surfaceContainerHigh,
            foregroundColor: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hLg,
        for (var i = 0; i < blocks.length; i++) ...[
          _TrainingBlockCard(
            key: ValueKey('training_block_${blocks[i].id}'),
            block: blocks[i],
            number: i + 1,
            firstWeek: startWeeks[i],
            onUpdate: onUpdate,
            onResize: onResize,
            onRemove: onRemove,
            onToggleTrainingDay: onToggleTrainingDay,
          ),
          AppWhiteSpace.hMd,
        ],
        OutlinedButton.icon(
          key: const ValueKey('programme_add_training_block'),
          onPressed: onAdd,
          style: OutlinedButton.styleFrom(
            foregroundColor: context.colorScheme.secondary,
            minimumSize: const Size(0, AppSizing.iconXxl),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            shape: const StadiumBorder(),
            textStyle: AppTextStyles.labelMd,
          ),
          icon: SvgPicture.asset(
            OutlinedSvgAssets.plus,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(
              context.colorScheme.secondary,
              BlendMode.srcIn,
            ),
          ),
          label: const Text(AppStrings.addTrainingBlock),
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.trainingBlockManualHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySm.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TrainingBlockCard extends StatelessWidget {
  const _TrainingBlockCard({
    super.key,
    required this.block,
    required this.number,
    required this.firstWeek,
    required this.onUpdate,
    required this.onResize,
    required this.onRemove,
    required this.onToggleTrainingDay,
  });

  final ProgrammeTrainingBlockDraft block;
  final int number;
  final int firstWeek;
  final void Function(
    String id, {
    String? name,
    TrainingBlockFocus? focus,
    String? progressionNotes,
  })
  onUpdate;
  final void Function(ProgrammeTrainingBlockDraft block, int weeks) onResize;
  final ValueChanged<ProgrammeTrainingBlockDraft> onRemove;
  final void Function(ProgrammeTrainingBlockDraft block, TrainingDay day)
  onToggleTrainingDay;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: context.colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.trainingBlockNumber(number),
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.colorScheme.secondary,
                    ),
                  ),
                  AppWhiteSpace.hXs,
                  Text(
                    AppStrings.trainingBlockWeekRange(
                      firstWeek,
                      firstWeek + block.weekCount - 1,
                    ),
                    key: ValueKey('training_block_range_${block.id}'),
                    style: AppTextStyles.bodySm.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: ValueKey('training_block_remove_${block.id}'),
              tooltip: AppStrings.removeTrainingBlock,
              onPressed: () => onRemove(block),
              style: IconButton.styleFrom(
                minimumSize: const Size.square(AppSizing.iconXxl),
              ),
              icon: SvgPicture.asset(
                OutlinedSvgAssets.trash,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.error,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        AppWhiteSpace.hMd,
        TextFormField(
          key: ValueKey('training_block_name_${block.id}'),
          initialValue: block.name,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
          decoration: const InputDecoration(
            labelText: AppStrings.trainingBlockName,
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => onUpdate(block.id, name: value),
        ),
        AppWhiteSpace.hMd,
        DropdownButtonFormField<TrainingBlockFocus>(
          key: ValueKey('training_block_focus_${block.id}_${block.focus.name}'),
          initialValue: block.focus,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: AppStrings.trainingBlockFocus,
          ),
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
          items: [
            for (final focus in TrainingBlockFocus.values)
              DropdownMenuItem(value: focus, child: Text(focus.label)),
          ],
          onChanged: (focus) {
            if (focus != null) onUpdate(block.id, focus: focus);
          },
          icon: SvgPicture.asset(
            OutlinedSvgAssets.chevronDown,
            width: AppSizing.iconSm,
            height: AppSizing.iconSm,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.trainingBlockLength,
          style: AppTextStyles.labelMd.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hSm,
        Row(
          children: [
            IconButton(
              key: ValueKey('training_block_decrease_${block.id}'),
              tooltip: AppStrings.decreaseBlockWeeks,
              onPressed: block.weekCount > 1
                  ? () => onResize(block, block.weekCount - 1)
                  : null,
              style: IconButton.styleFrom(
                minimumSize: const Size.square(AppSizing.iconXxl),
              ),
              icon: SvgPicture.asset(
                OutlinedSvgAssets.minusCircle,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(
                  block.weekCount > 1
                      ? context.colorScheme.secondary
                      : context.colorScheme.outline,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Expanded(
              child: Text(
                AppStrings.programmeDurationWeeks(block.weekCount),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              key: ValueKey('training_block_increase_${block.id}'),
              tooltip: AppStrings.increaseBlockWeeks,
              onPressed: () => onResize(block, block.weekCount + 1),
              style: IconButton.styleFrom(
                minimumSize: const Size.square(AppSizing.iconXxl),
              ),
              icon: SvgPicture.asset(
                OutlinedSvgAssets.plus,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.blockTrainingDays,
          style: AppTextStyles.labelMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        AppWhiteSpace.hSm,
        Text(
          AppStrings.blockTrainingDaysHint,
          style: AppTextStyles.bodySm.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hMd,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final day in TrainingDay.values)
              Semantics(
                label: day.fullDisplayLabel,
                child: FilterChip(
                  key: ValueKey('training_block_day_${block.id}_${day.name}'),
                  label: Text(
                    day.displayLabel,
                    style: AppTextStyles.labelMd.copyWith(
                      color: block.trainingDays.contains(day)
                          ? context.colorScheme.onSecondaryContainer
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  selected: block.trainingDays.contains(day),
                  selectedColor: context.colorScheme.secondaryContainer,
                  showCheckmark: false,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  onSelected: (_) => onToggleTrainingDay(block, day),
                ),
              ),
          ],
        ),
        AppWhiteSpace.hMd,
        TextFormField(
          key: ValueKey('training_block_notes_${block.id}'),
          initialValue: block.progressionNotes,
          maxLines: null,
          minLines: 2,
          textCapitalization: TextCapitalization.sentences,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
          decoration: const InputDecoration(
            labelText: AppStrings.trainingBlockProgression,
            hintText: AppStrings.trainingBlockProgressionHint,
          ),
          onChanged: (value) => onUpdate(block.id, progressionNotes: value),
        ),
      ],
    ),
  );
}
