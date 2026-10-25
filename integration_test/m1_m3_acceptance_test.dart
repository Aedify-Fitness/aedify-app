import '../test/support/exercise_library/native_dataset_fixture.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_detail_screen.dart';
import 'dart:io';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/network/network_status.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/core/storage/preference_key.dart';
import 'package:aedify/core/storage/preferences_service.dart';
import 'package:aedify/core/storage/secure_storage_service.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/onboarding/presentation/onboarding_screen.dart';
import 'package:aedify/features/settings/data/provider_key_validator.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/provider_operation_type.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../test/support/settings/provider_metadata_adapter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M1 native storage and M3 onboarding/BYOK persist safely', (
    tester,
  ) async {
    final root = await Directory(
      (await getTemporaryDirectory()).path,
    ).createTemp('aedify_m1_m3_');
    final file = File(p.join(root.path, 'acceptance.sqlite'));
    final db = AppDatabase(NativeDatabase(file));
    final files = LocalFileStore(basePath: root.path);
    final secure = SecureStorageService();
    final preferences = PreferencesService();
    final previousTab = await preferences.getString(
      PreferenceKey.lastSelectedTab,
    );
    final adapter = ProviderMetadataAdapter();
    final network = _AcceptanceNetworkStatus();
    final container = ProviderContainer(
      overrides: [
        AppProviders.appDatabaseProvider.overrideWithValue(db),
        AppProviders.localFileStoreProvider.overrideWithValue(files),
        AppProviders.secureStorageProvider.overrideWithValue(secure),
        AppProviders.networkStatusProvider.overrideWithValue(network),
        AppProviders.providerKeyValidatorProvider.overrideWithValue(
          ProviderKeyValidator(dio: adapter.client()),
        ),
      ],
    );
    final configIds = <String>[];
    const alias = 'aedify-native-acceptance-synthetic';
    addTearDown(() async {
      for (final id in configIds) {
        await secure.deleteProviderApiKey(id);
      }
      await secure.deleteProviderApiKey(alias);
      if (previousTab == null) {
        await preferences.remove(PreferenceKey.lastSelectedTab);
      } else {
        await preferences.setString(PreferenceKey.lastSelectedTab, previousTab);
      }
      container.dispose();
      network.dispose();
      await db.close();
      await root.delete(recursive: true);
    });
    await db.readiness();
    await files.ensureCoreDirectories();
    final marker = await files.fileAt(FileCategory.temp, 'writable.txt');
    await marker.writeAsString('synthetic');
    expect(await marker.readAsString(), 'synthetic');
    await secure.saveProviderApiKey(alias, 'synthetic-key-one');
    expect(
      await SecureStorageService().readProviderApiKey(alias),
      'synthetic-key-one',
    );
    await secure.rotateProviderApiKey(alias, 'synthetic-key-two');
    expect(await secure.readProviderApiKey(alias), 'synthetic-key-two');
    await secure.deleteProviderApiKey(alias);
    expect(await secure.readProviderApiKey(alias), isNull);
    await preferences.setString(PreferenceKey.lastSelectedTab, 'acceptance');
    expect(
      await PreferencesService().getString(PreferenceKey.lastSelectedTab),
      'acceptance',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> tap(String label) async {
      final target = find.widgetWithText(FilledButton, label);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    await tap(AppStrings.onboardingInitializeSpace);
    await tap(AppStrings.continueLabel);
    await tester.ensureVisible(find.text(AppStrings.onboardingExperienceAdept));
    await tester.tap(find.text(AppStrings.onboardingExperienceAdept));
    await tester.pumpAndSettle();
    await tap(AppStrings.continueLabel);
    for (final day in [
      TrainingDay.monday,
      TrainingDay.wednesday,
      TrainingDay.friday,
    ]) {
      final target = find.text(day.displayLabel).first;
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }
    for (var step = 0; step < 5; step++) {
      await tap(AppStrings.continueLabel);
    }
    await tap(AppStrings.finishSetup);
    expect(
      await container
          .read(AppProviders.onboardingRepositoryProvider)
          .isOnboardingCompleted(),
      isTrue,
    );
    expect(
      await container.read(AppProviders.byokRepositoryProvider).getConfigs(),
      isEmpty,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    final repository = container.read(AppProviders.byokRepositoryProvider);
    final capabilities = container.read(
      AppProviders.providerCapabilityRepositoryProvider,
    );
    for (final pair in [
      (AiProviderName.openai, 'gpt-4o'),
      (AiProviderName.anthropic, 'claude-sonnet-4-6'),
      (AiProviderName.google, 'gemini-2.5-pro'),
    ]) {
      final id = await repository.saveConfig(
        ByokEditDraft(
          providerName: pair.$1,
          selectedModel: pair.$2,
          apiKey: 'synthetic-provider-key',
        ),
      );
      configIds.add(id);
      expect(
        await SecureStorageService().readProviderApiKey(id),
        'synthetic-provider-key',
      );
      expect(
        (await capabilities.getCapability(
          providerName: pair.$1,
          modelName: pair.$2,
        ))!.supportsTextInput,
        isTrue,
      );
      expect(
        (await container
                .read(AppProviders.providerGateServiceProvider)
                .evaluate(operation: ProviderOperationType.aiWorkoutGeneration))
            .isAllowed,
        isTrue,
      );
      await repository.rotateKey(
        configId: id,
        providerName: pair.$1,
        newApiKey: 'synthetic-rotated-key',
      );
      expect(await secure.readProviderApiKey(id), 'synthetic-rotated-key');
      adapter.status = 401;
      await expectLater(
        repository.rotateKey(
          configId: id,
          providerName: pair.$1,
          newApiKey: 'synthetic-invalid-key',
        ),
        throwsA(isA<ProviderValidationFailure>()),
      );
      expect(await secure.readProviderApiKey(id), 'synthetic-rotated-key');
      adapter.status = 200;
      await container
          .read(AppProviders.providerCapabilityRefreshServiceProvider)
          .refresh(providerName: pair.$1, modelName: pair.$2);
      await repository.deleteConfig(id);
      expect(await secure.readProviderApiKey(id), isNull);
    }
    final rows = await db
        .customSelect('SELECT * FROM ai_provider_configs')
        .get();
    expect(rows, isEmpty);
    final second = AppDatabase(NativeDatabase(file));
    expect(
      (await second.select(second.userProfile).get())
          .single
          .onboardingCompleted,
      isTrue,
    );
    await second.close();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'M2 fixture transport sync, unchanged manifest and offline library',
    (tester) async {
      final storage = NativeDatasetStorageFixture();
      final auth = NativeDatasetAuthFixture();
      final root = await Directory(
        (await getTemporaryDirectory()).path,
      ).createTemp('aedify_m2_');
      final file = File(p.join(root.path, 'library.sqlite'));
      var db = AppDatabase(NativeDatabase(file));
      final network = _AcceptanceNetworkStatus();
      ProviderContainer create() => ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          AppProviders.firebaseAuthServiceProvider.overrideWithValue(auth),
          AppProviders.firebaseStorageClientProvider.overrideWithValue(storage),
          AppProviders.localFileStoreProvider.overrideWithValue(
            LocalFileStore(basePath: root.path),
          ),
          AppProviders.networkStatusProvider.overrideWithValue(network),
        ],
      );
      var container = create();
      addTearDown(() async {
        container.dispose();
        network.dispose();
        await db.close();
        await root.delete(recursive: true);
      });
      var sync = container.read(
        AppProviders.exerciseDatasetSyncControllerProvider.notifier,
      );
      await sync.initialize().timeout(const Duration(minutes: 2));
      var state = container
          .read(AppProviders.exerciseDatasetSyncControllerProvider)
          .requireValue;
      expect(state.phase, ExerciseDatasetSyncPhase.synced);
      expect(state.exerciseCount, 4);
      final before = await db
          .customSelect('SELECT id, updated_at FROM exercises ORDER BY id')
          .get();
      await sync.refresh();
      final after = await db
          .customSelect('SELECT id, updated_at FROM exercises ORDER BY id')
          .get();
      expect(
        after.map((row) => row.data).toList(),
        before.map((row) => row.data).toList(),
      );
      expect(storage.downloadCount, 1);
      container.dispose();
      await db.close();
      network.online = false;
      db = AppDatabase(NativeDatabase(file));
      container = create();
      sync = container.read(
        AppProviders.exerciseDatasetSyncControllerProvider.notifier,
      );
      await sync.refresh();
      state = container
          .read(AppProviders.exerciseDatasetSyncControllerProvider)
          .requireValue;
      expect(state.phase, ExerciseDatasetSyncPhase.synced);
      expect(state.isOffline, isTrue);
      final repository = container.read(
        AppProviders.exerciseRepositoryProvider,
      );
      for (final modality in ExerciseModality.values) {
        final matches = await repository.searchExercises(
          ExerciseFilterState(modality: modality),
        );
        expect(matches, isNotEmpty, reason: modality.name);
        final detail = await repository.getExerciseDetail(matches.first.id);
        expect(detail!.name, matches.first.name);
        final searched = await repository.searchExercises(
          ExerciseFilterState(searchQuery: matches.first.name),
        );
        expect(searched.map((e) => e.id), contains(matches.first.id));
      }
      final items = await repository.searchExercises(
        const ExerciseFilterState(),
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ExerciseDetailScreen(exerciseId: items.first.id),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(items.first.name), findsWidgets);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

class _AcceptanceNetworkStatus extends NetworkStatus {
  bool online = true;
  @override
  bool get isOnline => online;
  @override
  Future<bool> check() async => online;
}
