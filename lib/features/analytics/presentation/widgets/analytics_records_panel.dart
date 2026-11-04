import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/domain/personal_record.dart';
import 'package:aedify/features/analytics/presentation/analytics_format.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_components.dart';
import 'package:aedify/features/lift_log/workout_history_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AnalyticsRecordsPanel extends StatefulWidget {
  const AnalyticsRecordsPanel({
    super.key,
    required this.title,
    required this.records,
    required this.unit,
    this.names = const {},
    this.onExercise,
  });
  final String title;
  final List<PersonalRecord> records;
  final PreferredUnit unit;
  final Map<int, String> names;
  final ValueChanged<int>? onExercise;
  @override
  State<AnalyticsRecordsPanel> createState() => _AnalyticsRecordsPanelState();
}

class _AnalyticsRecordsPanelState extends State<AnalyticsRecordsPanel> {
  static const _initialCount = 5;
  bool _expanded = false;
  @override
  Widget build(BuildContext context) => AnalyticsPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalyticsSectionTitle(widget.title),
        AppWhiteSpace.hMd,
        if (widget.records.isEmpty)
          Text(
            AnalyticsStrings.noRecordImprovements,
            style: AnalyticsStyles.small(context),
          ),
        for (final record in widget.records.take(
          _expanded ? widget.records.length : _initialCount,
        ))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: InkWell(
              onTap: widget.onExercise == null
                  ? null
                  : () => widget.onExercise!(record.exerciseId),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.onExercise != null)
                      Text(
                        widget.names[record.exerciseId] ??
                            WorkoutHistoryStrings.exerciseReference(
                              record.exerciseId,
                            ),
                        style: AnalyticsStyles.label(context),
                      ),
                    Text(
                      AnalyticsFormat.recordTitle(record, widget.unit),
                      style: AnalyticsStyles.small(context),
                    ),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Text(
                          AnalyticsFormat.recordValue(record, widget.unit),
                          style: AnalyticsStyles.body(context),
                        ),
                        Text(
                          record.isBaseline
                              ? AnalyticsStrings.baseline
                              : AnalyticsFormat.date(record.achievedAt),
                          style: AnalyticsStyles.small(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (widget.records.length > _initialCount)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded
                  ? AnalyticsStrings.showFewerRecords
                  : AnalyticsStrings.showAllRecords,
            ),
          ),
      ],
    ),
  );
}
