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
  late int _remaining;
  Timer? _timer;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    )..forward();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining--;
      });
      if (_remaining <= 0) {
        _timer?.cancel();
        widget.onDismiss();
      }
    });
  }

  void _adjust(int delta) {
    final newRemaining = (_remaining + delta).clamp(0, 300);
    setState(() {
      _remaining = newRemaining;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining ~/ 60;
    final secs = _remaining % 60;
    final progress = widget.seconds > 0 ? _remaining / widget.seconds : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: context.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
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
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppStrings.restTime.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.tonal(
                onPressed: () => _adjust(-15),
                child: const Text(AppStrings.restMinus15),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton.tonal(
                onPressed: () => _adjust(15),
                child: const Text(AppStrings.restPlus15),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: widget.onDismiss,
            child: const Text(AppStrings.skipRest),
          ),
        ],
      ),
    );
  }
}
