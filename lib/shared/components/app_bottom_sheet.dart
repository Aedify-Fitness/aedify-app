import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

/// Consistent modal bottom sheet shell: handle bar, optional title with a
/// close button, and padded content. Use [AppBottomSheet.show] to present.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showCloseButton = true,
    this.padding,
    this.heightFactor,
  });

  final Widget child;
  final String? title;
  final bool showCloseButton;
  final EdgeInsetsGeometry? padding;

  /// Fraction of the screen height the sheet occupies. When null, the sheet
  /// sizes to its content.
  final double? heightFactor;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool showCloseButton = true,
    bool isScrollControlled = true,
    double? heightFactor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (_) => AppBottomSheet(
        title: title,
        showCloseButton: showCloseButton,
        heightFactor: heightFactor,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final brightness = context.theme.brightness;

    final content = Container(
      height: heightFactor != null
          ? MediaQuery.of(context).size.height * heightFactor!
          : null,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Center(
                child: Container(
                  width: AppSizing.handleWidth,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: brightness == Brightness.light
                        ? AedifyLightColors.handleBarColor
                        : AedifyDarkColors.handleBarColor,
                    borderRadius: BorderRadius.circular(AppRadius.xxs),
                  ),
                ),
              ),
            ),
            if (title != null || showCloseButton)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: context.textTheme.headlineMedium,
                        ),
                      )
                    else
                      const Spacer(),
                    if (showCloseButton)
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        onTap: () => context.pop(),
                        child: Container(
                          width: AppSizing.iconXxl,
                          height: AppSizing.iconXxl,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            OutlinedSvgAssets.xMark,
                            width: AppSizing.iconMd,
                            height: AppSizing.iconMd,
                            colorFilter: ColorFilter.mode(
                              colorScheme.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Flexible(
              child: Padding(
                padding:
                    padding ??
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );

    return SafeArea(top: false, child: content);
  }
}
