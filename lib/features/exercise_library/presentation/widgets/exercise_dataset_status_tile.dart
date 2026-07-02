import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class ExerciseDatasetStatusTile extends StatelessWidget {
  const ExerciseDatasetStatusTile({
    super.key,
    required this.libraryVersion,
    required this.schemaVersion,
    required this.exerciseCount,
    required this.syncStatusLabel,
  });

  final String? libraryVersion;
  final int? schemaVersion;
  final int? exerciseCount;
  final String syncStatusLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            AppStrings.exerciseLibraryStatus,
            style: context.textTheme.titleSmall,
          ),
        ),
        _RowInfo(
          label: AppStrings.exerciseLibraryVersion,
          value: libraryVersion ?? '--',
        ),
        _RowInfo(
          label: AppStrings.exerciseLibrarySchemaVersion,
          value: schemaVersion?.toString() ?? '--',
        ),
        _RowInfo(
          label: AppStrings.exerciseLibraryExerciseCount,
          value: exerciseCount?.toString() ?? '--',
        ),
        _RowInfo(
          label: AppStrings.exerciseLibrarySyncStatus,
          value: syncStatusLabel,
        ),
        Divider(height: AppSizing.divider),
      ],
    );
  }
}

class _RowInfo extends StatelessWidget {
  const _RowInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          Text(value, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}
