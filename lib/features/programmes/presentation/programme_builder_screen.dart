import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/application/programme_builder_controller.dart';
import 'package:aedify/features/programmes/application/programme_builder_mode.dart';
import 'package:aedify/features/programmes/application/programme_builder_phase.dart';
import 'package:aedify/features/programmes/application/programme_builder_state.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_details_section.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_weeks_overview.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_save_bar.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_builder_error_banner.dart';
import 'package:aedify/features/programmes/presentation/widgets/discard_programme_changes_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/template_reassignment_bottom_sheet.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

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
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.draft.name);
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
            Navigator.of(context).pop();
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProgrammeDetailsSection(
                      nameController: _nameController,
                      onNameChanged: (value) => _controller.updateName(value),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ProgrammeWeeksOverview(
                      weeks: weeks,
                      onAddWeek: () => _controller.addWeek(),
                      onRemoveWeek: (index) => _controller.removeWeek(index),
                      onDuplicateWeek: (index) =>
                          _controller.duplicateWeek(index),
                      onAddSlot: (weekIndex) => _controller.addSlot(
                        weekIndex: weekIndex,
                        scheduledDayIndex: weekIndex,
                      ),
                      onRemoveSlot: (weekIndex, slotIndex) =>
                          _controller.removeSlot(weekIndex, slotIndex),
                      onAssignTemplate: (weekIndex, slotIndex) {
                        _showTemplateSheet(weekIndex, slotIndex);
                      },
                    ),
                  ],
                ),
              ),
            ),
            ProgrammeSaveBar(
              state: state,
              onSave: () async {
                await _controller.saveProgramme();
                final currentState = ref.read(widget.provider);
                if (currentState is AsyncData &&
                    !currentState.value.hasValidationErrors &&
                    currentState.value.phase != ProgrammeBuilderPhase.failure &&
                    context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.programmeSaved)),
                  );
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
    showModalBottomSheet(
      context: context,
      builder: (ctx) => TemplateReassignmentBottomSheet(
        availableTemplates: templates,
        onSelected: (template) {
          _controller.assignTemplateToSlot(
            weekIndex: weekIndex,
            slotIndex: slotIndex,
            template: template,
          );
        },
      ),
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
