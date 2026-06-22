import 'dart:convert';
import 'dart:io';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageFailure implements Exception {
  const FirebaseStorageFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'FirebaseStorageFailure($code): $message';
}

class FirebaseStorageClient {
  FirebaseStorageClient({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> getText(String remotePath) async {
    try {
      final ref = _storage.ref(remotePath);
      final data = await ref.getData();
      if (data == null) {
        throw FirebaseStorageFailure(
          code: 'not_found',
          message: 'No data at $remotePath',
        );
      }
      return utf8.decode(data);
    } on FirebaseException catch (e) {
      throw FirebaseStorageFailure(
        code: e.code,
        message: e.message ?? AppErrorStrings.storageErrorMessage,
      );
    }
  }

  Future<void> downloadToFile({
    required String remotePath,
    required String localPath,
  }) async {
    try {
      final ref = _storage.ref(remotePath);
      final file = File(localPath);
      await ref.writeToFile(file);
    } on FirebaseException catch (e) {
      throw FirebaseStorageFailure(
        code: e.code,
        message: e.message ?? AppErrorStrings.downloadFailedMessage,
      );
    }
  }
}
