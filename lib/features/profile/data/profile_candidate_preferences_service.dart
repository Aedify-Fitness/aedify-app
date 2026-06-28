import 'package:aedify/features/profile/domain/profile_candidate_preferences.dart';

abstract class ProfileCandidatePreferencesService {
  Future<ProfileCandidatePreferences> buildPreferences();
}
