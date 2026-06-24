import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/features/profile/domain/profile_view_data.dart';

abstract class ProfileRepository {
  Future<ProfileViewData?> getProfile();

  Future<void> saveProfile(ProfileEditDraft draft);

  Future<ProfileSaveImpact> evaluateSaveImpact(ProfileEditDraft draft);
}
