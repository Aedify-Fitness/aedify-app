class ByokEditDraft {
  const ByokEditDraft({
    this.configId,
    this.providerName,
    this.selectedModel,
    this.apiKey,
    this.makeActive = true,
  });

  final String? configId;
  final String? providerName;
  final String? selectedModel;
  final String? apiKey;
  final bool makeActive;

  ByokEditDraft copyWith({
    String? configId,
    String? providerName,
    String? selectedModel,
    String? apiKey,
    bool? makeActive,
    bool clearConfigId = false,
    bool clearProviderName = false,
    bool clearSelectedModel = false,
    bool clearApiKey = false,
  }) {
    return ByokEditDraft(
      configId: clearConfigId ? null : (configId ?? this.configId),
      providerName: clearProviderName
          ? null
          : (providerName ?? this.providerName),
      selectedModel: clearSelectedModel
          ? null
          : (selectedModel ?? this.selectedModel),
      apiKey: clearApiKey ? null : (apiKey ?? this.apiKey),
      makeActive: makeActive ?? this.makeActive,
    );
  }
}
