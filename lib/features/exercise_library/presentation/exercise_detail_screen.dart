import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_detail_instructions.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_detail_style.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_section.dart';
import 'package:aedify/features/lift_log/presentation/widgets/exercise_history_section.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
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

/// A focused exercise guide with local preferences and optional spoken steps.
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
  void didUpdateWidget(covariant ExerciseDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseId != widget.exerciseId) _tabIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      AppProviders.exerciseDetailControllerProvider(widget.exerciseId),
    );
    final actions = ref.watch(
      AppProviders.exerciseDetailActionsControllerProvider(widget.exerciseId),
    );
    final controller = ref.read(
      AppProviders.exerciseDetailActionsControllerProvider(
        widget.exerciseId,
      ).notifier,
    );
    final detail = detailAsync.asData?.value;
    final isSaving = actions.isLoading || detailAsync.isLoading;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      bottomNavigationBar: detail == null
          ? null
          : _AvoidAction(
              detail: detail,
              isSaving: isSaving,
              hasError: actions.hasError,
              onPressed: () => controller.setAvoided(!detail.isSubstitutedOut),
            ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppExerciseDetailTokens.maxScreenWidth,
            ),
            child: Column(
              children: [
                _DetailHeader(
                  detail: detail,
                  isSaving: isSaving,
                  onFavorite: detail == null
                      ? null
                      : () => controller.setFavorite(!detail.isFavorite),
                ),
                Expanded(
                  child: detailAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: AppStrings.loading,
                      ),
                    ),
                    error: (_, _) => _DetailMessage(
                      icon: OutlinedSvgAssets.exclamationCircle,
                      title: AppStrings.exerciseDetailLoadFailed,
                      onRetry: () => ref.invalidate(
                        AppProviders.exerciseDetailControllerProvider(
                          widget.exerciseId,
                        ),
                      ),
                    ),
                    data: (detail) => detail == null
                        ? const _DetailMessage(
                            icon: OutlinedSvgAssets.informationCircle,
                            title: AppStrings.exerciseNotFound,
                          )
                        : _DetailContent(
                            key: ValueKey(detail.id),
                            detail: detail,
                            tabIndex: _tabIndex,
                            onTabChanged: (index) =>
                                setState(() => _tabIndex = index),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.detail,
    required this.isSaving,
    required this.onFavorite,
  });

  final ExerciseDetailViewData? detail;
  final bool isSaving;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _DetailIconButton(
            asset: OutlinedSvgAssets.xMark,
            label: AppStrings.close,
            onPressed: () {
              if (context.canPop()) context.pop();
            },
          ),
          AppWhiteSpace.wSm,
          Expanded(
            child: Text(
              AppStrings.exerciseGuide,
              textAlign: TextAlign.center,
              style: ExerciseDetailStyle.label(
                context,
              ).copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
          AppWhiteSpace.wSm,
          if (detail != null)
            MergeSemantics(
              child: Semantics(
                toggled: detail!.isFavorite,
                child: _DetailIconButton(
                  asset: detail!.isFavorite
                      ? SolidSvgAssets.star
                      : OutlinedSvgAssets.star,
                  label: AppStrings.toggleFavorite,
                  color: ExerciseDetailStyle.accent(context),
                  onPressed: isSaving ? null : onFavorite,
                ),
              ),
            )
          else
            const SizedBox(width: AppExerciseDetailTokens.controlSize),
        ],
      ),
    );
  }
}

