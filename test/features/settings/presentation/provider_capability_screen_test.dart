import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/data/provider_capability_repository.dart';
import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/features/settings/presentation/provider_capability_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCapabilityRepository implements ProviderCapabilityRepository {
  const _FakeCapabilityRepository(this.capability);

  final ProviderCapabilityViewData? capability;

  @override
  Future<void> clearCapability({
    required AiProviderName providerName,
    required String modelName,
  }) async {}

  @override
  Future<ProviderCapabilityViewData?> getCapability({
    required AiProviderName providerName,
    required String modelName,
  }) async => capability;

  @override
  Future<void> saveCapability(ProviderCapabilityViewData capability) async {}
}

void main() {
  testWidgets('shows explicit available and unavailable capability states', (
    tester,
  ) async {
    final capability = ProviderCapabilityViewData(
      providerName: AiProviderName.openai,
      modelName: 'gpt-4o',
      supportsTextInput: true,
      supportsImageInput: false,
      supportsJsonSchemaMode: true,
      supportsStreaming: false,
      supportsToolCalling: true,
      maxContextTokens: 128000,
      maxOutputTokens: 4096,
      maxImagesPerRequest: 4,
      checkedAt: DateTime(2026, 7, 24, 10, 30),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AppProviders.providerCapabilityRepositoryProvider.overrideWith(
            (ref) => _FakeCapabilityRepository(capability),
          ),
        ],
        child: const MaterialApp(
          home: ProviderCapabilityScreen(
            providerName: 'openai',
            modelName: 'gpt-4o',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('provider-capability-text-input-available')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('provider-capability-image-input-unavailable')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('provider-capability-text-input')),
        matching: find.text(AppStrings.enabled),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('provider-capability-image-input')),
        matching: find.text(AppStrings.disabled),
      ),
      findsOneWidget,
    );
  });
}
