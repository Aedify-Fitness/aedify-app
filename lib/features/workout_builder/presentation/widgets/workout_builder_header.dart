import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:go_router/go_router.dart';

class WorkoutBuilderHeader extends StatelessWidget {
  const WorkoutBuilderHeader({
    super.key,
    required this.title,
    required this.onSave,
    required this.isSaving,
  });

  final String title;
  final VoidCallback onSave;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: SvgPicture.asset(
            OutlinedSvgAssets.arrowLeft,
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        AppWhiteSpace.wSm,
        Expanded(child: Text(title, style: AppTextStyles.headlineMd)),
        TextButton(
          onPressed: isSaving ? null : onSave,
          child: isSaving
              ? const SizedBox(
                  width: AppSpacing.md,
                  height: AppSpacing.md,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSizing.strokeWidth,
                  ),
                )
              : Text(AppStrings.saveWorkout),
        ),
      ],
    );
  }
}
