import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/user_profile_dao.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/data/onboarding_repository.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';

class DriftOnboardingRepository implements OnboardingRepository {
  DriftOnboardingRepository({required AppDatabase database})
    : _dao = UserProfileDao(database);

  final UserProfileDao _dao;

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
    final now = DateTime.now();
    final existing = await _dao.getProfile();
    await _dao.upsertProfile(
      UserProfileCompanion(
        id: const Value('default'),
        name: Value(draft.displayName),
        experienceLevel: Value(draft.experienceLevel ?? ''),
        goalsJson: Value(jsonEncode(draft.goals)),
        trainingDaysPerWeek: Value(draft.trainingDaysPerWeek),
        targetSessionLengthMinutes: Value(draft.targetSessionLengthMinutes),
        equipmentAccessJson: Value(jsonEncode(draft.equipmentAccess)),
        preferredUnits: Value(draft.preferredUnits?.dbValue ?? 'metric'),
        heightCm: Value(draft.heightCm),
        bodyweightKg: Value(draft.bodyweightKg),
        injuriesLimitationsJson: Value(jsonEncode(draft.limitations)),
        otherNotes: Value(draft.notes),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> completeOnboarding(OnboardingDraft draft) async {
    final now = DateTime.now();
    await saveOnboardingDraft(draft);
    await _dao.markOnboardingCompleted(completedAt: now);
  }

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
        sex: Value(existing?.sex),
        dateOfBirth: Value(existing?.dateOfBirth),
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
      experienceLevel: profile.experienceLevel,
      goals: _decodeJsonList(profile.goalsJson),
      trainingDaysPerWeek: profile.trainingDaysPerWeek,
      targetSessionLengthMinutes: profile.targetSessionLengthMinutes,
      equipmentAccess: _decodeJsonList(profile.equipmentAccessJson),
      preferredUnits: PreferredUnit.fromDb(profile.preferredUnits),
      heightCm: profile.heightCm,
      bodyweightKg: profile.bodyweightKg,
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
}
