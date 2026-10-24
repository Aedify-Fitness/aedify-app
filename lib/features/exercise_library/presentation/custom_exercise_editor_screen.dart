import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/custom_exercise_editor_controller.dart';
import 'package:aedify/features/exercise_library/application/custom_exercise_editor_phase.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_editor_mode.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_editor_style.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_equipment_difficulty_section.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_error_banner.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_instructions_section.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_logging_type_picker.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_modality_section.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_muscle_group_picker.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_name_field.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/delete_custom_exercise_dialog.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/discard_custom_exercise_changes_dialog.dart';
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

/// Defines a local exercise while keeping editing and persistence separate.
class CustomExerciseEditorScreen extends ConsumerStatefulWidget {
  const CustomExerciseEditorScreen.create({super.key})
    : mode = CustomExerciseEditorMode.create,
      exerciseId = null;

  const CustomExerciseEditorScreen.edit({super.key, required this.exerciseId})
    : mode = CustomExerciseEditorMode.edit;

  final CustomExerciseEditorMode mode;
  final int? exerciseId;

  @override
  ConsumerState<CustomExerciseEditorScreen> createState() =>
      _CustomExerciseEditorScreenState();
}

class _CustomExerciseEditorScreenState
    extends ConsumerState<CustomExerciseEditorScreen> {
  final _scrollController = ScrollController();
  bool _confirming = false;
  bool _leaving = false;

  CustomExerciseEditorArgs get _args =>
      (mode: widget.mode, exerciseId: widget.exerciseId);

  CustomExerciseEditorController get _controller => ref.read(
    AppProviders.customExerciseEditorControllerProvider(_args).notifier,
  );

  void _close({bool? result}) {
    if (_leaving || !mounted) return;
    _leaving = true;
    FocusManager.instance.primaryFocus?.unfocus();
    final provider = AppProviders.customExerciseEditorControllerProvider(_args);
    if (context.canPop()) {
      context.pop(result);
    } else {
      context.goNamed(AppRoutes.exercises().name);
    }
    ref.invalidate(provider);
  }

  Future<void> _requestClose() async {
    if (_confirming || _leaving) return;
    final state = ref
        .read(AppProviders.customExerciseEditorControllerProvider(_args))
        .asData
        ?.value;
    if (state?.isSaving ?? false) return;
    if (state?.isDirty != true) {
      _close(
        result: state?.phase == CustomExerciseEditorPhase.saved ? true : null,
      );
      return;
    }
    _confirming = true;
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      final discard = await showDialog<bool>(
        context: context,
        builder: (_) => DiscardCustomExerciseChangesDialog(
          onDiscard: _controller.discardChanges,
        ),
      );
      if (discard == true && mounted) _close();
    } finally {
      _confirming = false;
    }
  }

  Future<void> _confirmDelete() async {
    if (_confirming || _leaving) return;
    final state = ref
        .read(AppProviders.customExerciseEditorControllerProvider(_args))
        .asData
        ?.value;
    if (state == null || state.isSaving) return;
    _confirming = true;
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      await showDialog<void>(
        context: context,
        builder: (_) =>
            DeleteCustomExerciseDialog(onConfirm: () => _controller.delete()),
      );
    } finally {
      _confirming = false;
    }
  }

  void _save() {
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.save();
  }

  void _revealErrors() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final duration = CustomExerciseEditorStyle.motionDuration(context);
      if (duration == Duration.zero) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.animateTo(
          0,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = AppProviders.customExerciseEditorControllerProvider(_args);
    ref.listen(provider, (previous, next) {
      final state = next.asData?.value;
      if (state == null) return;
      if (state.phase == CustomExerciseEditorPhase.deleted) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _close(result: true),
        );
      } else if ((state.hasValidationErrors &&
              !identical(
                previous?.asData?.value.validationErrors,
                state.validationErrors,
              )) ||
          (state.phase == CustomExerciseEditorPhase.failure &&
              previous?.asData?.value.phase !=
                  CustomExerciseEditorPhase.failure)) {
        _revealErrors();
      }
    });
    final asyncState = ref.watch(provider);
    final state = asyncState.asData?.value;
    final busy = state?.isSaving ?? false;
    final saved = state?.phase == CustomExerciseEditorPhase.saved;
    final deleted = state?.phase == CustomExerciseEditorPhase.deleted;
    final showForm = state != null && !saved && !deleted && !state.isLoading;

    return PopScope(
      canPop: !busy && (state?.isDirty != true),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          if (!_leaving) {
            _leaving = true;
            ref.invalidate(provider);
          }
        } else {
          _requestClose();
        }
      },
      child: Scaffold(
        key: const Key('custom_exercise_editor_screen'),
        backgroundColor: context.colorScheme.surface,
        bottomNavigationBar: showForm
            ? Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: _EditorActions(
                  mode: widget.mode,
                  isSaving: busy,
                  onSave: _save,
                  onDiscard: _requestClose,
                ),
              )
            : null,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppCustomExerciseEditorTokens.maxContentWidth,
              ),
              child: Column(
                children: [
                  _EditorHeader(
                    onBack: busy ? null : _requestClose,
                    showDelete:
                        widget.mode == CustomExerciseEditorMode.edit &&
                        showForm,
                    onDelete: busy ? null : _confirmDelete,
                  ),
                  Expanded(
                    child: asyncState.when(
                      loading: () => const _EditorLoading(),
                      error: (_, _) => _EditorMessage(
                        message: AppStrings.customExerciseLoadFailed,
                        onAction: () => ref.invalidate(provider),
                        actionLabel: AppStrings.retry,
                      ),
                      data: (state) {
                        if (state.isLoading || deleted) {
                          return const _EditorLoading();
                        }
                        if (saved) {
                          return _EditorMessage(
                            message: AppStrings.customExerciseSaved,
                            icon: OutlinedSvgAssets.checkBadge,
                            onAction: () => _close(result: true),
                            actionLabel: AppStrings.done,
                          );
                        }
                        return SingleChildScrollView(
                          key: const Key('custom_exercise_editor_scroll'),
                          controller: _scrollController,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                          child: AbsorbPointer(
                            absorbing: busy,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.phase ==
                                        CustomExerciseEditorPhase.failure &&
                                    state.errorMessage != null) ...[
                                  CustomExerciseErrorBanner(
                                    message: state.errorMessage!,
                                    onRetry: () =>
                                        state.errorCode == 'delete_failed'
                                        ? _controller.delete()
                                        : _controller.save(),
                                  ),
                                  AppWhiteSpace.hLg,
                                ],
                                if (state.hasValidationErrors) ...[
                                  const CustomExerciseErrorBanner(
                                    message:
                                        AppStrings.customExerciseMissingFields,
                                  ),
                                  AppWhiteSpace.hLg,
                                ],
                                _EditorIntroduction(
                                  mode: widget.mode,
                                  child: CustomExerciseNameField(
                                    initialValue: state.draft.name,
                                    onChanged: _controller.rename,
                                    enabled: !busy,
                                    errorText: state.validationErrors
                                        .where(
                                          (error) =>
                                              error.scope ==
                                              CustomExerciseValidationScope
                                                  .name,
                                        )
                                        .map((error) => error.message)
                                        .firstOrNull,
                                  ),
                                ),
                                AppWhiteSpace.hXl,
                                CustomExerciseMuscleGroupPicker(
                                  selected: state.draft.muscleGroups,
                                  onToggle: _controller.toggleMuscleGroup,
                                  enabled: !busy,
                                  errorText: state.validationErrors
                                      .where(
                                        (error) =>
                                            error.scope ==
                                            CustomExerciseValidationScope
                                                .muscleGroups,
                                      )
                                      .map((error) => error.message)
                                      .firstOrNull,
                                ),
                                AppWhiteSpace.hXl,
                                Semantics(
                                  header: true,
                                  child: Text(
                                    AppStrings.customExerciseSetup,
                                    style: CustomExerciseEditorStyle.heading(
                                      context,
                                    ),
                                  ),
                                ),
                                AppWhiteSpace.hMd,
                                CustomExerciseEquipmentDifficultySection(
                                  equipment: state.draft.equipment,
                                  onEquipmentChanged: _controller.setEquipment,
                                  difficulty: state.draft.difficulty,
                                  onDifficultyChanged:
                                      _controller.setDifficulty,
                                  enabled: !busy,
                                ),
                                AppWhiteSpace.hLg,
                                CustomExerciseModalitySection(
                                  modality: state.draft.modality,
                                  onChanged: _controller.setModality,
                                  enabled: !busy,
                                ),
                                AppWhiteSpace.hXl,
                                CustomExerciseLoggingTypePicker(
                                  selected: state.draft.loggingType,
                                  onChanged: _controller.setLoggingType,
                                  enabled: !busy,
                                ),
                                AppWhiteSpace.hXl,
                                CustomExerciseInstructionsSection(
                                  steps: state.draft.steps,
                                  onAddStep: _controller.addStep,
                                  onUpdateStep: (index, value) => _controller
                                      .updateStep(index: index, value: value),
                                  onRemoveStep: _controller.removeStep,
                                  validationErrors: state.validationErrors,
                                  enabled: !busy,
                                ),
                                AppWhiteSpace.hLg,
                                SizedBox(
                                  height: MediaQuery.paddingOf(context).bottom,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({
    required this.onBack,
    required this.showDelete,
    required this.onDelete,
  });

  final VoidCallback? onBack;
  final bool showDelete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('custom_exercise_back_action'),
            tooltip: AppStrings.backLabel,
            onPressed: onBack,
            constraints: const BoxConstraints(
              minWidth: AppCustomExerciseEditorTokens.controlSize,
              minHeight: AppCustomExerciseEditorTokens.controlSize,
            ),
            style: IconButton.styleFrom(
              backgroundColor: context.colorScheme.surfaceContainerLow,
            ),
            icon: SvgPicture.asset(
              OutlinedSvgAssets.arrowLeft,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
          AppWhiteSpace.wSm,
          Expanded(
            child: Text(
              AppStrings.customExercise,
              textAlign: TextAlign.center,
              style: CustomExerciseEditorStyle.label(context),
            ),
          ),
          AppWhiteSpace.wSm,
          if (showDelete)
            IconButton(
              tooltip: AppStrings.customExerciseDelete,
              onPressed: onDelete,
              constraints: const BoxConstraints(
                minWidth: AppCustomExerciseEditorTokens.controlSize,
                minHeight: AppCustomExerciseEditorTokens.controlSize,
              ),
              icon: SvgPicture.asset(
                OutlinedSvgAssets.trash,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.error,
                  BlendMode.srcIn,
                ),
              ),
            )
          else
            const SizedBox(width: AppCustomExerciseEditorTokens.controlSize),
        ],
      ),
    );
  }
}

class _EditorIntroduction extends StatelessWidget {
  const _EditorIntroduction({required this.mode, required this.child});
  final CustomExerciseEditorMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final create = mode == CustomExerciseEditorMode.create;
    return Container(
      key: const Key('custom_exercise_editor_intro'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              create
                  ? AppStrings.createCustomExercise
                  : AppStrings.editCustomExercise,
              style: AppTextStyles.headlineLg.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AppWhiteSpace.hSm,
          Text(
            create
                ? AppStrings.customExerciseEditorHint
                : AppStrings.customExerciseEditHint,
            style: CustomExerciseEditorStyle.small(context),
          ),
          AppWhiteSpace.hLg,
          child,
          AppWhiteSpace.hMd,
          Text(
            AppStrings.customExerciseNameAndMusclesRequired,
            style: CustomExerciseEditorStyle.caption(context),
          ),
        ],
      ),
    );
  }
}

