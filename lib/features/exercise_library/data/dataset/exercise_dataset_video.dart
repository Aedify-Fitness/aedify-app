class ExerciseDatasetVideo {
  const ExerciseDatasetVideo({
    required this.url,
    required this.angle,
    required this.gender,
    this.ogImage,
  });

  final Uri url;
  final String angle;
  final String gender;
  final String? ogImage;
}
