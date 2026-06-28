import 'package:aedify/core/network/network_status.dart';
import 'package:aedify/features/exercise_library/data/exercise_repository.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_seed.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/data/onboarding_repository.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/features/profile/domain/profile_view_data.dart';
import 'package:aedify/features/settings/data/byok_repository.dart';
import 'package:aedify/features/settings/data/provider_capability_repository.dart';
import 'package:aedify/features/settings/data/provider_gate_service.dart';
import 'package:aedify/features/settings/domain/byok_config_view_data.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_provider_option.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/features/settings/domain/provider_gate_decision.dart';
import 'package:aedify/features/settings/domain/provider_operation_type.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  bool _completed = false;
  OnboardingDraft? _saved;

  @override
  Future<bool> isOnboardingCompleted() async => _completed;

  @override
  Future<OnboardingDraft?> loadOnboardingDraft() async => _saved;

  @override
  Future<void> saveOnboardingDraft(OnboardingDraft draft) async {
    _saved = draft;
  }

  @override
  Future<void> completeOnboarding(OnboardingDraft draft) async {
    _saved = draft;
    _completed = true;
  }

  @override
  Future<void> clearOnboardingDraft() async {
    _saved = null;
  }
}

class FakeByokRepository implements ByokRepository {
  final _configs = <ByokConfigViewData>[];
  final _keys = <String, String>{};
  String? _activeConfigId;
  bool _shouldValidate = true;

  void setValidationResult(bool valid) {
    _shouldValidate = valid;
  }

  void addConfig(ByokConfigViewData config, {String? apiKey}) {
    _configs.removeWhere((c) => c.id == config.id);
    _configs.add(config);
    if (apiKey != null) {
      _keys[config.id] = apiKey;
    }
    if (config.isActive) {
      _activeConfigId = config.id;
    }
  }

  @override
  Future<List<ByokConfigViewData>> getConfigs() async =>
      List.unmodifiable(_configs);

