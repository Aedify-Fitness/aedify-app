import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/features/programmes/presentation/widgets/saved_workout_library_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reviews a saved workout and exposes its available session action.
class SavedWorkoutListTile extends StatelessWidget {
  const SavedWorkoutListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onPlay,
    required this.onResume,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
    this.activeSessionWorkoutId,
    this.hasActiveSession = false,
  });

  final SavedWorkoutListItem item;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final VoidCallback onResume;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final String? activeSessionWorkoutId;
  final bool hasActiveSession;

  @override
  Widget build(BuildContext context) {
    final isActive = activeSessionWorkoutId == item.id;
    final blocked =
        !isActive && (hasActiveSession || activeSessionWorkoutId != null);
    final duration = item.estimatedDurationMinutes;
    final modalities = item.modalities
        .map((value) => value.trim())
        .where(
          (value) =>
              value.isNotEmpty &&
              value.toLowerCase() != item.focus.trim().toLowerCase(),
        )
        .toSet();
    return Material(
      key: ValueKey('saved_workout_card_${item.id}'),
      color: SavedWorkoutLibraryStyle.panel(context),
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            child: InkWell(
              key: ValueKey('saved_workout_open_${item.id}'),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.focus.trim().isNotEmpty) ...[
                                Text(
                                  item.focus,
                                  style: SavedWorkoutLibraryStyle.label(context)
                                      .copyWith(
                                        color: SavedWorkoutLibraryStyle.accent(
                                          context,
                                        ),
                                      ),
                                ),
                                AppWhiteSpace.hSm,
                              ],
                              Text(
                                item.name,
                                style: SavedWorkoutLibraryStyle.title(context),
                              ),
                            ],
                          ),
                        ),
                        AppWhiteSpace.wSm,
                        PopupMenuButton<_WorkoutAction>(
                          key: ValueKey('saved_workout_menu_${item.id}'),
                          tooltip: AppStrings.workoutOptions,
                          style: IconButton.styleFrom(
                            minimumSize: const Size.square(
                              AppLibraryTokens.controlSize,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.sm,
                          ),
                          color: context.colorScheme.surfaceContainerHigh,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          popUpAnimationStyle:
                              MediaQuery.disableAnimationsOf(context)
                              ? AnimationStyle.noAnimation
                              : null,
                          icon: const _LibraryIcon(
                            asset: OutlinedSvgAssets.ellipsisVertical,
                          ),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: _WorkoutAction.edit,
                              height: AppLibraryTokens.controlSize,
                              child: _MenuLabel(
                                label: AppStrings.editWorkout,
                                asset: OutlinedSvgAssets.pencil,
                              ),
                            ),
                            PopupMenuItem(
                              value: _WorkoutAction.archive,
                              height: AppLibraryTokens.controlSize,
                              child: _MenuLabel(
                                label: AppStrings.archiveWorkout,
                                asset: OutlinedSvgAssets.archiveBox,
                              ),
                            ),
                            PopupMenuItem(
                              value: _WorkoutAction.delete,
                              height: AppLibraryTokens.controlSize,
                              child: _MenuLabel(
                                label: AppStrings.deleteWorkout,
                                asset: OutlinedSvgAssets.trash,
                                destructive: true,
                              ),
                            ),
                          ],
                          onSelected: (action) {
                            switch (action) {
                              case _WorkoutAction.edit:
                                onEdit();
                              case _WorkoutAction.archive:
                                onArchive();
                              case _WorkoutAction.delete:
                                onDelete();
                            }
                          },
                        ),
                      ],
                    ),
                    AppWhiteSpace.hMd,
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _Metadata(
                          label: AppStrings.workoutExerciseTotal(
                            item.exerciseCount,
                          ),
                          asset: OutlinedSvgAssets.listBullet,
                        ),
                        if (duration != null && duration > 0)
                          _Metadata(
                            label: AppStrings.workoutDurationEstimate(duration),
                            asset: OutlinedSvgAssets.clock,
                          ),
                      ],
                    ),
                    if (modalities.isNotEmpty) ...[
                      AppWhiteSpace.hSm,
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          for (final modality in modalities)
                            Text(
                              SavedWorkoutLibraryStyle.formatLabel(modality),
                              style: SavedWorkoutLibraryStyle.small(context),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: FilledButton(
              key: ValueKey('saved_workout_action_${item.id}'),
              onPressed: blocked
                  ? null
                  : isActive
                  ? onResume
                  : onPlay,
              style: FilledButton.styleFrom(
                backgroundColor: SavedWorkoutLibraryStyle.actionFill(context),
                foregroundColor: SavedWorkoutLibraryStyle.actionForeground(
                  context,
                ),
                disabledBackgroundColor:
                    context.colorScheme.surfaceContainerHigh,
                disabledForegroundColor: context.colorScheme.onSurfaceVariant,
                minimumSize: const Size.fromHeight(
                  AppLibraryTokens.controlSize,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.buttonVertical,
                ),
                textStyle: SavedWorkoutLibraryStyle.label(
                  context,
                ).copyWith(inherit: false),
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LibraryIcon(
                    asset: OutlinedSvgAssets.play,
                    color: blocked
                        ? context.colorScheme.onSurfaceVariant
                        : SavedWorkoutLibraryStyle.actionForeground(context),
                  ),
                  AppWhiteSpace.wSm,
                  Flexible(
                    child: Text(
                      isActive
                          ? AppStrings.resumeWorkout
                          : AppStrings.startWorkout,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _WorkoutAction { edit, archive, delete }

class _Metadata extends StatelessWidget {
  const _Metadata({required this.label, required this.asset});
  final String label;
  final String asset;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _LibraryIcon(asset: asset),
      AppWhiteSpace.wXs,
      Flexible(
        child: Text(label, style: SavedWorkoutLibraryStyle.small(context)),
      ),
    ],
  );
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({
    required this.label,
    required this.asset,
    this.destructive = false,
  });
  final String label;
  final String asset;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _LibraryIcon(
        asset: asset,
        color: destructive ? context.colorScheme.error : null,
      ),
      AppWhiteSpace.wSm,
      Expanded(
        child: Text(
          label,
          style: SavedWorkoutLibraryStyle.body(context).copyWith(
            color: destructive
                ? context.colorScheme.error
                : context.colorScheme.onSurface,
          ),
        ),
      ),
    ],
  );
}

class _LibraryIcon extends StatelessWidget {
  const _LibraryIcon({required this.asset, this.color});
  final String asset;
  final Color? color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.asset(
      asset,
      width: AppSizing.iconSm,
      height: AppSizing.iconSm,
      colorFilter: ColorFilter.mode(
        color ?? context.colorScheme.onSurfaceVariant,
        BlendMode.srcIn,
      ),
    ),
  );
}
