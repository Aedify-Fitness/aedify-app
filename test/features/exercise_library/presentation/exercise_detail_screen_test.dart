import 'dart:async';
import 'dart:ui' as ui;

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/application/workout_history_providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/application/exercise_step_audio_controller.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_video_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/exercise_library/domain/exercise_step_audio_state.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_detail_screen.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_step_audio_button.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_video_card.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_force.dart';
import 'package:aedify/shared/domain/exercise_mechanic.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/exercise_video_angle.dart';
import 'package:aedify/shared/domain/exercise_video_gender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockDetailScreenRepository implements ExerciseRepository {
  ExerciseDetailViewData? detail;
  Future<ExerciseDetailViewData?>? pendingLoad;
  Future<void>? pendingPreferenceSave;
  bool failLoading = false;
  bool failFavorite = false;
  bool failAvoid = false;
  int detailLoadCount = 0;

  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async => [];

  @override
  Future<ExerciseDetailViewData?> getExerciseDetail(int exerciseId) async {
    detailLoadCount++;
    if (failLoading) throw StateError('Detail unavailable');
    if (pendingLoad != null) return pendingLoad;
    return detail;
  }

  @override
  Future<void> setFavorite({
    required int exerciseId,
    required bool isFavorite,
  }) async {
    await pendingPreferenceSave;
    if (failFavorite) throw StateError('Favorite unavailable');
    _updatePreferences(isFavorite: isFavorite);
  }

  @override
  Future<void> setSubstitutedOut({
    required int exerciseId,
    required bool isSubstitutedOut,
  }) async {
    await pendingPreferenceSave;
    if (failAvoid) throw StateError('Avoid preference unavailable');
    _updatePreferences(isSubstitutedOut: isSubstitutedOut);
  }

  void _updatePreferences({bool? isFavorite, bool? isSubstitutedOut}) {
    final current = detail;
    if (current == null) return;
    detail = ExerciseDetailViewData(
      id: current.id,
      name: current.name,
      difficulty: current.difficulty,
      primaryMuscles: current.primaryMuscles,
      muscleGroups: current.muscleGroups,
      category: current.category,
      modality: current.modality,
      equipment: current.equipment,
      force: current.force,
      mechanic: current.mechanic,
      grips: current.grips,
      steps: current.steps,
      videos: current.videos,
      isFavorite: isFavorite ?? current.isFavorite,
      isSubstitutedOut: isSubstitutedOut ?? current.isSubstitutedOut,
      loggingType: current.loggingType,
    );
  }

  @override
  Future<List<ExerciseListItem>> getCustomExercises() async => [];

  @override
  Future<ExerciseDetailViewData?> getCustomExerciseDetail(
    int exerciseId,
  ) async => null;

  @override
  Future<int> createCustomExercise(CustomExerciseSeed seed) async => -1;

  @override
  Future<void> updateCustomExercise({
    required int exerciseId,
    required CustomExerciseSeed seed,
  }) async {}

  @override
  Future<void> deleteCustomExercise(int exerciseId) async {}
}

class _PreloadedAudioController extends ExerciseStepAudioController {
  _PreloadedAudioController(this.initialState);

  final Map<String, ExerciseStepAudioState> initialState;

  @override
  Map<String, ExerciseStepAudioState> build() => initialState;
}

class _ExerciseDetailTestApp {
  _ExerciseDetailTestApp._();

  static Finder iconButton(String tooltip) => find.byWidgetPredicate(
    (widget) => widget is IconButton && widget.tooltip == tooltip,
  );

  static Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  static Widget build(
    ExerciseRepository repository, {
    int exerciseId = 1,
    Map<String, ExerciseStepAudioState> audioStates = const {},
    TextScaler textScaler = TextScaler.noScaling,
    ThemeMode themeMode = ThemeMode.light,
    bool accessibleNavigation = false,
    bool highContrast = false,
  }) {
    return ProviderScope(
      overrides: [
        WorkoutHistoryProviders.exerciseHistoryProvider.overrideWith(
          (ref, id) async => [],
        ),
        AppProviders.exerciseRepositoryProvider.overrideWithValue(repository),
        AppProviders.exerciseStepAudioControllerProvider.overrideWith(
          () => _PreloadedAudioController(audioStates),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: textScaler,
              accessibleNavigation: accessibleNavigation,
              highContrast: highContrast,
            ),
            child: child!,
          );
        },
        home: ExerciseDetailScreen(exerciseId: exerciseId),
      ),
    );
  }
}

