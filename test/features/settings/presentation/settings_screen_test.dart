import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_controller.dart';
import 'package:aedify/features/exercise_library/application/exercise_dataset_sync_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_dataset_status_tile.dart';
import 'package:aedify/features/settings/data/settings_repository.dart';
import 'package:aedify/features/settings/domain/settings_edit_draft.dart';
import 'package:aedify/features/settings/domain/settings_view_data.dart';
import 'package:aedify/features/settings/presentation/settings_screen.dart';
import 'package:aedify/features/settings/presentation/widgets/settings_storage_boundary_card.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/theme_mode_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedSyncNotifier extends ExerciseDatasetSyncController {
  _FixedSyncNotifier(this._state);

  final ExerciseDatasetSyncState _state;

  @override
  Future<ExerciseDatasetSyncState> build() async => _state;
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<SettingsViewData> getSettings() async {
    return SettingsViewData(
      preferredUnits: PreferredUnit.metric,
      themeMode: ThemeModeSetting.system,
      notificationsEnabled: true,
      workoutTimerSoundEnabled: true,
      exerciseAudioEnabled: false,
      crashlyticsEnabled: true,
      redactionStrictMode: true,
      diagnosticsEnabled: false,
      aiEnabled: true,
      importsEnabled: true,
      sharingEnabled: true,
      progressMediaEnabled: true,
      physiqueAnalysisEnabled: true,
    );
  }

  @override
  Future<void> saveSettings(SettingsEditDraft draft) async {}
}

class _FailingSettingsRepository implements SettingsRepository {
  @override
  Future<SettingsViewData> getSettings() async {
    throw Exception('connection failed');
  }

  @override
  Future<void> saveSettings(SettingsEditDraft draft) async {}
}

Widget wrapWithProviders(ExerciseDatasetSyncState syncState) {
  return MaterialApp(
    home: ProviderScope(
      overrides: [
        AppProviders.exerciseDatasetSyncControllerProvider.overrideWith(
          () => _FixedSyncNotifier(syncState),
        ),
        AppProviders.settingsRepositoryProvider.overrideWith(
          (ref) => _FakeSettingsRepository(),
        ),
      ],
      child: const SettingsScreen(),
    ),
  );
}

void main() {
  group('SettingsScreen', () {
    testWidgets('renders profile entry', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.synced,
            libraryVersion: 'v1',
          ),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.profile), findsWidgets);
    });

    testWidgets('renders exercise library status section with details', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(
          ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.synced,
            libraryVersion: 'v1',
          ),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.exerciseLibraryStatus), findsOneWidget);
      expect(find.byType(ExerciseDatasetStatusTile), findsOneWidget);
      expect(find.text(AppStrings.exerciseLibraryVersion), findsOneWidget);
      expect(find.text(AppStrings.exerciseLibrarySynced), findsOneWidget);
    });

    testWidgets('renders never synced status label', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.neverSynced,
          ),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.exerciseLibraryNeverSynced), findsWidgets);
    });

    testWidgets('renders failed sync label', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
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

    testWidgets('renders app settings section', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.synced,
            libraryVersion: 'v1',
          ),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.appSettings), findsOneWidget);
    });

    testWidgets('renders feature status section', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.synced,
            libraryVersion: 'v1',
          ),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.featureStatus), findsOneWidget);
    });

    testWidgets('renders privacy/storage boundary card', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          ExerciseDatasetSyncState(
            phase: ExerciseDatasetSyncPhase.synced,
            libraryVersion: 'v1',
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SettingsStorageBoundaryCard), findsOneWidget);
    });

    testWidgets('shows error state when settings fail to load', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              AppProviders.exerciseDatasetSyncControllerProvider.overrideWith(
                () => _FixedSyncNotifier(
                  ExerciseDatasetSyncState(
                    phase: ExerciseDatasetSyncPhase.synced,
                    libraryVersion: 'v1',
                  ),
                ),
              ),
              AppProviders.settingsRepositoryProvider.overrideWith(
                (ref) => _FailingSettingsRepository(),
              ),
            ],
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text(AppErrorStrings.settingsLoadFailedMessage),
        findsOneWidget,
      );
      expect(find.text(AppStrings.retry), findsOneWidget);
    });
  });
}
