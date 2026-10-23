import 'package:aedify/features/programmes/application/programme_review_summary.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Single-column mobile review of the programme before saving to its library.
class ProgrammeBuilderReview extends StatelessWidget {
  const ProgrammeBuilderReview({
    super.key,
    required this.draft,
    required this.summary,
  });

  final ProgrammeBuilderDraft draft;
  final ProgrammeReviewSummary summary;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('programme_review'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        AppStrings.reviewAndPublish,
        style: AppTextStyles.headlineLg.copyWith(
          color: context.colorScheme.onSurface,
        ),
      ),
      AppWhiteSpace.hSm,
      Text(
        AppStrings.programmeReviewIntro,
        style: AppTextStyles.bodyLg.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      AppWhiteSpace.hXl,
      _ProgrammeSummary(draft: draft, summary: summary),
      AppWhiteSpace.hLg,
      Text(
        AppStrings.programmeArchitecture.toUpperCase(),
        style: AppTextStyles.labelMd.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      AppWhiteSpace.hMd,
      for (var i = 0; i < summary.blocks.length; i++) ...[
        _BlockPreview(preview: summary.blocks[i], number: i + 1),
        AppWhiteSpace.hMd,
      ],
      AppWhiteSpace.hSm,
      _PublicationPreview(summary: summary),
      AppWhiteSpace.hLg,
      _WeeklyWorkload(summary: summary),
    ],
  );
}

class _ProgrammeSummary extends StatelessWidget {
  const _ProgrammeSummary({required this.draft, required this.summary});
  final ProgrammeBuilderDraft draft;
  final ProgrammeReviewSummary summary;

  @override
  Widget build(BuildContext context) => _ReviewCard(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          // constraints: const BoxConstraints(
          //   minHeight: AppProgrammeReviewTokens.heroMinHeight,
          // ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          color: context.colorScheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (summary.goalLabel != null)
                AppBadge(
                  label: summary.goalLabel!.toUpperCase(),
                  backgroundColor: context.colorScheme.onSecondary.withValues(
                    alpha: AppProgrammeReviewTokens.badgeOpacity,
                  ),
                  foregroundColor: context.colorScheme.onSecondary,
                  borderRadius: AppRadius.sm,
                  textStyle: AppTextStyles.labelSm,
                ),
              AppWhiteSpace.hSm,
              Text(
                draft.name,
                key: const ValueKey('programme_review_name'),
                style: AppTextStyles.headlineMd.copyWith(
                  color: context.colorScheme.onSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SummaryMetric(
                      label: AppStrings.duration,
                      value: summary.weekCount.toString(),
                      unit: summary.weekCount == 1
                          ? AppStrings.weekLabelPrefix
                          : AppStrings.weeks,
                    ),
                  ),
                  AppWhiteSpace.wMd,
                  Expanded(
                    child: _SummaryMetric(
                      label: AppStrings.programmeFrequency,
                      value: AppStrings.programmeReviewFrequency(
                        summary.minDaysPerWeek,
                        summary.maxDaysPerWeek,
                      ),
                      unit: AppStrings.daysPerWeek,
                    ),
                  ),
                ],
              ),
              AppWhiteSpace.hLg,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SummaryMetric(
                      label: AppStrings.trainingBlocks,
                      value: summary.blocks.length.toString(),
                      unit: summary.blocks.length == 1
                          ? AppStrings.programmePhase
                          : AppStrings.programmePhases,
                    ),
                  ),
                  AppWhiteSpace.wMd,
                  Expanded(
                    child: _SummaryMetric(
                      label: AppStrings.exercisesLabel,
                      value: summary.uniqueExerciseCount.toString(),
                      unit: AppStrings.programmeUnique,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSm.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      AppWhiteSpace.hXs,
      Text.rich(
        TextSpan(
          text: value,
          children: [
            TextSpan(
              text: ' $unit',
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        style: AppTextStyles.headlineMd.copyWith(
          color: context.colorScheme.onSurface,
        ),
      ),
    ],
  );
}

class _BlockPreview extends StatelessWidget {
  const _BlockPreview({required this.preview, required this.number});
  final ProgrammeReviewBlock preview;
  final int number;

  @override
  Widget build(BuildContext context) => _ReviewCard(
    key: ValueKey('programme_review_block_${preview.block.id}'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppProgrammeBuilderTokens.sectionIconSize,
              height: AppProgrammeBuilderTokens.sectionIconSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.surfaceContainerHigh,
              ),
              child: SvgPicture.asset(
                preview.block.focus == TrainingBlockFocus.accumulation ||
                        preview.block.focus ==
                            TrainingBlockFocus.hypertrophyBiased
                    ? OutlinedSvgAssets.bolt
                    : OutlinedSvgAssets.materialFitnessCenter,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            AppWhiteSpace.wControlGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.programmeReviewPhaseName(
                      number,
                      preview.block.name,
                    ),
                    style: AppTextStyles.bodyLg.copyWith(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppWhiteSpace.hXs,
                  Text(
                    AppStrings.trainingBlockWeekRange(
                      preview.firstWeek,
                      preview.lastWeek,
                    ),
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppWhiteSpace.hMd,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _PreviewTag(label: preview.block.focus.label),
            _PreviewTag(
              label: AppStrings.programmeDurationWeeks(preview.block.weekCount),
            ),
          ],
        ),
        if (preview.block.progressionNotes.isNotEmpty) ...[
          AppWhiteSpace.hMd,
          Text(
            preview.block.progressionNotes,
            style: AppTextStyles.bodySm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (preview.exerciseNames.isNotEmpty) ...[
          AppWhiteSpace.hMd,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final name in preview.exerciseNames)
                _PreviewTag(label: name),
              if (preview.remainingExercises > 0)
                _PreviewTag(
                  label: AppStrings.programmeReviewMoreExercises(
                    preview.remainingExercises,
                  ),
                ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _PreviewTag extends StatelessWidget {
  const _PreviewTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      border: Border.all(
        color: context.colorScheme.outlineVariant.withValues(
          alpha: AppProgrammeReviewTokens.borderOpacity,
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.controlGap,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

class _PublicationPreview extends StatelessWidget {
  const _PublicationPreview({required this.summary});
  final ProgrammeReviewSummary summary;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('programme_publication_preview'),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    decoration: BoxDecoration(
      color: context.colorScheme.inverseSurface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.shieldCheck,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onInverseSurface,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Text(
                AppStrings.programmePublicationPreview.toUpperCase(),
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onInverseSurface,
                ),
              ),
            ),
          ],
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.programmePublicationHint,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onInverseSurface,
          ),
        ),
        AppWhiteSpace.hLg,
        const _PublicationFact(
          label: AppStrings.programmeVisibility,
          value: AppStrings.programmePrivateLocal,
        ),
        _PublicationFact(
          label: AppStrings.programmeDeloadWeeks,
          value: summary.deloadWeekCount.toString(),
        ),
        _PublicationFact(
          label: AppStrings.programmeRpeTargets,
          isLast: true,
          value: summary.averageTargetRpe == null
              ? AppStrings.programmeTargetsNotSet
              : summary.hasRirEstimates
              ? AppStrings.programmeRpeIncludesRirEstimates
              : AppStrings.programmeRpePrescribed,
        ),
      ],
    ),
  );
}

class _PublicationFact extends StatelessWidget {
  const _PublicationFact({
    required this.label,
    required this.value,
    this.isLast = false,
  });
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(
      top: AppSpacing.controlGap,
      bottom: isLast ? 0 : AppSpacing.controlGap,
    ),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : Border(
              bottom: BorderSide(
                color: context.colorScheme.onInverseSurface.withValues(
                  alpha: AppProgrammeReviewTokens.inverseDividerOpacity,
                ),
              ),
            ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onInverseSurface,
            ),
          ),
        ),
        AppWhiteSpace.wMd,
        Flexible(
          fit: FlexFit.tight,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onInverseSurface,
            ),
          ),
        ),
      ],
    ),
  );
}

