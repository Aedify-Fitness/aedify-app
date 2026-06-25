import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_dataset_status_tile.dart';
import 'package:aedify/features/settings/application/settings_controller.dart';
import 'package:aedify/features/settings/domain/settings_edit_draft.dart';
import 'package:aedify/features/settings/presentation/widgets/settings_feature_status_tile.dart';
import 'package:aedify/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:aedify/features/settings/presentation/widgets/settings_storage_boundary_card.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/theme_mode_setting.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(AppProviders.settingsControllerProvider);
    final syncState = ref.watch(
      AppProviders.exerciseDatasetSyncControllerProvider,
    );

    final libraryVersion = syncState.whenOrNull(
      data: (state) => state.libraryVersion,
    );
    final schemaVersion = syncState.whenOrNull(
      data: (state) => state.schemaVersion,
    );
    final exerciseCount = syncState.whenOrNull(
      data: (state) => state.exerciseCount,
    );
    final syncStatusLabel = syncState.when(
      loading: () => AppStrings.exerciseLibrarySyncing,
      error: (_, _) => AppStrings.exerciseLibrarySyncFailedLabel,
      data: (state) {
        if (state.isSynced) return AppStrings.exerciseLibrarySynced;
        if (state.needsInitialSync) {
          return AppStrings.exerciseLibraryNeverSynced;
        }
        if (state.hasFailure) return AppStrings.exerciseLibrarySyncFailedLabel;
        return AppStrings.exerciseLibrarySyncing;
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _ErrorView(
          message: AppErrorStrings.settingsLoadFailedMessage,
          onRetry: () => ref
              .read(AppProviders.settingsControllerProvider.notifier)
              .reload(),
        ),
        data: (state) {
          if (state.hasError) {
            return _ErrorView(
              message:
                  state.errorMessage ??
                  AppErrorStrings.settingsLoadFailedMessage,
              onRetry: () => ref
                  .read(AppProviders.settingsControllerProvider.notifier)
                  .reload(),
            );
          }
          return _SettingsContentView(
            state: state,
            ref: ref,
            libraryVersion: libraryVersion,
            schemaVersion: schemaVersion,
            exerciseCount: exerciseCount,
            syncStatusLabel: syncStatusLabel,
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSpacing.xxl,
              height: AppSpacing.xxl,
              colorFilter: ColorFilter.mode(
                context.colorScheme.error,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.hMd,
            Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hLg,
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsContentView extends ConsumerWidget {
  const _SettingsContentView({
    required this.state,
    required this.ref,
    required this.libraryVersion,
    required this.schemaVersion,
    required this.exerciseCount,
    required this.syncStatusLabel,
  });

  final SettingsState state;
  final WidgetRef ref;
  final String? libraryVersion;
  final int? schemaVersion;
  final int? exerciseCount;
  final String syncStatusLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      AppProviders.settingsControllerProvider.notifier,
    );
    final draft = state.editDraft ?? const SettingsEditDraft();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.errorMessage != null)
            _ErrorBanner(message: state.errorMessage!),

          // Profile
          _NavTile(
            icon: OutlinedSvgAssets.user,
            title: AppStrings.profile,
            onTap: () => context.pushNamed(AppRoutes.profile().name),
          ),
          AppWhiteSpace.hMd,

          // Exercise library status
          ExerciseDatasetStatusTile(
            libraryVersion: libraryVersion,
            schemaVersion: schemaVersion,
            exerciseCount: exerciseCount,
            syncStatusLabel: syncStatusLabel,
          ),
          AppWhiteSpace.hMd,

          // App settings
          SettingsSectionCard(
            title: AppStrings.appSettings,
            children: [
              _SettingsDropdownTile(
                label: AppStrings.preferredUnits,
                value: draft.preferredUnits.dbValue,
                options: PreferredUnit.values.map((e) => e.name).toList(),
                optionLabels: PreferredUnit.values
                    .map((e) => e.displayLabel)
                    .toList(),
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(preferredUnits: PreferredUnit.fromDb(value)),
                  );
                },
              ),
              _SettingsDropdownTile(
                label: AppStrings.themeMode,
                value: draft.themeMode.dbValue ?? draft.themeMode.name,
                options: ThemeModeSetting.values.map((e) => e.name).toList(),
                optionLabels: ThemeModeSetting.values
                    .map((e) => e.displayLabel)
                    .toList(),
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(themeMode: ThemeModeSetting.fromDb(value)),
                  );
                },
              ),
              _SettingsSwitchTile(
                label: AppStrings.notifications,
                value: draft.notificationsEnabled,
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(notificationsEnabled: value),
                  );
                },
              ),
              _SettingsSwitchTile(
                label: AppStrings.workoutTimerSound,
                value: draft.workoutTimerSoundEnabled,
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(workoutTimerSoundEnabled: value),
                  );
                },
              ),
              _SettingsSwitchTile(
                label: AppStrings.exerciseAudio,
                value: draft.exerciseAudioEnabled,
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(exerciseAudioEnabled: value),
                  );
                },
              ),
              _SettingsSwitchTile(
                label: AppStrings.crashDiagnostics,
                value: draft.crashlyticsEnabled,
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(crashlyticsEnabled: value),
                  );
                },
              ),
              _SettingsSwitchTile(
                label: AppStrings.strictRedaction,
                value: draft.redactionStrictMode,
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(redactionStrictMode: value),
                  );
                },
              ),
              AppWhiteSpace.hMd,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isSaving ? null : controller.save,
                  child: state.isSaving
                      ? const SizedBox(
                          width: AppSizing.iconSm,
                          height: AppSizing.iconSm,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(AppStrings.saveSettings),
                ),
              ),
            ],
          ),
          AppWhiteSpace.hMd,

          // AI setup entry
          _NavTile(
            icon: OutlinedSvgAssets.sparkles,
            title: AppStrings.byokSetup,
            subtitle: AppStrings.aiSettings,
            onTap: () => context.pushNamed(AppRoutes.aiProviderSettings().name),
          ),
          AppWhiteSpace.hMd,

          // Feature status
          SettingsSectionCard(
            title: AppStrings.featureStatus,
            children: [
              if (state.viewData != null) ...[
                SettingsFeatureStatusTile(
                  label: AppStrings.aiTrainer,
                  enabled: state.viewData!.aiEnabled,
                ),
                SettingsFeatureStatusTile(
                  label: AppStrings.import,
                  enabled: state.viewData!.importsEnabled,
                ),
                SettingsFeatureStatusTile(
                  label: AppStrings.sharing,
                  enabled: state.viewData!.sharingEnabled,
                ),
                SettingsFeatureStatusTile(
                  label: AppStrings.progressMedia,
                  enabled: state.viewData!.progressMediaEnabled,
                ),
                SettingsFeatureStatusTile(
                  label: AppStrings.diagnostics,
                  enabled: state.viewData!.diagnosticsEnabled,
                ),
              ],
            ],
          ),
          AppWhiteSpace.hMd,

          // Privacy and storage
          const SettingsStorageBoundaryCard(),
          AppWhiteSpace.hMd,

          // Diagnostics entry
          _NavTile(
            icon: OutlinedSvgAssets.codeBracket,
            title: AppStrings.diagnostics,
            onTap: () => context.pushNamed(AppRoutes.diagnostics().name),
          ),
          AppWhiteSpace.hXl,
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onErrorContainer,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: AppSizing.divider,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    AppWhiteSpace.hXs,
                    Text(
                      subtitle!,
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SvgPicture.asset(
              OutlinedSvgAssets.chevronRight,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsDropdownTile extends StatelessWidget {
  const _SettingsDropdownTile({
    required this.label,
    required this.value,
    required this.options,
    required this.optionLabels,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final List<String> optionLabels;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          DropdownButton<String>(
            value: options.contains(value) ? value : options.first,
            underline: const SizedBox(),
            items: List.generate(options.length, (i) {
              return DropdownMenuItem(
                value: options[i],
                child: Text(optionLabels[i]),
              );
            }),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
