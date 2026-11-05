import 'dart:async';
import 'package:aedify/features/progress_media/data/progress_reminder_repository.dart';
import 'package:aedify/features/progress_media/data/progress_reminder_scheduler.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';

/// Serializes platform effects; durable intent is written before OS replacement.
class ProgressReminderService {
  ProgressReminderService({
    required this.repository,
    required this.scheduler,
    required this.now,
    required this.featureAllowed,
  });
  final ProgressReminderRepository repository;
  final ProgressReminderScheduler scheduler;
  final DateTime Function() now;
  final bool Function() featureAllowed;
  final _capture = StreamController<void>.broadcast();
  Stream<void> get captureRequests => _capture.stream;
  Future<void> _tail = Future.value();
  Future<ProgressReminderView> refresh({
    ProgressReminderCadence? choice,
    bool request = false,
    ProgressReminderEvent? event,
  }) {
    final result = _tail.then(
      (_) => _refresh(choice: choice, request: request, event: event),
    );
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<ProgressReminderView> _refresh({
    ProgressReminderCadence? choice,
    bool request = false,
    ProgressReminderEvent? event,
  }) async {
    // Storage errors are propagated without initializing the OS or prompting.
    var context = await repository.load();
    try {
      final launch = await scheduler.initialize();
      if (choice != null) {
        await repository.choose(choice, now());
        context = await repository.load();
      }
      if (event != null || launch != null) {
        await _act(context, event ?? launch!);
        context = await repository.load();
      }
      final state = context.reminder;
      if (!context.hasSessions ||
          !state.enabled ||
          !featureAllowed() ||
          !context.notificationsAllowed) {
        await scheduler.cancel();
        return ProgressReminderView(
          context: context,
          status: !context.hasSessions
              ? ProgressReminderStatus.noSession
              : !state.enabled
              ? ProgressReminderStatus.off
              : ProgressReminderStatus.appDisabled,
        );
      }
      final permission = await scheduler.permission(
        request: request && choice != ProgressReminderCadence.off,
      );
      if (permission != true) {
        await scheduler.cancel();
        return ProgressReminderView(
          context: context,
          status: permission == null
              ? ProgressReminderStatus.unsupported
              : ProgressReminderStatus.permissionDenied,
        );
      }
      final dates = ProgressReminderPolicy.dates(state, now());
      if (dates.isEmpty) throw ProgressReminderFailure.storage;
      if (state.nextReminderAt != dates.first) {
        await repository.setNext(state, dates.first, now());
        context = await repository.load();
      }
      await scheduler.replace(
        ProgressReminderPolicy.dates(context.reminder, now()),
        context.reminder.nextReminderAt!,
      );
      // A concurrent check-in/settings commit must not leave an old OS schedule.
      final latest = await repository.load();
      if (!_same(context, latest) || !featureAllowed()) {
        await scheduler.cancel();
        return _refresh();
      }
      return ProgressReminderView(
        context: latest,
        status: ProgressReminderStatus.scheduled,
      );
    } catch (error) {
      // Fail closed after partial OS updates; cleanup errors remain retryable.
      try {
        await scheduler.cancel();
      } catch (_) {}
      return ProgressReminderView(
        context: await repository.load(),
        status: ProgressReminderStatus.failed,
        failure: error is ProgressReminderFailure
            ? error
            : ProgressReminderFailure.platform,
      );
    }
  }

  bool _same(ProgressReminderContext a, ProgressReminderContext b) =>
      a.hasSessions == b.hasSessions &&
      a.notificationsAllowed == b.notificationsAllowed &&
      a.reminder.enabled == b.reminder.enabled &&
      a.reminder.cadence == b.reminder.cadence &&
      a.reminder.nextReminderAt == b.reminder.nextReminderAt &&
      a.reminder.lastSessionAt == b.reminder.lastSessionAt;
  Future<void> _act(
    ProgressReminderContext context,
    ProgressReminderEvent event,
  ) async {
    final state = context.reminder;
    if (!context.hasSessions ||
        !state.enabled ||
        !context.notificationsAllowed ||
        !featureAllowed() ||
        state.nextReminderAt != event.generation) {
      return;
    }
    final expected = ProgressReminderPolicy.dates(
      state,
      event.generation.subtract(const Duration(seconds: 1)),
    );
    if (!expected.contains(event.due) ||
        event.due.isAfter(now().add(const Duration(minutes: 5)))) {
      return;
    }
    if (event.action == ProgressReminderAction.take) {
      if (!_capture.isClosed) _capture.add(null);
      return;
    }
    final next = event.action == ProgressReminderAction.snooze
        ? now().add(const Duration(days: 1)).toUtc()
        : ProgressReminderPolicy.next(
            state.lastSessionAt!.toLocal(),
            state.cadence!,
            now().isAfter(event.due) ? now().toLocal() : event.due.toLocal(),
          ).toUtc();
    await repository.setNext(state, next, now());
  }

  Future<void> dispose() => _capture.close();
}
