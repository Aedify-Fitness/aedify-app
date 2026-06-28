import 'package:aedify/features/settings/presentation/widgets/settings_storage_boundary_card.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsStorageBoundaryCard', () {
    testWidgets('explains local-only profile/settings storage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SettingsStorageBoundaryCard())),
      );

      expect(find.text(AppStrings.localOnlyNotice), findsOneWidget);
    });

    testWidgets('explains secure storage for API keys', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SettingsStorageBoundaryCard())),
      );

      expect(find.text(AppStrings.secureStorageNotice), findsOneWidget);
    });
  });
}
