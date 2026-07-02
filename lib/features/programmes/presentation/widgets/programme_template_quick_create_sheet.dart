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
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
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
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.createTemplate, style: context.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: AppStrings.templateName,
              hintText: AppStrings.templateNameHint,
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _showExercisePicker,
            icon: SvgPicture.asset(
              OutlinedSvgAssets.plus,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
            ),
            label: const Text(AppStrings.selectExercisesForTemplate),
          ),
          if (_selectedExercises.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${_selectedExercises.length} ${AppStrings.exercisesSelected}',
              style: context.textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            ...List.generate(_selectedExercises.length, (i) {
              final ex = _selectedExercises[i];
              return ListTile(
                dense: true,
                title: Text(ex.name),
                trailing: IconButton(
                  icon: SvgPicture.asset(
                    OutlinedSvgAssets.xCircle,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                  ),
                  onPressed: () => _removeExercise(i),
                ),
              );
            }),
          ],
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _canCreate ? _createTemplate : null,
              child: const Text(AppStrings.createTemplate),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
