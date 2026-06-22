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
      expect(find.text(AppStrings.bodymapFront), findsOneWidget);
    });

    testWidgets('toggles to back side via button', (tester) async {
      await tester.pumpWidget(createBodymapApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('front'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.bodymapBack), findsWidgets);
    });

    testWidgets('browse button appears when bucket selected', (tester) async {
      await tester.pumpWidget(createBodymapApp());
      await tester.pumpAndSettle();

      final chestChip = find.text('Chest').last;
      await tester.ensureVisible(chestChip);
      await tester.pumpAndSettle();
      await tester.tap(chestChip);
      await tester.pumpAndSettle();

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
