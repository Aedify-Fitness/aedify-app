import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double baseUnit = 4;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
  static const double buttonVertical = 12;
  static const double inputVertical = 14;
}

class AppWhiteSpace {
  AppWhiteSpace._();

  static const wXs = SizedBox(width: AppSpacing.xs);
  static const wSm = SizedBox(width: AppSpacing.sm);
  static const wMd = SizedBox(width: AppSpacing.md);
  static const wLg = SizedBox(width: AppSpacing.lg);
  static const wXl = SizedBox(width: AppSpacing.xl);
  static const wXxl = SizedBox(width: AppSpacing.xxl);
  static const wXxxl = SizedBox(width: AppSpacing.xxxl);

  static const hXs = SizedBox(height: AppSpacing.xs);
  static const hSm = SizedBox(height: AppSpacing.sm);
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
  static const double full = 9999;
  static const double defaultRadius = 8;
}

class AppSizing {
  AppSizing._();

  static const double iconXs = 18;
  static const double iconSm = 20;
  static const double divider = 1;
  static const double iconXxs = 16;
  static const double handleWidth = 40;
  static const double fieldWidth = 120;
}

class AppFontSizes {
  AppFontSizes._();

  static const double xs = 12;
}
