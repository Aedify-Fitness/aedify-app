import 'dart:async';

import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A circular rest countdown with adjustments and a full-width skip action.
class RestTimerWidget extends StatefulWidget {
  const RestTimerWidget({
    super.key,
    required this.seconds,
    required this.onDismiss,
  });

  final int seconds;
  final VoidCallback onDismiss;

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  static const int _maximumRestSeconds = 300;

  late final ValueNotifier<int> _remaining;
  Timer? _timer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _remaining = ValueNotifier<int>(
      widget.seconds.clamp(0, _maximumRestSeconds),
    );
    _startTimer();
  }

  @override
  void didUpdateWidget(RestTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seconds != oldWidget.seconds) {
      _remaining.value = widget.seconds.clamp(0, _maximumRestSeconds);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _dismissed = false;
    if (_remaining.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _remaining.value == 0) _finishTimer();
      });
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _remaining.value = (_remaining.value - 1).clamp(0, _maximumRestSeconds);
      if (_remaining.value == 0) _finishTimer();
    });
  }

  void _finishTimer() {
    _timer?.cancel();
    if (!mounted || _dismissed) return;
    _dismissed = true;
    widget.onDismiss();
  }

  void _adjust(int delta) {
    if (_dismissed) return;
    final next = (_remaining.value + delta).clamp(0, _maximumRestSeconds);
    _remaining.value = next;
    if (next == 0) _finishTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remaining.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const ValueKey<String>('workout_runner_rest_timer'),
      color: context.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppWorkoutRunnerTokens.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppWorkoutRunnerTokens.horizontalPadding,
                vertical: AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RestTimerRing(remaining: _remaining),
                  AppWhiteSpace.hMd,
                  Row(
                    children: [
                      Expanded(
                        child: _RestAdjustButton(
                          key: const ValueKey<String>(
                            'workout_runner_rest_subtract',
                          ),
                          label: AppStrings.restMinus15,
                          onPressed: () => _adjust(-15),
                        ),
                      ),
                      AppWhiteSpace.wSm,
                      Expanded(
                        child: _RestAdjustButton(
                          key: const ValueKey<String>(
                            'workout_runner_rest_add',
                          ),
                          label: AppStrings.restPlus15,
                          onPressed: () => _adjust(15),
                        ),
                      ),
                    ],
                  ),
                  AppWhiteSpace.hControlGap,
                  FilledButton(
                    key: const ValueKey<String>('workout_runner_rest_skip'),
                    onPressed: _finishTimer,
                    style: FilledButton.styleFrom(
                      backgroundColor: WorkoutRunnerStyle.actionFill(context),
                      foregroundColor: WorkoutRunnerStyle.actionForeground(
                        context,
                      ),
                      minimumSize: const Size.fromHeight(
                        AppWorkoutRunnerTokens.controlSize,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.controlGap,
                      ),
                      textStyle: WorkoutRunnerStyle.label(
                        context,
                      ).copyWith(inherit: false),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      AppStrings.skipRest,
                      textAlign: TextAlign.center,
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

class _RestTimerRing extends StatelessWidget {
  const _RestTimerRing({required this.remaining});

  final ValueListenable<int> remaining;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: remaining,
          builder: (context, value, _) {
            final timerLabel = _RestTimerFormatter.format(value);
            final clockStyle = WorkoutRunnerStyle.heading(context).copyWith(
              color: WorkoutRunnerStyle.accent(context),
              fontFeatures: const [FontFeature.tabularFigures()],
            );
            final painter = TextPainter(
              text: TextSpan(text: timerLabel, style: clockStyle),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
              maxLines: 1,
            )..layout();
            final diameter =
                (painter.width +
                        (AppSpacing.xs * 2) +
                        (AppWorkoutRunnerTokens.restTimerRingBorderWidth * 2))
                    .ceilToDouble()
                    .clamp(
                      AppWorkoutRunnerTokens.restTimerRingSize,
                      double.infinity,
                    );
            painter.dispose();
            return Semantics(
              label: AppStrings.restTimeRemaining(timerLabel),
              child: ExcludeSemantics(
                child: Container(
                  key: const ValueKey<String>('workout_runner_rest_timer_ring'),
                  width: diameter,
                  height: diameter,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: WorkoutRunnerStyle.accent(context),
                      width: AppWorkoutRunnerTokens.restTimerRingBorderWidth,
                    ),
                  ),
                  child: Text(timerLabel, maxLines: 1, style: clockStyle),
                ),
              ),
            );
          },
        ),
        AppWhiteSpace.hSm,
        Text(AppStrings.restTime, style: WorkoutRunnerStyle.caption(context)),
      ],
    );
  }
}

class _RestAdjustButton extends StatelessWidget {
  const _RestAdjustButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colorScheme.onSurface,
        backgroundColor: context.colorScheme.surfaceContainerLow,
        side: BorderSide(color: context.colorScheme.outlineVariant),
        minimumSize: const Size(
          AppWorkoutRunnerTokens.controlSize,
          AppWorkoutRunnerTokens.controlSize,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.controlGap,
          vertical: AppSpacing.controlGap,
        ),
        textStyle: WorkoutRunnerStyle.label(context).copyWith(inherit: false),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

abstract final class _RestTimerFormatter {
  static String format(int totalSeconds) {
    final minutes = totalSeconds ~/ Duration.secondsPerMinute;
    final seconds = totalSeconds.remainder(Duration.secondsPerMinute);
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
