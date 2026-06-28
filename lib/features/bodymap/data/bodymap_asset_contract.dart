import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/bodymap/domain/bodymap_view_side.dart';
import 'package:aedify/shared/constants/svg_assets_bodymap.dart';

class BodymapAssetContract {
  BodymapAssetContract._();

  static const String frontAssetPath = BodymapSvgAssets.front;
  static const String backAssetPath = BodymapSvgAssets.back;

  static const Map<String, BodymapBucket> frontPathToBucket = {
    'chest': BodymapBucket.chest,
    'shoulders_r': BodymapBucket.shoulders,
    'shoulders_l': BodymapBucket.shoulders,
    'biceps_r': BodymapBucket.biceps,
    'biceps_l': BodymapBucket.biceps,
    'forearms_r': BodymapBucket.forearms,
    'forearms_l': BodymapBucket.forearms,
    'core': BodymapBucket.core,
    'quads_r': BodymapBucket.quads,
    'quads_l': BodymapBucket.quads,
    'adductors_r': BodymapBucket.adductors,
    'adductors_l': BodymapBucket.adductors,
    'calves_r': BodymapBucket.calves,
    'calves_l': BodymapBucket.calves,
    'feet_r': BodymapBucket.feet,
    'feet_l': BodymapBucket.feet,
    'neck': BodymapBucket.neck,
  };

  static const Map<String, BodymapBucket> backPathToBucket = {
    'traps': BodymapBucket.shoulders,
    'shoulders_r': BodymapBucket.shoulders,
    'shoulders_l': BodymapBucket.shoulders,
    'lats_r': BodymapBucket.back,
    'lats_l': BodymapBucket.back,
    'spine': BodymapBucket.back,
    'triceps_r': BodymapBucket.triceps,
    'triceps_l': BodymapBucket.triceps,
    'forearms_r': BodymapBucket.forearms,
    'forearms_l': BodymapBucket.forearms,
    'glutes_r': BodymapBucket.glutes,
    'glutes_l': BodymapBucket.glutes,
    'hamstrings_r': BodymapBucket.hamstrings,
    'hamstrings_l': BodymapBucket.hamstrings,
    'calves_r': BodymapBucket.calves,
    'calves_l': BodymapBucket.calves,
    'feet_r': BodymapBucket.feet,
    'feet_l': BodymapBucket.feet,
    'neck': BodymapBucket.neck,
  };

  static String assetPathForSide(BodymapViewSide side) {
    return switch (side) {
      BodymapViewSide.front => frontAssetPath,
      BodymapViewSide.back => backAssetPath,
    };
  }

  static Map<String, BodymapBucket> mappingForSide(BodymapViewSide side) {
    return switch (side) {
      BodymapViewSide.front => frontPathToBucket,
      BodymapViewSide.back => backPathToBucket,
    };
  }

  static Iterable<BodymapBucket> allBucketsForSide(BodymapViewSide side) {
    return mappingForSide(side).values.toSet();
  }
}
