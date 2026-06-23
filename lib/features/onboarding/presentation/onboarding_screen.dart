import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding_step_scaffold.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(
      AppProviders.onboardingControllerProvider,
    );

    return onboardingAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.onboardingLoadFailed,
                style: AppTextStyles.bodyMd,
              ),
              AppWhiteSpace.hMd,
              FilledButton(
                onPressed: () => ref
                    .read(AppProviders.onboardingControllerProvider.notifier)
                    .loadExistingDraft(),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
      data: (state) => _buildStep(context, ref, state),
    );
  }

  Widget _buildStep(
    BuildContext context,
    WidgetRef ref,
    OnboardingState state,
  ) {
    final controller = ref.read(
      AppProviders.onboardingControllerProvider.notifier,
    );

    if (state.currentStep == OnboardingStep.welcome) {
      return OnboardingStepScaffold(
        title: AppStrings.onboardingWelcomeTitle,
        onBack: null,
        onNext: () => controller.nextStep(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.onboardingWelcomeDescription,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        OnboardingProgressHeader(currentStep: state.currentStep),
        Expanded(
          child: _StepBody(
            state: state,
            onUpdateDraft: (draft) => controller.updateDraft(draft),
            onNext: () => controller.nextStep(),
            onBack: () => controller.previousStep(),
            onComplete: () => controller.completeOnboarding(),
          ),
        ),
      ],
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.state,
    required this.onUpdateDraft,
    required this.onNext,
    required this.onBack,
    required this.onComplete,
  });

  final OnboardingState state;
  final void Function(OnboardingDraft draft) onUpdateDraft;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final isByok = state.currentStep == OnboardingStep.byokOptional;
    final isReview = state.currentStep == OnboardingStep.review;

    String? secondaryLabel;
    VoidCallback? backAction;
    if (isByok) {
      secondaryLabel = AppStrings.skipForNow;
      backAction = () {
        onUpdateDraft(state.draft.copyWith(byokSkipped: true));
        onNext();
      };
    } else if (state.currentStep != OnboardingStep.experienceGoals) {
      backAction = onBack;
    }

    return OnboardingStepScaffold(
      title: _titleForStep(state.currentStep),
      onBack: backAction,
      onNext: isReview ? onComplete : onNext,
      isPrimaryLoading: state.isSaving,
      primaryLabel: isReview ? AppStrings.finishSetup : null,
      secondaryLabel: secondaryLabel,
      child: SingleChildScrollView(child: _stepContent(context)),
    );
  }

  String _titleForStep(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.experienceGoals:
        return AppStrings.onboardingExperienceTitle;
      case OnboardingStep.schedule:
        return AppStrings.onboardingScheduleTitle;
      case OnboardingStep.equipment:
        return AppStrings.onboardingEquipmentTitle;
      case OnboardingStep.unitsMetrics:
        return AppStrings.onboardingUnitsTitle;
      case OnboardingStep.limitations:
        return AppStrings.onboardingLimitationsTitle;
      case OnboardingStep.byokOptional:
        return AppStrings.onboardingByokOptionalTitle;
      case OnboardingStep.review:
        return AppStrings.onboardingReviewTitle;
      default:
        return '';
    }
  }

  Widget _stepContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildValidationOrError(context),
        switch (state.currentStep) {
          OnboardingStep.experienceGoals => _ExperienceGoalsStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.schedule => _ScheduleStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.equipment => _EquipmentStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.unitsMetrics => _UnitsMetricsStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.limitations => _LimitationsStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.byokOptional => _ByokOptionalStep(
            draft: state.draft,
            onUpdateDraft: onUpdateDraft,
          ),
          OnboardingStep.review => _ReviewStep(draft: state.draft),
          _ => const SizedBox.shrink(),
        },
      ],
    );
  }

  Widget _buildValidationOrError(BuildContext context) {
    if (state.hasValidationMessage) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(
          state.validationMessage!,
          style: AppTextStyles.labelSm.copyWith(
            color: context.colorScheme.error,
          ),
        ),
      );
    }
    if (state.hasError) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(
          state.errorMessage ?? '',
          style: AppTextStyles.labelSm.copyWith(
            color: context.colorScheme.error,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// --- Step widgets ---

class _ExperienceGoalsStep extends StatelessWidget {
  const _ExperienceGoalsStep({
    required this.draft,
    required this.onUpdateDraft,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const _experienceLevels = [
    AppStrings.onboardingExperienceBeginner,
    AppStrings.onboardingExperienceIntermediate,
    AppStrings.onboardingExperienceAdvanced,
  ];

  static const _goalOptions = [
    AppStrings.onboardingGoalBuildMuscle,
    AppStrings.onboardingGoalLoseWeight,
    AppStrings.onboardingGoalIncreaseStrength,
    AppStrings.onboardingGoalImproveEndurance,
    AppStrings.onboardingGoalGeneralFitness,
    AppStrings.onboardingGoalFlexibility,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.onboardingExperienceHint, style: AppTextStyles.labelMd),
        AppWhiteSpace.hSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _experienceLevels.map((level) {
            final selected = draft.experienceLevel == level;
            return ChoiceChip(
              label: Text(level),
              selected: selected,
              onSelected: (_) {
                onUpdateDraft(draft.copyWith(experienceLevel: level));
              },
            );
          }).toList(),
        ),
        AppWhiteSpace.hLg,
        Text(AppStrings.onboardingGoalsHint, style: AppTextStyles.labelMd),
        AppWhiteSpace.hSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _goalOptions.map((goal) {
            final selected = draft.goals.contains(goal);
            return FilterChip(
              label: Text(goal),
              selected: selected,
              onSelected: (isSelected) {
                final updated = isSelected
                    ? [...draft.goals, goal]
                    : draft.goals.where((g) => g != goal).toList();
                onUpdateDraft(draft.copyWith(goals: updated));
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ScheduleStep extends StatelessWidget {
  const _ScheduleStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.onboardingScheduleHint, style: AppTextStyles.labelMd),
        AppWhiteSpace.hSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: List.generate(7, (i) {
            final day = i + 1;
            final selected = draft.trainingDaysPerWeek == day;
            return ChoiceChip(
              label: Text('$day'),
              selected: selected,
              onSelected: (_) {
                onUpdateDraft(draft.copyWith(trainingDaysPerWeek: day));
              },
            );
          }),
        ),
        AppWhiteSpace.hLg,
        Text(
          AppStrings.onboardingSessionLengthHint,
          style: AppTextStyles.labelMd,
        ),
        AppWhiteSpace.hSm,
        SizedBox(
          width: 120,
          child: TextField(
            controller: TextEditingController(
              text: draft.targetSessionLengthMinutes?.toString() ?? '',
            ),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '45',
              suffixText: 'min',
            ),
            onChanged: (value) {
              final parsed = int.tryParse(value);
              onUpdateDraft(draft.copyWith(targetSessionLengthMinutes: parsed));
            },
          ),
        ),
      ],
    );
  }
}

class _EquipmentStep extends StatelessWidget {
  const _EquipmentStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const _equipmentOptions = [
    AppStrings.onboardingEquipmentNone,
    AppStrings.onboardingEquipmentDumbbells,
    AppStrings.onboardingEquipmentBarbell,
    AppStrings.onboardingEquipmentKettlebell,
    AppStrings.onboardingEquipmentResistanceBands,
    AppStrings.onboardingEquipmentCableMachine,
    AppStrings.onboardingEquipmentSmithMachine,
    AppStrings.onboardingEquipmentPullUpBar,
    AppStrings.onboardingEquipmentBench,
    AppStrings.onboardingEquipmentSquatRack,
    AppStrings.onboardingEquipmentCardioMachine,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.onboardingEquipmentHint, style: AppTextStyles.labelMd),
        AppWhiteSpace.hSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _equipmentOptions.map((equipment) {
            final selected = draft.equipmentAccess.contains(equipment);
            return FilterChip(
              label: Text(equipment),
              selected: selected,
              onSelected: (isSelected) {
                final updated = isSelected
                    ? [...draft.equipmentAccess, equipment]
                    : draft.equipmentAccess
                          .where((e) => e != equipment)
                          .toList();
                onUpdateDraft(draft.copyWith(equipmentAccess: updated));
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _UnitsMetricsStep extends StatelessWidget {
  const _UnitsMetricsStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.onboardingUnitsHint, style: AppTextStyles.labelMd),
        AppWhiteSpace.hSm,
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            ChoiceChip(
              label: const Text(AppStrings.onboardingUnitMetric),
              selected: draft.preferredUnits != 'imperial',
              onSelected: (_) {
                onUpdateDraft(draft.copyWith(preferredUnits: 'metric'));
              },
            ),
            ChoiceChip(
              label: const Text(AppStrings.onboardingUnitImperial),
              selected: draft.preferredUnits == 'imperial',
              onSelected: (_) {
                onUpdateDraft(draft.copyWith(preferredUnits: 'imperial'));
              },
            ),
          ],
        ),
        AppWhiteSpace.hLg,
        Text(AppStrings.onboardingHeightHint, style: AppTextStyles.labelMd),
        AppWhiteSpace.hSm,
        SizedBox(
          width: 120,
          child: TextField(
            controller: TextEditingController(
              text: draft.heightCm?.toString() ?? '',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: '170',
              suffixText: 'cm',
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              onUpdateDraft(draft.copyWith(heightCm: parsed));
            },
          ),
        ),
        AppWhiteSpace.hLg,
        Text(AppStrings.onboardingWeightHint, style: AppTextStyles.labelMd),
        AppWhiteSpace.hSm,
        SizedBox(
          width: 120,
          child: TextField(
            controller: TextEditingController(
              text: draft.bodyweightKg?.toString() ?? '',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: '70', suffixText: 'kg'),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              onUpdateDraft(draft.copyWith(bodyweightKg: parsed));
            },
          ),
        ),
      ],
    );
  }
}

