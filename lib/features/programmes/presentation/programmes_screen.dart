import 'dart:math' as math;

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/features/programmes/presentation/widgets/archive_item_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/delete_item_dialog.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/widgets/dashed_border_painter.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ProgrammesScreen extends ConsumerStatefulWidget {
  const ProgrammesScreen({super.key});

  @override
  ConsumerState<ProgrammesScreen> createState() => _ProgrammesScreenState();
}

class _ProgrammesScreenState extends ConsumerState<ProgrammesScreen> {
  String _activeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(
      AppProviders.programmeLibraryControllerProvider,
    );
    final cs = context.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _ErrorView(
            message: AppStrings.programmesLoadFailed,
            onRetry: () => ref
                .read(AppProviders.programmeLibraryControllerProvider.notifier)
                .reload(),
          ),
          data: (state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorCode != null) {
              return _ErrorView(
                message: state.errorMessage ?? AppStrings.programmesLoadFailed,
                onRetry: () => ref
                    .read(
                      AppProviders.programmeLibraryControllerProvider.notifier,
                    )
                    .reload(),
              );
            }

            final items = _filteredItems(state.items);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      top: AppSpacing.xl,
                      right: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.programmes,
                          style: context.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.01,
                          ),
                        ),
                        _NewButton(
                          onTap: () => context.pushNamed(
                            AppRoutes.programmeBuilderCreate().name,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: _FilterPills(
                      activeFilter: _activeFilter,
                      onChanged: (filter) {
                        setState(() => _activeFilter = filter);
                      },
                    ),
                  ),
                ),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyView(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      top: AppSpacing.lg,
                      right: AppSpacing.md,
                      bottom: AppSpacing.xxl,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: items.length + 1,
                        (context, index) {
                          if (index == items.length) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.sm,
                              ),
                              child: _ImportCard(),
                            );
                          }
                          final item = items[index];
                          return _ProgramCard(
                            item: item,
                            onTap: () => context.pushNamed(
                              AppRoutes.programmeCalendar().name,
                              pathParameters: {'id': item.id},
                            ),
                            onEdit: () => context.pushNamed(
                              AppRoutes.programmeBuilderEdit().name,
                              pathParameters: {'id': item.id},
                            ),
                            onToggleActive: () => _toggleActive(item),
                            onArchive: () => _showArchiveDialog(item),
                            onDelete: () => _showDeleteDialog(item),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<ProgrammeListItem> _filteredItems(List<ProgrammeListItem> items) {
    if (_activeFilter == 'all') return items;

    return items.where((item) {
      if (_activeFilter == 'ai') return item.source == 'ai_generated';
      if (_activeFilter == 'custom') {
        return (item.source == 'manual' || item.source == null) &&
            !item.imported;
      }
      if (_activeFilter == 'imported') return item.imported;
      return true;
    }).toList();
  }

  Future<void> _toggleActive(ProgrammeListItem item) async {
    final controller = ref.read(
      AppProviders.programmeLibraryControllerProvider.notifier,
    );

    if (item.active) {
      await controller.deactivateProgramme(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.programmeDeactivated)),
      );
      return;
    }

    final items =
        ref
            .read(AppProviders.programmeLibraryControllerProvider)
            .asData
            ?.value
            .items ??
        const <ProgrammeListItem>[];
    ProgrammeListItem? existingActive;
    for (final entry in items) {
      if (entry.active) {
        existingActive = entry;
        break;
      }
    }
    if (existingActive != null && existingActive.id != item.id && mounted) {
      final activeName = existingActive.name;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(AppStrings.activateProgramme),
          content: Text(
            '${AppStrings.activeProgrammeWarning} $activeName will be deactivated.',
          ),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(false),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => ctx.pop(true),
              child: const Text(AppStrings.activateProgramme),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await controller.activateProgramme(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.programmeActivated)),
    );
  }

  void _showArchiveDialog(ProgrammeListItem item) {
    showDialog<void>(
      context: context,
      builder: (_) => ArchiveItemDialog(
        title: AppStrings.archiveProgrammeConfirm,
        message: '',
        onConfirm: () async {
          await ref
              .read(AppProviders.programmeLibraryControllerProvider.notifier)
              .archiveProgramme(item.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.programmeArchived)),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(ProgrammeListItem item) {
    showDialog<void>(
      context: context,
      builder: (_) => DeleteItemDialog(
        title: AppStrings.deleteProgrammeConfirm,
        message: '',
        confirmLabel: AppStrings.deleteProgramme,
        onConfirm: () async {
          await ref
              .read(AppProviders.programmeLibraryControllerProvider.notifier)
              .deleteProgramme(item.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.programmeDeleted)),
          );
        },
      ),
    );
  }
}

