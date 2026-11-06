import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/application/analytics_insights_providers.dart';
import 'package:aedify/features/analytics/data/analytics_csv_destination.dart';
import 'package:aedify/features/analytics/domain/analytics_insights.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/domain/analytics_query_failure.dart';
import 'package:aedify/features/analytics/presentation/analytics_format.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_components.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_trend_chart.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnalyticsInsightsPanel extends ConsumerStatefulWidget {
  const AnalyticsInsightsPanel({
    super.key,
    required this.range,
    required this.unit,
  });
  final AnalyticsRange range;
  final PreferredUnit unit;
  @override
  ConsumerState<AnalyticsInsightsPanel> createState() =>
      _AnalyticsInsightsPanelState();
}

class _AnalyticsInsightsPanelState
    extends ConsumerState<AnalyticsInsightsPanel> {
  BodyMetric _metric = BodyMetric.bodyweightKg;
  bool _exporting = false;
  String? _message;
  Future<void> _export() async {
    final range = widget.range;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text(AnalyticsStrings.exportCsv),
        content: const Text(AnalyticsStrings.exportReview),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text(AppStrings.continueLabel),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() {
      _exporting = true;
      _message = null;
    });
    final result = await ref
        .read(AnalyticsInsightsProviders.controller.notifier)
        .export(range, confirmed: true);
    if (!mounted) return;
    setState(() {
      _exporting = false;
      _message = switch (result) {
        AnalyticsExportResult.saved => AnalyticsStrings.exportSaved,
        AnalyticsExportResult.cancelled => AnalyticsStrings.exportCancelled,
        AnalyticsExportResult.unavailable =>
          AppErrorStrings.analyticsExportFailed,
        AnalyticsExportResult.tooLarge =>
          AppErrorStrings.analyticsExportTooLarge,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(AnalyticsInsightsProviders.data(widget.range));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnalyticsPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AnalyticsSectionTitle(AnalyticsStrings.measurements),
              AppWhiteSpace.hSm,
              DropdownButtonFormField<BodyMetric>(
                key: const ValueKey('analytics_body_metric'),
                initialValue: _metric,
                isExpanded: true,
                items: [
                  for (final metric in BodyMetric.values)
                    DropdownMenuItem(
                      value: metric,
                      child: Text(
                        AnalyticsStrings.metric(metric),
                        style: AnalyticsStyles.body(context),
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _metric = value);
                },
              ),
              AppWhiteSpace.hSm,
              OutlinedButton(
                key: const ValueKey('analytics_record_measurement'),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _MeasurementDialog(unit: widget.unit),
                ),
                child: const Text(AnalyticsStrings.recordMeasurement),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hMd,
        data.when(
          loading: () => const AnalyticsLoading(),
          error: (_, _) => AnalyticsMessage(
            message: AppErrorStrings.analyticsLoadFailed,
            action: AppStrings.retry,
            onAction: () => ref.invalidate(AnalyticsInsightsProviders.data),
          ),
          data: (insights) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnalyticsTrendChart(
                title: AnalyticsStrings.metric(_metric),
                hint: AnalyticsStrings.measurementHint,
                emptyMessage: AnalyticsStrings.noMeasurements,
                points: insights.series(_metric),
                unit: widget.unit,
                circumference: !_metric.isWeight && !_metric.isPercent,
                percentage: _metric.isPercent,
              ),
              AppWhiteSpace.hMd,
              AnalyticsPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AnalyticsSectionTitle(AnalyticsStrings.adherence),
                    AppWhiteSpace.hSm,
                    Text(
                      AnalyticsStrings.adherenceHint,
                      style: AnalyticsStyles.small(context),
                    ),
                    AppWhiteSpace.hMd,
                    if (insights.adherence.isEmpty)
                      Text(
                        AnalyticsStrings.noProgrammes,
                        style: AnalyticsStyles.body(context),
                      ),
                    for (final programme in insights.adherence) ...[
                      Text(
                        programme.name,
                        style: AnalyticsStyles.label(context),
                      ),
                      Text(
                        programme.percent == null
                            ? AnalyticsStrings.noDueWorkouts
                            : AnalyticsStrings.adherenceCount(
                                programme.completed,
                                programme.due,
                                AnalyticsFormat.number(
                                  programme.percent!,
                                  digits: 0,
                                ),
                              ),
                        style: AnalyticsStyles.body(context),
                      ),
                      if (programme.unscheduled > 0)
                        Text(
                          AnalyticsStrings.unscheduled(programme.unscheduled),
                          style: AnalyticsStyles.small(context),
                        ),
                      AppWhiteSpace.hMd,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hMd,
        OutlinedButton(
          key: const ValueKey('analytics_export_csv'),
          onPressed: _exporting ? null : _export,
          child: Text(
            _exporting
                ? AppStrings.progressPhotoWorking
                : AnalyticsStrings.exportCsv,
          ),
        ),
        if (_message != null)
          Semantics(
            liveRegion: true,
            child: Text(_message!, style: AnalyticsStyles.body(context)),
          ),
      ],
    );
  }
}

class _MeasurementDialog extends ConsumerStatefulWidget {
  const _MeasurementDialog({required this.unit});
  final PreferredUnit unit;
  @override
  ConsumerState<_MeasurementDialog> createState() => _MeasurementDialogState();
}

class _MeasurementDialogState extends ConsumerState<_MeasurementDialog> {
  final _fields = {
    for (final metric in BodyMetric.values) metric: TextEditingController(),
  };
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    for (final text in _fields.values) {
      text.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final values = <BodyMetric, double>{};
    for (final entry in _fields.entries) {
      if (entry.value.text.trim().isEmpty) continue;
      final parsed = double.tryParse(entry.value.text.trim());
      final canonical = parsed == null
          ? null
          : entry.key.isPercent
          ? parsed
          : entry.key.isWeight
          ? widget.unit.toCanonicalWeight(parsed)
          : widget.unit.toCanonicalHeight(parsed);
      if (canonical == null ||
          !canonical.isFinite ||
          canonical <= 0 ||
          (entry.key.isPercent && canonical > 100)) {
        setState(() => _error = AppErrorStrings.analyticsMeasurementInvalid);
        return;
      }
      values[entry.key] = canonical;
    }
    if (values.isEmpty) {
      setState(() => _error = AppErrorStrings.analyticsMeasurementInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(AnalyticsInsightsProviders.controller.notifier)
          .record(values);
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error == AnalyticsQueryFailure.invalidMeasurement
              ? AppErrorStrings.analyticsMeasurementInvalid
              : AppErrorStrings.analyticsMeasurementFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      scrollable: true,
      title: const Text(AnalyticsStrings.recordMeasurement),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(AnalyticsStrings.measuredToday),
          AppWhiteSpace.hMd,
          for (final metric in BodyMetric.values) ...[
            TextField(
              key: ValueKey('measurement_${metric.name}'),
              controller: _fields[metric],
              enabled: !_busy,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText:
                    '${AnalyticsStrings.metric(metric)} (${metric.isPercent
                        ? AnalyticsStrings.percentUnit
                        : metric.isWeight
                        ? widget.unit.weightUnit
                        : widget.unit.heightUnit})',
              ),
            ),
            AppWhiteSpace.hSm,
          ],
          if (_error != null) Semantics(liveRegion: true, child: Text(_error!)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => context.pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          key: const ValueKey('measurement_save'),
          onPressed: _busy ? null : _save,
          child: const Text(AppStrings.save),
        ),
      ],
    ),
  );
}
