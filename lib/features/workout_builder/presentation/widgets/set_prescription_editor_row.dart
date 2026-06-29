import 'package:flutter/material.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';

class SetPrescriptionEditorRow extends StatelessWidget {
  const SetPrescriptionEditorRow({
    super.key,
    required this.prescription,
    required this.modality,
    required this.onChanged,
    required this.onRemove,
    this.errorText,
  });

  final SetPrescriptionDraft prescription;
  final String modality;
  final ValueChanged<SetPrescriptionDraft> onChanged;
  final VoidCallback onRemove;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: AppSpacing.xxl,
            child: Text(
              '${prescription.setIndex + 1}',
              style: AppTextStyles.labelSm,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: AppSizing.fieldWidthLg,
            child: TextField(
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: prescription.prescribedRepsMin?.toString() ?? '',
                ),
              ),
              decoration: InputDecoration(
                labelText: AppStrings.reps,
                isDense: true,
                errorText: errorText,
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => onChanged(
                prescription.copyWith(prescribedRepsMin: int.tryParse(v)),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: AppSizing.fieldWidthMd,
            child: TextField(
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: prescription.prescribedWeightKg?.toString() ?? '',
                ),
              ),
              decoration: InputDecoration(
                labelText: AppStrings.weight,
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => onChanged(
                prescription.copyWith(prescribedWeightKg: double.tryParse(v)),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: AppSizing.fieldWidthSm,
            child: TextField(
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: prescription.restSeconds?.toString() ?? '',
                ),
              ),
              decoration: InputDecoration(
                labelText: AppStrings.rest,
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => onChanged(
                prescription.copyWith(restSeconds: int.tryParse(v)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: AppSpacing.md),
            onPressed: onRemove,
            tooltip: AppStrings.removeSet,
          ),
        ],
      ),
    );
  }
}
