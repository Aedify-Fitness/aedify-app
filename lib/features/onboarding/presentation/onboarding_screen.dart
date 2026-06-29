import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding_step_scaffold.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_provider_option.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_colors.dart';
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
      data: (state) => _OnboardingStepView(state: state),
    );
  }
}

class _OnboardingStepView extends ConsumerWidget {
  const _OnboardingStepView({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      AppProviders.onboardingControllerProvider.notifier,
    );

    return _StepBody(
      state: state,
      onUpdateDraft: (draft) => controller.updateDraft(draft),
      onNext: () => controller.nextStep(),
      onBack: () => controller.previousStep(),
      onComplete: () => controller.completeOnboarding(),
      onJumpToStep: (step) => controller.jumpToStep(step),
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
    required this.onJumpToStep,
  });

  final OnboardingState state;
  final void Function(OnboardingDraft draft) onUpdateDraft;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onComplete;
  final void Function(OnboardingStep) onJumpToStep;

  @override
  Widget build(BuildContext context) {
    final isReview = state.currentStep == OnboardingStep.review;

    return OnboardingStepScaffold(
      title: _titleForStep(state.currentStep),
      description: _descriptionForStep(state.currentStep),
      header: OnboardingProgressHeader(currentStep: state.currentStep),
      hero: state.currentStep == OnboardingStep.welcome
          ? const _WelcomeHero()
          : null,
      onBack: state.currentStep == OnboardingStep.welcome ? null : onBack,
      onNext: isReview ? onComplete : onNext,
      isPrimaryLoading: state.isSaving,
      primaryLabel: isReview ? AppStrings.finishSetup : null,
      child: _StepContent(
        state: state,
        onUpdateDraft: onUpdateDraft,
        onJumpToStep: onJumpToStep,
      ),
    );
  }

  String _titleForStep(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        return '';
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
    }
  }

  String? _descriptionForStep(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        return null;
      case OnboardingStep.experienceGoals:
        return AppStrings.onboardingExperienceDescription;
      case OnboardingStep.schedule:
        return AppStrings.onboardingScheduleDescription;
      case OnboardingStep.equipment:
        return AppStrings.onboardingEquipmentDescription;
      case OnboardingStep.unitsMetrics:
        return AppStrings.onboardingUnitsDescription;
      case OnboardingStep.limitations:
        return AppStrings.onboardingLimitationsDescription;
      case OnboardingStep.byokOptional:
        return AppStrings.onboardingByokDetail;
      case OnboardingStep.review:
        return AppStrings.onboardingReviewDescription;
    }
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.state,
    required this.onUpdateDraft,
    required this.onJumpToStep,
  });

  final OnboardingState state;
  final void Function(OnboardingDraft) onUpdateDraft;
  final void Function(OnboardingStep) onJumpToStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ValidationMessage(state: state),
        switch (state.currentStep) {
          OnboardingStep.welcome => const _WelcomeStep(),
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
          OnboardingStep.review => _ReviewStep(
            draft: state.draft,
            onJumpToStep: onJumpToStep,
          ),
        },
      ],
    );
  }
}

