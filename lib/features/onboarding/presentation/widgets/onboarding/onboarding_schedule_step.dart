import 'package:aedify/features/onboarding/presentation/widgets/onboarding/onboarding_intro_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingScheduleStep extends StatelessWidget {
  const OnboardingScheduleStep({
    super.key,
    required this.draft,
    required this.onUpdateDraft,
  });

  final OnboardingDraft draft;
  final void Function(OnboardingDraft) onUpdateDraft;

  static const double defaultDuration = 60;

  double get _bgImageSize => 250;
  int get _durationDivisions => 20;
  double get _minimumDuration => 20;
  double get _maximumDuration => 120;
  double get _selectedDuration =>
      (draft.targetSessionLengthMinutes?.toDouble() ?? defaultDuration)
          .clamp(_minimumDuration, _maximumDuration)
          .toDouble();
  double get weeklyHours =>
      draft.trainingDays.length * _selectedDuration / defaultDuration;
  String get fatigueRisk => weeklyHours > 7
      ? AppStrings.onboardingFatigueHigh
      : weeklyHours > 5
      ? AppStrings.onboardingFatigueModerate
      : AppStrings.onboardingFatigueLow;

  @override
  Widget build(BuildContext context) {
    final durationScaleStyle = AppTextStyles.labelSm.copyWith(
      color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      fontWeight: FontWeight.w700,
      letterSpacing: AppSizing.reviewStatusLetterSpacing,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingIntroHeader(
          title: AppStrings.onboardingRhythmDisplayTitle,
          description: AppStrings.onboardingRhythmDisplayDescription,
        ),
        _OnboardingSchedulePanel(
          sectionTitle: AppStrings.onboardingWeeklyFrequency,
          sectionIcon: OutlinedSvgAssets.materialCalendarToday,
          sectionDescription: AppStrings.onboardingWeeklyFrequencyDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                mainAxisExtent: AppSizing.onboardingWeekdayChoiceHeight,
                children: TrainingDay.values.map((day) {
                  final isSelected = draft.trainingDays.contains(day);
                  return _OnboardingWeekdayChoice(
                    label: day.displayLabel,
                    selected: isSelected,
                    onTap: () {
                      final updated = List<TrainingDay>.from(
                        draft.trainingDays,
                      );
                      if (isSelected) {
                        updated.remove(day);
                      } else {
                        updated.add(day);
                      }
                      updated.sort(
                        (first, second) => first.index.compareTo(second.index),
                      );
                      onUpdateDraft(
                        draft.copyWith(
                          trainingDays: updated,
                          trainingDaysPerWeek: updated.length,
                          targetSessionLengthMinutes:
                              draft.targetSessionLengthMinutes ??
                              defaultDuration.toInt(),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              AppWhiteSpace.hLg,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLow,
                  border: Border(
                    left: BorderSide(
                      color: context.theme.brightness == Brightness.dark
                          ? context.colorScheme.primary
                          : context.colorScheme.secondary,
                      width: AppSpacing.xs,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                ),
                child: _OnboardingFeatureBullet(
                  iconAsset: OutlinedSvgAssets.materialLightBulb,
                  message: AppStrings.onboardingScheduleTip,
                ),
              ),
            ],
          ),
        ),
        AppWhiteSpace.hLg,
        _OnboardingSchedulePanel(
          sectionIcon: OutlinedSvgAssets.materialTimer,
          sectionTitle: AppStrings.onboardingSessionDuration,
          sectionDescription: AppStrings.onboardingSessionDurationDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.headlineMd.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    children: [
                      TextSpan(
                        text: _selectedDuration.round().toString(),
                        style: AppTextStyles.headlineXl.copyWith(
                          color: context.theme.brightness == Brightness.dark
                              ? context.colorScheme.primary
                              : context.colorScheme.secondary,
                          fontSize: AppFontSizes.displayLg,
                        ),
                      ),
                      const TextSpan(
                        text: ' ${AppStrings.onboardingReviewMinutes}',
                      ),
                    ],
                  ),
                ),
              ),
              AppWhiteSpace.hMd,
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: AppSpacing.sm,
                  activeTrackColor: context.theme.brightness == Brightness.dark
                      ? context.colorScheme.primary
                      : context.colorScheme.secondary,
                  inactiveTrackColor: context.colorScheme.surfaceContainerHigh,
                  overlayColor: context.colorScheme.secondary.withValues(
                    alpha: 0.12,
                  ),
                  thumbColor: context.theme.brightness == Brightness.dark
                      ? context.colorScheme.primary
                      : context.colorScheme.secondary,
                  thumbShape: _ScheduleSliderThumbShape(
                    ringColor: context.colorScheme.surfaceContainerLowest,
                  ),
                  tickMarkShape: SliderTickMarkShape.noTickMark,
                ),
                child: Slider(
                  value: _selectedDuration,
                  min: _minimumDuration,
                  max: _maximumDuration,
                  divisions: _durationDivisions,
                  onChanged: (value) {
                    onUpdateDraft(
                      draft.copyWith(targetSessionLengthMinutes: value.round()),
                    );
                  },
                ),
              ),
              AppWhiteSpace.hMd,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.onboardingScheduleEndurance.toUpperCase(),
                      textAlign: TextAlign.start,
                      style: durationScaleStyle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.onboardingScheduleOptimal.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: durationScaleStyle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.onboardingScheduleIntensity.toUpperCase(),
                      textAlign: TextAlign.end,
                      style: durationScaleStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppWhiteSpace.hXl,
        _OnboardingSchedulePanel(
          hasBgPicture: true,
          sectionTitle: AppStrings.onboardingTotalWeeklyLoad,
          child: Stack(
            children: [
              Positioned(
                right: -AppSizing.fieldWidthMd + AppSpacing.xxs,
                bottom: -AppSizing.fieldWidthMd - AppSpacing.xxs,
                child: Opacity(
                  opacity: 0.05,
                  child: SvgPicture.asset(
                    OutlinedSvgAssets.materialAnalytics,
                    width: _bgImageSize,
                    height: _bgImageSize,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  bottom: AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _OnboardingScheduleSummaryTile(
                              label: AppStrings
                                  .onboardingEstimatedTrainingVolume
                                  .toUpperCase(),
                              value: AppStrings.onboardingScheduleHours(
                                weeklyHours,
                              ),
                              accent: true,
                            ),
                          ),
                          AppWhiteSpace.wSm,
                          Expanded(
                            child: _OnboardingScheduleSummaryTile(
                              label: AppStrings.onboardingFatigueRisk
                                  .toUpperCase(),
                              value: fatigueRisk,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppWhiteSpace.hXl,
                    SizedBox(
                      height: AppSizing.onboardingWeeklyLoadChartHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: TrainingDay.values.map((day) {
                          final selected = draft.trainingDays.contains(day);
                          final heightProgress =
                              (_selectedDuration - _minimumDuration) /
                              (_maximumDuration - _minimumDuration);
                          final selectedBarHeight =
                              AppSizing.onboardingScheduleBarMinHeight +
                              (AppSizing.onboardingWeeklyLoadChartHeight -
                                      AppSizing
                                          .onboardingScheduleBarMinHeight) *
                                  heightProgress;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.inputHorizontal,
                              ),
                              child: AnimatedContainer(
                                key: ValueKey<String>(
                                  'onboarding_schedule_bar_${day.name}',
                                ),
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                height: selected
                                    ? selectedBarHeight
                                    : AppSizing.onboardingScheduleBarMinHeight,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? context.theme.brightness ==
                                                Brightness.dark
                                            ? context.colorScheme.primary
                                            : context.colorScheme.secondary
                                      : context.colorScheme.surfaceContainer,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(
                                      AppRadius.defaultRadius,
                                    ),
                                    topRight: Radius.circular(
                                      AppRadius.defaultRadius,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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

class _ScheduleSliderThumbShape extends SliderComponentShape {
  const _ScheduleSliderThumbShape({required this.ringColor});

  final Color ringColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.square(AppSpacing.lg);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final outerPath = Path()
      ..addOval(
        Rect.fromCircle(center: center, radius: AppSpacing.buttonVertical),
      );
    canvas.drawShadow(
      outerPath,
      sliderTheme.thumbColor ?? ringColor,
      AppSpacing.xs,
      true,
    );
    canvas.drawCircle(
      center,
      AppSpacing.buttonVertical,
      Paint()..color = ringColor,
    );
    canvas.drawCircle(
      center,
      AppSpacing.sm,
      Paint()..color = sliderTheme.thumbColor ?? ringColor,
    );
  }
}

class _OnboardingSchedulePanel extends StatelessWidget {
  final Widget child;
  final String sectionTitle;
  final String? sectionIcon;
  final bool hasBgPicture;
  final String? sectionDescription;
  const _OnboardingSchedulePanel({
    required this.child,
    required this.sectionTitle,
    this.sectionIcon,
    this.sectionDescription,
    this.hasBgPicture = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: double.infinity,
      padding: hasBgPicture
          ? EdgeInsets.zero
          : const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: AppSizing.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.secondary.withValues(alpha: 0.06),
            blurRadius: AppSpacing.lg,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: !hasBgPicture
                ? EdgeInsets.zero
                : const EdgeInsets.only(
                    top: AppSpacing.xl,
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                  ),
            child: Row(
              children: [
                Expanded(child: _OnboardingSectionTitle(title: sectionTitle)),
                AppWhiteSpace.wSm,
                if (sectionIcon != null)
                  SvgPicture.asset(
                    sectionIcon!,
                    width: AppSizing.iconLg,
                    height: AppSizing.iconLg,
                    colorFilter: ColorFilter.mode(
                      context.theme.brightness == Brightness.dark
                          ? context.colorScheme.primary
                          : context.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
              ],
            ),
          ),
          if (sectionDescription != null) ...[
            AppWhiteSpace.hXs,

            Text(
              sectionDescription!,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          AppWhiteSpace.hXl,

          child,
        ],
      ),
    );
  }
}

class _OnboardingWeekdayChoice extends StatelessWidget {
  const _OnboardingWeekdayChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final selectedBackground = isDark
        ? context.colorScheme.primaryContainer
        : context.colorScheme.secondaryContainer;
    final selectedForeground = isDark
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onSecondaryContainer;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: AppSizing.onboardingWeekdayChoiceHeight,
        decoration: BoxDecoration(
          color: selected
              ? selectedBackground
              : context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected
                ? context.colorScheme.secondary
                : context.colorScheme.surfaceContainerLow,
            width: selected ? AppSizing.strokeWidth : AppSizing.divider,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: selected
                      ? selectedForeground
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingFeatureBullet extends StatelessWidget {
  const _OnboardingFeatureBullet({
    required this.iconAsset,
    required this.message,
  });

  final String iconAsset;
  final String message;

  @override
  Widget build(BuildContext context) {
    final iconColor = context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconAsset,
          width: AppSizing.iconSm,
          height: AppSizing.iconSm,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
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

class _OnboardingScheduleSummaryTile extends StatelessWidget {
  const _OnboardingScheduleSummaryTile({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: accent
            ? context.colorScheme.secondaryContainer.withValues(alpha: 0.2)
            : context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: accent
                  ? context.colorScheme.secondary
                  : context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppWhiteSpace.hXs,
          Text(
            value,
            style: AppTextStyles.headlineMd.copyWith(
              color: accent
                  ? context.colorScheme.secondary
                  : context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSectionTitle extends StatelessWidget {
  const _OnboardingSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.bodyLg.copyWith(
        color: context.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