class _WeeklyWorkload extends StatelessWidget {
  const _WeeklyWorkload({required this.summary});
  final ProgrammeReviewSummary summary;

  @override
  Widget build(BuildContext context) => _ReviewCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.chartBar,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Text(
                AppStrings.programmeWeeklyWorkload.toUpperCase(),
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        AppWhiteSpace.hLg,
        _WorkloadMetric(
          label: summary.hasRirEstimates
              ? AppStrings.programmeAverageEstimatedRpe
              : AppStrings.programmeAverageRpe,
          value:
              summary.averageTargetRpe?.toStringAsFixed(1) ??
              AppStrings.programmeTargetsNotSet,
          fraction: summary.averageTargetRpe == null
              ? 0
              : (summary.averageTargetRpe! / ProgrammeReviewSummary.maxRpe)
                    .clamp(0, 1),
        ),
        AppWhiteSpace.hLg,
        _WorkloadMetric(
          label: AppStrings.programmeAverageWorkingSets,
          value: summary.averageWeeklySets.toStringAsFixed(1),
          fraction: summary.maxWeeklySets == 0
              ? 0
              : summary.averageWeeklySets / summary.maxWeeklySets,
        ),
        AppWhiteSpace.hSm,
        Text(
          AppStrings.programmeReviewBusiestWeek(summary.maxWeeklySets),
          style: AppTextStyles.labelSm.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        if (summary.hasRirEstimates) ...[
          AppWhiteSpace.hSm,
          Text(
            AppStrings.programmeRirEstimateHint,
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    ),
  );
}

class _WorkloadMetric extends StatelessWidget {
  const _WorkloadMetric({
    required this.label,
    required this.value,
    required this.fraction,
  });
  final String label;
  final String value;
  final double fraction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          AppWhiteSpace.wSm,
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      AppWhiteSpace.hSm,
      ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: LinearProgressIndicator(
          value: fraction,
          semanticsLabel: label,
          minHeight: AppProgrammeReviewTokens.workloadTrackHeight,
          color: context.colorScheme.secondary,
          backgroundColor: context.colorScheme.surfaceContainer,
        ),
      ),
    ],
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.md),
      border: Border.all(
        color: context.colorScheme.outlineVariant.withValues(
          alpha: AppProgrammeReviewTokens.borderOpacity,
        ),
      ),
    ),
    child: Padding(padding: padding, child: child),
  );
}