class _ValidationMessage extends StatelessWidget {
  const _ValidationMessage({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final message = state.hasValidationMessage
        ? state.validationMessage
        : state.hasError
        ? state.errorMessage
        : null;
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: _SurfacePanel(
        backgroundColor: context.colorScheme.errorContainer,
        borderColor: context.colorScheme.error,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onErrorContainer,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatefulWidget {
  const _FormField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
    this.hintText,
    this.suffixText,
    this.width,
    this.maxLines,
  });

  final String initialValue;
  final void Function(String) onChanged;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? suffixText;
  final double? width;
  final int? maxLines;

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixText: widget.suffixText,
      ),
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: textField);
    }
    return textField;
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.headlineXl.copyWith(
              color: context.colorScheme.onSurface,
            ),
            children: [
              const TextSpan(text: AppStrings.onboardingWelcomeHeroLineOne),
              const TextSpan(text: '\n'),
              TextSpan(
                text: AppStrings.onboardingWelcomeHeroLineTwo,
                style: AppTextStyles.headlineXl.copyWith(
                  color: context.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hMd,
        Text(
          AppStrings.onboardingWelcomeDescription,
          style: AppTextStyles.bodyLg.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hSm,
        Text(
          AppStrings.onboardingWelcomeHeroDescription,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelHeader(
                iconAsset: OutlinedSvgAssets.shieldCheck,
                title: AppStrings.onboardingWelcomePrivacyTitle,
              ),
              AppWhiteSpace.hMd,
              const _FeatureBullet(
                iconAsset: OutlinedSvgAssets.lockClosed,
                message: AppStrings.onboardingWelcomePrivacyBulletOne,
              ),
              AppWhiteSpace.hSm,
              const _FeatureBullet(
                iconAsset: OutlinedSvgAssets.sparkles,
                message: AppStrings.onboardingWelcomePrivacyBulletTwo,
              ),
              AppWhiteSpace.hSm,
              const _FeatureBullet(
                iconAsset: OutlinedSvgAssets.pencilSquare,
                message: AppStrings.onboardingWelcomePrivacyBulletThree,
              ),
            ],
          ),
        ),
        AppWhiteSpace.hLg,
        _SurfacePanel(
          backgroundColor: context.colorScheme.surfaceContainerLow,
          borderColor: context.theme.brightness == Brightness.light
              ? AedifyLightColors.secondaryBorder
              : AedifyDarkColors.secondaryBorder,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelHeader(
                iconAsset: OutlinedSvgAssets.cpuChip,
                title: AppStrings.onboardingWelcomeAiCardTitle,
              ),
              AppWhiteSpace.hMd,
              Text(
                AppStrings.onboardingWelcomeAiCardDescription,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hLg,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: context.colorScheme.outlineVariant,
                    width: AppSizing.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.onboardingWelcomeAiCardButton,
                        style: AppTextStyles.labelMd,
                      ),
                    ),
                    SvgPicture.asset(
                      OutlinedSvgAssets.arrowRight,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExperienceGoalsStep extends StatelessWidget {
  const _ExperienceGoalsStep({
    required this.draft,
    required this.onUpdateDraft,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const _experienceLevels = [
    (
      AppStrings.onboardingExperienceBeginner,
      AppStrings.onboardingExperienceBeginnerDescription,
      OutlinedSvgAssets.faceSmile,
    ),
    (
      AppStrings.onboardingExperienceIntermediate,
      AppStrings.onboardingExperienceIntermediateDescription,
      OutlinedSvgAssets.chartBar,
    ),
    (
      AppStrings.onboardingExperienceAdvanced,
      AppStrings.onboardingExperienceAdvancedDescription,
      OutlinedSvgAssets.rocketLaunch,
    ),
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
      children: [
        _SurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: AppStrings.onboardingExperienceHint),
              AppWhiteSpace.hMd,
              for (final level in _experienceLevels) ...[
                _SelectionCard(
                  title: level.$1,
                  description: level.$2,
                  iconAsset: level.$3,
                  selected: draft.experienceLevel == level.$1,
                  onTap: () {
                    onUpdateDraft(draft.copyWith(experienceLevel: level.$1));
                  },
                ),
                if (level != _experienceLevels.last) AppWhiteSpace.hSm,
              ],
            ],
          ),
        ),
        AppWhiteSpace.hLg,
        _SurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: AppStrings.onboardingGoalsHint),
              AppWhiteSpace.hMd,
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
          ),
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
      children: [
        _SurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: AppStrings.onboardingScheduleHint),
              AppWhiteSpace.hMd,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: List.generate(7, (index) {
                  final day = index + 1;
                  return _MetricTile(
                    value: '$day',
                    label: day == 1
                        ? AppStrings.onboardingDaySingle
                        : AppStrings.onboardingDayPlural,
                    selected: draft.trainingDaysPerWeek == day,
                    onTap: () {
                      onUpdateDraft(draft.copyWith(trainingDaysPerWeek: day));
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hLg,
        _SurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                title: AppStrings.onboardingSessionLengthHint,
              ),
              AppWhiteSpace.hMd,
              _FormField(
                width: AppSizing.fieldWidth,
                initialValue:
                    draft.targetSessionLengthMinutes?.toString() ?? '',
                keyboardType: TextInputType.number,
                hintText: AppStrings.onboardingHintSessionMin,
                suffixText: AppStrings.onboardingReviewMinutes,
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  onUpdateDraft(
                    draft.copyWith(targetSessionLengthMinutes: parsed),
                  );
                },
              ),
            ],
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

  static const _foundationEquipment = [
    AppStrings.onboardingEquipmentNone,
    AppStrings.onboardingEquipmentDumbbells,
    AppStrings.onboardingEquipmentBarbell,
    AppStrings.onboardingEquipmentBench,
    AppStrings.onboardingEquipmentSquatRack,
  ];

  static const _accessoryEquipment = [
    AppStrings.onboardingEquipmentKettlebell,
    AppStrings.onboardingEquipmentResistanceBands,
    AppStrings.onboardingEquipmentPullUpBar,
  ];

  static const _machineEquipment = [
    AppStrings.onboardingEquipmentCableMachine,
    AppStrings.onboardingEquipmentSmithMachine,
    AppStrings.onboardingEquipmentCardioMachine,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EquipmentGroupCard(
          title: AppStrings.onboardingEquipmentGroupFoundation,
          description: AppStrings.onboardingEquipmentGroupFoundationDescription,
          items: _foundationEquipment,
          selectedItems: draft.equipmentAccess,
          onToggle: _toggleEquipment,
        ),
        AppWhiteSpace.hLg,
        _EquipmentGroupCard(
          title: AppStrings.onboardingEquipmentGroupAccessories,
          description:
              AppStrings.onboardingEquipmentGroupAccessoriesDescription,
          items: _accessoryEquipment,
          selectedItems: draft.equipmentAccess,
          onToggle: _toggleEquipment,
        ),
        AppWhiteSpace.hLg,
        _EquipmentGroupCard(
          title: AppStrings.onboardingEquipmentGroupMachines,
          description: AppStrings.onboardingEquipmentGroupMachinesDescription,
          items: _machineEquipment,
          selectedItems: draft.equipmentAccess,
          onToggle: _toggleEquipment,
        ),
      ],
    );
  }

  void _toggleEquipment(String equipment, bool isSelected) {
    final updated = isSelected
        ? [...draft.equipmentAccess, equipment]
        : draft.equipmentAccess.where((item) => item != equipment).toList();
    onUpdateDraft(draft.copyWith(equipmentAccess: updated));
  }
}

