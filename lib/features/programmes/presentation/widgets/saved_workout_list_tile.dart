import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class SavedWorkoutListTile extends StatelessWidget {
  const SavedWorkoutListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onArchive,
    required this.onDelete,
  });

  final SavedWorkoutListItem item;
  final VoidCallback onTap;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('${item.exerciseCount} ${AppStrings.exercisesSelected}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'archive':
                onArchive();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  SvgPicture.asset(
                    OutlinedSvgAssets.archiveBox,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(AppStrings.archiveWorkout),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  SvgPicture.asset(
                    OutlinedSvgAssets.trash,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.error,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    AppStrings.deleteWorkout,
                    style: TextStyle(color: context.colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
