class FeatureFlags {
  final bool aiEnabled;
  final bool importsEnabled;
  final bool sharingEnabled;
  final bool progressMediaEnabled;
  final bool physiqueAnalysisEnabled;
  final bool crashlyticsEnabled;
  final bool diagnosticsEnabled;

  const FeatureFlags({
    this.aiEnabled = true,
    this.importsEnabled = true,
    this.sharingEnabled = true,
    this.progressMediaEnabled = true,
    this.physiqueAnalysisEnabled = true,
    this.crashlyticsEnabled = true,
    this.diagnosticsEnabled = false,
  });

  static const FeatureFlags defaultFlags = FeatureFlags();
  static const FeatureFlags allDisabled = FeatureFlags(
    aiEnabled: false,
    importsEnabled: false,
    sharingEnabled: false,
    progressMediaEnabled: false,
    physiqueAnalysisEnabled: false,
    crashlyticsEnabled: false,
    diagnosticsEnabled: false,
  );
}
