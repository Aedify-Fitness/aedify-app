import 'package:dio/dio.dart';

class KeyValidationResult {
  const KeyValidationResult({required this.isValid, this.errorCode});

  final bool isValid;
  final String? errorCode;
}

class ProviderKeyValidator {
  ProviderKeyValidator._();

  static Future<KeyValidationResult> validate({
    required String providerName,
    required String apiKey,
  }) async {
    final endpoint = _endpointFor(providerName);
    if (endpoint == null) {
      return const KeyValidationResult(
        isValid: false,
        errorCode: 'unsupported_provider',
      );
    }

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
      ),
    );

    try {
      await dio.get(
        endpoint.url,
        options: Options(
          headers: {
            endpoint.authHeader: apiKey.startsWith('Bearer ')
                ? apiKey
                : 'Bearer $apiKey',
          },
        ),
      );
      return const KeyValidationResult(isValid: true);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return KeyValidationResult(isValid: false, errorCode: 'invalid_key');
      }
      if (statusCode == 200 || statusCode == 201 || statusCode == 202) {
        return const KeyValidationResult(isValid: true);
      }
      return KeyValidationResult(
        isValid: false,
        errorCode: 'validation_failed',
      );
    }
  }

  static _ValidationEndpoint? _endpointFor(String provider) {
    switch (provider) {
      case 'openai':
        return const _ValidationEndpoint(
          url: 'https://api.openai.com/v1/models',
          authHeader: 'Authorization',
        );
      case 'anthropic':
        return const _ValidationEndpoint(
          url: 'https://api.anthropic.com/v1/messages',
          authHeader: 'x-api-key',
        );
      case 'google':
        return const _ValidationEndpoint(
          url: 'https://generativelanguage.googleapis.com/v1/models',
          authHeader: 'x-goog-api-key',
        );
      default:
        return null;
    }
  }
}

class _ValidationEndpoint {
  const _ValidationEndpoint({required this.url, required this.authHeader});

  final String url;
  final String authHeader;
}
