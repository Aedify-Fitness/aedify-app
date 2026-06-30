import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeListTile extends StatelessWidget {
  const ProgrammeListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onArchive,
    required this.onDelete,
  });

  final ProgrammeListItem item;
  final VoidCallback onTap;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Row(
          children: [
            Expanded(child: Text(item.name)),
            if (item.active)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: SvgPicture.asset(
                  SolidSvgAssets.checkCircle,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '${item.weeksTotal ?? 0} ${AppStrings.onboardingDayPlural.toLowerCase()}, ${item.daysPerWeek ?? 0} ${AppStrings.onboardingReviewDaysPerWeek}',
        ),
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
                  Text(AppStrings.archiveProgramme),
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
                    AppStrings.deleteProgramme,
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
