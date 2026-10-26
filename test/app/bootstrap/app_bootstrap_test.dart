import 'dart:async';
import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/firebase/firebase_bootstrap.dart';
import 'package:aedify/core/network/network_status.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_controller.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('BootstrapController', () {
    test('succeeds when Firebase/DB/file-store succeed', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.firebaseBootstrapProvider.overrideWithValue(
            _FakeFirebaseBootstrap(),
          ),
          AppProviders.appDatabaseProvider.overrideWith(
            (ref) => AppDatabase(NativeDatabase.memory()),
          ),
          AppProviders.localFileStoreProvider.overrideWithValue(
            _FakeLocalFileStore(),
          ),
          AppProviders.networkStatusProvider.overrideWithValue(
            _FakeNetworkStatus(isOnline: true),
          ),
          AppProviders.exerciseDatasetSyncControllerProvider.overrideWith(
            () => _FakeSyncController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        AppBootstrap.controllerProvider.notifier,
      );
      expect(
        container.read(AppBootstrap.controllerProvider).phase,
        StartupPhase.initializing,
      );

      await controller.start();

      final state = container.read(AppBootstrap.controllerProvider);
      expect(state.phase, StartupPhase.success);
      expect(state.isOffline, false);
    });

    test('fails when Firebase throws', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.firebaseBootstrapProvider.overrideWithValue(
            _FakeFirebaseBootstrap(shouldThrow: true),
          ),
          AppProviders.appDatabaseProvider.overrideWith(
            (ref) => AppDatabase(NativeDatabase.memory()),
          ),
          AppProviders.localFileStoreProvider.overrideWithValue(
            _FakeLocalFileStore(),
          ),
          AppProviders.networkStatusProvider.overrideWithValue(
            _FakeNetworkStatus(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        AppBootstrap.controllerProvider.notifier,
      );
      await controller.start();

      final state = container.read(AppBootstrap.controllerProvider);
      expect(state.phase, StartupPhase.failure);
      expect(state.failure, isNotNull);
      expect(state.failure!.retryable, true);
    });

    test('fails when DB readiness throws', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.firebaseBootstrapProvider.overrideWithValue(
            _FakeFirebaseBootstrap(),
          ),
          AppProviders.appDatabaseProvider.overrideWithValue(
            _FakeAppDatabase(shouldThrow: true),
          ),
          AppProviders.localFileStoreProvider.overrideWithValue(
            _FakeLocalFileStore(),
          ),
          AppProviders.networkStatusProvider.overrideWithValue(
            _FakeNetworkStatus(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        AppBootstrap.controllerProvider.notifier,
      );
      await controller.start();

      final state = container.read(AppBootstrap.controllerProvider);
      expect(state.phase, StartupPhase.failure);
      expect(state.failure, isNotNull);
    });

    test('fails when file-store init throws', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.firebaseBootstrapProvider.overrideWithValue(
            _FakeFirebaseBootstrap(),
          ),
          AppProviders.appDatabaseProvider.overrideWith(
            (ref) => AppDatabase(NativeDatabase.memory()),
          ),
          AppProviders.localFileStoreProvider.overrideWithValue(
            _FakeLocalFileStore(shouldThrow: true),
          ),
          AppProviders.networkStatusProvider.overrideWithValue(
            _FakeNetworkStatus(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        AppBootstrap.controllerProvider.notifier,
      );
      await controller.start();

      final state = container.read(AppBootstrap.controllerProvider);
      expect(state.phase, StartupPhase.failure);
      expect(state.failure, isNotNull);
    });

    test('treats offline/network failure as non-blocking', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.firebaseBootstrapProvider.overrideWithValue(
            _FakeFirebaseBootstrap(),
          ),
          AppProviders.appDatabaseProvider.overrideWith(
            (ref) => AppDatabase(NativeDatabase.memory()),
          ),
          AppProviders.localFileStoreProvider.overrideWithValue(
            _FakeLocalFileStore(),
          ),
          AppProviders.networkStatusProvider.overrideWithValue(
            _FakeNetworkStatus(isOnline: false),
          ),
          AppProviders.exerciseDatasetSyncControllerProvider.overrideWith(
            () => _FakeSyncController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        AppBootstrap.controllerProvider.notifier,
      );
      await controller.start();

      final state = container.read(AppBootstrap.controllerProvider);
      expect(state.phase, StartupPhase.success);
      expect(state.isOffline, true);
    });

    test('retry transitions correctly', () async {
      final fakeFirebase = _FakeFirebaseBootstrap(shouldThrow: true);
      final container = ProviderContainer(
        overrides: [
          AppProviders.firebaseBootstrapProvider.overrideWithValue(
            fakeFirebase,
          ),
          AppProviders.appDatabaseProvider.overrideWith(
            (ref) => AppDatabase(NativeDatabase.memory()),
          ),
          AppProviders.localFileStoreProvider.overrideWithValue(
            _FakeLocalFileStore(),
          ),
          AppProviders.networkStatusProvider.overrideWithValue(
            _FakeNetworkStatus(),
          ),
          AppProviders.exerciseDatasetSyncControllerProvider.overrideWith(
            () => _FakeSyncController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        AppBootstrap.controllerProvider.notifier,
      );

      await controller.start();
      expect(
        container.read(AppBootstrap.controllerProvider).phase,
        StartupPhase.failure,
      );

      fakeFirebase.shouldThrow = false;
      await controller.retry();

      expect(
        container.read(AppBootstrap.controllerProvider).phase,
        StartupPhase.success,
      );
    });
  });
}

class _FakeSyncController extends ExerciseDatasetSyncController {
  @override
  Future<ExerciseDatasetSyncState> build() async {
    return const ExerciseDatasetSyncState(
      phase: ExerciseDatasetSyncPhase.synced,
      exerciseCount: 0,
    );
  }

  @override
  Future<void> initialize() async {}
}

class _FakeFirebaseBootstrap implements FirebaseBootstrap {
  bool shouldThrow;

  _FakeFirebaseBootstrap({this.shouldThrow = false});

  @override
  Future<void> initialize() async {
    if (shouldThrow) throw Exception('Firebase init failed');
  }

  @override
  Future<bool> get isInitialized async => !shouldThrow;
}

class _FakeAppDatabase implements AppDatabase {
  final bool shouldThrow;

  _FakeAppDatabase({this.shouldThrow = false});

  @override
  Future<void> readiness() async {
    if (shouldThrow) throw Exception('DB readiness failed');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocalFileStore implements LocalFileStore {
  final bool shouldThrow;

  _FakeLocalFileStore({this.shouldThrow = false});

  @override
  Future<void> ensureCoreDirectories() async {
    if (shouldThrow) throw Exception('File store init failed');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNetworkStatus implements NetworkStatus {
  final bool _isOnline;

  _FakeNetworkStatus({bool isOnline = true}) : _isOnline = isOnline;

  @override
  Future<bool> check() async => _isOnline;

  @override
  bool get isOnline => _isOnline;

  @override
  Stream<bool> get onStatusChanged => const Stream.empty();

  @override
  void dispose() {}
}
