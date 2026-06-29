import 'package:flutter/material.dart';

import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_validation_error.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/set_prescription_editor_row.dart';

class SetPrescriptionList extends StatelessWidget {
  const SetPrescriptionList({
    super.key,
    required this.exerciseDraftId,
    required this.sets,
    required this.onUpdateSet,
    required this.onRemoveSet,
    required this.validationErrors,
  });

  final String exerciseDraftId;
  final List<SetPrescriptionDraft> sets;
  final void Function(String setId, SetPrescriptionDraft prescription)
  onUpdateSet;
  final void Function(String setId) onRemoveSet;
  final List<WorkoutBuilderValidationError> validationErrors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final prescription in sets)
          SetPrescriptionEditorRow(
            key: ValueKey(prescription.id),
            prescription: prescription,
            modality: '',
            onChanged: (updated) => onUpdateSet(prescription.id, updated),
            onRemove: () => onRemoveSet(prescription.id),
            errorText: validationErrors
                .where((e) => e.setId == prescription.id)
                .firstOrNull
                ?.message,
          ),
      ],
    );
  }
}
