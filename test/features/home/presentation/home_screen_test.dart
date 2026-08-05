import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/home/presentation/home_screen.dart';
import 'package:aedify/features/profile/application/profile_controller.dart';
import 'package:aedify/features/programmes/application/programme_library_controller.dart';
import 'package:aedify/features/programmes/application/programme_library_state.dart';
import 'package:aedify/features/programmes/application/today_workout_resolver.dart';
import 'package:aedify/features/programmes/domain/programme_aggregate.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/widgets/app_bottom_navigation_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  static void useFixedMobileSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  static Widget app({
    required ProgrammeLibraryState programmeState,
    ProgrammeSync? sync,
    ThemeData? theme,
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
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
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

  static ProgrammeSync restDaySync() {
    final scheduled = scheduledWorkoutSync();
    return ProgrammeSync(
      aggregate: scheduled.aggregate,
      resolution: const TodayWorkoutResolution(
        todayFlatIndex: 1,
        completedWorkoutIds: {},
      ),
    );
  }

  static ProgrammeSync emptyProgrammeSync() {
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
        templates: const [],
        weeks: const [],
        workouts: const [],
        exercises: const [],
        sets: const [],
        revisions: const [],
      ),
      resolution: const TodayWorkoutResolution(completedWorkoutIds: {}),
    );
  }
}

