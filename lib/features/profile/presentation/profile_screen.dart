import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/profile/application/profile_controller.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/shared/components/app_list_tile.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/sex.dart';
import 'package:aedify/shared/formatters/measurement_formatter.dart';
import 'package:aedify/shared/formatters/measurement_parser.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(AppProviders.profileControllerProvider);
    final saveState = profileAsync.asData?.value;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          AppStrings.profileEdit,
          style: AppTextStyles.headlineLgMobile.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _ErrorView(
          message: AppErrorStrings.profileLoadFailedMessage,
          onRetry: () => ref
              .read(AppProviders.profileControllerProvider.notifier)
              .reload(),
        ),
        data: (state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.hasError) {
            return _ErrorView(
              message:
                  state.errorMessage ??
                  AppErrorStrings.profileLoadFailedMessage,
              onRetry: () => ref
                  .read(AppProviders.profileControllerProvider.notifier)
                  .reload(),
            );
          }
          return _ProfileContentView(state: state);
        },
      ),
      bottomNavigationBar:
          saveState == null || saveState.isLoading || saveState.hasError
          ? null
          : _ProfileSaveBar(state: saveState),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSpacing.xxl,
              height: AppSpacing.xxl,
              colorFilter: ColorFilter.mode(
                context.colorScheme.error,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.hMd,
            Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hLg,
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContentView extends ConsumerWidget {
  const _ProfileContentView({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      AppProviders.profileControllerProvider.notifier,
    );
    final draft = state.draft ?? const ProfileEditDraft();
    final impact = state.impact;

    return SafeArea(
      top: false,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(
              left: AppSpacing.marginMobile,
              top: AppSpacing.lg,
              right: AppSpacing.marginMobile,
              bottom: AppSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (state.validationMessage != null)
                  _ValidationBanner(message: state.validationMessage!),
                if (state.errorMessage != null &&
                    state.validationMessage == null)
                  _ValidationBanner(
                    message: state.errorMessage!,
                    isError: true,
                  ),
                if (impact == ProfileSaveImpact.mayAffectActiveProgrammes)
                  const _ImpactWarning(
                    message: AppStrings.profileUpdateMayAffectPrograms,
                  ),
                _IdentityUnitsSection(draft: draft, controller: controller),
                AppWhiteSpace.hLg,
                _TrainingProfileSection(draft: draft, controller: controller),
                AppWhiteSpace.hLg,
                _ScheduleSection(draft: draft, controller: controller),
                AppWhiteSpace.hLg,
                _EquipmentSection(draft: draft, controller: controller),
                AppWhiteSpace.hLg,
                _LimitationsSection(
                  draft: draft,
                  controller: controller,
                  ref: ref,
                ),
                AppWhiteSpace.hLg,
                _MeasurementsSection(draft: draft, controller: controller),
                AppWhiteSpace.hXl,
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityUnitsSection extends StatelessWidget {
  const _IdentityUnitsSection({required this.draft, required this.controller});

  final ProfileEditDraft draft;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: AppStrings.onboardingPersonalDetailsTitle,
      description: AppStrings.localOnlyNotice,
      iconAsset: OutlinedSvgAssets.identification,
      tonal: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: AppStrings.displayName,
            initialValue: draft.displayName ?? '',
            hintText: AppStrings.displayName,
            onTonalSurface: true,
            onChanged: (value) {
              controller.updateDraft(
                draft.copyWith(displayName: value.isEmpty ? null : value),
              );
            },
          ),
          AppWhiteSpace.hLg,
          const _SubsectionLabel(title: AppStrings.sex),
          AppWhiteSpace.hSm,
          _PillSelector(
            options: const [
              AppStrings.sexMale,
              AppStrings.sexFemale,
              AppStrings.sexNotSpecified,
            ],
            selected: _ProfileTaxonomy.sexLabel(draft.sex),
            onTonalSurface: true,
            onSelected: (value) {
              controller.updateDraft(
                draft.copyWith(sex: _ProfileTaxonomy.sexFromLabel(value)),
              );
            },
          ),
          AppWhiteSpace.hLg,
          AppListTile(
            title: AppStrings.dateOfBirth,
            subtitle: draft.dateOfBirth != null
                ? DateFormat('MMM d, yyyy').format(draft.dateOfBirth!)
                : AppStrings.selectDate,
            leadingAsset: OutlinedSvgAssets.calendarDays,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: draft.dateOfBirth ?? DateTime(1990),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                controller.updateDraft(draft.copyWith(dateOfBirth: picked));
              }
            },
          ),
          AppWhiteSpace.hLg,
          const _SubsectionLabel(title: AppStrings.preferredUnits),
          AppWhiteSpace.hSm,
          _UnitSelector(
            selected: draft.preferredUnits,
            onTonalSurface: true,
            onSelected: (value) {
              controller.updateDraft(draft.copyWith(preferredUnits: value));
            },
          ),
        ],
      ),
    );
  }
}

