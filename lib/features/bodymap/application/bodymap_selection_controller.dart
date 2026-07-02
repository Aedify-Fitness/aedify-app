import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/bodymap/domain/bodymap_view_side.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BodymapSelectionState {
  const BodymapSelectionState({required this.side, this.selectedBucket});

  final BodymapViewSide side;
  final BodymapBucket? selectedBucket;

  BodymapSelectionState copyWith({
    BodymapViewSide? side,
    BodymapBucket? selectedBucket,
    bool clearSelection = false,
  }) {
    return BodymapSelectionState(
      side: side ?? this.side,
      selectedBucket: clearSelection
          ? null
          : (selectedBucket ?? this.selectedBucket),
    );
  }
}

class BodymapSelectionController extends Notifier<BodymapSelectionState> {
  static final _logger = AppLogger(name: 'BodymapSelectionController');

  @override
  BodymapSelectionState build() {
    return const BodymapSelectionState(
      side: BodymapViewSide.front,
      selectedBucket: null,
    );
  }

  void selectBucket(BodymapBucket bucket) {
    _logger.debug('selectMuscle — group: ${bucket.name}');
    state = state.copyWith(selectedBucket: bucket);
  }

  void clearSelection() {
    state = state.copyWith(clearSelection: true);
  }

  void toggleSide() {
    state = state.copyWith(
      side: state.side == BodymapViewSide.front
          ? BodymapViewSide.back
          : BodymapViewSide.front,
    );
  }

  void setSide(BodymapViewSide side) {
    state = state.copyWith(side: side);
  }
}
