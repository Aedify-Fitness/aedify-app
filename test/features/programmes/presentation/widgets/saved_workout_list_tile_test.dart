import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/features/programmes/presentation/widgets/saved_workout_list_tile.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(home: Scaffold(body: widget));
}

void main() {
  testWidgets('displays workout name and exercise count', (tester) async {
    final item = SavedWorkoutListItem(
      id: 'w1',
      name: 'Push Day',
      status: SavedWorkoutStatus.active,
      exerciseCount: 5,
      updatedAt: DateTime(2026, 6, 30),
      modalities: [],
      focus: '',
    );

    await tester.pumpWidget(
      _wrap(
        SavedWorkoutListTile(
          item: item,
          onTap: () {},
          onPlay: () {},
          onResume: () {},
          onEdit: () {},
          onArchive: () {},
          onDelete: () {},
        ),
      ),
    );

    expect(find.text('Push Day'), findsOneWidget);
    expect(find.textContaining('5'), findsOneWidget);
  });

  testWidgets('shows popup menu with edit, archive and delete', (tester) async {
    final item = SavedWorkoutListItem(
      id: 'w1',
      name: 'Push Day',
      status: SavedWorkoutStatus.active,
      exerciseCount: 5,
      updatedAt: DateTime(2026, 6, 30),
      modalities: [],
      focus: '',
    );

    await tester.pumpWidget(
      _wrap(
        SavedWorkoutListTile(
          item: item,
          onTap: () {},
          onPlay: () {},
          onResume: () {},
          onEdit: () {},
          onArchive: () {},
          onDelete: () {},
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.editWorkout), findsOneWidget);
    expect(find.text(AppStrings.archiveWorkout), findsOneWidget);
    expect(find.text(AppStrings.deleteWorkout), findsOneWidget);
  });

  testWidgets('calls onArchive when archive is selected', (tester) async {
    bool archived = false;
    final item = SavedWorkoutListItem(
      id: 'w1',
      name: 'Push Day',
      status: SavedWorkoutStatus.active,
      exerciseCount: 5,
      updatedAt: DateTime(2026, 6, 30),
      modalities: [],
      focus: '',
    );

    await tester.pumpWidget(
      _wrap(
        SavedWorkoutListTile(
          item: item,
          onTap: () {},
          onPlay: () {},
          onResume: () {},
          onEdit: () {},
          onArchive: () => archived = true,
          onDelete: () {},
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.archiveWorkout));
    await tester.pumpAndSettle();

    expect(archived, isTrue);
  });
}
