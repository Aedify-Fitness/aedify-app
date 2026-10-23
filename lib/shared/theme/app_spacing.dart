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
  static const double formFieldVertical = 20;
  static const double formChipHorizontal = 20;
  static const double formChipVertical = 10;
  static const double formSectionGap = 40;

  // DESIGN.md semantic layout tokens
  static const double gutter = 24;
  static const double marginMobile = 16;
  static const double marginDesktop = 48;
  static const double containerMax = 1280;
  static const double stackSm = 8;
  static const double stackMd = 16;
  static const double stackLg = 32;
}

abstract final class AppBottomNavigationTokens {
  static const double height = AppSpacing.xxxl;
  static const double selectedIndicatorEdgeInset = 6;
  static const double selectedIndicatorHeight =
      height - (selectedIndicatorEdgeInset * 2);
  static const double horizontalMargin = AppSpacing.marginMobile;
  static const double bottomMargin = AppSpacing.marginMobile;
  static const double contentBreathingSpace = AppSpacing.marginMobile;
  static const double blurSigma = 20;
  static const double borderWidth = 1;
  static const double shadowOpacity = 0.08;
  static const double borderOpacity = 0.32;
  static const double lightSurfaceOpacity = 0.3;
  static const double darkSurfaceOpacity = 0.3;
  static const double highContrastSurfaceOpacity = 0.96;
  static const double baseContentClearance =
      height + bottomMargin + contentBreathingSpace;

  static double surfaceOpacity(BuildContext context) {
    if (MediaQuery.highContrastOf(context)) {
      return highContrastSurfaceOpacity;
    }
    return Theme.brightnessOf(context) == Brightness.dark
        ? darkSurfaceOpacity
        : lightSurfaceOpacity;
  }
}

abstract final class AppProgrammeBuilderTokens {
  static const double mobileContentMaxWidth = 390;
  static const double assignmentSheetHeightFactor = 0.85;
  static const double supersetSheetHeightFactor = 0.85;
  static const double actionShadowOpacity = 0.12;
  static const double actionShadowBlur = 20;
  static const double actionIconOpacity = 0.2;
  static const double actionDisabledOpacity = 0.3;
  static const double managementBorderOpacity = 0.6;
  static const double managementDividerOpacity = 0.5;
  static const double managementButtonBorderOpacity = 0.8;
  static const double assignmentExerciseIconSize = 56;
  static const double saveDraftWidth = 88;
  static const double headerMinHeight = 64;
  static const double backSwipeEdge = 24;
  static const double backSwipeDistance = 64;
  static const double backSwipeVelocity = 500;
  static const double sectionIconSize = 40;
  static const double sectionGap = 24;
  static const double dayGap = 4;
  static const double borderOpacity = 0.3;
  static const double highlightOpacity = 0.1;
  static const List<int> durationWeeks = [1, 4, 8, 12];
}

abstract final class AppProgrammeReviewTokens {
  static const double heroMinHeight = 128;
  static const double badgeOpacity = 0.2;
  static const double borderOpacity = 0.2;
  static const double inverseDividerOpacity = 0.1;
  static const double workloadTrackHeight = 8;
}

abstract final class AppProgrammeCalendarTokens {
  static const double maxContentWidth = 640;
  static const double controlSize = 48;
  static const double weekWidth = 80;
  static const double dayRailWidth = 48;
  static const double progressTrackHeight = 6;
}

abstract final class AppExerciseConfigTokens {
  static const double tableWidth = 440;
  static const double fieldHeight = 36;
  static const double labelTracking = 0.5;
}

