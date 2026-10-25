import 'dart:io';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/secure_storage_service.dart';
import 'package:aedify/features/settings/data/provider_key_validator.dart';
import 'package:aedify/features/settings/presentation/byok_settings_screen.dart';
import 'package:aedify/features/settings/presentation/provider_capability_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../test/support/settings/provider_metadata_adapter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'BYOK save, model edit, capability navigation/refresh and delete',
    (tester) async {
      final directory = await Directory(
        (await getTemporaryDirectory()).path,
      ).createTemp('aedify_m3_ui_');
      final db = AppDatabase(
        NativeDatabase(File(p.join(directory.path, 'settings.sqlite'))),
      );
      final adapter = ProviderMetadataAdapter();
      final secure = SecureStorageService();
      final container = ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          AppProviders.secureStorageProvider.overrideWithValue(secure),
          AppProviders.providerKeyValidatorProvider.overrideWithValue(
            ProviderKeyValidator(dio: adapter.client()),
          ),
        ],
      );
      final router = GoRouter(
        initialLocation: AppRoutes.byokSettings().path,
        routes: [
          GoRoute(
            path: AppRoutes.byokSettings().path,
            name: AppRoutes.byokSettings().name,
            builder: (_, _) => const ByokSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.providerCapabilities().path,
            name: AppRoutes.providerCapabilities().name,
            builder: (_, state) => ProviderCapabilityScreen(
              providerName: state.pathParameters['provider']!,
              modelName: state.pathParameters['model']!,
            ),
          ),
        ],
      );
      addTearDown(() async {
        for (final row in await db.select(db.aiProviderConfigs).get()) {
          await secure.deleteProviderApiKey(row.secureKeyAlias);
        }
        router.dispose();
        container.dispose();
        await db.close();
        await directory.delete(recursive: true);
      });
      Widget app(ThemeMode mode) => UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          routerConfig: router,
        ),
      );
      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(app(ThemeMode.light));
      await tester.pumpAndSettle();
      await tap(find.byKey(const ValueKey('byok-provider-openai')));
      final field = find.descendant(
        of: find.byKey(const ValueKey('byok-api-key-field')),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(field);
      await tester.enterText(field, 'synthetic-ui-key');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tap(find.text(AppStrings.saveKey));
      final repository = container.read(AppProviders.byokRepositoryProvider);
      final id = (await repository.getConfigs()).single.id;
      expect(await secure.readProviderApiKey(id), 'synthetic-ui-key');
      expect(find.text('synthetic-ui-key'), findsNothing);

      await tester.pumpWidget(app(ThemeMode.dark));
      await tester.pumpAndSettle();
      await tap(find.byKey(ValueKey('byok-edit-$id')));
      await tap(find.byKey(const ValueKey('byok-model-gpt-4o-mini')));
      await tap(find.text(AppStrings.saveKey));
      final configs = await repository.getConfigs();
      expect(configs, hasLength(1));
      expect(configs.single.selectedModel, 'gpt-4o-mini');
      expect(await secure.readProviderApiKey(id), 'synthetic-ui-key');

      await tap(find.byKey(ValueKey('byok-capabilities-$id')));
      expect(
        GoRouterState.of(
          tester.element(find.byType(ProviderCapabilityScreen)),
        ).name,
        AppRoutes.providerCapabilities().name,
      );
      final screen = tester.widget<ProviderCapabilityScreen>(
        find.byType(ProviderCapabilityScreen),
      );
      expect(screen.providerName, 'openai');
      expect(screen.modelName, 'gpt-4o-mini');
      expect(find.text(AppStrings.providerCapabilityTitle), findsWidgets);
      expect(
        find.byKey(const ValueKey('provider-capability-text-input-available')),
        findsOneWidget,
      );
      final before = adapter.requests.length;
      await tap(find.text(AppStrings.refreshCapabilities));
      expect(adapter.requests.length, before + 1);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tap(find.byKey(ValueKey('byok-delete-$id')));
      await tap(find.widgetWithText(FilledButton, AppStrings.deleteKey));
      expect(await repository.getConfigs(), isEmpty);
      expect(await secure.readProviderApiKey(id), isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
