class ProviderCapabilityViewData {
  const ProviderCapabilityViewData({
    required this.providerName,
    required this.modelName,
    required this.supportsTextInput,
    required this.supportsImageInput,
    required this.supportsJsonSchemaMode,
    required this.supportsStreaming,
    this.supportsToolCalling,
    required this.maxContextTokens,
    required this.maxOutputTokens,
    required this.maxImagesPerRequest,
    required this.checkedAt,
  });

  final String providerName;
  final String modelName;
  final bool supportsTextInput;
  final bool supportsImageInput;
  final bool supportsJsonSchemaMode;
  final bool supportsStreaming;
  final bool? supportsToolCalling;
  final int? maxContextTokens;
  final int? maxOutputTokens;
  final int? maxImagesPerRequest;
  final DateTime checkedAt;
}
