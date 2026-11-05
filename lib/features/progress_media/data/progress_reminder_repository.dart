import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';
import 'package:drift/drift.dart';

/// Intent is durable; OS scheduling is reconciled separately and can be retried.
class ProgressReminderRepository {
  ProgressReminderRepository(this._db);
  final AppDatabase _db;
  Stream<int> watchChanges() {
    var revision = 0;
    return _db
        .customSelect(
          'SELECT r.enabled, r.cadence, r.last_session_at, r.next_reminder_at, r.last_prompted_at, '
          '(SELECT notifications_enabled FROM app_settings LIMIT 1) AS notifications_allowed, '
          '(SELECT COUNT(*) FROM progress_media_sessions WHERE deleted_at IS NULL) AS session_count '
          'FROM (SELECT 1) AS seed LEFT JOIN progress_media_reminder_settings AS r ON r.id = \'default\'',
          readsFrom: {
            _db.progressMediaReminderSettings,
            _db.progressMediaSessions,
            _db.appSettings,
          },
        )
        .watch()
        .map((_) => ++revision);
  }

  Future<ProgressReminderContext> load() => _safe(
    () => _db.transaction(() async {
      final row = await _db
          .select(_db.progressMediaReminderSettings)
          .getSingleOrNull();
      final latest =
          await (_db.select(_db.progressMediaSessions)
                ..where((s) => s.deletedAt.isNull())
                ..limit(1))
              .get();
      final settings = await _db.select(_db.appSettings).getSingleOrNull();
      return ProgressReminderContext(
        hasSessions: latest.isNotEmpty,
        notificationsAllowed: settings?.notificationsEnabled ?? true,
        reminder: row == null
            ? const ProgressMediaReminderState()
            : ProgressMediaReminderState(
                enabled: row.enabled,
                cadence: row.cadence == null
                    ? null
                    : ProgressReminderCadence.fromDb(row.cadence!),
                lastSessionAt: row.lastSessionAt?.toUtc(),
                nextReminderAt: row.nextReminderAt?.toUtc(),
                lastPromptedAt: row.lastPromptedAt?.toUtc(),
              ),
      );
    }),
  );
  Future<void> choose(ProgressReminderCadence cadence, DateTime now) => _safe(
    () => _db.transaction(() async {
      final context = await load();
      final state = context.reminder;
      if (!context.hasSessions || state.lastSessionAt == null) {
        throw ProgressReminderFailure.storage;
      }
      await (_db.update(_db.progressMediaReminderSettings)).write(
        ProgressMediaReminderSettingsCompanion(
          enabled: Value(cadence != ProgressReminderCadence.off),
          cadence: Value(cadence.dbValue),
          lastPromptedAt: Value(state.lastPromptedAt ?? now),
          nextReminderAt: Value(
            cadence == ProgressReminderCadence.off
                ? null
                : ProgressReminderPolicy.next(
                    state.lastSessionAt!.toLocal(),
                    cadence,
                    now.toLocal(),
                  ).toUtc(),
          ),
          updatedAt: Value(now),
        ),
      );
    }),
  );
  Future<void> setNext(
    ProgressMediaReminderState expected,
    DateTime next,
    DateTime now,
  ) => _safe(() async {
    final changed =
        await (_db.update(_db.progressMediaReminderSettings)..where(
              (r) =>
                  r.enabled.equals(true) &
                  r.nextReminderAt.equals(expected.nextReminderAt!) &
                  r.lastSessionAt.equals(expected.lastSessionAt!) &
                  r.cadence.equals(expected.cadence!.dbValue),
            ))
            .write(
              ProgressMediaReminderSettingsCompanion(
                nextReminderAt: Value(next),
                updatedAt: Value(now),
              ),
            );
    if (changed != 1) throw ProgressReminderFailure.storage;
  });
  Future<T> _safe<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      throw ProgressReminderFailure.storage;
    }
  }
}
