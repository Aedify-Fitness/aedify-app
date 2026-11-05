import 'dart:async';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

abstract interface class ProgressReminderScheduler {
  Stream<ProgressReminderEvent> get events;
  Future<ProgressReminderEvent?> initialize();
  Future<bool?> permission({bool request = false});
  Future<void> replace(List<DateTime> dates, DateTime generation);
  Future<void> cancel();
}

/// Local notifications contain fixed copy and scheduling tokens, never media data.
class LocalProgressReminderScheduler implements ProgressReminderScheduler {
  LocalProgressReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  static const firstId = 61000;
  static const channelId = 'aedify_check_ins';
  static const categoryId = 'aedify_check_ins';
  final FlutterLocalNotificationsPlugin _plugin;
  final _events = StreamController<ProgressReminderEvent>.broadcast();
  Future<void>? _initializing;
  bool _launchRead = false;
  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  @override
  Stream<ProgressReminderEvent> get events => _events.stream;
  static ProgressReminderEvent? decode(NotificationResponse? response) {
    if (response == null ||
        response.id == null ||
        response.id! < firstId ||
        response.id! >= firstId + ProgressReminderPolicy.horizon) {
      return null;
    }
    final parts = response.payload?.split(':');
    if (parts == null || parts.length != 3 || parts[0] != 'checkin') {
      return null;
    }
    final generation = int.tryParse(parts[1]);
    final due = int.tryParse(parts[2]);
    if (generation == null ||
        due == null ||
        generation <= 0 ||
        due < generation ||
        due > 253402300799000) {
      return null;
    }
    final action = switch (response.actionId) {
      'snooze' => ProgressReminderAction.snooze,
      'skip' => ProgressReminderAction.skip,
      'take' || null || '' => ProgressReminderAction.take,
      _ => null,
    };
    return action == null
        ? null
        : ProgressReminderEvent(
            action: action,
            generation: DateTime.fromMillisecondsSinceEpoch(
              generation,
              isUtc: true,
            ),
            due: DateTime.fromMillisecondsSinceEpoch(due, isUtc: true),
          );
  }

  @override
  Future<ProgressReminderEvent?> initialize() async {
    if (!_supported) return null;
    await (_initializing ??= _initialize().catchError((Object error) {
      _initializing = null;
      throw ProgressReminderFailure.platform;
    }));
    if (_launchRead) return null;
    _launchRead = true;
    final launch = await _plugin.getNotificationAppLaunchDetails();
    return launch?.didNotificationLaunchApp == true
        ? decode(launch?.notificationResponse)
        : null;
  }

  Future<void> _initialize() async {
    final result = await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('ic_notification_aedify'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: [
            DarwinNotificationCategory(
              categoryId,
              actions: [
                DarwinNotificationAction.plain(
                  'take',
                  AppStrings.progressReminderTake,
                  options: {DarwinNotificationActionOption.foreground},
                ),
                DarwinNotificationAction.plain(
                  'snooze',
                  AppStrings.progressReminderSnooze,
                  options: {DarwinNotificationActionOption.foreground},
                ),
                DarwinNotificationAction.plain(
                  'skip',
                  AppStrings.progressReminderSkip,
                  options: {DarwinNotificationActionOption.foreground},
                ),
              ],
            ),
          ],
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final event = decode(response);
        if (event != null && !_events.isClosed) _events.add(event);
      },
    );
    // iOS returns false when initialization intentionally requests no permissions.
    // Authorization is checked separately immediately before scheduling.
    if (result == null ||
        (defaultTargetPlatform == TargetPlatform.android && !result)) {
      throw ProgressReminderFailure.platform;
    }
  }

  @override
  Future<bool?> permission({bool request = false}) async {
    if (!_supported) return null;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!;
      if (request) await android.requestNotificationsPermission();
      if (await android.areNotificationsEnabled() != true) return false;
      final channels = await android.getNotificationChannels();
      return channels
              ?.where((c) => c.id == channelId)
              .every((c) => c.importance != Importance.none) ??
          true;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()!;
    if (request) {
      await ios.requestPermissions(alert: true, badge: false, sound: true);
    }
    final status = await ios.checkPermissions();
    return status != null &&
        ((status.isEnabled && status.isAlertEnabled) ||
            status.isProvisionalEnabled);
  }

  @override
  Future<void> cancel() async {
    if (!_supported) return;
    for (var i = 0; i < ProgressReminderPolicy.horizon; i++) {
      await _plugin.cancel(id: firstId + i);
    }
  }

  @override
  Future<void> replace(List<DateTime> dates, DateTime generation) async {
    final pending = (await _plugin.pendingNotificationRequests())
        .where(
          (n) =>
              n.id >= firstId &&
              n.id < firstId + ProgressReminderPolicy.horizon,
        )
        .toList();
    if (pending.length == dates.length &&
        List.generate(dates.length, (i) => i).every(
          (i) => pending.any(
            (n) =>
                n.id == firstId + i &&
                n.title == AppStrings.appTitle &&
                n.body == AppStrings.progressReminderNotification &&
                n.payload ==
                    'checkin:${generation.millisecondsSinceEpoch}:${dates[i].millisecondsSinceEpoch}',
          ),
        )) {
      return;
    }
    await cancel();
    try {
      for (var i = 0; i < dates.length; i++) {
        await _plugin.zonedSchedule(
          id: firstId + i,
          title: AppStrings.appTitle,
          body: AppStrings.progressReminderNotification,
          scheduledDate: tz.TZDateTime.from(dates[i], tz.UTC),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload:
              'checkin:${generation.millisecondsSinceEpoch}:${dates[i].millisecondsSinceEpoch}',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              AppStrings.progressReminderTitle,
              icon: 'ic_notification_aedify',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              visibility: NotificationVisibility.private,
              actions: [
                AndroidNotificationAction(
                  'take',
                  AppStrings.progressReminderTake,
                  showsUserInterface: true,
                ),
                AndroidNotificationAction(
                  'snooze',
                  AppStrings.progressReminderSnooze,
                  showsUserInterface: true,
                ),
                AndroidNotificationAction(
                  'skip',
                  AppStrings.progressReminderSkip,
                  showsUserInterface: true,
                ),
              ],
            ),
            iOS: DarwinNotificationDetails(
              categoryIdentifier: categoryId,
              presentBadge: false,
            ),
          ),
        );
      }
    } catch (_) {
      await cancel();
      throw ProgressReminderFailure.platform;
    }
  }

  Future<void> dispose() => _events.close();
}