class _ExerciseDetailFixtures {
  _ExerciseDetailFixtures._();

  static ExerciseDetailViewData detail({
    int id = 1,
    String name = 'Bench Press',
    ExerciseDifficulty? difficulty = ExerciseDifficulty.intermediate,
    EquipmentTag? equipment = EquipmentTag.barbell,
    ExerciseForce? force = ExerciseForce.push,
    ExerciseMechanic? mechanic = ExerciseMechanic.compound,
    List<String> steps = const [
      'Set up on the bench.',
      'Press the bar with control.',
    ],
    List<ExerciseDetailVideoViewData> videos = const [
      ExerciseDetailVideoViewData(
        url: 'https://example.com/v.mp4',
        angle: ExerciseVideoAngle.front,
        gender: ExerciseVideoGender.male,
        ogImageUrl: null,
      ),
    ],
  }) {
    return ExerciseDetailViewData(
      id: id,
      name: name,
      difficulty: difficulty,
      primaryMuscles: const ['Chest', 'Triceps'],
      muscleGroups: const {BodymapBucket.chest},
      category: 'compound',
      modality: ExerciseModality.strength,
      equipment: equipment,
      force: force,
      mechanic: mechanic,
      grips: const ['barbell'],
      steps: steps,
      videos: videos,
      isFavorite: false,
      isSubstitutedOut: false,
    );
  }
}

