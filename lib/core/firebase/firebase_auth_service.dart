import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthFailure implements Exception {
  const FirebaseAuthFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'FirebaseAuthFailure($code): $message';
}

class FirebaseAuthService {
  static final _logger = AppLogger(name: 'FirebaseAuthService');

  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<void> ensureAnonymousSignIn() async {
    _logger.info('ensureSignedIn');
    if (_auth.currentUser != null) return;
    try {
      final result = await _auth.signInAnonymously();
      final user = result.user;
      if (user != null) {
        _logger.info('ensureSignedIn — signed in', metadata: {'uid': user.uid});
      }
    } on FirebaseAuthException catch (e) {
      _logger.error('ensureSignedIn failed', error: e);
      throw FirebaseAuthFailure(
        code: e.code,
        message: e.message ?? AppErrorStrings.anonymousSignInFailedMessage,
      );
    }
  }
}