class _TrainingProfileSection extends StatelessWidget {
  const _TrainingProfileSection({
    required this.draft,
    required this.controller,
  });

  final ProfileEditDraft draft;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: AppStrings.onboardingReviewProfileTitle,
      description: AppStrings.onboardingExperienceDescription,
      iconAsset: OutlinedSvgAssets.academicCap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SubsectionLabel(title: AppStrings.experienceLevel),
          AppWhiteSpace.hSm,
          _PillSelector(
            options: const [
              AppStrings.onboardingExperienceBeginner,
              AppStrings.onboardingExperienceIntermediate,
              AppStrings.onboardingExperienceAdvanced,
            ],
            selected: _ProfileTaxonomy.experienceLabel(draft.experienceLevel),
            onSelected: (value) {
              controller.updateDraft(
                draft.copyWith(
                  experienceLevel: _ProfileTaxonomy.experienceFromLabel(value),
                ),
              );
            },
          ),
          AppWhiteSpace.hLg,
          const _SubsectionLabel(title: AppStrings.goals),
          AppWhiteSpace.hSm,
          _PillSelector(
            options: const [
              AppStrings.onboardingGoalBuildMuscle,
              AppStrings.onboardingGoalLoseWeight,
              AppStrings.onboardingGoalIncreaseStrength,
              AppStrings.onboardingGoalImproveEndurance,
              AppStrings.onboardingGoalGeneralFitness,
              AppStrings.onboardingGoalFlexibility,
            ],
            selectedSet: draft.goals.map(_ProfileTaxonomy.goalLabel).toSet(),
            onSelectedSet: (value) {
              final goal = _ProfileTaxonomy.goalFromLabel(value);
              final updated = draft.goals.contains(goal)
                  ? (Set<GoalTag>.from(draft.goals)..remove(goal))
                  : {...draft.goals, goal};
              controller.updateDraft(draft.copyWith(goals: updated));
            },
          ),
        ],
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.draft, required this.controller});

  final ProfileEditDraft draft;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: AppStrings.onboardingScheduleTitle,
      description: AppStrings.onboardingScheduleDescription,
      iconAsset: OutlinedSvgAssets.calendarDays,
      tonal: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SubsectionLabel(title: AppStrings.trainingDays),
          AppWhiteSpace.hSm,
          _DaysPerWeekSelector(
            selected: draft.trainingDaysPerWeek,
            onTonalSurface: true,
            onSelected: (value) {
              controller.updateDraft(
                draft.copyWith(trainingDaysPerWeek: value),
              );
            },
          ),
          AppWhiteSpace.hLg,
          _FormField(
            label: AppStrings.sessionLength,
            initialValue: draft.targetSessionLengthMinutes?.toString() ?? '',
            hintText: AppStrings.onboardingHintSessionMin,
            suffixText: AppStrings.onboardingReviewMinutes,
            keyboardType: TextInputType.number,
            onTonalSurface: true,
            onChanged: (value) {
              final parsed = int.tryParse(value);
              controller.updateDraft(
                draft.copyWith(targetSessionLengthMinutes: parsed),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EquipmentSection extends StatelessWidget {
  const _EquipmentSection({required this.draft, required this.controller});

  final ProfileEditDraft draft;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: AppStrings.onboardingEquipmentTitle,
      description: AppStrings.onboardingEquipmentDescription,
      iconAsset: OutlinedSvgAssets.wrenchScrewdriver,
      child: _PillSelector(
        options: const [
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
          AppStrings.onboardingEquipmentBosuBall,
          AppStrings.onboardingEquipmentMedicineBall,
          AppStrings.onboardingEquipmentPlate,
          AppStrings.onboardingEquipmentTrx,
          AppStrings.onboardingEquipmentVitruvian,
        ],
        selectedSet: draft.equipmentAccess
            .map(_ProfileTaxonomy.equipmentLabel)
            .toSet(),
        onSelectedSet: (value) {
          final equipment = _ProfileTaxonomy.equipmentFromLabel(value);
          final updated = draft.equipmentAccess.contains(equipment)
              ? (Set<EquipmentTag>.from(draft.equipmentAccess)
                  ..remove(equipment))
              : {...draft.equipmentAccess, equipment};
          controller.updateDraft(draft.copyWith(equipmentAccess: updated));
        },
      ),
    );
  }
}

class _LimitationsSection extends StatelessWidget {
  const _LimitationsSection({
    required this.draft,
    required this.controller,
    required this.ref,
  });

  final ProfileEditDraft draft;
  final ProfileController controller;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: AppStrings.onboardingLimitationsTitle,
      description: AppStrings.onboardingLimitationsDescription,
      iconAsset: OutlinedSvgAssets.shieldCheck,
      tonal: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SubsectionLabel(title: AppStrings.injuriesAndLimitations),
          AppWhiteSpace.hSm,
          _PillSelector(
            options: const [
              AppStrings.onboardingLimitationNone,
              AppStrings.onboardingLimitationLowerBack,
              AppStrings.onboardingLimitationKnee,
              AppStrings.onboardingLimitationShoulder,
              AppStrings.onboardingLimitationWrist,
              AppStrings.onboardingLimitationHip,
              AppStrings.onboardingLimitationNeck,
              AppStrings.onboardingLimitationElbow,
              AppStrings.onboardingLimitationAnkle,
            ],
            selectedSet: draft.injuriesLimitations.toSet(),
            onTonalSurface: true,
            onSelectedSet: (value) {
              final updated = draft.injuriesLimitations.contains(value)
                  ? draft.injuriesLimitations
                        .where((item) => item != value)
                        .toList()
                  : [...draft.injuriesLimitations, value];
              controller.updateDraft(
                draft.copyWith(injuriesLimitations: updated),
              );
            },
          ),
          AppWhiteSpace.hLg,
          _ExerciseSelector(
            title: AppStrings.substitutions,
            selectedIds: draft.substitutedExerciseIds,
            hintText: AppStrings.selectSubstitutions,
            iconAsset: OutlinedSvgAssets.arrowsRightLeft,
            onTap: () => _ProfileExerciseMultiSelect.show(
              context: context,
              ref: ref,
              draft: draft,
              controller: controller,
              mode: _ExerciseSelectMode.substitutions,
            ),
          ),
          AppWhiteSpace.hSm,
          _ExerciseSelector(
            title: AppStrings.favorites,
            selectedIds: draft.favoriteExerciseIds,
            hintText: AppStrings.selectFavorites,
            iconAsset: OutlinedSvgAssets.heart,
            onTap: () => _ProfileExerciseMultiSelect.show(
              context: context,
              ref: ref,
              draft: draft,
              controller: controller,
              mode: _ExerciseSelectMode.favorites,
            ),
          ),
          AppWhiteSpace.hLg,
          _FormField(
            label: AppStrings.notes,
            initialValue: draft.otherNotes ?? '',
            maxLines: 3,
            hintText: AppStrings.onboardingNotesHint,
            onTonalSurface: true,
            onChanged: (value) {
              controller.updateDraft(
                draft.copyWith(otherNotes: value.isEmpty ? null : value),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MeasurementsSection extends StatelessWidget {
  const _MeasurementsSection({required this.draft, required this.controller});

  final ProfileEditDraft draft;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: AppStrings.onboardingBodyMetricsTitle,
      description: AppStrings.onboardingBodyMetricsDescription,
      iconAsset: OutlinedSvgAssets.scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: draft.preferredUnits.weightLabel,
            initialValue: MeasurementFormatter.formatWeight(
              weightKg: draft.bodyweightKg,
              preferredUnit: draft.preferredUnits,
            ),
            hintText: draft.preferredUnits.weightHint,
            suffixText: draft.preferredUnits.weightUnit,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: controller.updateBodyweightFromDisplay,
          ),
          AppWhiteSpace.hMd,
          _FormField(
            label: draft.preferredUnits.heightLabel,
            initialValue: MeasurementFormatter.formatHeight(
              heightCm: draft.heightCm,
              preferredUnit: draft.preferredUnits,
            ),
            hintText: draft.preferredUnits.heightHint,
            suffixText: draft.preferredUnits.heightUnit,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: controller.updateHeightFromDisplay,
          ),
          AppWhiteSpace.hLg,
          const _SubsectionLabel(title: AppStrings.onboardingMaxLiftsTitle),
          AppWhiteSpace.hSm,
          _FormField(
            label: AppStrings.bench1Rm,
            initialValue: MeasurementFormatter.formatWeight(
              weightKg: draft.bench1RmKg,
              preferredUnit: draft.preferredUnits,
            ),
            suffixText: draft.preferredUnits.weightUnit,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final parsed = MeasurementParser.parseWeightToCanonicalKg(
                rawValue: value,
                preferredUnit: draft.preferredUnits,
              );
              controller.updateDraft(draft.copyWith(bench1RmKg: parsed));
            },
          ),
          AppWhiteSpace.hMd,
          _FormField(
            label: AppStrings.squat1Rm,
            initialValue: MeasurementFormatter.formatWeight(
              weightKg: draft.squat1RmKg,
              preferredUnit: draft.preferredUnits,
            ),
            suffixText: draft.preferredUnits.weightUnit,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final parsed = MeasurementParser.parseWeightToCanonicalKg(
                rawValue: value,
                preferredUnit: draft.preferredUnits,
              );
              controller.updateDraft(draft.copyWith(squat1RmKg: parsed));
            },
          ),
          AppWhiteSpace.hMd,
          _FormField(
            label: AppStrings.deadlift1Rm,
            initialValue: MeasurementFormatter.formatWeight(
              weightKg: draft.deadlift1RmKg,
              preferredUnit: draft.preferredUnits,
            ),
            suffixText: draft.preferredUnits.weightUnit,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final parsed = MeasurementParser.parseWeightToCanonicalKg(
                rawValue: value,
                preferredUnit: draft.preferredUnits,
              );
              controller.updateDraft(draft.copyWith(deadlift1RmKg: parsed));
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileSaveBar extends ConsumerWidget {
  const _ProfileSaveBar({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      AppProviders.profileControllerProvider.notifier,
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLowest,
          border: Border(
            top: BorderSide(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: AppSizing.divider,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
              vertical: AppSpacing.sm,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSpacing.xxl),
                  textStyle: AppTextStyles.labelMd,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                onPressed: state.isSaving
                    ? null
                    : () {
                        controller.evaluateImpact();
                        controller.save();
                      },
                child: state.isSaving
                    ? const SizedBox(
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: AppSizing.strokeWidth,
                        ),
                      )
                    : const Text(AppStrings.save),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTaxonomy {
  _ProfileTaxonomy._();

  static String? experienceLabel(ExperienceLevel? value) {
    return switch (value) {
      ExperienceLevel.beginner => AppStrings.onboardingExperienceBeginner,
      ExperienceLevel.intermediate =>
        AppStrings.onboardingExperienceIntermediate,
      ExperienceLevel.advanced => AppStrings.onboardingExperienceAdvanced,
      ExperienceLevel.novice => AppStrings.onboardingExperienceBeginner,
      null => null,
    };
  }

  static ExperienceLevel experienceFromLabel(String value) {
    return switch (value) {
      AppStrings.onboardingExperienceBeginner => ExperienceLevel.beginner,
      AppStrings.onboardingExperienceIntermediate =>
        ExperienceLevel.intermediate,
      AppStrings.onboardingExperienceAdvanced => ExperienceLevel.advanced,
      _ => ExperienceLevel.beginner,
    };
  }

  static String? sexLabel(Sex? value) {
    return switch (value) {
      Sex.male => AppStrings.sexMale,
      Sex.female => AppStrings.sexFemale,
      Sex.notSpecified => AppStrings.sexNotSpecified,
      null => null,
    };
  }

  static Sex sexFromLabel(String value) {
    return switch (value) {
      AppStrings.sexMale => Sex.male,
      AppStrings.sexFemale => Sex.female,
      _ => Sex.notSpecified,
    };
  }

  static String goalLabel(GoalTag value) {
    return switch (value) {
      GoalTag.buildMuscle => AppStrings.onboardingGoalBuildMuscle,
      GoalTag.loseWeight => AppStrings.onboardingGoalLoseWeight,
      GoalTag.increaseStrength => AppStrings.onboardingGoalIncreaseStrength,
      GoalTag.improveEndurance => AppStrings.onboardingGoalImproveEndurance,
      GoalTag.generalFitness => AppStrings.onboardingGoalGeneralFitness,
      GoalTag.flexibility => AppStrings.onboardingGoalFlexibility,
    };
  }

  static GoalTag goalFromLabel(String value) {
    return switch (value) {
      AppStrings.onboardingGoalBuildMuscle => GoalTag.buildMuscle,
      AppStrings.onboardingGoalLoseWeight => GoalTag.loseWeight,
      AppStrings.onboardingGoalIncreaseStrength => GoalTag.increaseStrength,
      AppStrings.onboardingGoalImproveEndurance => GoalTag.improveEndurance,
      AppStrings.onboardingGoalGeneralFitness => GoalTag.generalFitness,
      _ => GoalTag.flexibility,
    };
  }

  static String equipmentLabel(EquipmentTag value) {
    return switch (value) {
      EquipmentTag.bodyweight => AppStrings.onboardingEquipmentNone,
      EquipmentTag.dumbbell => AppStrings.onboardingEquipmentDumbbells,
      EquipmentTag.barbell => AppStrings.onboardingEquipmentBarbell,
      EquipmentTag.kettlebell => AppStrings.onboardingEquipmentKettlebell,
      EquipmentTag.bands => AppStrings.onboardingEquipmentResistanceBands,
      EquipmentTag.cable => AppStrings.onboardingEquipmentCableMachine,
      EquipmentTag.smithMachine => AppStrings.onboardingEquipmentSmithMachine,
      EquipmentTag.pullUpBar => AppStrings.onboardingEquipmentPullUpBar,
      EquipmentTag.bench => AppStrings.onboardingEquipmentBench,
      EquipmentTag.squatRack => AppStrings.onboardingEquipmentSquatRack,
      EquipmentTag.cardioMachine => AppStrings.onboardingEquipmentCardioMachine,
      EquipmentTag.machine => AppStrings.onboardingEquipmentMachine,
      EquipmentTag.ezBar => AppStrings.onboardingEquipmentEzBar,
      EquipmentTag.bosuBall => AppStrings.onboardingEquipmentBosuBall,
      EquipmentTag.medicineBall => AppStrings.onboardingEquipmentMedicineBall,
      EquipmentTag.plate => AppStrings.onboardingEquipmentPlate,
      EquipmentTag.trx => AppStrings.onboardingEquipmentTrx,
      EquipmentTag.vitruvian => AppStrings.onboardingEquipmentVitruvian,
      EquipmentTag.other => AppStrings.onboardingEquipmentOther,
    };
  }

  static EquipmentTag equipmentFromLabel(String value) {
    return switch (value) {
      AppStrings.onboardingEquipmentNone => EquipmentTag.bodyweight,
      AppStrings.onboardingEquipmentDumbbells => EquipmentTag.dumbbell,
      AppStrings.onboardingEquipmentBarbell => EquipmentTag.barbell,
      AppStrings.onboardingEquipmentKettlebell => EquipmentTag.kettlebell,
      AppStrings.onboardingEquipmentResistanceBands => EquipmentTag.bands,
      AppStrings.onboardingEquipmentCableMachine => EquipmentTag.cable,
      AppStrings.onboardingEquipmentSmithMachine => EquipmentTag.smithMachine,
      AppStrings.onboardingEquipmentPullUpBar => EquipmentTag.pullUpBar,
      AppStrings.onboardingEquipmentBench => EquipmentTag.bench,
      AppStrings.onboardingEquipmentSquatRack => EquipmentTag.squatRack,
      AppStrings.onboardingEquipmentCardioMachine => EquipmentTag.cardioMachine,
      AppStrings.onboardingEquipmentMachine => EquipmentTag.machine,
      AppStrings.onboardingEquipmentEzBar => EquipmentTag.ezBar,
      AppStrings.onboardingEquipmentBosuBall => EquipmentTag.bosuBall,
      AppStrings.onboardingEquipmentMedicineBall => EquipmentTag.medicineBall,
      AppStrings.onboardingEquipmentPlate => EquipmentTag.plate,
      AppStrings.onboardingEquipmentTrx => EquipmentTag.trx,
      AppStrings.onboardingEquipmentVitruvian => EquipmentTag.vitruvian,
      _ => EquipmentTag.other,
    };
  }
}

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isError
              ? context.colorScheme.errorContainer
              : context.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              isError
                  ? OutlinedSvgAssets.exclamationCircle
                  : OutlinedSvgAssets.informationCircle,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                isError
                    ? context.colorScheme.onErrorContainer
                    : context.colorScheme.onSecondaryContainer,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMd.copyWith(
                  color: isError
                      ? context.colorScheme.onErrorContainer
                      : context.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactWarning extends StatelessWidget {
  const _ImpactWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationTriangle,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onTertiaryContainer,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.child,
    this.tonal = false,
  });

  final String title;
  final String description;
  final String iconAsset;
  final Widget child;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final accent = colorScheme.brightness == Brightness.dark
        ? colorScheme.primary
        : colorScheme.secondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tonal
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.xl + AppSpacing.sm,
                height: AppSpacing.xl + AppSpacing.sm,
                decoration: BoxDecoration(
                  color: tonal
                      ? colorScheme.surfaceContainerLowest
                      : colorScheme.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconAsset,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                  ),
                ),
              ),
              AppWhiteSpace.wMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headlineLgMobile.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    AppWhiteSpace.hXs,
                    Text(
                      description,
                      style: AppTextStyles.bodySm.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          child,
        ],
      ),
    );
  }
}

class _SubsectionLabel extends StatelessWidget {
  const _SubsectionLabel({required this.title});

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

class _PillSelector extends StatelessWidget {
  const _PillSelector({
    required this.options,
    this.selected,
    this.selectedSet,
    this.onSelected,
    this.onSelectedSet,
    this.onTonalSurface = false,
  });

  final List<String> options;
  final String? selected;
  final Set<String>? selectedSet;
  final void Function(String)? onSelected;
  final void Function(String)? onSelectedSet;
  final bool onTonalSurface;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final isSelected = selectedSet != null
            ? selectedSet!.contains(option)
            : selected == option;
        return _SelectionPill(
          label: option,
          selected: isSelected,
          onTonalSurface: onTonalSurface,
          onTap: () {
            if (onSelected != null) {
              onSelected!(option);
            } else if (onSelectedSet != null) {
              onSelectedSet!(option);
            }
          },
        );
      }).toList(),
    );
  }
}

