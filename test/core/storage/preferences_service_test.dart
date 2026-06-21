import 'package:aedify/core/storage/preference_key.dart';
import 'package:aedify/core/storage/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesService', () {
    late PreferencesService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = PreferencesService(prefs: prefs);
    });

    test('setString and getString round-trip', () async {
      await service.setString(PreferenceKey.onboardingCompleted, 'true');
      final value = await service.getString(PreferenceKey.onboardingCompleted);
      expect(value, equals('true'));
    });

    test('getString returns null for missing key', () async {
      final value = await service.getString(PreferenceKey.lastSelectedTab);
      expect(value, isNull);
    });

    test('setBool and getBool round-trip', () async {
      await service.setBool(PreferenceKey.onboardingCompleted, true);
      final value = await service.getBool(PreferenceKey.onboardingCompleted);
      expect(value, isTrue);
    });

    test('setInt and getInt round-trip', () async {
      await service.setInt(PreferenceKey.lastSelectedTab, 42);
      final value = await service.getInt(PreferenceKey.lastSelectedTab);
      expect(value, equals(42));
    });

    test('remove clears key', () async {
      await service.setString(PreferenceKey.onboardingCompleted, 'true');
      await service.remove(PreferenceKey.onboardingCompleted);
      final value = await service.getString(PreferenceKey.onboardingCompleted);
      expect(value, isNull);
    });

    test('preference keys are correctly mapped', () async {
      await service.setString(PreferenceKey.themeMode, 'dark');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('dark'));
    });

    test('preference key allowlist matches non-critical supported keys', () {
      expect(
        PreferenceKey.values.map((key) => key.key).toSet(),
        equals({
          'onboarding_completed',
          'has_seen_onboarding_intro',
          'last_selected_tab',
          'theme_mode',
          'last_opened_library_filter',
          'feature_flag_overrides',
        }),
      );
    });
  });
}
