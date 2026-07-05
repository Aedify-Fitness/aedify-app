import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomExerciseStepsEditor extends StatefulWidget {
  const CustomExerciseStepsEditor({
    super.key,
    required this.steps,
    required this.onAddStep,
    required this.onUpdateStep,
    required this.onRemoveStep,
  });

  final List<String> steps;
  final VoidCallback onAddStep;
  final void Function(int index, String value) onUpdateStep;
  final ValueChanged<int> onRemoveStep;

  @override
  State<CustomExerciseStepsEditor> createState() =>
      _CustomExerciseStepsEditorState();
}

class _CustomExerciseStepsEditorState extends State<CustomExerciseStepsEditor> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.steps
        .map((s) => TextEditingController(text: s))
        .toList();
  }

  @override
  void didUpdateWidget(CustomExerciseStepsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steps.length > _controllers.length) {
      for (var i = _controllers.length; i < widget.steps.length; i++) {
        _controllers.add(TextEditingController(text: widget.steps[i]));
      }
    } else if (widget.steps.length < _controllers.length) {
      for (var i = widget.steps.length; i < _controllers.length; i++) {
        _controllers[i].dispose();
      }
      _controllers.removeRange(widget.steps.length, _controllers.length);
    }
    for (var i = 0; i < widget.steps.length && i < _controllers.length; i++) {
      if (widget.steps[i] != _controllers[i].text) {
        _controllers[i].text = widget.steps[i];
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.customExerciseSteps, style: AppTextStyles.labelMd),
        AppWhiteSpace.hXs,
        if (widget.steps.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              AppStrings.customExerciseNoSteps,
              style: AppTextStyles.labelSm,
            ),
          )
        else
          ...List.generate(widget.steps.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controllers[index],
                      decoration: InputDecoration(
                        hintText:
                            '${AppStrings.customExerciseSteps} ${index + 1}',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        isDense: true,
                      ),
                      maxLines: 2,
                      onChanged: (value) => widget.onUpdateStep(index, value),
                    ),
                  ),
                  AppWhiteSpace.wXs,
                  IconButton(
                    icon: SvgPicture.asset(
                      OutlinedSvgAssets.minusCircle,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                    ),
                    onPressed: () => widget.onRemoveStep(index),
                    tooltip: AppStrings.customExerciseRemoveStep,
                  ),
                ],
              ),
            );
          }),
        AppWhiteSpace.hXs,
        OutlinedButton.icon(
          onPressed: widget.onAddStep,
          icon: SvgPicture.asset(
            OutlinedSvgAssets.plus,
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
          ),
          label: Text(AppStrings.customExerciseAddStep),
        ),
      ],
    );
  }
}
