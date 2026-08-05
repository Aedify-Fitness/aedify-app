import 'package:aedify/app/router/bottom_nav_shell.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/widgets/app_bottom_navigation_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _TestDestination {
  const _TestDestination(this.path, this.label);

  final String path;
  final String label;

  static const values = [
    _TestDestination('/home', AppStrings.home),
    _TestDestination('/library', AppStrings.navLibrary),
    _TestDestination('/plan', AppStrings.navPlan),
    _TestDestination('/ai', AppStrings.navAi),
    _TestDestination('/stats', AppStrings.navStats),
  ];
}

class _TestBranchScreen extends StatelessWidget {
  const _TestBranchScreen({required this.label, this.showFab = false});

  final String label;
  final bool showFab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        key: ValueKey<String>('scroll_$label'),
        padding: EdgeInsets.only(
          bottom: AppBottomNavigationScope.contentClearance(
            context,
            fallback: 0,
          ),
        ),
        children: [
          const SizedBox(height: 900),
          Text(label, key: ValueKey<String>('last_$label')),
        ],
      ),
      floatingActionButton: showFab
          ? Padding(
              padding: EdgeInsets.only(
                bottom: AppBottomNavigationScope.floatingActionButtonLift(
                  context,
                ),
              ),
              child: FloatingActionButton(
                key: const ValueKey<String>('shell_test_fab'),
                onPressed: () {},
                child: const Text('+'),
              ),
            )
          : null,
    );
  }
}

class _BottomNavShellTestHarness {
  _BottomNavShellTestHarness._();

  static GoRouter router() {
    return GoRouter(
      initialLocation: _TestDestination.values.first.path,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return BottomNavShell(navigationShell: navigationShell);
          },
          branches: [
            for (var index = 0; index < _TestDestination.values.length; index++)
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: _TestDestination.values[index].path,
                    builder: (context, state) => _TestBranchScreen(
                      label: _TestDestination.values[index].label,
                      showFab: index == 0,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  static Widget app({
    required GoRouter router,
    ThemeData? theme,
    bool highContrast = false,
    TextScaler textScaler = TextScaler.noScaling,
    double bottomSafeArea = 0,
  }) {
    return MaterialApp.router(
      theme: theme ?? AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        final bottomInset = EdgeInsets.only(bottom: bottomSafeArea);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            highContrast: highContrast,
            textScaler: textScaler,
            padding: bottomInset,
            viewPadding: bottomInset,
          ),
          child: child!,
        );
      },
    );
  }

