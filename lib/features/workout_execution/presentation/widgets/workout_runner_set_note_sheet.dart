import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

class WorkoutRunnerSetNoteSheet extends StatefulWidget {
  const WorkoutRunnerSetNoteSheet({
    super.key,
    required this.initialNote,
    required this.onSave,
  });

  final String? initialNote;
  final ValueChanged<String?> onSave;

  @override
  State<WorkoutRunnerSetNoteSheet> createState() =>
      _WorkoutRunnerSetNoteSheetState();
}

class _WorkoutRunnerSetNoteSheetState extends State<WorkoutRunnerSetNoteSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          top: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.setNotes,
              style: AppTextStyles.headlineMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            AppWhiteSpace.hLg,
            AppTextField(
              key: const ValueKey<String>('workout_runner_note_field'),
              controller: _controller,
              labelText: AppStrings.setNotes,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
            AppWhiteSpace.hLg,
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final note = _controller.text.trim();
                  widget.onSave(note.isEmpty ? null : note);
                },
                child: const Text(AppStrings.saveNote),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
