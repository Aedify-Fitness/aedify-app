class AppRoutes {
  final String path;
  final String name;

  AppRoutes._({required this.path, required this.name});

  static const String initialRoute = '/onboarding';

  factory AppRoutes.home() => AppRoutes._(path: '/', name: 'home');
  factory AppRoutes.chat() => AppRoutes._(path: '/chat', name: 'chat');
  factory AppRoutes.share() => AppRoutes._(path: '/share', name: 'share');
  factory AppRoutes.import() => AppRoutes._(path: '/import', name: 'import');
  factory AppRoutes.workout() => AppRoutes._(path: '/workout', name: 'workout');
  factory AppRoutes.liftLog() =>
      AppRoutes._(path: '/lift-log', name: 'liftLog');
  factory AppRoutes.settings() =>
      AppRoutes._(path: '/settings', name: 'settings');
  factory AppRoutes.progress() =>
      AppRoutes._(path: '/progress', name: 'progress');
  factory AppRoutes.exercises() =>
      AppRoutes._(path: '/exercises', name: 'exercises');
  factory AppRoutes.analytics() =>
      AppRoutes._(path: '/analytics', name: 'analytics');
  factory AppRoutes.onboarding() =>
      AppRoutes._(path: '/onboarding', name: 'onboarding');
  factory AppRoutes.programmes() =>
      AppRoutes._(path: '/programmes', name: 'programmes');
  factory AppRoutes.importImage() =>
      AppRoutes._(path: '/import-image', name: 'importImage');
}
