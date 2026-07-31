import 'dart:ui';

import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_baseline_lift_field.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_constraint_surface.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_intro_header.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_metric_ruler.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';

import 'package:flutter/material.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingUnitsMetricsStep extends StatelessWidget {
  const OnboardingUnitsMetricsStep({
    super.key,
    required this.draft,
    required this.onUpdateDraft,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const _minimumWeightKg = 40.0;
  static const _maximumWeightKg = 180.0;
  static const _defaultWeightKg = 78.5;
  static const _metricWeightStep = 0.5;
  static const _imperialWeightStep = 1.0;
  static const _minimumHeightCm = 100.0;
  static const _maximumHeightCm = 230.0;
  static const _defaultHeightCm = 182.0;
  static const _heightStep = 1.0;

  static String _formatDisplayValue(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final preferredUnit = draft.preferredUnits ?? PreferredUnit.metric;
    final heightValue = draft.heightCm == null
        ? ''
        : _formatDisplayValue(preferredUnit.toDisplayHeight(draft.heightCm!));
    final weightValue = draft.bodyweightKg == null
        ? ''
        : _formatDisplayValue(
            preferredUnit.toDisplayWeight(draft.bodyweightKg!),
          );

    return Column(
      children: [
        OnboardingIntroHeader(
          title: AppStrings.onboardingEliteBaselineTitle,
          description: AppStrings.onboardingEliteBaselineDescription,
        ),
        _OnboardingBaselineMetricCard(
          key: const ValueKey<String>('onboarding_baseline_weight_card'),
          unitToggleKeyPrefix: 'onboarding_weight_unit',
          title: AppStrings.weight,
          selectedUnit: preferredUnit,
          metricUnitLabel: AppStrings.metricWeightUnit,
          imperialUnitLabel: AppStrings.imperialWeightUnit,
          value: weightValue,
          numericValue: draft.bodyweightKg == null
              ? null
              : preferredUnit.toDisplayWeight(draft.bodyweightKg!),
          minimumValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayWeight(_minimumWeightKg).roundToDouble()
              : _minimumWeightKg,
          maximumValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayWeight(_maximumWeightKg).roundToDouble()
              : _maximumWeightKg,
          defaultValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayWeight(_defaultWeightKg).roundToDouble()
              : _defaultWeightKg,
          step: preferredUnit.isImperial
              ? _imperialWeightStep
              : _metricWeightStep,
          hintText: preferredUnit.weightHint,
          displayUnit: preferredUnit.weightUnit,
          onSelectUnit: (unit) {
            onUpdateDraft(draft.copyWith(preferredUnits: unit));
          },
          onChanged: (value) {
            final parsed = double.tryParse(value);
            if (parsed == null) {
              onUpdateDraft(draft.copyWith(clearBodyweightKg: true));
              return;
            }
            onUpdateDraft(
              draft.copyWith(
                bodyweightKg: preferredUnit.toCanonicalWeight(parsed),
              ),
            );
          },
        ),
        AppWhiteSpace.hLg,
        _OnboardingBaselineMetricCard(
          key: const ValueKey<String>('onboarding_baseline_height_card'),
          unitToggleKeyPrefix: 'onboarding_height_unit',
          title: AppStrings.height,
          selectedUnit: preferredUnit,
          metricUnitLabel: AppStrings.metricHeightUnit,
          imperialUnitLabel: AppStrings.imperialHeightUnit,
          value: heightValue,
          numericValue: draft.heightCm == null
              ? null
              : preferredUnit.toDisplayHeight(draft.heightCm!),
          minimumValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayHeight(_minimumHeightCm).roundToDouble()
              : _minimumHeightCm,
          maximumValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayHeight(_maximumHeightCm).roundToDouble()
              : _maximumHeightCm,
          defaultValue: preferredUnit.isImperial
              ? preferredUnit.toDisplayHeight(_defaultHeightCm).roundToDouble()
              : _defaultHeightCm,
          step: _heightStep,
          hintText: preferredUnit.heightHint,
          displayUnit: preferredUnit.heightUnit,
          onSelectUnit: (unit) {
            onUpdateDraft(draft.copyWith(preferredUnits: unit));
          },
          onChanged: (value) {
            final parsed = double.tryParse(value);
            if (parsed == null) {
              onUpdateDraft(draft.copyWith(clearHeightCm: true));
              return;
            }
            onUpdateDraft(
              draft.copyWith(heightCm: preferredUnit.toCanonicalHeight(parsed)),
            );
          },
        ),
        AppWhiteSpace.hXl,
        _OnboardingBaselineMaxLiftsSurface(
          key: const ValueKey<String>('onboarding_baseline_max_lifts_card'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.onboardingMaxLiftsTitle,
                style: AppTextStyles.headlineMd.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                AppStrings.onboardingMaxLiftsHelper,
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppWhiteSpace.hMd,
              const _OnboardingBaselineAccuracyBadge(),
              AppWhiteSpace.hXl,
              OnboardingBaselineLiftField(
                key: ValueKey('bench1rm_${draft.preferredUnits}'),
                surfaceKey: const ValueKey<String>(
                  'onboarding_bench_press_1rm_input',
                ),
                label: AppStrings.onboardingBenchPressLabel,
                initialValue: draft.bench1RmKg != null
                    ? _formatDisplayValue(
                        preferredUnit.toDisplayWeight(draft.bench1RmKg!),
                      )
                    : '',
                unit: preferredUnit.weightUnit,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    onUpdateDraft(
                      draft.copyWith(
                        bench1RmKg: preferredUnit.toCanonicalWeight(parsed),
                      ),
                    );
                  } else {
                    onUpdateDraft(draft.copyWith(clearBench1RmKg: true));
                  }
                },
              ),
              AppWhiteSpace.hLg,
              OnboardingBaselineLiftField(
                key: ValueKey('squat1rm_${draft.preferredUnits}'),
                surfaceKey: const ValueKey<String>(
                  'onboarding_back_squat_1rm_input',
                ),
                label: AppStrings.onboardingBackSquatLabel,
                initialValue: draft.squat1RmKg != null
                    ? _formatDisplayValue(
                        preferredUnit.toDisplayWeight(draft.squat1RmKg!),
                      )
                    : '',
                unit: preferredUnit.weightUnit,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    onUpdateDraft(
                      draft.copyWith(
                        squat1RmKg: preferredUnit.toCanonicalWeight(parsed),
                      ),
                    );
                  } else {
                    onUpdateDraft(draft.copyWith(clearSquat1RmKg: true));
                  }
                },
              ),
              AppWhiteSpace.hLg,
              OnboardingBaselineLiftField(
                key: ValueKey('deadlift1rm_${draft.preferredUnits}'),
                surfaceKey: const ValueKey<String>(
                  'onboarding_deadlift_1rm_input',
                ),
                label: AppStrings.onboardingDeadliftLabel,
                initialValue: draft.deadlift1RmKg != null
                    ? _formatDisplayValue(
                        preferredUnit.toDisplayWeight(draft.deadlift1RmKg!),
                      )
                    : '',
                unit: preferredUnit.weightUnit,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    onUpdateDraft(
                      draft.copyWith(
                        deadlift1RmKg: preferredUnit.toCanonicalWeight(parsed),
                      ),
                    );
                  } else {
                    onUpdateDraft(draft.copyWith(clearDeadlift1RmKg: true));
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingBaselineAccuracyBadge extends StatelessWidget {
  const _OnboardingBaselineAccuracyBadge();

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
    final badgeColor = context.colorScheme.surfaceContainerHighest;

    return Container(
      key: const ValueKey<String>('onboarding_max_lifts_accuracy_badge'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.5),
          width: AppSizing.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.materialInfoFilled,
            width: AppSizing.iconS,
            height: AppSizing.iconS,
            colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
          ),
          AppWhiteSpace.wSm,
          Flexible(
            child: Text(
              AppStrings.onboardingImprovesAccuracy,
              style: AppTextStyles.labelSm.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBaselineMaxLiftsSurface extends StatelessWidget {
  const _OnboardingBaselineMaxLiftsSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final accent = isDark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return DecoratedBox(
      key: const ValueKey<String>('onboarding_max_lifts_glass_surface'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: AppSizing.onboardingGlassCardShadowBlur,
            spreadRadius: AppSizing.onboardingGlassCardShadowSpread,
            offset: const Offset(0, AppSizing.onboardingGlassCardShadowOffset),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppSpacing.controlGap,
            sigmaY: AppSpacing.controlGap,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLowest.withValues(
                alpha: 0.7,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color:
                    (isDark
                            ? context.colorScheme.outlineVariant
                            : context.colorScheme.surfaceContainerLowest)
                        .withValues(alpha: 0.4),
                width: AppSizing.divider,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _OnboardingBaselineMetricCard extends StatefulWidget {
  const _OnboardingBaselineMetricCard({
    super.key,
    required this.unitToggleKeyPrefix,
    required this.title,
    required this.selectedUnit,
    required this.metricUnitLabel,
    required this.imperialUnitLabel,
    required this.value,
    required this.numericValue,
    required this.minimumValue,
    required this.maximumValue,
    required this.defaultValue,
    required this.step,
    required this.hintText,
    required this.displayUnit,
    required this.onSelectUnit,
    required this.onChanged,
  });

  final String unitToggleKeyPrefix;
  final String title;
  final PreferredUnit selectedUnit;
  final String metricUnitLabel;
  final String imperialUnitLabel;
  final String value;
  final double? numericValue;
  final double minimumValue;
  final double maximumValue;
  final double defaultValue;
  final double step;
  final String hintText;
  final String displayUnit;
  final void Function(PreferredUnit unit) onSelectUnit;
  final void Function(String value) onChanged;

  @override
  State<_OnboardingBaselineMetricCard> createState() =>
      _BaselineMetricCardState();
}

class _BaselineMetricCardState extends State<_OnboardingBaselineMetricCard> {
  final _valueFieldKey = GlobalKey<_OnboardingMetricValueFieldState>();

  @override
  void didUpdateWidget(_OnboardingBaselineMetricCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedUnit != widget.selectedUnit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _valueFieldKey.currentState?.setValue(widget.value);
      });
    }
  }

  String _formatRulerValue(double value) {
    return widget.step < 1
        ? value.toStringAsFixed(1)
        : value.round().toString();
  }

  void _handleRulerChanged(double value) {
    final formatted = _formatRulerValue(value);
    _valueFieldKey.currentState?.setValue(formatted);
    widget.onChanged(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final rulerKeyPrefix = 'onboarding_${widget.title.toLowerCase()}_ruler';

    return OnboardingConstraintSurface(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              AppWhiteSpace.wMd,
              _OnboardingBaselineUnitToggle(
                keyPrefix: widget.unitToggleKeyPrefix,
                selectedUnit: widget.selectedUnit,
                metricLabel: widget.metricUnitLabel,
                imperialLabel: widget.imperialUnitLabel,
                onSelect: widget.onSelectUnit,
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          _OnboardingMetricValueField(
            key: _valueFieldKey,
            initialValue: widget.value,
            hintText: widget.hintText,
            suffixText: widget.displayUnit,
            onChanged: widget.onChanged,
          ),
          AppWhiteSpace.hMd,
          OnboardingMetricRuler(
            key: ValueKey<String>(rulerKeyPrefix),
            keyPrefix: rulerKeyPrefix,
            label: AppStrings.onboardingMetricRulerLabel(widget.title),
            value: widget.numericValue,
            defaultValue: widget.defaultValue,
            minimumValue: widget.minimumValue,
            maximumValue: widget.maximumValue,
            step: widget.step,
            onChanged: _handleRulerChanged,
          ),
        ],
      ),
    );
  }
}

class _OnboardingMetricValueField extends StatefulWidget {
  const _OnboardingMetricValueField({
    super.key,
    required this.initialValue,
    required this.hintText,
    required this.suffixText,
    required this.onChanged,
  });

  final String initialValue;
  final String hintText;
  final String suffixText;
  final void Function(String value) onChanged;

  @override
  State<_OnboardingMetricValueField> createState() =>
      _OnboardingMetricValueFieldState();
}

class _OnboardingMetricValueFieldState
    extends State<_OnboardingMetricValueField> {
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

  void setValue(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return SizedBox(
      width: AppSizing.onboardingMetricValueWidth,
      child: AppTextField(
        controller: _controller,
        hintText: widget.hintText,
        suffixText: widget.suffixText,
        suffixStyle: AppTextStyles.bodyMd.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: widget.onChanged,
        filled: false,
        borderOverride: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        style: AppTextStyles.headlineXl.copyWith(color: accent),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _OnboardingBaselineUnitToggle extends StatelessWidget {
  const _OnboardingBaselineUnitToggle({
    required this.keyPrefix,
    required this.selectedUnit,
    required this.metricLabel,
    required this.imperialLabel,
    required this.onSelect,
  });

  static const _animationDuration = Duration(milliseconds: 200);
  static const double _indicatorWidthFactor = 0.5;

  final String keyPrefix;
  final PreferredUnit selectedUnit;
  final String metricLabel;
  final String imperialLabel;
  final void Function(PreferredUnit unit) onSelect;

  @override
  Widget build(BuildContext context) {
    final metricSelected = selectedUnit == PreferredUnit.metric;

    return Container(
      key: ValueKey<String>('${keyPrefix}_toggle'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      child: IntrinsicWidth(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedAlign(
                  key: ValueKey<String>('${keyPrefix}_sliding_indicator'),
                  alignment: metricSelected
                      ? AlignmentDirectional.centerStart
                      : AlignmentDirectional.centerEnd,
                  duration: _animationDuration,
                  curve: Curves.easeOutCubic,
                  child: FractionallySizedBox(
                    widthFactor: _indicatorWidthFactor,
                    heightFactor: 1,
                    child: DecoratedBox(
                      key: ValueKey<String>('${keyPrefix}_sliding_thumb'),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: _OnboardingBaselineUnitButton(
                    label: metricLabel,
                    selected: metricSelected,
                    animationDuration: _animationDuration,
                    onTap: () => onSelect(PreferredUnit.metric),
                  ),
                ),
                Expanded(
                  child: _OnboardingBaselineUnitButton(
                    label: imperialLabel,
                    selected: !metricSelected,
                    animationDuration: _animationDuration,
                    onTap: () => onSelect(PreferredUnit.imperial),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingBaselineUnitButton extends StatelessWidget {
  const _OnboardingBaselineUnitButton({
    required this.label,
    required this.selected,
    required this.animationDuration,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Duration animationDuration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? context.theme.brightness == Brightness.dark
              ? context.colorScheme.primary
              : context.colorScheme.secondary
        : context.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.controlGap,
            vertical: AppSpacing.sm,
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: animationDuration,
              curve: Curves.easeOutCubic,
              style: AppTextStyles.labelSm.copyWith(color: foreground),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
