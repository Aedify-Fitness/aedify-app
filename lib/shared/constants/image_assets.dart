import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/foundation.dart' show Brightness;
import 'package:flutter/material.dart' show BuildContext;

class ImageAssets {
  ImageAssets._();

  static const _pathPrefix = 'assets/images';

  static const logoDark = '$_pathPrefix/logo_dark.png';
  static const logoLight = '$_pathPrefix/logo_light.png';
  static const onboardingWelcomeGym = '$_pathPrefix/onboarding_welcome_gym.jpg';
  static const onboardingDumbbells = '$_pathPrefix/onboarding_dumbbells.jpg';
  static const onboardingBarbell = '$_pathPrefix/onboarding_barbell.jpg';
  static const onboardingBench = '$_pathPrefix/onboarding_bench.jpg';
  static const onboardingSquatRack = '$_pathPrefix/onboarding_squat_rack.jpg';
  static const onboardingKettlebells =
      '$_pathPrefix/onboarding_kettlebells.jpg';
  static const onboardingResistanceBands =
      '$_pathPrefix/onboarding_resistance_bands.jpg';
  static const onboardingPullUpBar = '$_pathPrefix/onboarding_pull_up_bar.jpg';
  static const onboardingCableMachine =
      '$_pathPrefix/onboarding_cable_machine.jpg';
  static const onboardingSmithMachine =
      '$_pathPrefix/onboarding_smith_machine.jpg';
  static const onboardingCardioMachine =
      '$_pathPrefix/onboarding_cardio_machine.jpg';

  static String appLogo(BuildContext context) {
    return context.theme.brightness == Brightness.light ? logoLight : logoDark;
  }
}
