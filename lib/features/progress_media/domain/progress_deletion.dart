import 'package:aedify/shared/constants/app_error_strings.dart';

enum ProgressDeletionFailure implements Exception {
  unavailable;

  String get message => AppErrorStrings.progressDeletionFailed;
}

/// Aggregate local storage state; no private paths, notes or record IDs.
class ProgressCleanupStatus {
  const ProgressCleanupStatus({
    this.sessionCount = 0,
    this.activeBytes = 0,
    this.pendingFiles = 0,
    this.pendingBytes = 0,
    this.retryNeeded = false,
  });
  final int sessionCount;
  final int activeBytes;
  final int pendingFiles;
  final int pendingBytes;
  final bool retryNeeded;
  bool get pending => retryNeeded || pendingFiles > 0;
}