class _NewButton extends StatelessWidget {
  const _NewButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                OutlinedSvgAssets.plus,
                width: AppSizing.iconS,
                height: AppSizing.iconS,
                colorFilter: ColorFilter.mode(cs.secondary, BlendMode.srcIn),
              ),
              AppWhiteSpace.wXs,
              Text(
                AppStrings.newProgramme,
                style: context.textTheme.labelMedium?.copyWith(
                  color: cs.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  const _FilterPills({required this.activeFilter, required this.onChanged});

  final String activeFilter;
  final void Function(String) onChanged;

  static const _filters = [
    ('all', AppStrings.allFilter),
    ('ai', AppStrings.aiGenerated),
    ('custom', AppStrings.custom),
    ('imported', AppStrings.imported),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: _filters.map((filter) {
          final selected = activeFilter == filter.$1;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onChanged(filter.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: selected ? cs.secondary : cs.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: selected
                      ? null
                      : Border.all(color: cs.outlineVariant),
                ),
                child: Text(
                  filter.$2,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: selected ? cs.onSecondary : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActive,
    required this.onArchive,
    required this.onDelete,
  });

  final ProgrammeListItem item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  bool get _isCompleted => item.status == ProgramStatus.completed;

  String? get _sourceLabel {
    if (item.source == 'ai_generated') return AppStrings.aiGenerated;
    if (item.imported) return AppStrings.imported;
    return AppStrings.custom;
  }

  String? get _statusLabel {
    if (item.active) return AppStrings.programmeActive;
    if (_isCompleted) return AppStrings.completed;
    return null;
  }

  String get _goalDisplay {
    if (item.goalTags.isEmpty) return '';
    final tag = item.goalTags.first;
    return switch (tag) {
      GoalTag.buildMuscle => AppStrings.onboardingGoalBuildMuscle,
      GoalTag.loseWeight => AppStrings.onboardingGoalLoseWeight,
      GoalTag.increaseStrength => AppStrings.onboardingGoalIncreaseStrength,
      GoalTag.improveEndurance => AppStrings.onboardingGoalImproveEndurance,
      GoalTag.generalFitness => AppStrings.onboardingGoalGeneralFitness,
      GoalTag.flexibility => AppStrings.onboardingGoalFlexibility,
    };
  }

  int _currentWeek() {
    if (item.startDateLocal == null || item.weeksTotal == null) return 1;
    final start = DateTime.tryParse(item.startDateLocal!);
    if (start == null) return 1;
    final diff = DateTime.now().difference(start);
    final week = (diff.inDays / 7).ceil() + 1;
    if (week < 1) return 1;
    if (item.weeksTotal != null && week > item.weeksTotal!) {
      return item.weeksTotal!;
    }
    return week;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final tt = context.textTheme;
    final opacity = _isCompleted ? 0.8 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Material(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withValues(alpha: 0.03),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: cs.surfaceContainer),
              ),
              foregroundDecoration: item.active
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border(
                        top: BorderSide(
                          color: cs.secondary,
                          width: AppSizing.activeIndicatorHeight,
                        ),
                      ),
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            children: [
                              if (_statusLabel case final label?)
                                AppBadge(
                                  label: label,
                                  foregroundColor: cs.onSecondaryContainer,
                                  backgroundColor: cs.secondaryContainer,
                                  borderRadius: AppRadius.defaultRadius,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.02,
                                ),
                              if (_sourceLabel case final label?)
                                AppBadge(
                                  label: label,
                                  foregroundColor: cs.secondary,
                                  backgroundColor: cs.surfaceContainer,
                                  borderRadius: AppRadius.defaultRadius,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.02,
                                ),
                            ],
                          ),
                        ),
                        _CardMenu(
                          onEdit: onEdit,
                          onToggleActive: onToggleActive,
                          onArchive: onArchive,
                          onDelete: onDelete,
                        ),
                      ],
                    ),
                    AppWhiteSpace.hSm,
                    Text(
                      item.name,
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppWhiteSpace.hMd,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatCell(
                          value: '${item.weeksTotal ?? '-'}',
                          label: AppStrings.weeks,
                          tt: tt,
                        ),
                        _StatCell(
                          value: '${item.daysPerWeek ?? '-'}',
                          label: AppStrings.daysPerWeek,
                          tt: tt,
                        ),
                        _StatCell(
                          value: _goalDisplay,
                          label: AppStrings.goal,
                          tt: tt,
                          isBoldValue: true,
                        ),
                      ],
                    ),
                    if (item.active && item.weeksTotal != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Divider(
                          height: AppSizing.divider,
                          thickness: AppSizing.divider,
                        ),
                      ),
                      _ProgressBar(
                        currentWeek: _currentWeek(),
                        totalWeeks: item.weeksTotal!,
                        cs: cs,
                        tt: tt,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.tt,
    this.isBoldValue = false,
  });

  final String value;
  final String label;
  final TextTheme tt;
  final bool isBoldValue;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            value,
            maxLines: 1,
            style: tt.headlineMedium?.copyWith(
              fontSize: AppFontSizes.lg,
              fontWeight: isBoldValue ? FontWeight.w600 : null,
            ),
          ),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.currentWeek,
    required this.totalWeeks,
    required this.cs,
    required this.tt,
  });

  final int currentWeek;
  final int totalWeeks;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final progress = math.min(currentWeek / totalWeeks, 1.0);
    final percent = (progress * 100).round();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.weekOf(currentWeek, totalWeeks),
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            Text(
              '$percent%',
              style: tt.labelSmall?.copyWith(
                color: cs.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        AppWhiteSpace.hXs,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: cs.surfaceContainer,
            valueColor: AlwaysStoppedAnimation(cs.secondary),
            minHeight: AppSizing.progressBarHeight,
          ),
        ),
      ],
    );
  }
}

