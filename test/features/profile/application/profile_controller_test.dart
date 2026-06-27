import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/daos/user_profile_dao.dart';
import 'package:aedify/features/profile/data/drift_profile_repository.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import '../../../support/privacy/privacy_sentinel_values.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/strength_anchor_dao.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() {
    db.close();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        AppProviders.appDatabaseProvider.overrideWithValue(db),
        AppProviders.userProfileDaoProvider.overrideWithValue(
          UserProfileDao(db),
        ),
        AppProviders.strengthAnchorDaoProvider.overrideWithValue(
          StrengthAnchorDao(db),
        ),
        AppProviders.profileRepositoryProvider.overrideWithValue(
          DriftProfileRepository(
            database: db,
            userProfileDao: UserProfileDao(db),
            strengthAnchorDao: StrengthAnchorDao(db),
          ),
        ),
      ],
    );
  }

  group('ProfileController', () {
    test('initial build loads existing profile or empty state', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.profileControllerProvider.notifier,
      );

      await controller.build();

      final state = container.read(AppProviders.profileControllerProvider);
      expect(state.hasError, isFalse);
      expect(state.requireValue.isLoading, isFalse);
    });

    test('updateDraft updates state', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.profileControllerProvider.notifier,
      );

      await controller.build();
      await controller.updateDraft(
        const ProfileEditDraft(
          experienceLevel: 'Advanced',
          goals: ['Build muscle', 'Increase strength'],
        ),
      );

      final state = container.read(AppProviders.profileControllerProvider);
      expect(state.requireValue.draft!.experienceLevel, equals('Advanced'));
      expect(state.requireValue.draft!.goals, contains('Build muscle'));
    });

    test('save persists profile', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.profileControllerProvider.notifier,
      );

      await controller.build();

      await controller.updateDraft(
        const ProfileEditDraft(
          experienceLevel: 'Intermediate',
          preferredUnits: PreferredUnit.imperial,
        ),
      );

      await controller.save();

      final state = container.read(AppProviders.profileControllerProvider);
      expect(state.requireValue.isSaving, isFalse);
      expect(state.requireValue.hasError, isFalse);
      expect(state.requireValue.profile, isNotNull);
    });

    test('save surfaces validation error when experienceLevel empty', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.profileControllerProvider.notifier,
      );

      await controller.build();
      await controller.updateDraft(const ProfileEditDraft(experienceLevel: ''));

      await controller.save();

      final state = container.read(AppProviders.profileControllerProvider);
      expect(
        state.requireValue.validationMessage,
        equals(AppStrings.onboardingValidationRequired),
      );
    });

    test('reload refreshes state', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.profileControllerProvider.notifier,
      );

      await controller.build();
      await controller.updateDraft(
        const ProfileEditDraft(experienceLevel: 'Beginner'),
      );
      await controller.save();

      await controller.reload();

      final state = container.read(AppProviders.profileControllerProvider);
      expect(state.requireValue.isLoading, isFalse);
      expect(state.requireValue.profile, isNotNull);
    });

    test('updatePreferredUnits updates draft units', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.profileControllerProvider.notifier,
      );

      await controller.build();

      await controller.updatePreferredUnits(PreferredUnit.imperial);

      final state = container.read(AppProviders.profileControllerProvider);
      expect(state.requireValue.draft!.preferredUnits, PreferredUnit.imperial);
    });

    test('updateBodyweightFromDisplay converts to canonical kg', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.profileControllerProvider.notifier,
      );

      await controller.build();
      await controller.updateDraft(
        const ProfileEditDraft(
          experienceLevel: 'Beginner',
          preferredUnits: PreferredUnit.imperial,
        ),
      );

      await controller.updateBodyweightFromDisplay('154');

      final state = container.read(AppProviders.profileControllerProvider);
      expect(state.requireValue.draft!.bodyweightKg, closeTo(69.9, 0.1));
    });

    test('save failure exposes safe message without leaking notes', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.profileControllerProvider.notifier,
      );

      await controller.build();
      await controller.updateDraft(
        ProfileEditDraft(
          experienceLevel: 'Intermediate',
          otherNotes: PrivacySentinelValues.fakeProfileNote,
        ),
      );

      db.close();

      await controller.save();

      final state = container.read(AppProviders.profileControllerProvider);
      expect(state.requireValue.isSaving, isFalse);
      expect(state.requireValue.hasError, isTrue);
      expect(state.requireValue.errorCode, equals('profile_save_failed'));
      expect(
        state.requireValue.errorMessage,
        equals(AppErrorStrings.profileSaveFailedMessage),
      );
      expect(
        state.requireValue.errorMessage,
        isNot(contains(PrivacySentinelValues.fakeProfileNote)),
      );
    });

    test(
      'impact evaluation does not expose profile notes in error state',
      () async {
        final container = createContainer();
        final controller = container.read(
          AppProviders.profileControllerProvider.notifier,
        );

        await controller.build();
        await controller.updateDraft(
          ProfileEditDraft(
            experienceLevel: 'Beginner',
            otherNotes: PrivacySentinelValues.fakeProfileNote,
          ),
        );

        final state = container.read(AppProviders.profileControllerProvider);
        expect(state.requireValue.impact, isNotNull);
        expect(state.requireValue.hasError, isFalse);
        expect(
          state.requireValue.draft!.otherNotes,
          equals(PrivacySentinelValues.fakeProfileNote),
        );
      },
    );

    test('updateHeightFromDisplay converts to canonical cm', () async {
      final container = createContainer();
      final controller = container.read(
        AppProviders.profileControllerProvider.notifier,
      );

      await controller.build();
      await controller.updateDraft(
        const ProfileEditDraft(
          experienceLevel: 'Beginner',
          preferredUnits: PreferredUnit.imperial,
        ),
      );

      await controller.updateHeightFromDisplay('69');

      final state = container.read(AppProviders.profileControllerProvider);
      expect(state.requireValue.draft!.heightCm, closeTo(175.3, 0.1));
    });
  });
}
