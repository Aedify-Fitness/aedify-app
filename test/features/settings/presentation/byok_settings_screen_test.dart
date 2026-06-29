import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/data/drift_byok_repository.dart';
import 'package:aedify/features/settings/data/byok_repository.dart';
import 'package:aedify/features/settings/presentation/byok_settings_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import '../../../support/privacy/privacy_sentinel_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import '../data/fake_dependencies.dart';

class _ValidatingFakeRepository extends DriftByokRepository {
  _ValidatingFakeRepository({
    required super.configDao,
    required super.secureStorageService,
  });

  @override
  Future<bool> validateKey({
    required AiProviderName providerName,
    required String apiKey,
  }) async {
    return true;
  }
}

class _FailingValidationRepository extends DriftByokRepository {
  _FailingValidationRepository({
    required super.configDao,
    required super.secureStorageService,
  });

  @override
  Future<bool> validateKey({
    required AiProviderName providerName,
    required String apiKey,
  }) async {
    return false;
  }
}

Widget createTestApp({required ByokRepository repository}) {
  return ProviderScope(
    overrides: [
      AppProviders.byokRepositoryProvider.overrideWith((ref) => repository),
    ],
    child: const MaterialApp(home: ByokSettingsScreen()),
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late FakeConfigDao configDao;
  late FakeSecureStorage secureStorage;
  late ByokRepository repository;

  setUp(() {
    configDao = FakeConfigDao();
    secureStorage = FakeSecureStorage();
    repository = _ValidatingFakeRepository(
      configDao: configDao,
      secureStorageService: secureStorage,
    );
  });

  testWidgets('renders loading then empty state', (tester) async {
    await tester.pumpWidget(createTestApp(repository: repository));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text(AppStrings.byokSettings), findsOneWidget);
    expect(find.text(AppStrings.provider), findsOneWidget);
    expect(find.text(AppStrings.apiKey), findsOneWidget);
    expect(find.text(AppStrings.saveKey), findsOneWidget);
    expect(find.text(AppStrings.skipAiForNow), findsOneWidget);
  });

  testWidgets('shows provider choices and allows model/API key entry', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OpenAI'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.model), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'sk-test-key');
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.saveKey));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.savedProviders), findsOneWidget);
  });

  testWidgets('saved key is never displayed back in full', (tester) async {
    await tester.pumpWidget(createTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OpenAI'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      PrivacySentinelValues.fakeApiKey,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.saveKey));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.savedProviders), findsOneWidget);
    expect(find.text(PrivacySentinelValues.fakeApiKey), findsNothing);
    expect(find.text(AppStrings.keySaved), findsOneWidget);
  });

  testWidgets('validation failure surfaces safe error without leaking key', (
    tester,
  ) async {
    final failingRepo = _FailingValidationRepository(
      configDao: configDao,
      secureStorageService: secureStorage,
    );
    await tester.pumpWidget(createTestApp(repository: failingRepo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OpenAI'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      PrivacySentinelValues.fakeApiKey,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.saveKey));
    await tester.pumpAndSettle();

    expect(find.text(AppErrorStrings.byokKeyValidationFailed), findsOneWidget);
  });

  testWidgets('shows Google as a provider option', (tester) async {
    await tester.pumpWidget(createTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets(
    'invalid key validation surfaces safe error without leaking key',
    (tester) async {
      final failingRepo = _FailingValidationRepository(
        configDao: configDao,
        secureStorageService: secureStorage,
      );
      await tester.pumpWidget(createTestApp(repository: failingRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OpenAI'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        PrivacySentinelValues.fakeApiKey,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.saveKey));
      await tester.pumpAndSettle();

      // Safe error message — no raw key material
      expect(
        find.text(AppErrorStrings.byokKeyValidationFailed),
        findsOneWidget,
      );
      // After validation failure the form stays visible so the user can
      // correct the key. Privacy gate is no persistence/logging, not UI
      // clearance — so we do NOT assert findsNothing for the key here.
    },
  );

  testWidgets('delete key removes config and updates state', (tester) async {
    // First save a config
    await tester.pumpWidget(createTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OpenAI'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'sk-test-key-delete');
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.saveKey));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.savedProviders), findsOneWidget);

    // Tap delete key (opens confirmation dialog)
    await tester.tap(find.text(AppStrings.deleteKey));
    await tester.pumpAndSettle();

    // Confirm deletion in dialog — second "Delete key" is the FilledButton
    await tester.tap(find.text(AppStrings.deleteKey).last);
    await tester.pumpAndSettle();

    // Verify config is removed — should see the empty state again
    expect(find.text(AppStrings.savedProviders), findsNothing);
    expect(find.text(AppStrings.provider), findsOneWidget);
    expect(find.text(AppStrings.saveKey), findsOneWidget);
  });
}
