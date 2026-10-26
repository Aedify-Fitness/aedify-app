import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_list_tile.dart';
import 'package:aedify/shared/components/app_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/session_source.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

Widget _wrap(Widget widget, {TextScaler? textScaler}) {
  return MaterialApp(
    builder: textScaler == null
        ? null
        : (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: child!,
          ),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: widget,
      ),
    ),
  );
}

void main() {
  testWidgets('renders source, snapshot name, date, duration, and count', (
    tester,
  ) async {
    var wasTapped = false;
    final item = WorkoutHistoryListItem(
      sessionId: 'session-1',
      name: 'Lower Body Power',
      source: SessionSource.savedWorkout,
      completedAt: DateTime(2026, 7, 18),
      durationSeconds: 3720,
      exerciseCount: 4,
    );

    await tester.pumpWidget(
      _wrap(WorkoutHistoryListTile(item: item, onTap: () => wasTapped = true)),
    );

    expect(find.byType(AppBadge), findsOneWidget);
    expect(find.byType(Card), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(find.text(AppStrings.sourceSavedWorkout), findsOneWidget);
    expect(find.text('Lower Body Power'), findsOneWidget);
    expect(
      find.text(DateFormat.yMMMd().format(DateTime(2026, 7, 18))),
      findsOneWidget,
    );
    expect(find.text('1h 2m'), findsOneWidget);
    expect(find.text('4 ${AppStrings.historyExerciseList}'), findsOneWidget);
    expect(find.text(AppStrings.totalVolume), findsNothing);

    await tester.tap(find.byType(WorkoutHistoryListTile));
    await tester.pump();

    expect(wasTapped, isTrue);
  });

  testWidgets('wraps metadata on a compact phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final item = WorkoutHistoryListItem(
      sessionId: 'session-2',
      name: 'A deliberately long standalone training session',
      source: SessionSource.standalone,
      completedAt: DateTime(2026, 7, 19),
      durationSeconds: 2700,
      exerciseCount: 8,
    );

    await tester.pumpWidget(
      _wrap(
        WorkoutHistoryListTile(item: item, onTap: () {}),
        textScaler: const TextScaler.linear(1.6),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(item.name), findsOneWidget);
    expect(find.text(AppStrings.sourceStandalone), findsOneWidget);
  });
}
