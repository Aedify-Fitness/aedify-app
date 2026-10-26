import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_card.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/features/programmes/presentation/widgets/saved_workout_list_tile.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/saved_workout_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

abstract final class _Cards {
  static SavedWorkoutListItem get workout => SavedWorkoutListItem(
    id: 'upper',
    name: 'Upper strength',
    status: SavedWorkoutStatus.active,
    exerciseCount: 4,
    updatedAt: DateTime(2026, 10, 24),
    modalities: const ['strength'],
    focus: 'Strength',
    estimatedDurationMinutes: 45,
  );
  static const exercise = ExerciseListItem(
    id: 1,
    name: 'Bench press',
    difficulty: ExerciseDifficulty.intermediate,
    muscleGroups: {BodymapBucket.chest},
    modality: ExerciseModality.strength,
    equipment: EquipmentTag.barbell,
    isFavorite: false,
    isSubstitutedOut: false,
  );
  static SavedWorkoutListTile tile(
    List<String> actions, {
    String? activeId,
    bool active = false,
  }) => SavedWorkoutListTile(
    item: workout,
    activeSessionWorkoutId: activeId,
    hasActiveSession: active,
    onTap: () => actions.add('open'),
    onPlay: () => actions.add('start'),
    onResume: () => actions.add('resume'),
    onEdit: () => actions.add('edit'),
    onArchive: () => actions.add('archive'),
    onDelete: () => actions.add('delete'),
  );
  static Future<void> pump(
    WidgetTester tester,
    Widget child, {
    ThemeData? theme,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('card, Start and menu dispatch only their own callbacks', (
    tester,
  ) async {
    final actions = <String>[];
    await _Cards.pump(tester, _Cards.tile(actions));
    await tester.tap(find.text('Upper strength'));
    await tester.tap(find.text(AppStrings.startWorkout));
    for (final action in [
      (AppStrings.editWorkout, 'edit'),
      (AppStrings.archiveWorkout, 'archive'),
      (AppStrings.deleteWorkout, 'delete'),
    ]) {
      await tester.tap(find.byTooltip(AppStrings.workoutOptions));
      await tester.pumpAndSettle();
      await tester.tap(find.text(action.$1));
      await tester.pumpAndSettle();
    }
    expect(actions, ['open', 'start', 'edit', 'archive', 'delete']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('matching saved session resumes instead of starting', (
    tester,
  ) async {
    final actions = <String>[];
    await _Cards.pump(
      tester,
      _Cards.tile(actions, activeId: 'upper', active: true),
    );
    expect(find.text(AppStrings.startWorkout), findsNothing);
    await tester.tap(find.text(AppStrings.resumeWorkout));
    expect(actions, ['resume']);
  });

  for (final activeId in <String?>[null, 'another-workout']) {
    testWidgets(
      'another active session $activeId blocks Start while details remain available',
      (tester) async {
        final actions = <String>[];
        await _Cards.pump(
          tester,
          _Cards.tile(actions, activeId: activeId, active: true),
        );
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, AppStrings.startWorkout),
              )
              .onPressed,
          isNull,
        );
        await tester.tap(find.text('Upper strength'));
        expect(actions, ['open']);
      },
    );
  }

  for (final dark in [false, true]) {
    testWidgets(
      'exercise and saved workout backgrounds match in ${dark ? 'dark' : 'light'} mode',
      (tester) async {
        final actions = <String>[];
        await _Cards.pump(
          tester,
          Column(
            children: [
              ExerciseCard(item: _Cards.exercise, onTap: () {}),
              _Cards.tile(actions),
            ],
          ),
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        );
        final exercisePanel = tester.widget<AnimatedContainer>(
          find.descendant(
            of: find.byType(ExerciseCard),
            matching: find.byType(AnimatedContainer),
          ),
        );
        final workoutPanel = tester.widget<Material>(
          find.byKey(const Key('saved_workout_card_upper')),
        );
        expect(
          (exercisePanel.decoration! as BoxDecoration).color,
          workoutPanel.color,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
