import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
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
    return AppTextField(
      controller: _controller,
      labelText: AppStrings.customExerciseName,
      hintText: AppStrings.customExerciseNameHint,
      errorText: widget.errorText,
      onChanged: widget.onChanged,
    );
  }
}
