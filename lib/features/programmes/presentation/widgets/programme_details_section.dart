import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeDetailsSection extends StatelessWidget {
  const ProgrammeDetailsSection({
    super.key,
    required this.nameController,
    required this.onNameChanged,
    this.descriptionController,
    this.onDescriptionChanged,
  });

  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;
  final TextEditingController? descriptionController;
  final ValueChanged<String>? onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.programmeDetailsSectionTitle,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: AppStrings.programmeName,
            hintText: AppStrings.programmeNameHint,
          ),
          onChanged: onNameChanged,
        ),
        if (descriptionController != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: AppStrings.notes,
              hintText: AppStrings.optionalDescription,
            ),
            onChanged: onDescriptionChanged,
            maxLines: 2,
          ),
        ],
      ],
    );
  }
}
