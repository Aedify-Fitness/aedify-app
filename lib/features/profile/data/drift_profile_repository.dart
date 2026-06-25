import 'dart:convert';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/app_settings_dao.dart';
import 'package:aedify/core/db/daos/body_measurement_dao.dart';
import 'package:aedify/core/db/daos/strength_anchor_dao.dart';
import 'package:aedify/core/db/daos/user_profile_dao.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/features/profile/domain/profile_view_data.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:drift/drift.dart';

class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository({
    required AppDatabase database,
    required UserProfileDao userProfileDao,
    required AppSettingsDao appSettingsDao,
    required StrengthAnchorDao strengthAnchorDao,
    required BodyMeasurementDao bodyMeasurementDao,
  }) : _database = database,
       _userProfileDao = userProfileDao,
       _appSettingsDao = appSettingsDao,
       _strengthAnchorDao = strengthAnchorDao,
       _bodyMeasurementDao = bodyMeasurementDao;

  final AppDatabase _database;
  final UserProfileDao _userProfileDao;
  final AppSettingsDao _appSettingsDao;
  final StrengthAnchorDao _strengthAnchorDao;
  final BodyMeasurementDao _bodyMeasurementDao;

  @override
  Future<ProfileViewData?> getProfile() async {
    final profile = await _userProfileDao.getProfile();
    if (profile == null) return null;

    final anchors = await _strengthAnchorDao.getAllAnchors();

    return ProfileViewData(
      displayName: profile.name,
      experienceLevel: profile.experienceLevel,
      sex: profile.sex,
      dateOfBirth: profile.dateOfBirth,
      bench1RmKg: _findAnchorWeight(anchors, 1),
      squat1RmKg: _findAnchorWeight(anchors, 5),
      deadlift1RmKg: _findAnchorWeight(anchors, 6),
      goals: _decodeJsonList(profile.goalsJson),
      equipmentAccess: _decodeJsonList(profile.equipmentAccessJson),
      trainingDaysPerWeek: profile.trainingDaysPerWeek,
      targetSessionLengthMinutes: profile.targetSessionLengthMinutes,
      preferredUnits: PreferredUnit.fromDb(profile.preferredUnits),
      heightCm: profile.heightCm,
      bodyweightKg: profile.bodyweightKg,
      favoriteExerciseIds: _decodeIntList(profile.favoriteExerciseIdsJson),
      substitutedExerciseIds: _decodeIntList(
        profile.substitutedExerciseIdsJson,
      ),
      injuriesLimitations: _decodeJsonList(profile.injuriesLimitationsJson),
      otherNotes: profile.otherNotes,
    );
  }

  double? _findAnchorWeight(List<StrengthAnchor> anchors, int exerciseId) {
    for (final a in anchors) {
      if (a.anchorType == 'known_1rm' && a.exerciseId == exerciseId) {
        return a.weightKg;
      }
    }
    return null;
  }

  @override
  Future<void> saveProfile(ProfileEditDraft draft) async {
    final now = DateTime.now();
    await _database.inTransaction(() async {
      final existing = await _userProfileDao.getProfile();
      await _userProfileDao.upsertProfile(
        UserProfileCompanion(
          id: const Value('default'),
          name: Value(draft.displayName),
          sex: Value(draft.sex),
          dateOfBirth: Value(draft.dateOfBirth),
          experienceLevel: Value(draft.experienceLevel ?? ''),
          goalsJson: Value(_encodeJsonList(draft.goals)),
          equipmentAccessJson: Value(_encodeJsonList(draft.equipmentAccess)),
          trainingDaysPerWeek: Value(draft.trainingDaysPerWeek),
          targetSessionLengthMinutes: Value(draft.targetSessionLengthMinutes),
          preferredUnits: Value(draft.preferredUnits.dbValue),
          heightCm: Value(draft.heightCm),
          bodyweightKg: Value(draft.bodyweightKg),
          favoriteExerciseIdsJson: Value(
            _encodeJsonIntList(draft.favoriteExerciseIds),
          ),
          substitutedExerciseIdsJson: Value(
            _encodeJsonIntList(draft.substitutedExerciseIds),
          ),
          injuriesLimitationsJson: Value(
            _encodeJsonList(draft.injuriesLimitations),
          ),
          otherNotes: Value(draft.otherNotes),
          createdAt: Value(existing?.createdAt ?? now),
          updatedAt: Value(now),
        ),
      );

      final existingAnchors = await _strengthAnchorDao.getAllAnchors();
      for (final entry in _oneRmEntries(draft)) {
        final existingAnchor = existingAnchors
            .where((a) => a.id == entry.id)
            .firstOrNull;
        await _strengthAnchorDao.upsertAnchor(
          StrengthAnchorsCompanion(
            id: Value(entry.id),
            exerciseId: Value(entry.exerciseId),
            anchorType: const Value('known_1rm'),
            weightKg: Value(entry.weightKg),
            source: const Value('user_entered'),
            loggedAt: Value(entry.weightKg != null ? now : null),
            createdAt: Value(existingAnchor?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  @override
  Future<ProfileSaveImpact> evaluateSaveImpact(ProfileEditDraft draft) {
    return Future.value(ProfileSaveImpact.none);
  }

  List<String> _decodeJsonList(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list.cast<String>();
  }

  List<int> _decodeIntList(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list.cast<int>();
  }

  String _encodeJsonList(List<String> list) => jsonEncode(list);

  String _encodeJsonIntList(List<int> list) => jsonEncode(list);
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

List<_OneRmEntry> _oneRmEntries(ProfileEditDraft draft) => [
  _OneRmEntry(id: 'known_1rm_1', exerciseId: 1, weightKg: draft.bench1RmKg),
  _OneRmEntry(id: 'known_1rm_5', exerciseId: 5, weightKg: draft.squat1RmKg),
  _OneRmEntry(id: 'known_1rm_6', exerciseId: 6, weightKg: draft.deadlift1RmKg),
];