class _EditorActions extends StatelessWidget {
  const _EditorActions({
    required this.mode,
    required this.isSaving,
    required this.onSave,
    required this.onDiscard,
  });
  final CustomExerciseEditorMode mode;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final foreground = CustomExerciseEditorStyle.actionForeground(context);
    return ColoredBox(
      color: context.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppCustomExerciseEditorTokens.maxContentWidth,
            ),
            child: Padding(
              key: const Key('custom_exercise_editor_actions'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.controlGap,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final save = FilledButton(
                    key: const Key('custom_exercise_primary_action'),
                    onPressed: isSaving ? null : onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: CustomExerciseEditorStyle.actionFill(
                        context,
                      ),
                      foregroundColor: foreground,
                      disabledBackgroundColor:
                          context.colorScheme.surfaceContainerHigh,
                      disabledForegroundColor:
                          context.colorScheme.onSurfaceVariant,
                      minimumSize: const Size.fromHeight(
                        AppCustomExerciseEditorTokens.controlSize +
                            AppSpacing.sm,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      textStyle: CustomExerciseEditorStyle.label(
                        context,
                      ).copyWith(inherit: false),
                      shape: const StadiumBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSaving) ...[
                          SizedBox(
                            width: AppSizing.iconSm,
                            height: AppSizing.iconSm,
                            child: CircularProgressIndicator(
                              strokeWidth: AppSizing.strokeWidth,
                              semanticsLabel: AppStrings.loading,
                            ),
                          ),
                          AppWhiteSpace.wSm,
                        ],
                        Flexible(
                          child: Text(
                            mode == CustomExerciseEditorMode.create
                                ? AppStrings.createExercise
                                : AppStrings.save,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                  final discard = TextButton(
                    key: const Key('custom_exercise_discard_action'),
                    onPressed: isSaving ? null : onDiscard,
                    style: TextButton.styleFrom(
                      foregroundColor: context.colorScheme.onSurfaceVariant,
                      minimumSize: const Size.fromHeight(
                        AppCustomExerciseEditorTokens.controlSize,
                      ),
                      textStyle: CustomExerciseEditorStyle.label(
                        context,
                      ).copyWith(inherit: false),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.controlGap,
                      ),
                    ),
                    child: const Text(AppStrings.customExerciseDiscard),
                  );
                  final largeText =
                      MediaQuery.textScalerOf(context).scale(AppFontSizes.sm) >
                      AppFontSizes.sm *
                          AppCustomExerciseEditorTokens.largeTextBreakpoint;
                  return largeText
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [save, AppWhiteSpace.hXs, discard],
                        )
                      : Row(
                          children: [
                            Expanded(child: discard),
                            AppWhiteSpace.wSm,
                            Expanded(flex: 2, child: save),
                          ],
                        );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorLoading extends StatelessWidget {
  const _EditorLoading();
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(semanticsLabel: AppStrings.loading),
  );
}

class _EditorMessage extends StatelessWidget {
  const _EditorMessage({
    required this.message,
    required this.onAction,
    required this.actionLabel,
    this.icon = OutlinedSvgAssets.exclamationCircle,
  });
  final String message;
  final String icon;
  final VoidCallback onAction;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - AppSpacing.xxl).clamp(
              0,
              double.infinity,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset(
                icon,
                width: AppSizing.iconXxl,
                height: AppSizing.iconXxl,
                colorFilter: ColorFilter.mode(
                  CustomExerciseEditorStyle.accent(context),
                  BlendMode.srcIn,
                ),
              ),
              AppWhiteSpace.hMd,
              Text(
                message,
                textAlign: TextAlign.center,
                style: CustomExerciseEditorStyle.heading(context),
              ),
              AppWhiteSpace.hLg,
              FilledButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
