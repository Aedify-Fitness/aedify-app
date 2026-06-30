import 'package:aedify/features/workout_builder/domain/set_prescription_draft.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/set_type_option.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SetPrescriptionEditorRow extends StatefulWidget {
  const SetPrescriptionEditorRow({
    super.key,
    required this.prescription,
    required this.modality,
    required this.onChanged,
    required this.onRemove,
    required this.setTypeOptions,
    this.errorText,
  });

  final SetPrescriptionDraft prescription;
  final String modality;
  final ValueChanged<SetPrescriptionDraft> onChanged;
  final VoidCallback onRemove;
  final List<SetTypeOption> setTypeOptions;
  final String? errorText;

  @override
  State<SetPrescriptionEditorRow> createState() =>
      _SetPrescriptionEditorRowState();
}

class _SetPrescriptionEditorRowState extends State<SetPrescriptionEditorRow> {
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  late final TextEditingController _restController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController();
    _weightController = TextEditingController();
    _restController = TextEditingController();
    _syncControllers();
    _repsController.addListener(_onRepsChanged);
    _weightController.addListener(_onWeightChanged);
    _restController.addListener(_onRestChanged);
  }

  @override
  void didUpdateWidget(SetPrescriptionEditorRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.prescription.id != oldWidget.prescription.id ||
        widget.prescription.prescribedRepsMin !=
            oldWidget.prescription.prescribedRepsMin ||
        widget.prescription.prescribedWeightKg !=
            oldWidget.prescription.prescribedWeightKg ||
        widget.prescription.restSeconds != oldWidget.prescription.restSeconds) {
      _syncControllers();
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    _isSyncing = true;
    _repsController.text =
        widget.prescription.prescribedRepsMin?.toString() ?? '';
    _weightController.text =
        widget.prescription.prescribedWeightKg?.toString() ?? '';
    _restController.text = widget.prescription.restSeconds?.toString() ?? '';
    _isSyncing = false;
  }

  void _onRepsChanged() {
    if (_isSyncing) return;
    widget.onChanged(
      widget.prescription.copyWith(
        prescribedRepsMin: int.tryParse(_repsController.text),
      ),
    );
  }

  void _onWeightChanged() {
    if (_isSyncing) return;
    widget.onChanged(
      widget.prescription.copyWith(
        prescribedWeightKg: double.tryParse(_weightController.text),
      ),
    );
  }

  void _onRestChanged() {
    if (_isSyncing) return;
    widget.onChanged(
      widget.prescription.copyWith(
        restSeconds: int.tryParse(_restController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: AppSpacing.xxl,
            child: Text(
              '${widget.prescription.setIndex + 1}',
              style: AppTextStyles.labelSm,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: AppSizing.fieldWidthXl,
            child: DropdownButtonFormField<SetType>(
              initialValue: widget.prescription.setType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: AppStrings.setType,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.inputHorizontal,
                  vertical: AppSpacing.sm,
                ),
              ),
              items: widget.setTypeOptions.map((option) {
                return DropdownMenuItem<SetType>(
                  value: option.type,
                  child: Text(option.label, style: AppTextStyles.labelSm),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onChanged(
                    widget.prescription.copyWith(setType: value),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: AppSizing.fieldWidthLg,
            child: TextField(
              controller: _repsController,
              decoration: InputDecoration(
                labelText: AppStrings.reps,
                isDense: true,
                errorText: widget.errorText,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: AppSizing.fieldWidthMd,
            child: TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: AppStrings.weight,
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: AppSizing.fieldWidthSm,
            child: TextField(
              controller: _restController,
              decoration: const InputDecoration(
                labelText: AppStrings.rest,
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              OutlinedSvgAssets.trash,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
            ),
            onPressed: widget.onRemove,
            tooltip: AppStrings.removeSet,
          ),
        ],
      ),
    );
  }
}
