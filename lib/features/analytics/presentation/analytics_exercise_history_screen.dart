import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/application/analytics_view_providers.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/presentation/analytics_format.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_components.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_plateau_panel.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_records_panel.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_trend_chart.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_exercise_card.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnalyticsExerciseHistoryScreen extends ConsumerStatefulWidget {
  const AnalyticsExerciseHistoryScreen({super.key, required this.exerciseId});
  final int? exerciseId;
  @override
  ConsumerState<AnalyticsExerciseHistoryScreen> createState() =>
      _AnalyticsExerciseHistoryScreenState();
}

class _AnalyticsExerciseHistoryScreenState
    extends ConsumerState<AnalyticsExerciseHistoryScreen> {
  AnalyticsRange _range = AnalyticsRange.fourWeeks;
  void _refresh() =>
      AnalyticsViewProviders.refresh(ref, exerciseId: widget.exerciseId);
  @override
  Widget build(BuildContext context) {
    final id = widget.exerciseId;
    if (id == null) {
      return AnalyticsPage(
        onRefresh: () async {},
        children: [
          AnalyticsHeader(
            title: AppStrings.analytics,
            onRefresh: () {},
            onBack: context.pop,
          ),
          const AnalyticsMessage(message: AppErrorStrings.notFoundMessage),
        ],
      );
    }
    final data = ref.watch(
      AnalyticsViewProviders.dataProvider((range: _range, exerciseId: id)),
    );
    final units = ref.watch(AnalyticsViewProviders.unitsProvider);
    final view = data.asData?.value;
    final children = <Widget>[
      AnalyticsHeader(
        title:
            view?.exerciseNames[id] ??
            WorkoutHistoryStrings.exerciseReference(id),
        subtitle: AnalyticsStrings.localWorkingSets,
        onRefresh: _refresh,
        onBack: context.pop,
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
    } else if (view == null || units.isLoading) {
      children.add(const AnalyticsLoading());
    } else {
      final unit = units.requireValue;
      children.addAll([
        AnalyticsTrendChart(
          title: AnalyticsStrings.estimatedStrength,
          hint: AnalyticsStrings.estimatedStrengthHint,
          emptyMessage: AnalyticsStrings.noStrengthEstimate,
          points: view.strengthTrend,
          unit: unit,
        ),
        AnalyticsTrendChart(
          title: AnalyticsStrings.sessionVolume,
          hint: AnalyticsStrings.volumeHint,
          emptyMessage: AnalyticsStrings.noWeightedVolume,
          points: view.sessionVolume,
          unit: unit,
          volume: true,
        ),
        AnalyticsRecordsPanel(
          title: AnalyticsStrings.allTimeBests,
          records: view.records.current,
          unit: unit,
        ),
        if (view.estimates.estimates.any(
          (estimate) => !estimate.isAnchorCandidate,
        ))
          _LowConfidenceEstimates(data: view, unit: unit),
        AnalyticsPlateauPanel(exerciseId: id, names: view.exerciseNames),
        const AnalyticsSectionTitle(AnalyticsStrings.loggedSets),
        Text(
          AnalyticsStrings.historyIncludesWarmups,
          style: AnalyticsStyles.small(context),
        ),
        _SavedSetHistory(exerciseId: id),
      ]);
    }
    return AnalyticsPage(onRefresh: () async => _refresh(), children: children);
  }
}

class _LowConfidenceEstimates extends StatelessWidget {
  const _LowConfidenceEstimates({required this.data, required this.unit});
  final AnalyticsViewData data;
  final PreferredUnit unit;
  @override
  Widget build(BuildContext context) => AnalyticsPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalyticsSectionTitle(AnalyticsStrings.highRepEstimates),
        AppWhiteSpace.hSm,
        Text(
          AnalyticsStrings.highRepHint,
          style: AnalyticsStyles.small(context),
        ),
        for (final estimate
            in data.estimates.estimates
                .where((item) => !item.isAnchorCandidate)
                .toList()
                .reversed
                .take(5))
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AnalyticsStrings.estimateValue(
                    AnalyticsFormat.number(
                      unit.toDisplayWeight(estimate.estimatedWeightKg),
                    ),
                    unit.weightUnit,
                  ),
                  style: AnalyticsStyles.body(context),
                ),
                Text(
                  '${AnalyticsStrings.lowConfidence} · ${AnalyticsFormat.date(estimate.performedAt)}',
                  style: AnalyticsStyles.small(context),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _SavedSetHistory extends ConsumerWidget {
  const _SavedSetHistory({required this.exerciseId});
  final int exerciseId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(AnalyticsViewProviders.historyProvider(exerciseId))
      .when(
        loading: () => const AnalyticsLoading(),
        error: (_, _) => AnalyticsMessage(
          message: AppStrings.workoutHistoryLoadFailed,
          error: true,
          action: AppStrings.retry,
          onAction: () => ref.invalidate(
            AnalyticsViewProviders.historyProvider(exerciseId),
          ),
        ),
        data: (sessions) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (sessions.isEmpty)
              Text(
                AnalyticsStrings.noSavedSets,
                style: AnalyticsStyles.small(context),
              ),
            for (final session in sessions) ...[
              Text(
                '${session.workoutName} · ${AnalyticsFormat.date(session.completedAt)}',
                style: AnalyticsStyles.label(context),
              ),
              AppWhiteSpace.hMd,
              for (final exercise in session.exercises)
                WorkoutHistoryExerciseCard(
                  item: exercise,
                  onTap: () => context.pushNamed(
                    AppRoutes.workoutHistoryDetail().name,
                    pathParameters: {'sessionId': session.sessionId},
                  ),
                ),
            ],
          ],
        ),
      );
}
