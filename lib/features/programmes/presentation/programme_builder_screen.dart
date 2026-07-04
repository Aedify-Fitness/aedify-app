import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/application/programme_builder_controller.dart';
import 'package:aedify/features/programmes/application/programme_builder_mode.dart';
import 'package:aedify/features/programmes/application/programme_builder_phase.dart';
import 'package:aedify/features/programmes/application/programme_builder_state.dart';
import 'package:aedify/features/programmes/application/saved_workout_to_template_converter.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_details_section.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_weeks_overview.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_save_bar.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_error_banner.dart';
import 'package:aedify/features/programmes/presentation/widgets/discard_programme_changes_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/active_programme_warning_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/template_reassignment_bottom_sheet.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_template_quick_create_sheet.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_superset_editor_sheet.dart';
import 'package:aedify/features/programmes/application/slot_day_assignment.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/core/logging/app_logger.dart';

class ProgrammeBuilderScreen extends ConsumerWidget {
  const ProgrammeBuilderScreen._({required this.mode, this.programmeId});

  factory ProgrammeBuilderScreen.create() {
    return const ProgrammeBuilderScreen._(mode: ProgrammeBuilderMode.create);
  }

  factory ProgrammeBuilderScreen.edit({required String programmeId}) {
    return ProgrammeBuilderScreen._(
      mode: ProgrammeBuilderMode.edit,
      programmeId: programmeId,
    );
  }

  factory ProgrammeBuilderScreen.duplicate({required String programmeId}) {
    return ProgrammeBuilderScreen._(
      mode: ProgrammeBuilderMode.duplicate,
      programmeId: programmeId,
    );
  }

  final ProgrammeBuilderMode mode;
  final String? programmeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = AppProviders.programmeBuilderControllerProvider((
      mode: mode,
      programmeId: programmeId,
    ));
    final stateAsync = ref.watch(provider);

    return stateAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.programmeBuilder)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.programmeBuilder)),
        body: _ErrorStateView(provider: provider),
      ),
      data: (state) =>
          _ProgrammeBuilderBody(mode: mode, state: state, provider: provider),
    );
  }
}

class _ProgrammeBuilderBody extends ConsumerStatefulWidget {
  const _ProgrammeBuilderBody({
    required this.mode,
    required this.state,
    required this.provider,
  });

  final ProgrammeBuilderMode mode;
  final ProgrammeBuilderState state;
  final dynamic provider;

  @override
  ConsumerState<_ProgrammeBuilderBody> createState() =>
      _ProgrammeBuilderBodyState();
}