class _SelectionPill extends StatelessWidget {
  const _SelectionPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.onTonalSurface = false,
  });

  static const _animationDuration = Duration(milliseconds: 200);

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool onTonalSurface;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final activeBackground = isDark
        ? colorScheme.primaryContainer
        : colorScheme.secondary;
    final activeForeground = isDark
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSecondary;
    final inactiveBackground = onTonalSurface
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surfaceContainerLow;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeInOutCubic,
        constraints: const BoxConstraints(minHeight: AppSizing.cardBadge),
        decoration: BoxDecoration(
          color: selected ? activeBackground : inactiveBackground,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selected) ...[
                    SvgPicture.asset(
                      OutlinedSvgAssets.check,
                      width: AppSizing.iconXxs,
                      height: AppSizing.iconXxs,
                      colorFilter: ColorFilter.mode(
                        activeForeground,
                        BlendMode.srcIn,
                      ),
                    ),
                    AppWhiteSpace.wXs,
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.labelMd.copyWith(
                        color: selected
                            ? activeForeground
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DaysPerWeekSelector extends StatelessWidget {
  const _DaysPerWeekSelector({
    required this.selected,
    required this.onSelected,
    this.onTonalSurface = false,
  });

  final int? selected;
  final void Function(int) onSelected;
  final bool onTonalSurface;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(7, (index) {
        final day = index + 1;
        final dayLabel = day == 1
            ? AppStrings.onboardingDaySingle
            : AppStrings.onboardingDayPlural;
        return _SelectionPill(
          label: '$day $dayLabel',
          selected: selected == day,
          onTonalSurface: onTonalSurface,
          onTap: () => onSelected(day),
        );
      }),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({
    required this.selected,
    required this.onSelected,
    this.onTonalSurface = false,
  });

  final PreferredUnit selected;
  final void Function(PreferredUnit) onSelected;
  final bool onTonalSurface;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: PreferredUnit.values.map((unit) {
        return _SelectionPill(
          label: unit.displayLabel,
          selected: selected == unit,
          onTonalSurface: onTonalSurface,
          onTap: () => onSelected(unit),
        );
      }).toList(),
    );
  }
}

