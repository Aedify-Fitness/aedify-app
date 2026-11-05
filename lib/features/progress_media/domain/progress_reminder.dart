import 'dart:math' as math;
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';

enum ProgressReminderStatus {
  noSession,
  off,
  scheduled,
  appDisabled,
  permissionDenied,
  unsupported,
  failed,
}

enum ProgressReminderAction { take, snooze, skip }

enum ProgressReminderFailure implements Exception {
  storage,
  platform;

  String get message => switch (this) {
    storage => AppErrorStrings.progressReminderStorage,
    platform => AppErrorStrings.progressReminderPlatform,
  };
}

class ProgressReminderContext {
  const ProgressReminderContext({
    required this.reminder,
    required this.hasSessions,
    required this.notificationsAllowed,
  });
  final ProgressMediaReminderState reminder;
  final bool hasSessions;
  final bool notificationsAllowed;
}

class ProgressReminderView {
  const ProgressReminderView({
    required this.context,
    required this.status,
    this.failure,
    this.busy = false,
  });
  final ProgressReminderContext context;
  final ProgressReminderStatus status;
  final ProgressReminderFailure? failure;
  final bool busy;
}

class ProgressReminderEvent {
  const ProgressReminderEvent({
    required this.action,
    required this.generation,
    required this.due,
  });
  final ProgressReminderAction action;
  final DateTime generation;
  final DateTime due;
}

/// Calendar cadence preserves the original day, clamping only shorter months.
abstract final class ProgressReminderPolicy {
  static const horizon = 12;
  static DateTime advance(
    DateTime anchor,
    ProgressReminderCadence cadence,
    int periods,
  ) {
    final months = switch (cadence) {
      ProgressReminderCadence.monthly => periods,
      ProgressReminderCadence.threeMonths => periods * 3,
      _ => 0,
    };
    DateTime date(int year, int month, int day) => anchor.isUtc
        ? DateTime.utc(
            year,
            month,
            day,
            anchor.hour,
            anchor.minute,
            anchor.second,
          )
        : DateTime(year, month, day, anchor.hour, anchor.minute, anchor.second);
    if (cadence == ProgressReminderCadence.off || periods < 1) {
      throw ProgressMediaFailure.invalid;
    }
    if (cadence == ProgressReminderCadence.twoWeeks) {
      return date(anchor.year, anchor.month, anchor.day + periods * 14);
    }
    final monthStart = date(anchor.year, anchor.month + months, 1);
    final lastDay = date(monthStart.year, monthStart.month + 1, 0).day;
    return date(
      monthStart.year,
      monthStart.month,
      math.min(anchor.day, lastDay),
    );
  }

  static DateTime next(
    DateTime anchor,
    ProgressReminderCadence cadence,
    DateTime after,
  ) {
    var periods = cadence == ProgressReminderCadence.twoWeeks
        ? math.max(1, after.difference(anchor).inDays ~/ 14)
        : math.max(
            1,
            ((after.year - anchor.year) * 12 + after.month - anchor.month) ~/
                (cadence == ProgressReminderCadence.threeMonths ? 3 : 1),
          );
    var result = advance(anchor, cadence, periods);
    while (!result.isAfter(after)) {
      result = advance(anchor, cadence, ++periods);
    }
    return result;
  }

  static List<DateTime> dates(ProgressMediaReminderState state, DateTime now) {
    final cadence = state.cadence;
    final first = state.nextReminderAt;
    final anchor = state.lastSessionAt;
    if (!state.enabled ||
        cadence == null ||
        cadence == ProgressReminderCadence.off ||
        first == null ||
        anchor == null) {
      return const [];
    }
    // Compute against local calendar dates; OS schedules receive UTC instants.
    final localAnchor = anchor.toLocal();
    var due = first.isAfter(now)
        ? first
        : next(localAnchor, cadence, now).toUtc();
    final result = <DateTime>[due];
    while (result.length < horizon) {
      due = next(localAnchor, cadence, due.toLocal()).toUtc();
      result.add(due);
    }
    return List.unmodifiable(result);
  }
}
