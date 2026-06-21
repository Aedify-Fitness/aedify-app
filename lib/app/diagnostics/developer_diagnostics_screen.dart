import 'package:aedify/app/bootstrap/app_bootstrap.dart';
import 'package:aedify/app/feature_flags/feature_flags.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeveloperDiagnosticsScreen extends ConsumerWidget {
  const DeveloperDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrapState = ref.watch(AppBootstrap.controllerProvider);
    final featureFlags = ref.watch(AppProviders.featureFlagsProvider);
    final database = ref.watch(AppProviders.appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.diagnostics)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.diagnosticsSummaryTitle,
              style: context.textTheme.headlineSmall,
            ),
            AppWhiteSpace.hMd,
            _DiagnosticRow(
              label: 'startup_phase',
              value: bootstrapState.phase.name,
            ),
            _DiagnosticRow(
              label: 'offline_mode',
              value: bootstrapState.isOffline.toString(),
            ),
            _DiagnosticRow(
              label: 'drift_schema_version',
              value: database.schemaVersion.toString(),
            ),
            _DiagnosticRow(
              label: 'non_sensitive_feature_flag',
              value: _featureFlagsSummary(featureFlags),
            ),
          ],
        ),
      ),
    );
  }

  String _featureFlagsSummary(FeatureFlags flags) {
    return [
      'ai=${flags.aiEnabled}',
      'imports=${flags.importsEnabled}',
      'sharing=${flags.sharingEnabled}',
      'progress=${flags.progressMediaEnabled}',
      'physique=${flags.physiqueAnalysisEnabled}',
      'crashlytics=${flags.crashlyticsEnabled}',
      'diagnostics=${flags.diagnosticsEnabled}',
    ].join(', ');
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text('$label: $value', style: context.textTheme.bodyMedium),
    );
  }
}
