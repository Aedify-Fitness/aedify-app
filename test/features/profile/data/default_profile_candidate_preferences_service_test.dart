import 'package:aedify/features/profile/data/profile_candidate_preferences_service.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/profile/data/default_profile_candidate_preferences_service.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/features/profile/domain/profile_view_data.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/exercise_difficulty.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProfileRepository implements ProfileRepository {
  ProfileViewData? profile;

  @override
  Future<ProfileViewData?> getProfile() async => profile;

  @override
  Future<void> saveProfile(ProfileEditDraft draft) async {}

  @override
  Future<ProfileSaveImpact> evaluateSaveImpact(ProfileEditDraft draft) async {
    return ProfileSaveImpact.none;
  }
}

void main() {
  late _FakeProfileRepository fakeRepo;
  late ProfileCandidatePreferencesService service;

  setUp(() {
    fakeRepo = _FakeProfileRepository();
    service = DefaultProfileCandidatePreferencesService(
      profileRepository: fakeRepo,
    );
  });

  group('DefaultProfileCandidatePreferencesService', () {
    test('maps equipment access into allowedEquipment', () async {
      fakeRepo.profile = _profile(
        equipmentAccess: {
          EquipmentTag.dumbbell,
          EquipmentTag.barbell,
          EquipmentTag.kettlebell,
        },
      );
      final prefs = await service.buildPreferences();
      expect(
        prefs.allowedEquipment,
        containsAll({EquipmentTag.dumbbell, EquipmentTag.barbell}),
      );
      expect(prefs.allowedEquipment.length, 3);
    });

    test('returns empty allowedEquipment when no equipment access', () async {
      fakeRepo.profile = _profile(equipmentAccess: const <EquipmentTag>{});
      final prefs = await service.buildPreferences();
      expect(prefs.allowedEquipment, isEmpty);
    });

    test(
      'maps beginner experience into restricted allowedDifficulties',
      () async {
        fakeRepo.profile = _profile(experienceLevel: ExperienceLevel.beginner);
        final prefs = await service.buildPreferences();
        expect(prefs.allowedDifficulties, {
          ExerciseDifficulty.novice,
          ExerciseDifficulty.beginner,
        });
      },
    );

    test(
      'maps intermediate experience into restricted allowedDifficulties',
      () async {
        fakeRepo.profile = _profile(
          experienceLevel: ExperienceLevel.intermediate,
        );
        final prefs = await service.buildPreferences();
        expect(prefs.allowedDifficulties, {
          ExerciseDifficulty.beginner,
          ExerciseDifficulty.intermediate,
        });
      },
    );

    test(
      'maps advanced experience into unrestricted allowedDifficulties',
      () async {
        fakeRepo.profile = _profile(experienceLevel: ExperienceLevel.advanced);
        final prefs = await service.buildPreferences();
        expect(prefs.allowedDifficulties, ExerciseDifficulty.values.toSet());
      },
    );

    test(
      'maps novice experience into restricted allowedDifficulties',
      () async {
        fakeRepo.profile = _profile(experienceLevel: ExperienceLevel.novice);
        final prefs = await service.buildPreferences();
        expect(prefs.allowedDifficulties, {
          ExerciseDifficulty.novice,
          ExerciseDifficulty.beginner,
        });
      },
    );

    test('maps build muscle goal into hypertrophy goal tag', () async {
      fakeRepo.profile = _profile(goals: {GoalTag.buildMuscle});
      final prefs = await service.buildPreferences();
      expect(prefs.goalTags, contains(GoalTag.buildMuscle));
    });

    test('maps lose weight goal into cardio goal tag', () async {
      fakeRepo.profile = _profile(goals: {GoalTag.loseWeight});
      final prefs = await service.buildPreferences();
      expect(prefs.goalTags, contains(GoalTag.loseWeight));
    });

    test('maps increase strength goal into strength goal tag', () async {
      fakeRepo.profile = _profile(goals: {GoalTag.increaseStrength});
      final prefs = await service.buildPreferences();
      expect(prefs.goalTags, contains(GoalTag.increaseStrength));
    });

    test('maps improve endurance goal into cardio goal tag', () async {
      fakeRepo.profile = _profile(goals: {GoalTag.improveEndurance});
      final prefs = await service.buildPreferences();
      expect(prefs.goalTags, contains(GoalTag.improveEndurance));
    });

    test('maps multiple goals into multiple goal tags', () async {
      fakeRepo.profile = _profile(
        goals: {
          GoalTag.buildMuscle,
          GoalTag.loseWeight,
          GoalTag.increaseStrength,
        },
      );
      final prefs = await service.buildPreferences();
      expect(
        prefs.goalTags,
        containsAll({
          GoalTag.buildMuscle,
          GoalTag.loseWeight,
          GoalTag.increaseStrength,
        }),
      );
    });

    test('maps substituted exercise ids into excludedExerciseIds', () async {
      fakeRepo.profile = _profile(substitutedExerciseIds: [3, 7]);
      final prefs = await service.buildPreferences();
      expect(prefs.excludedExerciseIds, {3, 7});
    });

    test('returns empty excludedExerciseIds when no substitutions', () async {
      fakeRepo.profile = _profile(substitutedExerciseIds: []);
      final prefs = await service.buildPreferences();
      expect(prefs.excludedExerciseIds, isEmpty);
    });

    test('returns includeCustomExercises true by default', () async {
      fakeRepo.profile = _profile();
      final prefs = await service.buildPreferences();
      expect(prefs.includeCustomExercises, isTrue);
    });

    test('returns empty preferredMuscleGroups by default', () async {
      fakeRepo.profile = _profile();
      final prefs = await service.buildPreferences();
      expect(prefs.preferredMuscleGroups, isEmpty);
    });

    test(
      'returns empty excludedMuscleGroups when no structured data',
      () async {
        fakeRepo.profile = _profile();
        final prefs = await service.buildPreferences();
        expect(prefs.excludedMuscleGroups, isEmpty);
      },
    );

    test('returns empty preferences when profile is null', () async {
      fakeRepo.profile = null;
      final prefs = await service.buildPreferences();
      expect(prefs.allowedEquipment, isEmpty);
      expect(prefs.allowedDifficulties, isNotEmpty);
      expect(prefs.excludedExerciseIds, isEmpty);
      expect(prefs.includeCustomExercises, isTrue);
    });

    test(
      'returns empty allowedModalities (no hard filter on modality)',
      () async {
        fakeRepo.profile = _profile(
          goals: {GoalTag.buildMuscle, GoalTag.improveEndurance},
        );
        final prefs = await service.buildPreferences();
        expect(prefs.allowedModalities, isEmpty);
      },
    );
  });
}

ProfileViewData _profile({
  ExperienceLevel? experienceLevel = ExperienceLevel.intermediate,
  Set<GoalTag> goals = const {GoalTag.buildMuscle},
  Set<EquipmentTag> equipmentAccess = const {
    EquipmentTag.dumbbell,
    EquipmentTag.barbell,
  },
  List<int> substitutedExerciseIds = const [],
}) {
  return ProfileViewData(
    displayName: null,
    experienceLevel: experienceLevel ?? ExperienceLevel.intermediate,
    goals: goals,
    equipmentAccess: equipmentAccess,
    trainingDaysPerWeek: null,
    targetSessionLengthMinutes: null,
    preferredUnits: PreferredUnit.metric,
    heightCm: null,
    bodyweightKg: null,
    favoriteExerciseIds: [],
    substitutedExerciseIds: substitutedExerciseIds,
    injuriesLimitations: [],
    otherNotes: null,
    sex: null,
    dateOfBirth: null,
    bench1RmKg: null,
    squat1RmKg: null,
    deadlift1RmKg: null,
  );
}