class _DetailIconButton extends StatelessWidget {
  const _DetailIconButton({
    required this.asset,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final String asset;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(AppExerciseDetailTokens.controlSize),
        backgroundColor: context.colorScheme.surfaceContainerLow,
      ),
      icon: SvgPicture.asset(
        asset,
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
        colorFilter: ColorFilter.mode(
          color ?? context.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    super.key,
    required this.detail,
    required this.tabIndex,
    required this.onTabChanged,
  });

  final ExerciseDetailViewData detail;
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const Key('exercise_detail_scroll_view'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    detail.name,
                    key: const Key('exercise_detail_title'),
                    style: AppTextStyles.headlineLg.copyWith(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppWhiteSpace.hMd,
                _ExerciseSummary(detail: detail),
                AppWhiteSpace.hLg,
                _DetailTabs(tabIndex: tabIndex, onChanged: onTabChanged),
                AppWhiteSpace.hLg,
                AnimatedSwitcher(
                  duration: ExerciseDetailStyle.motionDuration(context),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: tabIndex == 0
                      ? _Guidance(
                          detail: detail,
                          key: const ValueKey('guidance_tab'),
                        )
                      : ExerciseHistorySection(
                          key: const ValueKey('performance_tab'),
                          exerciseId: detail.id,
                          emptyState: const _Performance(),
                        ),
                ),
                AppWhiteSpace.hLg,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseSummary extends StatelessWidget {
  const _ExerciseSummary({required this.detail});

  final ExerciseDetailViewData detail;

  @override
  Widget build(BuildContext context) {
    final labels = [
      if (detail.equipment != null) detail.equipment!.dbValue,
      if (detail.difficulty != null) detail.difficulty!.dbValue,
      detail.modality.dbValue,
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final label in labels)
          AppBadge(
            label: ExerciseDetailStyle.formatLabel(label),
            backgroundColor: context.colorScheme.surfaceContainerLow,
            foregroundColor: context.colorScheme.onSurfaceVariant,
            borderRadius: AppRadius.full,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.controlGap,
              vertical: AppSpacing.xs,
            ),
            textStyle: ExerciseDetailStyle.caption(context),
          ),
      ],
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({required this.tabIndex, required this.onChanged});

  final int tabIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            for (var index = 0; index < 2; index++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: tabIndex == index,
                  child: Material(
                    color: tabIndex == index
                        ? context.theme.brightness == Brightness.dark
                              ? context.colorScheme.surfaceContainerHigh
                              : ExerciseDetailStyle.panel(context)
                        : context.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onChanged(index),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: AppExerciseDetailTokens.controlSize,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.buttonVertical,
                          ),
                          child: Text(
                            index == 0
                                ? AppStrings.guidance
                                : AppStrings.performance,
                            textAlign: TextAlign.center,
                            style: ExerciseDetailStyle.label(context).copyWith(
                              color: tabIndex == index
                                  ? ExerciseDetailStyle.accent(context)
                                  : context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Guidance extends ConsumerWidget {
  const _Guidance({super.key, required this.detail});

  final ExerciseDetailViewData detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoStates = ref.watch(
      AppProviders.exerciseVideoStateControllerProvider,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseVideoSection(
          key: const Key('exercise_detail_video_section'),
          videos: detail.videos,
          failureStates: videoStates,
          onRetry: () => ref
              .read(AppProviders.exerciseVideoStateControllerProvider.notifier)
              .resetAll(),
        ),
        AppWhiteSpace.hXl,
        ExerciseDetailInstructions(
          key: const Key('exercise_detail_instructions_section'),
          detail: detail,
        ),
        AppWhiteSpace.hLg,
        _MetadataDisclosure(
          key: const Key('exercise_detail_metadata_section'),
          detail: detail,
        ),
        AppWhiteSpace.hLg,
        const _NotesSection(key: Key('exercise_detail_notes_section')),
      ],
    );
  }
}

class _MetadataDisclosure extends StatefulWidget {
  const _MetadataDisclosure({super.key, required this.detail});

  final ExerciseDetailViewData detail;

  @override
  State<_MetadataDisclosure> createState() => _MetadataDisclosureState();
}

class _MetadataDisclosureState extends State<_MetadataDisclosure> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final items =
        <String>[
              if (detail.category?.isNotEmpty ?? false) detail.category!,
              ...detail.muscleGroups.map((group) => group.label),
              if (detail.force != null) detail.force!.dbValue,
              if (detail.mechanic != null) detail.mechanic!.dbValue,
              ...detail.grips,
            ]
            .map(ExerciseDetailStyle.formatLabel)
            .where((item) => item.trim().isNotEmpty)
            .toSet();
    final content = !_expanded
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final item in items)
                  AppBadge(
                    label: item,
                    backgroundColor: context.colorScheme.surfaceContainerHigh,
                    foregroundColor: context.colorScheme.onSurfaceVariant,
                    textStyle: ExerciseDetailStyle.caption(context),
                    borderRadius: AppRadius.full,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.controlGap,
                      vertical: AppSpacing.xs,
                    ),
                  ),
              ],
            ),
          );
    final duration = ExerciseDetailStyle.motionDuration(context);
    return Material(
      color: ExerciseDetailStyle.panel(context),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.viewDetails,
                        style: ExerciseDetailStyle.label(context),
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
          if (duration == Duration.zero)
            content
          else
            AnimatedSize(
              duration: duration,
              alignment: Alignment.topCenter,
              curve: Curves.easeOutCubic,
              child: content,
            ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatefulWidget {
  const _NotesSection({super.key});

  @override
  State<_NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<_NotesSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.notes, style: ExerciseDetailStyle.heading(context)),
        AppWhiteSpace.hSm,
        Text(
          AppStrings.exerciseNotesComingSoon,
          style: ExerciseDetailStyle.small(context),
        ),
        AppWhiteSpace.hMd,
        AppTextField(
          key: const Key('exercise_detail_notes_field'),
          controller: _controller,
          enabled: false,
          hintText: AppStrings.typeYourNotesHere,
          minLines: 2,
          maxLines: 2,
          filled: true,
          fillColor: context.colorScheme.surfaceContainerLow,
          borderOverride: InputBorder.none,
          style: ExerciseDetailStyle.body(context),
        ),
      ],
    );
  }
}

