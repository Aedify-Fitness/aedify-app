import 'dart:async';

import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_block.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_training_log.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_intent.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _LogFixtures {
  _LogFixtures._();

  static WorkoutRunnerSetItem set(
    String id, {
    int exerciseId = 1,
    int index = 0,
    SetType type = SetType.working,
    bool completed = false,
    bool skipped = false,
    double? actualWeight = 22.05,
    int? actualReps = 10,
  }) => WorkoutRunnerSetItem(
    id: id,
    exerciseId: exerciseId,
    setIndex: index,
    setType: type,
    performedAt: DateTime.utc(2026, 10, 24),
    completed: completed,
    skipped: skipped,
    setIntent: SetIntent.technique,
    prescribedRepsMin: 8,
    prescribedRepsMax: 12,
    prescribedWeightKg: 20.5,
    prescribedRpeMin: 8,
    prescribedRpeMax: 9,
    actualReps: actualReps,
    actualWeightKg: actualWeight,
    actualDurationSeconds: 35,
    actualDistanceMeters: 20,
    actualRpe: 8.5,
    actualRir: 2,
    restSeconds: 90,
    notes: 'Keep every repetition controlled.',
  );

  static WorkoutRunnerExerciseItem member(
    String id,
    List<WorkoutRunnerSetItem> sets, {
    int exerciseId = 1,
    int order = 0,
    String? name,
    ExerciseLoggingType? loggingType,
  }) => WorkoutRunnerExerciseItem(
    id: id,
    exerciseId: exerciseId,
    exerciseName: name ?? 'Exercise $exerciseId',
    loggingType: loggingType,
    sortOrder: order,
    supersetGroupId: 'paired',
    supersetOrder: order,
    sets: sets,
  );

  static WorkoutRunnerBlock single() => WorkoutRunnerBlock(
    members: [
      member('member-1', [
        set('warmup', type: SetType.warmup, completed: true),
        set('active', index: 1),
        set('upcoming', index: 2),
      ]),
    ],
  );

  static WorkoutRunnerBlock paired() => WorkoutRunnerBlock(
    members: [
      member('member-a', [
        set('a-w0', type: SetType.warmup),
        set('a-w1', index: 1, type: SetType.warmup),
        set('a-s0', index: 2),
        set('a-s1', index: 3),
      ], name: 'Seated single-arm dumbbell overhead press'),
      member(
        'member-b',
        [
          set('b-w0', exerciseId: 2, type: SetType.warmup),
          set('b-s0', exerciseId: 2, index: 1),
          set('b-s1', exerciseId: 2, index: 2),
          set('b-s2', exerciseId: 2, index: 3),
        ],
        exerciseId: 2,
        order: 1,
        name: 'Chest-supported cable rear deltoid row',
      ),
    ],
  );

  static Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Brightness brightness = Brightness.light,
    double textScale = 1,
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
            disableAnimations: true,
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: child,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  static Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
  }
}

class _LogHarness extends StatefulWidget {
  const _LogHarness({
    super.key,
    required this.initialBlock,
    this.enabled = true,
    this.canLog = true,
    this.pendingLog,
  });

  final WorkoutRunnerBlock initialBlock;
  final bool enabled;
  final bool canLog;
  final Completer<void>? pendingLog;

  @override
  State<_LogHarness> createState() => _LogHarnessState();
}

class _LogHarnessState extends State<_LogHarness> {
  late WorkoutRunnerBlock block;
  WorkoutRunnerSetItem? updated;
  String? updatedExercise;
  final completedCalls = <(String, String, bool)>[];
  final skippedCalls = <(String, String, bool)>[];
  final noteCalls = <(String, String)>[];
  final opened = <int>[];
  int added = 0;
  int logged = 0;

  @override
  void initState() {
    super.initState();
    block = widget.initialBlock;
  }

  void replace(WorkoutRunnerBlock next) => setState(() => block = next);

