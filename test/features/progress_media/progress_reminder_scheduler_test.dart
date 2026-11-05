import 'package:aedify/features/progress_media/data/progress_reminder_scheduler.dart';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  late List<MethodCall> calls;
  bool rejectSchedule = false;
  List<Map<String, Object?>> pending = [];
  setUp(() {
    calls = [];
    pending = [];
    rejectSchedule = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'initialize' => defaultTargetPlatform != TargetPlatform.iOS,
            'getNotificationAppLaunchDetails' => {
              'notificationLaunchedApp': false,
            },
            'areNotificationsEnabled' ||
            'requestNotificationsPermission' => true,
            'getNotificationChannels' => [],
            'pendingNotificationRequests' => pending,
            'checkPermissions' => {
              'isEnabled': defaultTargetPlatform != TargetPlatform.iOS,
              'isAlertEnabled': defaultTargetPlatform != TargetPlatform.iOS,
              'isProvisionalEnabled':
                  defaultTargetPlatform == TargetPlatform.iOS,
            },
            'requestPermissions' => true,
            'zonedSchedule' =>
              rejectSchedule
                  ? throw PlatformException(
                      code: 'private-sentinel',
                      message: '/private/media-sentinel',
                    )
                  : null,
            _ => null,
          };
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    test(
      '${platform.name} initialization never requests permission; explicit request does',
      () async {
        debugDefaultTargetPlatformOverride = platform;
        if (platform == TargetPlatform.android) {
          AndroidFlutterLocalNotificationsPlugin.registerWith();
        } else {
          IOSFlutterLocalNotificationsPlugin.registerWith();
        }
        final scheduler = LocalProgressReminderScheduler();
        addTearDown(scheduler.dispose);
        await scheduler.initialize();
        expect(await scheduler.permission(), isTrue);
        expect(calls.where((c) => c.method.startsWith('request')), isEmpty);
        if (platform == TargetPlatform.iOS) {
          final args =
              calls.firstWhere((c) => c.method == 'initialize').arguments
                  as Map;
          expect(args['requestAlertPermission'], isFalse);
          expect(args['requestSoundPermission'], isFalse);
          expect(args['requestBadgePermission'], isFalse);
          expect(args['notificationCategories'], hasLength(1));
        }
        await scheduler.permission(request: true);
        expect(
          calls.where((c) => c.method.startsWith('request')),
          hasLength(1),
        );
      },
    );
    test(
      '${platform.name} native queue contains only generic copy/tokens and cancels only reserved IDs',
      () async {
        debugDefaultTargetPlatformOverride = platform;
        if (platform == TargetPlatform.android) {
          AndroidFlutterLocalNotificationsPlugin.registerWith();
        } else {
          IOSFlutterLocalNotificationsPlugin.registerWith();
        }
        final scheduler = LocalProgressReminderScheduler();
        addTearDown(scheduler.dispose);
        await scheduler.initialize();
        final date = DateTime.utc(2026, 12, 1, 12);
        await scheduler.replace([
          date,
          date.add(const Duration(days: 14)),
        ], date);
        final schedules = calls
            .where((c) => c.method == 'zonedSchedule')
            .toList();
        expect(schedules, hasLength(2));
        for (final call in schedules) {
          final args = call.arguments as Map;
          expect(args['title'], AppStrings.appTitle);
          expect(args['body'], AppStrings.progressReminderNotification);
          expect(args['timeZoneName'], 'Etc/UTC');
          expect((args['payload'] as String).split(':'), hasLength(3));
          expect(args.toString(), isNot(contains('private-sentinel')));
        }
        expect(calls.where((c) => c.method == 'cancelAll'), isEmpty);
        expect(
          calls
              .where((c) => c.method == 'cancel')
              .map(
                (c) => c.arguments is int
                    ? c.arguments
                    : (c.arguments as Map)['id'],
              ),
          List.generate(12, (i) => 61000 + i),
        );
      },
    );
  }
  test(
    'unchanged native queue is reused without cancelling other or current reminders',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      AndroidFlutterLocalNotificationsPlugin.registerWith();
      final scheduler = LocalProgressReminderScheduler();
      addTearDown(scheduler.dispose);
      await scheduler.initialize();
      final date = DateTime.utc(2026, 12, 1);
      pending = [
        {
          'id': 61000,
          'title': AppStrings.appTitle,
          'body': AppStrings.progressReminderNotification,
          'payload':
              'checkin:${date.millisecondsSinceEpoch}:${date.millisecondsSinceEpoch}',
        },
      ];
      calls.clear();
      await scheduler.replace([date], date);
      expect(calls.map((c) => c.method), ['pendingNotificationRequests']);
    },
  );
  test(
    'partial schedule failure cleans reserved IDs and strips platform error details',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      AndroidFlutterLocalNotificationsPlugin.registerWith();
      final scheduler = LocalProgressReminderScheduler();
      addTearDown(scheduler.dispose);
      await scheduler.initialize();
      rejectSchedule = true;
      final date = DateTime.utc(2026, 12, 1);
      await expectLater(
        scheduler.replace([date], date),
        throwsA(ProgressReminderFailure.platform),
      );
      expect(calls.where((c) => c.method == 'cancel'), hasLength(24));
    },
  );
}
