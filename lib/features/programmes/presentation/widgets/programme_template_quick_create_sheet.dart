import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart';
import 'package:aedify/shared/components/app_bottom_sheet.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/components/app_list_tile.dart';
import 'package:aedify/shared/components/app_section_header.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:uuid/uuid.dart';

class ProgrammeTemplateQuickCreateSheet extends ConsumerStatefulWidget {
  const ProgrammeTemplateQuickCreateSheet({super.key});

  @override
  ConsumerState<ProgrammeTemplateQuickCreateSheet> createState() =>
      _ProgrammeTemplateQuickCreateSheetState();
}

class _ProgrammeTemplateQuickCreateSheetState
    extends ConsumerState<ProgrammeTemplateQuickCreateSheet> {
  final _nameController = TextEditingController();
  final _selectedExercises = <ExerciseReference>[];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canCreate =>
      _nameController.text.trim().isNotEmpty && _selectedExercises.isNotEmpty;

  void _addExercise(ExerciseReference exercise) {
    setState(() {
      _selectedExercises.add(exercise);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExerciseBottomSheet(
        onSelectExercises: (exercises) {
          for (final exercise in exercises) {
            _addExercise(exercise);
          }
        },
      ),
    ).then((_) {
      ref
          .read(AppProviders.exerciseSearchControllerProvider.notifier)
          .clearFilters();
    });
  }

  void _createTemplate() {
    if (!_canCreate) return;

    final exercises = <ProgrammeExerciseDraft>[];
    for (var i = 0; i < _selectedExercises.length; i++) {
      final ex = _selectedExercises[i];
      exercises.add(
        ProgrammeExerciseDraft(
          id: const Uuid().v4(),
          exerciseId: ex.exerciseId,
          sortOrder: i,
          sets: [
            SetPrescriptionDraft(
              id: const Uuid().v4(),
              setIndex: 0,
              setType: SetType.working,
              prescribedRepsExact: 10,
            ),
          ],
          exerciseRef: ex.name,
        ),
      );
    }

    final template = ProgrammeBuilderTemplateDraft(
      id: const Uuid().v4(),
      templateKey: const Uuid().v4(),
      name: _nameController.text.trim(),
      exercises: exercises,
    );

    context.pop(template);
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: AppStrings.createTemplate,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.lg,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AppTextField(
                    controller: _nameController,
                    labelText: AppStrings.templateName,
                    hintText: AppStrings.templateNameHint,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    fillColor: context.colorScheme.surfaceContainerLowest,
                    borderRadius: AppRadius.md,
                  ),
                ),
              ),
              AppWhiteSpace.hMd,
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showExercisePicker,
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.plus,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: const Text(AppStrings.selectExercisesForTemplate),
                ),
              ),
              if (_selectedExercises.isNotEmpty) ...[
                AppWhiteSpace.hLg,
                AppSectionHeader(
                  title:
                      '${_selectedExercises.length} ${AppStrings.exercisesSelected}',
                ),
                AppWhiteSpace.hSm,
                ...List.generate(_selectedExercises.length, (index) {
                  final exercise = _selectedExercises[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppListTile(
                      title: exercise.name,
                      leadingAsset: OutlinedSvgAssets.sparkles,
                      trailing: Tooltip(
                        message: AppStrings.removeExercise,
                        child: AppIconButton(
                          key: ValueKey('remove_template_exercise_$index'),
                          asset: OutlinedSvgAssets.xCircle,
                          onPressed: () => _removeExercise(index),
                          semanticLabel: AppStrings.removeExercise,
                          color: context.colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }),
              ],
              AppWhiteSpace.hMd,
              ListenableBuilder(
                listenable: _nameController,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_nameController.text.trim().isEmpty)
                        Text(
                          AppStrings.onboardingValidationRequired,
                          style: AppTextStyles.labelSm.copyWith(
                            color: context.colorScheme.error,
                          ),
                        ),
                      if (_selectedExercises.isEmpty) ...[
                        if (_nameController.text.trim().isEmpty)
                          AppWhiteSpace.hXs,
                        Text(
                          AppStrings.addAtLeastOneExercise,
                          style: AppTextStyles.labelSm.copyWith(
                            color: context.colorScheme.error,
                          ),
                        ),
                      ],
                      AppWhiteSpace.hSm,
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _canCreate ? _createTemplate : null,
                          child: const Text(AppStrings.createTemplate),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
