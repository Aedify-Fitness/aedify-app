import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enableObscureToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.validator,
    this.filled,
    this.fillColor,
    this.contentPadding,
    this.borderRadius,
    this.style,
    this.isDense,
    this.suffixText,
    this.suffixStyle,
    this.borderOverride,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enableObscureToggle;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool? filled;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final double? borderRadius;
  final InputBorder? borderOverride;
  final TextStyle? style;
  final bool? isDense;
  final String? suffixText;
  final TextStyle? suffixStyle;
  final TextAlign textAlign;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText != oldWidget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  Widget? _buildObscureToggle() {
    if (!widget.enableObscureToggle) return null;
    final cs = context.colorScheme;
    return IconButton(
      tooltip: _obscured ? 'Show' : 'Hide',
      icon: SvgPicture.asset(
        _obscured ? OutlinedSvgAssets.eyeSlash : OutlinedSvgAssets.eye,
        width: AppSizing.iconMd,
        height: AppSizing.iconMd,
        colorFilter: ColorFilter.mode(cs.onSurfaceVariant, BlendMode.srcIn),
      ),
      onPressed: () => setState(() => _obscured = !_obscured),
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final cs = context.colorScheme;
    return InputDecoration(
      hintText: widget.hintText,
      hintStyle:
          widget.style?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ) ??
          AppTextStyles.bodyMd.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
      labelText: widget.labelText,
      labelStyle: AppTextStyles.labelMd.copyWith(color: cs.onSurfaceVariant),
      errorText: widget.errorText,
      errorStyle: AppTextStyles.labelSm.copyWith(color: cs.error),
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon ?? _buildObscureToggle(),
      suffixText: widget.suffixText,
      suffixStyle: widget.suffixStyle,
      filled: widget.filled ?? true,
      fillColor: widget.fillColor ?? cs.surfaceContainerLowest,
      isDense: widget.isDense ?? false,
      contentPadding:
          widget.contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.inputVertical,
          ),
      border:
          widget.borderOverride ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppRadius.defaultRadius,
            ),
            borderSide: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
      enabledBorder:
          widget.borderOverride ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppRadius.defaultRadius,
            ),
            borderSide: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
      focusedBorder:
          widget.borderOverride ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppRadius.defaultRadius,
            ),
            borderSide: BorderSide(
              color: cs.secondary,
              width: AppSizing.strokeWidth,
            ),
          ),
      errorBorder:
          widget.borderOverride ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppRadius.defaultRadius,
            ),
            borderSide: BorderSide(color: cs.error),
          ),
      focusedErrorBorder:
          widget.borderOverride ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppRadius.defaultRadius,
            ),
            borderSide: BorderSide(
              color: cs.error,
              width: AppSizing.strokeWidth,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveObscured = widget.enableObscureToggle
        ? _obscured
        : widget.obscureText;

    final field = (widget.validator != null)
        ? TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            decoration: _buildDecoration(context),
            obscureText: effectiveObscured,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            enabled: widget.enabled,
            validator: widget.validator,
            style: widget.style,
            textAlign: widget.textAlign,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          )
        : TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            decoration: _buildDecoration(context),
            obscureText: effectiveObscured,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            enabled: widget.enabled,
            style: widget.style,
            textAlign: widget.textAlign,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          );

    return field;
  }
}
