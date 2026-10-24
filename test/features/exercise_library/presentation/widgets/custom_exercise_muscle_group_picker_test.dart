import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_muscle_group_picker.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

abstract final class _MusclePickerFixtures {
  static void ignoreToggle(BodymapBucket bucket) {}

  static Widget app(Widget picker, {bool dark = false, double scale = 1}) {
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
          child: picker,
        ),
      ),
    );
  }

  static Finder chip(BodymapBucket bucket) =>
      find.byKey(ValueKey('custom_exercise_muscle_${bucket.name}'));
}

void main() {
  group('CustomExerciseMuscleGroupPicker', () {
    testWidgets('renders all 14 choices and the multi-select guidance', (
      tester,
    ) async {
      await tester.pumpWidget(
        _MusclePickerFixtures.app(
          const CustomExerciseMuscleGroupPicker(
            selected: {},
            onToggle: _MusclePickerFixtures.ignoreToggle,
          ),
        ),
      );
      expect(find.text(AppStrings.customExerciseMuscleGroups), findsOneWidget);
      expect(
        find.text(AppStrings.customExerciseMuscleGroupsHint),
        findsOneWidget,
      );
      expect(find.byType(TextButton), findsNWidgets(14));
      for (final bucket in BodymapBucket.values) {
        expect(_MusclePickerFixtures.chip(bucket), findsOneWidget);
      }
    });

    testWidgets('supports multiple selections and independent deselection', (
      tester,
    ) async {
      final selected = <BodymapBucket>{};
      await tester.pumpWidget(
        _MusclePickerFixtures.app(
          StatefulBuilder(
            builder: (context, setState) => CustomExerciseMuscleGroupPicker(
              selected: selected,
              onToggle: (bucket) => setState(() {
                if (!selected.remove(bucket)) selected.add(bucket);
              }),
            ),
          ),
        ),
      );
      await tester.tap(_MusclePickerFixtures.chip(BodymapBucket.chest));
      await tester.pump();
      await tester.tap(_MusclePickerFixtures.chip(BodymapBucket.shoulders));
      await tester.pump();
      expect(selected, {BodymapBucket.chest, BodymapBucket.shoulders});
      expect(
        tester.getSemantics(_MusclePickerFixtures.chip(BodymapBucket.chest)),
        isSemantics(
          isButton: true,
          isSelected: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(_MusclePickerFixtures.chip(BodymapBucket.chest));
      await tester.pump();
      expect(selected, {BodymapBucket.shoulders});
      expect(
        tester.getSemantics(_MusclePickerFixtures.chip(BodymapBucket.chest)),
        isSemantics(isSelected: false),
      );
    });

    testWidgets('disables every choice without losing selected semantics', (
      tester,
    ) async {
      var toggles = 0;
      await tester.pumpWidget(
        _MusclePickerFixtures.app(
          CustomExerciseMuscleGroupPicker(
            selected: const {BodymapBucket.chest},
            enabled: false,
            onToggle: (_) => toggles++,
          ),
        ),
      );
      final chip = _MusclePickerFixtures.chip(BodymapBucket.chest);
      await tester.tap(chip);
      expect(toggles, 0);
      expect(
        tester.getSemantics(chip),
        isSemantics(isSelected: true, isEnabled: false, hasTapAction: false),
      );
      for (final button in tester.widgetList<TextButton>(
        find.byType(TextButton),
      )) {
        expect(button.onPressed, isNull);
      }
    });

    testWidgets('announces field errors inline', (tester) async {
      await tester.pumpWidget(
        _MusclePickerFixtures.app(
          const CustomExerciseMuscleGroupPicker(
            selected: {},
            onToggle: _MusclePickerFixtures.ignoreToggle,
            errorText: AppStrings.customExerciseMissingFields,
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text(AppStrings.customExerciseMissingFields)),
        isSemantics(isLiveRegion: true),
      );
    });

    for (final dark in [false, true]) {
      testWidgets(
        'keeps all controls usable at 320px and 2x text in ${dark ? 'dark' : 'light'}',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          BodymapBucket? toggled;
          await tester.pumpWidget(
            _MusclePickerFixtures.app(
              CustomExerciseMuscleGroupPicker(
                selected: const {},
                onToggle: (value) => toggled = value,
              ),
              dark: dark,
              scale: 2,
            ),
          );
          for (final bucket in BodymapBucket.values) {
            final chip = _MusclePickerFixtures.chip(bucket);
            await tester.ensureVisible(chip);
            final ink = find.descendant(
              of: chip,
              matching: find.byType(InkWell),
            );
            expect(tester.getSize(ink).height, greaterThanOrEqualTo(48));
            expect(tester.getSize(ink).width, greaterThanOrEqualTo(48));
            expect(tester.takeException(), isNull);
          }
          await tester.tap(_MusclePickerFixtures.chip(BodymapBucket.feet));
          expect(toggled, BodymapBucket.feet);
        },
      );
    }
  });
}
