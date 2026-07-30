import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomExerciseStepsEditor extends StatefulWidget {
  const CustomExerciseStepsEditor({
    super.key,
    required this.steps,
    required this.onAddStep,
    required this.onUpdateStep,
    required this.onRemoveStep,
    this.onSwitchToText,
  });

  final List<String> steps;
  final VoidCallback onAddStep;
  final void Function(int index, String value) onUpdateStep;
  final ValueChanged<int> onRemoveStep;
  final VoidCallback? onSwitchToText;

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
    final cs = context.colorScheme;
    return Container(
      constraints: BoxConstraints(minHeight: AppSizing.inputFieldHeight * 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(widget.steps.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: [
                        SizedBox(
                          width: AppSizing.iconSm,
                          child: Text(
                            '${index + 1}.',
                            style: AppTextStyles.labelMd.copyWith(
                              color: cs.secondary,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLowest,
                              border: Border.all(color: cs.outlineVariant),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: TextField(
                              controller: _controllers[index],
                              decoration: InputDecoration(
                                hintText: AppStrings.customExerciseStepHint,
                                hintStyle: AppTextStyles.bodyMd.copyWith(
                                  color: cs.onSurfaceVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                isDense: true,
                              ),
                              style: AppTextStyles.bodyMd.copyWith(
                                color: cs.onSurface,
                              ),
                              onChanged: (value) =>
                                  widget.onUpdateStep(index, value),
                              onTapOutside: (_) =>
                                  FocusScope.of(context).unfocus(),
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        IconButton(
                          icon: SvgPicture.asset(
                            OutlinedSvgAssets.trash,
                            width: AppSizing.iconMd,
                            height: AppSizing.iconMd,
                            colorFilter: ColorFilter.mode(
                              cs.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: () => widget.onRemoveStep(index),
                          tooltip: AppStrings.customExerciseRemoveStep,
                          constraints: BoxConstraints(
                            minWidth: AppSizing.iconXxl,
                            minHeight: AppSizing.iconXxl,
                          ),
                          padding: const EdgeInsets.all(AppSpacing.sm),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: widget.onAddStep,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        OutlinedSvgAssets.plusCircle,
                        width: AppSizing.iconMd,
                        height: AppSizing.iconMd,
                        colorFilter: ColorFilter.mode(
                          cs.secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        AppStrings.customExerciseAddStep,
                        style: AppTextStyles.labelMd.copyWith(
                          color: cs.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: widget.onSwitchToText,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.04),
                      offset: const Offset(0, 2),
                      blurRadius: AppRadius.defaultRadius,
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  OutlinedSvgAssets.bars3BottomLeft,
                  height: AppSizing.iconS,
                  colorFilter: ColorFilter.mode(
                    cs.onSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
