import 'dart:convert';
import 'dart:io';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
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
  static final _logger = AppLogger(name: 'FirebaseStorageClient');

  FirebaseStorageClient({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> getText(String remotePath) async {
    try {
      final ref = _storage.ref(remotePath);
      final data = await ref.getData();
      if (data == null) {
        throw FirebaseStorageFailure(
          code: AppErrorCodes.notFound,
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
    _logger.info(
      'downloadToFile — start',
      metadata: {'remotePath': remotePath, 'localPath': localPath},
    );
    try {
      final ref = _storage.ref(remotePath);
      final file = File(localPath);
      await ref.writeToFile(file);
      _logger.info(
        'downloadToFile — complete',
        metadata: {'localPath': localPath},
      );
    } on FirebaseException catch (e) {
      _logger.error('downloadToFile failed', error: e);
      throw FirebaseStorageFailure(
        code: e.code,
        message: e.message ?? AppErrorStrings.downloadFailedMessage,
      );
    }
  }
}
