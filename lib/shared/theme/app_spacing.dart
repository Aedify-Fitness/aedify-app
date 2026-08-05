import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double baseUnit = 4;
  static const double xxxs = 1;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
  static const double buttonVertical = 12;
  static const double inputHorizontal = 6;
  static const double inputVertical = 14;
  static const double reviewActionVertical = 20;
  static const double controlGap = 12;

  // DESIGN.md semantic layout tokens
  static const double gutter = 24;
  static const double marginMobile = 16;
  static const double marginDesktop = 48;
  static const double containerMax = 1280;
  static const double stackSm = 8;
  static const double stackMd = 16;
  static const double stackLg = 32;
}

class AppWhiteSpace {
  AppWhiteSpace._();

  static const wXxs = SizedBox(width: AppSpacing.xxs);
  static const wXs = SizedBox(width: AppSpacing.xs);
  static const wSm = SizedBox(width: AppSpacing.sm);
  static const wControlGap = SizedBox(width: AppSpacing.controlGap);
  static const wMd = SizedBox(width: AppSpacing.md);
  static const wLg = SizedBox(width: AppSpacing.lg);
  static const wXl = SizedBox(width: AppSpacing.xl);
  static const wXxl = SizedBox(width: AppSpacing.xxl);
  static const wXxxl = SizedBox(width: AppSpacing.xxxl);

  static const hXxs = SizedBox(height: AppSpacing.xxs);
  static const hXs = SizedBox(height: AppSpacing.xs);
  static const hSm = SizedBox(height: AppSpacing.sm);
  static const hControlGap = SizedBox(height: AppSpacing.controlGap);
  static const hMd = SizedBox(height: AppSpacing.md);
  static const hLg = SizedBox(height: AppSpacing.lg);
  static const hXl = SizedBox(height: AppSpacing.xl);
  static const hXxl = SizedBox(height: AppSpacing.xxl);
  static const hXxxl = SizedBox(height: AppSpacing.xxxl);

  static SizedBox both(double value) => SizedBox(width: value, height: value);
  static SizedBox custom({double? width, double? height}) =>
      SizedBox(width: width, height: height);
}

class AppRadius {
  AppRadius._();

  static const double sm = 4;
  static const double xxs = 2;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 9999;
  static const double defaultRadius = 8;
}

class AppSizing {
  AppSizing._();

  static const double iconXs = 14;
  static const double iconS = 18;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 28;
  static const double iconXxl = 48;
  static const double divider = 1;
  static const double iconXxs = 16;
  static const double strokeWidth = 2;
  static const double handleWidth = 40;
  static const double fieldWidth = 120;
  static const double progressBarHeight = 6;
  static const double cardBadge = 44;
  static const double optionCardMinHeight = 104;
  static const double metricTileMinWidth = 88;
  static const double metricTileHeight = 72;
  static const double fieldWidthXs = 56;
  static const double fieldWidthSm = 64;
  static const double fieldWidthMd = 72;
  static const double fieldWidthLg = 80;
  static const double fieldWidthXl = 96;
  static const double reviewCardIcon = 36;
  static const double bodymapSvgWidth = 240;
  static const double bodymapSvgHeight = 480;
  static const double videoCardHeight = 220;
  static const double videoPreviewHeight = 200;
  static const double emptyStateHeight = 300;
  static const double restTimerSize = 200;
  static const double weekTypeDropdownWidth = 130;
  static const double dataFieldWidthSm = 60;
  static const double dataFieldWidthMd = 100;
  static const double timerStrokeWidth = 8;
  static const double hairlineStrokeWidth = 1;
  static const double inputFieldHeight = 36;
  static const double activeIndicatorHeight = 4;
  static const double navBarHeight = 72;
  static const double deloadLineStrokeWidth = 10;
  static const double deloadLineSpacing = 40;
  static const double exerciseNumberCircle = 56;
  static const double setNumberColumnWidth = 32;
  static const double decorativeIcon = 128;
  static const double onboardingHeroImageHeight = 200;
  static const double onboardingEquipmentImageHeight = 160;
  static const double onboardingEquipmentThumbnail = 96;
  static const double onboardingConstraintActionSize = 32;
  static const double onboardingLimitationTileHeight = 120;
  static const double onboardingMetricValueWidth = 180;
  static const double onboardingMetricRulerHeight = 96;
  static const double onboardingMetricRulerMajorTick = 32;
  static const double onboardingMetricRulerMinorTick = 16;
  static const double onboardingMaxLiftFieldHeight = 56;
  static const double onboardingByokFieldHeight = 56;
  static const double onboardingByokProviderCardMinHeight = 112;
  static const double onboardingByokBenefitIcon = 32;
  static const double onboardingEyebrowLetterSpacing = 0.6;
  static const double onboardingGlassCardShadowBlur = 40;
  static const double onboardingGlassCardShadowSpread = -10;
  static const double onboardingGlassCardShadowOffset = 10;
  static const double onboardingIdentityChoiceHeight = 88;
  static const double onboardingWeekdayChoiceHeight = 56;
  static const double onboardingScheduleChartHeight = 96;
  static const double onboardingWeeklyLoadChartHeight = 128;
  static const double onboardingScheduleBarMinHeight = 16;
  static const double onboardingScheduleBarMaxHeight = 72;
  static const double onboardingGoalCardAspectRatio = 2.2;
  static const double reviewStatusDot = 8;
  static const double reviewDayIndicatorWidth = 24;
  static const double reviewDayIndicatorHeight = 4;
  static const double reviewMetricIcon = 96;
  static const double reviewDecorativeIcon = 200;
  static const double reviewStatusLetterSpacing = 1.2;
}

class AppFontSizes {
  AppFontSizes._();

  static const double xxs = 10;
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 28;
  static const double displaySm = 32;
  static const double displayMd = 40;
  static const double displayLg = 56;
}
