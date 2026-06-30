import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class CancelWorkoutDialog extends StatelessWidget {
  const CancelWorkoutDialog({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.cancelWorkout),
      content: const Text(AppStrings.cancelWorkoutMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text(AppStrings.cancelWorkout),
        ),
      ],
    );
  }
}
