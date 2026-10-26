import 'package:aedify/features/settings/data/provider_key_validator.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/settings/provider_metadata_adapter.dart';

void main() {
  late ProviderMetadataAdapter adapter;
  late ProviderKeyValidator validator;
  setUp(() {
    adapter = ProviderMetadataAdapter();
    validator = ProviderKeyValidator(dio: adapter.client());
  });

  for (final provider in [
    AiProviderName.openai,
    AiProviderName.anthropic,
    AiProviderName.google,
  ]) {
    test(
      '$provider validates with the correct metadata endpoint and auth',
      () async {
        final result = await validator.checkKey(
          providerName: provider,
          apiKey: 'test-key',
        );
        expect(result.isValid, isTrue);
        final request = adapter.requests.single;
        expect(request.method, 'GET');
        expect(request.data, isNull);
        expect(request.queryParameters, isEmpty);
        expect(request.followRedirects, isFalse);
        switch (provider) {
          case AiProviderName.openai:
            expect(request.headers['Authorization'], 'Bearer test-key');
            expect(request.uri.toString(), 'https://api.openai.com/v1/models');
          case AiProviderName.anthropic:
            expect(request.headers['x-api-key'], 'test-key');
            expect(request.headers['anthropic-version'], '2023-06-01');
            expect(
              request.uri.toString(),
              'https://api.anthropic.com/v1/models',
            );
          case AiProviderName.google:
            expect(request.headers['x-goog-api-key'], 'test-key');
            expect(
              request.uri.toString(),
              'https://generativelanguage.googleapis.com/v1beta/models',
            );
          default:
            fail('Unexpected fixture provider');
        }
      },
    );
  }

  for (final status in [301, 401, 403, 404, 429, 500]) {
    test('HTTP $status is rejected without returning request data', () async {
      adapter.status = status;
      final result = await validator.checkKey(
        providerName: AiProviderName.openai,
        apiKey: 'test-key',
      );
      expect(result.isValid, isFalse);
      expect(result.errorCode, isNot(contains('test-key')));
    });
  }

  test('network failures produce a safe result', () async {
    adapter.failTransport = true;
    final result = await validator.checkKey(
      providerName: AiProviderName.google,
      apiKey: 'test-key',
    );
    expect(result.isValid, isFalse);
    expect(result.errorCode, 'validation_failed');
  });

  test(
    'unknown model never triggers a request or enables capabilities',
    () async {
      await expectLater(
        validator.inspectModel(
          providerName: AiProviderName.openai,
          apiKey: 'test-key',
          modelName: 'unknown',
        ),
        throwsA(isA<ProviderValidationFailure>()),
      );
      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'selected model availability is checked, not just a valid key',
    () async {
      adapter.status = 404;
      await expectLater(
        validator.inspectModel(
          providerName: AiProviderName.openai,
          apiKey: 'test-key',
          modelName: 'gpt-4o',
        ),
        throwsA(isA<ProviderValidationFailure>()),
      );
      expect(adapter.requests.single.uri.path, '/v1/models/gpt-4o');
    },
  );

  test('malformed metadata cannot validate a key', () async {
    adapter.responseOverride = {};
    expect(
      (await validator.checkKey(
        providerName: AiProviderName.openai,
        apiKey: 'test-key',
      )).isValid,
      isFalse,
    );
  });

  test('model identity mismatch fails closed', () async {
    adapter.responseOverride = {'id': 'other-model'};
    await expectLater(
      validator.inspectModel(
        providerName: AiProviderName.openai,
        apiKey: 'test-key',
        modelName: 'gpt-4o',
      ),
      throwsA(isA<ProviderValidationFailure>()),
    );
  });

  test(
    'provider-reported unsupported image/schema capabilities are respected',
    () async {
      adapter.responseOverride = {
        'id': 'claude-sonnet-4-6',
        'capabilities': {
          'image_input': {'supported': false},
          'structured_outputs': {'supported': false},
        },
      };
      final result = await validator.inspectModel(
        providerName: AiProviderName.anthropic,
        apiKey: 'test-key',
        modelName: 'claude-sonnet-4-6',
      );
      expect(result.supportsImageInput, isFalse);
      expect(result.supportsJsonSchemaMode, isFalse);
    },
  );

  test('Google model without generateContent remains disabled', () async {
    adapter.responseOverride = {
      'name': 'models/gemini-2.5-pro',
      'supportedGenerationMethods': ['embedContent'],
    };
    final result = await validator.inspectModel(
      providerName: AiProviderName.google,
      apiKey: 'test-key',
      modelName: 'gemini-2.5-pro',
    );
    expect(result.supportsTextInput, isFalse);
    expect(result.supportsImageInput, isFalse);
    expect(result.supportsJsonSchemaMode, isFalse);
  });
}