void main() {
  group('HomeScreen', () {
    testWidgets('guides the user when no programme is active', (tester) async {
      _HomeTestFixtures.useFixedMobileSurface(tester);
      await tester.pumpWidget(
        _HomeTestFixtures.app(
          programmeState: const ProgrammeLibraryState(
            items: [],
            isLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final panel = find.byKey(const Key('home_no_programme_panel'));
      final workoutSurface = find.byKey(const Key('home_workout_surface'));
      expect(panel, findsOneWidget);
      expect(
        tester.getSize(workoutSurface).height,
        greaterThanOrEqualTo(AppSizing.homeWorkoutHeroMinHeight),
      );
      expect(
        find.descendant(
          of: panel,
          matching: find.text(AppStrings.scheduledToday.toUpperCase()),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: panel,
          matching: find.text(AppStrings.noActiveProgramme),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: panel,
          matching: find.text(AppStrings.noActiveProgrammeHint),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home_browse_programmes_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('home_start_workout_button')), findsNothing);
      expect(
        find.byKey(const Key('home_view_workout_details_button')),
        findsNothing,
      );
      expect(find.byType(FloatingActionButton), findsNothing);
      final homeList = tester.widget<ListView>(
        find.byKey(const Key('home_scroll_view')),
      );
      expect(
        (homeList.padding! as EdgeInsets).bottom,
        AppBottomNavigationScope.contentClearance(
          tester.element(find.byKey(const Key('home_scroll_view'))),
          fallback: AppSizing.navBarHeight + AppSpacing.xxl,
        ),
      );
    });

    testWidgets('makes the scheduled workout Start CTA dominant', (
      tester,
    ) async {
      _HomeTestFixtures.useFixedMobileSurface(tester);
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

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byKey(const Key('home_active_programme_panel')),
        120,
        scrollable: scrollable,
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('home_workout_surface')),
        120,
        scrollable: scrollable,
      );

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

    testWidgets(
      'orders the truthful home composition from signals to actions',
      (tester) async {
        _HomeTestFixtures.useFixedMobileSurface(tester);
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
          tester.getTopLeft(find.byKey(const Key('home_greeting_header'))).dy,
          AppSizing.homeContentTopOffset,
        );

        const orderedSectionKeys = [
          'home_greeting_header',
          'home_plateau_signal',
          'home_volume_signal',
          'home_active_programme_panel',
          'home_workout_surface',
          'home_quick_actions',
        ];
        for (var index = 0; index < orderedSectionKeys.length; index++) {
          final keyValue = orderedSectionKeys[index];
          final section = find.byKey(Key(keyValue));
          await tester.scrollUntilVisible(
            section,
            120,
            scrollable: find.byType(Scrollable).first,
          );
          if (keyValue == 'home_workout_surface') {
            expect(
              tester.getSize(section).height,
              greaterThanOrEqualTo(AppSizing.homeWorkoutHeroMinHeight),
            );
            expect(
              find.descendant(of: section, matching: find.text('45 min')),
              findsOneWidget,
            );
            expect(
              find.descendant(
                of: section,
                matching: find.text('0 ${AppStrings.exercisesCompleted}'),
              ),
              findsOneWidget,
            );
            expect(
              find.descendant(
                of: section,
                matching: find.text(AppStrings.viewDetails),
              ),
              findsOneWidget,
            );
            expect(
              find.descendant(
                of: section,
                matching: find.text(AppStrings.startWorkout),
              ),
              findsOneWidget,
            );
            final startButton = find.byKey(
              const Key('home_start_workout_button'),
            );
            final playIcon = find
                .descendant(of: startButton, matching: find.byType(SvgPicture))
                .first;
            expect(
              tester.getCenter(playIcon).dx,
              greaterThan(
                tester
                    .getCenter(
                      find.descendant(
                        of: startButton,
                        matching: find.text(AppStrings.startWorkout),
                      ),
                    )
                    .dx,
              ),
            );
          }
          if (keyValue == 'home_active_programme_panel') {
            expect(
              find.descendant(
                of: section,
                matching: find.text(
                  AppStrings.activeProgramLabel.toUpperCase(),
                ),
              ),
              findsOneWidget,
            );
            expect(
              find.descendant(
                of: section,
                matching: find.text('Strength Base'),
              ),
              findsOneWidget,
            );
            expect(
              find.descendant(
                of: section,
                matching: find.text(AppStrings.weekOf(1, 4)),
              ),
              findsOneWidget,
            );
            expect(
              find.descendant(
                of: section,
                matching: find.text(AppStrings.sessionsRemainingThisWeek(1)),
              ),
              findsOneWidget,
            );
            final progressIndicator = tester.widget<LinearProgressIndicator>(
              find.descendant(
                of: section,
                matching: find.byType(LinearProgressIndicator),
              ),
            );
            expect(progressIndicator.value, 0.25);
          }
          if (keyValue == 'home_quick_actions') {
            expect(
              find.descendant(
                of: section,
                matching: find.text(AppStrings.generateWorkout),
              ),
              findsOneWidget,
            );
            final actionSize = tester.getSize(
              find.byKey(const Key('home_generate_workout_action')),
            );
            expect(actionSize.width, 171);
            expect(actionSize.height, 171);
            expect(find.byType(FloatingActionButton), findsNothing);
            expect(
              find.descendant(
                of: section,
                matching: find.text(AppStrings.manualLog),
              ),
              findsOneWidget,
            );
            expect(
              find.descendant(
                of: section,
                matching: find.text(AppStrings.logBodyweight),
              ),
              findsOneWidget,
            );
            expect(
              find.descendant(
                of: section,
                matching: find.text(AppStrings.progressPhoto),
              ),
              findsOneWidget,
            );
          }
          if (index > 0) {
            final previousSection = find.byKey(
              Key(orderedSectionKeys[index - 1]),
            );
            expect(
              tester.getTopLeft(section).dy,
              greaterThan(tester.getTopLeft(previousSection).dy),
              reason:
                  '${orderedSectionKeys[index]} should follow '
                  '${orderedSectionKeys[index - 1]}',
            );
          }
        }
      },
    );

    testWidgets('does not show empty active programmes as complete', (
      tester,
    ) async {
      _HomeTestFixtures.useFixedMobileSurface(tester);
      final programme = _HomeTestFixtures.activeProgramme();
      await tester.pumpWidget(
        _HomeTestFixtures.app(
          programmeState: ProgrammeLibraryState(
            items: [programme],
            isLoading: false,
          ),
          sync: _HomeTestFixtures.emptyProgrammeSync(),
        ),
      );
      await tester.pumpAndSettle();

      final panel = find.byKey(const Key('home_active_programme_panel'));
      await tester.scrollUntilVisible(
        panel,
        120,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(AppStrings.weekOf(1, 4)), findsOneWidget);
      expect(
        find.text(AppStrings.sessionsRemainingThisWeek(0)),
        findsOneWidget,
      );
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.descendant(
          of: panel,
          matching: find.byType(LinearProgressIndicator),
        ),
      );
      expect(progressIndicator.value, 0);
    });

    testWidgets('shows no workout today below the active programme', (
      tester,
    ) async {
      _HomeTestFixtures.useFixedMobileSurface(tester);
      final programme = _HomeTestFixtures.activeProgramme();
      await tester.pumpWidget(
        _HomeTestFixtures.app(
          programmeState: ProgrammeLibraryState(
            items: [programme],
            isLoading: false,
          ),
          sync: _HomeTestFixtures.restDaySync(),
        ),
      );
      await tester.pumpAndSettle();

      final activeProgrammePanel = find.byKey(
        const Key('home_active_programme_panel'),
      );
      final workoutSurface = find.byKey(const Key('home_workout_surface'));
      final noWorkoutPanel = find.byKey(const Key('home_no_workout_panel'));
      await tester.scrollUntilVisible(
        workoutSurface,
        120,
        scrollable: find.byType(Scrollable).first,
      );

      expect(noWorkoutPanel, findsOneWidget);
      expect(
        find.descendant(
          of: noWorkoutPanel,
          matching: find.text(AppStrings.rest.toUpperCase()),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: noWorkoutPanel,
          matching: find.text(AppStrings.noWorkoutToday),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: noWorkoutPanel,
          matching: find.text(AppStrings.noWorkoutTodayMessage),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: noWorkoutPanel,
          matching: find.text('Strength Base'),
        ),
        findsNothing,
      );
      expect(
        tester.getTopLeft(activeProgrammePanel).dy,
        lessThan(tester.getTopLeft(workoutSurface).dy),
      );
      expect(
        find.byKey(const Key('home_scheduled_workout_panel')),
        findsNothing,
      );
      expect(find.byKey(const Key('home_start_workout_button')), findsNothing);
      expect(
        find.byKey(const Key('home_view_workout_details_button')),
        findsNothing,
      );
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('uses a raised dark surface for the volume card', (
      tester,
    ) async {
      _HomeTestFixtures.useFixedMobileSurface(tester);
      await tester.pumpWidget(
        _HomeTestFixtures.app(
          programmeState: const ProgrammeLibraryState(
            items: [],
            isLoading: false,
          ),
          theme: AppTheme.darkTheme,
        ),
      );
      await tester.pumpAndSettle();

      final volumeCard = tester.widget<Container>(
        find.byKey(const Key('home_volume_signal')),
      );
      final decoration = volumeCard.decoration! as BoxDecoration;
      expect(
        decoration.color,
        AppTheme.darkTheme.colorScheme.surfaceContainerLow,
      );
    });
  });
}