class _Performance extends StatelessWidget {
  const _Performance();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('exercise_detail_history_empty_state'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: ExerciseDetailStyle.panel(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.chartBar,
            width: AppSizing.iconXxl,
            height: AppSizing.iconXxl,
            colorFilter: ColorFilter.mode(
              ExerciseDetailStyle.accent(context),
              BlendMode.srcIn,
            ),
          ),
          AppWhiteSpace.hLg,
          Text(
            AppStrings.noHistoryYet,
            textAlign: TextAlign.center,
            style: ExerciseDetailStyle.heading(context),
          ),
          AppWhiteSpace.hSm,
          Text(
            AppStrings.noHistoryHint,
            textAlign: TextAlign.center,
            style: ExerciseDetailStyle.body(
              context,
            ).copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          AppWhiteSpace.hLg,
          FilledButton(
            onPressed: () => context.pushNamed(AppRoutes.chat().name),
            style: FilledButton.styleFrom(
              backgroundColor: ExerciseDetailStyle.actionFill(context),
              foregroundColor: ExerciseDetailStyle.actionForeground(context),
              minimumSize: const Size.fromHeight(
                AppExerciseDetailTokens.controlSize,
              ),
              textStyle: ExerciseDetailStyle.label(
                context,
              ).copyWith(inherit: false),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.buttonVertical,
              ),
            ),
            child: Text(AppStrings.askAiCoach),
          ),
        ],
      ),
    );
  }
}

class _AvoidAction extends StatelessWidget {
  const _AvoidAction({
    required this.detail,
    required this.isSaving,
    required this.hasError,
    required this.onPressed,
  });

  final ExerciseDetailViewData detail;
  final bool isSaving;
  final bool hasError;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.surface,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppExerciseDetailTokens.maxScreenWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasError) ...[
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        AppErrorStrings.exercisePreferenceSaveFailed,
                        textAlign: TextAlign.center,
                        style: ExerciseDetailStyle.small(
                          context,
                        ).copyWith(color: context.colorScheme.error),
                      ),
                    ),
                    AppWhiteSpace.hSm,
                  ],
                  if (detail.isSubstitutedOut) ...[
                    Text(
                      AppStrings.exerciseAvoidedHint,
                      textAlign: TextAlign.center,
                      style: ExerciseDetailStyle.caption(context),
                    ),
                    AppWhiteSpace.hSm,
                  ],
                  MergeSemantics(
                    child: Semantics(
                      toggled: detail.isSubstitutedOut,
                      child: Tooltip(
                        message: AppStrings.toggleSubstitution,
                        child: OutlinedButton(
                          key: const Key('exercise_detail_substitute_action'),
                          onPressed: isSaving ? null : onPressed,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                              AppExerciseDetailTokens.bottomActionHeight,
                            ),
                            foregroundColor: ExerciseDetailStyle.accent(
                              context,
                            ),
                            backgroundColor: ExerciseDetailStyle.panel(context),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.buttonVertical,
                            ),
                            side: BorderSide(
                              color: context.colorScheme.outlineVariant,
                            ),
                            shape: const StadiumBorder(),
                            textStyle: ExerciseDetailStyle.label(
                              context,
                            ).copyWith(inherit: false),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isSaving)
                                SizedBox(
                                  width: AppSizing.iconSm,
                                  height: AppSizing.iconSm,
                                  child: CircularProgressIndicator(
                                    strokeWidth: AppSizing.strokeWidth,
                                    semanticsLabel: AppStrings.loading,
                                  ),
                                )
                              else
                                SvgPicture.asset(
                                  detail.isSubstitutedOut
                                      ? OutlinedSvgAssets.arrowPath
                                      : OutlinedSvgAssets.noSymbol,
                                  width: AppSizing.iconSm,
                                  height: AppSizing.iconSm,
                                  colorFilter: ColorFilter.mode(
                                    ExerciseDetailStyle.accent(context),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              AppWhiteSpace.wSm,
                              Flexible(
                                child: Text(
                                  detail.isSubstitutedOut
                                      ? AppStrings.allowExercise
                                      : AppStrings.avoidExercise,
                                  textAlign: TextAlign.center,
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
          ),
        ),
      ),
    );
  }
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({required this.icon, required this.title, this.onRetry});

  final String icon;
  final String title;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            icon,
            width: AppSizing.iconXxl,
            height: AppSizing.iconXxl,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          AppWhiteSpace.hMd,
          Text(
            title,
            textAlign: TextAlign.center,
            style: ExerciseDetailStyle.heading(context),
          ),
          if (onRetry != null) ...[
            AppWhiteSpace.hMd,
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: ExerciseDetailStyle.actionFill(context),
                foregroundColor: ExerciseDetailStyle.actionForeground(context),
                minimumSize: const Size.fromHeight(
                  AppExerciseDetailTokens.controlSize,
                ),
                textStyle: ExerciseDetailStyle.label(
                  context,
                ).copyWith(inherit: false),
              ),
              child: const Text(AppStrings.tryAgain),
            ),
          ],
        ],
      ),
    );
  }
}
