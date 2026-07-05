class AppRoutes {
  final String path;
  final String name;

  AppRoutes._({required this.path, required this.name});

  static const String initialRoute = '/startup';

  factory AppRoutes.home() => AppRoutes._(path: '/', name: 'home');
  factory AppRoutes.chat() => AppRoutes._(path: '/chat', name: 'chat');
  factory AppRoutes.share() => AppRoutes._(path: '/share', name: 'share');
  factory AppRoutes.import() => AppRoutes._(path: '/import', name: 'import');
  factory AppRoutes.startup() => AppRoutes._(path: '/startup', name: 'startup');
  factory AppRoutes.workout() => AppRoutes._(path: '/workout', name: 'workout');
  factory AppRoutes.bodymap() => AppRoutes._(path: '/bodymap', name: 'bodymap');
  factory AppRoutes.liftLog() =>
      AppRoutes._(path: '/lift-log', name: 'liftLog');
  factory AppRoutes.workoutHistoryDetail() =>
      AppRoutes._(path: '/lift-log/:sessionId', name: 'workoutHistoryDetail');
  factory AppRoutes.savedWorkoutLibrary() =>
      AppRoutes._(path: '/workouts', name: 'savedWorkoutLibrary');
  factory AppRoutes.settings() =>
      AppRoutes._(path: '/settings', name: 'settings');
  factory AppRoutes.progress() =>
      AppRoutes._(path: '/progress', name: 'progress');
  factory AppRoutes.exercises() =>
      AppRoutes._(path: '/exercises', name: 'exercises');
  factory AppRoutes.analytics() =>
      AppRoutes._(path: '/analytics', name: 'analytics');
  factory AppRoutes.library() => AppRoutes._(path: '/library', name: 'library');
  factory AppRoutes.onboarding() =>
      AppRoutes._(path: '/onboarding', name: 'onboarding');
  factory AppRoutes.programmes() =>
      AppRoutes._(path: '/programmes', name: 'programmes');
  factory AppRoutes.aiDisabled() =>
      AppRoutes._(path: '/ai-disabled', name: 'aiDisabled');
  factory AppRoutes.diagnostics() =>
      AppRoutes._(path: '/diagnostics', name: 'diagnostics');
  factory AppRoutes.importImage() =>
      AppRoutes._(path: '/import-image', name: 'importImage');
  factory AppRoutes.draftBlocked() =>
      AppRoutes._(path: '/draft-blocked', name: 'draftBlocked');
  factory AppRoutes.aiUnavailable() =>
      AppRoutes._(path: '/ai-unavailable', name: 'aiUnavailable');
  factory AppRoutes.exerciseDetail() =>
      AppRoutes._(path: '/exercises/:id', name: 'exerciseDetail');
  factory AppRoutes.aiUnsupported() =>
      AppRoutes._(path: '/ai-unsupported', name: 'aiUnsupported');
  factory AppRoutes.shareDisabled() =>
      AppRoutes._(path: '/share-disabled', name: 'shareDisabled');
  factory AppRoutes.importDisabled() =>
      AppRoutes._(path: '/import-disabled', name: 'importDisabled');
  factory AppRoutes.progressDisabled() =>
      AppRoutes._(path: '/progress-disabled', name: 'progressDisabled');
  factory AppRoutes.profile() => AppRoutes._(path: '/profile', name: 'profile');
  factory AppRoutes.aiProviderSettings() =>
      AppRoutes._(path: '/settings/ai-provider', name: 'aiProviderSettings');
  factory AppRoutes.byokSettings() =>
      AppRoutes._(path: '/settings/byok', name: 'byokSettings');
  factory AppRoutes.workoutBuilderCreate() =>
      AppRoutes._(path: '/workouts/new', name: 'workoutBuilderCreate');
  factory AppRoutes.workoutBuilderEdit() =>
      AppRoutes._(path: '/workouts/:id/edit', name: 'workoutBuilderEdit');

  // Programme builder
  factory AppRoutes.programmeBuilderCreate() =>
      AppRoutes._(path: '/programmes/new', name: 'programmeBuilderCreate');
  factory AppRoutes.programmeBuilderEdit() =>
      AppRoutes._(path: '/programmes/:id/edit', name: 'programmeBuilderEdit');
  factory AppRoutes.programmeBuilderDuplicate() => AppRoutes._(
    path: '/programmes/:id/duplicate',
    name: 'programmeBuilderDuplicate',
  );

  // Workout runner
  factory AppRoutes.workoutRunnerActive() =>
      AppRoutes._(path: '/workout/active', name: 'workoutRunnerActive');
  factory AppRoutes.workoutRunnerSavedWorkout() =>
      AppRoutes._(path: '/workouts/:id/run', name: 'workoutRunnerSavedWorkout');
  factory AppRoutes.workoutRunnerProgramWorkout() => AppRoutes._(
    path: '/programmes/:programId/workouts/:workoutId/run',
    name: 'workoutRunnerProgramWorkout',
  );
  factory AppRoutes.finishEarlySummary() => AppRoutes._(
    path: '/workout/finish-early/summary',
    name: 'finishEarlySummary',
  );
  factory AppRoutes.sessionComplete() =>
      AppRoutes._(path: '/workout/summary', name: 'sessionComplete');

  // Programme calendar (read-only)
  factory AppRoutes.programmeCalendar() =>
      AppRoutes._(path: '/programmes/:id', name: 'programmeCalendar');
  factory AppRoutes.programmeWorkoutDetail() => AppRoutes._(
    path: '/programmes/:programId/workouts/:workoutId',
    name: 'programmeWorkoutDetail',
  );

  // Custom exercise editor
  factory AppRoutes.customExerciseCreate() =>
      AppRoutes._(path: '/exercises/custom/new', name: 'customExerciseCreate');

  factory AppRoutes.customExerciseEdit() => AppRoutes._(
    path: '/exercises/custom/:id/edit',
    name: 'customExerciseEdit',
  );
}
