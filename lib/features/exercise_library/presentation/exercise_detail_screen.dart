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
    final detail = detailAsync.asData?.value;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _CompactHeader(detail: detail, exerciseId: widget.exerciseId),
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
  const _CompactHeader({required this.detail, required this.exerciseId});

  final ExerciseDetailViewData? detail;
  final int exerciseId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            message: AppStrings.backLabel,
            child: AppIconButton(
              asset: OutlinedSvgAssets.arrowLeft,
              semanticLabel: AppStrings.backLabel,
              backgroundColor: context.colorScheme.surfaceContainerLow,
              onPressed: () {
                if (context.canPop()) context.pop();
              },
            ),
          ),
          if (detail != null)
            _FavoriteButton(detail: detail!, exerciseId: exerciseId)
          else
            AppWhiteSpace.custom(
              width: AppSizing.iconXxl,
              height: AppSizing.iconXxl,
            ),
        ],
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
        asset: detail.isFavorite
            ? SolidSvgAssets.heart
            : OutlinedSvgAssets.heart,
        semanticLabel: AppStrings.toggleFavorite,
        color: detail.isFavorite
            ? context.colorScheme.error
            : context.colorScheme.onSurfaceVariant,
        backgroundColor: detail.isFavorite
            ? context.colorScheme.errorContainer
            : context.colorScheme.surfaceContainerLow,
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ExerciseHero(detail: detail),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: _SegmentedTab(
              tabIndex: tabIndex,
              onTabChanged: onTabChanged,
            ),
          ),
          if (tabIndex == 0) _GuidanceTab(detail: detail),
          if (tabIndex == 1) const _PerformanceTab(),
          _TonalSection(elevated: tabIndex == 1, child: const _ActionButtons()),
        ],
      ),
    );
  }
}

class _ExerciseHero extends StatelessWidget {
  const _ExerciseHero({required this.detail});

  final ExerciseDetailViewData detail;

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[
      if (detail.difficulty != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.difficulty!.dbValue),
      _ExerciseDetailLabelFormatter.formatLabel(detail.modality.dbValue),
      if (detail.equipment != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.equipment!.dbValue),
    ];

    return Container(
      color: context.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.category != null && detail.category!.isNotEmpty) ...[
            Text(
              _ExerciseDetailLabelFormatter.formatLabel(detail.category!),
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppWhiteSpace.hSm,
          ],
          Text(
            detail.name,
            style: AppTextStyles.headlineLgMobile.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          if (detail.primaryMuscles.isNotEmpty) ...[
            AppWhiteSpace.hSm,
            Text(
              detail.primaryMuscles.join(', '),
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (metadata.isNotEmpty) ...[
            AppWhiteSpace.hLg,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: metadata
                  .map((label) => _MetadataBadge(label: label))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuidanceTab extends StatelessWidget {
  const _GuidanceTab({required this.detail});

  final ExerciseDetailViewData detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TonalSection(
          key: const Key('exercise_detail_video_section'),
          elevated: true,
          child: ExerciseVideoSection(
            videos: detail.videos,
            onRetry: () {},
            failureStates: const {},
          ),
        ),
        _TonalSection(
          key: const Key('exercise_detail_instructions_section'),
          child: _StepsSection(steps: detail.steps, detail: detail),
        ),
        _TonalSection(
          key: const Key('exercise_detail_bodymap_section'),
          elevated: true,
          child: _BodymapSection(detail: detail),
        ),
        _TonalSection(
          key: const Key('exercise_detail_metadata_section'),
          child: _MetadataSection(detail: detail),
        ),
        const _TonalSection(
          key: Key('exercise_detail_notes_section'),
          elevated: true,
          child: _NotesSection(),
        ),
      ],
    );
  }
}

class _TonalSection extends StatelessWidget {
  const _TonalSection({super.key, required this.child, this.elevated = false});

  final Widget child;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: elevated
          ? context.colorScheme.surfaceContainerLow
          : context.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl,
      ),
      child: child,
    );
  }
}

class _StepsSection extends ConsumerWidget {
  const _StepsSection({required this.steps, required this.detail});

