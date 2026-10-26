import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/settings/application/settings_controller.dart';
import 'package:aedify/features/settings/domain/settings_edit_draft.dart';
import 'package:aedify/features/settings/presentation/widgets/settings_feature_status_tile.dart';
import 'package:aedify/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:aedify/features/settings/presentation/widgets/settings_storage_boundary_card.dart';
import 'package:aedify/shared/components/app_list_tile.dart';
import 'package:aedify/shared/components/app_toggle_pill.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/theme_mode_setting.dart';
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
        error: (_, _) => _ErrorView(
          message: AppErrorStrings.settingsLoadFailedMessage,
          onRetry: () => ref
              .read(AppProviders.settingsControllerProvider.notifier)
              .reload(),
        ),
        data: (state) {
          if (state.hasError && state.viewData == null) {
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
    required this.libraryVersion,
    required this.schemaVersion,
    required this.exerciseCount,
    required this.syncStatusLabel,
  });

  final SettingsState state;
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.errorMessage != null) ...[
            _ErrorBanner(message: state.errorMessage!),
            AppWhiteSpace.hMd,
          ],
          SettingsSectionCard(
            title: AppStrings.profile,
            children: [
              AppListTile(
                title: AppStrings.profileEdit,
                subtitle: AppStrings.localOnlyNotice,
                leadingAsset: OutlinedSvgAssets.user,
                showChevron: true,
                onTap: () => context.pushNamed(AppRoutes.profile().name),
              ),
            ],
          ),
          AppWhiteSpace.hMd,
          SettingsSectionCard(
            title: AppStrings.appSettings,
            children: [
              _SegmentedSetting<PreferredUnit>(
                title: AppStrings.preferredUnits,
                subtitle: draft.preferredUnits.displayLabel,
                leadingAsset: OutlinedSvgAssets.scale,
                selectedValue: draft.preferredUnits,
                options: PreferredUnit.values
                    .map(
                      (unit) => _SegmentOption(
                        value: unit,
                        label: unit.displayLabel,
                        key: ValueKey('settings-units-${unit.name}'),
                      ),
                    )
                    .toList(),
                onChanged: (unit) {
                  controller.updateDraft(draft.copyWith(preferredUnits: unit));
                },
              ),
              _SegmentedSetting<ThemeModeSetting>(
                title: AppStrings.themeMode,
                subtitle: draft.themeMode.displayLabel,
                leadingAsset: OutlinedSvgAssets.swatch,
                selectedValue: draft.themeMode,
                options: ThemeModeSetting.values
                    .map(
                      (mode) => _SegmentOption(
                        value: mode,
                        label: mode.displayLabel,
                        key: ValueKey('settings-theme-${mode.name}'),
                      ),
                    )
                    .toList(),
                onChanged: (mode) {
                  controller.updateDraft(draft.copyWith(themeMode: mode));
                },
              ),
            ],
          ),
          AppWhiteSpace.hMd,
          SettingsSectionCard(
            title: AppStrings.notifications,
            children: [
              _SettingsToggleTile(
                toggleKey: const ValueKey('settings-notifications-toggle'),
                icon: OutlinedSvgAssets.bell,
                label: AppStrings.notifications,
                value: draft.notificationsEnabled,
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(notificationsEnabled: value),
                  );
                },
              ),
              _SettingsToggleTile(
                toggleKey: const ValueKey('settings-timer-sound-toggle'),
                icon: OutlinedSvgAssets.speakerWave,
                label: AppStrings.workoutTimerSound,
                value: draft.workoutTimerSoundEnabled,
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(workoutTimerSoundEnabled: value),
                  );
                },
              ),
              _SettingsToggleTile(
                toggleKey: const ValueKey('settings-exercise-audio-toggle'),
                icon: OutlinedSvgAssets.microphone,
                label: AppStrings.exerciseAudio,
                value: draft.exerciseAudioEnabled,
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(exerciseAudioEnabled: value),
                  );
                },
              ),
            ],
          ),
          AppWhiteSpace.hMd,
          SettingsSectionCard(
            title: AppStrings.aiSettings,
            children: [
              AppListTile(
                title: AppStrings.byokSetup,
                subtitle: AppStrings.secureStorageNotice,
                leadingAsset: OutlinedSvgAssets.key,
                showChevron: true,
                onTap: () => context.pushNamed(AppRoutes.byokSettings().name),
              ),
            ],
          ),
          AppWhiteSpace.hMd,
          SettingsSectionCard(
            title: AppStrings.exerciseLibraryStatus,
            children: [
              AppListTile(
                title: AppStrings.exerciseLibraryVersion,
                subtitle: libraryVersion ?? AppStrings.loading,
                leadingAsset: OutlinedSvgAssets.bookOpen,
              ),
              AppListTile(
                title: AppStrings.exerciseLibrarySchemaVersion,
                subtitle: schemaVersion?.toString() ?? AppStrings.loading,
                leadingAsset: OutlinedSvgAssets.circleStack,
              ),
              AppListTile(
                title: AppStrings.exerciseLibraryExerciseCount,
                subtitle: exerciseCount?.toString() ?? AppStrings.loading,
                leadingAsset: OutlinedSvgAssets.listBullet,
              ),
              AppListTile(
                title: AppStrings.exerciseLibrarySyncStatus,
                subtitle: syncStatusLabel,
                leadingAsset: OutlinedSvgAssets.arrowPath,
              ),
            ],
          ),
          AppWhiteSpace.hMd,
          SettingsSectionCard(
            title: AppStrings.featureStatus,
            children: [
              if (state.viewData != null) ...[
                SettingsFeatureStatusTile(
                  label: AppStrings.aiTrainer,
                  enabled: state.viewData!.aiEnabled,
                  leadingAsset: OutlinedSvgAssets.sparkles,
                ),
                SettingsFeatureStatusTile(
                  label: AppStrings.import,
                  enabled: state.viewData!.importsEnabled,
                  leadingAsset: OutlinedSvgAssets.arrowDownTray,
                ),
                SettingsFeatureStatusTile(
                  label: AppStrings.sharing,
                  enabled: state.viewData!.sharingEnabled,
                  leadingAsset: OutlinedSvgAssets.share,
                ),
                SettingsFeatureStatusTile(
                  label: AppStrings.progressMedia,
                  enabled: state.viewData!.progressMediaEnabled,
                  leadingAsset: OutlinedSvgAssets.photo,
                ),
                SettingsFeatureStatusTile(
                  label: AppStrings.diagnostics,
                  enabled: state.viewData!.diagnosticsEnabled,
                  leadingAsset: OutlinedSvgAssets.bugAnt,
                ),
              ],
            ],
          ),
          AppWhiteSpace.hMd,
          SettingsSectionCard(
            title: AppStrings.privacyAndStorage,
            children: [
              const SettingsStorageBoundaryCard(showTitle: false),
              _SettingsToggleTile(
                toggleKey: const ValueKey('settings-diagnostics-toggle'),
                icon: OutlinedSvgAssets.bugAnt,
                label: AppStrings.crashDiagnostics,
                value: draft.crashlyticsEnabled,
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(crashlyticsEnabled: value),
                  );
                },
              ),
              _SettingsToggleTile(
                toggleKey: const ValueKey('settings-redaction-toggle'),
                icon: OutlinedSvgAssets.shieldCheck,
                label: AppStrings.strictRedaction,
                value: draft.redactionStrictMode,
                onChanged: (value) {
                  controller.updateDraft(
                    draft.copyWith(redactionStrictMode: value),
                  );
                },
              ),
              AppListTile(
                title: AppStrings.diagnostics,
                subtitle: state.viewData?.diagnosticsEnabled == true
                    ? AppStrings.enabled
                    : AppStrings.disabled,
                leadingAsset: OutlinedSvgAssets.codeBracket,
                showChevron: true,
                onTap: () => context.pushNamed(AppRoutes.diagnostics().name),
              ),
            ],
          ),
          AppWhiteSpace.hLg,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isSaving ? null : controller.save,
              child: state.isSaving
                  ? const SizedBox(
                      width: AppSizing.iconSm,
                      height: AppSizing.iconSm,
                      child: CircularProgressIndicator(
                        strokeWidth: AppSizing.strokeWidth,
                      ),
                    )
                  : const Text(AppStrings.saveSettings),
            ),
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
    return Container(
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
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.toggleKey,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final Key toggleKey;
  final String icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: label,
      subtitle: value ? AppStrings.enabled : AppStrings.disabled,
      leadingAsset: icon,
      trailing: AppTogglePill(
        key: toggleKey,
        value: value,
        semanticLabel: label,
        onChanged: onChanged,
      ),
    );
  }
}

