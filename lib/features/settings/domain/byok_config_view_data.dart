class ByokConfigViewData {
  const ByokConfigViewData({
    required this.id,
    required this.providerName,
    required this.displayName,
    required this.selectedModel,
    required this.hasKey,
    required this.isActive,
    required this.lastValidationStatus,
    required this.lastErrorCode,
  });

  final String id;
  final String providerName;
  final String? displayName;
  final String? selectedModel;
  final bool hasKey;
  final bool isActive;
  final String? lastValidationStatus;
  final String? lastErrorCode;
}
