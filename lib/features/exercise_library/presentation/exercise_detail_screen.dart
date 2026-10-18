import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/data/bodymap_asset_contract.dart';
import 'package:aedify/features/bodymap/domain/bodymap_view_side.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_step_audio_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_step_audio_button.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_section.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_empty_state.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/components/app_section_header.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/theme/app_durations.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final int exerciseId;

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      AppProviders.exerciseDetailControllerProvider(widget.exerciseId),
    );

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const _CompactHeader(),
            Expanded(
              child: detailAsync.when(
                loading: () => const _LoadingView(),
                error: (_, _) => _ErrorView(exerciseId: widget.exerciseId),
                data: (detail) => detail == null
                    ? const _NotFoundView()
                    : _DetailContent(
                        detail: detail,
                        tabIndex: _tabIndex,
                        onTabChanged: (index) {
                          setState(() => _tabIndex = index);
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

class _CompactHeader extends StatelessWidget {
  const _CompactHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppExerciseDetailTokens.maxScreenWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              Tooltip(
                message: AppStrings.close,
                child: AppIconButton(
                  asset: OutlinedSvgAssets.xMark,
                  semanticLabel: AppStrings.close,
                  onPressed: () {
                    if (context.canPop()) context.pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.detail, required this.exerciseId});

  final ExerciseDetailViewData detail;
  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: AppStrings.toggleFavorite,
      child: AppIconButton(
        asset: detail.isFavorite ? SolidSvgAssets.star : OutlinedSvgAssets.star,
        semanticLabel: AppStrings.toggleFavorite,
        color: _ExerciseDetailColors.accent(context),
        onPressed: () async {
          try {
            final repository = ref.read(
              AppProviders.exerciseRepositoryProvider,
            );
            await repository.setFavorite(
              exerciseId: detail.id,
              isFavorite: !detail.isFavorite,
            );
            ref.invalidate(
              AppProviders.exerciseDetailControllerProvider(exerciseId),
            );
          } catch (_) {}
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.detail,
    required this.tabIndex,
    required this.onTabChanged,
  });

  final ExerciseDetailViewData detail;
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomScrollView(
            key: const Key('exercise_detail_scroll_view'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppExerciseDetailTokens.contentBottomClearance,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppExerciseDetailTokens.maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ExerciseTitle(detail: detail),
                          AppWhiteSpace.hMd,
                          _SegmentedTab(
                            tabIndex: tabIndex,
                            onTabChanged: onTabChanged,
                          ),
                          AppWhiteSpace.hLg,
                          AnimatedSwitcher(
                            duration: MediaQuery.accessibleNavigationOf(context)
                                ? Duration.zero
                                : AppDurations.segmentedControl,
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: tabIndex == 0
                                ? _GuidanceTab(
                                    key: const ValueKey<String>('guidance_tab'),
                                    detail: detail,
                                  )
                                : const _PerformanceTab(
                                    key: ValueKey<String>('performance_tab'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppExerciseDetailTokens.bottomActionInset,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppExerciseDetailTokens.bottomActionMaxWidth,
              ),
              child: _BottomSubstituteAction(detail: detail),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseTitle extends StatelessWidget {
  const _ExerciseTitle({required this.detail});

  final ExerciseDetailViewData detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            detail.name,
            key: const Key('exercise_detail_title'),
            style: AppTextStyles.headlineLgMobile.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
        AppWhiteSpace.wSm,
        _FavoriteButton(detail: detail, exerciseId: detail.id),
      ],
    );
  }
}

class _GuidanceTab extends StatelessWidget {
  const _GuidanceTab({super.key, required this.detail});

  final ExerciseDetailViewData detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseVideoSection(
          key: const Key('exercise_detail_video_section'),
          videos: detail.videos,
          onRetry: () {},
          failureStates: const {},
        ),
        AppWhiteSpace.hMd,
        _MetadataSection(
          key: const Key('exercise_detail_metadata_section'),
          detail: detail,
        ),
        AppWhiteSpace.hMd,
        _MusclesWorkedCard(
          key: const Key('exercise_detail_bodymap_section'),
          detail: detail,
        ),
        AppWhiteSpace.hMd,
        _StepsSection(
          key: const Key('exercise_detail_instructions_section'),
          steps: detail.steps,
          detail: detail,
        ),
        AppWhiteSpace.hMd,
        const _NotesSection(key: Key('exercise_detail_notes_section')),
      ],
    );
  }
}

class _ExerciseDetailCard extends StatelessWidget {
  const _ExerciseDetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: MediaQuery.highContrastOf(context)
            ? Border.all(color: context.colorScheme.outlineVariant)
            : null,
      ),
      child: child,
    );
  }
}

class _MusclesWorkedCard extends StatelessWidget {
  const _MusclesWorkedCard({super.key, required this.detail});

  final ExerciseDetailViewData detail;

  @override
  Widget build(BuildContext context) {
    final primaryLabels = detail.primaryMuscles
        .map(_ExerciseDetailLabelFormatter.formatLabel)
        .toSet()
        .toList();
    final focusLabels = detail.muscleGroups
        .map((group) => group.label)
        .where(
          (label) => !primaryLabels.any(
            (primary) => primary.toLowerCase() == label.toLowerCase(),
          ),
        )
        .toList();
    final effectivePrimary = primaryLabels.isEmpty
        ? detail.muscleGroups.map((group) => group.label).toList()
        : primaryLabels;

    return _ExerciseDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.musclesWorked,
            style: AppTextStyles.headlineMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          if (effectivePrimary.isNotEmpty || focusLabels.isNotEmpty) ...[
            AppWhiteSpace.hMd,
            LayoutBuilder(
              builder: (context, constraints) {
                final stacksVertically =
                    constraints.maxWidth <
                        AppExerciseDetailTokens.compactContentBreakpoint ||
                    MediaQuery.textScalerOf(context).scale(1) >=
                        AppExerciseDetailTokens.largeTextBreakpoint;
                final primary = _MuscleGroup(
                  label: AppStrings.primary,
                  muscles: effectivePrimary,
                  emphasized: true,
                );
                final focus = _MuscleGroup(
                  label: AppStrings.muscleFocus,
                  muscles: focusLabels,
                );

                if (focusLabels.isEmpty) return primary;
                if (stacksVertically) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [primary, AppWhiteSpace.hMd, focus],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: primary),
                    AppWhiteSpace.wLg,
                    Expanded(child: focus),
                  ],
                );
              },
            ),
          ],
          AppWhiteSpace.hMd,
          const _BodymapStage(),
        ],
      ),
    );
  }
}

