import 'package:aedify/shared/constants/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class M4RouteDriver {
  const M4RouteDriver();

  Future<void> goToSavedWorkouts({
    required WidgetTester tester,
    required GoRouter router,
  }) async {
    router.goNamed(AppRoutes.savedWorkoutLibrary().name);
    await tester.pump();
    await tester.pump();
  }

  Future<void> goToLiftLog({
    required WidgetTester tester,
    required GoRouter router,
  }) async {
    router.goNamed(AppRoutes.liftLog().name);
    await tester.pump();
    await tester.pump();
  }

  Future<void> goToWorkoutBuilderCreate({
    required WidgetTester tester,
    required GoRouter router,
  }) async {
    router.goNamed(AppRoutes.workoutBuilderCreate().name);
    await tester.pump();
    await tester.pump();
  }

  Future<void> goToProgrammeBuilderCreate({
    required WidgetTester tester,
    required GoRouter router,
  }) async {
    router.goNamed(AppRoutes.programmeBuilderCreate().name);
    await tester.pump();
    await tester.pump();
  }
}
