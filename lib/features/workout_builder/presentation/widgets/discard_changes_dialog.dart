import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({super.key, required this.onDiscard});

  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.unsavedChanges),
      content: Text(AppStrings.unsavedChangesMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () {
            onDiscard();
            Navigator.of(context).pop();
          },
          child: Text(AppStrings.discardChanges),
        ),
      ],
    );
  }
}
