import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_step_audio_button.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_section.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
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
      appBar: AppBar(
        title: Text(detailAsync.asData?.value?.name ?? ''),
        actions: [
          if (detailAsync.asData?.value != null)
            _FavoriteButton(
              detail: detailAsync.asData!.value!,
              exerciseId: widget.exerciseId,
            ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(exerciseId: widget.exerciseId),
        data: (detail) {
          if (detail == null) {
            return Center(child: Text(AppStrings.exerciseNotFound));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _VideoHero(videos: detail.videos, name: detail.name),
                const SizedBox(height: AppSpacing.md),
                _SegmentedTab(
                  tabIndex: _tabIndex,
                  onTabChanged: (i) => setState(() => _tabIndex = i),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_tabIndex == 0) _GuidanceTab(detail: detail),
                if (_tabIndex == 1) const _PerformanceTab(),
                const SizedBox(height: AppSpacing.lg),
                _ActionButtons(exerciseId: detail.id),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.detail, required this.exerciseId});

  final dynamic detail;
  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = detail.isFavorite as bool;
    return IconButton(
      icon: SvgPicture.asset(
        isFavorite ? SolidSvgAssets.heart : OutlinedSvgAssets.heart,
        width: AppSpacing.lg,
        height: AppSpacing.lg,
        colorFilter: isFavorite
            ? ColorFilter.mode(context.colorScheme.error, BlendMode.srcIn)
            : null,
      ),
      onPressed: () async {
        try {
          final repository = ref.read(AppProviders.exerciseRepositoryProvider);
          await repository.setFavorite(
            exerciseId: detail.id,
            isFavorite: !isFavorite,
          );
          ref.invalidate(
            AppProviders.exerciseDetailControllerProvider(exerciseId),
          );
        } catch (_) {}
      },
      tooltip: AppStrings.toggleFavorite,
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSpacing.xxl,
              height: AppSpacing.xxl,
              colorFilter: ColorFilter.mode(
                context.colorScheme.error,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.exerciseDetailLoadFailed,
              style: context.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () {
                ref.invalidate(
                  AppProviders.exerciseDetailControllerProvider(exerciseId),
                );
              },
              child: const Text(AppStrings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoHero extends StatelessWidget {
  const _VideoHero({required this.videos, required this.name});

  final List videos;
  final String name;

  @override
  Widget build(BuildContext context) {
    final hasVideo = videos.isNotEmpty;
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasVideo)
            Positioned.fill(
              child: Center(
                child: SvgPicture.asset(
                  OutlinedSvgAssets.playCircle,
                  width: AppSizing.iconXxl,
                  height: AppSizing.iconXxl,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.onSurface.withAlpha(25),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            )
          else
            Center(
              child: SvgPicture.asset(
                OutlinedSvgAssets.playCircle,
                width: AppSizing.iconXxl,
                height: AppSizing.iconXxl,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSurfaceVariant.withAlpha(77),
                  BlendMode.srcIn,
                ),
              ),
            ),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colorScheme.surface.withAlpha(230),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.shadow.withAlpha(30),
                    blurRadius: AppRadius.md,
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  OutlinedSvgAssets.play,
                  width: AppSizing.iconLg,
                  height: AppSizing.iconLg,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: AppStrings.guidance,
              selected: tabIndex == 0,
              onTap: () => onTabChanged(0),
            ),
          ),
          Expanded(
            child: _TabButton(
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

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: selected
            ? BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.shadow.withAlpha(15),
                    blurRadius: AppRadius.sm,
                  ),
                ],
              )
            : null,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.textTheme.labelMedium?.copyWith(
            color: selected
                ? context.colorScheme.onSurface
                : context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _GuidanceTab extends StatelessWidget {
  const _GuidanceTab({required this.detail});

  final dynamic detail;

  @override
  Widget build(BuildContext context) {
    final primaryMuscles = detail.primaryMuscles as List<String>;
    final muscleGroups = detail.muscleGroups;
    final steps = detail.steps as List<String>;

    return Column(
      children: [
        _MetadataCard(detail: detail),
        const SizedBox(height: AppSpacing.md),
        _MuscleFocusCard(
          primaryMuscles: primaryMuscles,
          muscleGroups: muscleGroups,
        ),
        const SizedBox(height: AppSpacing.md),
        _StepsCard(steps: steps, detail: detail),
        const SizedBox(height: AppSpacing.md),
        ExerciseVideoSection(
          videos: detail.videos,
          onRetry: () {},
          failureStates: const {},
        ),
      ],
    );
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.detail});

  final dynamic detail;

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      if (detail.difficulty != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.difficulty.dbValue),
      if (detail.modality != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.modality.dbValue),
      if (detail.equipment != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.equipment.dbValue),
      if (detail.force != null)
        _ExerciseDetailLabelFormatter.formatLabel(detail.force.dbValue),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: items
              .map(
                (item) => Chip(
                  label: Text(item),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _MuscleFocusCard extends StatelessWidget {
  const _MuscleFocusCard({
    required this.primaryMuscles,
    required this.muscleGroups,
  });

  final List<String> primaryMuscles;
  final dynamic muscleGroups;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.user,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppStrings.muscleFocus,
                  style: context.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (muscleGroups != null && muscleGroups.isNotEmpty) ...[
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: (muscleGroups as Iterable).map((g) {
                  return Chip(
                    label: Text(g.label.toString()),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: primaryMuscles
                  .map(
                    (m) => Chip(
                      label: Text(m),
                      backgroundColor: context.colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color: context.colorScheme.onSecondaryContainer,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.steps, required this.detail});

  final List<String> steps;
  final dynamic detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.listBullet,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppStrings.executionSteps,
                  style: context.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...steps.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: context.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: context.colorScheme.onSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                    ExerciseStepAudioButton(
                      exerciseId: detail.id,
                      stepIndex: entry.key,
                      text: entry.value,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  const _PerformanceTab();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                OutlinedSvgAssets.chartBar,
                width: AppSizing.iconXxl,
                height: AppSizing.iconXxl,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.surfaceContainerHighest,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.noHistoryYet,
                style: context.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  AppStrings.noHistoryHint,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
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
            ),
            label: const Tooltip(
              message: AppStrings.toggleSubstitution,
              child: Text(AppStrings.substitute),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () {
              context.pushNamed(AppRoutes.chat().name);
            },
            icon: SvgPicture.asset(
              OutlinedSvgAssets.sparkles,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
            ),
            label: const Text(AppStrings.askAiCoach),
          ),
        ),
      ],
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
