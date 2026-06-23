import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/user_profile.dart';

part 'user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfile])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  Future<UserProfileData?> getProfile() async {
    return (select(
      userProfile,
    )..where((t) => t.id.equals('default'))).getSingleOrNull();
  }

  Future<void> upsertProfile(UserProfileCompanion profile) async {
    await into(userProfile).insertOnConflictUpdate(profile);
  }

  Future<void> markOnboardingCompleted({required DateTime completedAt}) async {
    await (update(userProfile)..where((t) => t.id.equals('default'))).write(
      UserProfileCompanion(
        onboardingCompleted: const Value(true),
        onboardingCompletedAt: Value(completedAt),
        updatedAt: Value(completedAt),
      ),
    );
  }
}