void main() {
  group('ExerciseDetailScreen', () {
    late _MockDetailScreenRepository repository;

    setUp(() {
      repository = _MockDetailScreenRepository()
        ..detail = _ExerciseDetailFixtures.detail();
    });

    testWidgets('keeps the exercise summary while details are collapsed', (
      tester,
    ) async {
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('Barbell'), findsOneWidget);
      expect(find.text('Push'), findsNothing);

      final disclosure = find.text(AppStrings.viewDetails);
      await _ExerciseDetailTestApp.reveal(tester, disclosure);
      await tester.tap(disclosure);
      await tester.pumpAndSettle();

      expect(find.text('Push'), findsOneWidget);
      expect(find.text('Compound'), findsWidgets);

      await _ExerciseDetailTestApp.reveal(tester, disclosure);
      await tester.tap(disclosure);
      await tester.pumpAndSettle();

      expect(find.text('Push'), findsNothing);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('Barbell'), findsOneWidget);
    });

    testWidgets('puts instructions before detailed metadata without anatomy', (
      tester,
    ) async {
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      const orderedSectionKeys = [
        'exercise_detail_video_section',
        'exercise_detail_instructions_section',
        'exercise_detail_metadata_section',
        'exercise_detail_notes_section',
      ];
      double? previousTop;
      for (final key in orderedSectionKeys) {
        final section = find.byKey(Key(key));
        expect(section, findsOneWidget);
        final top = tester.getTopLeft(section).dy;
        if (previousTop != null) expect(top, greaterThan(previousTop));
        previousTop = top;
      }
      expect(find.text(AppStrings.musclesWorked), findsNothing);
      expect(
        find.byKey(const Key('exercise_detail_bodymap_section')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('exercise_detail_bodymap_front')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('exercise_detail_bodymap_back')),
        findsNothing,
      );
    });

    testWidgets('renders instructions and audio controls in order', (
      tester,
    ) async {
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsOneWidget);
      expect(find.byType(ExerciseStepAudioButton), findsNWidgets(2));
      expect(
        tester.getTopLeft(find.text('Set up on the bench.')).dy,
        lessThan(
          tester.getTopLeft(find.text('Press the bar with control.')).dy,
        ),
      );
    });

    testWidgets('omits unavailable metadata without rendering null values', (
      tester,
    ) async {
      repository.detail = _ExerciseDetailFixtures.detail(
        difficulty: null,
        equipment: null,
        force: null,
        mechanic: null,
      );
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      final disclosure = find.text(AppStrings.viewDetails);
      await _ExerciseDetailTestApp.reveal(tester, disclosure);
      await tester.tap(disclosure);
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Strength'), findsWidgets);
      expect(find.text('Intermediate'), findsNothing);
      expect(find.text('Push'), findsNothing);
      expect(find.textContaining('null'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the exercise preview with angle and gender metadata', (
      tester,
    ) async {
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseVideoCard), findsOneWidget);
      expect(find.byKey(const Key('exercise_video_carousel')), findsOneWidget);
      final caption = find.byType(ExerciseVideoCaption);
      expect(
        find.descendant(of: caption, matching: find.text('Front')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: caption, matching: find.text('Male')),
        findsOneWidget,
      );
      expect(find.text('Set up on the bench.'), findsOneWidget);
    });

    testWidgets('favorite can be saved and removed with toggle semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
        await tester.pumpAndSettle();

        final favorite = find.byTooltip(AppStrings.toggleFavorite);
        expect(
          tester.getSemantics(favorite).flagsCollection.isToggled,
          ui.Tristate.isFalse,
        );
        await tester.tap(favorite);
        await tester.pumpAndSettle();

        expect(repository.detail!.isFavorite, isTrue);
        expect(
          tester.getSemantics(favorite).flagsCollection.isToggled,
          ui.Tristate.isTrue,
        );
        await tester.tap(favorite);
        await tester.pumpAndSettle();

        expect(repository.detail!.isFavorite, isFalse);
        expect(
          tester.getSemantics(favorite).flagsCollection.isToggled,
          ui.Tristate.isFalse,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('avoid action clearly allows the exercise to be restored', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
        await tester.pumpAndSettle();

        final action = find.byKey(
          const Key('exercise_detail_substitute_action'),
        );
        expect(find.byTooltip(AppStrings.toggleSubstitution), findsOneWidget);
        expect(find.text(AppStrings.avoidExercise), findsOneWidget);
        expect(
          tester.getSemantics(action).flagsCollection.isToggled,
          ui.Tristate.isFalse,
        );
        await tester.tap(action);
        await tester.pumpAndSettle();

        expect(repository.detail!.isSubstitutedOut, isTrue);
        expect(find.text(AppStrings.allowExercise), findsOneWidget);
        expect(find.text(AppStrings.exerciseAvoidedHint), findsOneWidget);
        expect(find.text(AppStrings.avoidExercise), findsNothing);
        expect(
          tester.getSemantics(action).flagsCollection.isToggled,
          ui.Tristate.isTrue,
        );
        await tester.tap(action);
        await tester.pumpAndSettle();

        expect(repository.detail!.isSubstitutedOut, isFalse);
        expect(find.text(AppStrings.avoidExercise), findsOneWidget);
        expect(find.text(AppStrings.allowExercise), findsNothing);
        expect(find.text(AppStrings.exerciseAvoidedHint), findsNothing);
        expect(
          tester.getSemantics(action).flagsCollection.isToggled,
          ui.Tristate.isFalse,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('preference actions stay disabled until saving finishes', (
      tester,
    ) async {
      final pendingSave = Completer<void>();
      repository.pendingPreferenceSave = pendingSave.future;
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      final favorite = find.byTooltip(AppStrings.toggleFavorite);
      final avoid = find.byKey(const Key('exercise_detail_substitute_action'));
      await tester.tap(favorite);
      await tester.pump();

      expect(
        tester
            .widget<IconButton>(
              _ExerciseDetailTestApp.iconButton(AppStrings.toggleFavorite),
            )
            .onPressed,
        isNull,
      );
      expect(tester.widget<OutlinedButton>(avoid).onPressed, isNull);
      expect(repository.detail!.isFavorite, isFalse);
      expect(repository.detail!.isSubstitutedOut, isFalse);

      pendingSave.complete();
      await tester.pumpAndSettle();

      expect(repository.detail!.isFavorite, isTrue);
      expect(tester.widget<OutlinedButton>(avoid).onPressed, isNotNull);
    });

    testWidgets('keeps preferences disabled until refreshed detail arrives', (
      tester,
    ) async {
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      final refresh = Completer<ExerciseDetailViewData?>();
      repository.pendingLoad = refresh.future;
      final favorite = _ExerciseDetailTestApp.iconButton(
        AppStrings.toggleFavorite,
      );
      final avoid = find.byKey(const Key('exercise_detail_substitute_action'));
      await tester.tap(favorite);
      await tester.pump();
      await tester.pump();

      expect(repository.detailLoadCount, 2);
      expect(repository.detail!.isFavorite, isTrue);
      expect(tester.widget<IconButton>(favorite).onPressed, isNull);
      expect(tester.widget<OutlinedButton>(avoid).onPressed, isNull);

      repository.pendingLoad = null;
      refresh.complete(repository.detail);
      await tester.pumpAndSettle();

      expect(tester.widget<IconButton>(favorite).onPressed, isNotNull);
      expect(tester.widget<OutlinedButton>(avoid).onPressed, isNotNull);
      await tester.tap(favorite);
      await tester.pumpAndSettle();
      expect(repository.detail!.isFavorite, isFalse);
    });

    for (final preference in ['favorite', 'avoid']) {
      testWidgets('$preference failure remains visible and can be retried', (
        tester,
      ) async {
        repository.failFavorite = preference == 'favorite';
        repository.failAvoid = preference == 'avoid';
        await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
        await tester.pumpAndSettle();

        final action = preference == 'favorite'
            ? find.byTooltip(AppStrings.toggleFavorite)
            : find.byKey(const Key('exercise_detail_substitute_action'));
        await tester.tap(action);
        await tester.pumpAndSettle();

        expect(
          find.text(AppErrorStrings.exercisePreferenceSaveFailed),
          findsOneWidget,
        );
        expect(repository.detail!.isFavorite, isFalse);
        expect(repository.detail!.isSubstitutedOut, isFalse);
        expect(find.text('Bench Press'), findsOneWidget);
        expect(tester.takeException(), isNull);

        repository.failFavorite = false;
        repository.failAvoid = false;
        await tester.tap(action);
        await tester.pumpAndSettle();

        expect(
          find.text(AppErrorStrings.exercisePreferenceSaveFailed),
          findsNothing,
        );
        expect(
          preference == 'favorite'
              ? repository.detail!.isFavorite
              : repository.detail!.isSubstitutedOut,
          isTrue,
        );
      });
    }

    testWidgets('shows a dismissible loading state before detail arrives', (
      tester,
    ) async {
      final pendingLoad = Completer<ExerciseDetailViewData?>();
      repository.pendingLoad = pendingLoad.future;
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byTooltip(AppStrings.close), findsOneWidget);
      expect(
        find.byKey(const Key('exercise_detail_substitute_action')),
        findsNothing,
      );
      pendingLoad.complete(repository.detail);
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows an honest not-found state for a missing exercise', (
      tester,
    ) async {
      repository.detail = null;
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.exerciseNotFound), findsOneWidget);
      expect(find.byTooltip(AppStrings.close), findsOneWidget);
      expect(
        find.byKey(const Key('exercise_detail_substitute_action')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('retries failed loading and displays the recovered exercise', (
      tester,
    ) async {
      repository.failLoading = true;
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.exerciseDetailLoadFailed), findsOneWidget);
      expect(find.text(AppStrings.tryAgain), findsOneWidget);
      final failedLoadCount = repository.detailLoadCount;
      repository.failLoading = false;
      await tester.tap(find.text(AppStrings.tryAgain));
      await tester.pumpAndSettle();

      expect(repository.detailLoadCount, greaterThan(failedLoadCount));
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text(AppStrings.exerciseDetailLoadFailed), findsNothing);
    });

    testWidgets('custom exercise stays useful without video or steps', (
      tester,
    ) async {
      repository.detail = _ExerciseDetailFixtures.detail(
        id: -1,
        name: 'My exercise',
        videos: const [],
        steps: const [],
      );
      await tester.pumpWidget(
        _ExerciseDetailTestApp.build(repository, exerciseId: -1),
      );
      await tester.pumpAndSettle();

      expect(find.text('My exercise'), findsOneWidget);
      expect(find.text(AppStrings.noExerciseVideos), findsOneWidget);
      expect(find.text(AppStrings.customExerciseNoSteps), findsOneWidget);
      expect(find.byType(ExerciseStepAudioButton), findsNothing);
      expect(find.text(AppStrings.avoidExercise), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('instructions remain available when videos are absent', (
      tester,
    ) async {
      repository.detail = _ExerciseDetailFixtures.detail(videos: const []);
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noExerciseVideos), findsOneWidget);
      expect(find.text('Set up on the bench.'), findsOneWidget);
      expect(find.text('Press the bar with control.'), findsOneWidget);
      expect(find.byType(ExerciseStepAudioButton), findsNWidgets(2));
    });

    testWidgets('step text remains usable when audio is unavailable', (
      tester,
    ) async {
      await tester.pumpWidget(
        _ExerciseDetailTestApp.build(
          repository,
          audioStates: const {
            '1:0': ExerciseStepAudioState(
              phase: ExerciseStepAudioPhase.unavailable,
            ),
            '1:1': ExerciseStepAudioState(
              phase: ExerciseStepAudioPhase.unavailable,
            ),
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip(AppStrings.audioUnavailable), findsNWidgets(2));
      expect(find.text('Set up on the bench.'), findsOneWidget);
      expect(find.text('Press the bar with control.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('highlights only the active audio step', (tester) async {
      await tester.pumpWidget(
        _ExerciseDetailTestApp.build(
          repository,
          audioStates: const {
            '1:0': ExerciseStepAudioState(
              phase: ExerciseStepAudioPhase.speaking,
              activeStepIndex: 0,
            ),
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('exercise_step_0_active')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('exercise_step_1_idle')),
        findsOneWidget,
      );
      expect(find.byTooltip(AppStrings.stopStepAudio), findsOneWidget);
    });

    testWidgets('performance is honest and guidance remains reachable', (
      tester,
    ) async {
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.performance));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('exercise_detail_history_empty_state')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.noHistoryYet), findsOneWidget);
      expect(find.text(AppStrings.noHistoryHint), findsOneWidget);
      expect(find.text(AppStrings.askAiCoach), findsOneWidget);
      expect(find.text(AppStrings.avoidExercise), findsOneWidget);
      expect(
        find.byKey(const Key('exercise_detail_instructions_section')),
        findsNothing,
      );

      await tester.tap(find.text(AppStrings.guidance));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('exercise_detail_history_empty_state')),
        findsNothing,
      );
      expect(find.text('Set up on the bench.'), findsOneWidget);
    });

    testWidgets('notes honestly remain disabled until persistence exists', (
      tester,
    ) async {
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      final notes = find.byKey(const Key('exercise_detail_notes_field'));
      expect(notes, findsOneWidget);
      expect(
        tester
            .widget<TextField>(
              find.descendant(of: notes, matching: find.byType(TextField)),
            )
            .enabled,
        isFalse,
      );
      expect(find.text(AppStrings.typeYourNotesHere), findsOneWidget);
      expect(find.text(AppStrings.exerciseNotesComingSoon), findsOneWidget);
    });

    testWidgets('footer stays fixed and leaves all scroll content reachable', (
      tester,
    ) async {
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      final action = find.byKey(const Key('exercise_detail_substitute_action'));
      final scrollView = find.byKey(const Key('exercise_detail_scroll_view'));
      final initialTop = tester.getTopLeft(action).dy;
      expect(
        tester.getBottomLeft(scrollView).dy,
        lessThanOrEqualTo(initialTop),
      );

      final notesMessage = find.text(AppStrings.exerciseNotesComingSoon);
      await _ExerciseDetailTestApp.reveal(tester, notesMessage);

      expect(tester.getTopLeft(action).dy, initialTop);
      expect(
        tester.getBottomLeft(notesMessage).dy,
        lessThanOrEqualTo(tester.getBottomLeft(scrollView).dy),
      );
      expect(
        tester.getTopLeft(notesMessage).dy,
        greaterThanOrEqualTo(tester.getTopLeft(scrollView).dy),
      );
      expect(action.hitTestable(), findsOneWidget);
    });

    testWidgets('header actions provide at least 48 logical pixel targets', (
      tester,
    ) async {
      await tester.pumpWidget(_ExerciseDetailTestApp.build(repository));
      await tester.pumpAndSettle();

      for (final label in [AppStrings.close, AppStrings.toggleFavorite]) {
        final targetSize = tester.getSize(find.byTooltip(label));
        expect(targetSize.width, greaterThanOrEqualTo(48));
        expect(targetSize.height, greaterThanOrEqualTo(48));
      }
    });

    for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'reflows on a small phone with large text in ${themeMode.name}',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(320, 640);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          repository.detail = _ExerciseDetailFixtures.detail(
            name:
                'Alternating incline dumbbell bench press with a slow eccentric',
          );
          await tester.pumpWidget(
            _ExerciseDetailTestApp.build(
              repository,
              textScaler: const TextScaler.linear(2),
              themeMode: themeMode,
              accessibleNavigation: true,
              highContrast: true,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(
            find.byKey(const Key('exercise_detail_title')),
            findsOneWidget,
          );
          final action = find.byKey(
            const Key('exercise_detail_substitute_action'),
          );
          expect(action.hitTestable(), findsOneWidget);
          expect(
            tester
                .getBottomLeft(
                  find.byKey(const Key('exercise_detail_scroll_view')),
                )
                .dy,
            lessThanOrEqualTo(tester.getTopLeft(action).dy),
          );

          await _ExerciseDetailTestApp.reveal(
            tester,
            find.text(AppStrings.viewDetails),
          );
          await tester.tap(find.text(AppStrings.viewDetails));
          await tester.pumpAndSettle();
          expect(find.text('Push'), findsOneWidget);
          expect(tester.takeException(), isNull);

          await _ExerciseDetailTestApp.reveal(
            tester,
            find.text(AppStrings.exerciseNotesComingSoon),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
