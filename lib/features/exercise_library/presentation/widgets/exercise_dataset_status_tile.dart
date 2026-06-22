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
        _row(
          context,
          AppStrings.exerciseLibraryVersion,
          libraryVersion ?? '--',
        ),
        _row(
          context,
          AppStrings.exerciseLibrarySchemaVersion,
          schemaVersion?.toString() ?? '--',
        ),
        _row(
          context,
          AppStrings.exerciseLibraryExerciseCount,
          exerciseCount?.toString() ?? '--',
        ),
        _row(context, AppStrings.exerciseLibrarySyncStatus, syncStatusLabel),
        Divider(height: AppSizing.divider),
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value) {
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
