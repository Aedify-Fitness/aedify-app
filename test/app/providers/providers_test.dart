import 'dart:async';
import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/firebase/firebase_bootstrap.dart';
import 'package:aedify/core/network/network_status.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_controller.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';

void main() {
  group('Provider overrides', () {
    test(
      'bootstrap controller reads overridden firebaseBootstrapProvider',
      () async {
        final fakeFirebase = _FakeFirebaseBootstrap();
        final container = ProviderContainer(
          overrides: [
            AppProviders.firebaseBootstrapProvider.overrideWithValue(
              fakeFirebase,
            ),
            AppProviders.appDatabaseProvider.overrideWithValue(
              _FakeAppDatabase(),
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

        expect(fakeFirebase.initializedCalled, true);
        expect(
          container.read(AppBootstrap.controllerProvider).phase,
          StartupPhase.success,
        );
      },
    );

    test('no dependency is hardcoded - firebase override works', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.firebaseBootstrapProvider.overrideWithValue(
            _FakeFirebaseBootstrap(shouldThrow: true),
          ),
          AppProviders.appDatabaseProvider.overrideWithValue(
            _FakeAppDatabase(),
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

      expect(
        container.read(AppBootstrap.controllerProvider).phase,
        StartupPhase.failure,
      );
    });

    test('overrides can inject all fakes', () async {
      final container = ProviderContainer(
        overrides: [
          AppProviders.firebaseBootstrapProvider.overrideWithValue(
            _FakeFirebaseBootstrap(),
          ),
          AppProviders.appDatabaseProvider.overrideWithValue(
            _FakeAppDatabase(),
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
  bool initializedCalled = false;
  final bool shouldThrow;

  _FakeFirebaseBootstrap({this.shouldThrow = false});

  @override
  Future<void> initialize() async {
    if (shouldThrow) throw Exception('Firebase init failed');
    initializedCalled = true;
  }

  @override
  Future<bool> get isInitialized async => !shouldThrow;
}

class _FakeAppDatabase implements AppDatabase {
  const _FakeAppDatabase();

  @override
  Future<void> readiness() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocalFileStore implements LocalFileStore {
  const _FakeLocalFileStore();

  @override
  Future<void> ensureCoreDirectories() async {}

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
