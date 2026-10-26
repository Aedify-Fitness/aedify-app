import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bordered, collapsible surface for local weeks and workout assignments.
class ProgrammeWeekManagementSection extends StatefulWidget {
  const ProgrammeWeekManagementSection({super.key, required this.child});
  final Widget child;

  @override
  State<ProgrammeWeekManagementSection> createState() =>
      _ProgrammeWeekManagementSectionState();
}

class _ProgrammeWeekManagementSectionState
    extends State<ProgrammeWeekManagementSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => Material(
    key: const ValueKey('programme_week_management_surface'),
    color: context.colorScheme.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: BorderSide(
        color: context.colorScheme.outlineVariant.withValues(
          alpha: AppProgrammeBuilderTokens.managementBorderOpacity,
        ),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      childrenPadding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.lg,
      ),
      shape: const Border(),
      collapsedShape: const Border(),
      onExpansionChanged: (expanded) => setState(() => _expanded = expanded),
      leading: SvgPicture.asset(
        OutlinedSvgAssets.calendarDays,
        width: AppSizing.iconMd,
        height: AppSizing.iconMd,
        colorFilter: ColorFilter.mode(
          context.colorScheme.secondary,
          BlendMode.srcIn,
        ),
      ),
      trailing: SvgPicture.asset(
        _expanded ? OutlinedSvgAssets.chevronUp : OutlinedSvgAssets.chevronDown,
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
        colorFilter: ColorFilter.mode(
          context.colorScheme.onSurfaceVariant,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        AppStrings.manageTrainingWeeks,
        style: AppTextStyles.headlineMd.copyWith(
          fontSize: AppFontSizes.xl,
          fontWeight: FontWeight.w700,
          color: context.colorScheme.onSurface,
        ),
      ),
      children: [
        Divider(
          height: AppSizing.divider,
          color: context.colorScheme.outlineVariant.withValues(
            alpha: AppProgrammeBuilderTokens.managementDividerOpacity,
          ),
        ),
        AppWhiteSpace.hLg,
        widget.child,
      ],
    ),
  );
}

class ProgrammeBuilderPillButton extends StatelessWidget {
  const ProgrammeBuilderPillButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: context.colorScheme.surfaceContainerLowest,
        foregroundColor: context.colorScheme.onSurface,
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(
            alpha: AppProgrammeBuilderTokens.managementButtonBorderOpacity,
          ),
        ),
        shape: const StadiumBorder(),
        minimumSize: const Size(0, AppSizing.iconXxl),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.inputVertical,
        ),
      ),
      icon: SvgPicture.asset(
        OutlinedSvgAssets.plus,
        width: AppSizing.iconSm,
        height: AppSizing.iconSm,
        colorFilter: ColorFilter.mode(
          context.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
      label: Text(
        label,
        style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
  );
}
