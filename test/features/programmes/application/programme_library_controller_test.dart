import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/features/programmes/domain/programme_aggregate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProgrammeRepository implements ProgrammeRepository {
  _FakeProgrammeRepository({this.shouldThrow = false});

  final bool shouldThrow;
  final programmes = <ProgrammeAggregate>[];
  String? lastArchivedId;
  String? lastDeletedId;

  @override
  Future<ProgrammeAggregate?> getProgramme(String id) async => null;

  @override
  Future<List<ProgrammeAggregate>> listProgrammes({
    String? status,
    bool activeOnly = false,
  }) async {
    if (shouldThrow) throw Exception('Database error');
    return programmes;
  }

  @override
  Future<String> saveProgramme(dynamic draft) async => '';

  @override
  Future<void> archiveProgramme(String id) async {
    lastArchivedId = id;
  }

  @override
  Future<void> deleteProgramme(String id) async {
    lastDeletedId = id;
  }

  @override
  Future<void> activateProgramme(String id) async {}

  @override
  Future<void> deactivateProgramme(String id) async {}
}

ProgrammeAggregate _makeAggregate({
  String id = 'p1',
  String name = 'Test Programme',
  bool active = true,
  int? weeksTotal = 4,
  int? daysPerWeek = 3,
}) {
  return ProgrammeAggregate(
    program: Program(
      id: id,
      name: name,
      description: null,
      source: 'manual',
      creationMethod: 'manual',
      importOrigin: null,
      status: 'active',
      active: active,
      startDateLocal: null,
      endDateLocal: null,
      weeksTotal: weeksTotal,
      daysPerWeek: daysPerWeek,
      sessionLengthMinutes: null,
      goalTagsJson: '[]',
      equipmentJson: '[]',
      experienceLevelAtCreation: null,
      preferredUnitsAtCreation: null,
      periodisationModel: null,
      trainingStyle: null,
      referenceStrategy: null,
      blockType: null,
      progressionRulesJson: null,
      deloadRulesJson: null,
      warmupPolicyJson: null,
      fatigueManagementJson: null,
      aiGenerationSnapshotId: null,
      aiOutputSchemaVersion: null,
      imported: false,
      importedAt: null,
      importSourceFileType: null,
      importReviewStatus: null,
      sourceFileRetained: false,
      shareSchemaVersion: null,
      externalShareId: null,
      exportPrivacyMode: null,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 6, 30),
      archivedAt: null,
      deletedAt: null,
    ),
    templates: [],
    weeks: [],
    workouts: [],
    exercises: [],
    sets: [],
    revisions: [],
  );
}

void main() {
  group('ProgrammeLibraryController', () {
    ProviderContainer createContainer({bool shouldThrow = false}) {
      return ProviderContainer(
        overrides: [
          AppProviders.programmeRepositoryProvider.overrideWith(
            (ref) => _FakeProgrammeRepository(shouldThrow: shouldThrow),
          ),
        ],
      );
    }

    test('initial state is empty when no programmes', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.programmeLibraryControllerProvider.notifier,
      );
      final state = await controller.future;

      expect(state.items, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorCode, isNull);
    });

    test('loads programmes from repository', () async {
      final container = createContainer();
      final repo =
          container.read(AppProviders.programmeRepositoryProvider)
              as _FakeProgrammeRepository;

      repo.programmes.add(_makeAggregate());

      final controller = container.read(
        AppProviders.programmeLibraryControllerProvider.notifier,
      );
      // Trigger reload to fetch updated list
      await controller.reload();
      final state = container
          .read(AppProviders.programmeLibraryControllerProvider)
          .requireValue;

      expect(state.items.length, equals(1));
      expect(state.items[0].name, equals('Test Programme'));
      expect(state.items[0].active, isTrue);
    });

    test('archiveProgramme calls repository', () async {
      final container = createContainer();
      final repo =
          container.read(AppProviders.programmeRepositoryProvider)
              as _FakeProgrammeRepository;

      await container
          .read(AppProviders.programmeLibraryControllerProvider.notifier)
          .archiveProgramme('p1');

      expect(repo.lastArchivedId, equals('p1'));
    });

    test('deleteProgramme calls repository', () async {
      final container = createContainer();
      final repo =
          container.read(AppProviders.programmeRepositoryProvider)
              as _FakeProgrammeRepository;

      await container
          .read(AppProviders.programmeLibraryControllerProvider.notifier)
          .deleteProgramme('p1');

      expect(repo.lastDeletedId, equals('p1'));
    });

    test('handles load failure gracefully', () async {
      final container = createContainer(shouldThrow: true);
      final controller = container.read(
        AppProviders.programmeLibraryControllerProvider.notifier,
      );
      final state = await controller.future;

      expect(state.errorCode, isNotNull);
      expect(state.items, isEmpty);
    });
  });
}
