import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiscardCustomExerciseChangesDialog extends StatelessWidget {
  const DiscardCustomExerciseChangesDialog({
    super.key,
    required this.onDiscard,
  });

  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.customExerciseUnsavedChanges),
      content: const Text(AppStrings.customExerciseUnsavedChangesMessage),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(AppStrings.cancel),
        ),
        AppWhiteSpace.wSm,
        FilledButton(
          onPressed: () {
            onDiscard();
            context.pop(true);
          },
          child: const Text(AppStrings.customExerciseDiscard),
        ),
      ],
    );
  }
}
