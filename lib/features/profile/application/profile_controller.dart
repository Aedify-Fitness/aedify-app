import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/features/profile/domain/profile_view_data.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/formatters/measurement_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  const ProfileState({
    required this.isLoading,
    this.profile,
    this.draft,
    this.impact = ProfileSaveImpact.none,
    this.validationMessage,
    this.errorCode,
    this.errorMessage,
    this.isSaving = false,
  });

  final bool isLoading;
  final ProfileViewData? profile;
  final ProfileEditDraft? draft;
  final ProfileSaveImpact impact;
  final String? validationMessage;
  final String? errorCode;
  final String? errorMessage;
  final bool isSaving;

  bool get hasError => errorCode != null;

  ProfileState copyWith({
    bool? isLoading,
    ProfileViewData? profile,
    ProfileEditDraft? draft,
    ProfileSaveImpact? impact,
    String? validationMessage,
    String? errorCode,
    String? errorMessage,
    bool? isSaving,
    bool clearProfile = false,
    bool clearDraft = false,
    bool clearValidationMessage = false,
    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: clearProfile ? null : (profile ?? this.profile),
      draft: clearDraft ? null : (draft ?? this.draft),
      impact: impact ?? this.impact,
      validationMessage: clearValidationMessage
          ? null
          : (validationMessage ?? this.validationMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSaving: isSaving ?? this.isSaving,
    );
  }

  const ProfileState.initial() : this(isLoading: true);
}

class ProfileController extends AsyncNotifier<ProfileState> {
  @override
  Future<ProfileState> build() async {
    final repository = ref.read(AppProviders.profileRepositoryProvider);
    try {
      final profile = await repository.getProfile();
      ProfileEditDraft? draft;
      if (profile != null) {
        draft = ProfileEditDraft(
          displayName: profile.displayName,
          sex: profile.sex,
          dateOfBirth: profile.dateOfBirth,
          bench1RmKg: profile.bench1RmKg,
          squat1RmKg: profile.squat1RmKg,
          deadlift1RmKg: profile.deadlift1RmKg,
          experienceLevel: profile.experienceLevel,
          goals: profile.goals,
          equipmentAccess: profile.equipmentAccess,
          trainingDaysPerWeek: profile.trainingDaysPerWeek,
          targetSessionLengthMinutes: profile.targetSessionLengthMinutes,
          preferredUnits: profile.preferredUnits,
          heightCm: profile.heightCm,
          bodyweightKg: profile.bodyweightKg,
          favoriteExerciseIds: profile.favoriteExerciseIds,
          substitutedExerciseIds: profile.substitutedExerciseIds,
          injuriesLimitations: profile.injuriesLimitations,
          otherNotes: profile.otherNotes,
        );
      }
      var impact = ProfileSaveImpact.none;
      if (draft != null) {
        impact = await repository.evaluateSaveImpact(draft);
      }
      return ProfileState(
        isLoading: false,
        profile: profile,
        draft: draft,
        impact: impact,
      );
    } catch (e) {
      return ProfileState(
        isLoading: false,
        errorCode: AppErrorCodes.profileLoadFailed,
        errorMessage: AppErrorStrings.profileLoadFailedMessage,
      );
    }
  }

  Future<void> updateDraft(ProfileEditDraft draft) async {
    final current = state.requireValue;
    final repository = ref.read(AppProviders.profileRepositoryProvider);
    final impact = await repository.evaluateSaveImpact(draft);
    state = AsyncData(
      current.copyWith(
        draft: draft,
        impact: impact,
        clearValidationMessage: true,
      ),
    );
  }

  Future<void> evaluateImpact() async {
    final current = state.requireValue;
    if (current.draft == null) return;
    final repository = ref.read(AppProviders.profileRepositoryProvider);
    final impact = await repository.evaluateSaveImpact(current.draft!);
    state = AsyncData(current.copyWith(impact: impact));
  }

  Future<void> save() async {
    final current = state.requireValue;
    if (current.draft == null) return;

    final validationMessage = _validateDraft(current.draft!);
    if (validationMessage != null) {
      state = AsyncData(current.copyWith(validationMessage: validationMessage));
      return;
    }

    state = AsyncData(current.copyWith(isSaving: true, clearError: true));

    try {
      final repository = ref.read(AppProviders.profileRepositoryProvider);
      await repository.saveProfile(current.draft!);
      final updatedProfile = await repository.getProfile();
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          profile: updatedProfile,
          draft: current.draft,
          clearValidationMessage: true,
          clearError: true,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          errorCode: AppErrorCodes.profileSaveFailed,
          errorMessage: AppErrorStrings.profileSaveFailedMessage,
        ),
      );
    }
  }

  Future<void> reload() async {
    final repository = ref.read(AppProviders.profileRepositoryProvider);
    state = const AsyncLoading();
    try {
      final profile = await repository.getProfile();
      state = AsyncData(ProfileState(isLoading: false, profile: profile));
    } catch (e) {
      state = AsyncData(
        ProfileState(
          isLoading: false,
          errorCode: AppErrorCodes.profileLoadFailed,
          errorMessage: AppErrorStrings.profileLoadFailedMessage,
        ),
      );
    }
  }

  Future<void> updatePreferredUnits(PreferredUnit unit) async {
    final current = state.requireValue;
    final draft = current.draft ?? const ProfileEditDraft();
    await updateDraft(draft.copyWith(preferredUnits: unit));
  }

  Future<void> updateBodyweightFromDisplay(String rawValue) async {
    final current = state.requireValue;
    final draft = current.draft ?? const ProfileEditDraft();
    final canonical = MeasurementParser.parseWeightToCanonicalKg(
      rawValue: rawValue,
      preferredUnit: draft.preferredUnits,
    );
    await updateDraft(draft.copyWith(bodyweightKg: canonical));
  }

  Future<void> updateHeightFromDisplay(String rawValue) async {
    final current = state.requireValue;
    final draft = current.draft ?? const ProfileEditDraft();
    final canonical = MeasurementParser.parseHeightToCanonicalCm(
      rawValue: rawValue,
      preferredUnit: draft.preferredUnits,
    );
    await updateDraft(draft.copyWith(heightCm: canonical));
  }

  String? _validateDraft(ProfileEditDraft draft) {
    if (draft.experienceLevel == null || draft.experienceLevel!.isEmpty) {
      return AppStrings.onboardingValidationRequired;
    }
    return null;
  }
}