abstract final class AppWorkoutRunnerTokens {
  static const double maxContentWidth = 512;
  static const double horizontalPadding = 20;
  static const double innerMaxContentWidth =
      maxContentWidth - (horizontalPadding * 2);
  static const double headerExtent = 116;
  static const double supersetHeaderExtent = 96;
  static const double stackedHeaderBreakpoint = 360;
  static const double largeTextBreakpoint = 1.3;
  static const double sectionGap = AppSpacing.lg;
  static const double contentBreathingSpace = AppSpacing.lg;
  static const double actionBarVerticalPadding = AppSpacing.lg;
  static const double actionBarButtonHeight = 60;
  static const double actionBarGap = AppSpacing.md;
  static const double actionBarExtent =
      actionBarButtonHeight + (actionBarVerticalPadding * 2);
  static const double mediaAspectRatio = 16 / 9;
  static const double mediaControlSize = AppSpacing.xxl;
  static const double mediaControlVisualSize = 40;
  static const double timerMinWidth = 104;
  static const double timerHeight = AppSpacing.xxl;
  static const double restTimerRingSize = 128;
  static const double restTimerRingBorderWidth = AppSpacing.xs;
  static const double restTimerLabelGap = AppSpacing.sm;
  static const double restTimerLabelLineHeight = AppSpacing.md;
  static const double restTimerLabelLetterSpacing = 1.2;
  static const double restPanelVerticalPadding = AppSpacing.lg;
  static const double restPanelSectionGap = AppSpacing.lg;
  static const double restAdjustButtonVerticalPadding =
      AppSpacing.buttonVertical;
  static const double restAdjustButtonLineHeight = 20;
  static const double restSkipButtonVerticalPadding = AppSpacing.md;
  static const double restSkipButtonLineHeight = AppSpacing.lg;
  static const double restPanelExtent =
      (restPanelVerticalPadding * 2) +
      restTimerRingSize +
      restTimerLabelGap +
      restTimerLabelLineHeight +
      (restPanelSectionGap * 2) +
      (restAdjustButtonVerticalPadding * 2) +
      restAdjustButtonLineHeight +
      (restSkipButtonVerticalPadding * 2) +
      restSkipButtonLineHeight;
  static const double trainingLogHeaderVerticalPadding = AppSpacing.md;
  static const double setRowHorizontalPadding = AppSpacing.lg;
  static const double standardSetRowVerticalPadding = AppSpacing.lg;
  static const double activeSetRowVerticalPadding = AppSpacing.xl;
  static const double setGridGap = AppSpacing.sm;
  static const double setActionSize = 40;
  static const double activeSetActionSize = AppSpacing.xxl;
  static const double activeRailWidth = AppSpacing.xs;
  static const double activeRailInset = 12;
  static const double supersetPreviewImageSize = AppSpacing.xxxl;
  static const double supersetConnectorLeft = 38;
  static const double supersetConnectorTop = 40;
  static const double supersetConnectorBottom = 40;
  static const double supersetConnectorWidth = 2;
  static const double supersetConnectorOpacity = 0.2;
  static const double supersetUpcomingRoundOpacity = 0.5;
  static const double supersetSetRowVerticalPadding = AppSpacing.md;
  static const double setInputHeight = 44;
  static const double setInputMaxWidth = AppSizing.fieldWidthLg;
  static const double insightIconSize = 40;
  static const double nextExerciseIconSize = AppSpacing.xxl;
  static const double nextExerciseMinHeight = 112;
  static const double nextExerciseElevation = 1;
  static const double glassBlurSigma = 12;
  static const double headerSurfaceOpacity = 0.8;
  static const double actionSurfaceOpacity = 0.9;
  static const double mediaGlassSurfaceOpacity = 0.2;
  static const double mediaGlassBorderOpacity = 0.3;
  static const double mediaScrimOpacity = 0.48;
  static const double activeRowSurfaceOpacity = 0.05;
  static const double upcomingRowOpacity = 0.4;
  static const double subtleBorderOpacity = 0.6;
  static const double shadowOpacity = 0.08;
  static const double shadowBlurRadius = 20;
  static const double shadowOffsetY = AppSpacing.xs;
  static const double eyebrowLetterSpacing = 1.2;
  static const double edgeSwipeWidth = 30;
  static const double edgeSwipeMinimumVelocity = 200;

  static double headerExtentFor(BuildContext context) {
    final scaledTitle = MediaQuery.textScalerOf(context).scale(AppFontSizes.lg);
    final extraHeight = (scaledTitle - AppFontSizes.lg).clamp(0, AppSpacing.xl);
    return headerExtent + extraHeight;
  }
}

abstract final class AppExerciseDetailTokens {
  static const double controlSize = 48;
  static const double maxContentWidth = 398;
  static const double maxScreenWidth = maxContentWidth + (AppSpacing.md * 2);
  static const double mediaAspectRatio = 16 / 9;
  static const double videoCardWidth = 288;
  static const double videoCardGap = AppSpacing.md;
  static const double videoScrimOpacity = 0.2;
  static const double videoOverlaySurfaceOpacity = 0.9;
  static const double videoBadgeVerticalPadding = 6;
  static const double bodymapStageHeight = 192;
  static const double compactContentBreakpoint = 300;
  static const double largeTextBreakpoint = 1.3;
  static const double mutedBodymapOpacity = 0.8;
  static const double notesMinHeight = 150;
  static const double bottomActionHeight = 56;
  static const double bottomActionMaxWidth = 384;
  static const double bottomActionInset = AppSpacing.lg;
  static const double bottomActionBorderOpacity = 0.2;
  static const double stepDividerOpacity = 0.1;
  static const double contentBottomClearance =
      bottomActionHeight + (bottomActionInset * 2);
}

abstract final class AppWorkoutDetailTokens {
  static const double maxContentWidth = 640;
  static const double controlSize = 48;
  static const double exerciseNumberSize = 36;
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
  static const hFormSectionGap = SizedBox(height: AppSpacing.formSectionGap);

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
  static const double navBarHeight = AppBottomNavigationTokens.height;
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
  static const double homeAlertIconTile = 40;
  static const double homeMetricIconSize = 56;
  static const double homeContentTopOffset = 96;
  static const double homeWorkoutHeroMinHeight = 340;
  static const double homeWorkoutGlowSize = 256;
  static const double homeWorkoutGlowOffset = 64;
  static const double homeWorkoutGlowBlur = 80;
  static const double homePrimaryActionHeight = 56;
  static const double homeSecondaryActionHeight = 52;
  static const double homeProgrammeTrackHeight = 10;
  static const double homeQuickActionIconSize = 56;
  static const double homeEyebrowLetterSpacing = 1.2;
  static const double customExerciseEditorMaxWidth = 768;
  static const double customExerciseLoggingThreeColumnMinWidth = 600;
  static const double customExerciseLoggingCardHeight = 164;
  static const double customExerciseInputFocusBlur = 20;
  static const double customExerciseActionElevation = 6;
  static const double workoutDetailInlineMetadataMinWidth = 200;
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
