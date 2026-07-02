import 'dart:convert';

import 'package:aedify/core/logging/app_logger.dart';
import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/strength_anchor_dao.dart';
import 'package:aedify/core/db/daos/user_profile_dao.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/data/onboarding_repository.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/enum_codec.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/sex.dart';
import 'package:aedify/shared/domain/strength_anchor_source.dart';
import 'package:aedify/shared/domain/strength_anchor_type.dart';
import 'package:aedify/shared/domain/training_day.dart';

class DriftOnboardingRepository implements OnboardingRepository {
  DriftOnboardingRepository({required AppDatabase database})
    : _dao = UserProfileDao(database),
      _strengthAnchorDao = StrengthAnchorDao(database);

  static final _logger = AppLogger(name: 'DriftOnboardingRepository');

  final UserProfileDao _dao;
  final StrengthAnchorDao _strengthAnchorDao;

  @override
  Future<bool> isOnboardingCompleted() async {
    final profile = await _dao.getProfile();
    return profile?.onboardingCompleted ?? false;
  }

  @override
  Future<OnboardingDraft?> loadOnboardingDraft() async {
    final profile = await _dao.getProfile();
    if (profile == null) return null;
    return _profileToDraft(profile);
  }

  @override
  Future<void> saveOnboardingDraft(OnboardingDraft draft) async {
    _logger.info('save');
    final now = DateTime.now();
    final existing = await _dao.getProfile();
    await _dao.upsertProfile(
      UserProfileCompanion(
        id: const Value('default'),
        name: Value(draft.displayName),
        sex: Value(draft.sex?.dbValue),
        dateOfBirth: Value(draft.dateOfBirth),
        experienceLevel: Value(draft.experienceLevel?.dbValue ?? ''),
        goalsJson: Value(
          EnumCodec.encodeSet(draft.goals, (value) => value.dbValue),
        ),
        trainingDaysPerWeek: Value(draft.trainingDaysPerWeek),
        trainingDayNamesJson: Value(
          EnumCodec.encodeList(draft.trainingDays, (value) => value.dbValue),
        ),
        targetSessionLengthMinutes: Value(draft.targetSessionLengthMinutes),
        equipmentAccessJson: Value(
          EnumCodec.encodeSet(draft.equipmentAccess, (value) => value.dbValue),
        ),
        preferredUnits: Value(draft.preferredUnits?.dbValue ?? 'metric'),
        heightCm: Value(draft.heightCm),
        bodyweightKg: Value(draft.bodyweightKg),
        favoriteExerciseIdsJson: Value(jsonEncode(draft.favoriteExerciseIds)),
        substitutedExerciseIdsJson: Value(
          jsonEncode(draft.substitutedExerciseIds),
        ),
        injuriesLimitationsJson: Value(jsonEncode(draft.limitations)),
        otherNotes: Value(draft.notes),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> completeOnboarding(OnboardingDraft draft) async {
    _logger.info('complete');
    final now = DateTime.now();
    await saveOnboardingDraft(draft);

    final existingAnchors = await _strengthAnchorDao.getAllAnchors();
    for (final entry in _oneRmEntries(draft)) {
      final existingAnchor = existingAnchors
          .where((a) => a.id == entry.id)
          .firstOrNull;
      await _strengthAnchorDao.upsertAnchor(
        StrengthAnchorsCompanion(
          id: Value(entry.id),
          exerciseId: Value(entry.exerciseId),
          anchorType: Value(StrengthAnchorType.known1rm.dbValue),
          weightKg: Value(entry.weightKg),
          source: Value(StrengthAnchorSource.userEntered.dbValue),
          loggedAt: Value(entry.weightKg != null ? now : null),
          createdAt: Value(existingAnchor?.createdAt ?? now),
          updatedAt: Value(now),
        ),
      );
    }

    await _dao.markOnboardingCompleted(completedAt: now);
  }

  List<_OneRmEntry> _oneRmEntries(OnboardingDraft draft) => [
    _OneRmEntry(id: 'known_1rm_1', exerciseId: 1, weightKg: draft.bench1RmKg),
    _OneRmEntry(id: 'known_1rm_5', exerciseId: 5, weightKg: draft.squat1RmKg),
    _OneRmEntry(
      id: 'known_1rm_6',
      exerciseId: 6,
      weightKg: draft.deadlift1RmKg,
    ),
  ];

  @override
  Future<void> clearOnboardingDraft() async {
    await _clearDraftFields();
  }

  Future<void> _clearDraftFields() async {
    final now = DateTime.now();
    final existing = await _dao.getProfile();
    await _dao.upsertProfile(
      UserProfileCompanion(
        id: const Value('default'),
        name: const Value(null),
        sex: const Value(null),
        dateOfBirth: const Value(null),
        heightCm: const Value(null),
        bodyweightKg: const Value(null),
        bodyweightLoggedAt: Value(existing?.bodyweightLoggedAt),
        preferredUnits: const Value('metric'),
        experienceLevel: const Value(''),
        targetSessionLengthMinutes: const Value(null),
        trainingDaysPerWeek: const Value(null),
        trainingDayNamesJson: Value(existing?.trainingDayNamesJson ?? '[]'),
        onboardingCompleted: Value(existing?.onboardingCompleted ?? false),
        onboardingCompletedAt: Value(existing?.onboardingCompletedAt),
        goalsJson: const Value('[]'),
        equipmentAccessJson: const Value('[]'),
        favoriteExerciseIdsJson: const Value('[]'),
        substitutedExerciseIdsJson: const Value('[]'),
        injuriesLimitationsJson: const Value('[]'),
        otherNotes: const Value(null),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }

  OnboardingDraft _profileToDraft(UserProfileData profile) {
    return OnboardingDraft(
      displayName: profile.name,
      sex: profile.sex == null || profile.sex!.isEmpty
          ? null
          : Sex.fromDb(profile.sex!),
      dateOfBirth: profile.dateOfBirth,
      experienceLevel: profile.experienceLevel.isEmpty
          ? null
          : ExperienceLevel.fromDb(profile.experienceLevel),
      goals: EnumCodec.decodeSet(profile.goalsJson, GoalTag.fromDb),
      trainingDaysPerWeek: profile.trainingDaysPerWeek,
      trainingDays: EnumCodec.decodeList(
        profile.trainingDayNamesJson,
        TrainingDay.fromDb,
      ),
      targetSessionLengthMinutes: profile.targetSessionLengthMinutes,
      equipmentAccess: EnumCodec.decodeSet(
        profile.equipmentAccessJson,
        EquipmentTag.fromDb,
      ),
      preferredUnits: PreferredUnit.fromDb(profile.preferredUnits),
      heightCm: profile.heightCm,
      bodyweightKg: profile.bodyweightKg,
      favoriteExerciseIds: _decodeIntList(profile.favoriteExerciseIdsJson),
      substitutedExerciseIds: _decodeIntList(
        profile.substitutedExerciseIdsJson,
      ),
      limitations: _decodeJsonList(profile.injuriesLimitationsJson),
      notes: profile.otherNotes,
    );
  }

  List<String> _decodeJsonList(String json) {
    try {
      return (jsonDecode(json) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  List<int> _decodeIntList(String json) {
    try {
      return (jsonDecode(json) as List).cast<int>();
    } catch (_) {
      return [];
    }
  }
}

class _OneRmEntry {
  const _OneRmEntry({
    required this.id,
    required this.exerciseId,
    required this.weightKg,
  });

  final String id;
  final int exerciseId;
  final double? weightKg;
}
