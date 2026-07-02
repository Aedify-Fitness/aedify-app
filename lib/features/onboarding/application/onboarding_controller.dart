import 'dart:async';
import 'package:aedify/core/logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';

class OnboardingController extends AsyncNotifier<OnboardingState> {
  Timer? _draftSaveDebounceTimer;
  OnboardingDraft? _pendingDraftSave;

  static final _logger = AppLogger(name: 'OnboardingController');
  static const _debounceDuration = Duration(milliseconds: 400);

  @override
  Future<OnboardingState> build() async {
    _logger.info('build');
    ref.onDispose(() {
      _draftSaveDebounceTimer?.cancel();
    });
    final repository = ref.read(AppProviders.onboardingRepositoryProvider);
    final existing = await repository.loadOnboardingDraft();
    if (existing != null) {
      return OnboardingState(
        currentStep: _resumeStepForDraft(existing),
        draft: existing,
        isSaving: false,
      );
    }
    return const OnboardingState.initial();
  }

  void updateDraft(OnboardingDraft draft) {
    state = AsyncData(
      state.requireValue.copyWith(draft: draft, clearValidationMessage: true),
    );
    _scheduleDraftSave(draft);
  }

  Future<void> nextStep() async {
    final current = state.requireValue;

    final validationMessage = _validateStep(current.currentStep, current.draft);
    if (validationMessage != null) {
      state = AsyncData(current.copyWith(validationMessage: validationMessage));
      return;
    }

    await _flushPendingDraftSave();

    final next = _nextStepFor(current.currentStep);
    if (next == null) return;

    _logger.info('nextStep — ${current.currentStep.name} -> ${next.name}');
    state = AsyncData(
      current.copyWith(
        currentStep: next,
        clearValidationMessage: true,
        clearError: true,
      ),
    );
  }

  void previousStep() {
    final current = state.requireValue;
    final previous = _previousStepFor(current.currentStep);
    if (previous == null) return;

    _logger.info(
      'previousStep — ${current.currentStep.name} -> ${previous.name}',
    );
    state = AsyncData(
      current.copyWith(
        currentStep: previous,
        clearValidationMessage: true,
        clearError: true,
      ),
    );
  }

  void jumpToStep(OnboardingStep step) {
    _logger.info('jumpToStep — ${step.name}');
    state = AsyncData(
      state.requireValue.copyWith(
        currentStep: step,
        clearValidationMessage: true,
        clearError: true,
      ),
    );
  }

