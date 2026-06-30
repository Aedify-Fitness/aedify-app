import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_muscle_group_picker.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _createTestApp(CustomExerciseMuscleGroupPicker picker) {
  return MaterialApp(home: Scaffold(body: picker));
}

void main() {
  group('CustomExerciseMuscleGroupPicker', () {
    testWidgets('renders title label', (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseMuscleGroupPicker(
            selected: {},
            onToggle: _onToggle,
          ),
        ),
      );

      expect(find.text(AppStrings.customExerciseMuscleGroups), findsOneWidget);
    });

    testWidgets('renders a chip for each bodymap bucket', (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseMuscleGroupPicker(
            selected: {},
            onToggle: _onToggle,
          ),
        ),
      );

      for (final bucket in BodymapBucket.values) {
        expect(find.text(bucket.label), findsWidgets);
      }
    });

    testWidgets('highlights selected groups', (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseMuscleGroupPicker(
            selected: {BodymapBucket.chest, BodymapBucket.shoulders},
            onToggle: _onToggle,
          ),
        ),
      );

      final chestChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Chest'),
          matching: find.byType(FilterChip),
        ),
      );
      final shouldersChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Shoulders'),
          matching: find.byType(FilterChip),
        ),
      );
      final backChip = tester.widget<FilterChip>(
        find.ancestor(of: find.text('Back'), matching: find.byType(FilterChip)),
      );

      expect(chestChip.selected, isTrue);
      expect(shouldersChip.selected, isTrue);
      expect(backChip.selected, isFalse);
    });

    testWidgets('shows error text when provided', (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseMuscleGroupPicker(
            selected: {},
            onToggle: _onToggle,
            errorText: 'At least one muscle group is required.',
          ),
        ),
      );

      expect(
        find.text('At least one muscle group is required.'),
        findsOneWidget,
      );
    });

    testWidgets('does not show error text when null', (tester) async {
      await tester.pumpWidget(
        _createTestApp(
          const CustomExerciseMuscleGroupPicker(
            selected: {},
            onToggle: _onToggle,
          ),
        ),
      );

      expect(find.text('At least one muscle group is required.'), findsNothing);
    });

    testWidgets('calls onToggle when a chip is tapped', (tester) async {
      BodymapBucket? toggledBucket;
      await tester.pumpWidget(
        _createTestApp(
          CustomExerciseMuscleGroupPicker(
            selected: {},
            onToggle: (bucket) => toggledBucket = bucket,
          ),
        ),
      );

      await tester.tap(find.text('Chest'));
      await tester.pump();

      expect(toggledBucket, BodymapBucket.chest);
    });
  });
}

void _onToggle(BodymapBucket bucket) {}
