import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/theme_mode_setting.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class AedifyApp extends ConsumerWidget {
  const AedifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(AppRouter.appRouterProvider);
    final settingsAsync = ref.watch(AppProviders.settingsControllerProvider);
    final themeMode =
        settingsAsync.asData?.value.viewData?.themeMode ??
        ThemeModeSetting.system;
    return MaterialApp.router(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.materialThemeMode,
      routerConfig: router,
    );
  }
}
