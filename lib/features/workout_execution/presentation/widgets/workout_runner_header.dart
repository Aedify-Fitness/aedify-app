import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class WorkoutRunnerHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton.tonalIcon(
            onPressed: isCompleting ? null : onComplete,
            icon: isCompleting
                ? const SizedBox(
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : SvgPicture.asset(
                    OutlinedSvgAssets.check,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                  ),
            label: Text(AppStrings.completeWorkout),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onCancel,
            icon: SvgPicture.asset(
              OutlinedSvgAssets.xMark,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
            ),
            tooltip: AppStrings.cancelWorkout,
          ),
        ],
      ),
    );
  }
}
