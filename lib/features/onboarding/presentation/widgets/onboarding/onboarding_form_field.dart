import 'package:flutter/material.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingFormField extends StatefulWidget {
  const OnboardingFormField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.maxLines,
  });

  final String initialValue;
  final void Function(String) onChanged;
  final String? hintText;
  final int? maxLines;

  @override
  State<OnboardingFormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<OnboardingFormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      hintText: widget.hintText,
      maxLines: widget.maxLines ?? 1,
      onChanged: widget.onChanged,
      fillColor: context.colorScheme.surfaceContainerLowest,
      borderRadius: AppRadius.md,
      style: AppTextStyles.bodyMd,
    );
  }
}