class _FormField extends StatefulWidget {
  const _FormField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
    this.hintText,
    this.suffixText,
    this.maxLines,
    this.onTonalSurface = false,
  });

  final String label;
  final String initialValue;
  final void Function(String) onChanged;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? suffixText;
  final int? maxLines;
  final bool onTonalSurface;

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
  void didUpdateWidget(_FormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          AppWhiteSpace.hSm,
        ],
        AppTextField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          hintText: widget.hintText,
          suffixText: widget.suffixText,
          suffixStyle: AppTextStyles.labelMd.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          maxLines: widget.maxLines ?? 1,
          fillColor: widget.onTonalSurface
              ? context.colorScheme.surfaceContainerLowest
              : context.colorScheme.surfaceContainerLow,
          style: AppTextStyles.bodyMd.copyWith(
            color: context.colorScheme.onSurface,
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}

class _ExerciseSelector extends StatelessWidget {
  const _ExerciseSelector({
    required this.title,
    required this.selectedIds,
    required this.hintText,
    required this.iconAsset,
    required this.onTap,
  });

  final String title;
  final List<int> selectedIds;
  final String hintText;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: title,
      subtitle: selectedIds.isEmpty
          ? hintText
          : '${selectedIds.length} ${AppStrings.exercisesSelected}',
      leadingAsset: iconAsset,
      showChevron: true,
      onTap: onTap,
    );
  }
}

