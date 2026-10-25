import 'dart:convert';
import 'dart:io';

import 'package:aedify/core/firebase/firebase_auth_service.dart';
import 'package:aedify/core/firebase/firebase_storage_client.dart';
import 'package:crypto/crypto.dart';

import 'exercise_library_fixture_dataset_builder.dart';
import 'exercise_library_fixture_manifest_builder.dart';

/// Replaces only the remote Firebase transport, preserving the real parser,
/// checksum checks, importer, SQLite storage, controllers and library screens.
class NativeDatasetStorageFixture implements FirebaseStorageClient {
  NativeDatasetStorageFixture() {
    final builder = ExerciseLibraryFixtureDatasetBuilder();
    for (final entry in [
      'strength',
      'cardio',
      'flexibility',
      'recovery',
    ].indexed) {
      builder.addExercise({
        'id': entry.$1 + 100,
        'name': 'Synthetic ${entry.$2} exercise',
        'difficulty': 'beginner',
        'primary_muscles': ['pectoralis major'],
        'muscle_groups': ['Chest'],
        'modality': entry.$2,
        'equipment': 'bodyweight',
        'mechanic': null,
        'force': null,
        'grips': <String>[],
        'steps': ['Move smoothly.'],
        'videos': <Object>[],
      });
    }
    dataset = jsonEncode(builder.build());
    manifest = jsonEncode(
      ExerciseLibraryFixtureManifestBuilder()
          .withExerciseCount(4)
          .withSizeBytes(utf8.encode(dataset).length)
          .withSha256(sha256.convert(utf8.encode(dataset)).toString())
          .build(),
    );
  }
  late final String dataset;
  late final String manifest;
  int downloadCount = 0;
  @override
  Future<String> getText(String remotePath) async => manifest;
  @override
  Future<void> downloadToFile({
    required String remotePath,
    required String localPath,
  }) async {
    downloadCount++;
    await File(localPath).writeAsString(dataset);
  }
}

class NativeDatasetAuthFixture implements FirebaseAuthService {
  @override
  Future<void> ensureAnonymousSignIn() async {}
}
