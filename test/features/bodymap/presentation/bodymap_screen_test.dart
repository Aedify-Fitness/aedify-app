import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/application/bodymap_selection_controller.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/bodymap/domain/bodymap_view_side.dart';
import 'package:aedify/features/bodymap/presentation/bodymap_screen.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/application/exercise_search_controller.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createBodymapApp({
  BodymapSelectionState? initialState,
  ExerciseFilterState? filterState,
}) {
  return ProviderScope(
    overrides: [
      AppProviders.bodymapSelectionControllerProvider.overrideWith(
        () => BodymapSelectionController(),
      ),
      if (initialState != null)
        AppProviders.bodymapSelectionControllerProvider.overrideWith(() {
          final c = BodymapSelectionController();
          c.selectBucket(initialState.selectedBucket ?? BodymapBucket.chest);
          if (initialState.side == BodymapViewSide.back) c.toggleSide();
          return c;
        }),
      AppProviders.exerciseSearchControllerProvider.overrideWith(() {
        final c = ExerciseSearchController();
        if (filterState != null) c.updateFilters(filterState);
        return c;
      }),
    ],
    child: const MaterialApp(home: BodymapScreen()),
  );
}

void main() {
  group('BodymapScreen', () {
    testWidgets('renders front side by default', (tester) async {
      await tester.pumpWidget(createBodymapApp());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.bodymap), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('bodymap_svg_front')),
        findsOneWidget,
      );

      final frontControl = tester.widget<Semantics>(
        find.byKey(const ValueKey<String>('bodymap_side_front')),
      );
      expect(frontControl.properties.selected, isTrue);
    });

    testWidgets('selects the back side via segmented control', (tester) async {
      await tester.pumpWidget(createBodymapApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('bodymap_side_back')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('bodymap_svg_back')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('bodymap_svg_front')),
        findsNothing,
      );

      final backControl = tester.widget<Semantics>(
        find.byKey(const ValueKey<String>('bodymap_side_back')),
      );
      expect(backControl.properties.selected, isTrue);
    });

    testWidgets('selected bucket shows context and browse action', (
      tester,
    ) async {
      await tester.pumpWidget(createBodymapApp());
      await tester.pumpAndSettle();

      final chestChip = find.byKey(
        const ValueKey<String>('bodymap_bucket_chest'),
      );
      await tester.ensureVisible(chestChip);
      await tester.pumpAndSettle();
      await tester.tap(chestChip);
      await tester.pumpAndSettle();

      final contextPanel = find.byKey(
        const ValueKey<String>('bodymap_selection_context'),
      );
      await tester.ensureVisible(contextPanel);
      await tester.pumpAndSettle();

      expect(contextPanel, findsOneWidget);
      expect(
        find.descendant(
          of: contextPanel,
          matching: find.text(BodymapBucket.chest.label),
        ),
        findsOneWidget,
      );

      final browseButton = find.text(AppStrings.browseByMuscle);
      await tester.ensureVisible(browseButton);
      await tester.pumpAndSettle();

      expect(browseButton, findsOneWidget);
    });

    testWidgets('hides browse button when no bucket selected', (tester) async {
      await tester.pumpWidget(createBodymapApp());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.browseByMuscle), findsNothing);
    });
  });
}
