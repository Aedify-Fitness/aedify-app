import 'package:aedify/features/exercise_library/presentation/widgets/custom_exercise_editor_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

/// Keeps the active name selection intact as the local draft changes.
class CustomExerciseNameField extends StatefulWidget {
  const CustomExerciseNameField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  State<CustomExerciseNameField> createState() =>
      _CustomExerciseNameFieldState();
}

class _CustomExerciseNameFieldState extends State<CustomExerciseNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(CustomExerciseNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue == oldWidget.initialValue ||
        _controller.text == widget.initialValue) {
      return;
    }
    final value = _controller.value;
    final text = widget.initialValue;
    _controller.value = value.copyWith(
      text: text,
      selection: value.selection.isValid
          ? TextSelection(
              baseOffset: value.selection.baseOffset.clamp(0, text.length),
              extentOffset: value.selection.extentOffset.clamp(0, text.length),
              affinity: value.selection.affinity,
              isDirectional: value.selection.isDirectional,
            )
          : TextSelection.collapsed(offset: text.length),
      composing: value.composing.isValid && value.composing.end <= text.length
          ? value.composing
          : TextRange.empty,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide.none,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.customExerciseName,
          style: CustomExerciseEditorStyle.label(context),
        ),
        AppWhiteSpace.hSm,
        Semantics(
          label: AppStrings.customExerciseName,
          child: TextField(
            key: const Key('custom_exercise_name_text_field'),
            controller: _controller,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            style: CustomExerciseEditorStyle.body(context),
            decoration: InputDecoration(
              hintText: AppStrings.customExerciseNameHint,
              hintStyle: CustomExerciseEditorStyle.small(context),
              errorText: widget.errorText,
              errorMaxLines: null,
              errorStyle: CustomExerciseEditorStyle.caption(
                context,
              ).copyWith(color: context.colorScheme.error),
              filled: true,
              fillColor: context.colorScheme.surfaceContainerLowest,
              border: border,
              enabledBorder: border,
              disabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(
                  color: CustomExerciseEditorStyle.accent(context),
                  width: AppSizing.strokeWidth,
                ),
              ),
              errorBorder: border.copyWith(
                borderSide: BorderSide(
                  color: context.colorScheme.error,
                  width: AppSizing.strokeWidth,
                ),
              ),
              focusedErrorBorder: border.copyWith(
                borderSide: BorderSide(
                  color: context.colorScheme.error,
                  width: AppSizing.strokeWidth,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
        ),
      ],
    );
  }
}
