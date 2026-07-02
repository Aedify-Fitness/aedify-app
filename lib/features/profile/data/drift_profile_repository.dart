import 'dart:convert';

import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/strength_anchor_dao.dart';
import 'package:aedify/core/db/daos/user_profile_dao.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/features/profile/domain/profile_view_data.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/enum_codec.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/sex.dart';
import 'package:aedify/shared/domain/strength_anchor_source.dart';
import 'package:aedify/shared/domain/strength_anchor_type.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:drift/drift.dart';

class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository({
    required AppDatabase database,
    required UserProfileDao userProfileDao,
    required StrengthAnchorDao strengthAnchorDao,
  }) : _database = database,
       _userProfileDao = userProfileDao,
       _strengthAnchorDao = strengthAnchorDao;

  static final _logger = AppLogger(name: 'DriftProfileRepository');

  final AppDatabase _database;
  final UserProfileDao _userProfileDao;
  final StrengthAnchorDao _strengthAnchorDao;

  @override
  Future<ProfileViewData?> getProfile() async {
    _logger.debug('get');
    final profile = await _userProfileDao.getProfile();
    if (profile == null) return null;

    final anchors = await _strengthAnchorDao.getAllAnchors();

    return ProfileViewData(
      displayName: profile.name,
      experienceLevel: ExperienceLevel.fromDb(profile.experienceLevel),
      sex: profile.sex == null || profile.sex!.isEmpty
          ? null
          : Sex.fromDb(profile.sex!),
      dateOfBirth: profile.dateOfBirth,
      bench1RmKg: _findAnchorWeight(anchors, 1),
      squat1RmKg: _findAnchorWeight(anchors, 5),
      deadlift1RmKg: _findAnchorWeight(anchors, 6),
      goals: EnumCodec.decodeSet(profile.goalsJson, GoalTag.fromDb),
      equipmentAccess: EnumCodec.decodeSet(
        profile.equipmentAccessJson,
        EquipmentTag.fromDb,
      ),
      trainingDaysPerWeek: profile.trainingDaysPerWeek,
      trainingDays: EnumCodec.decodeList(
        profile.trainingDayNamesJson,
        TrainingDay.fromDb,
      ),
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
      if (a.anchorType == StrengthAnchorType.known1rm.dbValue &&
          a.exerciseId == exerciseId) {
        return a.weightKg;
      }
    }
    return null;
  }

  @override
  Future<void> saveProfile(ProfileEditDraft draft) async {
    _logger.info('save');
    final now = DateTime.now();
    await _database.inTransaction(() async {
      final existing = await _userProfileDao.getProfile();
      await _userProfileDao.upsertProfile(
        UserProfileCompanion(
          id: const Value('default'),
          name: Value(draft.displayName),
          sex: Value(draft.sex?.dbValue),
          dateOfBirth: Value(draft.dateOfBirth),
          experienceLevel: Value(draft.experienceLevel?.dbValue ?? ''),
          goalsJson: Value(
            EnumCodec.encodeSet(draft.goals, (value) => value.dbValue),
          ),
          equipmentAccessJson: Value(
            EnumCodec.encodeSet(
              draft.equipmentAccess,
              (value) => value.dbValue,
            ),
          ),
          trainingDaysPerWeek: Value(draft.trainingDaysPerWeek),
          trainingDayNamesJson: Value(
            EnumCodec.encodeList(draft.trainingDays, (value) => value.dbValue),
          ),
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
            anchorType: Value(StrengthAnchorType.known1rm.dbValue),
            weightKg: Value(entry.weightKg),
            source: Value(StrengthAnchorSource.userEntered.dbValue),
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

  List<int> _decodeIntList(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list.cast<int>();
  }

  List<String> _decodeJsonList(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list.cast<String>();
  }

  String _encodeJsonList(List<String> list) => jsonEncode(list);

  String _encodeJsonIntList(List<int> list) => jsonEncode(list);

  static List<_OneRmEntry> _oneRmEntries(ProfileEditDraft draft) => [
    _OneRmEntry(id: 'known_1rm_1', exerciseId: 1, weightKg: draft.bench1RmKg),
    _OneRmEntry(id: 'known_1rm_5', exerciseId: 5, weightKg: draft.squat1RmKg),
    _OneRmEntry(
      id: 'known_1rm_6',
      exerciseId: 6,
      weightKg: draft.deadlift1RmKg,
    ),
  ];
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
