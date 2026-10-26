import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_block.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_exercise_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_item.dart';
import 'package:aedify/features/workout_execution/domain/workout_runner_set_policy.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_training_log.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ActualEntryHarness extends StatefulWidget {
  const _ActualEntryHarness({
    super.key,
    this.type = ExerciseLoggingType.repsWeight,
  });
  final ExerciseLoggingType type;
  bool get timed => type == ExerciseLoggingType.duration;

  @override
  State<_ActualEntryHarness> createState() => _ActualEntryHarnessState();
}

class _ActualEntryHarnessState extends State<_ActualEntryHarness> {
  late WorkoutRunnerSetItem set;
  int logged = 0;

  @override
  void initState() {
    super.initState();
    set = WorkoutRunnerSetItem(
      id: 'set',
      exerciseId: 1,
      setIndex: 0,
      setType: SetType.working,
      performedAt: DateTime(2026),
      completed: false,
      skipped: false,
      prescribedRepsExact: widget.timed ? null : 8,
      prescribedWeightKg: widget.type == ExerciseLoggingType.repsWeight
          ? 40
          : null,
      prescribedDurationSeconds: widget.timed ? 90 : null,
      prescribedDistanceMeters: widget.timed ? 300 : null,
      prescribedRir: 2,
      notes: 'Technique note',
    );
  }

  @override
  Widget build(BuildContext context) => WorkoutRunnerTrainingLog(
    block: WorkoutRunnerBlock(
      members: [
        WorkoutRunnerExerciseItem(
          id: 'exercise',
          exerciseId: 1,
          exerciseName: 'Movement',
          sortOrder: 0,
          loggingType: widget.type,
          sets: [set],
        ),
      ],
    ),
    activeSet: set,
    enabled: true,
    canLogSet: WorkoutRunnerSetPolicy.canComplete(
      set,
      loggingType: widget.type,
    ),
    onUpdateSet: (_, updated) => setState(() => set = updated),
    onToggleCompleted: (_, _, _) {},
    onLogSet: () async {
      logged++;
    },
    onAddSet: () {},
    onAddNote: (_, _) {},
    onShowExercise: (_) {},
  );
}

abstract final class _ActualEntryFixtures {
  static Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool dark = false,
    double textScale = 1,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );

  static Future<void> enter(
    WidgetTester tester,
    String key,
    String value,
  ) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.enterText(finder, value);
    await tester.pump();
  }
}

