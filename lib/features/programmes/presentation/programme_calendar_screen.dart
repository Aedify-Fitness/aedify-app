import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_calendar_header.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_week_section.dart';
import 'package:aedify/features/programmes/presentation/widgets/week_selector_pills.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProgrammeCalendarScreen extends ConsumerStatefulWidget {
  const ProgrammeCalendarScreen({super.key, required this.programmeId});

  final String programmeId;

  @override
  ConsumerState<ProgrammeCalendarScreen> createState() =>
      _ProgrammeCalendarScreenState();
}

class _ProgrammeCalendarScreenState
    extends ConsumerState<ProgrammeCalendarScreen> {
  final Set<int> _expandedWeeks = {};
  bool _didInitialExpand = false;

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(
      AppProviders.programmeCalendarControllerProvider(widget.programmeId),
    );

    return asyncState.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: _ErrorView(
          message: AppStrings.programmeCalendarLoadFailed,
          onRetry: () => ref
              .read(
                AppProviders.programmeCalendarControllerProvider(
                  widget.programmeId,
                ).notifier,
              )
              .reload(),
        ),
      ),
      data: (state) {
        if (state.isLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(),
            body: _ErrorView(
              message: state.errorMessage!,
              onRetry: () => ref
                  .read(
                    AppProviders.programmeCalendarControllerProvider(
                      widget.programmeId,
                    ).notifier,
                  )
                  .reload(),
            ),
          );
        }

        final viewData = state.viewData;
        if (viewData == null) {
          return Scaffold(
            appBar: AppBar(),
            body: _ErrorView(
              message: AppStrings.programmeCalendarLoadFailed,
              onRetry: () => ref
                  .read(
                    AppProviders.programmeCalendarControllerProvider(
                      widget.programmeId,
                    ).notifier,
                  )
                  .reload(),
            ),
          );
        }

        if (!_didInitialExpand) {
          _didInitialExpand = true;
          if (viewData.todayWeekNumber != null) {
            _expandedWeeks.add(viewData.todayWeekNumber!);
          } else if (viewData.weeks.isNotEmpty) {
            _expandedWeeks.add(viewData.weeks.first.weekNumber);
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(viewData.name),
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  OutlinedSvgAssets.pencil,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                ),
                onPressed: () {
                  context.pushNamed(
                    AppRoutes.programmeBuilderEdit().name,
                    pathParameters: {'id': widget.programmeId},
                  );
                },
                tooltip: AppStrings.editProgramme,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProgrammeCalendarHeader(
                  viewData: viewData,
                  onStartTodayWorkout: viewData.todayWorkoutId != null
                      ? () {
                          context.pushNamed(
                            AppRoutes.workoutRunnerProgramWorkout().name,
                            pathParameters: {
                              'programId': widget.programmeId,
                              'workoutId': viewData.todayWorkoutId!,
                            },
                          );
                        }
                      : null,
                ),
                WeekSelectorPills(
                  weeks: viewData.weeks,
                  currentWeekNumber: viewData.todayWeekNumber,
                  scrollController: ScrollController(),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: viewData.weeks.map((week) {
                      final isExpanded = _expandedWeeks.contains(
                        week.weekNumber,
                      );
                      return ProgrammeWeekSection(
                        week: week,
                        isExpanded: isExpanded,
                        onToggle: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedWeeks.remove(week.weekNumber);
                            } else {
                              _expandedWeeks.add(week.weekNumber);
                            }
                          });
                        },
                        onDayTap: (day) {
                          if (day.workoutId != null) {
                            context.pushNamed(
                              AppRoutes.programmeWorkoutDetail().name,
                              pathParameters: {
                                'programId': widget.programmeId,
                                'workoutId': day.workoutId!,
                              },
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.exclamationCircle,
            width: AppSizing.iconLg,
            height: AppSizing.iconLg,
            colorFilter: ColorFilter.mode(
              context.colorScheme.error,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(message),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ],
      ),
    );
  }
}
