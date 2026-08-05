import 'dart:ui';

import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/widgets/app_bottom_navigation_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class _BottomNavItemData {
  const _BottomNavItemData({
    required this.label,
    required this.iconAsset,
    required this.selectedIconAsset,
  });

  final String label;
  final String iconAsset;
  final String selectedIconAsset;

  static const items = [
    _BottomNavItemData(
      label: AppStrings.home,
      iconAsset: OutlinedSvgAssets.home,
      selectedIconAsset: SolidSvgAssets.home,
    ),
    _BottomNavItemData(
      label: AppStrings.navLibrary,
      iconAsset: OutlinedSvgAssets.bookOpen,
      selectedIconAsset: SolidSvgAssets.bookOpen,
    ),
    _BottomNavItemData(
      label: AppStrings.navPlan,
      iconAsset: OutlinedSvgAssets.clipboardDocumentList,
      selectedIconAsset: SolidSvgAssets.clipboardDocumentList,
    ),
    _BottomNavItemData(
      label: AppStrings.navAi,
      iconAsset: OutlinedSvgAssets.chatBubbleLeft,
      selectedIconAsset: SolidSvgAssets.chatBubbleLeft,
    ),
    _BottomNavItemData(
      label: AppStrings.navStats,
      iconAsset: OutlinedSvgAssets.chartBar,
      selectedIconAsset: SolidSvgAssets.chartBar,
    ),
  ];
}

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('bottom_navigation_shell_scaffold'),
      extendBody: true,
      body: AppBottomNavigationScope(
        bottomViewPadding: MediaQuery.viewPaddingOf(context).bottom,
        child: navigationShell,
      ),
      bottomNavigationBar: _FloatingNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _FloatingNavigationBar extends StatelessWidget {
  const _FloatingNavigationBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final surfaceColor =
        (Theme.brightnessOf(context) == Brightness.dark
                ? cs.surfaceContainerLow
                : cs.surfaceContainerLowest)
            .withValues(
              alpha: AppBottomNavigationTokens.surfaceOpacity(context),
            );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppBottomNavigationTokens.horizontalMargin,
          right: AppBottomNavigationTokens.horizontalMargin,
          bottom: AppBottomNavigationTokens.bottomMargin,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(
                  alpha: AppBottomNavigationTokens.shadowOpacity,
                ),
                blurRadius: AppSpacing.xl,
                offset: const Offset(0, AppSpacing.sm),
              ),
            ],
          ),
          child: ClipRRect(
            key: const ValueKey<String>('bottom_navigation_glass_clip'),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: BackdropFilter(
              key: const ValueKey<String>('bottom_navigation_glass_blur'),
              filter: ImageFilter.blur(
                sigmaX: AppBottomNavigationTokens.blurSigma,
                sigmaY: AppBottomNavigationTokens.blurSigma,
              ),
              child: DecoratedBox(
                key: const ValueKey<String>('bottom_navigation_glass_surface'),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border.all(
                    color: cs.outlineVariant.withValues(
                      alpha: AppBottomNavigationTokens.borderOpacity,
                    ),
                    width: AppBottomNavigationTokens.borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: NavigationBar(
                  key: const ValueKey<String>('bottom_navigation_bar'),
                  height: AppBottomNavigationTokens.height,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  destinations: [
                    for (final item in _BottomNavItemData.items)
                      NavigationDestination(
                        icon: _NavIcon(asset: item.iconAsset, selected: false),
                        selectedIcon: _NavIcon(
                          asset: item.selectedIconAsset,
                          selected: true,
                        ),
                        label: item.label,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.asset, required this.selected});

  final String asset;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final color = selected
        ? (Theme.brightnessOf(context) == Brightness.dark
              ? cs.onPrimaryContainer
              : cs.onSecondaryContainer)
        : cs.onSurfaceVariant;
    return SvgPicture.asset(
      asset,
      width: AppSizing.iconMd,
      height: AppSizing.iconMd,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