class _LimitationsStep extends StatelessWidget {
  const _LimitationsStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const _limitationOptions = [
    AppStrings.onboardingLimitationNone,
    AppStrings.onboardingLimitationLowerBack,
    AppStrings.onboardingLimitationKnee,
    AppStrings.onboardingLimitationShoulder,
    AppStrings.onboardingLimitationWrist,
    AppStrings.onboardingLimitationHip,
    AppStrings.onboardingLimitationNeck,
    AppStrings.onboardingLimitationElbow,
    AppStrings.onboardingLimitationAnkle,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.onboardingLimitationsHint,
          style: AppTextStyles.labelMd,
        ),
        AppWhiteSpace.hSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _limitationOptions.map((limitation) {
            final selected = draft.limitations.contains(limitation);
            return FilterChip(
              label: Text(limitation),
              selected: selected,
              onSelected: (isSelected) {
                final updated = isSelected
                    ? [...draft.limitations, limitation]
                    : draft.limitations.where((l) => l != limitation).toList();
                onUpdateDraft(draft.copyWith(limitations: updated));
              },
            );
          }).toList(),
        ),
        AppWhiteSpace.hLg,
        Text(AppStrings.onboardingNotesHint, style: AppTextStyles.labelMd),
        AppWhiteSpace.hSm,
        TextField(
          controller: TextEditingController(text: draft.notes ?? ''),
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: AppStrings.onboardingNotesHint,
          ),
          onChanged: (value) {
            onUpdateDraft(draft.copyWith(notes: value.isEmpty ? null : value));
          },
        ),
      ],
    );
  }
}

