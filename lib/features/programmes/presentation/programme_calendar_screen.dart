import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_calendar_header.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_section.dart';
import 'package:aedify/shared/components/app_empty_state.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/components/app_section_header.dart';
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

class ProgrammeCalendarScreen extends ConsumerStatefulWidget {
  const ProgrammeCalendarScreen({super.key, required this.programmeId});

  final String programmeId;

  @override
  ConsumerState<ProgrammeCalendarScreen> createState() =>
      _ProgrammeCalendarScreenState();
}

class _ProgrammeCalendarScreenState
    extends ConsumerState<ProgrammeCalendarScreen> {
  final Set<int> _expandedWeeks = {};
  final Map<int, GlobalKey> _weekKeys = {};
  final Map<int, GlobalKey> _weekPillKeys = {};
  final ScrollController _weekNavigationController = ScrollController();
  bool _didInitialExpand = false;
  int? _selectedWeekNumber;

  @override
  void dispose() {
    _weekNavigationController.dispose();
    super.dispose();
  }

  Future<void> _reload() => ref
      .read(
        AppProviders.programmeCalendarControllerProvider(
          widget.programmeId,
        ).notifier,
      )
      .reload();

  Future<void> _openProgrammeEditor() async {
    await context.pushNamed(
      AppRoutes.programmeBuilderEdit().name,
      pathParameters: {'id': widget.programmeId},
    );
    if (mounted) await _reload();
  }

  Future<void> _openTodayWorkout(String workoutId) async {
    await context.pushNamed(
      AppRoutes.workoutRunnerProgramWorkout().name,
      pathParameters: {'programId': widget.programmeId, 'workoutId': workoutId},
    );
    if (mounted) await _reload();
  }

  Future<void> _resumeActiveWorkout() async {
    await context.pushNamed(AppRoutes.workoutRunnerActive().name);
    if (mounted) await _reload();
  }

  Future<void> _openWorkoutDetail(DayViewData day) async {
    if (day.workoutId == null) return;
    await context.pushNamed(
      AppRoutes.programmeWorkoutDetail().name,
      pathParameters: {
        'programId': widget.programmeId,
        'workoutId': day.workoutId!,
      },
    );
    if (mounted) await _reload();
  }

  GlobalKey _weekKey(int weekNumber) =>
      _weekKeys.putIfAbsent(weekNumber, () => GlobalKey());

  void _initializeWeekState(ProgrammeCalendarViewData viewData) {
    if (_didInitialExpand) return;
    _didInitialExpand = true;

    final initialWeek =
        viewData.todayWeekNumber ??
        (viewData.weeks.isEmpty ? null : viewData.weeks.first.weekNumber);
    _selectedWeekNumber = initialWeek;
    if (initialWeek == null) return;

    _expandedWeeks.add(initialWeek);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pillContext = _weekPillKeys[initialWeek]?.currentContext;
      if (pillContext == null) return;
      Scrollable.ensureVisible(
        pillContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _selectWeek(int weekNumber) {
    setState(() {
      _selectedWeekNumber = weekNumber;
      _expandedWeeks.add(weekNumber);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _weekKeys[weekNumber]?.currentContext;
      if (targetContext == null) return;
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _toggleWeek(int weekNumber) {
    setState(() {
      _selectedWeekNumber = weekNumber;
      if (_expandedWeeks.contains(weekNumber)) {
        _expandedWeeks.remove(weekNumber);
      } else {
        _expandedWeeks.add(weekNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(
      AppProviders.programmeCalendarControllerProvider(widget.programmeId),
    );

    return asyncState.when(
      loading: () =>
          const _CalendarStateScaffold(child: _CalendarLoadingView()),
      error: (error, stack) => _CalendarStateScaffold(
        child: _CalendarErrorView(
          message: AppStrings.programmeCalendarLoadFailed,
          onRetry: _reload,
        ),
      ),
      data: (state) {
        if (state.isLoading) {
          return const _CalendarStateScaffold(child: _CalendarLoadingView());
        }
        if (state.errorMessage != null) {
          return _CalendarStateScaffold(
            child: _CalendarErrorView(
              message: state.errorMessage!,
              onRetry: _reload,
            ),
          );
        }

        final viewData = state.viewData;
        if (viewData == null) {
          return _CalendarStateScaffold(
            child: _CalendarErrorView(
              message: AppStrings.programmeCalendarLoadFailed,
              onRetry: _reload,
            ),
          );
        }

        _initializeWeekState(viewData);
        final activeSession = ref
            .watch(AppProviders.activeWorkoutSessionProvider)
            .asData
            ?.value;

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: ProgrammeCalendarHeader(
                      viewData: viewData,
                      programId: widget.programmeId,
                      activeSession: activeSession,
                      onBack: context.pop,
                      onEdit: _openProgrammeEditor,
                      onResumeTodayWorkout: _resumeActiveWorkout,
                      onStartTodayWorkout: viewData.todayWorkoutId == null
                          ? null
                          : () => _openTodayWorkout(viewData.todayWorkoutId!),
                    ),
                  ),
                  const SliverToBoxAdapter(child: AppWhiteSpace.hXl),
                  if (viewData.weeks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _WeekNavigator(
                        weeks: viewData.weeks,
                        currentWeekNumber: viewData.todayWeekNumber,
                        selectedWeekNumber: _selectedWeekNumber,
                        controller: _weekNavigationController,
                        pillKeys: _weekPillKeys,
                        onSelected: _selectWeek,
                      ),
                    ),
                  const SliverToBoxAdapter(child: AppWhiteSpace.hLg),
                  if (viewData.weeks.isEmpty)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      sliver: SliverToBoxAdapter(
                        child: AppEmptyState(
                          iconAsset: OutlinedSvgAssets.calendarDays,
                          title: AppStrings.noWorkoutsInWeek,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final week = viewData.weeks[index];
                          return KeyedSubtree(
                            key: _weekKey(week.weekNumber),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: ProgrammeWeekSection(
                                week: week,
                                isExpanded: _expandedWeeks.contains(
                                  week.weekNumber,
                                ),
                                isCurrentWeek:
                                    week.weekNumber == viewData.todayWeekNumber,
                                onToggle: () => _toggleWeek(week.weekNumber),
                                onDayTap: _openWorkoutDetail,
                              ),
                            ),
                          );
                        }, childCount: viewData.weeks.length),
                      ),
                    ),
                  const SliverToBoxAdapter(child: AppWhiteSpace.hXxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({
    required this.weeks,
    required this.currentWeekNumber,
    required this.selectedWeekNumber,
    required this.controller,
    required this.pillKeys,
    required this.onSelected,
  });

  final List<WeekViewData> weeks;
  final int? currentWeekNumber;
  final int? selectedWeekNumber;
  final ScrollController controller;
  final Map<int, GlobalKey> pillKeys;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AppSectionHeader(title: AppStrings.weeks),
        ),
        AppWhiteSpace.hSm,
        SizedBox(
          height: AppSpacing.xxxl,
          child: ListView.separated(
            controller: controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: weeks.length,
            separatorBuilder: (context, index) => AppWhiteSpace.wSm,
            itemBuilder: (context, index) {
              final week = weeks[index];
              return KeyedSubtree(
                key: pillKeys.putIfAbsent(week.weekNumber, () => GlobalKey()),
                child: _WeekPill(
                  week: week,
                  isCurrent: week.weekNumber == currentWeekNumber,
                  isSelected: week.weekNumber == selectedWeekNumber,
                  onTap: () => onSelected(week.weekNumber),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeekPill extends StatelessWidget {
  const _WeekPill({
    required this.week,
    required this.isCurrent,
    required this.isSelected,
    required this.onTap,
  });

  final WeekViewData week;
  final bool isCurrent;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected
        ? context.colorScheme.onSecondary
        : isCurrent
        ? context.colorScheme.secondary
        : context.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected
            ? context.colorScheme.secondary
            : isCurrent
            ? context.colorScheme.secondaryContainer
            : context.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(
            color: isSelected
                ? context.colorScheme.secondary
                : isCurrent
                ? context.colorScheme.secondary
                : context.colorScheme.outlineVariant,
            width: AppSizing.hairlineStrokeWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (week.isDeload || week.isWeekCompleted) ...[
                  SvgPicture.asset(
                    week.isDeload
                        ? OutlinedSvgAssets.leaf
                        : SolidSvgAssets.checkCircle,
                    width: AppSizing.iconXs,
                    height: AppSizing.iconXs,
                    colorFilter: ColorFilter.mode(
                      foregroundColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  AppWhiteSpace.wXs,
                ],
                Text(
                  '${AppStrings.weekLabelPrefix} ${week.weekNumber}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: foregroundColor,
                    fontWeight: isSelected || isCurrent
                        ? FontWeight.w700
                        : FontWeight.w500,
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

class _CalendarStateScaffold extends StatelessWidget {
  const _CalendarStateScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppIconButton(
                  asset: OutlinedSvgAssets.arrowLeft,
                  onPressed: context.pop,
                  semanticLabel: AppStrings.backLabel,
                  backgroundColor: context.colorScheme.surfaceContainerLow,
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _CalendarLoadingView extends StatelessWidget {
  const _CalendarLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.loading,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarErrorView extends StatelessWidget {
  const _CalendarErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppEmptyState(
        iconAsset: OutlinedSvgAssets.exclamationCircle,
        title: message,
        actionLabel: AppStrings.retry,
        onAction: onRetry,
      ),
    );
  }
}
