import 'dart:async';
import 'dart:ui';

import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Full-width bottom rest panel shown after a set is logged.
///
/// Matches the supplied design: a large circular countdown, a REST TIME
/// eyebrow label, -15s/+15s adjustments, and a full-width skip action that
/// returns the runner to the log-set action bar.
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

  @override
  void initState() {
    super.initState();
    _remaining = ValueNotifier<int>(
      widget.seconds.clamp(0, _maximumRestSeconds),
    );
    if (widget.seconds <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finishTimer());
      return;
    }
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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final next = _remaining.value - 1;
      _remaining.value = next.clamp(0, _maximumRestSeconds);
      if (_remaining.value == 0) _finishTimer();
    });
  }

  void _finishTimer() {
    _timer?.cancel();
    if (!mounted) return;
    widget.onDismiss();
  }

  void _adjust(int delta) {
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
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final accent = _RestTimerColors.accent(context);
    final onAccent = _RestTimerColors.onAccent(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppWorkoutRunnerTokens.glassBlurSigma,
          sigmaY: AppWorkoutRunnerTokens.glassBlurSigma,
        ),
        child: Container(
          key: const ValueKey<String>('workout_runner_rest_timer'),
          padding: EdgeInsets.only(
            left: AppWorkoutRunnerTokens.horizontalPadding,
            top: AppWorkoutRunnerTokens.restPanelVerticalPadding,
            right: AppWorkoutRunnerTokens.horizontalPadding,
            bottom:
                bottomInset + AppWorkoutRunnerTokens.restPanelVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surface.withValues(
              alpha: AppWorkoutRunnerTokens.actionSurfaceOpacity,
            ),
            border: Border(
              top: BorderSide(
                color: context.colorScheme.outlineVariant,
                width: AppSizing.divider,
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppWorkoutRunnerTokens.maxContentWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RestTimerRing(remaining: _remaining, accent: accent),
                  const SizedBox(
                    height: AppWorkoutRunnerTokens.restPanelSectionGap,
                  ),
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
                      AppWhiteSpace.wMd,
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
                  const SizedBox(
                    height: AppWorkoutRunnerTokens.restPanelSectionGap,
                  ),
                  FilledButton(
                    key: const ValueKey<String>('workout_runner_rest_skip'),
                    onPressed: widget.onDismiss,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: onAccent,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppWorkoutRunnerTokens
                            .restSkipButtonVerticalPadding,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppStrings.skipRestAndLogNextSet,
                        maxLines: 1,
                        style: AppTextStyles.headlineMd.copyWith(
                          color: onAccent,
                          fontSize: AppFontSizes.lg,
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
    );
  }
}

class _RestTimerRing extends StatelessWidget {
  const _RestTimerRing({required this.remaining, required this.accent});

  final ValueListenable<int> remaining;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: remaining,
          builder: (context, value, _) {
            final timerLabel = _RestTimerFormatter.format(value);
            return Semantics(
              label: AppStrings.restTimeRemaining(timerLabel),
              child: ExcludeSemantics(
                child: Container(
                  key: const ValueKey<String>('workout_runner_rest_timer_ring'),
                  width: AppWorkoutRunnerTokens.restTimerRingSize,
                  height: AppWorkoutRunnerTokens.restTimerRingSize,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: accent.withValues(
                      alpha: AppWorkoutRunnerTokens.activeRowSurfaceOpacity,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent,
                      width: AppWorkoutRunnerTokens.restTimerRingBorderWidth,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      timerLabel,
                      maxLines: 1,
                      style: AppTextStyles.headlineLg.copyWith(
                        color: accent,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppWorkoutRunnerTokens.restTimerLabelGap),
        Text(
          AppStrings.restTime.toUpperCase(),
          maxLines: 1,
          style: AppTextStyles.labelSm.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            letterSpacing: AppWorkoutRunnerTokens.restTimerLabelLetterSpacing,
          ),
        ),
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
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          vertical: AppWorkoutRunnerTokens.restAdjustButtonVerticalPadding,
        ),
        textStyle: AppTextStyles.labelMd,
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
    );
  }
}

class _RestTimerColors {
  _RestTimerColors._();

  static Color accent(BuildContext context) =>
      Theme.brightnessOf(context) == Brightness.dark
      ? context.colorScheme.primary
      : context.colorScheme.secondary;

  static Color onAccent(BuildContext context) =>
      Theme.brightnessOf(context) == Brightness.dark
      ? context.colorScheme.onPrimary
      : context.colorScheme.onSecondary;
}

class _RestTimerFormatter {
  _RestTimerFormatter._();

  static String format(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
