import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_input_label.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_intro_header.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/sex.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

enum _IdentityChoice {
  male(
    sex: Sex.male,
    label: AppStrings.sexMale,
    icon: OutlinedSvgAssets.materialMale,
  ),
  female(
    sex: Sex.female,
    label: AppStrings.sexFemale,
    icon: OutlinedSvgAssets.materialFemale,
  ),
  other(
    sex: Sex.notSpecified,
    label: AppStrings.sexOther,
    icon: OutlinedSvgAssets.materialTransgender,
  );

  final Sex sex;
  final String icon;
  final String label;

  const _IdentityChoice({
    required this.sex,
    required this.icon,
    required this.label,
  });
}

enum _UnitChoice {
  metric(unit: PreferredUnit.metric, label: AppStrings.onboardingMetricChoice),
  imperial(
    unit: PreferredUnit.imperial,
    label: AppStrings.onboardingImperialChoice,
  );

  final String label;
  final PreferredUnit unit;

  const _UnitChoice({required this.unit, required this.label});
}

class OnboardingCoreIdentityStep extends StatelessWidget {
  const OnboardingCoreIdentityStep({
    super.key,
    required this.draft,
    required this.onUpdateDraft,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  @override
  Widget build(BuildContext context) {
    final preferredUnit = draft.preferredUnits ?? PreferredUnit.metric;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.secondary.withValues(alpha: 0.08),
            blurRadius: AppSpacing.lg,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: Column(
        children: [
          OnboardingIntroHeader(
            title: AppStrings.onboardingCoreIdentityTitle,
            description: AppStrings.onboardingCoreIdentityCardDescription,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingInputLabel(
                title: AppStrings.onboardingCoreIdentitySexLabel,
              ),
              AppWhiteSpace.hMd,
              Row(
                spacing: AppSpacing.sm,
                children: _IdentityChoice.values
                    .map(
                      (e) => Expanded(
                        child: _OnboardingIdentityChoiceCard(
                          label: e.label,
                          iconAsset: e.icon,
                          selected: draft.sex == e.sex,
                          onTap: () {
                            onUpdateDraft(draft.copyWith(sex: e.sex));
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
              AppWhiteSpace.hXl,
              const OnboardingInputLabel(
                title: AppStrings.onboardingMeasurementSystem,
              ),
              AppWhiteSpace.hMd,
              _OnboardingUnitChoiceSelector(
                preferredUnit: preferredUnit,
                onUnitChange: (unit) {
                  onUpdateDraft(draft.copyWith(preferredUnits: unit));
                },
              ),
              AppWhiteSpace.hXl,
              const OnboardingInputLabel(title: AppStrings.dateOfBirth),
              AppWhiteSpace.hMd,
              Semantics(
                button: true,
                label: AppStrings.selectDate,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm * 2),
                  ),
                  constraints: const BoxConstraints(
                    minHeight: AppSizing.iconXxl,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: draft.dateOfBirth ?? now,
                        firstDate: DateTime(1925),
                        lastDate: now,
                      );
                      if (picked != null) {
                        onUpdateDraft(draft.copyWith(dateOfBirth: picked));
                      }
                    },
                    borderRadius: BorderRadius.circular(AppRadius.sm * 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            draft.dateOfBirth != null
                                ? '${draft.dateOfBirth!.year}-'
                                      '${draft.dateOfBirth!.month.toString().padLeft(2, '0')}-'
                                      '${draft.dateOfBirth!.day.toString().padLeft(2, '0')}'
                                : AppStrings.dateOfBirth,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: draft.dateOfBirth != null
                                  ? context.colorScheme.onSurface
                                  : context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SvgPicture.asset(
                          OutlinedSvgAssets.materialCalendarToday,
                          width: AppSizing.iconSm,
                          height: AppSizing.iconSm,
                          colorFilter: ColorFilter.mode(
                            context.colorScheme.onSurfaceVariant,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppWhiteSpace.hSm,
              Text(
                AppStrings.onboardingDateOfBirthHelper,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingIdentityChoiceCard extends StatelessWidget {
  const _OnboardingIdentityChoiceCard({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final accent = isDark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final foreground = selected ? accent : context.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(
          minHeight: AppSizing.onboardingIdentityChoiceHeight,
        ),
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.surfaceContainerHigh
              : context.colorScheme.surfaceBright,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            width: selected ? AppSizing.strokeWidth : AppSizing.divider,
            color: selected
                ? accent
                : context.colorScheme.surfaceContainerLowest,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                ),
                AppWhiteSpace.hSm,
                Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMd.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingUnitChoiceSelector extends StatelessWidget {
  const _OnboardingUnitChoiceSelector({
    required this.preferredUnit,
    required this.onUnitChange,
  });

  static const _animationDuration = Duration(milliseconds: 200);
  static const double _indicatorWidthFactor = 0.5;

  final PreferredUnit preferredUnit;
  final ValueChanged<PreferredUnit> onUnitChange;

  @override
  Widget build(BuildContext context) {
    final selectedBackground = context.colorScheme.surfaceContainerLowest;
    final selectedForeground = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final metricSelected = preferredUnit == PreferredUnit.metric;

    return Container(
      key: const ValueKey<String>('onboarding_unit_selector'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedAlign(
                key: const ValueKey<String>(
                  'onboarding_unit_sliding_indicator',
                ),
                alignment: metricSelected
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                duration: _animationDuration,
                curve: Curves.easeOutCubic,
                child: FractionallySizedBox(
                  widthFactor: _indicatorWidthFactor,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: selectedBackground,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: [
                        BoxShadow(
                          color: context.colorScheme.onSurface.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: AppSpacing.sm,
                          offset: const Offset(0, AppSpacing.xxs),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: _UnitChoice.values
                .map(
                  (e) => Expanded(
                    child: _OnboardingUnitChoiceButton(
                      label: e.label,
                      selected: preferredUnit == e.unit,
                      onTap: () => onUnitChange(e.unit),
                      animationDuration: _animationDuration,
                      selectedForeground: selectedForeground,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _OnboardingUnitChoiceButton extends StatelessWidget {
  const _OnboardingUnitChoiceButton({
    required this.label,
    required this.selected,
    required this.selectedForeground,
    required this.animationDuration,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedForeground;
  final Duration animationDuration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: animationDuration,
              curve: Curves.easeOutCubic,
              style: AppTextStyles.labelMd.copyWith(
                color: selected
                    ? selectedForeground
                    : context.colorScheme.onSurfaceVariant,
              ),
              child: Text(label, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
