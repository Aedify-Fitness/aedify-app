import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/application/programme_builder_phase.dart';
import 'package:aedify/features/programmes/application/programme_builder_state.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeSaveBar extends ConsumerWidget {
  const ProgrammeSaveBar({
    super.key,
    required this.state,
    required this.onSave,
  });

  final ProgrammeBuilderState state;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSave =
        state.draft.name.trim().isNotEmpty &&
        state.phase != ProgrammeBuilderPhase.saving;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          top: BorderSide(color: context.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          if (state.isDirty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Container(
                width: AppSizing.iconXs,
                height: AppSizing.iconXs,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Expanded(
            child: Text(
              state.isDirty ? AppStrings.unsavedProgrammeChanges : '',
              style: context.textTheme.bodySmall,
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: canSave ? onSave : null,
            icon: state.isSaving
                ? const SizedBox(
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: AppSizing.strokeWidth,
                    ),
                  )
                : SvgPicture.asset(
                    OutlinedSvgAssets.documentArrowDown,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                  ),
            label: Text(state.isSaving ? '' : AppStrings.saveProgramme),
          ),
        ],
      ),
    );
  }
}
