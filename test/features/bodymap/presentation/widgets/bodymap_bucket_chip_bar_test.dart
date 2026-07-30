import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/bodymap/presentation/widgets/bodymap_bucket_chip_bar.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

      final selectedPill = find.byKey(
        const ValueKey<String>('bodymap_bucket_chest'),
      );
      final semantics = tester.widget<Semantics>(selectedPill);

      expect(semantics.properties.selected, isTrue);
      expect(
        find.descendant(of: selectedPill, matching: find.byType(SvgPicture)),
        findsOneWidget,
      );
      expect(
        tester.getSize(selectedPill).height,
        greaterThanOrEqualTo(AppSizing.cardBadge),
      );
    });

    testWidgets('tapping selected bucket calls onClear', (tester) async {
      var cleared = false;
      await tester.pumpWidget(
        createChipBar(
          selectedBucket: BodymapBucket.chest,
          onClear: () => cleared = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('bodymap_bucket_chest')),
      );
      expect(cleared, isTrue);
    });

    testWidgets('tapping bucket calls onSelected', (tester) async {
      BodymapBucket? selected;
      await tester.pumpWidget(
        createChipBar(onSelected: (bucket) => selected = bucket),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('bodymap_bucket_chest')),
      );

      expect(selected, BodymapBucket.chest);
    });
  });
}
