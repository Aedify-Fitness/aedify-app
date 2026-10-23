import 'package:aedify/features/programmes/domain/programme_workout_detail_view_data.dart';
import 'package:aedify/features/programmes/presentation/widgets/workout_detail_style.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/exercise_logging_type.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ordered exercise previews with independently disclosed set prescriptions.
class WorkoutDetailExerciseFlow extends StatelessWidget {
  const WorkoutDetailExerciseFlow({
    super.key,
    required this.exercises,
    required this.onExerciseTap,
  });

  final List<ExerciseDetailItem> exercises;
  final ValueChanged<int> onExerciseTap;

  @override
  Widget build(BuildContext context) {
    final processedGroups = <String>{};
    final sections = <Widget>[];
    var ordinal = 0;

    for (var index = 0; index < exercises.length; index++) {
      final exercise = exercises[index];
      final groupId = exercise.supersetGroupId;
      if (groupId != null && !processedGroups.add(groupId)) continue;

      final members = groupId == null
          ? [index]
          : [
              for (var member = 0; member < exercises.length; member++)
                if (exercises[member].supersetGroupId == groupId) member,
            ];
      members.sort((first, second) {
        final order = (exercises[first].supersetOrder ?? 0).compareTo(
          exercises[second].supersetOrder ?? 0,
        );
        return order == 0 ? first.compareTo(second) : order;
      });

      final cards = <Widget>[];
      for (final member in members) {
        ordinal++;
        cards.add(
          Padding(
            key: ValueKey(('workout_detail_occurrence', member)),
            padding: EdgeInsets.only(
              top: cards.isEmpty ? 0 : AppSpacing.controlGap,
            ),
            child: _ExerciseCard(
              key: ValueKey((exercises[member].exerciseId, member)),
              exercise: exercises[member],
              ordinal: ordinal,
              onTap: () => onExerciseTap(exercises[member].exerciseId),
            ),
          ),
        );
      }

      sections.add(
        Padding(
          padding: EdgeInsets.only(top: sections.isEmpty ? 0 : AppSpacing.md),
          child: groupId == null
              ? cards.single
              : _SupersetSection(children: cards),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    );
  }
}

class _SupersetSection extends StatelessWidget {
  const _SupersetSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('workout_detail_superset_group'),
      decoration: BoxDecoration(
        color: context.theme.brightness == Brightness.dark
            ? context.colorScheme.surfaceContainer
            : context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.controlGap,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                bottom: AppSpacing.controlGap,
              ),
              child: Text(
                AppStrings.superset,
                style: WorkoutDetailStyle.label(
                  context,
                ).copyWith(color: WorkoutDetailStyle.accent(context)),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  const _ExerciseCard({
    super.key,
    required this.exercise,
    required this.ordinal,
    required this.onTap,
  });

  final ExerciseDetailItem exercise;
  final int ordinal;
  final VoidCallback onTap;

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _expanded = false;

  void _toggleSets() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final sets = [...exercise.sets]
      ..sort((first, second) => first.setIndex.compareTo(second.setIndex));
    final duration = WorkoutDetailStyle.motionDuration(context);
    final details = _expanded
        ? _SetDetails(exercise: exercise, sets: sets)
        : const SizedBox.shrink();

    return Material(
      key: Key('workout_detail_exercise_${exercise.exerciseId}'),
      color: WorkoutDetailStyle.panel(context),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            hint: AppStrings.exerciseGuide,
            child: InkWell(
              key: Key('workout_detail_exercise_guide_${exercise.exerciseId}'),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ExerciseNumber(ordinal: widget.ordinal),
                    AppWhiteSpace.wControlGap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: WorkoutDetailStyle.label(
                              context,
                            ).copyWith(fontSize: AppFontSizes.lg),
                          ),
                          if (exercise.equipment.isNotEmpty) ...[
                            AppWhiteSpace.hXs,
                            Text(
                              exercise.equipment,
                              style: WorkoutDetailStyle.small(context).copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppWhiteSpace.wSm,
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: ExcludeSemantics(
                        child: SvgPicture.asset(
                          OutlinedSvgAssets.chevronRight,
                          width: AppSizing.iconS,
                          height: AppSizing.iconS,
                          colorFilter: ColorFilter.mode(
                            WorkoutDetailStyle.accent(context),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: _PrescriptionSummary(exercise: exercise),
          ),
          if (sets.isNotEmpty) ...[
            MergeSemantics(
              child: Semantics(
                expanded: _expanded,
                child: TextButton(
                  key: Key('workout_detail_sets_${exercise.exerciseId}'),
                  onPressed: _toggleSets,
                  style: TextButton.styleFrom(
                    foregroundColor: WorkoutDetailStyle.accent(context),
                    minimumSize: const Size.fromHeight(
                      AppWorkoutDetailTokens.controlSize,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.buttonVertical,
                    ),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _expanded
                              ? AppStrings.workoutHideSets
                              : AppStrings.workoutViewSets,
                          style: WorkoutDetailStyle.label(
                            context,
                          ).copyWith(color: WorkoutDetailStyle.accent(context)),
                        ),
                      ),
                      AppWhiteSpace.wSm,
                      ExcludeSemantics(
                        child: SvgPicture.asset(
                          _expanded
                              ? OutlinedSvgAssets.chevronUp
                              : OutlinedSvgAssets.chevronDown,
                          width: AppSizing.iconSm,
                          height: AppSizing.iconSm,
                          colorFilter: ColorFilter.mode(
                            WorkoutDetailStyle.accent(context),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (duration == Duration.zero)
              details
            else
              AnimatedSize(
                duration: duration,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: details,
              ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseNumber extends StatelessWidget {
  const _ExerciseNumber({required this.ordinal});

  final int ordinal;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: AppWorkoutDetailTokens.exerciseNumberSize,
        minHeight: AppWorkoutDetailTokens.exerciseNumberSize,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      alignment: Alignment.center,
      child: Text(
        ordinal.toString().padLeft(2, '0'),
        style: WorkoutDetailStyle.label(
          context,
        ).copyWith(color: WorkoutDetailStyle.accent(context)),
      ),
    );
  }
}

class _PrescriptionSummary extends StatelessWidget {
  const _PrescriptionSummary({required this.exercise});

  final ExerciseDetailItem exercise;

  @override
  Widget build(BuildContext context) {
    final working = exercise.sets
        .where((set) => set.setType == SetType.working.dbValue)
        .toList();
    final warmupCount = exercise.sets
        .where((set) => set.setType == SetType.warmup.dbValue)
        .length;
    final targets = working.map((set) {
      if (exercise.loggingType == ExerciseLoggingType.duration) {
        final seconds = set.durationSeconds;
        return seconds == null
            ? null
            : '$seconds${AppStrings.secondsUnitAbbreviation}';
      }
      final reps = set.repsDisplay?.trim();
      return reps == null || reps.isEmpty
          ? null
          : AppStrings.exerciseRepsSummary(reps);
    }).toList();
    final distinctTargets = targets.toSet();
    final target = distinctTargets.length == 1
        ? distinctTargets.single
        : targets.any((value) => value != null)
        ? AppStrings.workoutVariableTargets
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.sets.isEmpty)
          Text(AppStrings.noSetsYet, style: WorkoutDetailStyle.small(context))
        else
          Wrap(
            spacing: AppSpacing.controlGap,
            runSpacing: AppSpacing.xs,
            children: [
              if (working.isNotEmpty)
                Text(
                  AppStrings.workoutWorkingSets(working.length),
                  style: WorkoutDetailStyle.small(context),
                ),
              if (warmupCount > 0)
                Text(
                  AppStrings.workoutWarmupSets(warmupCount),
                  style: WorkoutDetailStyle.small(
                    context,
                  ).copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        if (target != null) ...[
          AppWhiteSpace.hXs,
          Text(target, style: WorkoutDetailStyle.label(context)),
        ],
      ],
    );
  }
}

class _SetDetails extends StatelessWidget {
  const _SetDetails({required this.exercise, required this.sets});

  final ExerciseDetailItem exercise;
  final List<SetPrescriptionItem> sets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final set in sets)
            Padding(
              key: Key(
                'workout_detail_set_${exercise.exerciseId}_${set.setIndex}',
              ),
              padding: const EdgeInsets.only(top: AppSpacing.controlGap),
              child: _SetRow(set: set),
            ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.set});

  final SetPrescriptionItem set;

  @override
  Widget build(BuildContext context) {
    final typeLabel = switch (set.setType) {
      'warmup' => AppStrings.warmupSet,
      'working' => AppStrings.workingSet,
      _ => set.setType,
    };
    final notes = set.notes?.trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.brightness == Brightness.dark
            ? context.colorScheme.surfaceContainer
            : context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.controlGap,
          vertical: AppSpacing.controlGap,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.workoutSetDetailsLabel(set.setIndex + 1, typeLabel),
              style: WorkoutDetailStyle.label(context),
            ),
            AppWhiteSpace.hSm,
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                if (set.repsDisplay?.trim().isNotEmpty ?? false)
                  _SetFact(label: AppStrings.reps, value: set.repsDisplay!),
                if (set.durationSeconds != null)
                  _SetFact(
                    label: AppStrings.duration,
                    value:
                        '${set.durationSeconds}${AppStrings.secondsUnitAbbreviation}',
                  ),
                if (set.weightDisplay?.trim().isNotEmpty ?? false)
                  _SetFact(label: AppStrings.weight, value: set.weightDisplay!),
                if (set.rpeDisplay?.trim().isNotEmpty ?? false)
                  _SetFact(label: AppStrings.intensity, value: set.rpeDisplay!),
                if (set.restSeconds != null)
                  _SetFact(
                    label: AppStrings.rest,
                    value:
                        '${set.restSeconds}${AppStrings.secondsUnitAbbreviation}',
                  ),
              ],
            ),
            if (notes != null && notes.isNotEmpty) ...[
              AppWhiteSpace.hSm,
              _SetFact(label: AppStrings.notes, value: notes),
            ],
          ],
        ),
      ),
    );
  }
}

class _SetFact extends StatelessWidget {
  const _SetFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WorkoutDetailStyle.caption(
            context,
          ).copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
        AppWhiteSpace.hXxs,
        Text(value, style: WorkoutDetailStyle.small(context)),
      ],
    );
  }
}