class _ProgrammeBuilderBodyState extends ConsumerState<_ProgrammeBuilderBody> {
  static final _logger = AppLogger(name: 'ProgrammeBuilder._Body');

  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.draft.name);
    if (widget.mode == ProgrammeBuilderMode.edit && widget.state.draft.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => const ActiveProgrammeWarningDialog(),
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(_ProgrammeBuilderBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.draft.name != widget.state.draft.name) {
      _nameController.text = widget.state.draft.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  ProgrammeBuilderController get _controller =>
      ref.read(widget.provider.notifier);

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final weeks = state.draft.weeks ?? [];
    final hasErrors = state.hasValidationErrors;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (state.isDirty) {
          final discard = await showDialog<bool>(
            context: context,
            builder: (_) => const DiscardProgrammeChangesDialog(),
          );
          if (discard == true && context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.mode == ProgrammeBuilderMode.create
                ? AppStrings.createProgramme
                : AppStrings.editProgramme,
          ),
        ),
        body: Column(
          children: [
            if (state.errorMessage != null)
              ProgrammeBuilderErrorBanner(
                errorCode: state.errorCode,
                errorMessage: state.errorMessage!,
              ),
            if (hasErrors) _ValidationBanner(errors: state.validationErrors),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProgrammeDetailsSection(
                        nameController: _nameController,
                        onNameChanged: (value) => _controller.updateName(value),
                        selectedGoals: widget.state.draft.goalTags ?? const {},
                        onGoalsChanged: (goals) =>
                            _controller.setGoalTags(goals),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ProgrammeWeeksOverview(
                        weeks: weeks,
                        onAddWeek: () => _controller.addWeek(),
                        onRemoveWeek: (index) => _controller.removeWeek(index),
                        onDuplicateWeek: (index) =>
                            _controller.duplicateWeek(index),
                        onAddSlot: (weekIndex) async {
                          _logger.debug('onAddSlot weekIndex=$weekIndex');
                          final week = widget.state.draft.weeks?.elementAt(
                            weekIndex,
                          );
                          final slotCount = week?.slots?.length ?? 0;
                          _logger.debug('onAddSlot slotCount=$slotCount');
                          var scheduledDayIndex = slotCount;
                          TrainingDay? scheduledDay;

                          final profileRepo = ref.read(
                            AppProviders.profileRepositoryProvider,
                          );
                          final profile = await profileRepo.getProfile();
                          final trainingDays = profile?.trainingDays ?? [];
                          if (trainingDays.isNotEmpty) {
                            final assigned = SlotDayAssignment.assignDaySlots(
                              trainingDays,
                              slotCount + 1,
                            );
                            if (assigned.isNotEmpty) {
                              final day = assigned.last;
                              scheduledDayIndex = TrainingDay.values.indexOf(
                                day,
                              );
                              scheduledDay = day;
                            }
                          }
                          _controller.addSlot(
                            weekIndex: weekIndex,
                            scheduledDayIndex: scheduledDayIndex,
                            scheduledDay: scheduledDay,
                          );
                        },
                        onRemoveSlot: (weekIndex, slotIndex) =>
                            _controller.removeSlot(weekIndex, slotIndex),
                        onAssignTemplate: (weekIndex, slotIndex) {
                          _showTemplateSheet(weekIndex, slotIndex);
                        },
                        onOpenSupersetEditor: (weekIndex, slotIndex) {
                          _showSupersetSheet(weekIndex, slotIndex);
                        },
                        onSetWeekType: (weekIndex, type) {
                          _controller.setWeekType(
                            weekIndex: weekIndex,
                            type: type,
                          );
                        },
                        onChangeSlotDay: (weekIndex, slotIndex) =>
                            _handleChangeSlotDay(weekIndex, slotIndex),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ProgrammeSaveBar(
              state: state,
              onToggleActive: () {
                final newStatus = state.draft.status == ProgramStatus.active
                    ? ProgramStatus.inactive
                    : ProgramStatus.active;
                _controller.setProgrammeStatus(newStatus);
              },
              onSave: () async {
                await _controller.saveProgramme();
                final savedState = ref
                    .read(
                      AppProviders.programmeBuilderControllerProvider((
                        mode: widget.mode,
                        programmeId: widget.state.programmeId,
                      )),
                    )
                    .asData
                    ?.value;
                final saved =
                    savedState != null &&
                    !savedState.hasValidationErrors &&
                    savedState.phase != ProgrammeBuilderPhase.failure;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        saved
                            ? AppStrings.programmeSaved
                            : AppStrings.programmeSaveFailed,
                      ),
                    ),
                  );
                  if (saved) {
                    final programmeId = widget.state.programmeId;
                    context.pop();
                    ref
                        .read(
                          AppProviders
                              .programmeLibraryControllerProvider
                              .notifier,
                        )
                        .reload();
                    if (programmeId != null) {
                      ref
                          .read(
                            AppProviders.programmeCalendarControllerProvider(
                              programmeId,
                            ).notifier,
                          )
                          .reload();
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplateSheet(int weekIndex, int slotIndex) {
    final state = widget.state;
    final templates =
        state.draft.weeks
            ?.expand((w) => w.slots ?? [])
            .map((s) => s.template)
            .whereType<ProgrammeBuilderTemplateDraft>()
            .toSet()
            .toList() ??
        <ProgrammeBuilderTemplateDraft>[];

    final listUseCase = ref.read(AppProviders.listSavedWorkoutsUseCaseProvider);
    listUseCase
        .execute()
        .then((savedWorkouts) {
          if (!mounted) return;
          _showTemplateSheetWithData(
            weekIndex: weekIndex,
            slotIndex: slotIndex,
            templates: templates,
            savedWorkouts: savedWorkouts,
          );
        })
        .catchError((_) {
          if (!mounted) return;
          _showTemplateSheetWithData(
            weekIndex: weekIndex,
            slotIndex: slotIndex,
            templates: templates,
          );
        });
  }

  void _showTemplateSheetWithData({
    required int weekIndex,
    required int slotIndex,
    required List<ProgrammeBuilderTemplateDraft> templates,
    List<SavedWorkoutListItem>? savedWorkouts,
  }) {
    showModalBottomSheet<bool?>(
      context: context,
      builder: (ctx) => TemplateReassignmentBottomSheet(
        availableTemplates: templates,
        savedWorkouts: savedWorkouts,
        onSelected: (template) {
          _controller.assignTemplateToSlot(
            weekIndex: weekIndex,
            slotIndex: slotIndex,
            template: template,
          );
        },
        onSelectSavedWorkout: (item) {
          _importSavedWorkoutAsTemplate(
            weekIndex: weekIndex,
            slotIndex: slotIndex,
            savedWorkoutId: item.id,
          );
        },
      ),
    ).then((shouldCreate) {
      if (shouldCreate == true) {
        _showQuickCreateSheet(weekIndex, slotIndex);
      }
    });
  }

  void _importSavedWorkoutAsTemplate({
    required int weekIndex,
    required int slotIndex,
    required String savedWorkoutId,
  }) {
    final repo = ref.read(AppProviders.savedWorkoutRepositoryProvider);
    repo
        .getSavedWorkout(savedWorkoutId)
        .then((aggregate) {
          if (aggregate == null || !mounted) return;
          final converter = const SavedWorkoutToTemplateConverter();
          final template = converter.convert(aggregate);
          _controller.assignTemplateToSlot(
            weekIndex: weekIndex,
            slotIndex: slotIndex,
            template: template,
          );
        })
        .catchError((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppStrings.workoutLoadFailed)));
        });
  }

  void _showQuickCreateSheet(int weekIndex, int slotIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ProgrammeTemplateQuickCreateSheet(),
    ).then((result) {
      if (result is ProgrammeBuilderTemplateDraft && mounted) {
        _controller.assignTemplateToSlot(
          weekIndex: weekIndex,
          slotIndex: slotIndex,
          template: result,
        );
      }
    });
  }

  void _showSupersetSheet(int weekIndex, int slotIndex) {
    final weeks = widget.state.draft.weeks ?? [];
    if (weekIndex >= weeks.length) return;
    final slots = weeks[weekIndex].slots ?? [];
    if (slotIndex >= slots.length) return;
    final template = slots[slotIndex].template;
    if (template == null || template.exercises.isEmpty) return;

    final exercises = template.exercises;
    final selected = <String>{
      ...template.exercises
          .where((e) => e.supersetGroupId != null)
          .map((e) => e.id),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return ProgrammeSupersetEditorSheet(
              exercises: exercises,
              selectedExerciseIds: selected,
              activeGroupId: exercises.any((e) => e.supersetGroupId != null)
                  ? exercises
                        .firstWhere(
                          (e) => e.supersetGroupId != null,
                          orElse: () => exercises.first,
                        )
                        .supersetGroupId
                  : null,
              onToggleSelection: (id) {
                setSheetState(() {
                  selected.contains(id)
                      ? selected.remove(id)
                      : selected.add(id);
                });
              },
              onCreateSuperset: () {
                if (selected.length >= 2) {
                  _controller.createTemplateSuperset(
                    templateId: template.id,
                    selectedExerciseIds: selected.toList(),
                  );
                  ctx.pop();
                }
              },
              onRemoveMember: (exerciseId) {
                _controller.removeTemplateExerciseFromSuperset(
                  templateId: template.id,
                  exerciseId: exerciseId,
                );
                ctx.pop();
              },
              onDeleteGroup: () {
                final groupId = exercises
                    .firstWhere(
                      (e) => e.supersetGroupId != null,
                      orElse: () => exercises.first,
                    )
                    .supersetGroupId;
                if (groupId != null) {
                  _controller.deleteTemplateSuperset(
                    templateId: template.id,
                    groupId: groupId,
                  );
                }
                ctx.pop();
              },
            );
          },
        );
      },
    );
  }

  void _handleChangeSlotDay(int weekIndex, int slotIndex) {
    final slots = widget.state.draft.weeks?.elementAt(weekIndex).slots;
    if (slots == null || slotIndex >= slots.length) return;
    final currentDay = slots[slotIndex].scheduledDay;
    _showDayPicker(context, currentDay).then((selected) {
      if (selected != null && mounted) {
        _controller.updateSlotDay(
          weekIndex: weekIndex,
          slotIndex: slotIndex,
          day: selected,
        );
      }
    });
  }

  Future<TrainingDay?> _showDayPicker(
    BuildContext context,
    TrainingDay? currentDay,
  ) {
    return showModalBottomSheet<TrainingDay>(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.selectDay, style: context.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: TrainingDay.values.map((day) {
                  final isSelected = day == currentDay;
                  return ChoiceChip(
                    selected: isSelected,
                    label: Text(
                      day.fullDisplayLabel,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? context.colorScheme.onSecondary
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    selectedColor: context.colorScheme.secondary,
                    backgroundColor:
                        context.colorScheme.surfaceContainerHighest,
                    side: isSelected
                        ? BorderSide.none
                        : BorderSide(color: context.colorScheme.outlineVariant),
                    onSelected: (_) => Navigator.of(ctx).pop(day),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorStateView extends ConsumerWidget {
  const _ErrorStateView({required this.provider});

  final dynamic provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.exclamationCircle,
            width: AppSizing.iconXxl,
            height: AppSizing.iconXxl,
            colorFilter: ColorFilter.mode(
              context.colorScheme.error,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.programmeLoadFailed,
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => ref.invalidate(provider),
            child: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({required this.errors});

  final List<ProgrammeBuilderValidationError> errors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      color: context.theme.brightness == Brightness.light
          ? AedifyLightColors.errorSurface
          : AedifyDarkColors.errorSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              AppStrings.programmeInvalid,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ),
          ...errors.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  SvgPicture.asset(
                    OutlinedSvgAssets.exclamationTriangle,
                    width: AppSizing.iconSm,
                    height: AppSizing.iconSm,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.error,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(e.message, style: context.textTheme.bodySmall),
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
