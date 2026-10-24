import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/rest_timer_widget.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_duration_timer.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_header.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

abstract final class _TimerFixtures {
  static final startedAt = DateTime(2026, 10, 24, 10);

  static Widget app(Widget child, {bool dark = false, double scale = 1}) {
    return MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  static Finder key(String key) => find.byKey(ValueKey<String>(key));

  static void surface(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  static WorkoutRunnerHeader header({
    String title = 'Upper strength',
    String exerciseTitle = 'Incline dumbbell press',
    required VoidCallback onClose,
    bool showSubstitute = false,
    VoidCallback? onSubstitute,
  }) => WorkoutRunnerHeader(
    workoutTitle: title,
    exerciseTitle: exerciseTitle,
    workoutStartedAt: startedAt,
    isPaused: true,
    pausedDurationSeconds: 3723,
    onClose: onClose,
    onSubstitute: onSubstitute,
    showSubstitute: showSubstitute,
  );
}

void main() {
  testWidgets(
    'header restores workout context, exercise title and a single substitute action',
    (tester) async {
      _TimerFixtures.surface(tester, const Size(390, 844));
      var closed = 0;
      await tester.pumpWidget(
        _TimerFixtures.app(
          _TimerFixtures.header(onClose: () => closed++, showSubstitute: true),
        ),
      );
      expect(find.text('Upper strength'), findsOneWidget);
      expect(find.text('UPPER STRENGTH'), findsNothing);
      expect(find.text('Incline dumbbell press'), findsOneWidget);
      expect(find.text('01:02:03'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(_TimerFixtures.key('workout_runner_substitute'), findsOneWidget);
      expect(
        tester.getRect(find.text('Upper strength')).top,
        lessThan(tester.getRect(find.text('Incline dumbbell press')).top),
      );
      final close = _TimerFixtures.key('workout_runner_close_button');
      expect(tester.getSize(close).shortestSide, greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(close),
        isSemantics(isButton: true, hasTapAction: true),
      );
      await tester.tap(close);
      expect(closed, 1);
    },
  );

  testWidgets(
    'optional substitution has a 48px target and disabled semantics',
    (tester) async {
      await tester.pumpWidget(
        _TimerFixtures.app(
          _TimerFixtures.header(onClose: () {}, showSubstitute: true),
        ),
      );
      final substitute = _TimerFixtures.key('workout_runner_substitute');
      expect(tester.getSize(substitute).height, greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(substitute),
        isSemantics(isButton: true, isEnabled: false, hasTapAction: false),
      );
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'header wraps its title and stacks the timer at 320px/2x in ${dark ? 'dark' : 'light'}',
      (tester) async {
        _TimerFixtures.surface(tester, const Size(320, 568));
        const title = 'A long upper body strength and conditioning session';
        await tester.pumpWidget(
          _TimerFixtures.app(
            _TimerFixtures.header(title: title, onClose: () {}),
            dark: dark,
            scale: 2,
          ),
        );
        expect(tester.takeException(), isNull);
        final titleRect = tester.getRect(find.text(title));
        final duration = _TimerFixtures.key('workout_runner_duration_timer');
        expect(
          tester.getRect(duration).top,
          greaterThanOrEqualTo(titleRect.bottom),
        );
        expect(tester.widget<Text>(find.text(title)).maxLines, isNull);
        expect(
          tester.widget<Text>(find.text(title)).style!.fontFamily,
          dark ? 'Inter' : 'Manrope',
        );
        expect(
          tester
              .widget<Text>(find.text('Incline dumbbell press'))
              .style!
              .fontFamily,
          'Manrope',
        );
      },
    );

    testWidgets(
      'rest panel has natural large-text height and real touch targets in ${dark ? 'dark' : 'light'}',
      (tester) async {
        _TimerFixtures.surface(tester, const Size(320, 568));
        await tester.pumpWidget(
          _TimerFixtures.app(
            RestTimerWidget(seconds: 90, onDismiss: () {}),
            dark: dark,
            scale: 2,
          ),
        );
        expect(find.text('01:30'), findsOneWidget);
        expect(find.text(AppStrings.restTime), findsOneWidget);
        expect(find.byType(BackdropFilter), findsNothing);
        for (final key in [
          'workout_runner_rest_subtract',
          'workout_runner_rest_add',
          'workout_runner_rest_skip',
        ]) {
          final control = _TimerFixtures.key(key);
          await tester.ensureVisible(control);
          final ink = find.descendant(
            of: control,
            matching: find.byType(InkWell),
          );
          expect(tester.getSize(ink).shortestSide, greaterThanOrEqualTo(48));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'rest panel restores the circular countdown and stacked controls',
    (tester) async {
      _TimerFixtures.surface(tester, const Size(390, 844));
      await tester.pumpWidget(
        _TimerFixtures.app(RestTimerWidget(seconds: 90, onDismiss: () {})),
      );
      final ring = _TimerFixtures.key('workout_runner_rest_timer_ring');
      final ringSize = tester.getSize(ring);
      expect(ringSize.width, ringSize.height);
      expect(ringSize.width, greaterThanOrEqualTo(128));
      final subtract = _TimerFixtures.key('workout_runner_rest_subtract');
      final skip = _TimerFixtures.key('workout_runner_rest_skip');
      expect(
        tester.getRect(subtract).top,
        greaterThan(tester.getRect(ring).bottom),
      );
      expect(
        tester.getRect(skip).top,
        greaterThan(tester.getRect(subtract).bottom),
      );
      expect(tester.getSize(skip).width, 350);
      expect(
        tester.getSemantics(
          _TimerFixtures.key('workout_runner_rest_timer_ring'),
        ),
        isSemantics(label: AppStrings.restTimeRemaining('01:30')),
      );
    },
  );

  testWidgets('rest adjustments cap at five minutes and zero dismisses once', (
    tester,
  ) async {
    var dismissed = 0;
    await tester.pumpWidget(
      _TimerFixtures.app(
        RestTimerWidget(seconds: 299, onDismiss: () => dismissed++),
      ),
    );
    await tester.tap(_TimerFixtures.key('workout_runner_rest_add'));
    await tester.pump();
    expect(find.text('05:00'), findsOneWidget);
    await tester.tap(_TimerFixtures.key('workout_runner_rest_add'));
    await tester.pump();
    expect(find.text('05:00'), findsOneWidget);
    await tester.pumpWidget(
      _TimerFixtures.app(
        RestTimerWidget(seconds: 10, onDismiss: () => dismissed++),
      ),
    );
    await tester.tap(_TimerFixtures.key('workout_runner_rest_subtract'));
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);
    expect(dismissed, 1);
    await tester.pump(const Duration(minutes: 1));
    await tester.tap(_TimerFixtures.key('workout_runner_rest_skip'));
    expect(dismissed, 1);
  });

  testWidgets('skip cancels the countdown and cannot complete twice', (
    tester,
  ) async {
    var dismissed = 0;
    await tester.pumpWidget(
      _TimerFixtures.app(
        RestTimerWidget(seconds: 2, onDismiss: () => dismissed++),
      ),
    );
    await tester.tap(_TimerFixtures.key('workout_runner_rest_skip'));
    await tester.pump(const Duration(seconds: 3));
    expect(dismissed, 1);
    expect(find.text('00:02'), findsOneWidget);
  });

  testWidgets(
    'new rest duration restarts after completion and zero completes safely',
    (tester) async {
      var dismissed = 0;
      Widget rest(int seconds) => _TimerFixtures.app(
        RestTimerWidget(seconds: seconds, onDismiss: () => dismissed++),
      );
      await tester.pumpWidget(rest(1));
      await tester.pump(const Duration(seconds: 1));
      expect(dismissed, 1);
      await tester.pumpWidget(rest(30));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:29'), findsOneWidget);
      await tester.pumpWidget(rest(0));
      expect(dismissed, 2);
      await tester.pump(const Duration(seconds: 1));
      expect(dismissed, 2);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'elapsed clock resynchronizes after app resume and freezes when paused',
    (tester) async {
      var now = _TimerFixtures.startedAt.add(const Duration(seconds: 61));
      Widget timer({bool paused = false}) => _TimerFixtures.app(
        WorkoutDurationTimer(
          startedAt: _TimerFixtures.startedAt,
          isPaused: paused,
          pausedDurationSeconds: paused ? 61 : null,
          now: () => now,
        ),
      );
      await tester.pumpWidget(timer());
      expect(find.text('01:01'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      now = now.add(const Duration(minutes: 2));
      await tester.pump(const Duration(minutes: 2));
      expect(find.text('01:01'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('03:01'), findsOneWidget);
      await tester.pumpWidget(timer(paused: true));
      now = now.add(const Duration(minutes: 2));
      await tester.pump(const Duration(minutes: 2));
      expect(find.text('01:01'), findsOneWidget);
      expect(
        tester.getSemantics(
          _TimerFixtures.key('workout_runner_duration_timer'),
        ),
        isSemantics(label: AppStrings.timeElapsedLabel('01:01')),
      );
    },
  );
}
