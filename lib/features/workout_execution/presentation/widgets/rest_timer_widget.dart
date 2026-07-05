import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

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

class _RestTimerWidgetState extends State<RestTimerWidget>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<int> _remaining;
  Timer? _timer;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _remaining = ValueNotifier<int>(widget.seconds);
    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    )..forward();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _remaining.value--;
      if (_remaining.value <= 0) {
        _timer?.cancel();
        widget.onDismiss();
      }
    });
  }

  void _adjust(int delta) {
    _remaining.value = (_remaining.value + delta).clamp(0, 300);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remaining.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: context.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _remaining,
            builder: (context, remaining, _) {
              final minutes = remaining ~/ 60;
              final secs = remaining % 60;
              final progress = widget.seconds > 0
                  ? remaining / widget.seconds
                  : 0.0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: AppSizing.restTimerSize,
                    height: AppSizing.restTimerSize,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: AppSizing.timerStrokeWidth,
                      backgroundColor: context.colorScheme.surfaceContainer,
                      color: context.colorScheme.secondary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                        style: context.textTheme.headlineLarge,
                      ),
                      AppWhiteSpace.hXs,
                      Text(
                        AppStrings.restTime.toUpperCase(),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          AppWhiteSpace.hMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.tonal(
                onPressed: () => _adjust(-15),
                child: const Text(AppStrings.restMinus15),
              ),
              AppWhiteSpace.wMd,
              FilledButton.tonal(
                onPressed: () => _adjust(15),
                child: const Text(AppStrings.restPlus15),
              ),
            ],
          ),
          AppWhiteSpace.hMd,
          TextButton(
            onPressed: widget.onDismiss,
            child: const Text(AppStrings.skipRest),
          ),
        ],
      ),
    );
  }
}
