import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/application/analytics_view_providers.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/presentation/analytics_format.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_components.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_plateau_panel.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_records_panel.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_trend_chart.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_list_tile.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsRange _range = AnalyticsRange.fourWeeks;
  void _refresh() => AnalyticsViewProviders.refresh(ref);
  void _exercise(int id) => context.pushNamed(
    AppRoutes.analyticsExerciseHistory().name,
    pathParameters: {'id': '$id'},
  );
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(
      AnalyticsViewProviders.dataProvider((range: _range, exerciseId: null)),
    );
    final units = ref.watch(AnalyticsViewProviders.unitsProvider);
    final children = <Widget>[
      AnalyticsHeader(
        title: AppStrings.analytics,
        subtitle: AnalyticsStrings.introduction,
        onRefresh: _refresh,
      ),
      AnalyticsRangePicker(
        range: _range,
        onChanged: (range) => setState(() => _range = range),
      ),
    ];
    if (data.hasError || units.hasError) {
      children.add(
        AnalyticsMessage(
          message: AppErrorStrings.analyticsLoadFailed,
          error: true,
          action: AppStrings.retry,
          onAction: _refresh,
        ),
      );
    } else if (data.isLoading || units.isLoading) {
      children.add(const AnalyticsLoading());
    } else {
      final view = data.requireValue;
      final unit = units.requireValue;
      if (view.workingSets == 0) {
        children.add(
          AnalyticsMessage(
            title: view.hasAnyHistory
                ? AnalyticsStrings.emptyRange
                : AnalyticsStrings.emptyTitle,
            message: view.hasAnyHistory
                ? AnalyticsStrings.emptyRangeHint
                : AnalyticsStrings.emptyHint,
            action: AppStrings.logWorkout,
            onAction: () =>
                context.pushNamed(AppRoutes.workoutRunnerStandalone().name),
          ),
        );
      } else {
        children.addAll([
          AnalyticsOverview(data: view, unit: unit),
          AnalyticsTrendChart(
            title: AnalyticsStrings.weeklyVolume,
            hint: AnalyticsStrings.volumeHint,
            emptyMessage: AnalyticsStrings.noWeightedVolume,
            points: view.weeklyVolume,
            unit: unit,
            volume: true,
          ),
          AnalyticsPlateauPanel(
            names: view.exerciseNames,
            onExercise: _exercise,
          ),
          AnalyticsRecordsPanel(
            title: AnalyticsStrings.recentRecords,
            records: view.recentRecords,
            unit: unit,
            names: view.exerciseNames,
            onExercise: _exercise,
          ),
          const AnalyticsSectionTitle(AnalyticsStrings.exerciseTrends),
          for (final exercise in view.exercises)
            AnalyticsPanel(
              child: InkWell(
                key: ValueKey('analytics_exercise_${exercise.id}'),
                onTap: () => _exercise(exercise.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name, style: AnalyticsStyles.body(context)),
                      AppWhiteSpace.hSm,
                      Text(
                        AnalyticsStrings.sessionsAndSets(
                          exercise.sessions,
                          exercise.sets,
                        ),
                        style: AnalyticsStyles.small(context),
                      ),
                      AppWhiteSpace.hXs,
                      Text(
                        AnalyticsFormat.date(exercise.latest),
                        style: AnalyticsStyles.small(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ]);
      }
      children.add(const _RecentWorkouts());
    }
    return AnalyticsPage(onRefresh: () async => _refresh(), children: children);
  }
}

class AnalyticsOverview extends StatelessWidget {
  const AnalyticsOverview({super.key, required this.data, required this.unit});
  final AnalyticsViewData data;
  final PreferredUnit unit;
  @override
  Widget build(BuildContext context) => AnalyticsPanel(
    emphasized: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AnalyticsStrings.localWorkingSets,
          style: AnalyticsStyles.small(context),
        ),
        AppWhiteSpace.hMd,
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            AnalyticsMetric(
              label: AnalyticsStrings.sessions,
              value: '${data.sessions}',
            ),
            AnalyticsMetric(
              label: AnalyticsStrings.workingSets,
              value: '${data.workingSets}',
            ),
          ],
        ),
        AppWhiteSpace.hLg,
        Text(
          AnalyticsFormat.weight(data.volumeKgReps, unit, volume: true),
          style: AppTextStyles.headlineLgMobile,
        ),
        Text(
          AnalyticsStrings.externalVolume,
          style: AnalyticsStyles.small(context),
        ),
        AppWhiteSpace.hLg,
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.md,
          children: [
            AnalyticsMetric(
              label: AnalyticsStrings.thisWeek,
              value: AnalyticsFormat.weight(
                data.currentWeekVolume,
                unit,
                volume: true,
              ),
            ),
            AnalyticsMetric(
              label: AnalyticsStrings.previousWeek,
              value: AnalyticsFormat.weight(
                data.previousWeekVolume,
                unit,
                volume: true,
              ),
            ),
          ],
        ),
        AppWhiteSpace.hMd,
        Text(
          data.weekChangePercent == null
              ? AnalyticsStrings.noPreviousVolume
              : AnalyticsStrings.signedChange(
                  '${data.weekChangePercent! >= 0 ? '+' : ''}${AnalyticsFormat.number(data.weekChangePercent!)}',
                ),
          style: AnalyticsStyles.label(context),
        ),
        Text(
          AnalyticsStrings.volumeComparison,
          style: AnalyticsStyles.small(context),
        ),
      ],
    ),
  );
}

class _RecentWorkouts extends ConsumerWidget {
  const _RecentWorkouts();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(AnalyticsViewProviders.recentWorkoutsProvider)
      .when(
        loading: () => const AnalyticsLoading(),
        error: (_, _) => AnalyticsMessage(
          message: AppStrings.workoutHistoryLoadFailed,
          error: true,
          action: AppStrings.retry,
          onAction: () =>
              ref.invalidate(AnalyticsViewProviders.recentWorkoutsProvider),
        ),
        data: (workouts) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AnalyticsSectionTitle(AnalyticsStrings.recentWorkouts),
            AppWhiteSpace.hMd,
            if (workouts.isEmpty)
              Text(
                AppStrings.noWorkoutHistoryYet,
                style: AnalyticsStyles.small(context),
              ),
            for (final workout in workouts.take(5))
              WorkoutHistoryListTile(
                item: workout,
                onTap: () => context.pushNamed(
                  AppRoutes.workoutHistoryDetail().name,
                  pathParameters: {'sessionId': workout.sessionId},
                ),
              ),
            TextButton(
              onPressed: () => context.pushNamed(AppRoutes.liftLog().name),
              child: const Text(AppStrings.historyTab),
            ),
          ],
        ),
      );
}
