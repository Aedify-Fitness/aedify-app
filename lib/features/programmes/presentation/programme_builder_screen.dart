import 'package:aedify/features/programmes/application/programme_review_summary.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_review.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_workout_scope_selector.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_back_gesture.dart';
import 'package:aedify/features/programmes/domain/programme_training_block_draft.dart';
import 'package:aedify/features/programmes/domain/programme_workout_repetition.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_training_blocks.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_state.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/application/programme_builder_controller.dart';
import 'package:aedify/features/programmes/application/programme_builder_mode.dart';
import 'package:aedify/features/programmes/application/programme_builder_phase.dart';
import 'package:aedify/features/programmes/application/programme_builder_state.dart';
import 'package:aedify/features/programmes/application/programme_builder_step_validator.dart';
import 'package:aedify/features/programmes/application/saved_workout_to_template_converter.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';
import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_details_page.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_schedule.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_workouts.dart';
import 'package:aedify/features/workout_builder/presentation/widgets/add_exercise_bottom_sheet.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_weeks_overview.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_action_bar.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_error_banner.dart';
import 'package:aedify/features/programmes/presentation/widgets/discard_programme_changes_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/active_programme_warning_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/template_reassignment_bottom_sheet.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_superset_editor_sheet.dart';
import 'package:aedify/features/programmes/application/slot_day_assignment.dart';
import 'package:aedify/shared/components/app_bottom_sheet.dart';
import 'package:aedify/shared/components/app_icon_button.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
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
      loading: () => _BuilderScaffold(
        mode: mode,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => _BuilderScaffold(
        mode: mode,
        child: _ErrorStateView(provider: provider),
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
  final AsyncNotifierProvider<ProgrammeBuilderController, ProgrammeBuilderState>
  provider;

  @override
  ConsumerState<_ProgrammeBuilderBody> createState() =>
      _ProgrammeBuilderBodyState();
}

class _ProgrammeBuilderBodyState extends ConsumerState<_ProgrammeBuilderBody> {
  static final _logger = AppLogger(name: 'ProgrammeBuilder._Body');

  late TextEditingController _nameController;
  bool _allowPop = false;
  bool _exitPending = false;
  bool _lastSaveWasDraft = false;
  late ProgrammeReviewSummary _reviewSummary;
  int _step = 0;
  bool _showDetailsErrors = false;
  final ScrollController _scrollController = ScrollController();
  int _weekIndex = 0;
  Set<int> _repeatedSlotIndices = {};
  ({String templateId, String exerciseId, int revision})? _workoutSelection;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _reviewSummary = ProgrammeReviewSummary.fromDraft(widget.state.draft);
    _repeatedSlotIndices = ProgrammeWorkoutRepetition.repeatedSlots(
      widget.state.draft,
      _weekIndex,
    );
    _nameController = TextEditingController(text: widget.state.draft.name);
    _descriptionController = TextEditingController(
      text: widget.state.draft.description ?? '',
    );
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
    if (_step == 4 && !identical(oldWidget.state.draft, widget.state.draft)) {
      _reviewSummary = ProgrammeReviewSummary.fromDraft(widget.state.draft);
    }
    if (_nameController.text != widget.state.draft.name) {
      _nameController.text = widget.state.draft.name;
    }
    if (_descriptionController.text != (widget.state.draft.description ?? '')) {
      _descriptionController.text = widget.state.draft.description ?? '';
    }
    final weekCount = widget.state.draft.weeks?.length ?? 0;
    if (_weekIndex >= weekCount) {
      _weekIndex = weekCount == 0 ? 0 : weekCount - 1;
    }
    if ((_step == 2 || _step == 3) &&
        !identical(oldWidget.state.draft, widget.state.draft)) {
      _repeatedSlotIndices = ProgrammeWorkoutRepetition.repeatedSlots(
        widget.state.draft,
        _weekIndex,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  ProgrammeBuilderController get _controller =>
      ref.read(widget.provider.notifier);

  Future<void> _requestExit() async {
    if (_exitPending || widget.state.isSaving) return;
    final current = ref.read(widget.provider).asData?.value;
    if (!(current?.isDirty ?? widget.state.isDirty)) {
      context.pop();
      return;
    }

    _exitPending = true;
    bool? discard;
    try {
      discard = await showDialog<bool>(
        context: context,
        builder: (_) => const DiscardProgrammeChangesDialog(),
      );
    } finally {
      _exitPending = false;
    }
    if (discard != true || !mounted) return;

    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  void _goBack() {
    if (widget.state.isSaving) return;
    if (_step > 0) {
      _selectStep(_step - 1);
    } else {
      _requestExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final stepErrors = switch (_step) {
      1 => ProgrammeBuilderStepValidator.blocks(state.draft),
      2 => ProgrammeBuilderStepValidator.schedule(state.draft),
      3 => ProgrammeBuilderStepValidator.workouts(state.draft),
      _ => <ProgrammeBuilderValidationError>[],
    };
    return PopScope(
      canPop: _allowPop || (_step == 0 && !state.isDirty && !state.isSaving),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack();
      },
      child: ProgrammeBuilderBackGesture(
        enabled: !state.isSaving,
        onBack: _goBack,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          extendBody: true,
          backgroundColor: context.colorScheme.surface,
          bottomNavigationBar: _step == 4
              ? ProgrammeBuilderActionBar(
                  title: AppStrings.programmeReadyToPublish,
                  subtitle: AppStrings.programmeBuilderStep(5),
                  actionLabel: state.isSaving
                      ? AppStrings.loading
                      : AppStrings.publish,
                  actionKey: const ValueKey('programme_builder_publish'),
                  asset: OutlinedSvgAssets.arrowUpTray,
                  isSaving: state.isSaving,
                  onPressed: state.isSaving ? null : _saveProgramme,
                )
              : _BuilderNextBar(
                  step: _step,
                  enabled:
                      !state.isSaving &&
                      state.hasRequiredDetails &&
                      stepErrors.isEmpty,
                  onNext: () => _selectStep(_step + 1),
                ),
          body: Builder(
            builder: (context) => SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _ProgrammeBuilderHeader(
                    mode: widget.mode,
                    step: _step,
                    onBack: state.isSaving ? null : _goBack,
                    onSaveDraft: state.isSaving ? null : _saveDraft,
                  ),
                  if (_step > 0) ...[
                    _BuilderProgress(step: _step, onSelect: _selectStep),
                    AppWhiteSpace.hSm,
                  ],
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        key: ValueKey('programme_builder_scroll_$_step'),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.only(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          top: _step == 0 ? AppSpacing.xl : 0,
                          bottom:
                              MediaQuery.paddingOf(context).bottom +
                              AppSpacing.xl,
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.errorMessage != null) ...[
                                ProgrammeBuilderErrorBanner(
                                  errorCode: state.errorCode,
                                  errorMessage: state.errorMessage!,
                                  onRetry: state.isDirty
                                      ? () => _saveProgramme(
                                          asDraft: _lastSaveWasDraft,
                                        )
                                      : () => ref.invalidate(widget.provider),
                                ),
                                AppWhiteSpace.hMd,
                              ],
                              if (state.hasValidationErrors) ...[
                                _ValidationBanner(
                                  errors: state.validationErrors,
                                ),
                                AppWhiteSpace.hMd,
                              ],
                              if (stepErrors.isNotEmpty) ...[
                                _ValidationBanner(errors: stepErrors),
                                AppWhiteSpace.hMd,
                              ],
                              AbsorbPointer(
                                absorbing: state.isSaving,
                                child: _stepContent(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepContent() {
    final state = widget.state;
    final weeks = state.draft.weeks ?? [];
    if (_step == 0) {
      return ProgrammeBuilderDetailsPage(
        draft: state.draft,
        nameController: _nameController,
        descriptionController: _descriptionController,
        nameError: _showDetailsErrors && state.draft.name.trim().isEmpty
            ? AppStrings.programmeNameRequired
            : null,
        goalsError:
            _showDetailsErrors && (state.draft.goalTags?.isEmpty ?? true)
            ? AppStrings.programmeGoalsRequired
            : null,
        onNameChanged: _controller.updateName,
        onDescriptionChanged: _controller.updateDescription,
        onGoalsChanged: _controller.setGoalTags,
      );
    }
    if (_step == 1) {
      return ProgrammeBuilderTrainingBlocks(
        blocks: state.draft.trainingBlocks,
        onAdd: _controller.addTrainingBlock,
        onUpdate: (id, {name, focus, progressionNotes}) =>
            _controller.updateTrainingBlock(
              id,
              name: name,
              focus: focus,
              progressionNotes: progressionNotes,
            ),
        onResize: _resizeTrainingBlock,
        onRemove: _removeTrainingBlock,
        onToggleTrainingDay: _toggleBlockTrainingDay,
      );
    }
    if (_step == 2) {
      return ProgrammeBuilderSchedule(
        blockLabel: ProgrammeTrainingBlockDraft.forWeek(
          state.draft.trainingBlocks,
          _weekIndex,
        )?.name,
        weeks: weeks,
        weekIndex: _weekIndex,
        onWeekChanged: (index) => setState(() {
          _weekIndex = index;
          _repeatedSlotIndices = ProgrammeWorkoutRepetition.repeatedSlots(
            state.draft,
            index,
          );
        }),
        repeatedSlotIndices: _repeatedSlotIndices,
        onToggleDay: (day, enabled) =>
            _controller.setTrainingDay(day, enabled, weekIndex: _weekIndex),
        onAssignDay: _assignDayTemplate,
        onRepeatTemplate: _canRepeatWeek(_weekIndex)
            ? (slotIndex) =>
                  _repeatAssignedWorkout(_weekIndex, slotIndex, confirm: true)
            : null,
        onClearTemplate: (index) =>
            _controller.clearSlotTemplate(_weekIndex, index),
      );
    }
    if (_step == 3) {
      return ProgrammeBuilderWorkouts(
        blockLabel: ProgrammeTrainingBlockDraft.forWeek(
          state.draft.trainingBlocks,
          _weekIndex,
        )?.name,
        weekIndex: _weekIndex,
        onWeekChanged: (index) => setState(() {
          _weekIndex = index;
          _repeatedSlotIndices = ProgrammeWorkoutRepetition.repeatedSlots(
            state.draft,
            index,
          );
        }),
        repeatedSlotIndices: _repeatedSlotIndices,
        selection: _workoutSelection,
        weeks: weeks,
        controller: _controller,
        enabled: !state.isSaving,
        onAddDay: () => _controller.addWorkoutDay(_weekIndex),
        onRemoveDay: (weekIndex, slotIndex) =>
            _controller.removeSlot(weekIndex, slotIndex),
        onAssignTemplate: _showTemplateSheet,
        onRepeatTemplate: _canRepeatWeek(_weekIndex)
            ? _repeatAssignedWorkout
            : null,
        onAddExercises: _addTemplateExercises,
        onEditSuperset: _showSupersetSheet,
        weekManagement: ProgrammeWeeksOverview(
          weeks: weeks,
          onAddWeek: () => _controller.addWeek(),
          onRemoveWeek: (index) => _controller.removeWeek(index),
          onDuplicateWeek: (index) => _controller.duplicateWeek(index),
          onAddSlot: _addSlot,
          onRemoveSlot: (weekIndex, slotIndex) =>
              _controller.removeSlot(weekIndex, slotIndex),
          onAssignTemplate: (weekIndex, slotIndex) =>
              _showTemplateSheet(weekIndex, slotIndex),
          onOpenSupersetEditor: (weekIndex, slotIndex) =>
              _showSupersetSheet(weekIndex, slotIndex),
          onSetWeekType: (weekIndex, type) =>
              _controller.setWeekType(weekIndex: weekIndex, type: type),
          onEditExercise: _editWeekExercise,
          onAddExercises: (weekIndex, slotIndex) {
            final template =
                widget.state.draft.weeks?[weekIndex].slots?[slotIndex].template;
            if (template != null) _addTemplateExercises(template.id);
          },
          onChangeSlotDay: (weekIndex, slotIndex) =>
              _handleChangeSlotDay(weekIndex, slotIndex),
        ),
      );
    }

    return ProgrammeBuilderReview(draft: state.draft, summary: _reviewSummary);
  }

  void _selectAssignedWorkout(int weekIndex, int slotIndex) {
    if (_step != 3 || !mounted) return;
    final template = ref
        .read(widget.provider)
        .asData
        ?.value
        .draft
        .weeks?[weekIndex]
        .slots?[slotIndex]
        .template;
    if (template == null) return;
    setState(() {
      _weekIndex = weekIndex;
      _repeatedSlotIndices = ProgrammeWorkoutRepetition.repeatedSlots(
        widget.state.draft,
        weekIndex,
      );
      _workoutSelection = (
        templateId: template.id,
        exerciseId: template.exercises.firstOrNull?.id ?? '',
        revision: (_workoutSelection?.revision ?? 0) + 1,
      );
    });
  }

  void _editWeekExercise(int weekIndex, int slotIndex, String exerciseId) {
    final template =
        widget.state.draft.weeks?[weekIndex].slots?[slotIndex].template;
    if (template == null || widget.state.isSaving) return;
    setState(() {
      _weekIndex = weekIndex;
      _repeatedSlotIndices = ProgrammeWorkoutRepetition.repeatedSlots(
        widget.state.draft,
        weekIndex,
      );
      _workoutSelection = (
        templateId: template.id,
        exerciseId: exerciseId,
        revision: (_workoutSelection?.revision ?? 0) + 1,
      );
    });
  }

  Future<void> _addTemplateExercises(String templateId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddExerciseBottomSheet(
        onSelectExercises: (exercises) =>
            _controller.addTemplateExercises(templateId, exercises),
      ),
    );
    if (!mounted) return;
    ref
        .read(AppProviders.exerciseSearchControllerProvider.notifier)
        .clearFilters();
  }

  bool _validateDetails() {
    final state = ref.read(widget.provider).asData?.value ?? widget.state;
    if (state.hasRequiredDetails) return true;
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    setState(() {
      _step = 0;
      _showDetailsErrors = true;
    });
    return false;
  }

  void _selectStep(int step) {
    final state = ref.read(widget.provider).asData?.value ?? widget.state;
    if (state.isSaving) return;
    if (step > 0 && !_validateDetails()) return;
    if (step > _step && step > 1) {
      final blockErrors = ProgrammeBuilderStepValidator.blocks(state.draft);
      if (blockErrors.isNotEmpty) {
        _showIncompleteStep(1, blockErrors);
        return;
      }
      if (step > 2) {
        final scheduleErrors = ProgrammeBuilderStepValidator.schedule(
          state.draft,
        );
        if (scheduleErrors.isNotEmpty) {
          _showIncompleteStep(2, scheduleErrors);
          return;
        }
      }
      if (step > 3) {
        final workoutErrors = ProgrammeBuilderStepValidator.workouts(
          state.draft,
        );
        if (workoutErrors.isNotEmpty) {
          _showIncompleteStep(3, workoutErrors);
          return;
        }
      }
    }
    FocusScope.of(context).unfocus();
    if (step == 2 || step == 3) {
      _repeatedSlotIndices = ProgrammeWorkoutRepetition.repeatedSlots(
        state.draft,
        _weekIndex,
      );
    }
    if (step == 4) {
      _reviewSummary = ProgrammeReviewSummary.fromDraft(state.draft);
    }
    setState(() => _step = step);
  }

  void _showIncompleteStep(
    int step,
    List<ProgrammeBuilderValidationError> errors,
  ) {
    FocusScope.of(context).unfocus();
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    setState(() {
      _step = step;
      _weekIndex = errors.first.weekIndex ?? 0;
      if (step == 2 || step == 3) {
        _repeatedSlotIndices = ProgrammeWorkoutRepetition.repeatedSlots(
          widget.state.draft,
          _weekIndex,
        );
      }
    });
  }

  Future<void> _toggleBlockTrainingDay(
    ProgrammeTrainingBlockDraft block,
    TrainingDay day,
  ) async {
    final enabled = !block.trainingDays.contains(day);
    if (!enabled) {
      final draft = ref.read(widget.provider).requireValue.draft;
      final index = draft.trainingBlocks.indexWhere(
        (item) => item.id == block.id,
      );
      if (index < 0) return;
      final start = draft.trainingBlocks
          .take(index)
          .fold<int>(0, (sum, item) => sum + item.weekCount);
      final removesWorkouts = (draft.weeks ?? [])
          .skip(start)
          .take(block.weekCount)
          .any(
            (week) =>
                week.slots?.any(
                  (slot) =>
                      slot.scheduledDayIndex == day.index &&
                      slot.template != null,
                ) ??
                false,
          );
      if (removesWorkouts) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text(AppStrings.removeBlockTrainingDay),
            content: Text(
              AppStrings.removeBlockTrainingDayMessage(day.fullDisplayLabel),
            ),
            actions: [
              TextButton(
                onPressed: () => dialogContext.pop(false),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () => dialogContext.pop(true),
                child: const Text(AppStrings.continueLabel),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
      }
    }
    if (mounted) _controller.setBlockTrainingDay(block.id, day, enabled);
  }

  Future<bool> _confirmBlockRemoval(
    ProgrammeTrainingBlockDraft block, {
    int remainingWeeks = 0,
  }) async {
    final draft = ref.read(widget.provider).requireValue.draft;
    final index = draft.trainingBlocks.indexWhere(
      (item) => item.id == block.id,
    );
    if (index < 0) return false;
    final start = draft.trainingBlocks
        .take(index)
        .fold<int>(0, (sum, item) => sum + item.weekCount);
    final affected = (draft.weeks ?? [])
        .skip(start + remainingWeeks)
        .take(block.weekCount - remainingWeeks);
    if (!affected.any((week) => week.slots?.isNotEmpty ?? false)) return true;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              remainingWeeks == 0
                  ? AppStrings.removeTrainingBlock
                  : AppStrings.shortenProgramme,
            ),
            content: Text(
              remainingWeeks == 0
                  ? AppStrings.removeTrainingBlockMessage
                  : AppStrings.shortenProgrammeMessage,
            ),
            actions: [
              TextButton(
                onPressed: () => dialogContext.pop(false),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () => dialogContext.pop(true),
                child: const Text(AppStrings.continueLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _resizeTrainingBlock(
    ProgrammeTrainingBlockDraft block,
    int count,
  ) async {
    if (count < block.weekCount &&
        !await _confirmBlockRemoval(block, remainingWeeks: count)) {
      return;
    }
    if (mounted) _controller.updateTrainingBlock(block.id, weekCount: count);
  }

  Future<void> _removeTrainingBlock(ProgrammeTrainingBlockDraft block) async {
    if (await _confirmBlockRemoval(block) && mounted) {
      _controller.removeTrainingBlock(block.id);
    }
  }

  void _assignDayTemplate(TrainingDay day, int? slotIndex) {
    if (slotIndex == null) {
      _controller.setTrainingDay(day, true, weekIndex: _weekIndex);
      final current = ref.read(widget.provider).asData?.value;
      slotIndex = current?.draft.weeks?[_weekIndex].slots?.indexWhere(
        (slot) => slot.scheduledDayIndex == TrainingDay.values.indexOf(day),
      );
    }
    if (slotIndex == null || slotIndex < 0) return;
    _showTemplateSheet(_weekIndex, slotIndex);
  }

  Future<void> _saveDraft() async {
    await _saveProgramme(asDraft: true);
  }

  Future<void> _addSlot(int weekIndex) async {
    _logger.debug('onAddSlot weekIndex=$weekIndex');
    final week = widget.state.draft.weeks?.elementAt(weekIndex);
    final slotCount = week?.slots?.length ?? 0;
    _logger.debug('onAddSlot slotCount=$slotCount');
    var scheduledDayIndex = slotCount;
    TrainingDay? scheduledDay;

    final profileRepo = ref.read(AppProviders.profileRepositoryProvider);
    final profile = await profileRepo.getProfile();
    final trainingDays = profile?.trainingDays ?? [];
    if (trainingDays.isNotEmpty) {
      final assigned = SlotDayAssignment.assignDaySlots(
        trainingDays,
        slotCount + 1,
      );
      if (assigned.isNotEmpty) {
        final day = assigned.last;
        scheduledDayIndex = TrainingDay.values.indexOf(day);
        scheduledDay = day;
      }
    }
    _controller.addSlot(
      weekIndex: weekIndex,
      scheduledDayIndex: scheduledDayIndex,
      scheduledDay: scheduledDay,
    );
  }

  Future<void> _saveProgramme({bool asDraft = false}) async {
    _lastSaveWasDraft = asDraft;
    if (asDraft) {
      await _controller.saveDraft();
    } else {
      await _controller.saveProgramme();
    }
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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? asDraft
                    ? AppStrings.programmeDraftSaved
                    : AppStrings.programmeSaved
              : AppStrings.programmeSaveFailed,
        ),
      ),
    );
    if (!saved) return;

    final programmeId = widget.state.programmeId;
    setState(() => _allowPop = true);
    ref.read(AppProviders.programmeLibraryControllerProvider.notifier).reload();
    if (programmeId != null) {
      ref
          .read(
            AppProviders.programmeCalendarControllerProvider(
              programmeId,
            ).notifier,
          )
          .reload();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  bool _canRepeatWeek(int weekIndex) =>
      (ProgrammeTrainingBlockDraft.forWeek(
            widget.state.draft.trainingBlocks,
            weekIndex,
          )?.weekCount ??
          0) >
      1;

  Future<void> _repeatAssignedWorkout(
    int weekIndex,
    int slotIndex, {
    bool confirm = false,
  }) async {
    final current = ref.read(widget.provider).asData?.value;
    if (current == null || current.isSaving) return;
    final weeks = current.draft.weeks ?? [];
    if (weekIndex < 0 || weekIndex >= weeks.length) return;
    final slots = weeks[weekIndex].slots ?? [];
    if (slotIndex < 0 ||
        slotIndex >= slots.length ||
        slots[slotIndex].template == null) {
      return;
    }
    final block = ProgrammeTrainingBlockDraft.forWeek(
      current.draft.trainingBlocks,
      weekIndex,
    );
    if (block == null || block.weekCount < 2) return;
    if (confirm) {
      final day =
          TrainingDay.values[slots[slotIndex].scheduledDayIndex %
              TrainingDay.values.length];
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          scrollable: true,
          title: const Text(AppStrings.programmeWorkoutScope),
          content: Text(
            AppStrings.programmeRepeatWorkoutConfirm(
              day.fullDisplayLabel,
              block.name,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text(AppStrings.programmeCustomDay),
            ),
            FilledButton(
              onPressed: () => dialogContext.pop(true),
              child: const Text(AppStrings.programmeRepeatInBlock),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    _controller.repeatWorkoutAcrossBlock(
      weekIndex: weekIndex,
      slotIndex: slotIndex,
    );
  }

  void _showTemplateSheet(int weekIndex, int slotIndex) {
    final state = widget.state;
    final templates =
        state.draft.weeks
            ?.expand((w) => w.slots ?? [])
            .map((s) => s.template)
            .whereType<ProgrammeBuilderTemplateDraft>()
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
    var repeatAcrossBlock = false;
    showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: context.colorScheme.surface.withValues(alpha: 0),
      builder: (ctx) => TemplateReassignmentBottomSheet(
        availableTemplates: templates,
        savedWorkouts: savedWorkouts,
        assignmentScope: _canRepeatWeek(weekIndex)
            ? ProgrammeWorkoutScopeSelector(
                onChanged: (repeat) => repeatAcrossBlock = repeat,
              )
            : null,
        onSelected: (template) async {
          await _controller.assignTemplateToSlot(
            weekIndex: weekIndex,
            slotIndex: slotIndex,
            template: template,
          );
          if (repeatAcrossBlock && mounted) {
            await _repeatAssignedWorkout(weekIndex, slotIndex);
          }
          _selectAssignedWorkout(weekIndex, slotIndex);
        },
        onSelectSavedWorkout: (item) {
          _importSavedWorkoutAsTemplate(
            weekIndex: weekIndex,
            slotIndex: slotIndex,
            savedWorkoutId: item.id,
            repeatAcrossBlock: repeatAcrossBlock,
          );
        },
      ),
    ).then((shouldCreate) {
      if (shouldCreate == true) {
        _createProgrammeTemplate(
          weekIndex,
          slotIndex,
          repeatAcrossBlock: repeatAcrossBlock,
        );
      }
    });
  }

  void _importSavedWorkoutAsTemplate({
    required int weekIndex,
    required int slotIndex,
    required String savedWorkoutId,
    bool repeatAcrossBlock = false,
  }) {
    final repo = ref.read(AppProviders.savedWorkoutRepositoryProvider);
    repo
        .getSavedWorkout(savedWorkoutId)
        .then((aggregate) async {
          if (aggregate == null || !mounted) return;
          final converter = const SavedWorkoutToTemplateConverter();
          final template = converter.convert(aggregate);
          await _controller.assignTemplateToSlot(
            weekIndex: weekIndex,
            slotIndex: slotIndex,
            template: template,
          );
          if (repeatAcrossBlock && mounted) {
            await _repeatAssignedWorkout(weekIndex, slotIndex);
          }
          _selectAssignedWorkout(weekIndex, slotIndex);
        })
        .catchError((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppStrings.workoutLoadFailed)));
        });
  }

  Future<void> _createProgrammeTemplate(
    int weekIndex,
    int? slotIndex, {
    bool repeatAcrossBlock = false,
  }) async {
    if (!mounted) return;
    ref.invalidate(
      AppProviders.workoutBuilderControllerProvider((
        mode: WorkoutBuilderMode.programmeTemplate,
        savedWorkoutId: null,
      )),
    );
    final draft = await context.pushNamed<WorkoutBuilderDraft>(
      AppRoutes.programmeWorkoutBuilderCreate().name,
    );
    if (draft == null || !mounted) return;
    await _controller.assignWorkoutDraftToSlot(
      weekIndex: weekIndex,
      slotIndex: slotIndex,
      draft: draft,
    );
    if (!mounted) return;
    final assignedSlot =
        slotIndex ??
        ((ref
                    .read(widget.provider)
                    .asData
                    ?.value
                    .draft
                    .weeks?[weekIndex]
                    .slots
                    ?.length ??
                1) -
            1);
    if (repeatAcrossBlock && mounted) {
      await _repeatAssignedWorkout(weekIndex, assignedSlot);
    }
    if (!mounted) return;
    _selectAssignedWorkout(weekIndex, assignedSlot);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.templateCreated)));
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
      backgroundColor: context.colorScheme.surface.withValues(alpha: 0),
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
      backgroundColor: context.colorScheme.surface.withValues(alpha: 0),
      builder: (ctx) {
        return AppBottomSheet(
          title: AppStrings.selectDay,
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.lg,
            ),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: TrainingDay.values.map((day) {
                return _DaySelectionPill(
                  day: day,
                  isSelected: day == currentDay,
                  onTap: () => ctx.pop(day),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _BuilderScaffold extends StatelessWidget {
  const _BuilderScaffold({required this.mode, required this.child});

  final ProgrammeBuilderMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ProgrammeBuilderHeader(mode: mode, onBack: () => context.pop()),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _ProgrammeBuilderHeader extends StatelessWidget {
  const _ProgrammeBuilderHeader({
    required this.mode,
    this.step = 0,
    this.onBack,
    this.onSaveDraft,
  });
  final ProgrammeBuilderMode mode;
  final int step;
  final VoidCallback? onBack;
  final VoidCallback? onSaveDraft;
  String get _title => step > 0
      ? _BuilderSteps.labels[step]
      : switch (mode) {
          ProgrammeBuilderMode.create => AppStrings.programmeCreateTitle,
          ProgrammeBuilderMode.edit => AppStrings.editProgramme,
          ProgrammeBuilderMode.duplicate => AppStrings.duplicateProgramme,
        };
  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('programme_builder_header'),
    constraints: const BoxConstraints(
      minHeight: AppProgrammeBuilderTokens.headerMinHeight,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    color: context.colorScheme.surface,
    child: Row(
      children: [
        AppIconButton(
          key: const ValueKey('programme_builder_back'),
          asset: OutlinedSvgAssets.arrowLeft,
          onPressed: onBack,
          semanticLabel: AppStrings.backLabel,
        ),
        AppWhiteSpace.wSm,
        Expanded(
          child: Text(
            _title,
            style: AppTextStyles.headlineMd.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: AppProgrammeBuilderTokens.saveDraftWidth,
          child: TextButton(
            key: const ValueKey('programme_save_draft'),
            onPressed: onSaveDraft,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
              foregroundColor: context.colorScheme.secondary,
              textStyle: AppTextStyles.labelMd,
            ),
            child: const Text(
              AppStrings.saveDraft,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );
}

class _BuilderSteps {
  _BuilderSteps._();
  static const labels = [
    AppStrings.programmeDetailsSectionTitle,
    AppStrings.trainingBlocks,
    AppStrings.weeklySchedule,
    AppStrings.defineWorkouts,
    AppStrings.reviewAndPublish,
  ];
}

class _BuilderProgress extends StatelessWidget {
  const _BuilderProgress({required this.step, required this.onSelect});
  final int step;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: Row(
      children: List.generate(
        _BuilderSteps.labels.length,
        (index) => Expanded(
          child: Semantics(
            button: true,
            selected: index == step,
            label: _BuilderSteps.labels[index],
            child: InkWell(
              onTap: () => onSelect(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.formFieldVertical,
                ),
                child: Container(
                  height: AppSizing.activeIndicatorHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    color: index <= step
                        ? context.colorScheme.secondary
                        : context.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _BuilderNextBar extends StatelessWidget {
  const _BuilderNextBar({
    required this.step,
    required this.enabled,
    required this.onNext,
  });
  final int step;
  final bool enabled;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) => ProgrammeBuilderActionBar(
    key: const ValueKey('programme_builder_next_bar'),
    title: switch (step) {
      0 => AppStrings.nextTrainingBlocks,
      1 => AppStrings.nextWeeklySchedule,
      2 => AppStrings.nextDefineWorkouts,
      _ => AppStrings.nextReviewAndPublish,
    },
    actionLabel: AppStrings.proceed,
    actionKey: const ValueKey('programme_builder_next'),
    asset: step == 0
        ? OutlinedSvgAssets.rocketLaunch
        : step == 1
        ? OutlinedSvgAssets.calendarDays
        : OutlinedSvgAssets.checkCircle,
    onPressed: enabled ? onNext : null,
  );
}

class _DaySelectionPill extends StatelessWidget {
  const _DaySelectionPill({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final TrainingDay day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: day.fullDisplayLabel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: AppSizing.cardBadge),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? colorScheme.secondary
                : colorScheme.outlineVariant,
            width: AppSizing.hairlineStrokeWidth,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    SvgPicture.asset(
                      OutlinedSvgAssets.check,
                      width: AppSizing.iconXs,
                      height: AppSizing.iconXs,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSecondaryContainer,
                        BlendMode.srcIn,
                      ),
                    ),
                    AppWhiteSpace.wXs,
                  ],
                  Text(
                    day.fullDisplayLabel,
                    style: AppTextStyles.labelMd.copyWith(
                      color: isSelected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorStateView extends ConsumerWidget {
  const _ErrorStateView({required this.provider});

  final AsyncNotifierProvider<ProgrammeBuilderController, ProgrammeBuilderState>
  provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
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
            AppWhiteSpace.hMd,
            Text(
              AppStrings.programmeLoadFailed,
              style: AppTextStyles.bodyLg.copyWith(
                color: context.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hMd,
            FilledButton(
              onPressed: () => ref.invalidate(provider),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({required this.errors});

  final List<ProgrammeBuilderValidationError> errors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.brightness == Brightness.light
            ? AedifyLightColors.errorSurface
            : AedifyDarkColors.errorSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.colorScheme.error.withValues(alpha: 0.24),
          width: AppSizing.hairlineStrokeWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  OutlinedSvgAssets.exclamationTriangle,
                  width: AppSizing.iconMd,
                  height: AppSizing.iconMd,
                  colorFilter: ColorFilter.mode(
                    context.colorScheme.error,
                    BlendMode.srcIn,
                  ),
                ),
                AppWhiteSpace.wSm,
                Expanded(
                  child: Text(
                    AppStrings.programmeInvalid,
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            AppWhiteSpace.hSm,
            ...errors.map(
              (error) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  error.message,
                  style: AppTextStyles.bodySm.copyWith(
                    color: context.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