void main() {
  testWidgets(
    'targets stay hints; effort, warmup and clear edits preserve metadata',
    (tester) async {
      final key = GlobalKey<_ActualEntryHarnessState>();
      await _ActualEntryFixtures.pump(tester, _ActualEntryHarness(key: key));
      final weight = tester.widget<TextField>(
        find.byKey(const Key('active_weight_field')),
      );
      expect(weight.controller!.text, isEmpty);
      expect(weight.decoration!.hintText, '40');
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const Key('workout_runner_set_action_set')),
            )
            .onPressed,
        isNull,
      );
      await _ActualEntryFixtures.enter(tester, 'active_weight_field', '42.5');
      await _ActualEntryFixtures.enter(tester, 'active_reps_field', '7');
      await _ActualEntryFixtures.enter(tester, 'active_rpe_field', '8.5');
      expect(find.byKey(const Key('active_rir_field')), findsNothing);
      expect(key.currentState!.set.actualRir, 2);
      await _ActualEntryFixtures.enter(tester, 'active_rpe_field', '10');
      expect(key.currentState!.set.actualRir, 0);
      await _ActualEntryFixtures.enter(tester, 'active_rpe_field', '8.5');
      await _ActualEntryFixtures.enter(tester, 'active_rpe_field', '.');
      expect(key.currentState!.set.actualRpe, 8.5);
      expect(find.byKey(const Key('active_duration_field')), findsNothing);
      expect(find.byKey(const Key('active_distance_field')), findsNothing);
      expect(key.currentState!.set.actualRpe, 8.5);
      expect(key.currentState!.set.actualRir, 2);
      expect(key.currentState!.set.actualDurationSeconds, isNull);
      expect(key.currentState!.set.actualDistanceMeters, isNull);
      final warmup = find.byKey(const Key('workout_runner_set_type_set'));
      await tester.ensureVisible(warmup);
      await tester.tap(warmup);
      await tester.pump();
      expect(key.currentState!.set.setType, SetType.warmup);
      await tester.tap(warmup);
      await tester.pump();
      expect(key.currentState!.set.setType, SetType.working);
      expect(key.currentState!.set.actualWeightKg, 42.5);
      expect(key.currentState!.set.actualReps, 7);
      await _ActualEntryFixtures.enter(tester, 'active_rpe_field', '11');
      expect(find.text(AppErrorStrings.workoutActualsInvalid), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const Key('workout_runner_set_action_set')),
            )
            .onPressed,
        isNull,
      );
      await _ActualEntryFixtures.enter(tester, 'active_rpe_field', '');
      expect(key.currentState!.set.actualRpe, isNull);
      expect(key.currentState!.set.actualRir, isNull);
      expect(key.currentState!.set.prescribedRepsExact, 8);
      expect(key.currentState!.set.prescribedWeightKg, 40);
      expect(key.currentState!.set.prescribedRir, 2);
      expect(key.currentState!.set.actualDurationSeconds, isNull);
      expect(key.currentState!.set.notes, 'Technique note');
      await _ActualEntryFixtures.enter(tester, 'active_reps_field', '');
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const Key('workout_runner_set_action_set')),
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final type in ExerciseLoggingType.values) {
    testWidgets('${type.name} exposes matching header and inline actuals', (
      tester,
    ) async {
      final key = GlobalKey<_ActualEntryHarnessState>();
      await _ActualEntryFixtures.pump(
        tester,
        _ActualEntryHarness(key: key, type: type),
      );
      final headings = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const Key('workout_runner_table_columns')),
              matching: find.byType(Text),
            ),
          )
          .map((text) => text.data)
          .toList();
      expect(headings, [
        AppStrings.setNumberColumn,
        AppStrings.targetColumn,
        ...switch (type) {
          ExerciseLoggingType.repsWeight => [
            AppStrings.kilogramsAbbreviation,
            AppStrings.repsColumn,
          ],
          ExerciseLoggingType.repsOnly => [AppStrings.repsColumn],
          ExerciseLoggingType.duration => [
            AppStrings.durationColumn,
            AppStrings.distanceColumn,
          ],
        },
        AppStrings.rpe,
        AppStrings.logColumn,
      ]);
      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.textContaining(AppStrings.rir), findsNothing);
      expect(find.textContaining('${AppStrings.rpe} 8'), findsOneWidget);
      final fields = switch (type) {
        ExerciseLoggingType.repsWeight => ['weight', 'reps', 'rpe'],
        ExerciseLoggingType.repsOnly => ['reps', 'rpe'],
        ExerciseLoggingType.duration => ['duration', 'distance', 'rpe'],
      };
      expect(
        tester.widgetList<TextField>(find.byType(TextField)).length,
        fields.length,
      );
      for (final field in fields) {
        expect(find.byKey(Key('active_${field}_field')), findsOneWidget);
      }
      if (type == ExerciseLoggingType.repsOnly) {
        await _ActualEntryFixtures.enter(tester, 'active_reps_field', '12');
        final log = find.byKey(const Key('workout_runner_set_action_set'));
        await tester.ensureVisible(log);
        await tester.tap(log);
        await tester.pump();
        expect(key.currentState!.logged, 1);
        expect(key.currentState!.set.actualWeightKg, isNull);
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final dark in [false, true]) {
    testWidgets(
      'timed actuals work at 320px and 2x text in ${dark ? 'dark' : 'light'} theme',
      (tester) async {
        tester.view.physicalSize = const Size(320, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey<_ActualEntryHarnessState>();
        await _ActualEntryFixtures.pump(
          tester,
          _ActualEntryHarness(key: key, type: ExerciseLoggingType.duration),
          dark: dark,
          textScale: 2,
        );
        expect(find.byKey(const Key('active_weight_field')), findsNothing);
        expect(find.byKey(const Key('active_reps_field')), findsNothing);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('active_duration_field')))
              .controller!
              .text,
          isEmpty,
        );
        await _ActualEntryFixtures.enter(tester, 'active_duration_field', '95');
        final log = find.byKey(const Key('workout_runner_set_action_set'));
        expect(tester.widget<IconButton>(log).onPressed, isNotNull);
        await _ActualEntryFixtures.enter(tester, 'active_rpe_field', '7.5');
        expect(key.currentState!.set.actualRir, 3);
        expect(find.byKey(const Key('active_rir_field')), findsNothing);
        await _ActualEntryFixtures.enter(
          tester,
          'active_distance_field',
          '310',
        );
        await tester.ensureVisible(log);
        await tester.tap(log);
        await tester.pumpAndSettle();
        expect(key.currentState!.logged, 1);
        expect(key.currentState!.set.actualDurationSeconds, 95);
        expect(key.currentState!.set.actualDistanceMeters, 310);
        expect(key.currentState!.set.prescribedDurationSeconds, 90);
        expect(key.currentState!.set.prescribedDistanceMeters, 300);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
