import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SupersetActionsMenu extends StatelessWidget {
  const SupersetActionsMenu({
    super.key,
    required this.isGrouped,
    required this.onCreateSuperset,
    required this.onRemoveFromSuperset,
    required this.onDeleteSuperset,
  });

  final bool isGrouped;
  final VoidCallback onCreateSuperset;
  final VoidCallback onRemoveFromSuperset;
  final VoidCallback onDeleteSuperset;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: AppSizing.fieldWidthLg * 2),
      onSelected: (value) {
        switch (value) {
          case 'create':
            onCreateSuperset();
          case 'remove':
            onRemoveFromSuperset();
          case 'delete':
            onDeleteSuperset();
        }
      },
      itemBuilder: (context) => [
        if (!isGrouped)
          PopupMenuItem(
            value: 'create',
            child: Text(AppStrings.createSuperset),
          ),
        if (isGrouped) ...[
          PopupMenuItem(
            value: 'remove',
            child: Text(AppStrings.removeFromSuperset),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text(AppStrings.deleteSuperset),
          ),
        ],
      ],
      child: IconButton(
        icon: SvgPicture.asset(
          OutlinedSvgAssets.ellipsisVertical,
          width: AppSizing.iconMd,
          height: AppSizing.iconMd,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onSurface.withValues(alpha: 0.38),
            BlendMode.srcIn,
          ),
        ),
        onPressed: null,
      ),
    );
  }
}
