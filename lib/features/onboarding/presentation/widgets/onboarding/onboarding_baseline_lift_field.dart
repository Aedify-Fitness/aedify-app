import 'package:flutter/material.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingBaselineLiftField extends StatefulWidget {
  const OnboardingBaselineLiftField({
    super.key,
    required this.surfaceKey,
    required this.label,
    required this.initialValue,
    required this.unit,
    required this.onChanged,
  });

  final Key surfaceKey;
  final String label;
  final String initialValue;
  final String unit;
  final void Function(String value) onChanged;

  @override
  State<OnboardingBaselineLiftField> createState() => _BaselineLiftFieldState();
}

class _BaselineLiftFieldState extends State<OnboardingBaselineLiftField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          style: AppTextStyles.labelMd.copyWith(
            color: _hasFocus ? accent : context.colorScheme.onSurface,
          ),
          child: Text(widget.label),
        ),
        AppWhiteSpace.hControlGap,
        Semantics(
          textField: true,
          label: widget.label,
          child: AnimatedContainer(
            key: widget.surfaceKey,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: AppSizing.onboardingMaxLiftFieldHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _hasFocus
                  ? context.colorScheme.surfaceContainerLowest
                  : context.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              border: _hasFocus
                  ? Border.all(color: accent, width: AppSizing.strokeWidth)
                  : null,
            ),
            child: AppTextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              hintText: AppStrings.onboardingMetricZeroHint,
              suffixText: widget.unit,
              suffixStyle: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              filled: false,
              isDense: true,
              borderOverride: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.buttonVertical,
              ),
              style: AppTextStyles.headlineMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
