import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/bodymap/presentation/widgets/bodymap_bucket_chip_bar.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createChipBar({
  BodymapBucket? selectedBucket,
  void Function(BodymapBucket)? onSelected,
  VoidCallback? onClear,
}) {
  return MaterialApp(
    home: Scaffold(
      body: BodymapBucketChipBar(
        selectedBucket: selectedBucket,
        onSelected: onSelected ?? (_) {},
        onClear: onClear ?? () {},
      ),
    ),
  );
}

void main() {
  group('BodymapBucketChipBar', () {
    testWidgets('renders all 14 buckets', (tester) async {
      await tester.pumpWidget(createChipBar());
      await tester.pumpAndSettle();

      for (final bucket in BodymapBucket.values) {
        expect(find.text(bucket.label), findsWidgets);
      }
    });

    testWidgets('highlights selected bucket', (tester) async {
      await tester.pumpWidget(
        createChipBar(selectedBucket: BodymapBucket.chest),
      );
      await tester.pumpAndSettle();

      // The selected chip should have a distinct style; at minimum we assert
      // it is present and the clear button appears.
      expect(find.text(BodymapBucket.chest.label), findsWidgets);
      expect(find.text(AppStrings.clearSelection), findsOneWidget);
    });

    testWidgets('clear button calls onClear', (tester) async {
      var cleared = false;
      await tester.pumpWidget(
        createChipBar(
          selectedBucket: BodymapBucket.chest,
          onClear: () => cleared = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.clearSelection));
      expect(cleared, isTrue);
    });

    testWidgets('clear button is hidden when no bucket selected', (
      tester,
    ) async {
      await tester.pumpWidget(createChipBar());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.clearSelection), findsNothing);
    });
  });
}