  void update(String exerciseId, WorkoutRunnerSetItem set) {
    updated = set;
    updatedExercise = exerciseId;
    replace(
      WorkoutRunnerBlock(
        members: [
          for (final member in block.members)
            if (member.id == exerciseId)
              member.copyWith(
                sets: [
                  for (final existing in member.sets)
                    if (existing.id == set.id) set else existing,
                ],
              )
            else
              member,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => WorkoutRunnerTrainingLog(
    block: block,
    activeSet: const WorkoutRunnerBlockResolver()
        .firstIncompleteSet(block)
        ?.set,
    enabled: widget.enabled,
    canLogSet: widget.canLog,
    onUpdateSet: update,
    onToggleCompleted: (exercise, set, value) {
      completedCalls.add((exercise, set.id, value));
      update(exercise, set.copyWith(completed: value));
    },
    onToggleSkipped: (exercise, set, value) {
      skippedCalls.add((exercise, set.id, value));
      update(exercise, set.copyWith(skipped: value));
    },
    onLogSet: () async {
      logged++;
      await widget.pendingLog?.future;
    },
    onAddSet: () => added++,
    onAddNote: (exercise, set) => noteCalls.add((exercise, set.id)),
    onShowExercise: opened.add,
  );
}

void main() {
  testWidgets(
    'shows complete prescriptions separately from active actual inputs',
    (tester) async {
      await _LogFixtures.pump(
        tester,
        _LogHarness(initialBlock: _LogFixtures.single()),
      );
      final active = find.byKey(const Key('workout_runner_set_row_active'));
      expect(
        find.descendant(of: active, matching: find.textContaining('20.5 kg')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: active, matching: find.textContaining('8–12 Reps')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: active, matching: find.textContaining('RPE 8–9')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: active, matching: find.textContaining('Rest: 90s')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('active_weight_field')))
            .controller!
            .text,
        '22.05',
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('active_reps_field')))
            .controller!
            .text,
        '10',
      );
      expect(find.text(AppStrings.previousColumn), findsNothing);
    },
  );

  testWidgets('editing and clearing actuals retains every other set field', (
    tester,
  ) async {
    final key = GlobalKey<_LogHarnessState>();
    await _LogFixtures.pump(
      tester,
      _LogHarness(key: key, initialBlock: _LogFixtures.single()),
    );
    final weight = find.byKey(const Key('active_weight_field'));
    await tester.ensureVisible(weight);
    await tester.enterText(weight, '41.25');
    await tester.pump();
    final changed = key.currentState!.updated!;
    expect(changed.actualWeightKg, 41.25);
    expect(changed.actualReps, 10);
    expect(changed.actualRpe, 8.5);
    expect(changed.actualRir, 2);
    expect(changed.actualDurationSeconds, 35);
    expect(changed.actualDistanceMeters, 20);
    expect(changed.setIntent, SetIntent.technique);
    expect(changed.prescribedRepsMin, 8);
    expect(changed.prescribedRepsMax, 12);
    expect(changed.restSeconds, 90);
    expect(changed.notes, 'Keep every repetition controlled.');
    expect(key.currentState!.updatedExercise, 'member-1');
    await tester.enterText(weight, '');
    await tester.pump();
    expect(key.currentState!.updated!.actualWeightKg, isNull);
    expect(tester.widget<TextField>(weight).controller!.text, isEmpty);
    final reps = find.byKey(const Key('active_reps_field'));
    await tester.ensureVisible(reps);
    await tester.enterText(reps, '');
    await tester.pump();
    expect(key.currentState!.updated!.actualReps, isNull);
    expect(key.currentState!.updated!.actualRpe, 8.5);
    expect(tester.widget<TextField>(reps).controller!.text, isEmpty);
  });

  testWidgets('numeric echoes and refresh retain field identity and caret', (
    tester,
  ) async {
    final key = GlobalKey<_LogHarnessState>();
    await _LogFixtures.pump(
      tester,
      _LogHarness(key: key, initialBlock: _LogFixtures.single()),
    );
    final weight = find.byKey(const Key('active_weight_field'));
    await tester.ensureVisible(weight);
    await tester.tap(weight);
    const edit = TextEditingValue(
      text: '41.20',
      selection: TextSelection.collapsed(offset: 3),
    );
    tester.testTextInput.updateEditingValue(edit);
    await tester.pump();
    final controller = tester.widget<TextField>(weight).controller!;
    expect(controller.value, edit);
    final sameBlock = key.currentState!.block;
    key.currentState!.replace(
      WorkoutRunnerBlock(members: [...sameBlock.members]),
    );
    await tester.pump();
    expect(tester.widget<TextField>(weight).controller, same(controller));
    expect(controller.value, edit);
    expect(tester.testTextInput.isVisible, isTrue);
    key.currentState!.update(
      'member-1',
      key.currentState!.updated!.copyWith(actualWeightKg: 7),
    );
    await tester.pump();
    expect(controller.text, '7');
    expect(controller.selection.baseOffset, 1);
  });

  testWidgets('empty completed actuals never fall back to prescribed results', (
    tester,
  ) async {
    final set = WorkoutRunnerSetItem(
      id: 'done',
      exerciseId: 1,
      setIndex: 0,
      setType: SetType.working,
      performedAt: DateTime.utc(2026),
      completed: true,
      skipped: false,
      prescribedWeightKg: 80,
      prescribedRepsExact: 5,
    );
    await _LogFixtures.pump(
      tester,
      _LogHarness(
        initialBlock: WorkoutRunnerBlock(
          members: [
            _LogFixtures.member('member-1', [set]),
          ],
        ),
      ),
    );
    final row = find.byKey(const Key('workout_runner_set_row_done'));
    expect(
      find.descendant(
        of: row,
        matching: find.text(AppStrings.unavailableValue),
      ),
      findsNWidgets(3),
    );
    expect(find.descendant(of: row, matching: find.text('80')), findsNothing);
    expect(find.descendant(of: row, matching: find.text('5')), findsNothing);
    expect(find.text('${AppStrings.actual}: 80 kg · 5 Reps'), findsNothing);
    expect(find.byKey(const Key('active_weight_field')), findsNothing);
  });

  testWidgets(
    '390px exposes scrollable columns, inline effort and live status',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _LogFixtures.pump(
        tester,
        _LogHarness(initialBlock: _LogFixtures.single()),
      );
      expect(
        find.byKey(const Key('workout_runner_table_columns')),
        findsOneWidget,
      );
      for (final label in [
        AppStrings.setNumberColumn,
        AppStrings.targetColumn,
        AppStrings.kilogramsAbbreviation,
        AppStrings.repsColumn,
        AppStrings.rpe,
        AppStrings.logColumn,
        AppStrings.runnerLive,
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      final weight = find.byKey(const Key('active_weight_field'));
      final reps = find.byKey(const Key('active_reps_field'));
      expect(tester.getTopLeft(weight).dy, tester.getTopLeft(reps).dy);
      expect(
        tester.getSize(weight).height,
        greaterThanOrEqualTo(AppWorkoutRunnerTokens.controlSize),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('groups asymmetric warm-up and working rounds in member order', (
    tester,
  ) async {
    await _LogFixtures.pump(
      tester,
      _LogHarness(initialBlock: _LogFixtures.paired()),
    );
    expect(find.text(AppStrings.superset), findsOneWidget);
    final ids = [
      'a-w0',
      'b-w0',
      'a-w1',
      'a-s0',
      'b-s0',
      'a-s1',
      'b-s1',
      'b-s2',
    ];
    for (var index = 1; index < ids.length; index++) {
      expect(
        tester
            .getTopLeft(
              find.byKey(Key('workout_runner_set_row_${ids[index - 1]}')),
            )
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(Key('workout_runner_set_row_${ids[index]}')),
              )
              .dy,
        ),
      );
    }
    final secondWarmup = find.byKey(
      const Key('workout_runner_superset_round_warmup_1'),
    );
    expect(
      tester.getTopLeft(secondWarmup).dy,
      lessThan(tester.getTopLeft(find.text('W2 (A)')).dy),
    );
    expect(find.text('W2 (B)'), findsNothing);
    final finalWorking = find.byKey(
      const Key('workout_runner_superset_round_working_2'),
    );
    expect(
      tester.getTopLeft(finalWorking).dy,
      lessThan(tester.getTopLeft(find.text('S3 (B)')).dy),
    );
    expect(
      find.text(AppStrings.runnerRound(1, AppStrings.warmupSet)),
      findsOneWidget,
    );
  });

  testWidgets(
    'mixed superset rows follow each member type and type taps preserve ownership',
    (tester) async {
      final key = GlobalKey<_LogHarnessState>();
      await _LogFixtures.pump(
        tester,
        _LogHarness(
          key: key,
          initialBlock: WorkoutRunnerBlock(
            members: [
              _LogFixtures.member('strength', [
                _LogFixtures.set('weighted'),
              ], loggingType: ExerciseLoggingType.repsWeight),
              _LogFixtures.member(
                'bodyweight',
                [_LogFixtures.set('bodyweight', exerciseId: 2)],
                exerciseId: 2,
                order: 1,
                loggingType: ExerciseLoggingType.repsOnly,
              ),
              _LogFixtures.member(
                'timed',
                [_LogFixtures.set('timed', exerciseId: 3)],
                exerciseId: 3,
                order: 2,
                loggingType: ExerciseLoggingType.duration,
              ),
            ],
          ),
        ),
      );
      final headers = find.byKey(const Key('workout_runner_table_columns'));
      expect(headers, findsNWidgets(3));
      final headings = [
        for (final header in headers.evaluate())
          tester
              .widgetList<Text>(
                find.descendant(
                  of: find.byWidget(header.widget),
                  matching: find.byType(Text),
                ),
              )
              .map((text) => text.data)
              .toList(),
      ];
      expect(
        headings[0],
        containsAllInOrder([
          AppStrings.kilogramsAbbreviation,
          AppStrings.repsColumn,
          AppStrings.rpe,
        ]),
      );
      expect(headings[1], isNot(contains(AppStrings.kilogramsAbbreviation)));
      expect(headings[1], contains(AppStrings.repsColumn));
      expect(
        headings[2],
        containsAllInOrder([
          AppStrings.durationColumn,
          AppStrings.distanceColumn,
          AppStrings.rpe,
        ]),
      );
      expect(headings[2], isNot(contains(AppStrings.repsColumn)));
      await _LogFixtures.tap(tester, 'workout_runner_set_type_bodyweight');
      expect(key.currentState!.updatedExercise, 'bodyweight');
      expect(key.currentState!.updated!.setType, SetType.warmup);
      expect(key.currentState!.updated!.actualReps, 10);
      expect(key.currentState!.updated!.actualRpe, 8.5);
      expect(
        key.currentState!.block.members.first.sets.single.setType,
        SetType.working,
      );
      await _LogFixtures.tap(tester, 'workout_runner_set_type_bodyweight');
      expect(key.currentState!.updated!.setType, SetType.working);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'guides, notes, add set, undo, skip and restore use correct ownership',
    (tester) async {
      final key = GlobalKey<_LogHarnessState>();
      await _LogFixtures.pump(
        tester,
        _LogHarness(key: key, initialBlock: _LogFixtures.single()),
      );
      await _LogFixtures.tap(tester, 'workout_runner_log_exercise_guide');
      await _LogFixtures.tap(tester, 'workout_runner_add_set');
      await _LogFixtures.tap(tester, 'workout_runner_add_note');
      expect(key.currentState!.opened, [1]);
      expect(key.currentState!.added, 1);
      expect(key.currentState!.noteCalls, [('member-1', 'active')]);
      await _LogFixtures.tap(tester, 'workout_runner_set_action_warmup');
      expect(key.currentState!.completedCalls, [('member-1', 'warmup', false)]);
      await _LogFixtures.tap(tester, 'workout_runner_skip_set_warmup');
      expect(key.currentState!.skippedCalls.last, ('member-1', 'warmup', true));
      await _LogFixtures.tap(tester, 'workout_runner_skip_set_warmup');
      expect(key.currentState!.skippedCalls.last, (
        'member-1',
        'warmup',
        false,
      ));
    },
  );

  testWidgets('logging prevents duplicate taps until its future completes', (
    tester,
  ) async {
    final key = GlobalKey<_LogHarnessState>();
    final pending = Completer<void>();
    await _LogFixtures.pump(
      tester,
      _LogHarness(
        key: key,
        initialBlock: _LogFixtures.single(),
        pendingLog: pending,
      ),
    );
    final action = find.byKey(const Key('workout_runner_set_action_active'));
    final invoke = tester.widget<IconButton>(action).onPressed!;
    invoke();
    invoke();
    expect(key.currentState!.logged, 1);
    await tester.pump();
    expect(tester.widget<IconButton>(action).onPressed, isNull);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('active_weight_field')))
          .enabled,
      isFalse,
    );
    pending.complete();
    await tester.pump();
    expect(tester.widget<IconButton>(action).onPressed, isNotNull);
  });

  testWidgets('paused and busy states disable mutation controls', (
    tester,
  ) async {
    await _LogFixtures.pump(
      tester,
      _LogHarness(initialBlock: _LogFixtures.single(), enabled: false),
    );
    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.enabled, isFalse);
    }
    for (final button in tester.widgetList<IconButton>(
      find.byType(IconButton),
    )) {
      expect(button.onPressed, isNull);
    }
    for (final button in tester.widgetList<TextButton>(
      find.byType(TextButton),
    )) {
      expect(button.onPressed, isNull);
    }
    for (final button in tester.widgetList<OutlinedButton>(
      find.byType(OutlinedButton),
    )) {
      expect(button.onPressed, isNull);
    }
  });

  testWidgets('incomplete actuals disable logging while input stays editable', (
    tester,
  ) async {
    final key = GlobalKey<_LogHarnessState>();
    await _LogFixtures.pump(
      tester,
      _LogHarness(key: key, initialBlock: _LogFixtures.single(), canLog: false),
    );
    final action = find.byKey(const Key('workout_runner_set_action_active'));
    expect(tester.widget<IconButton>(action).onPressed, isNull);
    final weight = find.byKey(const Key('active_weight_field'));
    expect(tester.widget<TextField>(weight).enabled, isTrue);
    await tester.ensureVisible(weight);
    await tester.enterText(weight, '25.5');
    await tester.pump();
    expect(key.currentState!.updated!.actualWeightKg, 25.5);
    expect(key.currentState!.logged, 0);
  });

  testWidgets(
    'completion actions expose one checked button with a 48px target',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await _LogFixtures.pump(
          tester,
          _LogHarness(initialBlock: _LogFixtures.single()),
        );
        final action = find.byKey(
          const Key('workout_runner_set_hit_target_warmup'),
        );
        expect(
          tester.getSemantics(action),
          isSemantics(
            isButton: true,
            hasTapAction: true,
            hasCheckedState: true,
            isChecked: true,
          ),
        );
        expect(
          tester.getSize(action).shortestSide,
          greaterThanOrEqualTo(AppWorkoutRunnerTokens.controlSize),
        );
      } finally {
        semantics.dispose();
      }
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      '320px, 2x text and full superset targets in ${brightness.name}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _LogFixtures.pump(
          tester,
          _LogHarness(initialBlock: _LogFixtures.paired()),
          brightness: brightness,
          textScale: 2,
        );
        expect(
          find.byKey(const Key('workout_runner_table_columns')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        final weight = find.byKey(const Key('active_weight_field'));
        await tester.ensureVisible(weight);
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(weight).height,
          greaterThanOrEqualTo(AppWorkoutRunnerTokens.controlSize),
        );
        final action = find.byKey(const Key('workout_runner_set_action_a-w0'));
        await tester.ensureVisible(action);
        expect(
          tester.getSize(action).shortestSide,
          greaterThanOrEqualTo(AppWorkoutRunnerTokens.controlSize),
        );
        await _LogFixtures.tap(tester, 'workout_runner_add_note');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
