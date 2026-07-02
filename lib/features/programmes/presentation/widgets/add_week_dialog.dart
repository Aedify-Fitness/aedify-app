import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:go_router/go_router.dart';

class AddWeekDialog extends StatelessWidget {
  const AddWeekDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addWeek),
      content: const Text(AppStrings.addWeekContent),
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
          child: const Text(AppStrings.addWeek),
        ),
      ],
    );
  }
}
