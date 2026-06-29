import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/strength_anchor_dao.dart';
import 'package:aedify/core/db/daos/user_profile_dao.dart';
import 'package:aedify/features/profile/data/drift_profile_repository.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/sex.dart';
import '../../../support/privacy/privacy_sentinel_values.dart';

void main() {
  late AppDatabase db;
  late ProfileRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftProfileRepository(
      database: db,
      userProfileDao: UserProfileDao(db),
      strengthAnchorDao: StrengthAnchorDao(db),
    );
  });

  tearDown(() {
    db.close();
  });

  group('DriftProfileRepository', () {
    test('getProfile returns null when no profile exists', () async {
      final profile = await repository.getProfile();
      expect(profile, isNull);
    });

    test('saveProfile persists and returns mapped view data', () async {
      await repository.saveProfile(
        const ProfileEditDraft(
          experienceLevel: ExperienceLevel.intermediate,
          goals: {GoalTag.buildMuscle},
          equipmentAccess: {EquipmentTag.dumbbell, EquipmentTag.bench},
          trainingDaysPerWeek: 4,
          targetSessionLengthMinutes: 45,
          preferredUnits: PreferredUnit.metric,
          heightCm: 180,
          bodyweightKg: 80,
          injuriesLimitations: ['Knee'],
          otherNotes: 'Left knee strain',
        ),
      );

      final profile = await repository.getProfile();
      expect(profile, isNotNull);
      expect(profile!.experienceLevel, equals(ExperienceLevel.intermediate));
      expect(profile.goals, contains(GoalTag.buildMuscle));
      expect(profile.equipmentAccess, contains(EquipmentTag.dumbbell));
      expect(profile.trainingDaysPerWeek, equals(4));
      expect(profile.targetSessionLengthMinutes, equals(45));
      expect(profile.preferredUnits, equals(PreferredUnit.metric));
      expect(profile.heightCm, equals(180));
      expect(profile.bodyweightKg, equals(80));
      expect(profile.injuriesLimitations, contains('Knee'));
      expect(profile.otherNotes, equals('Left knee strain'));
      expect(profile.displayName, isNull);
      expect(profile.sex, isNull);
      expect(profile.dateOfBirth, isNull);
      expect(profile.bench1RmKg, isNull);
      expect(profile.squat1RmKg, isNull);
      expect(profile.deadlift1RmKg, isNull);
    });

    test('saveProfile persists sex, DOB, and 1RMs', () async {
      await repository.saveProfile(
        ProfileEditDraft(
          experienceLevel: ExperienceLevel.intermediate,
          displayName: 'Alex',
          sex: Sex.male,
          dateOfBirth: DateTime(1990, 6, 15),
          bench1RmKg: 80.0,
          squat1RmKg: 120.0,
          deadlift1RmKg: 140.0,
        ),
      );

      final profile = await repository.getProfile();
      expect(profile, isNotNull);
      expect(profile!.displayName, equals('Alex'));
      expect(profile.sex, equals(Sex.male));
      expect(profile.dateOfBirth, equals(DateTime(1990, 6, 15)));
      expect(profile.bench1RmKg, equals(80.0));
      expect(profile.squat1RmKg, equals(120.0));
      expect(profile.deadlift1RmKg, equals(140.0));
    });

    test('preferred units default to metric', () async {
      await repository.saveProfile(
        const ProfileEditDraft(experienceLevel: ExperienceLevel.beginner),
      );

      final profile = await repository.getProfile();
      expect(profile, isNotNull);
      expect(profile!.preferredUnits, equals(PreferredUnit.metric));
    });

    test(
      'profile repository stores canonical bodyweight and height without exposing notes externally',
      () async {
        await repository.saveProfile(
          const ProfileEditDraft(
            experienceLevel: ExperienceLevel.beginner,
            bodyweightKg: 98.7,
            heightCm: 175,
            otherNotes: PrivacySentinelValues.fakeProfileNote,
            injuriesLimitations: [PrivacySentinelValues.fakeInjuryNote],
          ),
        );

        final profile = await repository.getProfile();
        expect(profile!.bodyweightKg, equals(98.7));
        expect(profile.heightCm, equals(175));
        expect(
          profile.otherNotes,
          equals(PrivacySentinelValues.fakeProfileNote),
        );
        expect(
          profile.injuriesLimitations,
          contains(PrivacySentinelValues.fakeInjuryNote),
        );
      },
    );

    test(
      'profile repository keeps injuriesLimitations and notes in local profile fields only',
      () async {
        await repository.saveProfile(
          const ProfileEditDraft(
            experienceLevel: ExperienceLevel.beginner,
            otherNotes: PrivacySentinelValues.fakeProfileNote,
            injuriesLimitations: [PrivacySentinelValues.fakeInjuryNote],
          ),
        );

        final saved = await db.select(db.userProfile).get();
        expect(saved.length, 1);
        expect(
          saved.first.otherNotes,
          contains(PrivacySentinelValues.fakeProfileNote),
        );
        expect(
          saved.first.injuriesLimitationsJson,
          contains(PrivacySentinelValues.fakeInjuryNote),
        );
      },
    );

    test(
      'profile repository does not involve shared preferences for persistence',
      () async {
        await repository.saveProfile(
          const ProfileEditDraft(
            experienceLevel: ExperienceLevel.beginner,
            bodyweightKg: 80,
            preferredUnits: PreferredUnit.metric,
          ),
        );

        final profile = await repository.getProfile();
        expect(profile, isNotNull);
        expect(profile!.bodyweightKg, equals(80));
      },
    );

    test('evaluateSaveImpact returns none when no active plan', () async {
      final impact = await repository.evaluateSaveImpact(
        const ProfileEditDraft(experienceLevel: ExperienceLevel.advanced),
      );
      expect(impact, equals(ProfileSaveImpact.none));
    });
  });
}
