import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutRunnerHeader extends StatefulWidget {
  const WorkoutRunnerHeader({
    super.key,
    required this.title,
    required this.onComplete,
    required this.onCancel,
    required this.isCompleting,
  });

  final String title;
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final bool isCompleting;

  @override
  State<WorkoutRunnerHeader> createState() => _WorkoutRunnerHeaderState();
}

class _WorkoutRunnerHeaderState extends State<WorkoutRunnerHeader> {
  final _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _timer?.cancel();
    super.dispose();
  }

  String get _elapsed {
    final d = _stopwatch.elapsed;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.sessionInProgress.toUpperCase(),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
                AppWhiteSpace.hXs,
                Text(
                  widget.title,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                ),
                AppWhiteSpace.hXs,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        OutlinedSvgAssets.clock,
                        width: AppSizing.iconS,
                        height: AppSizing.iconS,
                        colorFilter: ColorFilter.mode(
                          context.colorScheme.onSecondaryContainer,
                          BlendMode.srcIn,
                        ),
                      ),
                      AppWhiteSpace.wXs,
                      Text(
                        _elapsed,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: widget.isCompleting ? null : widget.onComplete,
            icon: SvgPicture.asset(
              OutlinedSvgAssets.xMark,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
            ),
            label: Text(AppStrings.finishEarly),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}
