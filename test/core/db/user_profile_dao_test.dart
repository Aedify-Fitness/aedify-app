import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/user_profile_dao.dart';

void main() {
  late AppDatabase db;
  late UserProfileDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = UserProfileDao(db);
  });

  tearDown(() {
    db.close();
  });

  group('UserProfileDao', () {
    test('getProfile returns null initially', () async {
      final profile = await dao.getProfile();
      expect(profile, isNull);
    });

    test('upsertProfile saves and reloads profile', () async {
      final now = DateTime.now();
      await dao.upsertProfile(
        UserProfileCompanion(
          id: const Value('default'),
          experienceLevel: const Value('Intermediate'),
          preferredUnits: const Value('metric'),
          goalsJson: const Value('["Build muscle"]'),
          equipmentAccessJson: const Value('["Dumbbells"]'),
          favoriteExerciseIdsJson: const Value('[]'),
          substitutedExerciseIdsJson: const Value('[]'),
          injuriesLimitationsJson: const Value('[]'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final profile = await dao.getProfile();
      expect(profile, isNotNull);
      expect(profile!.experienceLevel, equals('Intermediate'));
    });

    test('markOnboardingCompleted updates completion fields', () async {
      final now = DateTime.now();
      await dao.upsertProfile(
        UserProfileCompanion(
          id: const Value('default'),
          experienceLevel: const Value('Beginner'),
          preferredUnits: const Value('metric'),
          goalsJson: const Value('[]'),
          equipmentAccessJson: const Value('[]'),
          favoriteExerciseIdsJson: const Value('[]'),
          substitutedExerciseIdsJson: const Value('[]'),
          injuriesLimitationsJson: const Value('[]'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await dao.markOnboardingCompleted(completedAt: now);

      final profile = await dao.getProfile();
      expect(profile!.onboardingCompleted, isTrue);
      expect(profile.onboardingCompletedAt, isNotNull);
    });
  });
}
