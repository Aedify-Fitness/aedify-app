import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/programmes/application/programme_workout_detail_controller.dart';
import 'package:aedify/features/programmes/application/today_workout_resolver.dart';
import 'package:aedify/features/programmes/domain/programme_workout_detail_view_data.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/workout_detail_button_state.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
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
      loading: () =>
          Scaffold(body: const Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('$error'))),
      data: (detail) {
        if (detail == null) {
          return Scaffold(
            body: const Center(child: Text(AppStrings.missingSession)),
          );
        }

        return Scaffold(
          appBar: AppBar(elevation: 0),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroSection(detail: detail),
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xl + AppSpacing.sm,
                    bottom: AppSpacing.lg,
                  ),
                  child: Text(
                    AppStrings.workoutFlow,
                    style: AppTextStyles.headlineLgMobile.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: detail.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = detail.exercises[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < detail.exercises.length - 1
                            ? AppSpacing.md
                            : 0,
                      ),
                      child: _ExerciseCard(
                        exercise: exercise,
                        onTap: () {
                          context.pushNamed(
                            AppRoutes.exerciseDetail().name,
                            pathParameters: {
                              'id': exercise.exerciseId.toString(),
                            },
                          );
                        },
                      ),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xxl + AppSpacing.xl,
                    bottom: AppSpacing.xxxl,
                  ),
                  child: _AtmosphericSection(),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              detail.buttonState != WorkoutDetailButtonState.hidden
              ? SafeArea(
                  minimum: const EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.sm,
                  ),
                  child: FilledButton.icon(
                    onPressed: () {
                      if (detail.buttonState ==
                          WorkoutDetailButtonState.resume) {
                        context.pushNamed(AppRoutes.workoutRunnerActive().name);
                      } else {
                        context.pushNamed(
                          AppRoutes.workoutRunnerProgramWorkout().name,
                          pathParameters: {
                            'programId': programId,
                            'workoutId': workoutId,
                          },
                        );
                      }
                    },
                    icon: Icon(
                      Icons.play_arrow,
                      color: context.colorScheme.onSecondary,
                    ),
                    label: Text(
                      detail.buttonState == WorkoutDetailButtonState.resume
                          ? AppStrings.resumeWorkout
                          : AppStrings.startWorkout,
                      style: AppTextStyles.headlineMd.copyWith(
                        fontSize: AppFontSizes.xl,
                        color: context.colorScheme.onSecondary,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.detail});

  final ProgrammeWorkoutDetailViewData detail;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: cs.secondaryContainer.withAlpha(26),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            detail.programmeName,
            style: AppTextStyles.labelMd.copyWith(color: cs.secondary),
          ),
        ),
        AppWhiteSpace.hSm,
        Text(
          detail.workoutName,
          style: AppTextStyles.headlineXl.copyWith(color: cs.onSurface),
        ),
        AppWhiteSpace.hXl,
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          children: [
            _StatItem(
              icon: Icons.fitness_center,
              label: AppStrings.exercisesLabel,
              value: '${detail.exercises.length} ${AppStrings.movements}',
            ),
            _StatItem(
              icon: Icons.schedule,
              label: AppStrings.duration,
              value: '~${detail.durationMinutes} ${AppStrings.minutes}',
            ),
            if (detail.focusAreas.isNotEmpty)
              _StatItem(
                icon: Icons.my_location,
                label: AppStrings.focusLabel,
                value: detail.focusAreas,
              ),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizing.iconXxl,
          height: AppSizing.iconXxl,
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: cs.secondary, size: AppSizing.iconMd),
        ),
        AppWhiteSpace.custom(width: AppSpacing.sm + AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.labelSm.copyWith(color: cs.onSurfaceVariant),
            ),
            AppWhiteSpace.hXxs,
            Text(
              value,
              style: AppTextStyles.labelMd.copyWith(color: cs.onSurface),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, this.onTap});

  final ExerciseDetailItem exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final firstSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: cs.secondary.withAlpha(20),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: AppSizing.fieldWidthXl,
              height: AppSizing.fieldWidthXl,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              ),
              child: Icon(
                Icons.fitness_center,
                color: cs.onSurfaceVariant.withAlpha(77),
                size: AppSizing.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.md + AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: AppTextStyles.labelMd.copyWith(
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (exercise.equipment.isNotEmpty) ...[
                          AppWhiteSpace.wXs,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer.withAlpha(26),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              exercise.equipment,
                              style: AppTextStyles.labelSm.copyWith(
                                color: cs.secondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (firstSet != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Row(
                        spacing: AppSpacing.md,
                        children: [
                          _SetSummaryColumn(
                            label: AppStrings.setsAndReps,
                            value:
                                '${exercise.sets.length} x ${firstSet.repsDisplay ?? '-'}',
                          ),
                          Container(
                            width: 1,
                            height: AppSpacing.lg,
                            color: cs.outlineVariant,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.md),
                            child: _SetSummaryColumn(
                              label: AppStrings.intensity,
                              value: firstSet.rpeDisplay ?? '-',
                              valueColor: cs.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: cs.onSurfaceVariant,
              size: AppSizing.iconSm,
            ),
          ],
        ),
      ),
    );
  }
}

class _SetSummaryColumn extends StatelessWidget {
  const _SetSummaryColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            fontSize: AppFontSizes.xxs,
            color: cs.onSurfaceVariant,
          ),
        ),
        AppWhiteSpace.hXxs,
        Text(
          value,
          style: AppTextStyles.labelMd.copyWith(
            color: valueColor ?? cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AtmosphericSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant.withAlpha(77)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.secondaryContainer.withAlpha(13),
            cs.primaryContainer.withAlpha(26),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.readyToPush,
            style: AppTextStyles.headlineMd.copyWith(color: cs.primary),
          ),
          AppWhiteSpace.hSm,
          Text(
            AppStrings.sessionInspirationMessage,
            style: AppTextStyles.bodyMd.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
        ref.watch(AppProviders.homeRefreshTriggerProvider);
        final repo = ref.read(AppProviders.programmeRepositoryProvider);
        final aggregate = await repo.getProgramme(arg.programId);
        if (aggregate == null) return null;

        final sessionDao = ref.read(AppProviders.workoutSessionDaoProvider);
        final resolver = TodayWorkoutResolver(sessionDao: sessionDao);
        final resolution = await resolver.resolve(
          aggregate: aggregate,
          now: DateTime.now(),
        );

        final isToday = resolution.todayWorkoutId == arg.workoutId;
        final isCompleted = resolution.completedWorkoutIds.contains(
          arg.workoutId,
        );

        WorkoutDetailButtonState buttonState;
        if (isCompleted) {
          buttonState = WorkoutDetailButtonState.hidden;
        } else {
          final activeSession = await sessionDao.getActiveSession();
          final isInProgress = activeSession?.programWorkoutId == arg.workoutId;
          if (isInProgress) {
            buttonState = WorkoutDetailButtonState.resume;
          } else if (isToday) {
            buttonState = WorkoutDetailButtonState.start;
          } else {
            buttonState = WorkoutDetailButtonState.hidden;
          }
        }

        final exerciseIds = aggregate.exercises
            .map((e) => e.exerciseId)
            .toSet()
            .toList();
        final dao = ref.read(AppProviders.exerciseDaoProvider);
        final exerciseModels = <int, Exercise>{};
        for (final id in exerciseIds) {
          final row = await dao.getExerciseById(id);
          if (row != null) {
            exerciseModels[id] = row;
          }
        }

        return ProgrammeWorkoutDetailController.buildWorkoutDetail(
          aggregate,
          arg.workoutId,
          exerciseModels,
          buttonState: buttonState,
        );
      });
}
