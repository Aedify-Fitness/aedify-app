import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';

enum ThemeModeSetting {
  system(displayLabel: AppStrings.system, materialThemeMode: ThemeMode.system),
  light(displayLabel: AppStrings.light, materialThemeMode: ThemeMode.light),
  dark(displayLabel: AppStrings.dark, materialThemeMode: ThemeMode.dark);

  final String displayLabel;
  final ThemeMode materialThemeMode;

  const ThemeModeSetting({
    required this.displayLabel,
    required this.materialThemeMode,
  });

  String? get dbValue {
    switch (this) {
      case ThemeModeSetting.system:
        return null;
      case ThemeModeSetting.light:
        return 'light';
      case ThemeModeSetting.dark:
        return 'dark';
    }
  }

  static ThemeModeSetting fromDb(String? value) {
    switch (value) {
      case 'light':
        return ThemeModeSetting.light;
      case 'dark':
        return ThemeModeSetting.dark;
      default:
        return ThemeModeSetting.system;
    }
  }
}
