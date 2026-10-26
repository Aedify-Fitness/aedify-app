import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:go_router/go_router.dart';

class ActiveProgrammeWarningDialog extends StatelessWidget {
  const ActiveProgrammeWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.activeProgrammeWarning),
      content: const Text(AppStrings.activeProgrammeWarning),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(
            AppStrings.cancel,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.pop(true),
          child: const Text(AppStrings.continueLabel),
        ),
      ],
    );
  }
}
