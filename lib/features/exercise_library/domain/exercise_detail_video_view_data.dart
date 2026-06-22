class ExerciseDetailVideoViewData {
  const ExerciseDetailVideoViewData({
    required this.url,
    required this.angle,
    required this.gender,
    required this.ogImageUrl,
  });

  final String url;
  final String? angle;
  final String? gender;
  final String? ogImageUrl;

  bool get hasThumbnail => ogImageUrl != null && ogImageUrl!.isNotEmpty;
}
