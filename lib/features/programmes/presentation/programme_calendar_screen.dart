import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_calendar_header.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_section.dart';
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
  int? _selectedWeekNumber;

  @override
  void didUpdateWidget(covariant ProgrammeCalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.programmeId != widget.programmeId) {
      _selectedWeekNumber = null;
      _expandedWeeks.clear();
    }
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
    final workoutId = day.workoutId;
    if (workoutId == null) return;
    await context.pushNamed(
      AppRoutes.programmeWorkoutDetail().name,
      pathParameters: {'programId': widget.programmeId, 'workoutId': workoutId},
    );
    if (mounted) await _reload();
  }

  WeekViewData? _selectedWeek(ProgrammeCalendarViewData viewData) {
    if (viewData.weeks.isEmpty) {
      _selectedWeekNumber = null;
      return null;
    }
    for (final week in viewData.weeks) {
      if (week.weekNumber == _selectedWeekNumber) return week;
    }
    final initialWeek = viewData.weeks.firstWhere(
      (week) => week.weekNumber == viewData.todayWeekNumber,
      orElse: () => viewData.weeks.first,
    );
    _selectedWeekNumber = initialWeek.weekNumber;
    _expandedWeeks.add(initialWeek.weekNumber);
    return initialWeek;
  }

  void _selectWeek(int weekNumber) {
    setState(() {
      _selectedWeekNumber = weekNumber;
      _expandedWeeks.add(weekNumber);
    });
  }

  void _toggleWeek(int weekNumber) {
    setState(() {
      if (!_expandedWeeks.remove(weekNumber)) {
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
        child: _CalendarMessage(
          message: AppStrings.programmeCalendarLoadFailed,
          onAction: _reload,
          actionLabel: AppStrings.retry,
        ),
      ),
      data: (state) {
        if (state.isLoading) {
          return const _CalendarStateScaffold(child: _CalendarLoadingView());
        }
        final viewData = state.viewData;
        if (state.errorMessage != null || viewData == null) {
          return _CalendarStateScaffold(
            child: _CalendarMessage(
              message:
                  state.errorMessage ?? AppStrings.programmeCalendarLoadFailed,
              onAction: _reload,
              actionLabel: AppStrings.retry,
            ),
          );
        }

        final week = _selectedWeek(viewData);
        final activeSession = ref
            .watch(AppProviders.activeWorkoutSessionProvider)
            .asData
            ?.value;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppProgrammeCalendarTokens.maxContentWidth,
                ),
                child: RefreshIndicator(
                  onRefresh: _reload,
                  child: CustomScrollView(
                    key: const ValueKey('programme_calendar_scroll'),
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
                              : () =>
                                    _openTodayWorkout(viewData.todayWorkoutId!),
                        ),
                      ),
                      const SliverToBoxAdapter(child: AppWhiteSpace.hXl),
                      if (week == null)
                        SliverToBoxAdapter(
                          child: _CalendarMessage(
                            message: AppStrings.noWeeksAdded,
                            supportingText:
                                AppStrings.programmeEmptyScheduleHint,
                            onAction: _openProgrammeEditor,
                            actionLabel: AppStrings.edit,
                            iconAsset: OutlinedSvgAssets.calendarDays,
                          ),
                        )
                      else ...[
                        SliverToBoxAdapter(
                          child: _WeekNavigator(
                            key: ValueKey(widget.programmeId),
                            weeks: viewData.weeks,
                            currentWeekNumber: viewData.todayWeekNumber,
                            selectedWeekNumber: week.weekNumber,
                            onSelected: _selectWeek,
                          ),
                        ),
                        const SliverToBoxAdapter(child: AppWhiteSpace.hLg),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: ProgrammeWeekSection(
                              key: ValueKey(week.weekId),
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
                        ),
                      ],
                      const SliverToBoxAdapter(child: AppWhiteSpace.hXxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeekNavigator extends StatefulWidget {
  const _WeekNavigator({
    super.key,
    required this.weeks,
    required this.currentWeekNumber,
    required this.selectedWeekNumber,
    required this.onSelected,
  });

  final List<WeekViewData> weeks;
  final int? currentWeekNumber;
  final int selectedWeekNumber;
  final ValueChanged<int> onSelected;

  @override
  State<_WeekNavigator> createState() => _WeekNavigatorState();
}

class _WeekNavigatorState extends State<_WeekNavigator> {
  final Map<int, GlobalKey> _tileKeys = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _revealSelection();
  }

  @override
  void didUpdateWidget(covariant _WeekNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWeekNumber != widget.selectedWeekNumber ||
        oldWidget.weeks != widget.weeks) {
      _revealSelection();
    }
  }

  void _revealSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tileContext = _tileKeys[widget.selectedWeekNumber]?.currentContext;
      final renderObject = tileContext?.findRenderObject();
      if (tileContext == null || renderObject == null) return;
      // Reveal only the horizontal rail, keeping the programme header in place.
      Scrollable.of(tileContext).position.ensureVisible(
        renderObject,
        alignment: 0.5,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppDurations.navigationSelection,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final currentWeekNumber = widget.currentWeekNumber;
    final canReturnToCurrent =
        currentWeekNumber != null &&
        currentWeekNumber != widget.selectedWeekNumber &&
        widget.weeks.any((week) => week.weekNumber == currentWeekNumber);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.weeklySchedule,
                style:
                    (isDark
                            ? AppTextStylesDark.headlineMd
                            : AppTextStyles.headlineMd)
                        .copyWith(color: context.colorScheme.onSurface),
              ),
              AppWhiteSpace.hXs,
              Text(
                AppStrings.programmeScheduleHint,
                style:
                    (isDark ? AppTextStylesDark.bodySm : AppTextStyles.bodySm)
                        .copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
              if (canReturnToCurrent)
                TextButton(
                  key: const ValueKey('programme_calendar_current_week'),
                  onPressed: () => widget.onSelected(currentWeekNumber),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? context.colorScheme.primary
                        : context.colorScheme.secondary,
                    minimumSize: const Size.fromHeight(
                      AppProgrammeCalendarTokens.controlSize,
                    ),
                    textStyle:
                        (isDark
                                ? AppTextStylesDark.labelMd
                                : AppTextStyles.labelMd)
                            .copyWith(inherit: false),
                  ),
                  child: const Text(AppStrings.programmeCurrentWeek),
                ),
            ],
          ),
        ),
        AppWhiteSpace.hMd,
        SingleChildScrollView(
          key: const ValueKey('programme_calendar_week_navigation'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final week in widget.weeks)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _WeekTile(
                    key: _tileKeys.putIfAbsent(week.weekNumber, GlobalKey.new),
                    week: week,
                    isCurrent: week.weekNumber == currentWeekNumber,
                    isSelected: week.weekNumber == widget.selectedWeekNumber,
                    onTap: () => widget.onSelected(week.weekNumber),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekTile extends StatelessWidget {
  const _WeekTile({
    super.key,
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
    final isDark = context.theme.brightness == Brightness.dark;
    final colors = context.colorScheme;
    final accent = isDark ? colors.primary : colors.secondary;
    final textScale =
        MediaQuery.textScalerOf(context).scale(AppFontSizes.xxl) /
        AppFontSizes.xxl;
    final foreground = isSelected
        ? (isDark ? colors.onPrimary : colors.onSecondary)
        : colors.onSurface;
    final label = [
      AppStrings.programmeWeekLabel(week.weekNumber),
      if (isCurrent) AppStrings.programmeCurrentWeek,
      if (week.isDeload) AppStrings.weekDeload,
      if (week.isWeekCompleted) AppStrings.completed,
      if (week.isWeekSkipped) AppStrings.skipped,
    ].join(', ');

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: isSelected ? accent : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('programme_calendar_select_week_${week.weekNumber}'),
          onTap: onTap,
          child: ExcludeSemantics(
            child: SizedBox(
              width:
                  AppProgrammeCalendarTokens.weekWidth *
                  textScale.clamp(1, double.infinity),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.buttonVertical,
                ),
                child: Column(
                  children: [
                    Text(
                      AppStrings.weekLabelPrefix,
                      style:
                          (isDark
                                  ? AppTextStylesDark.labelSm
                                  : AppTextStyles.labelSm)
                              .copyWith(color: foreground),
                    ),
                    AppWhiteSpace.hXs,
                    Text(
                      week.weekNumber.toString().padLeft(2, '0'),
                      style: AppTextStyles.headlineMd.copyWith(
                        color: foreground,
                      ),
                    ),
                    AppWhiteSpace.hSm,
                    SizedBox(
                      height: AppSizing.iconSm,
                      child:
                          week.isDeload ||
                              week.isWeekCompleted ||
                              week.isWeekSkipped ||
                              isCurrent
                          ? SvgPicture.asset(
                              week.isDeload
                                  ? OutlinedSvgAssets.leaf
                                  : week.isWeekCompleted
                                  ? SolidSvgAssets.checkCircle
                                  : week.isWeekSkipped
                                  ? OutlinedSvgAssets.noSymbol
                                  : OutlinedSvgAssets.bolt,
                              width: AppSizing.iconSm,
                              height: AppSizing.iconSm,
                              colorFilter: ColorFilter.mode(
                                foreground,
                                BlendMode.srcIn,
                              ),
                            )
                          : Center(
                              child: Container(
                                width: AppSpacing.xs,
                                height: AppSpacing.xs,
                                decoration: BoxDecoration(
                                  color: foreground,
                                  shape: BoxShape.circle,
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppProgrammeCalendarTokens.maxContentWidth,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: AppStrings.backLabel,
                        onPressed: context.pop,
                        constraints: const BoxConstraints(
                          minWidth: AppProgrammeCalendarTokens.controlSize,
                          minHeight: AppProgrammeCalendarTokens.controlSize,
                        ),
                        icon: SvgPicture.asset(
                          OutlinedSvgAssets.arrowLeft,
                          width: AppSizing.iconMd,
                          height: AppSizing.iconMd,
                          colorFilter: ColorFilter.mode(
                            context.colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      AppWhiteSpace.wSm,
                      Expanded(
                        child: Text(
                          AppStrings.programmeCalendar,
                          style: AppTextStyles.labelMd.copyWith(
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarLoadingView extends StatelessWidget {
  const _CalendarLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(semanticsLabel: AppStrings.loading),
    );
  }
}

class _CalendarMessage extends StatelessWidget {
  const _CalendarMessage({
    required this.message,
    required this.onAction,
    required this.actionLabel,
    this.supportingText,
    this.iconAsset = OutlinedSvgAssets.exclamationCircle,
  });

  final String message;
  final String? supportingText;
  final VoidCallback onAction;
  final String actionLabel;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: AppSizing.iconXxl,
            height: AppSizing.iconXxl,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          AppWhiteSpace.hMd,
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                (isDark
                        ? AppTextStylesDark.headlineMd
                        : AppTextStyles.headlineMd)
                    .copyWith(color: context.colorScheme.onSurface),
          ),
          if (supportingText != null) ...[
            AppWhiteSpace.hSm,
            Text(
              supportingText!,
              textAlign: TextAlign.center,
              style: (isDark ? AppTextStylesDark.bodyMd : AppTextStyles.bodyMd)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
          AppWhiteSpace.hMd,
          FilledButton(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              backgroundColor: isDark
                  ? context.colorScheme.primaryContainer
                  : context.colorScheme.secondary,
              foregroundColor: isDark
                  ? context.colorScheme.onPrimaryContainer
                  : context.colorScheme.onSecondary,
              minimumSize: const Size.fromHeight(
                AppProgrammeCalendarTokens.controlSize,
              ),
              textStyle:
                  (isDark ? AppTextStylesDark.labelMd : AppTextStyles.labelMd)
                      .copyWith(inherit: false),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
