import 'package:flutter/material.dart';
import 'package:aedify/shared/theme/app_spacing.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String inter = 'Inter';
  static const String manrope = 'Manrope';

  static const TextStyle headlineXl = TextStyle(
    fontFamily: manrope,
    fontSize: AppFontSizes.displayMd,
    fontWeight: FontWeight.w700,
    height: 1.20,
    letterSpacing: -0.80,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: manrope,
    fontSize: AppFontSizes.displaySm,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.32,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: manrope,
    fontSize: AppFontSizes.xxl,
    fontWeight: FontWeight.w600,
    height: 1.333,
    letterSpacing: 0,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: manrope,
    fontSize: AppFontSizes.xxl,
    fontWeight: FontWeight.w600,
    height: 1.333,
    letterSpacing: 0,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: manrope,
    fontSize: AppFontSizes.lg,
    fontWeight: FontWeight.w400,
    height: 1.556,
    letterSpacing: 0,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: manrope,
    fontSize: AppFontSizes.md,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: manrope,
    fontSize: AppFontSizes.sm,
    fontWeight: FontWeight.w400,
    height: 1.429,
    letterSpacing: 0,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: manrope,
    fontSize: AppFontSizes.sm,
    fontWeight: FontWeight.w600,
    height: 1.429,
    letterSpacing: 0.14,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: manrope,
    fontSize: AppFontSizes.xs,
    fontWeight: FontWeight.w500,
    height: 1.333,
    letterSpacing: 0.24,
  );
}

class AppTextStylesDark {
  AppTextStylesDark._();

  static const TextStyle headlineXl = TextStyle(
    fontFamily: AppTextStyles.manrope,
    fontSize: AppFontSizes.displayMd,
    fontWeight: FontWeight.w700,
    height: 1.20,
    letterSpacing: -0.80,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: AppTextStyles.manrope,
    fontSize: AppFontSizes.displaySm,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.32,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: AppTextStyles.manrope,
    fontSize: AppFontSizes.xxxl,
    fontWeight: FontWeight.w600,
    height: 1.286,
    letterSpacing: 0,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: AppTextStyles.manrope,
    fontSize: AppFontSizes.xxl,
    fontWeight: FontWeight.w600,
    height: 1.333,
    letterSpacing: 0,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: AppTextStyles.inter,
    fontSize: AppFontSizes.lg,
    fontWeight: FontWeight.w400,
    height: 1.556,
    letterSpacing: 0,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: AppTextStyles.inter,
    fontSize: AppFontSizes.md,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: AppTextStyles.inter,
    fontSize: AppFontSizes.sm,
    fontWeight: FontWeight.w400,
    height: 1.429,
    letterSpacing: 0,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: AppTextStyles.inter,
    fontSize: AppFontSizes.sm,
    fontWeight: FontWeight.w600,
    height: 1.143,
    letterSpacing: 0.14,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: AppTextStyles.inter,
    fontSize: AppFontSizes.xs,
    fontWeight: FontWeight.w500,
    height: 1.167,
    letterSpacing: 0.24,
  );
}
