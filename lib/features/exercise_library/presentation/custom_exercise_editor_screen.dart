import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/custom_exercise_editor_phase.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_editor_mode.dart';
import 'package:aedify/features/exercise_library/domain/custom_exercise_validation_error.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_error_banner.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_modality_section.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_muscle_group_picker.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_name_field.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_steps_editor.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/delete_custom_exercise_dialog.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/discard_custom_exercise_changes_dialog.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomExerciseEditorScreen extends ConsumerWidget {
  const CustomExerciseEditorScreen.create({super.key})
    : mode = CustomExerciseEditorMode.create,
      exerciseId = null;

  const CustomExerciseEditorScreen.edit({super.key, required this.exerciseId})
    : mode = CustomExerciseEditorMode.edit;

  final CustomExerciseEditorMode mode;
  final int? exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(
      AppProviders.customExerciseEditorControllerProvider((
        mode: mode,
        exerciseId: exerciseId,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode == CustomExerciseEditorMode.create
              ? AppStrings.createCustomExercise
              : AppStrings.editCustomExercise,
        ),
        actions: [
          if (mode == CustomExerciseEditorMode.edit)
            IconButton(
              icon: SvgPicture.asset(
                OutlinedSvgAssets.trash,
                width: AppSizing.iconMd,
                height: AppSizing.iconMd,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => DeleteCustomExerciseDialog(
                    onConfirm: () {
                      ref
                          .read(
                            AppProviders.customExerciseEditorControllerProvider(
                              (mode: mode, exerciseId: exerciseId),
                            ).notifier,
                          )
                          .delete();
                    },
                  ),
                );
              },
              tooltip: AppStrings.customExerciseDeleted,
            ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.customExerciseLoadFailed,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge,
                ),
                AppWhiteSpace.hMd,
                FilledButton(
                  onPressed: () => ref.invalidate(
                    AppProviders.customExerciseEditorControllerProvider((
                      mode: mode,
                      exerciseId: exerciseId,
                    )),
                  ),
                  child: const Text(AppStrings.retry),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          if (state.phase == CustomExerciseEditorPhase.saved) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      OutlinedSvgAssets.checkBadge,
                      width: AppSpacing.xxl,
                      height: AppSpacing.xxl,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    AppWhiteSpace.hMd,
                    Text(
                      AppStrings.customExerciseSaved,
                      style: AppTextStyles.headlineMd,
                    ),
                    AppWhiteSpace.hLg,
                    FilledButton(
                      onPressed: () {
                        ref.invalidate(
                          AppProviders.customExerciseEditorControllerProvider((
                            mode: CustomExerciseEditorMode.create,
                            exerciseId: null,
                          )),
                        );
                        context.pop(true);
                      },
                      child: const Text(AppStrings.done),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.phase == CustomExerciseEditorPhase.deleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.pop(true);
              }
            });
            return const SizedBox.shrink();
          }

          final controller = ref.read(
            AppProviders.customExerciseEditorControllerProvider((
              mode: mode,
              exerciseId: exerciseId,
            )).notifier,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.phase == CustomExerciseEditorPhase.failure &&
                          state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: CustomExerciseErrorBanner(
                            message: state.errorMessage!,
                            onRetry: () => controller.save(),
                          ),
                        ),
                      if (state.hasValidationErrors)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: CustomExerciseErrorBanner(
                            message: AppStrings.customExerciseMissingFields,
                          ),
                        ),
                      CustomExerciseNameField(
                        initialValue: state.draft.name,
                        onChanged: (value) => controller.rename(value),
                        errorText: state.validationErrors
                            .where(
                              (e) =>
                                  e.scope == CustomExerciseValidationScope.name,
                            )
                            .map((e) => e.message)
                            .firstOrNull,
                      ),
                      AppWhiteSpace.hMd,
                      CustomExerciseModalitySection(
                        modality: state.draft.modality,
                        onChanged: (value) => controller.setModality(value),
                        equipment: state.draft.equipment,
                        onEquipmentChanged: (value) =>
                            controller.setEquipment(value),
                        difficulty: state.draft.difficulty,
                        onDifficultyChanged: (value) =>
                            controller.setDifficulty(value),
                      ),
                      AppWhiteSpace.hMd,
                      CustomExerciseMuscleGroupPicker(
                        selected: state.draft.muscleGroups,
                        onToggle: (bucket) =>
                            controller.toggleMuscleGroup(bucket),
                        errorText: state.validationErrors
                            .where(
                              (e) =>
                                  e.scope ==
                                  CustomExerciseValidationScope.muscleGroups,
                            )
                            .map((e) => e.message)
                            .firstOrNull,
                      ),
                      AppWhiteSpace.hMd,
                      CustomExerciseStepsEditor(
                        steps: state.draft.steps,
                        onAddStep: () => controller.addStep(),
                        onUpdateStep: (index, value) =>
                            controller.updateStep(index: index, value: value),
                        onRemoveStep: (index) => controller.removeStep(index),
                      ),
                      AppWhiteSpace.hXxxl,
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.isSaving
                          ? null
                          : () => controller.save(),
                      child: state.isSaving
                          ? const SizedBox(
                              width: AppSpacing.lg,
                              height: AppSpacing.lg,
                              child: CircularProgressIndicator(
                                strokeWidth: AppSizing.strokeWidth,
                              ),
                            )
                          : Text(AppStrings.save),
                    ),
                  ),
                ),
              ),
              if (state.isDirty)
                PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, _) {
                    if (didPop) return;
                    showDialog(
                      context: context,
                      builder: (_) => DiscardCustomExerciseChangesDialog(
                        onDiscard: () {
                          controller.discardChanges();
                          context.pop();
                          context.pop();
                        },
                      ),
                    );
                  },
                  child: const SizedBox.shrink(),
                ),
            ],
          );
        },
      ),
    );
  }
}