class _MuscleGroup extends StatelessWidget {
  const _MuscleGroup({
    required this.label,
    required this.muscles,
    this.emphasized = false,
  });

  final String label;
  final List<String> muscles;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppWhiteSpace.hSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: muscles
              .map(
                (muscle) => AppBadge(
                  label: muscle.toUpperCase(),
                  backgroundColor: emphasized
                      ? _ExerciseDetailColors.activeFill(context)
                      : context.colorScheme.secondaryContainer,
                  foregroundColor: emphasized
                      ? _ExerciseDetailColors.activeForeground(context)
                      : context.colorScheme.onSecondaryContainer,
                  borderRadius: AppRadius.full,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.controlGap,
                    vertical: AppSpacing.xs,
                  ),
                  textStyle: AppTextStyles.labelSm,
                  fontWeight: FontWeight.w600,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _BodymapStage extends StatelessWidget {
  const _BodymapStage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppExerciseDetailTokens.bodymapStageHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: const Row(
        children: [
          Expanded(child: _BodymapFigure(side: BodymapViewSide.front)),
          AppWhiteSpace.wSm,
          Expanded(child: _BodymapFigure(side: BodymapViewSide.back)),
        ],
      ),
    );
  }
}

class _BodymapFigure extends StatelessWidget {
  const _BodymapFigure({required this.side});

  final BodymapViewSide side;