class _UnitsMetricsStep extends StatelessWidget {
  const _UnitsMetricsStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  Widget build(BuildContext context) {
    final preferredUnit = draft.preferredUnits ?? PreferredUnit.metric;

    return Column(
      children: [
        _SurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: AppStrings.onboardingUnitsHint),
              AppWhiteSpace.hMd,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: PreferredUnit.values
                    .map(
                      (e) => ChoiceChip(
                        label: Text(e.displayLabel),
                        selected: preferredUnit == e,
                        onSelected: (_) {
                          final convertedHeight = draft.heightCm != null
                              ? double.parse(
                                  e
                                      .toImperialHeight(draft.heightCm!)
                                      .toStringAsFixed(1),
                                )
                              : null;
                          final convertedWeight = draft.bodyweightKg != null
                              ? double.parse(
                                  e
                                      .toImperialWeight(draft.bodyweightKg!)
                                      .toStringAsFixed(1),
                                )
                              : null;
                          onUpdateDraft(
                            draft.copyWith(
                              preferredUnits: e,
                              heightCm: convertedHeight,
                              bodyweightKg: convertedWeight,
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hLg,
        _SurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: AppStrings.onboardingBodyMetricsTitle),
              AppWhiteSpace.hMd,
              _InputLabel(title: preferredUnit.heightLabel),
              AppWhiteSpace.hSm,
              _FormField(
                key: ValueKey('height_${draft.preferredUnits}'),
                width: AppSizing.fieldWidth,
                initialValue: draft.heightCm != null
                    ? preferredUnit
                          .toImperialHeight(draft.heightCm!)
                          .toStringAsFixed(1)
                    : draft.heightCm?.toStringAsFixed(1) ?? '',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                hintText: preferredUnit.heightHint,
                suffixText: preferredUnit.heightUnit,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  final heightCm = parsed != null
                      ? preferredUnit.toMetricHeight(parsed)
                      : parsed;
                  onUpdateDraft(draft.copyWith(heightCm: heightCm));
                },
              ),
              AppWhiteSpace.hLg,
              _InputLabel(title: preferredUnit.weightLabel),
              AppWhiteSpace.hSm,
              _FormField(
                key: ValueKey('weight_${draft.preferredUnits}'),
                width: AppSizing.fieldWidth,
                initialValue: draft.bodyweightKg != null
                    ? preferredUnit
                          .toImperialWeight(draft.bodyweightKg!)
                          .toStringAsFixed(1)
                    : draft.bodyweightKg?.toStringAsFixed(1) ?? '',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                hintText: preferredUnit.weightHint,
                suffixText: preferredUnit.weightUnit,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  final bodyweightKg = parsed != null
                      ? preferredUnit.toMetricWeight(parsed)
                      : parsed;
                  onUpdateDraft(draft.copyWith(bodyweightKg: bodyweightKg));
                },
              ),
            ],
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
      children: [
        _SurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: AppStrings.onboardingLimitationsHint),
              AppWhiteSpace.hMd,
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
                          : draft.limitations
                                .where((item) => item != limitation)
                                .toList();
                      onUpdateDraft(draft.copyWith(limitations: updated));
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hLg,
        _SurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: AppStrings.onboardingNotesHint),
              AppWhiteSpace.hMd,
              _FormField(
                initialValue: draft.notes ?? '',
                maxLines: 4,
                hintText: AppStrings.onboardingNotesHint,
                onChanged: (value) {
                  onUpdateDraft(
                    draft.copyWith(notes: value.isEmpty ? null : value),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---- BYOK Form State (file-private, auto-dispose) ----

class _ByokFormState {
  const _ByokFormState({
    this.selectedProvider,
    this.selectedModel,
    this.isSaving = false,
    this.hasSaved = false,
  });

  final String? selectedProvider;
  final String? selectedModel;
  final bool isSaving;
  final bool hasSaved;

  _ByokFormState copyWith({
    String? selectedProvider,
    String? selectedModel,
    bool? isSaving,
    bool? hasSaved,
    bool clearProvider = false,
    bool clearModel = false,
  }) {
    return _ByokFormState(
      selectedProvider: clearProvider
          ? null
          : (selectedProvider ?? this.selectedProvider),
      selectedModel: clearModel ? null : (selectedModel ?? this.selectedModel),
      isSaving: isSaving ?? this.isSaving,
      hasSaved: hasSaved ?? this.hasSaved,
    );
  }
}

class _ByokFormNotifier extends Notifier<_ByokFormState> {
  @override
  _ByokFormState build() => const _ByokFormState();

  void selectProvider(String providerName, List<ByokProviderOption> options) {
    final option = options.firstWhere((o) => o.providerName == providerName);
    state = state.copyWith(
      selectedProvider: providerName,
      selectedModel: option.models.isNotEmpty ? option.models.first.id : null,
    );
  }

  void selectModel(String? modelId) {
    state = state.copyWith(selectedModel: modelId);
  }

  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving);
  }

  void markSaved() {
    state = state.copyWith(hasSaved: true, isSaving: false);
  }
}

final _byokOptionsProvider =
    FutureProvider.autoDispose<List<ByokProviderOption>>((ref) {
      return ref.read(AppProviders.byokRepositoryProvider).getProviderOptions();
    });

final _byokFormProvider =
    NotifierProvider.autoDispose<_ByokFormNotifier, _ByokFormState>(
      _ByokFormNotifier.new,
    );

// ---- BYOK Optional Step ----

class _ByokOptionalStep extends ConsumerStatefulWidget {
  const _ByokOptionalStep({required this.draft, required this.onUpdateDraft});

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  _ByokOptionalStepState createState() => _ByokOptionalStepState();
}

class _ByokOptionalStepState extends ConsumerState<_ByokOptionalStep> {
  final _keyController = TextEditingController();
  final _obscured = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _keyController.dispose();
    _obscured.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    final formState = ref.read(_byokFormProvider);
    final provider = formState.selectedProvider;
    if (provider == null || _keyController.text.isEmpty) return;

    ref.read(_byokFormProvider.notifier).setSaving(true);

    try {
      final repository = ref.read(AppProviders.byokRepositoryProvider);
      await repository.saveConfig(
        ByokEditDraft(
          providerName: provider,
          selectedModel: formState.selectedModel,
          apiKey: _keyController.text,
          makeActive: true,
        ),
      );
      widget.onUpdateDraft(widget.draft.copyWith(byokSkipped: false));
      ref.read(_byokFormProvider.notifier).markSaved();
    } catch (_) {
      ref.read(_byokFormProvider.notifier).setSaving(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(_byokOptionsProvider);
    final formState = ref.watch(_byokFormProvider);

    return optionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Column(
        children: [
          _infoPanel(context),
          AppWhiteSpace.hLg,
          Text(
            AppErrorStrings.byokLoadFailedMessage,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      data: (options) => _buildForm(context, options, formState),
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<ByokProviderOption> options,
    _ByokFormState formState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoPanel(context),
        AppWhiteSpace.hLg,

        // Provider selector
        if (!formState.hasSaved) ...[
          Text(
            AppStrings.provider,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          AppWhiteSpace.hSm,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: options.map((option) {
              final isSelected =
                  formState.selectedProvider == option.providerName;
              return ChoiceChip(
                label: Text(option.displayName),
                selected: isSelected,
                onSelected: (_) {
                  ref
                      .read(_byokFormProvider.notifier)
                      .selectProvider(option.providerName, options);
                },
              );
            }).toList(),
          ),
          AppWhiteSpace.hMd,

          // Model selector
          if (formState.selectedProvider != null) ...[
            Text(
              AppStrings.model,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            AppWhiteSpace.hSm,
            _OnboardingModelSelector(
              options: options,
              providerName: formState.selectedProvider!,
              selectedModelId: formState.selectedModel,
              onChanged: (value) {
                ref.read(_byokFormProvider.notifier).selectModel(value);
              },
            ),
            AppWhiteSpace.hMd,
          ],

          // API key input
          Text(
            AppStrings.apiKey,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          AppWhiteSpace.hSm,
          ValueListenableBuilder<bool>(
            valueListenable: _obscured,
            builder: (context, obscured, child) {
              return TextFormField(
                controller: _keyController,
                obscureText: obscured,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  hintText: AppStrings.apiKeyHint,
                  suffixIcon: IconButton(
                    icon: SvgPicture.asset(
                      obscured
                          ? OutlinedSvgAssets.eye
                          : OutlinedSvgAssets.eyeSlash,
                      width: AppSizing.iconSm,
                      height: AppSizing.iconSm,
                    ),
                    onPressed: () => _obscured.value = !obscured,
                  ),
                ),
              );
            },
          ),
          AppWhiteSpace.hMd,

          // Save key button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  formState.selectedProvider != null &&
                      _keyController.text.isNotEmpty
                  ? _saveKey
                  : null,
              child: formState.isSaving
                  ? const SizedBox(
                      width: AppSizing.iconSm,
                      height: AppSizing.iconSm,
                      child: CircularProgressIndicator(
                        strokeWidth: AppSizing.strokeWidth,
                      ),
                    )
                  : const Text(AppStrings.saveKey),
            ),
          ),
          AppWhiteSpace.hLg,
        ],

        // Saved confirmation
        if (formState.hasSaved)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.checkCircle,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.onPrimaryContainer,
                    BlendMode.srcIn,
                  ),
                ),
                AppWhiteSpace.wSm,
                Expanded(
                  child: Text(
                    AppStrings.byokOnboardingSaved,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Benefit cards
        if (!formState.hasSaved) ...[
          AppWhiteSpace.hLg,
          _BenefitCard(
            iconAsset: OutlinedSvgAssets.lockClosed,
            title: AppStrings.onboardingByokBenefitPrivate,
            description: AppStrings.onboardingByokBenefitPrivateDescription,
          ),
          AppWhiteSpace.hMd,
          _BenefitCard(
            iconAsset: OutlinedSvgAssets.sparkles,
            title: AppStrings.onboardingByokBenefitOptional,
            description: AppStrings.onboardingByokBenefitOptionalDescription,
          ),
          AppWhiteSpace.hMd,
          _BenefitCard(
            iconAsset: OutlinedSvgAssets.key,
            title: AppStrings.onboardingByokBenefitBringYourOwnKey,
            description:
                AppStrings.onboardingByokBenefitBringYourOwnKeyDescription,
          ),
        ],
      ],
    );
  }

  Widget _infoPanel(BuildContext context) {
    return _SurfacePanel(
      backgroundColor: context.colorScheme.surfaceContainerLow,
      borderColor: context.theme.brightness == Brightness.light
          ? AedifyLightColors.secondaryBorder
          : AedifyDarkColors.secondaryBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            iconAsset: OutlinedSvgAssets.cpuChip,
            title: AppStrings.onboardingByokOptionalTitle,
          ),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.onboardingByokDescription,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingModelSelector extends StatelessWidget {
  const _OnboardingModelSelector({
    required this.options,
    required this.providerName,
    required this.selectedModelId,
    required this.onChanged,
  });

  final List<ByokProviderOption> options;
  final String providerName;
  final String? selectedModelId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final option = options.firstWhere((o) => o.providerName == providerName);
    return DropdownButtonFormField<String>(
      initialValue: selectedModelId,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      items: option.models.map<DropdownMenuItem<String>>((model) {
        return DropdownMenuItem(
          value: model.id,
          child: Text(model.displayName),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.draft, required this.onJumpToStep});

  final OnboardingDraft draft;
  final void Function(OnboardingStep) onJumpToStep;

  @override
  Widget build(BuildContext context) {
    final preferredUnit = draft.preferredUnits ?? PreferredUnit.metric;
    return Column(
      children: [
        _ReviewSectionCard(
          title: AppStrings.onboardingReviewProfileTitle,
          iconAsset: OutlinedSvgAssets.chartBar,
          children: [
            _ReviewRow(
              label: AppStrings.onboardingExperienceHint,
              value:
                  draft.experienceLevel ??
                  AppStrings.onboardingReviewEmptyValue,
              onTap: () => onJumpToStep(OnboardingStep.experienceGoals),
            ),
            _ReviewRow(
              label: AppStrings.onboardingGoalsHint,
              value: draft.goals.isEmpty
                  ? AppStrings.onboardingReviewEmptyValue
                  : draft.goals.join(', '),
              onTap: () => onJumpToStep(OnboardingStep.experienceGoals),
            ),
          ],
        ),
        AppWhiteSpace.hLg,
        _ReviewSectionCard(
          title: AppStrings.onboardingReviewPlanTitle,
          iconAsset: OutlinedSvgAssets.calendar,
          children: [
            _ReviewRow(
              label: AppStrings.onboardingScheduleHint,
              value: draft.trainingDaysPerWeek != null
                  ? '${draft.trainingDaysPerWeek} ${AppStrings.onboardingReviewDaysPerWeek}'
                  : AppStrings.onboardingReviewEmptyValue,
              onTap: () => onJumpToStep(OnboardingStep.schedule),
            ),
            _ReviewRow(
              label: AppStrings.onboardingEquipmentHint,
              value: draft.equipmentAccess.isEmpty
                  ? AppStrings.onboardingReviewEmptyValue
                  : draft.equipmentAccess.join(', '),
              onTap: () => onJumpToStep(OnboardingStep.equipment),
            ),
            _ReviewRow(
              label: AppStrings.onboardingUnitsHint,
              value:
                  draft.preferredUnits?.displayLabel ?? AppStrings.metricUnits,
              onTap: () => onJumpToStep(OnboardingStep.unitsMetrics),
            ),
            if (draft.heightCm != null)
              _ReviewRow(
                label: preferredUnit.heightLabel,
                value: preferredUnit.isImperial
                    ? '${preferredUnit.toImperialHeight(draft.heightCm!).toStringAsFixed(1)} ${AppStrings.imperialHeightUnit}'
                    : '${draft.heightCm!.toStringAsFixed(1)} ${AppStrings.metricHeightUnit}',
                onTap: () => onJumpToStep(OnboardingStep.unitsMetrics),
              ),
            if (draft.bodyweightKg != null)
              _ReviewRow(
                label: preferredUnit.weightLabel,
                value: preferredUnit.isImperial
                    ? '${preferredUnit.toImperialWeight(draft.bodyweightKg!).toStringAsFixed(1)} ${AppStrings.imperialWeightUnit}'
                    : '${draft.bodyweightKg!.toStringAsFixed(1)} ${AppStrings.metricWeightUnit}',
                onTap: () => onJumpToStep(OnboardingStep.unitsMetrics),
              ),
          ],
        ),
        AppWhiteSpace.hLg,
        _ReviewSectionCard(
          title: AppStrings.onboardingReviewRecoveryTitle,
          iconAsset: OutlinedSvgAssets.shieldCheck,
          children: [
            _ReviewRow(
              label: AppStrings.onboardingLimitationsHint,
              value: draft.limitations.isEmpty
                  ? AppStrings.onboardingReviewEmptyValue
                  : draft.limitations.join(', '),
              onTap: () => onJumpToStep(OnboardingStep.limitations),
            ),
            if (draft.notes != null && draft.notes!.isNotEmpty)
              _ReviewRow(
                label: AppStrings.onboardingNotesHint,
                value: draft.notes!,
                onTap: () => onJumpToStep(OnboardingStep.limitations),
              ),
          ],
        ),
        AppWhiteSpace.hLg,
        _ReviewSectionCard(
          title: AppStrings.onboardingReviewAiTitle,
          iconAsset: OutlinedSvgAssets.cpuChip,
          children: [
            _ReviewRow(
              label: AppStrings.onboardingByokOptionalTitle,
              value: draft.byokSkipped
                  ? AppStrings.skipForNow
                  : AppStrings.onboardingReviewConfigured,
              onTap: () => onJumpToStep(OnboardingStep.byokOptional),
            ),
          ],
        ),
      ],
    );
  }
}

class _SurfacePanel extends StatelessWidget {
  const _SurfacePanel({
    required this.child,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: borderColor ?? context.colorScheme.outlineVariant,
          width: AppSizing.divider,
        ),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        if (description != null) ...[
          AppWhiteSpace.hXs,
          Text(
            description!,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelMd.copyWith(
        color: context.colorScheme.onSurface,
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.iconAsset, required this.title});

  final String iconAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBadge(iconAsset: iconAsset, accent: context.colorScheme.secondary),
        AppWhiteSpace.wMd,
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.headlineMd.copyWith(
              fontSize: AppFontSizes.xxl,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({required this.iconAsset, required this.message});

  final String iconAsset;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconAsset,
          width: AppSizing.iconMd,
          height: AppSizing.iconMd,
          colorFilter: ColorFilter.mode(
            context.colorScheme.secondary,
            BlendMode.srcIn,
          ),
        ),
        AppWhiteSpace.wSm,
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorScheme.secondary;
    final selectedBackground = context.colorScheme.secondaryContainer;
    final selectedForeground = context.colorScheme.onSecondaryContainer;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppSizing.optionCardMinHeight,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? selectedBackground
              : context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? accent : context.colorScheme.outlineVariant,
            width: AppSizing.divider,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(
              iconAsset: iconAsset,
              accent: selected
                  ? selectedForeground.withValues(alpha: 0.16)
                  : context.colorScheme.surfaceContainerLow,
              iconColor: selected ? selectedForeground : accent,
            ),
            AppWhiteSpace.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMd.copyWith(
                      color: selected
                          ? selectedForeground
                          : context.colorScheme.onSurface,
                    ),
                  ),
                  AppWhiteSpace.hXs,
                  Text(
                    description,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: selected
                          ? selectedForeground.withValues(alpha: 0.88)
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            SvgPicture.asset(
              selected
                  ? OutlinedSvgAssets.checkCircle
                  : OutlinedSvgAssets.chevronRight,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                selected ? selectedForeground : context.colorScheme.outline,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.value,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String value;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AppSizing.metricTileMinWidth,
          minHeight: AppSizing.metricTileHeight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.secondaryContainer
              : context.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected
                ? context.colorScheme.secondary
                : context.colorScheme.outlineVariant,
            width: AppSizing.divider,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: AppTextStyles.headlineMd.copyWith(
                color: selected
                    ? context.colorScheme.onSecondaryContainer
                    : context.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: selected
                    ? context.colorScheme.onSecondaryContainer
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentGroupCard extends StatelessWidget {
  const _EquipmentGroupCard({
    required this.title,
    required this.description,
    required this.items,
    required this.selectedItems,
    required this.onToggle,
  });

  final String title;
  final String description;
  final List<String> items;
  final List<String> selectedItems;
  final void Function(String item, bool isSelected) onToggle;

  @override
  Widget build(BuildContext context) {
    return _SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title, description: description),
          AppWhiteSpace.hMd,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: items.map((item) {
              final selected = selectedItems.contains(item);
              return FilterChip(
                label: Text(item),
                selected: selected,
                onSelected: (isSelected) => onToggle(item, isSelected),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.iconAsset,
    required this.title,
    required this.description,
  });

  final String iconAsset;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return _SurfacePanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(
            iconAsset: iconAsset,
            accent: context.colorScheme.primaryFixed,
          ),
          AppWhiteSpace.wMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMd),
                AppWhiteSpace.hXs,
                Text(
                  description,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.iconAsset,
    required this.accent,
    this.iconColor,
  });

  final String iconAsset;
  final Color accent;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizing.cardBadge,
      height: AppSizing.cardBadge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      // alignment: Alignment.center,
      child: SvgPicture.asset(
        iconAsset,
        width: AppSizing.iconMd,
        height: AppSizing.iconMd,
        colorFilter: ColorFilter.mode(
          iconColor ?? context.colorScheme.secondary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _ReviewSectionCard extends StatelessWidget {
  const _ReviewSectionCard({
    required this.title,
    required this.iconAsset,
    required this.children,
  });

  final String title;
  final String iconAsset;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(
                iconAsset: iconAsset,
                accent: context.colorScheme.primaryFixed,
              ),
              AppWhiteSpace.wMd,
              Expanded(child: Text(title, style: AppTextStyles.headlineMd)),
            ],
          ),
          AppWhiteSpace.hMd,
          ...children,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                AppWhiteSpace.hXs,
                Text(value, style: AppTextStyles.bodyMd),
              ],
            ),
          ),
          if (onTap != null) ...[
            AppWhiteSpace.wSm,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.onboardingReviewTapToEdit,
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
                AppWhiteSpace.wXs,
                SvgPicture.asset(
                  OutlinedSvgAssets.pencilSquare,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: row,
    );
  }
}
