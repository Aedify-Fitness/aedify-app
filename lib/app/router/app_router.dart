import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/guard/guard_state.dart';
import 'package:aedify/app/diagnostics/developer_diagnostics_screen.dart';
import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/app/router/bottom_nav_shell.dart';
import 'package:aedify/features/home/presentation/home_screen.dart';
import 'package:aedify/features/library/presentation/library_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/bootstrap/bootstrap_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/features/onboarding/presentation/onboarding_screen.dart';
import 'package:aedify/features/profile/presentation/profile_screen.dart';
import 'package:aedify/features/settings/presentation/byok_settings_screen.dart';
import 'package:aedify/features/settings/presentation/settings_screen.dart';
import 'package:aedify/features/exercise_library/presentation/custom_exercise_editor_screen.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_library_screen.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_detail_screen.dart';
import 'package:aedify/features/bodymap/presentation/bodymap_screen.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_session_view_data.dart';
import 'package:aedify/features/workout_execution/presentation/workout_runner_screen.dart';
import 'package:aedify/features/workout_execution/presentation/finish_early_session_complete_screen.dart';
import 'package:aedify/features/workout_execution/presentation/workout_complete_screen.dart';
import 'package:aedify/features/workout_builder/presentation/workout_builder_screen.dart';
import 'package:aedify/features/programmes/presentation/programmes_screen.dart';
import 'package:aedify/features/programmes/presentation/programme_builder_screen.dart';
import 'package:aedify/features/programmes/presentation/programme_calendar_screen.dart';
import 'package:aedify/features/programmes/presentation/workout_detail_screen.dart';
import 'package:aedify/features/lift_log/presentation/lift_log_screen.dart';
import 'package:aedify/features/lift_log/presentation/workout_history_detail_screen.dart';
import 'package:aedify/features/programmes/presentation/saved_workout_library_screen.dart';
import 'package:aedify/features/analytics/presentation/analytics_screen.dart';
import 'package:aedify/features/ai_trainer_chat/presentation/ai_chat_screen.dart';
import 'package:aedify/features/progress_media/presentation/progress_media_screen.dart';
import 'package:aedify/features/sharing/presentation/sharing_screen.dart';
import 'package:aedify/features/external_import/presentation/external_import_screen.dart';
import 'package:aedify/features/image_import/presentation/image_import_screen.dart';
import 'package:aedify/app/providers/providers.dart';

class AppRouter {
  AppRouter._();

  static final _draftGuardedRoutes = <String>{
    AppRoutes.chat().path,
    AppRoutes.import().path,
    AppRoutes.importImage().path,
    AppRoutes.workout().path,
    AppRoutes.programmes().path,
    AppRoutes.liftLog().path,
    AppRoutes.progress().path,
    AppRoutes.share().path,
  };

  static bool _isFlagDisabledRoute(String location, FeatureFlags flags) {
    if (!flags.aiEnabled && location == AppRoutes.chat().path) {
      return true;
    }
    if (!flags.importsEnabled &&
        (location == AppRoutes.import().path ||
            location == AppRoutes.importImage().path)) {
      return true;
    }
    if (!flags.sharingEnabled && location == AppRoutes.share().path) {
      return true;
    }
    if (!flags.progressMediaEnabled && location == AppRoutes.progress().path) {
      return true;
    }
    return false;
  }

