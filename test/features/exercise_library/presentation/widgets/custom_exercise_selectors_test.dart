import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_equipment_difficulty_section.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_logging_type_picker.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_modality_section.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

abstract final class _SelectorFixtures {
  static Widget app(Widget child, {bool dark = false, double scale = 1}) {
    return MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: child,
        ),
      ),
    );
  }

  static Finder key(String key) => find.byKey(ValueKey(key));

  static Finder get equipment => find.byType(DropdownButton<EquipmentTag>);
}

void main() {
  testWidgets('modality offers all four choices with exclusive selection', (
    tester,
  ) async {
    var modality = ExerciseModality.strength;
    await tester.pumpWidget(
      _SelectorFixtures.app(
        StatefulBuilder(
          builder: (context, setState) => CustomExerciseModalitySection(
            modality: modality,
            onChanged: (value) => setState(() => modality = value),
          ),
        ),
      ),
    );
    for (final value in ExerciseModality.values) {
      expect(
        _SelectorFixtures.key('custom_exercise_modality_${value.name}'),
        findsOneWidget,
      );
    }
    await tester.tap(_SelectorFixtures.key('custom_exercise_modality_cardio'));
    await tester.pump();
    expect(modality, ExerciseModality.cardio);
    expect(
      tester.getSemantics(
        _SelectorFixtures.key('custom_exercise_modality_cardio'),
      ),
      isSemantics(
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        isEnabled: true,
      ),
    );
    expect(
      tester.getSemantics(
        _SelectorFixtures.key('custom_exercise_modality_strength'),
      ),
      isSemantics(isSelected: false),
    );
  });

  testWidgets(
    'equipment retains all tags and difficulty retains all four levels',
    (tester) async {
      EquipmentTag? equipment;
      ExerciseDifficulty? difficulty;
      await tester.pumpWidget(
        _SelectorFixtures.app(
          StatefulBuilder(
            builder: (context, setState) =>
                CustomExerciseEquipmentDifficultySection(
                  equipment: equipment,
                  onEquipmentChanged: (value) =>
                      setState(() => equipment = value),
                  difficulty: difficulty,
                  onDifficultyChanged: (value) =>
                      setState(() => difficulty = value),
                ),
          ),
        ),
      );
      final dropdown = tester.widget<DropdownButton<EquipmentTag>>(
        _SelectorFixtures.equipment,
      );
      expect(dropdown.items!.map((item) => item.value), EquipmentTag.values);
      expect(dropdown.value, isNull);
      await tester.tap(_SelectorFixtures.equipment);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bodyweight').last);
      await tester.pumpAndSettle();
      expect(equipment, EquipmentTag.bodyweight);
      expect(
        tester
            .widget<DropdownButton<EquipmentTag>>(_SelectorFixtures.equipment)
            .value,
        equipment,
      );

      for (final value in ExerciseDifficulty.values) {
        expect(
          _SelectorFixtures.key('custom_exercise_difficulty_${value.name}'),
          findsOneWidget,
        );
      }
      await tester.tap(
        _SelectorFixtures.key('custom_exercise_difficulty_advanced'),
      );
      await tester.pump();
      expect(difficulty, ExerciseDifficulty.advanced);
      await tester.tap(
        _SelectorFixtures.key('custom_exercise_difficulty_advanced'),
      );
      expect(difficulty, ExerciseDifficulty.advanced);
    },
  );

  testWidgets('disabled equipment, modality and difficulty ignore input', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      _SelectorFixtures.app(
        Column(
          children: [
            CustomExerciseEquipmentDifficultySection(
              equipment: EquipmentTag.barbell,
              onEquipmentChanged: (_) => changes++,
              difficulty: ExerciseDifficulty.beginner,
              onDifficultyChanged: (_) => changes++,
              enabled: false,
            ),
            AppWhiteSpace.hLg,
            CustomExerciseModalitySection(
              modality: ExerciseModality.strength,
              onChanged: (_) => changes++,
              enabled: false,
            ),
          ],
        ),
      ),
    );
    expect(
      tester
          .widget<DropdownButton<EquipmentTag>>(_SelectorFixtures.equipment)
          .onChanged,
      isNull,
    );
    for (final button in tester.widgetList<TextButton>(
      find.byType(TextButton),
    )) {
      expect(button.onPressed, isNull);
    }
    await tester.tap(_SelectorFixtures.equipment);
    await tester.tap(
      _SelectorFixtures.key('custom_exercise_difficulty_advanced'),
    );
    expect(changes, 0);
  });

  testWidgets('logging rows select exact types and expose selected semantics', (
    tester,
  ) async {
    ExerciseLoggingType? selected;
    await tester.pumpWidget(
      _SelectorFixtures.app(
        StatefulBuilder(
          builder: (context, setState) => CustomExerciseLoggingTypePicker(
            selected: selected,
            onChanged: (value) => setState(() => selected = value),
          ),
        ),
      ),
    );
    for (final choice in [
      (key: 'reps_only', value: ExerciseLoggingType.repsOnly),
      (key: 'weight_reps', value: ExerciseLoggingType.repsWeight),
      (key: 'duration', value: ExerciseLoggingType.duration),
    ]) {
      final row = _SelectorFixtures.key(
        'custom_exercise_logging_${choice.key}',
      );
      await tester.tap(row);
      await tester.pump();
      expect(selected, choice.value);
      expect(
        tester.getSemantics(row),
        isSemantics(
          isButton: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
    }
  });

  testWidgets(
    'disabled logging rows keep selection and disable tap semantics',
    (tester) async {
      var changes = 0;
      await tester.pumpWidget(
        _SelectorFixtures.app(
          CustomExerciseLoggingTypePicker(
            selected: ExerciseLoggingType.repsWeight,
            onChanged: (_) => changes++,
            enabled: false,
          ),
        ),
      );
      final row = _SelectorFixtures.key('custom_exercise_logging_weight_reps');
      await tester.tap(row);
      expect(changes, 0);
      expect(
        tester.getSemantics(row),
        isSemantics(isSelected: true, isEnabled: false, hasTapAction: false),
      );
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'choices wrap and logging rows grow at 320px/2x in ${dark ? 'dark' : 'light'}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          _SelectorFixtures.app(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomExerciseEquipmentDifficultySection(
                  equipment: EquipmentTag.cardioMachine,
                  onEquipmentChanged: (_) {},
                  difficulty: ExerciseDifficulty.intermediate,
                  onDifficultyChanged: (_) {},
                ),
                AppWhiteSpace.hLg,
                CustomExerciseModalitySection(
                  modality: ExerciseModality.flexibility,
                  onChanged: (_) {},
                ),
                AppWhiteSpace.hLg,
                CustomExerciseLoggingTypePicker(
                  selected: ExerciseLoggingType.repsWeight,
                  onChanged: (_) {},
                ),
              ],
            ),
            dark: dark,
            scale: 2,
          ),
        );
        for (final value in ExerciseDifficulty.values) {
          final button = _SelectorFixtures.key(
            'custom_exercise_difficulty_${value.name}',
          );
          await tester.ensureVisible(button);
          final ink = find.descendant(
            of: button,
            matching: find.byType(InkWell),
          );
          expect(tester.getSize(ink).height, greaterThanOrEqualTo(48));
        }
        final rows = [
          _SelectorFixtures.key('custom_exercise_logging_reps_only'),
          _SelectorFixtures.key('custom_exercise_logging_weight_reps'),
          _SelectorFixtures.key('custom_exercise_logging_duration'),
        ];
        for (final row in rows) {
          await tester.ensureVisible(row);
          expect(tester.getSize(row).width, 288);
          expect(tester.getSize(row).height, greaterThanOrEqualTo(48));
          expect(tester.takeException(), isNull);
        }
        expect(
          find.text(AppStrings.customExerciseLoggingTypeDurationDesc),
          findsOneWidget,
        );
      },
    );
  }
}