  @override
  Future<ByokConfigViewData?> getActiveConfig() async {
    if (_activeConfigId == null) return null;
    try {
      return _configs.firstWhere((c) => c.id == _activeConfigId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasKey(String configId) async => _keys.containsKey(configId);

  @override
  Future<String> saveConfig(ByokEditDraft draft) async {
    final id =
        draft.configId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final config = ByokConfigViewData(
      id: id,
      providerName: draft.providerName ?? '',
      displayName: draft.providerName,
      selectedModel: draft.selectedModel,
      hasKey: draft.apiKey != null && draft.apiKey!.isNotEmpty,
      isActive: draft.makeActive,
      lastValidationStatus: null,
      lastErrorCode: null,
    );
    _configs.removeWhere((c) => c.id == id);
    _configs.add(config);
    if (draft.apiKey != null && draft.apiKey!.isNotEmpty) {
      _keys[id] = draft.apiKey!;
    }
    if (draft.makeActive) {
      _activeConfigId = id;
    }
    return id;
  }

  @override
  Future<void> rotateKey({
    required String configId,
    required String providerName,
    required String newApiKey,
  }) async {
    _keys[configId] = newApiKey;
  }

  @override
  Future<void> deleteConfig(String configId) async {
    _configs.removeWhere((c) => c.id == configId);
    _keys.remove(configId);
    if (_activeConfigId == configId) {
      _activeConfigId = null;
    }
  }

  @override
  Future<void> setActiveConfig(String configId) async {
    for (final config in _configs) {
      final updated = ByokConfigViewData(
        id: config.id,
        providerName: config.providerName,
        displayName: config.displayName,
        selectedModel: config.selectedModel,
        hasKey: config.hasKey,
        isActive: config.id == configId,
        lastValidationStatus: config.lastValidationStatus,
        lastErrorCode: config.lastErrorCode,
      );
      final idx = _configs.indexOf(config);
      _configs[idx] = updated;
    }
    _activeConfigId = configId;
  }

  @override
  Future<void> clearActiveConfig() async {
    for (final config in _configs) {
      final updated = ByokConfigViewData(
        id: config.id,
        providerName: config.providerName,
        displayName: config.displayName,
        selectedModel: config.selectedModel,
        hasKey: config.hasKey,
        isActive: false,
        lastValidationStatus: config.lastValidationStatus,
        lastErrorCode: config.lastErrorCode,
      );
      final idx = _configs.indexOf(config);
      _configs[idx] = updated;
    }
    _activeConfigId = null;
  }

  @override
  Future<List<ByokProviderOption>> getProviderOptions() async => [
    ByokProviderOption(
      id: 'openai',
      providerName: 'openai',
      displayName: 'OpenAI',
      description: '',
      models: [],
    ),
  ];

  @override
  Future<bool> validateKey({
    required String providerName,
    required String apiKey,
  }) async => _shouldValidate;
}

class FakeProfileRepository implements ProfileRepository {
  ProfileViewData? _profile;

  void setProfile(ProfileViewData profile) {
    _profile = profile;
  }

  @override
  Future<ProfileViewData?> getProfile() async => _profile;

  @override
  Future<void> saveProfile(ProfileEditDraft draft) async {
    _profile = ProfileViewData(
      displayName: draft.displayName,
      experienceLevel: draft.experienceLevel ?? '',
      goals: draft.goals,
      equipmentAccess: draft.equipmentAccess,
      trainingDaysPerWeek: draft.trainingDaysPerWeek,
      targetSessionLengthMinutes: draft.targetSessionLengthMinutes,
      preferredUnits: draft.preferredUnits,
      heightCm: draft.heightCm,
      bodyweightKg: draft.bodyweightKg,
      favoriteExerciseIds: draft.favoriteExerciseIds,
      substitutedExerciseIds: draft.substitutedExerciseIds,
      injuriesLimitations: draft.injuriesLimitations,
      otherNotes: draft.otherNotes,
      sex: draft.sex,
      dateOfBirth: draft.dateOfBirth,
      bench1RmKg: draft.bench1RmKg,
      squat1RmKg: draft.squat1RmKg,
      deadlift1RmKg: draft.deadlift1RmKg,
    );
  }

  @override
  Future<ProfileSaveImpact> evaluateSaveImpact(ProfileEditDraft draft) async =>
      ProfileSaveImpact.none;
}

class FakeProviderCapabilityRepository implements ProviderCapabilityRepository {
  ProviderCapabilityViewData? _capability;

  void setCapability(ProviderCapabilityViewData? capability) {
    _capability = capability;
  }

  @override
  Future<ProviderCapabilityViewData?> getCapability({
    required String providerName,
    required String modelName,
  }) async => _capability;

  @override
  Future<void> saveCapability(ProviderCapabilityViewData capability) async {
    _capability = capability;
  }

  @override
  Future<void> clearCapability({
    required String providerName,
    required String modelName,
  }) async {
    _capability = null;
  }
}

class FakeNetworkStatus extends NetworkStatus {
  FakeNetworkStatus({this.isOnline = true}) : super();

  @override
  final bool isOnline;

  @override
  Future<bool> check() async => isOnline;
}

class FakeProviderGateService implements ProviderGateService {
  FakeProviderGateService({required this.decision});

  final ProviderGateDecision decision;

  @override
  Future<ProviderGateDecision> evaluate({
    required ProviderOperationType operation,
  }) async => decision;
}

class FakeExerciseRepository implements ExerciseRepository {
  @override
  Future<List<ExerciseListItem>> searchExercises(
    ExerciseFilterState filters,
  ) async {
    return [];
  }

  @override
  Future<ExerciseDetailViewData?> getExerciseDetail(int exerciseId) async {
    return null;
  }

  @override
  Future<void> setFavorite({
    required int exerciseId,
    required bool isFavorite,
  }) async {}

  @override
  Future<void> setSubstitutedOut({
    required int exerciseId,
    required bool isSubstitutedOut,
  }) async {}

  @override
  Future<List<ExerciseListItem>> getCustomExercises() async => [];

  @override
  Future<ExerciseDetailViewData?> getCustomExerciseDetail(
    int exerciseId,
  ) async => null;

  @override
  Future<int> createCustomExercise(CustomExerciseSeed seed) async => 0;

  @override
  Future<void> updateCustomExercise({
    required int exerciseId,
    required CustomExerciseSeed seed,
  }) async {}

  @override
  Future<void> deleteCustomExercise(int exerciseId) async {}
}
