import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_photo_draft.dart';
import 'package:aedify/features/progress_media/presentation/progress_photo_components.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_button_styles.dart';
import 'package:aedify/shared/theme/app_durations.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProgressMediaScreen extends ConsumerStatefulWidget {
  const ProgressMediaScreen({super.key});
  @override
  ConsumerState<ProgressMediaScreen> createState() =>
      _ProgressMediaScreenState();
}

class _ProgressMediaScreenState extends ConsumerState<ProgressMediaScreen> {
  bool _allowPop = false;
  final _notes = TextEditingController();
  final _weight = TextEditingController();
  final _errorRegion = GlobalKey();
  @override
  void dispose() {
    _notes.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _choose(ProgressMediaPose pose, {bool recovered = false}) async {
    final source = await ProgressPhotoSourceSheet.show(
      context,
      recovered: recovered,
    );
    if (!mounted || source == null) return;
    final controller = ref.read(
      ProgressPhotoProviders.controllerProvider.notifier,
    );
    if (recovered) {
      controller.assignRecovered(pose, source);
    } else {
      await controller.pick(pose, source);
      await _revealFailure();
    }
  }

  Future<void> _revealFailure() async {
    if (!mounted ||
        ref
                .read(ProgressPhotoProviders.controllerProvider)
                .asData
                ?.value
                .failure ==
            null) {
      return;
    }
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final target = _errorRegion.currentContext;
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(
        target,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppDurations.formFocus,
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final saved = await ref
        .read(ProgressPhotoProviders.controllerProvider.notifier)
        .save();
    if (!saved) await _revealFailure();
  }

  Future<void> _leave() async {
    final value = ref
        .read(ProgressPhotoProviders.controllerProvider)
        .asData
        ?.value;
    if (value?.busy ?? false) return;
    if (value != null && value.dirty && !value.saved) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(AppStrings.progressPhotoDiscard),
          content: const Text(AppStrings.progressPhotoDiscardHint),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text(AppStrings.discardChanges),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
      if (!await ref
          .read(ProgressPhotoProviders.controllerProvider.notifier)
          .discard()) {
        await _revealFailure();
        return;
      }
    }
    if (!mounted) return;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.home().name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(ProgressPhotoProviders.controllerProvider);
    final value = data.asData?.value;
    final busy = value?.busy ?? false;
    return PopScope(
      canPop:
          _allowPop ||
          (!busy && (!(value?.dirty ?? false) || (value?.saved ?? false))),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.progressPhotoTitle),
          leading: IconButton(
            onPressed: busy ? null : _leave,
            tooltip: AppStrings.backLabel,
            icon: const ProgressPhotoIcon(OutlinedSvgAssets.arrowLeft),
          ),
        ),
        body: SafeArea(
          top: false,
          child: data.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(AppErrorStrings.progressMediaUnavailable),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(ProgressPhotoProviders.unitsProvider);
                        ref.invalidate(
                          ProgressPhotoProviders.controllerProvider,
                        );
                      },
                      child: const Text(AppStrings.retry),
                    ),
                  ],
                ),
              ),
            ),
            data: (state) => state.saved
                ? _ProgressPhotoSaved(onDone: _leave)
                : _form(state),
          ),
        ),
      ),
    );
  }

  Widget _form(ProgressPhotoState state) {
    final controller = ref.read(
      ProgressPhotoProviders.controllerProvider.notifier,
    );
    final dark = context.theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      key: const ValueKey('photo_form_scroll'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppProgressPhotoTokens.maxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.progressPhotoIntroduction,
                style: dark
                    ? AppTextStylesDark.headlineLgMobile
                    : AppTextStyles.headlineLgMobile,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.progressPhotoDescription,
                style: dark ? AppTextStylesDark.bodyMd : AppTextStyles.bodyMd,
              ),
              const SizedBox(height: AppSpacing.lg),
              const ProgressPhotoPanel(
                child: Text(AppStrings.progressPhotoGuidance),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.progressPhotoCount(state.photos.length),
                style: dark ? AppTextStylesDark.labelMd : AppTextStyles.labelMd,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (state.busy)
                const LinearProgressIndicator(
                  semanticsLabel: AppStrings.progressPhotoWorking,
                ),
              if (state.failure != null)
                Padding(
                  key: _errorRegion,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      state.failure!.message,
                      key: const ValueKey('photo_error'),
                      style: AppTextStyles.bodyMd.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              if (state.cancelled)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(AppStrings.progressPhotoCancelled),
                ),
              if (state.recovered != null)
                ProgressPhotoPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        AppStrings.progressPhotoRecovered,
                        style: AppTextStyles.headlineMd,
                      ),
                      const Text(AppStrings.progressPhotoRecoveredHint),
                      Image.memory(
                        state.recovered!.preview,
                        height: AppProgressPhotoTokens.recoveryPreviewHeight,
                        fit: BoxFit.contain,
                      ),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          for (final pose in ProgressPhotoLabels.poses)
                            TextButton(
                              onPressed: state.busy
                                  ? null
                                  : () => _choose(pose, recovered: true),
                              child: Text(ProgressPhotoLabels.pose(pose)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth >=
                              AppProgressPhotoTokens.twoColumnsMinWidth &&
                          MediaQuery.textScalerOf(
                                    context,
                                  ).scale(AppFontSizes.md) /
                                  AppFontSizes.md <
                              AppProgressPhotoTokens.singleColumnTextScale
                      ? 2
                      : 1;
                  final width =
                      (constraints.maxWidth - AppSpacing.md * (columns - 1)) /
                      columns;
                  return Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.lg,
                    children: [
                      for (final pose in ProgressPhotoLabels.poses)
                        SizedBox(
                          width: width,
                          child: ProgressPhotoSlot(
                            pose: pose,
                            photo: state.photos[pose],
                            busy: state.busy,
                            onChoose: () => _choose(pose),
                            onRemove: () => controller.remove(pose),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(AppStrings.progressPhotoPartialHint),
              const SizedBox(height: AppSpacing.xl),
              ProgressPhotoPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      AppStrings.progressPhotoDetails,
                      style: AppTextStyles.headlineMd,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      key: const ValueKey('photo_bodyweight'),
                      controller: _weight,
                      enabled: !state.busy,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: AppStrings.progressPhotoWeight(
                          state.units.weightUnit,
                        ),
                        hintText: AppStrings.customExerciseInstructionsOptional,
                      ),
                      onChanged: (value) =>
                          controller.updateFields(bodyweight: value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      key: const ValueKey('photo_notes'),
                      controller: _notes,
                      enabled: !state.busy,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: AppStrings.notes,
                        hintText: AppStrings.customExerciseInstructionsOptional,
                      ),
                      onChanged: (value) =>
                          controller.updateFields(notes: value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                key: const ValueKey('photo_save'),
                style: AppButtonStyles.primary(
                  context,
                  minimumHeight: AppProgressPhotoTokens.controlSize,
                ),
                onPressed: state.canSave ? _save : null,
                child: Text(
                  state.busy
                      ? AppStrings.progressPhotoWorking
                      : AppStrings.progressPhotoSave,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                AppStrings.progressPhotoBaselineHint,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressPhotoSaved extends StatelessWidget {
  const _ProgressPhotoSaved({required this.onDone});
  final VoidCallback onDone;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ProgressPhotoIcon(OutlinedSvgAssets.checkCircle),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            AppStrings.progressPhotoSaved,
            style: AppTextStyles.headlineMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            AppStrings.progressPhotoSavedHint,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: onDone,
            style: AppButtonStyles.primary(
              context,
              minimumHeight: AppProgressPhotoTokens.controlSize,
            ),
            child: const Text(AppStrings.done),
          ),
        ],
      ),
    ),
  );
}
