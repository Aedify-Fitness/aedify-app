import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingByokApiKeyField extends StatefulWidget {
  const OnboardingByokApiKeyField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<OnboardingByokApiKeyField> createState() => _ByokApiKeyFieldState();
}

class _ByokApiKeyFieldState extends State<OnboardingByokApiKeyField> {
  late final FocusNode _focusNode;
  final ValueNotifier<bool> _obscured = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _obscured.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusColor = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return AnimatedBuilder(
      animation: _focusNode,
      builder: (context, child) {
        return AnimatedContainer(
          key: const ValueKey<String>('onboarding_byok_api_key_field'),
          duration: const Duration(milliseconds: 200),
          height: AppSizing.onboardingByokFieldHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? focusColor
                  : context.colorScheme.surface,
              width: AppSizing.strokeWidth,
            ),
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: _obscured,
            builder: (context, obscured, child) {
              return AppTextField(
                controller: widget.controller,
                focusNode: _focusNode,
                hintText: widget.hintText,
                obscureText: obscured,
                filled: true,
                fillColor: context.colorScheme.surface,
                borderRadius: AppRadius.defaultRadius,
                borderOverride: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.inputVertical,
                ),
                onChanged: widget.onChanged,
                suffixIcon: IconButton(
                  tooltip: obscured
                      ? AppStrings.showApiKey
                      : AppStrings.hideApiKey,
                  onPressed: () => _obscured.value = !obscured,
                  icon: SvgPicture.asset(
                    obscured
                        ? OutlinedSvgAssets.materialVisibility
                        : OutlinedSvgAssets.materialVisibilityOff,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.outline,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
