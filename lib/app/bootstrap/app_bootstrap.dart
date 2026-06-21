import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/firebase/firebase_bootstrap.dart';
import 'package:aedify/core/network/network_status.dart';

enum BootstrapState { initializing, success, error }

class AppBootstrap {
  AppBootstrap({
    AppDatabase? database,
    FirebaseBootstrap? firebase,
    NetworkStatus? networkStatus,
  }) : _firebase = firebase;

  final FirebaseBootstrap? _firebase;

  Future<BootstrapState> initialize() async {
    try {
      if (_firebase != null) {
        await _firebase.initialize();
      }
      return BootstrapState.success;
    } catch (e) {
      return BootstrapState.error;
    }
  }
}

final bootstrapControllerProvider = Provider<AppBootstrap>((ref) {
  return AppBootstrap();
});

final bootstrapStateProvider = Provider<BootstrapState>((ref) {
  return BootstrapState.initializing;
});
