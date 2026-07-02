import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';

class ArchiveItemDialog extends StatelessWidget {
  const ArchiveItemDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmLabel,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;
  final String? confirmLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(AppStrings.cancel),
        ),
        const SizedBox(width: AppSpacing.sm),
        FilledButton(
          onPressed: () {
            onConfirm();
            context.pop();
          },
          child: Text(confirmLabel ?? AppStrings.archiveProgramme),
        ),
      ],
    );
  }
}