  final List<String> steps;
  final ExerciseDetailViewData detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioStates = ref.watch(
      AppProviders.exerciseStepAudioControllerProvider,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: AppStrings.executionSteps),
        AppWhiteSpace.hLg,
        ...steps.asMap().entries.map((entry) {
          final stepState =
              audioStates['${detail.id}:${entry.key}'] ??
              const ExerciseStepAudioState.idle();
          final isActive = stepState.isBusy;

          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key == steps.length - 1
                  ? AppSpacing.xxs
                  : AppSpacing.md,
            ),
            child: AnimatedContainer(
              key: ValueKey(
                'exercise_step_${entry.key}_${isActive ? 'active' : 'idle'}',
              ),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? context.colorScheme.secondaryContainer
                    : context.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppSpacing.lg,
                    height: AppSpacing.lg,
                    decoration: BoxDecoration(
                      color: isActive
                          ? context.colorScheme.secondary
                          : context.colorScheme.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.key + 1}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: isActive
                            ? context.colorScheme.onSecondary
                            : context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AppWhiteSpace.wMd,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxs),
                      child: Text(
                        entry.value,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: isActive
                              ? context.colorScheme.onSecondaryContainer
                              : context.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  AppWhiteSpace.wSm,
                  ExerciseStepAudioButton(
                    exerciseId: detail.id,
                    stepIndex: entry.key,
                    text: entry.value,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _BodymapSection extends StatefulWidget {
  const _BodymapSection({required this.detail});

  final ExerciseDetailViewData detail;

  @override
  State<_BodymapSection> createState() => _BodymapSectionState();
}

class _BodymapSectionState extends State<_BodymapSection> {
  BodymapViewSide _side = BodymapViewSide.front;

  @override
  Widget build(BuildContext context) {
    final muscleLabels = widget.detail.muscleGroups
        .map((group) => group.label)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: AppStrings.muscleFocus),
        AppWhiteSpace.hLg,
        _BodymapSideToggle(
          side: _side,
          onChanged: (side) => setState(() => _side = side),
        ),
        AppWhiteSpace.hLg,
        Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: AppSizing.bodymapSvgWidth,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: AspectRatio(
              aspectRatio:
                  AppSizing.bodymapSvgWidth / AppSizing.bodymapSvgHeight,
              child: SvgPicture.asset(
                BodymapAssetContract.assetPathForSide(_side),
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        if (muscleLabels.isNotEmpty ||
            widget.detail.primaryMuscles.isNotEmpty) ...[
          AppWhiteSpace.hLg,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ...muscleLabels.map((label) => _MetadataBadge(label: label)),
              ...widget.detail.primaryMuscles.map(
                (label) => _MetadataBadge(label: label, emphasized: true),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BodymapSideToggle extends StatelessWidget {
  const _BodymapSideToggle({required this.side, required this.onChanged});

  final BodymapViewSide side;
  final ValueChanged<BodymapViewSide> onChanged;

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
              label: AppStrings.bodymapFront,
              selected: side == BodymapViewSide.front,
              onTap: () => onChanged(BodymapViewSide.front),
            ),
          ),
          Expanded(
            child: _PillToggle(
              label: AppStrings.bodymapBack,
              selected: side == BodymapViewSide.back,
              onTap: () => onChanged(BodymapViewSide.back),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataSection extends StatefulWidget {
  const _MetadataSection({required this.detail});

  final ExerciseDetailViewData detail;

  @override
  State<_MetadataSection> createState() => _MetadataSectionState();
}

class _MetadataSectionState extends State<_MetadataSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final items = <String>[
      if (detail.category != null && detail.category!.isNotEmpty)
        _ExerciseDetailLabelFormatter.formatLabel(detail.category!),
      if (detail.difficulty != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.difficulty!.dbValue),
      _ExerciseDetailLabelFormatter.formatLabel(detail.modality.dbValue),
      if (detail.equipment != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.equipment!.dbValue),
      if (detail.force != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.force!.dbValue),
      if (detail.mechanic != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.mechanic!.dbValue),
      ...detail.grips.map(_ExerciseDetailLabelFormatter.formatLabel),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: AppStrings.exerciseGuide),
        AppWhiteSpace.hMd,
        Material(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
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
                      style: AppTextStyles.labelMd.copyWith(
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
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
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
  const _NotesSection();

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
        AppTextField(
          controller: _controller,
          enabled: false,
          hintText: AppStrings.comingSoon,
          minLines: 3,
          maxLines: 3,
          filled: true,
          fillColor: context.colorScheme.surfaceContainerLowest,
          borderOverride: InputBorder.none,
          style: AppTextStyles.bodyMd,
        ),
      ],
    );
  }
}

class _MetadataBadge extends StatelessWidget {
  const _MetadataBadge({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label,
      backgroundColor: emphasized
          ? context.colorScheme.secondaryContainer
          : context.colorScheme.surfaceContainerHigh,
      foregroundColor: emphasized
          ? context.colorScheme.onSecondaryContainer
          : context.colorScheme.onSurfaceVariant,
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
        color: context.colorScheme.surfaceContainerLow,
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
            ? context.colorScheme.secondary
            : context.colorScheme.surfaceContainerLow,
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
                        ? context.colorScheme.onSecondary
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
  const _PerformanceTab();

  @override
  Widget build(BuildContext context) {
    return _TonalSection(
      elevated: true,
      child: AppEmptyState(
        key: const Key('exercise_detail_history_empty_state'),
        iconAsset: OutlinedSvgAssets.chartBar,
        title: AppStrings.noHistoryYet,
        message: AppStrings.noHistoryHint,
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Tooltip(
          message: AppStrings.toggleSubstitution,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.comingSoon)),
              );
            },
            iconAlignment: IconAlignment.start,
            icon: SvgPicture.asset(
              OutlinedSvgAssets.arrowsRightLeft,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            label: const Text(AppStrings.substitute),
          ),
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
              context.colorScheme.onSecondary,
              BlendMode.srcIn,
            ),
          ),
          label: const Text(AppStrings.askAiCoach),
        ),
      ],
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
