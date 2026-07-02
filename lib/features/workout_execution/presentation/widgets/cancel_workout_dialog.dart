import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:go_router/go_router.dart';

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
          onPressed: () => context.pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () {
            context.pop();
            onConfirm();
          },
          child: const Text(AppStrings.cancelWorkout),
        ),
      ],
    );
  }
}
