import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/features/onboarding/presentation/onboarding_screen.dart';
import 'package:aedify/features/settings/presentation/settings_screen.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_library_screen.dart';
import 'package:aedify/features/workout_execution/presentation/workout_execution_screen.dart';
import 'package:aedify/features/programmes/presentation/programmes_screen.dart';
import 'package:aedify/features/lift_log/presentation/lift_log_screen.dart';
import 'package:aedify/features/analytics/presentation/analytics_screen.dart';
import 'package:aedify/features/ai_trainer_chat/presentation/ai_chat_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_media_screen.dart';
import 'package:aedify/features/sharing/presentation/sharing_screen.dart';
import 'package:aedify/features/external_import/presentation/external_import_screen.dart';
import 'package:aedify/features/image_import/presentation/image_import_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.initialRoute,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding().path,
        name: AppRoutes.onboarding().name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home().path,
        name: AppRoutes.home().name,
        builder: (context, state) => const ProgrammesScreen(),
      ),
      GoRoute(
        path: AppRoutes.exercises().path,
        name: AppRoutes.exercises().name,
        builder: (context, state) => const ExerciseLibraryScreen(),
      ),
      GoRoute(
        path: AppRoutes.workout().path,
        name: AppRoutes.workout().name,
        builder: (context, state) => const WorkoutExecutionScreen(),
      ),
      GoRoute(
        path: AppRoutes.programmes().path,
        name: AppRoutes.programmes().name,
        builder: (context, state) => const ProgrammesScreen(),
      ),
      GoRoute(
        path: AppRoutes.liftLog().path,
        name: AppRoutes.liftLog().name,
        builder: (context, state) => const LiftLogScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics().path,
        name: AppRoutes.analytics().name,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat().path,
        name: AppRoutes.chat().name,
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.progress().path,
        name: AppRoutes.progress().name,
        builder: (context, state) => const ProgressMediaScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings().path,
        name: AppRoutes.settings().name,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.share().path,
        name: AppRoutes.share().name,
        builder: (context, state) => const SharingScreen(),
      ),
      GoRoute(
        path: AppRoutes.import().path,
        name: AppRoutes.import().name,
        builder: (context, state) => const ExternalImportScreen(),
      ),
      GoRoute(
        path: AppRoutes.importImage().path,
        name: AppRoutes.importImage().name,
        builder: (context, state) => const ImageImportScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text(AppStrings.pageNotFound)),
      body: const Center(child: Text(AppStrings.pageNotFoundMessage)),
    ),
  );
});
