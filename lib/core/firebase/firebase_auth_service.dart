import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthFailure implements Exception {
  const FirebaseAuthFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'FirebaseAuthFailure($code): $message';
}

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<void> ensureAnonymousSignIn() async {
    if (_auth.currentUser != null) return;
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthFailure(
        code: e.code,
        message: e.message ?? 'Anonymous sign-in failed',
      );
    }
  }
}
