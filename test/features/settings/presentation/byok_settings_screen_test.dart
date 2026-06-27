import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/data/drift_byok_repository.dart';
import 'package:aedify/features/settings/data/byok_repository.dart';
import 'package:aedify/features/settings/presentation/byok_settings_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import '../../../support/privacy/privacy_sentinel_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../data/fake_dependencies.dart';

class _ValidatingFakeRepository extends DriftByokRepository {
  _ValidatingFakeRepository({
    required super.configDao,
    required super.secureStorageService,
  });

  @override
  Future<bool> validateKey({
    required String providerName,
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
    required String providerName,
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
}
