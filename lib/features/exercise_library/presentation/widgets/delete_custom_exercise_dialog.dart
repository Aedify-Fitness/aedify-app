import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeleteCustomExerciseDialog extends StatelessWidget {
  const DeleteCustomExerciseDialog({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.customExerciseDeleteConfirm),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(AppStrings.cancel),
        ),
        AppWhiteSpace.wSm,
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.error,
          ),
          onPressed: () {
            onConfirm();
            context.pop();
          },
          child: const Text(AppStrings.customExerciseDelete),
        ),
      ],
    );
  }
}
