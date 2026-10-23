import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/programmes/domain/programme_workout_detail_view_data.dart';
import 'package:aedify/features/programmes/presentation/widgets/workout_detail_exercise_flow.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FlowTestData {
  _FlowTestData._();

  static ExerciseDetailItem exercise({
    int id = 1,
    String? name,
    String equipment = 'Barbell',
    String? groupId,
    int? groupOrder,
    ExerciseLoggingType loggingType = ExerciseLoggingType.repsWeight,
    List<SetPrescriptionItem>? sets,
  }) => ExerciseDetailItem(
    exerciseId: id,
    name: name ?? 'Exercise $id',
    equipment: equipment,
    supersetGroupId: groupId,
    supersetOrder: groupOrder,
    loggingType: loggingType,
    sets:
        sets ??
        const [
          SetPrescriptionItem(
            setIndex: 0,
            setType: 'working',
            repsDisplay: '8',
          ),
        ],
  );

  static Future<void> pump(
    WidgetTester tester,
    List<ExerciseDetailItem> exercises, {
    ValueChanged<int>? onExerciseTap,
    Brightness brightness = Brightness.light,
    double textScale = 1,
    bool reducedMotion = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        home: MediaQuery(
          data: MediaQueryData(
            size: tester.view.physicalSize / tester.view.devicePixelRatio,
            textScaler: TextScaler.linear(textScale),
            disableAnimations: reducedMotion,
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: WorkoutDetailExerciseFlow(
                exercises: exercises,
                onExerciseTap: onExerciseTap ?? (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  static Future<void> revealSets(WidgetTester tester, int exerciseId) async {
    final disclosure = find.byKey(Key('workout_detail_sets_$exerciseId'));
    await tester.ensureVisible(disclosure);
    await tester.tap(disclosure);
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('groups and orders supersets while guide taps stay independent', (
    tester,
  ) async {
    final opened = <int>[];
    await _FlowTestData.pump(tester, [
      _FlowTestData.exercise(id: 1),
      _FlowTestData.exercise(id: 3, groupId: 'pair', groupOrder: 1),
      _FlowTestData.exercise(id: 2, groupId: 'pair', groupOrder: 0),
      _FlowTestData.exercise(id: 4),
    ], onExerciseTap: opened.add);

    expect(find.text(AppStrings.superset), findsOneWidget);
    final exerciseNames = [
      for (final id in [1, 2, 3, 4]) find.text('Exercise $id'),
    ];
    for (var index = 1; index < exerciseNames.length; index++) {
      expect(
        tester.getTopLeft(exerciseNames[index - 1]).dy,
        lessThan(tester.getTopLeft(exerciseNames[index]).dy),
      );
    }
    expect(find.text('01'), findsOneWidget);
    expect(find.text('04'), findsOneWidget);
    final guide = find.byKey(const Key('workout_detail_exercise_guide_2'));
    await tester.ensureVisible(guide);
    await tester.tap(guide);
    await tester.pump();
    expect(opened, [2]);
    expect(find.text(AppStrings.workoutHideSets), findsNothing);
  });

  testWidgets('working targets exclude warm-up sets and disclose every set', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      final opened = <int>[];
      await _FlowTestData.pump(tester, [
        _FlowTestData.exercise(
          sets: const [
            SetPrescriptionItem(
              setIndex: 0,
              setType: 'warmup',
              repsDisplay: '12',
            ),
            SetPrescriptionItem(
              setIndex: 1,
              setType: 'working',
              repsDisplay: '8',
            ),
            SetPrescriptionItem(
              setIndex: 2,
              setType: 'working',
              repsDisplay: '8',
            ),
          ],
        ),
      ], onExerciseTap: opened.add);
      expect(find.text(AppStrings.workoutWorkingSets(2)), findsOneWidget);
      expect(find.text(AppStrings.workoutWarmupSets(1)), findsOneWidget);
      expect(find.text(AppStrings.exerciseRepsSummary('8')), findsOneWidget);
      expect(find.text(AppStrings.exerciseRepsSummary('12')), findsNothing);
      expect(find.text('3 x 8'), findsNothing);
      final disclosure = find.byKey(const Key('workout_detail_sets_1'));
      expect(
        tester.getSemantics(disclosure),
        isSemantics(
          isButton: true,
          hasTapAction: true,
          hasExpandedState: true,
          isExpanded: false,
        ),
      );

      await _FlowTestData.revealSets(tester, 1);
      expect(opened, isEmpty);
      expect(tester.getSemantics(disclosure), isSemantics(isExpanded: true));
      expect(
        find.text(AppStrings.workoutSetDetailsLabel(1, AppStrings.warmupSet)),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.workoutSetDetailsLabel(3, AppStrings.workingSet)),
        findsOneWidget,
      );
      expect(find.text('12'), findsOneWidget);
      await _FlowTestData.revealSets(tester, 1);
      expect(find.text('12'), findsNothing);
      expect(find.text(AppStrings.workoutViewSets), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('varied and partially missing working targets are explicit', (
    tester,
  ) async {
    await _FlowTestData.pump(tester, [
      _FlowTestData.exercise(
        sets: const [
          SetPrescriptionItem(
            setIndex: 0,
            setType: 'working',
            repsDisplay: '10',
          ),
          SetPrescriptionItem(
            setIndex: 1,
            setType: 'working',
            repsDisplay: '6',
          ),
          SetPrescriptionItem(setIndex: 2, setType: 'working'),
        ],
      ),
    ]);
    expect(find.text(AppStrings.workoutVariableTargets), findsOneWidget);
    expect(find.text(AppStrings.exerciseRepsSummary('6')), findsNothing);
    expect(find.text(AppStrings.exerciseRepsSummary('10')), findsNothing);
  });

  testWidgets('reveals exact loads, effort, rest and notes in set order', (
    tester,
  ) async {
    await _FlowTestData.pump(tester, [
      _FlowTestData.exercise(
        sets: const [
          SetPrescriptionItem(
            setIndex: 1,
            setType: 'working',
            repsDisplay: '8-10',
            weightDisplay: '70% 1RM',
            rpeDisplay: 'RIR 2',
            restSeconds: 120,
            notes: 'Use the same load for both sides.',
          ),
          SetPrescriptionItem(
            setIndex: 0,
            setType: 'warmup',
            repsDisplay: '12',
            weightDisplay: '20.0 kg',
            rpeDisplay: 'RPE 5-6',
            restSeconds: 60,
          ),
        ],
      ),
    ]);
    expect(find.text('70% 1RM'), findsNothing);
    await _FlowTestData.revealSets(tester, 1);

    for (final value in [
      '70% 1RM',
      'RIR 2',
      '120s',
      '8-10',
      '20.0 kg',
      'RPE 5-6',
      '60s',
      '12',
      'Use the same load for both sides.',
    ]) {
      expect(find.text(value), findsOneWidget);
    }
    expect(
      tester.getTopLeft(find.byKey(const Key('workout_detail_set_1_0'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('workout_detail_set_1_1'))).dy,
      ),
    );
  });

  testWidgets('duration sets retain real durations and omit missing values', (
    tester,
  ) async {
    await _FlowTestData.pump(tester, [
      _FlowTestData.exercise(
        loggingType: ExerciseLoggingType.duration,
        sets: const [
          SetPrescriptionItem(
            setIndex: 0,
            setType: 'working',
            durationSeconds: 30,
          ),
          SetPrescriptionItem(
            setIndex: 1,
            setType: 'working',
            durationSeconds: 45,
          ),
        ],
      ),
    ]);
    expect(find.text(AppStrings.workoutVariableTargets), findsOneWidget);
    await _FlowTestData.revealSets(tester, 1);
    expect(find.text('30s'), findsOneWidget);
    expect(find.text('45s'), findsOneWidget);
    expect(find.text(AppStrings.reps), findsNothing);
    expect(find.text(AppStrings.weight), findsNothing);
    expect(find.text(AppStrings.intensity), findsNothing);
    expect(find.text(AppStrings.rest), findsNothing);
    expect(find.text('0s'), findsNothing);
  });

  testWidgets(
    'reps-only targets do not invent weight or effort prescriptions',
    (tester) async {
      await _FlowTestData.pump(tester, [
        _FlowTestData.exercise(
          loggingType: ExerciseLoggingType.repsOnly,
          sets: const [
            SetPrescriptionItem(
              setIndex: 0,
              setType: 'working',
              repsDisplay: '15',
            ),
          ],
        ),
      ]);
      expect(find.text(AppStrings.exerciseRepsSummary('15')), findsOneWidget);
      await _FlowTestData.revealSets(tester, 1);
      expect(find.text('15'), findsOneWidget);
      expect(find.text(AppStrings.weight), findsNothing);
      expect(find.text(AppStrings.intensity), findsNothing);
      expect(find.text(AppStrings.duration), findsNothing);
    },
  );

  testWidgets(
    'missing sets and targets stay honest and guides stay available',
    (tester) async {
      final opened = <int>[];
      await _FlowTestData.pump(tester, [
        _FlowTestData.exercise(id: 1, equipment: '', sets: []),
        _FlowTestData.exercise(
          id: 2,
          sets: const [SetPrescriptionItem(setIndex: 0, setType: 'working')],
        ),
      ], onExerciseTap: opened.add);
      expect(find.text(AppStrings.noSetsYet), findsOneWidget);
      expect(find.text(AppStrings.workoutViewSets), findsOneWidget);
      expect(find.text(AppStrings.workoutVariableTargets), findsNothing);
      await tester.tap(
        find.byKey(const Key('workout_detail_exercise_guide_1')),
      );
      expect(opened, [1]);
      await _FlowTestData.revealSets(tester, 2);
      expect(find.text(AppStrings.reps), findsNothing);
      expect(find.text(AppStrings.duration), findsNothing);
      expect(find.text(AppStrings.weight), findsNothing);
      expect(find.text(AppStrings.rest), findsNothing);
      expect(find.text('-'), findsNothing);
    },
  );

  testWidgets('repeated exercise IDs have independent disclosure state', (
    tester,
  ) async {
    await _FlowTestData.pump(tester, [
      _FlowTestData.exercise(name: 'First occurrence'),
      _FlowTestData.exercise(name: 'Second occurrence'),
    ]);
    expect(tester.takeException(), isNull);
    final disclosures = find.byKey(const Key('workout_detail_sets_1'));
    expect(disclosures, findsNWidgets(2));
    await tester.tap(disclosures.first);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.workoutHideSets), findsOneWidget);
    expect(find.text(AppStrings.workoutViewSets), findsOneWidget);
    expect(find.byKey(const Key('workout_detail_set_1_0')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets('320px, 2x text and reduced motion in ${brightness.name}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _FlowTestData.pump(
        tester,
        [
          _FlowTestData.exercise(
            name: 'Seated single-arm dumbbell overhead press',
            equipment: 'Adjustable dumbbells and an incline bench',
            groupId: 'pair',
            groupOrder: 0,
            sets: const [
              SetPrescriptionItem(
                setIndex: 0,
                setType: 'working',
                repsDisplay: '10-12',
                weightDisplay: '72% 1RM',
                rpeDisplay: 'RPE 7-8',
                restSeconds: 90,
                notes:
                    'Choose a controlled load and complete each repetition smoothly.',
              ),
            ],
          ),
          _FlowTestData.exercise(id: 2, groupId: 'pair', groupOrder: 1),
        ],
        brightness: brightness,
        textScale: 2,
        reducedMotion: true,
      );
      expect(tester.takeException(), isNull);
      await _FlowTestData.revealSets(tester, 1);
      expect(find.byType(AnimatedSize), findsNothing);
      expect(tester.takeException(), isNull);
      final disclosure = find.byKey(const Key('workout_detail_sets_1'));
      expect(
        tester.getSize(disclosure).height,
        greaterThanOrEqualTo(AppWorkoutDetailTokens.controlSize),
      );
      await tester.ensureVisible(find.text('72% 1RM'));
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<Text>(
              find.text('Seated single-arm dumbbell overhead press'),
            )
            .maxLines,
        isNull,
      );
    });
  }
}
