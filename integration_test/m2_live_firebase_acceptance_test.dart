import 'package:aedify/core/firebase/firebase_storage_client.dart';
import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_download_service.dart';
import 'dart:io';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/network/network_status.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/firebase_options.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:drift/native.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'M2 live Firebase first sync, unchanged manifest and offline library',
    (tester) async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final root = await Directory(
        (await getTemporaryDirectory()).path,
      ).createTemp('aedify_m2_');
      final file = File(p.join(root.path, 'library.sqlite'));
      var db = AppDatabase(NativeDatabase(file));
      final network = _AcceptanceNetworkStatus();
      ProviderContainer create() => ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
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
      if (state.phase != ExerciseDatasetSyncPhase.synced) {
        try {
          await FirebaseStorageClient().getText(
            ExerciseDatasetDownloadService.manifestRemotePath,
          );
        } on FirebaseStorageFailure catch (failure) {
          fail('Live dataset access failed: ${failure.code}');
        }
      }
      expect(
        state.phase,
        ExerciseDatasetSyncPhase.synced,
        reason: state.failure?.code,
      );
      expect(state.exerciseCount, greaterThan(0));
      final before = await db
          .customSelect('SELECT id, updated_at FROM exercises ORDER BY id')
          .get();
      await sync.refresh().timeout(const Duration(minutes: 1));
      final after = await db
          .customSelect('SELECT id, updated_at FROM exercises ORDER BY id')
          .get();
      expect(
        after.map((row) => row.data).toList(),
        before.map((row) => row.data).toList(),
      );
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
