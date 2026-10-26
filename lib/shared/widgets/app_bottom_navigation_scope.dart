import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Marks content rendered beneath Aedify's floating bottom navigation overlay.
class AppBottomNavigationScope extends InheritedWidget {
  const AppBottomNavigationScope({
    super.key,
    required super.child,
    this.bottomViewPadding = 0,
  });

  final double bottomViewPadding;

  static double contentClearance(
    BuildContext context, {
    required double fallback,
  }) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppBottomNavigationScope>();
    return scope != null
        ? AppBottomNavigationTokens.baseContentClearance +
              scope.bottomViewPadding
        : fallback;
  }

  static double floatingActionButtonLift(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppBottomNavigationScope>();
    return scope != null
        ? AppBottomNavigationTokens.height +
              AppBottomNavigationTokens.bottomMargin +
              scope.bottomViewPadding
        : 0;
  }

  static double contentClearanceWithFloatingActionButton(
    BuildContext context, {
    required double fallback,
  }) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppBottomNavigationScope>();
    return scope != null
        ? AppBottomNavigationTokens.baseContentClearance +
              scope.bottomViewPadding +
              AppSizing.cardBadge +
              AppSpacing.md
        : fallback;
  }

  @override
  bool updateShouldNotify(AppBottomNavigationScope oldWidget) {
    return bottomViewPadding != oldWidget.bottomViewPadding;
  }
}

/// Insets centered shell content so the glass overlay does not cover it.
class AppBottomNavigationContentInset extends StatelessWidget {
  const AppBottomNavigationContentInset({
    super.key,
    required this.child,
    this.fallback = 0,
  });

  final Widget child;
  final double fallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppBottomNavigationScope.contentClearance(
          context,
          fallback: fallback,
        ),
      ),
      child: child,
    );
  }
}
