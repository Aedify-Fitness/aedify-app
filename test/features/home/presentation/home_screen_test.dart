import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/profile/application/profile_controller.dart';
import 'package:aedify/features/programmes/application/programme_library_controller.dart';
import 'package:aedify/features/programmes/application/programme_library_state.dart';
import 'package:aedify/features/programmes/application/today_workout_resolver.dart';
import 'package:aedify/features/programmes/domain/programme_aggregate.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/features/home/presentation/home_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedProfileController extends ProfileController {
  _FixedProfileController(this.value);

  final ProfileState value;

  @override
  Future<ProfileState> build() async => value;
}

class _FixedProgrammeLibraryController extends ProgrammeLibraryController {
  _FixedProgrammeLibraryController(this.value);

  final ProgrammeLibraryState value;

  @override
  Future<ProgrammeLibraryState> build() async => value;
}

class _HomeTestFixtures {
  _HomeTestFixtures._();

  static Widget app({
    required ProgrammeLibraryState programmeState,
    ProgrammeSync? sync,
  }) {
    return ProviderScope(
      overrides: [
        AppProviders.profileControllerProvider.overrideWith(
          () => _FixedProfileController(const ProfileState(isLoading: false)),
        ),
        AppProviders.programmeLibraryControllerProvider.overrideWith(
          () => _FixedProgrammeLibraryController(programmeState),
        ),
        AppProviders.activeWorkoutSessionProvider.overrideWith(
          (ref) async => null,
        ),
        if (sync != null)
          AppProviders.programmeSyncProvider.overrideWith(
            (ref, id) async => sync,
          ),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  static ProgrammeListItem activeProgramme() {
    return ProgrammeListItem(
      id: 'programme-1',
      name: 'Strength Base',
      status: ProgramStatus.active,
      active: true,
      weeksTotal: 4,
      daysPerWeek: 3,
      updatedAt: DateTime(2026, 7, 24),
    );
  }

  static ProgrammeSync scheduledWorkoutSync() {
    final timestamp = DateTime(2026, 7, 24);
    return ProgrammeSync(
      aggregate: ProgrammeAggregate(
        program: Program(
          id: 'programme-1',
          name: 'Strength Base',
          source: 'manual',
          creationMethod: 'manual',
          status: 'active',
          active: true,
          weeksTotal: 4,
          daysPerWeek: 3,
          goalTagsJson: '[]',
          equipmentJson: '[]',
          imported: false,
          sourceFileRetained: false,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
        templates: [
          ProgramWorkoutTemplate(
            id: 'template-1',
            programId: 'programme-1',
            templateKey: 'upper-a',
            name: 'Upper Body A',
            estimatedDurationMinutes: 45,
            sortOrder: 0,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        ],
        weeks: const [
          ProgramWeek(id: 'week-1', programId: 'programme-1', weekNumber: 1),
        ],
        workouts: [
          ProgramWorkout(
            id: 'workout-1',
            programId: 'programme-1',
            programWeekId: 'week-1',
            workoutTemplateId: 'template-1',
            occurrenceRef: 'week-1-day-1',
            name: 'Upper Body A',
            scheduledDayIndex: 0,
            status: 'planned',
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        ],
        exercises: const [],
        sets: const [],
        revisions: const [],
      ),
      resolution: const TodayWorkoutResolution(
        todayWorkoutId: 'workout-1',
        todayFlatIndex: 0,
        completedWorkoutIds: {},
      ),
    );
  }
}

void main() {
  group('HomeScreen', () {
    testWidgets('guides the user when no programme is active', (tester) async {
      await tester.pumpWidget(
        _HomeTestFixtures.app(
          programmeState: const ProgrammeLibraryState(
            items: [],
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noActiveProgramme), findsOneWidget);
      expect(find.text(AppStrings.noActiveProgrammeHint), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, AppStrings.browseProgrammes),
        findsOneWidget,
      );
    });

    testWidgets('makes the scheduled workout Start CTA dominant', (
      tester,
    ) async {
      final programme = _HomeTestFixtures.activeProgramme();
      await tester.pumpWidget(
        _HomeTestFixtures.app(
          programmeState: ProgrammeLibraryState(
            items: [programme],
            isLoading: false,
          ),
          sync: _HomeTestFixtures.scheduledWorkoutSync(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('home_scheduled_workout_panel')),
        findsOneWidget,
      );
      expect(find.text('Upper Body A'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, AppStrings.startWorkout),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home_start_workout_button')),
        findsOneWidget,
      );
    });
  });
}
