import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class CustomExerciseNameField extends StatefulWidget {
  const CustomExerciseNameField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.errorText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<CustomExerciseNameField> createState() =>
      _CustomExerciseNameFieldState();
}

class _CustomExerciseNameFieldState extends State<CustomExerciseNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(CustomExerciseNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: AppStrings.customExerciseName,
        hintText: AppStrings.customExerciseNameHint,
        errorText: widget.errorText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
