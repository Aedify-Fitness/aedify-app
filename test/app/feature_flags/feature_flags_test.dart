import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('FeatureFlags', () {
    test('private-release defaults disable diagnostics only', () {
      expect(FeatureFlags.defaultFlags.aiEnabled, isTrue);
      expect(FeatureFlags.defaultFlags.importsEnabled, isTrue);
      expect(FeatureFlags.defaultFlags.sharingEnabled, isTrue);
      expect(FeatureFlags.defaultFlags.progressMediaEnabled, isTrue);
      expect(FeatureFlags.defaultFlags.physiqueAnalysisEnabled, isTrue);
      expect(FeatureFlags.defaultFlags.crashlyticsEnabled, isTrue);
      expect(FeatureFlags.defaultFlags.diagnosticsEnabled, isFalse);
    });

    test('crashlyticsServiceProvider obeys crashlyticsEnabled flag', () {
      final container = ProviderContainer(
        overrides: [
          AppProviders.featureFlagsProvider.overrideWithValue(
            const FeatureFlags(crashlyticsEnabled: false),
          ),
        ],
      );
      addTearDown(container.dispose);

      final service = container.read(AppProviders.crashlyticsServiceProvider);
      expect(service.enabled, isFalse);
    });
  });
}
