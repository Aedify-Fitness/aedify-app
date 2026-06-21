import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/bootstrap/bootstrap_screen.dart';
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
import 'package:aedify/app/providers/providers.dart';

final _draftGuardedRoutes = <String>{
  AppRoutes.chat().path,
  AppRoutes.import().path,
  AppRoutes.importImage().path,
  AppRoutes.workout().path,
  AppRoutes.programmes().path,
  AppRoutes.liftLog().path,
  AppRoutes.progress().path,
  AppRoutes.share().path,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  final bootstrapState = ref.watch(AppBootstrap.controllerProvider);
  final onboardingStatus = ref.watch(onboardingStatusProvider);
  final aiAvailability = ref.watch(aiAvailabilityProvider);
  final draftGuard = ref.watch(draftGuardProvider);

  return GoRouter(
    initialLocation: AppRoutes.initialRoute,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isOnStartup = location == AppRoutes.startup().path;

      // 1. Bootstrap guard — always first
      if (bootstrapState.phase == StartupPhase.initializing ||
          bootstrapState.phase == StartupPhase.failure) {
        if (!isOnStartup) return AppRoutes.startup().path;
        return null;
      }

      if (isOnStartup) return AppRoutes.onboarding().path;

      // 2. Onboarding guard
      if (onboardingStatus == OnboardingStatus.incomplete) {
        final isOnOnboarding = location == AppRoutes.onboarding().path;
        if (!isOnOnboarding) return AppRoutes.onboarding().path;
      }

      // 3. AI availability guard (chat only)
      if (aiAvailability == AiAvailability.missingKey &&
          location == AppRoutes.chat().path) {
        return AppRoutes.aiUnavailable().path;
      }
      if (aiAvailability == AiAvailability.unsupported &&
          location == AppRoutes.chat().path) {
        return AppRoutes.aiUnsupported().path;
      }

      // 4. Unsaved draft guard (broad strict blocking)
      if (draftGuard == DraftGuard.blockedByUnsavedDraft &&
          _draftGuardedRoutes.contains(location)) {
        return AppRoutes.draftBlocked().path;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.startup().path,
        name: AppRoutes.startup().name,
        builder: (context, state) => const BootstrapScreen(),
      ),
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
        path: AppRoutes.aiUnavailable().path,
        name: AppRoutes.aiUnavailable().name,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text(AppStrings.aiUnavailable)),
          body: const Center(child: Text(AppStrings.aiUnavailableMessage)),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiUnsupported().path,
        name: AppRoutes.aiUnsupported().name,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text(AppStrings.aiUnsupported)),
          body: const Center(child: Text(AppStrings.aiUnsupportedMessage)),
        ),
      ),
      GoRoute(
        path: AppRoutes.draftBlocked().path,
        name: AppRoutes.draftBlocked().name,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text(AppStrings.draftBlocked)),
          body: const Center(child: Text(AppStrings.draftBlockedMessage)),
        ),
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