class _CardMenu extends StatelessWidget {
  const _CardMenu({
    required this.onEdit,
    required this.onToggleActive,
    required this.onArchive,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return SizedBox(
      width: AppSizing.iconMd,
      height: AppSizing.iconMd,
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: SvgPicture.asset(
            OutlinedSvgAssets.ellipsisHorizontal,
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
            colorFilter: ColorFilter.mode(cs.onSurfaceVariant, BlendMode.srcIn),
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
              case 'toggleActive':
                onToggleActive();
              case 'archive':
                onArchive();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text(AppStrings.edit)),
            const PopupMenuItem(
              value: 'toggleActive',
              child: Text(AppStrings.activateProgramme),
            ),
            const PopupMenuItem(
              value: 'archive',
              child: Text(AppStrings.archiveProgramme),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(AppStrings.deleteProgramme),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: () {
          // TODO: wire import flow
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            width: double.infinity,
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: cs.outlineVariant,
                strokeWidth: 2,
                dashWidth: 8,
                gapWidth: 6,
                borderRadius: AppRadius.md,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      OutlinedSvgAssets.plus,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(
                        cs.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                    AppWhiteSpace.wSm,
                    Text(
                      AppStrings.importAedifyPlan,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSizing.iconLg,
              height: AppSizing.iconLg,
              colorFilter: ColorFilter.mode(cs.error, BlendMode.srcIn),
            ),
            AppWhiteSpace.hMd,
            Text(
              message,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppWhiteSpace.hMd,
              FilledButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.clipboardDocumentList,
              width: AppSizing.iconXxl,
              height: AppSizing.iconXxl,
              colorFilter: ColorFilter.mode(
                cs.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.hMd,
            Text(
              AppStrings.noProgrammesYet,
              style: context.textTheme.titleMedium,
            ),
            AppWhiteSpace.hSm,
            Text(
              AppStrings.noProgrammesYetHint,
              style: context.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
