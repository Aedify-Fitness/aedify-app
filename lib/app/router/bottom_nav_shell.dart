import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

//TODO: REMOVE CUSTOM IMPLEMENTATION
class _BottomNavItemData {
  const _BottomNavItemData({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;

  static const items = [
    _BottomNavItemData(label: 'HOME', iconAsset: OutlinedSvgAssets.home),
    _BottomNavItemData(label: 'LIB', iconAsset: OutlinedSvgAssets.sparkles),
    _BottomNavItemData(
      label: 'PLAN',
      iconAsset: OutlinedSvgAssets.clipboardDocumentList,
    ),
    _BottomNavItemData(
      label: 'AI',
      iconAsset: OutlinedSvgAssets.chatBubbleLeft,
    ),
    _BottomNavItemData(label: 'STATS', iconAsset: OutlinedSvgAssets.chartBar),
  ];
}

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
      // floatingActionButton: _CreateFab(
      //   onPressed: () => _showCreateMenu(context),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // void _showCreateMenu(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (_) => const _CreateMenuSheet(),
  //   );
  // }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final void Function(int) onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withAlpha(30),
            blurRadius: AppRadius.md,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_BottomNavItemData.items.length, (index) {
              final item = _BottomNavItemData.items[index];
              final selected = index == currentIndex;
              return _BottomNavItem(
                data: item,
                selected: selected,
                onTap: () => onDestinationSelected(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _BottomNavItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colorScheme.primary
        : context.colorScheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
            horizontal: AppSpacing.xxs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                data.iconAsset,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              AppWhiteSpace.hXxs,
              Text(
                data.label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class _CreateFab extends StatelessWidget {
//   const _CreateFab({required this.onPressed});

//   final VoidCallback onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//       onPressed: onPressed,
//       child: SvgPicture.asset(
//         OutlinedSvgAssets.plus,
//         width: AppSizing.iconMd,
//         height: AppSizing.iconMd,
//         colorFilter: ColorFilter.mode(
//           context.colorScheme.onPrimary,
//           BlendMode.srcIn,
//         ),
//       ),
//     );
//   }
// }

// class _CreateMenuSheet extends StatelessWidget {
//   const _CreateMenuSheet();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(AppSpacing.md),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(AppStrings.createNew, style: context.textTheme.titleMedium),
//           AppWhiteSpace.hMd,
//           ListTile(
//             leading: SvgPicture.asset(
//               OutlinedSvgAssets.sparkles,
//               width: AppSizing.iconMd,
//               height: AppSizing.iconMd,
//             ),
//             title: const Text(AppStrings.createWorkout),
//             onTap: () {
//               Navigator.of(context).pop();
//               context.pushNamed(AppRoutes.workoutBuilderCreate().name);
//             },
//           ),
//           ListTile(
//             leading: SvgPicture.asset(
//               OutlinedSvgAssets.clipboardDocumentList,
//               width: AppSizing.iconMd,
//               height: AppSizing.iconMd,
//             ),
//             title: const Text(AppStrings.createProgramme),
//             onTap: () {
//               Navigator.of(context).pop();
//               context.pushNamed(AppRoutes.programmeBuilderCreate().name);
//             },
//           ),
//           ListTile(
//             leading: SvgPicture.asset(
//               OutlinedSvgAssets.plusCircle,
//               width: AppSizing.iconMd,
//               height: AppSizing.iconMd,
//             ),
//             title: const Text(AppStrings.createCustomExercise),
//             onTap: () {
//               Navigator.of(context).pop();
//               context.pushNamed(AppRoutes.customExerciseCreate().name);
//             },
//           ),
//           AppWhiteSpace.hSm,
//         ],
//       ),
//     );
//   }
// }
