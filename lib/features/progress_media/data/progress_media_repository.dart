import 'package:aedify/features/progress_media/domain/progress_media.dart';

/// Private local storage boundary; no network, export or AI dependencies.
abstract interface class ProgressMediaRepository {
  /// Commits metadata and file registrations atomically for staged files.
  /// Failed saves leave staging files owned by the caller for retry/cancel.
  Future<void> saveSession(ProgressMediaSessionDraft draft);

  Future<List<ProgressMediaSession>> loadTimeline();
  Stream<List<ProgressMediaSession>> watchTimeline();
  Future<ProgressMediaSessionDetails?> getSessionDetails(String sessionId);
  Future<ProgressMediaSession?> getBaselineSession();
  Future<ProgressMediaSession?> getLatestSession();
  Future<List<ProgressMediaPosePair>> getComparablePosePairs(
    String firstSessionId,
    String secondSessionId,
  );
  Future<void> setBaseline(String sessionId);
  Future<void> updateNotes(String sessionId, String? notes);
  Future<ProgressMediaReminderState> getReminderState();

  /// Registered bytes including thumbnails/frames; not a full disk scan.
  Future<ProgressMediaStorageUsage> getStorageUsage();
}