enum _ExerciseSelectMode { favorites, substitutions }

class _ProfileExerciseMultiSelect {
  _ProfileExerciseMultiSelect._();

  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required ProfileEditDraft draft,
    required ProfileController controller,
    required _ExerciseSelectMode mode,
  }) async {
    final exercises = await ref
        .read(AppProviders.exerciseDaoProvider)
        .getAllExercises();
    if (!context.mounted) return;

    final currentIds = switch (mode) {
      _ExerciseSelectMode.favorites => List<int>.from(
        draft.favoriteExerciseIds,
      ),
      _ExerciseSelectMode.substitutions => List<int>.from(
        draft.substitutedExerciseIds,
      ),
    };

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final tempIds = Set<int>.from(currentIds);
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              builder: (_, scrollController) {
                return SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      AppWhiteSpace.hSm,
                      Container(
                        width: AppSizing.handleWidth,
                        height: AppSizing.progressBarHeight,
                        decoration: BoxDecoration(
                          color: ctx.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          mode == _ExerciseSelectMode.favorites
                              ? AppStrings.selectFavorites
                              : AppStrings.selectSubstitutions,
                          style: AppTextStyles.headlineMd.copyWith(
                            color: ctx.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Divider(
                        height: AppSizing.divider,
                        thickness: AppSizing.divider,
                        color: ctx.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          controller: scrollController,
                          itemCount: exercises.length,
                          separatorBuilder: (_, _) => AppWhiteSpace.hSm,
                          itemBuilder: (_, index) {
                            final exercise = exercises[index];
                            final isSelected = tempIds.contains(exercise.id);
                            return Semantics(
                              button: true,
                              selected: isSelected,
                              child: AppListTile(
                                title: exercise.name,
                                trailing: _SelectionIndicator(
                                  selected: isSelected,
                                ),
                                onTap: () {
                                  setSheetState(() {
                                    if (isSelected) {
                                      tempIds.remove(exercise.id);
                                    } else {
                                      tempIds.add(exercise.id);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: ctx.colorScheme.surfaceContainerLowest,
                          border: Border(
                            top: BorderSide(
                              color: ctx.colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                              width: AppSizing.divider,
                            ),
                          ),
                        ),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(AppSpacing.xxl),
                            textStyle: AppTextStyles.labelMd,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                          ),
                          onPressed: () {
                            controller
                                .updateDraft(switch (mode) {
                                  _ExerciseSelectMode.favorites =>
                                    draft.copyWith(
                                      favoriteExerciseIds: tempIds.toList(),
                                    ),
                                  _ExerciseSelectMode.substitutions =>
                                    draft.copyWith(
                                      substitutedExerciseIds: tempIds.toList(),
                                    ),
                                })
                                .then((_) {
                                  if (ctx.mounted) ctx.pop();
                                });
                          },
                          child: const Text(AppStrings.done),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  static const _animationDuration = Duration(milliseconds: 200);

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final activeBackground = colorScheme.brightness == Brightness.dark
        ? colorScheme.primaryContainer
        : colorScheme.secondary;
    final activeForeground = colorScheme.brightness == Brightness.dark
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSecondary;

    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOutCubic,
      width: AppSizing.iconMd,
      height: AppSizing.iconMd,
      decoration: BoxDecoration(
        color: selected ? activeBackground : colorScheme.surfaceContainerLow,
        shape: BoxShape.circle,
        border: selected
            ? null
            : Border.all(
                color: colorScheme.outlineVariant,
                width: AppSizing.divider,
              ),
      ),
      child: selected
          ? Center(
              child: SvgPicture.asset(
                OutlinedSvgAssets.check,
                width: AppSizing.iconXxs,
                height: AppSizing.iconXxs,
                colorFilter: ColorFilter.mode(
                  activeForeground,
                  BlendMode.srcIn,
                ),
              ),
            )
          : null,
    );
  }
}