class _SegmentedSetting<T> extends StatelessWidget {
  const _SegmentedSetting({
    required this.title,
    required this.subtitle,
    required this.leadingAsset,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final String leadingAsset;
  final T selectedValue;
  final List<_SegmentOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          AppListTile(
            title: title,
            subtitle: subtitle,
            leadingAsset: leadingAsset,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: _PillSegmentedControl<T>(
              selectedValue: selectedValue,
              options: options,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentOption<T> {
  const _SegmentOption({
    required this.value,
    required this.label,
    required this.key,
  });

  final T value;
  final String label;
  final Key key;
}

class _PillSegmentedControl<T> extends StatelessWidget {
  const _PillSegmentedControl({
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  final T selectedValue;
  final List<_SegmentOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: options.map((option) {
          final selected = option.value == selectedValue;
          final isDark = context.theme.brightness == Brightness.dark;
          final backgroundColor = isDark
              ? context.colorScheme.primaryContainer
              : context.colorScheme.secondaryContainer;
          final foregroundColor = isDark
              ? context.colorScheme.onPrimaryContainer
              : context.colorScheme.onSecondaryContainer;

          return Expanded(
            child: Semantics(
              key: option.key,
              button: true,
              selected: selected,
              label: option.label,
              child: Material(
                color: context.colorScheme.surface.withValues(alpha: 0),
                child: InkWell(
                  onTap: () => onChanged(option.value),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.buttonVertical,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? backgroundColor
                          : context.colorScheme.surface.withValues(alpha: 0),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      option.label,
                      style: AppTextStyles.labelMd.copyWith(
                        color: selected
                            ? foregroundColor
                            : context.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
