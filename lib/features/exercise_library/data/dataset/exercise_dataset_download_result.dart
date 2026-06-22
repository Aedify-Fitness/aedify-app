import 'package:aedify/features/exercise_library/data/dataset/exercise_dataset_manifest.dart';

class ExerciseDatasetDownloadResult {
  const ExerciseDatasetDownloadResult({
    required this.manifest,
    required this.localRelativePath,
    required this.localAbsolutePath,
    required this.downloadedAt,
    required this.sizeBytes,
  });

  final ExerciseDatasetManifest manifest;
  final String localRelativePath;
  final String localAbsolutePath;
  final DateTime downloadedAt;
  final int sizeBytes;
}
