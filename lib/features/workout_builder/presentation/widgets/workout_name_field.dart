import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';

class WorkoutNameField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TextField(
        controller: TextEditingController.fromValue(
          TextEditingValue(text: initialValue),
        ),
        decoration: InputDecoration(
          labelText: AppStrings.workoutName,
          hintText: AppStrings.workoutNameHint,
          errorText: errorText,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
