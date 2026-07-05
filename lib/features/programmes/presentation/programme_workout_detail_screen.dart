import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/application/programme_workout_detail_controller.dart';
import 'package:aedify/features/programmes/domain/programme_workout_detail_view_data.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class ProgrammeWorkoutDetailScreen extends ConsumerWidget {
  const ProgrammeWorkoutDetailScreen({
    super.key,
    required this.programId,
    required this.workoutId,
  });

  final String programId;
  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      _ProgrammeWorkoutDetailProviders.workoutDetailProvider((
        programId: programId,
        workoutId: workoutId,
      )),
    );

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$error')),
      ),
      data: (detail) {
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text(AppStrings.missingSession)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(detail.workoutName),
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  OutlinedSvgAssets.playCircle,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                ),
                onPressed: () {
                  context.pushNamed(
                    AppRoutes.workoutRunnerProgramWorkout().name,
                    pathParameters: {
                      'programId': programId,
                      'workoutId': workoutId,
                    },
                  );
                },
                tooltip: AppStrings.startWorkout,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _WorkoutDetailHeader(detail: detail),
              AppWhiteSpace.hLg,
              ...detail.exercises.map(
                (exercise) => _WorkoutExerciseCard(exercise: exercise),
              ),
              AppWhiteSpace.hXxl,
              FilledButton.icon(
                onPressed: () {
                  context.pushNamed(
                    AppRoutes.workoutRunnerProgramWorkout().name,
                    pathParameters: {
                      'programId': programId,
                      'workoutId': workoutId,
                    },
                  );
                },
                icon: SvgPicture.asset(
                  OutlinedSvgAssets.playCircle,
                  width: AppSizing.iconSm,
                  height: AppSizing.iconSm,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.onSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                label: Text(AppStrings.startWorkout),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkoutDetailHeader extends StatelessWidget {
  const _WorkoutDetailHeader({required this.detail});

  final ProgrammeWorkoutDetailViewData detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.dayLabel,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.secondary,
          ),
        ),
        AppWhiteSpace.hXs,
        if (detail.durationMinutes > 0)
          Row(
            children: [
              SvgPicture.asset(
                OutlinedSvgAssets.clock,
                width: AppSizing.iconS,
                height: AppSizing.iconS,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
              AppWhiteSpace.wXs,
              Text(
                '${detail.durationMinutes} min',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _WorkoutExerciseCard extends StatelessWidget {
  const _WorkoutExerciseCard({required this.exercise});

  final ExerciseDetailItem exercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppWhiteSpace.hMd,
          ...exercise.sets.map((set) => _WorkoutSetRow(set: set)),
        ],
      ),
    );
  }
}

class _WorkoutSetRow extends StatelessWidget {
  const _WorkoutSetRow({required this.set});

  final SetPrescriptionItem set;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: AppSizing.setNumberColumnWidth,
            child: Text(
              '${set.setIndex + 1}',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (set.repsDisplay != null) ...[
            _SetDetail(label: set.repsDisplay!, sublabel: 'reps'),
          ],
          if (set.weightDisplay != null) ...[
            AppWhiteSpace.wLg,
            _SetDetail(label: set.weightDisplay!, sublabel: ''),
          ],
          if (set.rpeDisplay != null) ...[
            AppWhiteSpace.wLg,
            _SetDetail(label: set.rpeDisplay!, sublabel: ''),
          ],
          if (set.restSeconds != null && set.restSeconds! > 0) ...[
            AppWhiteSpace.wLg,
            _SetDetail(label: '${set.restSeconds}s', sublabel: 'rest'),
          ],
        ],
      ),
    );
  }
}

class _SetDetail extends StatelessWidget {
  const _SetDetail({required this.label, required this.sublabel});

  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (sublabel.isNotEmpty)
          Text(
            sublabel,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _ProgrammeWorkoutDetailProviders {
  _ProgrammeWorkoutDetailProviders._();

  static final workoutDetailProvider =
      FutureProvider.family<
        ProgrammeWorkoutDetailViewData?,
        ({String programId, String workoutId})
      >((ref, arg) async {
        final repo = ref.read(AppProviders.programmeRepositoryProvider);
        final aggregate = await repo.getProgramme(arg.programId);
        if (aggregate == null) return null;

        final exerciseIds = aggregate.exercises
            .map((e) => e.exerciseId)
            .toSet()
            .toList();
        final dao = ref.read(AppProviders.exerciseDaoProvider);
        final exerciseNames = <int, String>{};
        for (final id in exerciseIds) {
          final row = await dao.getExerciseById(id);
          if (row != null) {
            exerciseNames[id] = row.name;
          }
        }

        return ProgrammeWorkoutDetailController.buildWorkoutDetail(
          aggregate,
          arg.workoutId,
          exerciseNames,
        );
      });
}
