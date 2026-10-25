import 'package:aedify/features/settings/domain/provider_capability_view_data.dart';
import 'package:aedify/features/settings/domain/provider_model_capabilities.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:dio/dio.dart';

class KeyValidationResult {
  const KeyValidationResult({required this.isValid, this.errorCode});

  final bool isValid;
  final String? errorCode;
}

/// Contains only an allowlisted code, never request or response contents.
class ProviderValidationFailure implements Exception {
  const ProviderValidationFailure(this.code);
  final String code;
  @override
  String toString() => 'ProviderValidationFailure($code)';
}

/// Uses metadata endpoints only; connection tests never send user content.
class ProviderKeyValidator {
  ProviderKeyValidator({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<KeyValidationResult> checkKey({
    required AiProviderName providerName,
    required String apiKey,
  }) async {
    try {
      final data = await _get(providerName, apiKey);
      final models =
          data[providerName == AiProviderName.google ? 'models' : 'data'];
      if (models is! List) {
        throw const ProviderValidationFailure(AppErrorCodes.validationFailed);
      }
      return const KeyValidationResult(isValid: true);
    } on ProviderValidationFailure catch (failure) {
      return KeyValidationResult(isValid: false, errorCode: failure.code);
    }
  }

  Future<ProviderCapabilityViewData> inspectModel({
    required AiProviderName providerName,
    required String apiKey,
    required String modelName,
  }) async {
    if (!ProviderModelCapabilities.isKnown(providerName, modelName)) {
      throw const ProviderValidationFailure(AppErrorCodes.unsupportedModel);
    }
    final data = await _get(providerName, apiKey, modelName: modelName);
    final returnedId =
        data[providerName == AiProviderName.google ? 'name' : 'id'];
    if (returnedId is! String ||
        !ProviderModelCapabilities.matchesModel(modelName, returnedId)) {
      throw const ProviderValidationFailure(AppErrorCodes.unsupportedModel);
    }
    return ProviderModelCapabilities.fromMetadata(
      providerName,
      modelName,
      data,
    );
  }

  Future<Map<String, dynamic>> _get(
    AiProviderName provider,
    String inputKey, {
    String? modelName,
  }) async {
    final key = inputKey.trim();
    if (key.isEmpty || key.contains('\n') || key.contains('\r')) {
      throw const ProviderValidationFailure(AppErrorCodes.invalidKey);
    }
    final (base, headers) = switch (provider) {
      AiProviderName.openai => (
        'https://api.openai.com/v1/models',
        {'Authorization': key.startsWith('Bearer ') ? key : 'Bearer $key'},
      ),
      AiProviderName.anthropic => (
        'https://api.anthropic.com/v1/models',
        {'x-api-key': key, 'anthropic-version': '2023-06-01'},
      ),
      AiProviderName.google => (
        'https://generativelanguage.googleapis.com/v1beta/models',
        {'x-goog-api-key': key},
      ),
      _ => throw const ProviderValidationFailure(
        AppErrorCodes.unsupportedProvider,
      ),
    };
    final url = modelName == null
        ? base
        : '$base/${Uri.encodeComponent(modelName)}';
    try {
      final response = await _dio
          .get<Object?>(
            url,
            options: Options(
              headers: headers,
              followRedirects: false,
              sendTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
              validateStatus: (_) => true,
            ),
          )
          .timeout(const Duration(seconds: 10));
      final status = response.statusCode;
      if (status == 401 || status == 403) {
        throw const ProviderValidationFailure(AppErrorCodes.invalidKey);
      }
      if (status == 404 && modelName != null) {
        throw const ProviderValidationFailure(AppErrorCodes.unsupportedModel);
      }
      if (status != 200 || response.data is! Map<String, dynamic>) {
        throw const ProviderValidationFailure(AppErrorCodes.validationFailed);
      }
      return response.data! as Map<String, dynamic>;
    } on ProviderValidationFailure {
      rethrow;
    } catch (_) {
      // Dio errors retain authorization headers and response bodies. Never
      // propagate or log them beyond this boundary.
      throw const ProviderValidationFailure(AppErrorCodes.validationFailed);
    }
  }
}
