import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_controller.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_dataset_status_tile.dart';
import 'package:aedify/features/settings/presentation/settings_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedStateNotifier extends ExerciseDatasetSyncController {
  _FixedStateNotifier(this._state);

  final ExerciseDatasetSyncState _state;

  @override
  Future<ExerciseDatasetSyncState> build() async => _state;
}

Widget wrapWithProvider(ExerciseDatasetSyncState state) {
  return MaterialApp(
    home: ProviderScope(
      overrides: [
        AppProviders.exerciseDatasetSyncControllerProvider.overrideWith(
          () => _FixedStateNotifier(state),
        ),
      ],
      child: const SettingsScreen(),
    ),
  );
}

void main() {
  group('SettingsScreen', () {
    testWidgets('shows dataset version and sync status', (tester) async {
      await tester.pumpWidget(
        wrapWithProvider(
          ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.synced,
            libraryVersion: 'v1',
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ExerciseDatasetStatusTile), findsOneWidget);
      expect(
        find.text(AppStrings.exerciseLibraryStatus),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.exerciseLibraryVersion),
        findsOneWidget,
      );
      expect(find.text('v1'), findsOneWidget);
      expect(
        find.text(AppStrings.exerciseLibrarySynced),
        findsOneWidget,
      );
    });

    testWidgets('shows never synced status label', (tester) async {
      await tester.pumpWidget(
        wrapWithProvider(
          const ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.neverSynced,
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text(AppStrings.exerciseLibraryNeverSynced),
        findsWidgets,
      );
    });

    testWidgets('shows failed sync label', (tester) async {
      await tester.pumpWidget(
        wrapWithProvider(
          ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.failed,
            failure: const ExerciseDatasetSyncFailure(
              code: 'error',
              message: 'failed',
              retryable: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text(AppStrings.exerciseLibrarySyncFailedLabel),
        findsWidgets,
      );
    });
  });
}