  @override
  Widget build(BuildContext context) {
    final isFront = side == BodymapViewSide.front;

    return Semantics(
      key: ValueKey<String>('exercise_detail_bodymap_${side.name}'),
      image: true,
      label: isFront ? AppStrings.bodymapFront : AppStrings.bodymapBack,
      child: SvgPicture.asset(
        BodymapAssetContract.assetPathForSide(side),
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          context.colorScheme.onSurfaceVariant.withValues(
            alpha: AppExerciseDetailTokens.mutedBodymapOpacity,
          ),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _StepsSection extends ConsumerWidget {
  const _StepsSection({super.key, required this.steps, required this.detail});

  final List<String> steps;
  final ExerciseDetailViewData detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioStates = ref.watch(
      AppProviders.exerciseStepAudioControllerProvider,
    );

    return _ExerciseDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.instructions,
            style: AppTextStyles.headlineMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          AppWhiteSpace.hMd,
          if (steps.isEmpty)
            Text(
              AppStrings.customExerciseNoSteps,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...steps.asMap().entries.expand((entry) {
              final stepState =
                  audioStates['${detail.id}:${entry.key}'] ??
                  const ExerciseStepAudioState.idle();
              final isActive = stepState.isBusy;

              return <Widget>[
                AnimatedContainer(
                  key: ValueKey(
                    'exercise_step_${entry.key}_${isActive ? 'active' : 'idle'}',
                  ),
                  duration: MediaQuery.accessibleNavigationOf(context)
                      ? Duration.zero
                      : AppDurations.segmentedControl,
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.controlGap,
                    vertical: AppSpacing.controlGap,
                  ),
                  decoration: isActive
                      ? BoxDecoration(
                          color: _ExerciseDetailColors.subtleActiveFill(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        )
                      : null,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExerciseStepAudioButton(
                        exerciseId: detail.id,
                        stepIndex: entry.key,
                        text: entry.value,
                      ),
                      AppWhiteSpace.wMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.exerciseStepLabel(entry.key + 1),
                              style: AppTextStyles.labelSm.copyWith(
                                color: _ExerciseDetailColors.accent(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AppWhiteSpace.hXs,
                            Text(
                              entry.value,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.key != steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.controlGap,
                    ),
                    child: Divider(
                      height: AppSizing.divider,
                      thickness: AppSizing.divider,
                      color: context.colorScheme.outlineVariant.withValues(
                        alpha: MediaQuery.highContrastOf(context)
                            ? 1
                            : AppExerciseDetailTokens.stepDividerOpacity,
                      ),
                    ),
                  ),
              ];
            }),
        ],
      ),
    );
  }
}

class _MetadataSection extends StatefulWidget {
  const _MetadataSection({super.key, required this.detail});

  final ExerciseDetailViewData detail;

  @override
  State<_MetadataSection> createState() => _MetadataSectionState();
}

class _MetadataSectionState extends State<_MetadataSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final rawItems = <String>[
      if (detail.equipment != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.equipment!.dbValue),
      if (detail.difficulty != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.difficulty!.dbValue),
      _ExerciseDetailLabelFormatter.formatLabel(detail.modality.dbValue),
      if (detail.category != null && detail.category!.isNotEmpty)
        _ExerciseDetailLabelFormatter.formatLabel(detail.category!),
      ...detail.muscleGroups.map((group) => group.label),
      if (detail.force != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.force!.dbValue),
      if (detail.mechanic != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.mechanic!.dbValue),
      ...detail.grips.map(_ExerciseDetailLabelFormatter.formatLabel),
    ];
    final seen = <String>{};
    final items = rawItems
        .where((label) => seen.add(label.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: AppStrings.exerciseGuide),
        AppWhiteSpace.hMd,
        Semantics(
          button: true,
          expanded: _expanded,
          child: Material(
            color: context.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.buttonVertical,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.viewDetails,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      _expanded
                          ? OutlinedSvgAssets.chevronUp
                          : OutlinedSvgAssets.chevronDown,
                      width: AppSizing.iconSm,
                      height: AppSizing.iconSm,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: MediaQuery.accessibleNavigationOf(context)
              ? Duration.zero
              : AppDurations.segmentedControl,
          curve: Curves.easeOutCubic,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: items
                        .map((label) => _MetadataBadge(label: label))
                        .toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NotesSection extends StatefulWidget {
  const _NotesSection({super.key});

  @override
  State<_NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<_NotesSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: AppStrings.notes),
        AppWhiteSpace.hMd,
        Container(
          constraints: const BoxConstraints(
            minHeight: AppExerciseDetailTokens.notesMinHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: MediaQuery.highContrastOf(context)
                ? Border.all(color: context.colorScheme.outlineVariant)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                key: const Key('exercise_detail_notes_field'),
                controller: _controller,
                enabled: false,
                hintText: AppStrings.typeYourNotesHere,
                minLines: 3,
                maxLines: 3,
                filled: true,
                fillColor: context.colorScheme.surfaceContainer,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxs,
                  vertical: AppSpacing.xxs,
                ),
                borderOverride: InputBorder.none,
                style: AppTextStyles.bodyMd,
              ),
              AppWhiteSpace.hSm,
              Text(
                AppStrings.exerciseNotesComingSoon,
                style: AppTextStyles.bodySm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetadataBadge extends StatelessWidget {
  const _MetadataBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label,
      backgroundColor: context.colorScheme.surfaceContainerHigh,
      foregroundColor: context.colorScheme.onSurfaceVariant,
      borderRadius: AppRadius.full,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      textStyle: AppTextStyles.labelSm,
      fontWeight: FontWeight.w600,
    );
  }
}

class _SegmentedTab extends StatelessWidget {
  const _SegmentedTab({required this.tabIndex, required this.onTabChanged});

  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PillToggle(
              label: AppStrings.guidance,
              selected: tabIndex == 0,
              onTap: () => onTabChanged(0),
            ),
          ),
          Expanded(
            child: _PillToggle(
              label: AppStrings.performance,
              selected: tabIndex == 1,
              onTap: () => onTabChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillToggle extends StatelessWidget {
  const _PillToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? _ExerciseDetailColors.activeFill(context)
            : context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizing.cardBadge),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMd.copyWith(
                    color: selected
                        ? _ExerciseDetailColors.activeForeground(context)
                        : context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  const _PerformanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _ExerciseDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppEmptyState(
            key: const Key('exercise_detail_history_empty_state'),
            iconAsset: OutlinedSvgAssets.chartBar,
            title: AppStrings.noHistoryYet,
            message: AppStrings.noHistoryHint,
          ),
          AppWhiteSpace.hMd,
          FilledButton.icon(
            onPressed: () {
              context.pushNamed(AppRoutes.chat().name);
            },
            icon: SvgPicture.asset(
              OutlinedSvgAssets.sparkles,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                _ExerciseDetailColors.activeForeground(context),
                BlendMode.srcIn,
              ),
            ),
            label: const Text(AppStrings.askAiCoach),
          ),
        ],
      ),
    );
  }
}

class _BottomSubstituteAction extends ConsumerWidget {
  const _BottomSubstituteAction({required this.detail});

  final ExerciseDetailViewData detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: AppStrings.toggleSubstitution,
      child: OutlinedButton.icon(
        key: const Key('exercise_detail_substitute_action'),
        onPressed: () async {
          try {
            final repository = ref.read(
              AppProviders.exerciseRepositoryProvider,
            );
            await repository.setSubstitutedOut(
              exerciseId: detail.id,
              isSubstitutedOut: !detail.isSubstitutedOut,
            );
            ref.invalidate(
              AppProviders.exerciseDetailControllerProvider(detail.id),
            );
          } catch (_) {}
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: detail.isSubstitutedOut
              ? _ExerciseDetailColors.subtleActiveFill(context)
              : context.colorScheme.surfaceContainerLowest,
          foregroundColor: context.colorScheme.onSurface,
          minimumSize: const Size.fromHeight(
            AppExerciseDetailTokens.bottomActionHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.buttonVertical,
          ),
          side: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(
              alpha: MediaQuery.highContrastOf(context)
                  ? 1
                  : AppExerciseDetailTokens.bottomActionBorderOpacity,
            ),
          ),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        iconAlignment: IconAlignment.start,
        icon: SvgPicture.asset(
          OutlinedSvgAssets.arrowsRightLeft,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(
            _ExerciseDetailColors.accent(context),
            BlendMode.srcIn,
          ),
        ),
        label: const Text(AppStrings.substitute),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            AppWhiteSpace.hMd,
            Text(
              AppStrings.loading,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppEmptyState(
        iconAsset: OutlinedSvgAssets.informationCircle,
        title: AppStrings.exerciseNotFound,
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppEmptyState(
        iconAsset: OutlinedSvgAssets.exclamationCircle,
        title: AppStrings.exerciseDetailLoadFailed,
        actionLabel: AppStrings.tryAgain,
        onAction: () {
          ref.invalidate(
            AppProviders.exerciseDetailControllerProvider(exerciseId),
          );
        },
      ),
    );
  }
}

class _ExerciseDetailColors {
  _ExerciseDetailColors._();

  static Color activeFill(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Theme.brightnessOf(context) == Brightness.dark
        ? colorScheme.primaryContainer
        : colorScheme.secondary;
  }

  static Color activeForeground(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Theme.brightnessOf(context) == Brightness.dark
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSecondary;
  }

  static Color accent(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Theme.brightnessOf(context) == Brightness.dark
        ? colorScheme.primary
        : colorScheme.secondary;
  }

  static Color subtleActiveFill(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Theme.brightnessOf(context) == Brightness.dark
        ? colorScheme.primaryContainer
        : colorScheme.secondaryContainer;
  }
}

class _ExerciseDetailLabelFormatter {
  _ExerciseDetailLabelFormatter._();

  static String formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