  static void useSurface(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
}

void main() {
  group('BottomNavShell', () {
    testWidgets('renders a clipped theme-aware glass overlay', (tester) async {
      _BottomNavShellTestHarness.useSurface(tester);
      final router = _BottomNavShellTestHarness.router();
      addTearDown(router.dispose);

      await tester.pumpWidget(_BottomNavShellTestHarness.app(router: router));
      await tester.pumpAndSettle();

      final shellScaffold = tester.widget<Scaffold>(
        find.byKey(const ValueKey<String>('bottom_navigation_shell_scaffold')),
      );
      final surface = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey<String>('bottom_navigation_glass_surface')),
      );
      final decoration = surface.decoration as BoxDecoration;
      final border = decoration.border! as Border;

      expect(shellScaffold.extendBody, isTrue);
      expect(
        find.byKey(const ValueKey<String>('bottom_navigation_glass_clip')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('bottom_navigation_glass_blur')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(
            const ValueKey<String>('bottom_navigation_glass_clip'),
          ),
          matching: find.byKey(
            const ValueKey<String>('bottom_navigation_glass_blur'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        decoration.color,
        AppTheme.lightTheme.colorScheme.surfaceContainerLowest.withValues(
          alpha: AppBottomNavigationTokens.lightSurfaceOpacity,
        ),
      );
      expect(border.top.width, AppBottomNavigationTokens.borderWidth);
      expect(
        border.top.color,
        AppTheme.lightTheme.colorScheme.outlineVariant.withValues(
          alpha: AppBottomNavigationTokens.borderOpacity,
        ),
      );
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('uses dark and high-contrast surface opacities', (
      tester,
    ) async {
      _BottomNavShellTestHarness.useSurface(tester);
      final router = _BottomNavShellTestHarness.router();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _BottomNavShellTestHarness.app(
          router: router,
          theme: AppTheme.darkTheme,
        ),
      );
      await tester.pumpAndSettle();

      DecoratedBox surface() => tester.widget<DecoratedBox>(
        find.byKey(const ValueKey<String>('bottom_navigation_glass_surface')),
      );
      double surfaceOpacity() =>
          ((surface().decoration as BoxDecoration).color!).a;

      expect(
        (surface().decoration as BoxDecoration).color,
        AppTheme.darkTheme.colorScheme.surfaceContainerLow.withValues(
          alpha: AppBottomNavigationTokens.darkSurfaceOpacity,
        ),
      );

      await tester.pumpWidget(
        _BottomNavShellTestHarness.app(
          router: router,
          theme: AppTheme.darkTheme,
          highContrast: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        surfaceOpacity(),
        closeTo(AppBottomNavigationTokens.highContrastSurfaceOpacity, 0.001),
      );
    });

    testWidgets('preserves destination navigation and selected state', (
      tester,
    ) async {
      _BottomNavShellTestHarness.useSurface(tester);
      final router = _BottomNavShellTestHarness.router();
      addTearDown(router.dispose);

      await tester.pumpWidget(_BottomNavShellTestHarness.app(router: router));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.navPlan));
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.path,
        _TestDestination.values[2].path,
      );
      expect(
        tester
            .widget<NavigationBar>(
              find.byKey(const ValueKey<String>('bottom_navigation_bar')),
            )
            .selectedIndex,
        2,
      );
    });

    testWidgets('keeps five destinations usable on a compact large-text view', (
      tester,
    ) async {
      _BottomNavShellTestHarness.useSurface(tester, size: const Size(320, 568));
      final router = _BottomNavShellTestHarness.router();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _BottomNavShellTestHarness.app(
          router: router,
          textScaler: const TextScaler.linear(2),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
      for (final destination in find.byType(NavigationDestination).evaluate()) {
        final size = tester.getSize(find.byWidget(destination.widget));
        expect(size.width, greaterThanOrEqualTo(44));
        expect(size.height, greaterThanOrEqualTo(44));
      }
    });

    testWidgets('respects safe area and clears final scroll content and FAB', (
      tester,
    ) async {
      _BottomNavShellTestHarness.useSurface(tester);
      final router = _BottomNavShellTestHarness.router();
      addTearDown(router.dispose);
      const bottomSafeArea = 24.0;

      await tester.pumpWidget(
        _BottomNavShellTestHarness.app(
          router: router,
          bottomSafeArea: bottomSafeArea,
        ),
      );
      await tester.pumpAndSettle();

      final navigationBar = find.byKey(
        const ValueKey<String>('bottom_navigation_bar'),
      );
      final expectedBottomGap =
          AppBottomNavigationTokens.bottomMargin + bottomSafeArea;
      expect(
        tester.view.physicalSize.height -
            tester.getBottomRight(navigationBar).dy,
        expectedBottomGap,
      );

      final listView = find.byKey(const ValueKey<String>('scroll_Home'));
      final scrollable = find
          .descendant(of: listView, matching: find.byType(Scrollable))
          .first;
      final lastItem = find.byKey(const ValueKey<String>('last_Home'));
      final scrollableState = tester.state<ScrollableState>(scrollable);
      scrollableState.position.jumpTo(scrollableState.position.maxScrollExtent);
      await tester.pump();

      expect(
        tester.getBottomRight(lastItem).dy,
        closeTo(
          tester.getTopLeft(navigationBar).dy -
              AppBottomNavigationTokens.contentBreathingSpace,
          1,
        ),
      );
      expect(
        tester
            .getBottomRight(
              find.byKey(const ValueKey<String>('shell_test_fab')),
            )
            .dy,
        lessThan(tester.getTopLeft(navigationBar).dy),
      );
    });
  });
}
