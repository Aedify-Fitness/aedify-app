import 'package:aedify/features/profile/data/profile_candidate_preferences_service.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/profile/data/default_profile_candidate_preferences_service.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/features/profile/domain/profile_view_data.dart';
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
        equipmentAccess: ['Dumbbell', 'Barbell', 'Kettlebell'],
      );
      final prefs = await service.buildPreferences();
      expect(prefs.allowedEquipment, containsAll(['Dumbbell', 'Barbell']));
      expect(prefs.allowedEquipment.length, 3);
    });

    test('returns empty allowedEquipment when no equipment access', () async {
      fakeRepo.profile = _profile(equipmentAccess: []);
      final prefs = await service.buildPreferences();
      expect(prefs.allowedEquipment, isEmpty);
    });

    test(
      'maps beginner experience into restricted allowedDifficulties',
      () async {
        fakeRepo.profile = _profile(experienceLevel: 'Beginner (0–6 mo)');
        final prefs = await service.buildPreferences();
        expect(prefs.allowedDifficulties, {'novice', 'beginner'});
      },
    );

    test(
      'maps intermediate experience into restricted allowedDifficulties',
      () async {
        fakeRepo.profile = _profile(
          experienceLevel: 'Intermediate (6 mo–2 yr)',
        );
        final prefs = await service.buildPreferences();
        expect(prefs.allowedDifficulties, {'beginner', 'intermediate'});
      },
    );

    test(
      'maps advanced experience into unrestricted allowedDifficulties',
      () async {
        fakeRepo.profile = _profile(experienceLevel: 'Advanced (2+ yr)');
        final prefs = await service.buildPreferences();
        expect(prefs.allowedDifficulties, {
          'novice',
          'beginner',
          'intermediate',
          'advanced',
        });
      },
    );

    test('returns all difficulties when experience level is null', () async {
      fakeRepo.profile = _profile(experienceLevel: null);
      final prefs = await service.buildPreferences();
      expect(prefs.allowedDifficulties, {
        'novice',
        'beginner',
        'intermediate',
        'advanced',
      });
    });

    test('returns all difficulties when experience level is unknown', () async {
      fakeRepo.profile = _profile(experienceLevel: 'Unknown value');
      final prefs = await service.buildPreferences();
      expect(prefs.allowedDifficulties, {
        'novice',
        'beginner',
        'intermediate',
        'advanced',
      });
    });

    test('maps build muscle goal into hypertrophy goal tag', () async {
      fakeRepo.profile = _profile(goals: ['Build muscle']);
      final prefs = await service.buildPreferences();
      expect(prefs.goalTags, contains('hypertrophy'));
    });

    test('maps lose weight goal into cardio goal tag', () async {
      fakeRepo.profile = _profile(goals: ['Lose weight']);
      final prefs = await service.buildPreferences();
      expect(prefs.goalTags, contains('cardio'));
    });

    test('maps increase strength goal into strength goal tag', () async {
      fakeRepo.profile = _profile(goals: ['Increase strength']);
      final prefs = await service.buildPreferences();
      expect(prefs.goalTags, contains('strength'));
    });

    test('maps improve endurance goal into cardio goal tag', () async {
      fakeRepo.profile = _profile(goals: ['Improve endurance']);
      final prefs = await service.buildPreferences();
      expect(prefs.goalTags, contains('cardio'));
    });

    test('maps multiple goals into multiple goal tags', () async {
      fakeRepo.profile = _profile(
        goals: ['Build muscle', 'Lose weight', 'Increase strength'],
      );
      final prefs = await service.buildPreferences();
      expect(
        prefs.goalTags,
        containsAll(['hypertrophy', 'cardio', 'strength']),
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
          goals: ['Build muscle', 'Improve endurance'],
        );
        final prefs = await service.buildPreferences();
        expect(prefs.allowedModalities, isEmpty);
      },
    );
  });
}

ProfileViewData _profile({
  String? experienceLevel = 'Intermediate (6 mo–2 yr)',
  List<String> goals = const ['Build muscle'],
  List<String> equipmentAccess = const ['Dumbbell', 'Barbell'],
  List<int> substitutedExerciseIds = const [],
}) {
  return ProfileViewData(
    displayName: null,
    experienceLevel: experienceLevel ?? '',
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
