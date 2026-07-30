import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/features/programmes/application/programme_builder_phase.dart';
import 'package:aedify/features/programmes/application/programme_builder_state.dart';
import 'package:aedify/shared/components/app_toggle_pill.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeSaveBar extends StatelessWidget {
  const ProgrammeSaveBar({
    super.key,
    required this.state,
    required this.onSave,
    required this.onToggleActive,
  });

  final ProgrammeBuilderState state;
  final VoidCallback onSave;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final canSave =
        state.draft.name.trim().isNotEmpty &&
        (state.draft.weeks?.isNotEmpty ?? false) &&
        state.phase != ProgrammeBuilderPhase.saving;

    final isActive = state.draft.status == ProgramStatus.active;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          border: Border(
            top: BorderSide(color: context.colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (state.isDirty) ...[
                  Container(
                    key: const Key('programme_dirty_indicator'),
                    width: AppSizing.iconS,
                    height: AppSizing.iconS,
                    decoration: BoxDecoration(
                      color: context.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppWhiteSpace.wSm,
                ],
                Expanded(
                  child: Text(
                    state.isDirty
                        ? AppStrings.unsavedProgrammeChanges
                        : state.draft.name.trim().isEmpty
                        ? AppStrings.newProgramme
                        : AppStrings.programmeSaved,
                    style: AppTextStyles.bodySm.copyWith(
                      color: state.isDirty
                          ? context.colorScheme.onSurface
                          : context.colorScheme.onSurfaceVariant,
                      fontWeight: state.isDirty
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                AppWhiteSpace.wSm,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isActive)
                          Container(
                            key: const Key('programme_inactive_indicator'),
                            width: AppSizing.iconS,
                            height: AppSizing.iconS,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.colorScheme.onSurfaceVariant,
                                width: AppSizing.strokeWidth,
                              ),
                            ),
                          )
                        else
                          SvgPicture.asset(
                            OutlinedSvgAssets.checkCircle,
                            width: AppSizing.iconS,
                            height: AppSizing.iconS,
                            colorFilter: ColorFilter.mode(
                              context.colorScheme.secondary,
                              BlendMode.srcIn,
                            ),
                          ),
                        AppWhiteSpace.wXs,
                        Text(
                          isActive
                              ? AppStrings.programmeActive
                              : AppStrings.programmeInactive,
                          style: AppTextStyles.labelSm.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    AppWhiteSpace.hXs,
                    AppTogglePill(
                      value: isActive,
                      semanticLabel: isActive
                          ? AppStrings.programmeActive
                          : AppStrings.programmeInactive,
                      onChanged: (_) => onToggleActive(),
                    ),
                  ],
                ),
              ],
            ),
            AppWhiteSpace.hSm,
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('programme_save_button'),
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
                        colorFilter: ColorFilter.mode(
                          context.colorScheme.onSecondary,
                          BlendMode.srcIn,
                        ),
                      ),
                label: Text(
                  state.isSaving
                      ? AppStrings.loading
                      : AppStrings.saveProgramme,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
