import 'dart:async';

import 'package:aedify/features/workout_execution/domain/workout_duration_resolver.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Read-only elapsed workout clock shown in the runner header.
class WorkoutDurationTimer extends StatefulWidget {
  const WorkoutDurationTimer({
    super.key,
    required this.startedAt,
    required this.isPaused,
    this.pausedDurationSeconds,
    this.now,
  });

  final DateTime startedAt;
  final bool isPaused;
  final int? pausedDurationSeconds;

  @visibleForTesting
  final DateTime Function()? now;

  @override
  State<WorkoutDurationTimer> createState() => _WorkoutDurationTimerState();
}

class _WorkoutDurationTimerState extends State<WorkoutDurationTimer>
    with WidgetsBindingObserver {
  late final ValueNotifier<int> _elapsedSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _elapsedSeconds = ValueNotifier<int>(_resolveElapsedSeconds());
    _restartTimer(syncImmediately: false);
  }

  @override
  void didUpdateWidget(WorkoutDurationTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startedAt != oldWidget.startedAt ||
        widget.isPaused != oldWidget.isPaused ||
        widget.pausedDurationSeconds != oldWidget.pausedDurationSeconds ||
        widget.now != oldWidget.now) {
      _restartTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _restartTimer();
        return;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _timer?.cancel();
        return;
    }
  }

  int _resolveElapsedSeconds() {
    return WorkoutDurationResolver.elapsedSeconds(
      startedAt: widget.startedAt,
      accumulatedSeconds: widget.isPaused ? widget.pausedDurationSeconds : null,
      now: widget.now?.call() ?? DateTime.now(),
    );
  }

  void _restartTimer({bool syncImmediately = true}) {
    _timer?.cancel();
    if (syncImmediately) {
      _elapsedSeconds.value = _resolveElapsedSeconds();
    }
    if (widget.isPaused) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _elapsedSeconds.value = _resolveElapsedSeconds();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _elapsedSeconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _elapsedSeconds,
      builder: (context, elapsedSeconds, _) {
        final timerLabel = _WorkoutDurationFormatter.format(elapsedSeconds);
        return Semantics(
          label: AppStrings.timeElapsedLabel(timerLabel),
          child: ExcludeSemantics(
            child: Container(
              key: const ValueKey<String>('workout_runner_duration_timer'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.controlGap,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    OutlinedSvgAssets.materialTimer,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  AppWhiteSpace.wSm,
                  Text(
                    timerLabel,
                    style: WorkoutRunnerStyle.label(context).copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WorkoutDurationFormatter {
  _WorkoutDurationFormatter._();

  static String format(int totalSeconds) {
    final hours = totalSeconds ~/ Duration.secondsPerHour;
    final minutes = (totalSeconds ~/ Duration.secondsPerMinute).remainder(
      Duration.minutesPerHour,
    );
    final seconds = totalSeconds.remainder(Duration.secondsPerMinute);
    final minuteLabel = minutes.toString().padLeft(2, '0');
    final secondLabel = seconds.toString().padLeft(2, '0');

    if (hours == 0) return '$minuteLabel:$secondLabel';
    return '${hours.toString().padLeft(2, '0')}:$minuteLabel:$secondLabel';
  }
}
