import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_controller.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_dataset_sync_banner.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_dataset_sync_status_card.dart';
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
    home: Scaffold(
      body: ProviderScope(
        overrides: [
          AppProviders.exerciseDatasetSyncControllerProvider.overrideWith(
            () => _FixedStateNotifier(state),
          ),
        ],
        child: const ExerciseDatasetSyncBanner(),
      ),
    ),
  );
}

void main() {
  group('ExerciseDatasetSyncBanner', () {
    testWidgets('shows nothing when synced and online', (tester) async {
      await tester.pumpWidget(
        wrapWithProvider(
          const ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.synced,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ExerciseDatasetSyncStatusCard), findsNothing);
    });

    testWidgets('shows first sync required state', (tester) async {
      await tester.pumpWidget(
        wrapWithProvider(
          const ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.neverSynced,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ExerciseDatasetSyncStatusCard), findsOneWidget);
      expect(find.text(AppStrings.exerciseLibrarySyncRequired), findsOneWidget);
      expect(
        find.text(AppStrings.exerciseLibraryTapToDownload),
        findsOneWidget,
      );
      expect(find.text(AppStrings.download), findsOneWidget);
    });

    testWidgets('shows offline unavailable state', (tester) async {
      await tester.pumpWidget(
        wrapWithProvider(
          const ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.unavailableOffline,
            isOffline: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ExerciseDatasetSyncStatusCard), findsOneWidget);
      expect(find.text(AppStrings.exerciseLibrarySyncRequired), findsOneWidget);
      expect(
        find.text(AppStrings.exerciseLibrarySyncUnavailableOffline),
        findsOneWidget,
      );
    });

    testWidgets('shows syncing state with progress indicator', (tester) async {
      await tester.pumpWidget(
        wrapWithProvider(
          const ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.checkingManifest,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ExerciseDatasetSyncStatusCard), findsOneWidget);
      expect(
        find.text(AppStrings.exerciseLibrarySyncInProgress),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows failed state with retry', (tester) async {
      await tester.pumpWidget(
        wrapWithProvider(
          ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.failed,
            failure: const ExerciseDatasetSyncFailure(
              code: 'datasetDownloadFailed',
              message: 'Network error',
              retryable: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ExerciseDatasetSyncStatusCard), findsOneWidget);
      expect(
        find.text(AppStrings.exerciseLibrarySyncFailed),
        findsOneWidget,
      );
      expect(find.text(AppStrings.exerciseLibraryRetry), findsOneWidget);
    });

    testWidgets('shows update-required state', (tester) async {
      await tester.pumpWidget(
        wrapWithProvider(
          ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.updateRequired,
            failure: const ExerciseDatasetSyncFailure(
              code: 'unsupportedAppSchema',
              message: 'Please update the app',
              retryable: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ExerciseDatasetSyncStatusCard), findsOneWidget);
      expect(
        find.text(AppStrings.exerciseLibraryUpdateRequired),
        findsAtLeast(1),
      );
    });
  });
}