  Future<void> completeOnboarding() async {
    final current = state.requireValue;
    _logger.info('complete');
    state = AsyncData(current.copyWith(isSaving: true, clearError: true));

    final validationMessage = _validateStep(current.currentStep, current.draft);
    if (validationMessage != null) {
      state = AsyncData(
        current.copyWith(isSaving: false, validationMessage: validationMessage),
      );
      return;
    }

    try {
      await _flushPendingDraftSave();
      final repository = ref.read(AppProviders.onboardingRepositoryProvider);
      await repository.completeOnboarding(current.draft);
      ref.invalidate(AppProviders.onboardingStatusProvider);
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          clearValidationMessage: true,
          clearError: true,
        ),
      );
    } catch (e) {
      _logger.error('complete — failed', error: e);
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          errorCode: AppErrorCodes.onboardingSaveFailed,
          errorMessage: AppErrorStrings.onboardingSaveFailedMessage,
        ),
      );
    }
  }

  Future<void> restartOnboarding() async {
    _draftSaveDebounceTimer?.cancel();
    _pendingDraftSave = null;
    _logger.info('restart');
    try {
      final repository = ref.read(AppProviders.onboardingRepositoryProvider);
      await repository.clearOnboardingDraft();
      state = AsyncData(const OnboardingState.initial());
    } catch (e) {
      _logger.error('restart — failed', error: e);
      state = AsyncData(
        state.requireValue.copyWith(
          errorCode: AppErrorCodes.onboardingClearFailed,
          errorMessage: AppErrorStrings.onboardingSaveFailedMessage,
        ),
      );
    }
  }

  Future<void> loadExistingDraft() async {
    _logger.info('loadExistingDraft');
    try {
      final repository = ref.read(AppProviders.onboardingRepositoryProvider);
      final existing = await repository.loadOnboardingDraft();
      if (existing != null) {
        state = AsyncData(
          OnboardingState(
            currentStep: _resumeStepForDraft(existing),
            draft: existing,
            isSaving: false,
          ),
        );
      }
    } catch (e) {
      _logger.error('loadExistingDraft — failed', error: e);
      state = AsyncData(
        state.requireValue.copyWith(
          errorCode: AppErrorCodes.onboardingLoadFailed,
          errorMessage: AppErrorStrings.onboardingLoadFailedMessage,
        ),
      );
    }
  }

  void _scheduleDraftSave(OnboardingDraft draft) {
    _pendingDraftSave = draft;
    _draftSaveDebounceTimer?.cancel();
    _draftSaveDebounceTimer = Timer(_debounceDuration, () {
      _executePendingSave();
    });
  }

  Future<void> _flushPendingDraftSave() async {
    if (_pendingDraftSave == null) return;
    _draftSaveDebounceTimer?.cancel();
    _draftSaveDebounceTimer = null;
    await _executePendingSave();
  }

  Future<void> _executePendingSave() async {
    final draft = _pendingDraftSave;
    if (draft == null) return;
    _pendingDraftSave = null;
    try {
      final repository = ref.read(AppProviders.onboardingRepositoryProvider);
      await repository.saveOnboardingDraft(draft);
    } catch (e) {
      _logger.error('_executePendingSave — failed', error: e);
      state = AsyncData(
        state.requireValue.copyWith(
          errorCode: AppErrorCodes.onboardingSaveFailed,
          errorMessage: AppErrorStrings.onboardingSaveFailedMessage,
        ),
      );
    }
  }

  OnboardingStep _resumeStepForDraft(OnboardingDraft draft) {
    if (draft.experienceLevel == null) {
      return OnboardingStep.experienceGoals;
    }
    if (draft.trainingDays.isEmpty) {
      return OnboardingStep.schedule;
    }
    if (draft.equipmentAccess.isEmpty &&
        draft.preferredUnits == null &&
        draft.heightCm == null &&
        draft.bodyweightKg == null &&
        draft.sex == null &&
        draft.dateOfBirth == null &&
        draft.bench1RmKg == null &&
        draft.squat1RmKg == null &&
        draft.deadlift1RmKg == null &&
        draft.limitations.isEmpty &&
        draft.notes == null &&
        draft.favoriteExerciseIds.isEmpty &&
        draft.substitutedExerciseIds.isEmpty &&
        draft.byokSkipped) {
      return OnboardingStep.equipment;
    }
    if (draft.preferredUnits == null &&
        draft.heightCm == null &&
        draft.bodyweightKg == null &&
        draft.sex == null &&
        draft.dateOfBirth == null &&
        draft.bench1RmKg == null &&
        draft.squat1RmKg == null &&
        draft.deadlift1RmKg == null) {
      return OnboardingStep.unitsMetrics;
    }
    if (draft.limitations.isEmpty &&
        (draft.notes == null || draft.notes!.isEmpty) &&
        draft.favoriteExerciseIds.isEmpty &&
        draft.substitutedExerciseIds.isEmpty) {
      return OnboardingStep.limitations;
    }
    if (!draft.byokSkipped) {
      return OnboardingStep.review;
    }
    return OnboardingStep.review;
  }

  String? _validateStep(OnboardingStep step, OnboardingDraft draft) {
    switch (step) {
      case OnboardingStep.experienceGoals:
        if (draft.experienceLevel == null) {
          return AppStrings.onboardingValidationRequired;
        }
        return null;
      case OnboardingStep.schedule:
        if (draft.trainingDays.isEmpty) {
          return AppStrings.onboardingValidationRequired;
        }
        return null;
      case OnboardingStep.welcome:
      case OnboardingStep.equipment:
      case OnboardingStep.unitsMetrics:
      case OnboardingStep.limitations:
      case OnboardingStep.byokOptional:
      case OnboardingStep.review:
        return null;
    }
  }

  OnboardingStep? _nextStepFor(OnboardingStep current) {
    switch (current) {
      case OnboardingStep.welcome:
        return OnboardingStep.experienceGoals;
      case OnboardingStep.experienceGoals:
        return OnboardingStep.schedule;
      case OnboardingStep.schedule:
        return OnboardingStep.equipment;
      case OnboardingStep.equipment:
        return OnboardingStep.unitsMetrics;
      case OnboardingStep.unitsMetrics:
        return OnboardingStep.limitations;
      case OnboardingStep.limitations:
        return OnboardingStep.byokOptional;
      case OnboardingStep.byokOptional:
        return OnboardingStep.review;
      case OnboardingStep.review:
        return null;
    }
  }

  OnboardingStep? _previousStepFor(OnboardingStep current) {
    switch (current) {
      case OnboardingStep.experienceGoals:
        return OnboardingStep.welcome;
      case OnboardingStep.schedule:
        return OnboardingStep.experienceGoals;
      case OnboardingStep.equipment:
        return OnboardingStep.schedule;
      case OnboardingStep.unitsMetrics:
        return OnboardingStep.equipment;
      case OnboardingStep.limitations:
        return OnboardingStep.unitsMetrics;
      case OnboardingStep.byokOptional:
        return OnboardingStep.limitations;
      case OnboardingStep.review:
        return OnboardingStep.byokOptional;
      case OnboardingStep.welcome:
        return null;
    }
  }
}