class _ByokOptionalStep extends StatelessWidget {
  const _ByokOptionalStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.onboardingByokDescription,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.draft});

  final OnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.onboardingReviewPreparing,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hLg,
        _reviewRow(
          context,
          AppStrings.onboardingExperienceHint,
          draft.experienceLevel ?? '—',
        ),
        _reviewRow(
          context,
          AppStrings.onboardingGoalsHint,
          draft.goals.isEmpty ? '—' : draft.goals.join(', '),
        ),
        _reviewRow(
          context,
          AppStrings.onboardingScheduleHint,
          draft.trainingDaysPerWeek != null
              ? '${draft.trainingDaysPerWeek} ${AppStrings.onboardingReviewDaysPerWeek}'
              : '—',
        ),
        _reviewRow(
          context,
          AppStrings.onboardingEquipmentHint,
          draft.equipmentAccess.isEmpty
              ? '—'
              : draft.equipmentAccess.join(', '),
        ),
        _reviewRow(
          context,
          AppStrings.onboardingUnitsHint,
          draft.preferredUnits ?? 'metric',
        ),
        if (draft.heightCm != null)
          _reviewRow(
            context,
            AppStrings.onboardingHeightHint,
            '${draft.heightCm} ${AppStrings.onboardingReviewCm}',
          ),
        if (draft.bodyweightKg != null)
          _reviewRow(
            context,
            AppStrings.onboardingWeightHint,
            '${draft.bodyweightKg} ${AppStrings.onboardingReviewKg}',
          ),
        _reviewRow(
          context,
          AppStrings.onboardingLimitationsHint,
          draft.limitations.isEmpty ? '—' : draft.limitations.join(', '),
        ),
        if (draft.notes != null && draft.notes!.isNotEmpty)
          _reviewRow(context, AppStrings.onboardingNotesHint, draft.notes!),
        _reviewRow(
          context,
          AppStrings.onboardingByokOptionalTitle,
          draft.byokSkipped
              ? AppStrings.skipForNow
              : AppStrings.onboardingReviewConfigured,
        ),
      ],
    );
  }

  Widget _reviewRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(value, style: AppTextStyles.bodyMd),
        ],
      ),
    );
  }
}
