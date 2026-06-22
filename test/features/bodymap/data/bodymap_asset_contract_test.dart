import 'package:aedify/features/bodymap/data/bodymap_asset_contract.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/bodymap/domain/bodymap_view_side.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BodymapAssetContract', () {
    test('front asset path is defined', () {
      expect(
        BodymapAssetContract.frontAssetPath,
        'assets/svgs/bodymap/front.svg',
      );
    });

    test('back asset path is defined', () {
      expect(
        BodymapAssetContract.backAssetPath,
        'assets/svgs/bodymap/back.svg',
      );
    });

    test('front mapping only uses approved buckets', () {
      for (final bucket in BodymapAssetContract.frontPathToBucket.values) {
        expect(BodymapBucket.values, contains(bucket));
      }
    });

    test('back mapping only uses approved buckets', () {
      for (final bucket in BodymapAssetContract.backPathToBucket.values) {
        expect(BodymapBucket.values, contains(bucket));
      }
    });

    test('all mapped buckets are valid 14-bucket values', () {
      final allMapped = {
        ...BodymapAssetContract.frontPathToBucket.values,
        ...BodymapAssetContract.backPathToBucket.values,
      };
      for (final bucket in allMapped) {
        expect(BodymapBucket.values, contains(bucket));
      }
      expect(allMapped.length, equals(BodymapBucket.values.length));
    });

    test('no duplicate path ids within front mapping', () {
      final paths = BodymapAssetContract.frontPathToBucket.keys.toList();
      expect(paths.toSet().length, equals(paths.length));
    });

    test('no duplicate path ids within back mapping', () {
      final paths = BodymapAssetContract.backPathToBucket.keys.toList();
      expect(paths.toSet().length, equals(paths.length));
    });

    test('assetPathForSide returns correct paths', () {
      expect(
        BodymapAssetContract.assetPathForSide(BodymapViewSide.front),
        equals(BodymapAssetContract.frontAssetPath),
      );
      expect(
        BodymapAssetContract.assetPathForSide(BodymapViewSide.back),
        equals(BodymapAssetContract.backAssetPath),
      );
    });

    test('allBucketsForSide returns unique buckets per side', () {
      final frontBuckets = BodymapAssetContract.allBucketsForSide(
        BodymapViewSide.front,
      );
      final backBuckets = BodymapAssetContract.allBucketsForSide(
        BodymapViewSide.back,
      );
      expect(frontBuckets.isNotEmpty, isTrue);
      expect(backBuckets.isNotEmpty, isTrue);
    });
  });
}
