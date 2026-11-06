import 'dart:math' as math;
import 'package:aedify/features/analytics/analytics_strings.dart';
import 'package:aedify/features/analytics/domain/analytics_view_data.dart';
import 'package:aedify/features/analytics/presentation/analytics_format.dart';
import 'package:aedify/features/analytics/presentation/widgets/analytics_components.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_durations.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Shared chart with touch tooltips and an accessible, expandable data table.
class AnalyticsTrendChart extends StatefulWidget {
  const AnalyticsTrendChart({
    super.key,
    required this.title,
    required this.hint,
    required this.emptyMessage,
    required this.points,
    required this.unit,
    this.volume = false,
    this.circumference = false,
    this.percentage = false,
  });
  final String title;
  final String hint;
  final String emptyMessage;
  final List<AnalyticsChartPoint> points;
  final PreferredUnit unit;
  final bool volume;
  final bool circumference;
  final bool percentage;
  @override
  State<AnalyticsTrendChart> createState() => _AnalyticsTrendChartState();
}

class _AnalyticsTrendChartState extends State<AnalyticsTrendChart> {
  static const _millisecondsPerDay = 86400000;
  late List<FlSpot> _spots;
  late List<AnalyticsChartPoint> _points;
  late double _maximum;
  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(covariant AnalyticsTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points ||
        oldWidget.unit != widget.unit ||
        oldWidget.circumference != widget.circumference ||
        oldWidget.percentage != widget.percentage) {
      _prepare();
    }
  }

  void _prepare() {
    _points = widget.points
        .where(
          (point) =>
              point.value.isFinite &&
              point.value >= 0 &&
              _display(point.value).isFinite,
        )
        .toList();
    _spots = [
      for (final point in _points)
        FlSpot(
          point.date.millisecondsSinceEpoch / _millisecondsPerDay,
          _display(point.value),
        ),
    ];
    _maximum = _spots.fold<double>(0, (max, point) => math.max(max, point.y));
  }

  double _display(double value) => widget.percentage
      ? value
      : widget.circumference
      ? widget.unit.toDisplayHeight(value)
      : widget.unit.toDisplayWeight(value);
  String _value(double value) => widget.circumference
      ? '${AnalyticsFormat.number(_display(value))} ${widget.unit.heightUnit}'
      : widget.percentage
      ? '${AnalyticsFormat.number(value)} ${AnalyticsStrings.percentUnit}'
      : AnalyticsFormat.weight(value, widget.unit, volume: widget.volume);

  @override
  Widget build(BuildContext context) {
    final accent = AnalyticsStyles.accent(context);
    final unitLabel =
        '${widget.percentage
            ? AnalyticsStrings.percentUnit
            : widget.circumference
            ? widget.unit.heightUnit
            : widget.unit.weightUnit}${widget.volume ? ' ${AnalyticsStrings.volumeUnit}' : ''}';
    return AnalyticsPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalyticsSectionTitle(widget.title),
          AppWhiteSpace.hSm,
          Text(widget.hint, style: AnalyticsStyles.small(context)),
          AppWhiteSpace.hLg,
          if (_spots.isEmpty)
            Text(widget.emptyMessage, style: AnalyticsStyles.body(context))
          else ...[
            Semantics(
              label: AnalyticsStrings.chartSemantics(
                widget.title,
                _spots.length,
                unitLabel,
              ),
              child: ExcludeSemantics(
                child: SizedBox(
                  height: AppSizing.analyticsChartHeight,
                  child: LineChart(
                    LineChartData(
                      minX: _spots.first.x,
                      maxX: _spots.length == 1
                          ? _spots.first.x + 1
                          : math.max(_spots.last.x, _spots.first.x + 1),
                      minY: 0,
                      maxY: _maximum == 0
                          ? 1
                          : (_maximum * 1.15).isFinite
                          ? _maximum * 1.15
                          : _maximum,
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        bottomTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            maxIncluded: false,
                            reservedSize: MediaQuery.textScalerOf(
                              context,
                            ).scale(AppSizing.fieldWidthXs),
                            interval: _maximum > 0 ? _maximum / 2 : 1,
                            getTitlesWidget: (value, _) => Text(
                              AnalyticsFormat.compact(value),
                              style: AnalyticsStyles.small(context),
                            ),
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: context.colorScheme.outlineVariant,
                          strokeWidth: AppSizing.hairlineStrokeWidth,
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          maxContentWidth: AppSizing.analyticsDataRowMinWidth,
                          getTooltipColor: (_) =>
                              context.colorScheme.surfaceContainerHighest,
                          getTooltipItems: (spots) => [
                            for (final spot in spots)
                              LineTooltipItem(
                                '${AnalyticsFormat.shortDate(_points[spot.spotIndex].date)}\n${AnalyticsFormat.number(spot.y)} $unitLabel',
                                AnalyticsStyles.label(context),
                              ),
                          ],
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _spots,
                          isCurved: false,
                          color: accent,
                          barWidth: AppSizing.strokeWidth,
                          dotData: FlDotData(show: _spots.length <= 12),
                          belowBarData: BarAreaData(
                            show: true,
                            color: accent.withValues(
                              alpha: AppWorkoutHistoryTokens.tintOpacity,
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : AppDurations.formFocus,
                  ),
                ),
              ),
            ),
            AppWhiteSpace.hSm,
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                Text(
                  AnalyticsFormat.shortDate(_points.first.date),
                  style: AnalyticsStyles.small(context),
                ),
                Text(
                  _value(_points.last.value),
                  style: AnalyticsStyles.label(context),
                ),
                Text(
                  AnalyticsFormat.shortDate(_points.last.date),
                  style: AnalyticsStyles.small(context),
                ),
              ],
            ),
            if (_spots.length == 1) ...[
              AppWhiteSpace.hSm,
              Text(
                AnalyticsStrings.sparseData,
                style: AnalyticsStyles.small(context),
              ),
            ],
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.zero,
              ),
              title: Text(
                AnalyticsStrings.viewData,
                style: AnalyticsStyles.label(context),
              ),
              children: [
                for (final point in _points)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Text(
                          AnalyticsFormat.date(point.date),
                          style: AnalyticsStyles.small(context),
                        ),
                        Text(
                          _value(point.value),
                          style: AnalyticsStyles.body(context),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
