import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared heading and surface grammar for the manual programme builder.
class ProgrammeBuilderSection extends StatelessWidget {
  const ProgrammeBuilderSection({
    super.key,
    required this.title,
    required this.asset,
    required this.child,
    this.action,
  });
  final String title;
  final String asset;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Container(
            width: AppSpacing.xl,
            height: AppSpacing.xl,
            decoration: BoxDecoration(
              color: context.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              asset,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSecondaryContainer,
                BlendMode.srcIn,
              ),
            ),
          ),
          AppWhiteSpace.wControlGap,
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headlineLgMobile.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
          if (action != null) ...[
            AppWhiteSpace.wSm,
            Flexible(
              child: Align(alignment: Alignment.centerRight, child: action),
            ),
          ],
        ],
      ),
      AppWhiteSpace.hLg,
      child,
    ],
  );
}

class ProgrammeBuilderPanel extends StatelessWidget {
  const ProgrammeBuilderPanel({
    super.key,
    required this.child,
    this.highlighted = false,
    this.padding = AppSpacing.md,
  });
  final Widget child;
  final bool highlighted;
  final double padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
    decoration: BoxDecoration(
      color: highlighted
          ? Color.alphaBlend(
              context.colorScheme.secondaryContainer.withValues(
                alpha: AppProgrammeBuilderTokens.highlightOpacity,
              ),
              context.colorScheme.surfaceContainerLowest,
            )
          : context.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.md),
      border: Border.all(
        color: highlighted
            ? context.colorScheme.secondaryContainer
            : context.colorScheme.outlineVariant.withValues(
                alpha: AppProgrammeBuilderTokens.borderOpacity,
              ),
        width: highlighted ? AppSizing.strokeWidth : AppSizing.divider,
      ),
    ),
    child: child,
  );
}
