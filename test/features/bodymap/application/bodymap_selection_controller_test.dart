import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/application/bodymap_selection_controller.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/bodymap/domain/bodymap_view_side.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BodymapSelectionController', () {
    late ProviderContainer container;
    late BodymapSelectionController controller;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          AppProviders.bodymapSelectionControllerProvider.overrideWith(
            () => BodymapSelectionController(),
          ),
        ],
      );
      controller = container.read(
        AppProviders.bodymapSelectionControllerProvider.notifier,
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('defaults to front side with no selection', () {
      final state = container.read(
        AppProviders.bodymapSelectionControllerProvider,
      );
      expect(state.side, BodymapViewSide.front);
      expect(state.selectedBucket, isNull);
    });

    test('selectBucket updates selected bucket', () {
      controller.selectBucket(BodymapBucket.chest);
      final state = container.read(
        AppProviders.bodymapSelectionControllerProvider,
      );
      expect(state.selectedBucket, BodymapBucket.chest);
    });

    test('clearSelection clears bucket', () {
      controller.selectBucket(BodymapBucket.chest);
      controller.clearSelection();
      final state = container.read(
        AppProviders.bodymapSelectionControllerProvider,
      );
      expect(state.selectedBucket, isNull);
    });

    test('toggleSide switches front and back', () {
      controller.toggleSide();
      expect(
        container.read(AppProviders.bodymapSelectionControllerProvider).side,
        BodymapViewSide.back,
      );
      controller.toggleSide();
      expect(
        container.read(AppProviders.bodymapSelectionControllerProvider).side,
        BodymapViewSide.front,
      );
    });

    test('setSide updates side explicitly', () {
      controller.setSide(BodymapViewSide.back);
      expect(
        container.read(AppProviders.bodymapSelectionControllerProvider).side,
        BodymapViewSide.back,
      );
    });

    test('selectBucket replaces previous selection', () {
      controller.selectBucket(BodymapBucket.chest);
      controller.selectBucket(BodymapBucket.back);
      final state = container.read(
        AppProviders.bodymapSelectionControllerProvider,
      );
      expect(state.selectedBucket, BodymapBucket.back);
    });
  });
}
