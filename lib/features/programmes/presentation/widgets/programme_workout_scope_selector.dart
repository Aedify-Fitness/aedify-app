import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';

/// Scope of a workout assignment, with independently editable repeated copies.
class ProgrammeWorkoutScopeSelector extends StatefulWidget {
  const ProgrammeWorkoutScopeSelector({super.key, required this.onChanged});
  final ValueChanged<bool> onChanged;

  @override
  State<ProgrammeWorkoutScopeSelector> createState() =>
      _ProgrammeWorkoutScopeSelectorState();
}

class _ProgrammeWorkoutScopeSelectorState
    extends State<ProgrammeWorkoutScopeSelector> {
  bool _repeat = false;

  void _select(bool repeat) {
    setState(() => _repeat = repeat);
    widget.onChanged(repeat);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(AppStrings.programmeWorkoutScope, style: AppTextStyles.labelMd),
      AppWhiteSpace.hSm,
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          ChoiceChip(
            label: const Text(AppStrings.programmeCustomDay),
            selected: !_repeat,
            onSelected: (_) => _select(false),
          ),
          ChoiceChip(
            label: const Text(AppStrings.programmeRepeatInBlock),
            selected: _repeat,
            onSelected: (_) => _select(true),
          ),
        ],
      ),
      AppWhiteSpace.hSm,
      Text(
        AppStrings.programmeRepeatCopiesHint,
        style: AppTextStyles.labelSm.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      AppWhiteSpace.hLg,
    ],
  );
}