  static final appRouterProvider = Provider<GoRouter>((ref) {
    final bootstrapState = ref.watch(AppBootstrap.controllerProvider);
    final onboardingStatusAsync = ref.watch(
      AppProviders.onboardingStatusProvider,
    );
    final aiAvailability = ref.watch(AppProviders.aiAvailabilityProvider);
    final draftGuard = ref.watch(AppProviders.draftGuardProvider);
    final featureFlags = ref.watch(AppProviders.featureFlagsProvider);

    return GoRouter(
      initialLocation: AppRoutes.initialRoute,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isOnStartup = location == AppRoutes.startup().path;

        if (bootstrapState.phase == StartupPhase.initializing ||
            bootstrapState.phase == StartupPhase.failure) {
          if (!isOnStartup) return AppRoutes.startup().path;
          return null;
        }

        if (onboardingStatusAsync.isLoading || onboardingStatusAsync.hasError) {
          if (!isOnStartup) return AppRoutes.startup().path;
          return null;
        }

        final onboardingStatus = onboardingStatusAsync.asData?.value;

        if (onboardingStatus == OnboardingStatus.complete) {
          if (isOnStartup || location == AppRoutes.onboarding().path) {
            return AppRoutes.home().path;
          }
        } else if (onboardingStatus == OnboardingStatus.incomplete) {
          if (isOnStartup) return AppRoutes.onboarding().path;
          final isOnOnboarding = location == AppRoutes.onboarding().path;
          if (!isOnOnboarding) return AppRoutes.onboarding().path;
        }

        if (AppRouter._isFlagDisabledRoute(location, featureFlags)) {
          if (!featureFlags.aiEnabled && location == AppRoutes.chat().path) {
            return AppRoutes.aiDisabled().path;
          }
          if (!featureFlags.importsEnabled &&
              (location == AppRoutes.import().path ||
                  location == AppRoutes.importImage().path)) {
            return AppRoutes.importDisabled().path;
          }
          if (!featureFlags.sharingEnabled &&
              location == AppRoutes.share().path) {
            return AppRoutes.shareDisabled().path;
          }
          if (!featureFlags.progressMediaEnabled &&
              location == AppRoutes.progress().path) {
            return AppRoutes.progressDisabled().path;
          }
        }

        if (aiAvailability == AiAvailability.missingKey &&
            location == AppRoutes.chat().path) {
          return AppRoutes.aiUnavailable().path;
        }
        if (aiAvailability == AiAvailability.unsupported &&
            location == AppRoutes.chat().path) {
          return AppRoutes.aiUnsupported().path;
        }

        if (draftGuard == DraftGuard.blockedByUnsavedDraft &&
            AppRouter._draftGuardedRoutes.contains(location)) {
          return AppRoutes.draftBlocked().path;
        }

        if (!featureFlags.diagnosticsEnabled &&
            location == AppRoutes.diagnostics().path) {
          return AppRoutes.home().path;
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
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              BottomNavShell(navigationShell: navigationShell),
          branches: [
            // Tab 0 — HOME
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home().path,
                  name: AppRoutes.home().name,
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            // Tab 1 — LIB (library hub)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.library().path,
                  name: AppRoutes.library().name,
                  builder: (context, state) => const LibraryHubScreen(),
                ),
              ],
            ),
            // Tab 2 — PLAN (programmes)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.programmes().path,
                  name: AppRoutes.programmes().name,
                  builder: (context, state) => const ProgrammesScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      name: AppRoutes.programmeBuilderCreate().name,
                      builder: (context, state) =>
                          ProgrammeBuilderScreen.create(),
                    ),
                    GoRoute(
                      path: ':id/edit',
                      name: AppRoutes.programmeBuilderEdit().name,
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return ProgrammeBuilderScreen.edit(programmeId: id);
                      },
                    ),
                    GoRoute(
                      path: ':id/duplicate',
                      name: AppRoutes.programmeBuilderDuplicate().name,
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return ProgrammeBuilderScreen.duplicate(
                          programmeId: id,
                        );
                      },
                    ),
                    GoRoute(
                      path: ':id',
                      name: AppRoutes.programmeCalendar().name,
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return ProgrammeCalendarScreen(programmeId: id);
                      },
                    ),
                    GoRoute(
                      path: ':programId/workouts/:workoutId',
                      name: AppRoutes.programmeWorkoutDetail().name,
                      builder: (context, state) {
                        final programId = state.pathParameters['programId']!;
                        final workoutId = state.pathParameters['workoutId']!;
                        return WorkoutDetailScreen(
                          programId: programId,
                          workoutId: workoutId,
                        );
                      },
                    ),
                    GoRoute(
                      path: ':programId/workouts/:workoutId/run',
                      name: AppRoutes.workoutRunnerProgramWorkout().name,
                      builder: (context, state) {
                        final programId = state.pathParameters['programId']!;
                        final workoutId = state.pathParameters['workoutId']!;
                        return WorkoutRunnerScreen.programWorkout(
                          programId: programId,
                          programWorkoutId: workoutId,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Tab 3 — AI
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.chat().path,
                  name: AppRoutes.chat().name,
                  builder: (context, state) => const AiChatScreen(),
                ),
              ],
            ),
            // Tab 4 — STATS (analytics)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.analytics().path,
                  name: AppRoutes.analytics().name,
                  builder: (context, state) => const AnalyticsScreen(),
                ),
              ],
            ),
          ],
        ),
        // Non-shell routes (no bottom nav)
        GoRoute(
          path: AppRoutes.workout().path,
          name: AppRoutes.workout().name,
          builder: (context, state) => const WorkoutRunnerScreen.resume(),
        ),
        GoRoute(
          path: AppRoutes.workoutRunnerActive().path,
          name: AppRoutes.workoutRunnerActive().name,
          builder: (context, state) => const WorkoutRunnerScreen.resume(),
        ),
        GoRoute(
          path: AppRoutes.workoutRunnerSavedWorkout().path,
          name: AppRoutes.workoutRunnerSavedWorkout().name,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return WorkoutRunnerScreen.savedWorkout(savedWorkoutId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.finishEarlySummary().path,
          name: AppRoutes.finishEarlySummary().name,
          builder: (context, state) {
            final session = state.extra as WorkoutRunnerSessionViewData;
            return FinishEarlySessionCompleteScreen(session: session);
          },
        ),
        GoRoute(
          path: AppRoutes.sessionComplete().path,
          name: AppRoutes.sessionComplete().name,
          builder: (context, state) {
            final session = state.extra as WorkoutRunnerSessionViewData;
            return WorkoutCompleteScreen(session: session);
          },
        ),
        GoRoute(
          path: AppRoutes.savedWorkoutLibrary().path,
          name: AppRoutes.savedWorkoutLibrary().name,
          builder: (context, state) => const SavedWorkoutLibraryScreen(),
        ),
        GoRoute(
          path: AppRoutes.workoutBuilderCreate().path,
          name: AppRoutes.workoutBuilderCreate().name,
          builder: (context, state) => const WorkoutBuilderScreen.create(),
        ),
        GoRoute(
          path: AppRoutes.workoutDetail().path,
          name: AppRoutes.workoutDetail().name,
          builder: (context, state) {
            final workoutId = state.pathParameters['workoutId']!;
            return WorkoutDetailScreen(workoutId: workoutId);
          },
        ),
        GoRoute(
          path: AppRoutes.workoutBuilderEdit().path,
          name: AppRoutes.workoutBuilderEdit().name,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return WorkoutBuilderScreen.edit(savedWorkoutId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.exercises().path,
          name: AppRoutes.exercises().name,
          builder: (context, state) => const ExerciseLibraryScreen(),
          routes: [
            GoRoute(
              path: ':id',
              name: AppRoutes.exerciseDetail().name,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ExerciseDetailScreen(exerciseId: id);
              },
            ),
            GoRoute(
              path: 'custom/new',
              name: AppRoutes.customExerciseCreate().name,
              builder: (context, state) =>
                  const CustomExerciseEditorScreen.create(),
            ),
            GoRoute(
              path: 'custom/:id/edit',
              name: AppRoutes.customExerciseEdit().name,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return CustomExerciseEditorScreen.edit(exerciseId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.liftLog().path,
          name: AppRoutes.liftLog().name,
          builder: (context, state) => const LiftLogScreen(),
          routes: [
            GoRoute(
              path: ':sessionId',
              name: AppRoutes.workoutHistoryDetail().name,
              builder: (context, state) {
                final sessionId = state.pathParameters['sessionId']!;
                return WorkoutHistoryDetailScreen(sessionId: sessionId);
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.bodymap().path,
          name: AppRoutes.bodymap().name,
          builder: (context, state) => const BodymapScreen(),
        ),
        GoRoute(
          path: AppRoutes.diagnostics().path,
          name: AppRoutes.diagnostics().name,
          builder: (context, state) => const DeveloperDiagnosticsScreen(),
        ),
        GoRoute(
          path: AppRoutes.aiDisabled().path,
          name: AppRoutes.aiDisabled().name,
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text(AppStrings.aiDisabled)),
            body: const Center(child: Text(AppStrings.aiDisabledMessage)),
          ),
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
          path: AppRoutes.importDisabled().path,
          name: AppRoutes.importDisabled().name,
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text(AppStrings.importDisabled)),
            body: const Center(child: Text(AppStrings.importDisabledMessage)),
          ),
        ),
        GoRoute(
          path: AppRoutes.shareDisabled().path,
          name: AppRoutes.shareDisabled().name,
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text(AppStrings.shareDisabled)),
            body: const Center(child: Text(AppStrings.shareDisabledMessage)),
          ),
        ),
        GoRoute(
          path: AppRoutes.progressDisabled().path,
          name: AppRoutes.progressDisabled().name,
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text(AppStrings.progressDisabled)),
            body: const Center(child: Text(AppStrings.progressDisabledMessage)),
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
          path: AppRoutes.profile().path,
          name: AppRoutes.profile().name,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.aiProviderSettings().path,
          name: AppRoutes.aiProviderSettings().name,
          redirect: (context, state) =>
              state.namedLocation(AppRoutes.byokSettings().name),
        ),
        GoRoute(
          path: AppRoutes.byokSettings().path,
          name: AppRoutes.byokSettings().name,
          builder: (context, state) => const ByokSettingsScreen(),
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
}
