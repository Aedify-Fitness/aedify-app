import 'package:aedify/features/progress_media/domain/progress_media.dart';

enum ProgressComparisonMode { baselineLatest, previousLatest, anyTwo }

/// Ephemeral filters never write to the profile or persisted media records.
class ProgressGalleryFilter {
  const ProgressGalleryFilter({this.type, this.pose, this.from, this.through});
  final ProgressMediaType? type;
  final ProgressMediaPose? pose;
  final DateTime? from;
  final DateTime? through;

  bool matches(ProgressMediaSession session) {
    final date = session.capturedAt.toLocal();
    final day = DateTime(date.year, date.month, date.day);
    return (type == null ||
            session.mediaType == type ||
            session.mediaType == ProgressMediaType.both) &&
        (from == null || !day.isBefore(from!)) &&
        (through == null || !day.isAfter(through!));
  }
}

abstract final class ProgressComparisonPolicy {
  static List<ProgressMediaPosePair> photoPairs(
    ProgressMediaSessionDetails first,
    ProgressMediaSessionDetails second,
  ) {
    final pairs = <ProgressMediaPosePair>[];
    for (final pose in const [
      ProgressMediaPose.front,
      ProgressMediaPose.back,
      ProgressMediaPose.leftSide,
      ProgressMediaPose.rightSide,
    ]) {
      final a = first.items
          .where(
            (i) =>
                i.file.type == ProgressMediaItemType.photo &&
                i.file.pose == pose,
          )
          .firstOrNull;
      final b = second.items
          .where(
            (i) =>
                i.file.type == ProgressMediaItemType.photo &&
                i.file.pose == pose,
          )
          .firstOrNull;
      if (a != null && b != null) {
        pairs.add(ProgressMediaPosePair(pose: pose, first: a, second: b));
      }
    }
    return List.unmodifiable(pairs);
  }

  /// Latest/previous use the repository's deterministic capture-date ordering.
  static ({String first, String second})? select(
    List<ProgressMediaSession> sessions,
    ProgressComparisonMode mode, {
    String? first,
    String? second,
  }) {
    if (sessions.length < 2) return null;
    final latest = sessions.first.id;
    final baseline = sessions.where((s) => s.isBaseline).firstOrNull?.id;
    final pair = switch (mode) {
      ProgressComparisonMode.baselineLatest => (
        first: baseline,
        second: latest,
      ),
      ProgressComparisonMode.previousLatest => (
        first: sessions[1].id,
        second: latest,
      ),
      ProgressComparisonMode.anyTwo => (first: first, second: second),
    };
    if (pair.first == null ||
        pair.second == null ||
        pair.first == pair.second ||
        !sessions.any((s) => s.id == pair.first) ||
        !sessions.any((s) => s.id == pair.second)) {
      return null;
    }
    return (first: pair.first!, second: pair.second!);
  }
}

/// Stable cover/label order is independent of random storage IDs.
abstract final class ProgressGalleryPolicy {
  static List<ProgressMediaItem> originals(
    ProgressMediaSessionDetails details,
  ) {
    const order = [
      ProgressMediaPose.front,
      ProgressMediaPose.back,
      ProgressMediaPose.leftSide,
      ProgressMediaPose.rightSide,
      ProgressMediaPose.allSidesVideo,
      ProgressMediaPose.unknown,
    ];
    return details.items.where((i) => i.file.type.isOriginal).toList()..sort(
      (a, b) =>
          order.indexOf(a.file.pose).compareTo(order.indexOf(b.file.pose)),
    );
  }
}
