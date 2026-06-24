import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/foundation.dart' show Brightness;
import 'package:flutter/material.dart' show BuildContext;

class ImageAssets {
  ImageAssets._();

  static const _pathPrefix = 'assets/images';

  static const logoDark = '$_pathPrefix/logo_dark.png';
  static const logoLight = '$_pathPrefix/logo_light.png';

  static String appLogo(BuildContext context) {
    return context.theme.brightness == Brightness.light ? logoLight : logoDark;
  }
}
