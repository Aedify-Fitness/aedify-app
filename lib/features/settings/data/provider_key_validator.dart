import 'package:aedify/core/logging/app_logger.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:dio/dio.dart';

class KeyValidationResult {
  const KeyValidationResult({required this.isValid, this.errorCode});

  final bool isValid;
  final String? errorCode;
}

class ProviderKeyValidator {
  ProviderKeyValidator._();

  static final _logger = AppLogger(name: 'ProviderKeyValidator');

  static Future<KeyValidationResult> validate({
    required AiProviderName providerName,
    required String apiKey,
  }) async {
    _logger.info('validate — provider: ${providerName.name}');
    final endpoint = _endpointFor(providerName);
    if (endpoint == null) {
      _logger.info('validate — provider unsupported: ${providerName.name}');
      return const KeyValidationResult(
        isValid: false,
        errorCode: AppErrorCodes.unsupportedProvider,
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
      _logger.info('validate — valid: ${providerName.name}');
      return const KeyValidationResult(isValid: true);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        _logger.info('validate — invalid key: ${providerName.name}');
        return KeyValidationResult(
          isValid: false,
          errorCode: AppErrorCodes.invalidKey,
        );
      }
      if (statusCode == 200 || statusCode == 201 || statusCode == 202) {
        _logger.info('validate — valid: ${providerName.name}');
        return const KeyValidationResult(isValid: true);
      }
      _logger.error('validate — failed: ${providerName.name}', error: e);
      return KeyValidationResult(
        isValid: false,
        errorCode: AppErrorCodes.validationFailed,
      );
    }
  }

  static _ValidationEndpoint? _endpointFor(AiProviderName provider) {
    switch (provider) {
      case AiProviderName.openai:
        return const _ValidationEndpoint(
          url: 'https://api.openai.com/v1/models',
          authHeader: 'Authorization',
        );
      case AiProviderName.anthropic:
        return const _ValidationEndpoint(
          url: 'https://api.anthropic.com/v1/messages',
          authHeader: 'x-api-key',
        );
      case AiProviderName.google:
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
