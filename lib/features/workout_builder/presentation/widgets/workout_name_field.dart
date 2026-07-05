import 'package:aedify/shared/components/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';

class WorkoutNameField extends StatefulWidget {
  const WorkoutNameField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.errorText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<WorkoutNameField> createState() => _WorkoutNameFieldState();
}

class _WorkoutNameFieldState extends State<WorkoutNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(WorkoutNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppTextField(
        controller: _controller,
        labelText: AppStrings.workoutName,
        hintText: AppStrings.workoutNameHint,
        errorText: widget.errorText,
        onChanged: widget.onChanged,
      ),
    );
  }
}
