import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/profile/application/profile_controller.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(AppProviders.profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileEdit)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _ErrorView(
          message: AppErrorStrings.profileLoadFailedMessage,
          onRetry: () => ref
              .read(AppProviders.profileControllerProvider.notifier)
              .reload(),
        ),
        data: (state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.hasError) {
            return _ErrorView(
              message:
                  state.errorMessage ??
                  AppErrorStrings.profileLoadFailedMessage,
              onRetry: () => ref
                  .read(AppProviders.profileControllerProvider.notifier)
                  .reload(),
            );
          }
          return _ProfileContentView(state: state);
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationCircle,
              width: AppSpacing.xxl,
              height: AppSpacing.xxl,
              colorFilter: ColorFilter.mode(
                context.colorScheme.error,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.hMd,
            Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppWhiteSpace.hLg,
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContentView extends ConsumerWidget {
  const _ProfileContentView({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      AppProviders.profileControllerProvider.notifier,
    );
    final draft = state.draft ?? const ProfileEditDraft();
    final impact = state.impact;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.validationMessage != null)
            _ValidationBanner(message: state.validationMessage!),
          if (state.errorMessage != null && state.validationMessage == null)
            _ValidationBanner(message: state.errorMessage!, isError: true),
          if (impact == ProfileSaveImpact.mayAffectActiveProgrammes)
            _ImpactWarning(message: AppStrings.profileUpdateMayAffectPrograms),

          // Display name
          _FormField(
            label: AppStrings.displayName,
            initialValue: draft.displayName ?? '',
            hintText: AppStrings.displayName,
            onChanged: (value) {
              controller.updateDraft(
                draft.copyWith(displayName: value.isEmpty ? null : value),
              );
            },
          ),
          AppWhiteSpace.hMd,

          // Experience Level
          _SectionCard(
            title: AppStrings.experienceLevel,
            child: _ChipSelector(
              options: const [
                'Beginner (0–6 mo)',
                'Intermediate (6 mo–2 yr)',
                'Advanced (2+ yr)',
              ],
              selected: draft.experienceLevel,
              onSelected: (value) {
                controller.updateDraft(draft.copyWith(experienceLevel: value));
              },
            ),
          ),
          AppWhiteSpace.hMd,

          // Sex
          _SectionCard(
            title: AppStrings.sex,
            child: _ChipSelector(
              options: const [
                AppStrings.sexMale,
                AppStrings.sexFemale,
                AppStrings.sexNotSpecified,
              ],
              selected: draft.sex,
              onSelected: (value) {
                controller.updateDraft(draft.copyWith(sex: value));
              },
            ),
          ),
          AppWhiteSpace.hMd,

          // Date of birth
          _SectionCard(
            title: AppStrings.dateOfBirth,
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: draft.dateOfBirth ?? DateTime(1990),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  controller.updateDraft(draft.copyWith(dateOfBirth: picked));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      OutlinedSvgAssets.calendarDays,
                      width: AppSizing.iconMd,
                      height: AppSizing.iconMd,
                      colorFilter: ColorFilter.mode(
                        context.colorScheme.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                    AppWhiteSpace.wMd,
                    Text(
                      draft.dateOfBirth != null
                          ? DateFormat('MMM d, yyyy').format(draft.dateOfBirth!)
                          : AppStrings.selectDate,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: draft.dateOfBirth != null
                            ? context.colorScheme.onSurface
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppWhiteSpace.hMd,

          // Goals
          _SectionCard(
            title: AppStrings.goals,
            child: _ChipSelector(
              options: const [
                'Build muscle',
                'Lose weight',
                'Increase strength',
                'Improve endurance',
                'General fitness',
                'Flexibility',
              ],
              selected: null,
              selectedSet: draft.goals.toSet(),
              onSelectedSet: (value) {
                final updated = draft.goals.contains(value)
                    ? draft.goals.where((g) => g != value).toList()
                    : [...draft.goals, value];
                controller.updateDraft(draft.copyWith(goals: updated));
              },
            ),
          ),
          AppWhiteSpace.hMd,

          // Equipment
          _SectionCard(
            title: AppStrings.equipment,
            child: _ChipSelector(
              options: const [
                'None / bodyweight',
                'Dumbbells',
                'Barbell',
                'Kettlebell',
                'Resistance bands',
                'Cable machine',
                'Smith machine',
                'Pull-up bar',
                'Bench',
                'Squat rack',
                'Cardio machine',
              ],
              selected: null,
              selectedSet: draft.equipmentAccess.toSet(),
              onSelectedSet: (value) {
                final updated = draft.equipmentAccess.contains(value)
                    ? draft.equipmentAccess.where((e) => e != value).toList()
                    : [...draft.equipmentAccess, value];
                controller.updateDraft(
                  draft.copyWith(equipmentAccess: updated),
                );
              },
            ),
          ),
          AppWhiteSpace.hMd,

          // Schedule
          _SectionCard(
            title: AppStrings.trainingDays,
            child: _DaysPerWeekSelector(
              selected: draft.trainingDaysPerWeek,
              onSelected: (value) {
                controller.updateDraft(
                  draft.copyWith(trainingDaysPerWeek: value),
                );
              },
            ),
          ),
          AppWhiteSpace.hMd,

          _FormField(
            label: AppStrings.sessionLength,
            initialValue: draft.targetSessionLengthMinutes?.toString() ?? '',
            hintText: '45',
            suffixText: 'min',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final parsed = int.tryParse(value);
              controller.updateDraft(
                draft.copyWith(targetSessionLengthMinutes: parsed),
              );
            },
          ),
          AppWhiteSpace.hMd,

          // Units
          _SectionCard(
            title: AppStrings.preferredUnits,
            child: _UnitSelector(
              selected: draft.preferredUnits,
              onSelected: (value) {
                controller.updateDraft(draft.copyWith(preferredUnits: value));
              },
            ),
          ),
          AppWhiteSpace.hMd,

          // Body metrics
          _SectionCard(
            title: AppStrings.bodyweight,
            child: _FormField(
              label: '',
              initialValue: draft.bodyweightKg?.toString() ?? '',
              hintText: '70',
              suffixText: 'kg',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                controller.updateDraft(draft.copyWith(bodyweightKg: parsed));
              },
            ),
          ),
          AppWhiteSpace.hMd,

          _FormField(
            label: AppStrings.height,
            initialValue: draft.heightCm?.toString() ?? '',
            hintText: '170',
            suffixText: 'cm',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              controller.updateDraft(draft.copyWith(heightCm: parsed));
            },
          ),
          AppWhiteSpace.hMd,

          // Max lifts (1RMs)
          _SectionCard(
            title: AppStrings.maxLifts,
            child: Column(
              children: [
                _FormField(
                  label: AppStrings.bench1Rm,
                  initialValue: draft.bench1RmKg?.toString() ?? '',
                  hintText: '60',
                  suffixText: 'kg',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    controller.updateDraft(draft.copyWith(bench1RmKg: parsed));
                  },
                ),
                AppWhiteSpace.hMd,
                _FormField(
                  label: AppStrings.squat1Rm,
                  initialValue: draft.squat1RmKg?.toString() ?? '',
                  hintText: '80',
                  suffixText: 'kg',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    controller.updateDraft(draft.copyWith(squat1RmKg: parsed));
                  },
                ),
                AppWhiteSpace.hMd,
                _FormField(
                  label: AppStrings.deadlift1Rm,
                  initialValue: draft.deadlift1RmKg?.toString() ?? '',
                  hintText: '100',
                  suffixText: 'kg',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    controller.updateDraft(
                      draft.copyWith(deadlift1RmKg: parsed),
                    );
                  },
                ),
              ],
            ),
          ),
          AppWhiteSpace.hMd,

          // Favorites
          _SectionCard(
            title: AppStrings.favorites,
            child: _ExerciseSelector(
              selectedIds: draft.favoriteExerciseIds,
              hintText: AppStrings.selectFavorites,
              onTap: () => _showExerciseMultiSelect(
                context: context,
                ref: ref,
                draft: draft,
                controller: controller,
                mode: _ExerciseSelectMode.favorites,
              ),
            ),
          ),
          AppWhiteSpace.hMd,

          // Substitutions
          _SectionCard(
            title: AppStrings.substitutions,
            child: _ExerciseSelector(
              selectedIds: draft.substitutedExerciseIds,
              hintText: AppStrings.selectSubstitutions,
              onTap: () => _showExerciseMultiSelect(
                context: context,
                ref: ref,
                draft: draft,
                controller: controller,
                mode: _ExerciseSelectMode.substitutions,
              ),
            ),
          ),
          AppWhiteSpace.hMd,

          // Injuries and limitations
          _SectionCard(
            title: AppStrings.injuriesAndLimitations,
            child: _ChipSelector(
              options: const [
                'None',
                'Lower back',
                'Knee',
                'Shoulder',
                'Wrist',
                'Hip',
                'Neck',
                'Elbow',
                'Ankle',
              ],
              selected: null,
              selectedSet: draft.injuriesLimitations.toSet(),
              onSelectedSet: (value) {
                final updated = draft.injuriesLimitations.contains(value)
                    ? draft.injuriesLimitations
                          .where((i) => i != value)
                          .toList()
                    : [...draft.injuriesLimitations, value];
                controller.updateDraft(
                  draft.copyWith(injuriesLimitations: updated),
                );
              },
            ),
          ),
          AppWhiteSpace.hMd,

          // Notes
          _FormField(
            label: AppStrings.notes,
            initialValue: draft.otherNotes ?? '',
            maxLines: 3,
            hintText: AppStrings.notes,
            onChanged: (value) {
              controller.updateDraft(
                draft.copyWith(otherNotes: value.isEmpty ? null : value),
              );
            },
          ),
          AppWhiteSpace.hLg,

          // Save button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isSaving
                  ? null
                  : () {
                      controller.evaluateImpact();
                      controller.save();
                    },
              child: state.isSaving
                  ? const SizedBox(
                      width: AppSizing.iconSm,
                      height: AppSizing.iconSm,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AppStrings.saveProfile),
            ),
          ),
          AppWhiteSpace.hXl,
        ],
      ),
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isError
              ? context.colorScheme.errorContainer
              : context.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              isError
                  ? OutlinedSvgAssets.exclamationCircle
                  : OutlinedSvgAssets.informationCircle,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                isError
                    ? context.colorScheme.onErrorContainer
                    : context.colorScheme.onSecondaryContainer,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMd.copyWith(
                  color: isError
                      ? context.colorScheme.onErrorContainer
                      : context.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactWarning extends StatelessWidget {
  const _ImpactWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              OutlinedSvgAssets.exclamationTriangle,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onTertiaryContainer,
                BlendMode.srcIn,
              ),
            ),
            AppWhiteSpace.wSm,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMd.copyWith(
                  color: context.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: AppSizing.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMd.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          AppWhiteSpace.hMd,
          child,
        ],
      ),
    );
  }
}

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({
    required this.options,
    this.selected,
    this.selectedSet,
    this.onSelected,
    this.onSelectedSet,
  });

  final List<String> options;
  final String? selected;
  final Set<String>? selectedSet;
  final void Function(String)? onSelected;
  final void Function(String)? onSelectedSet;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final isSelected = selectedSet != null
            ? selectedSet!.contains(option)
            : selected == option;
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) {
            if (onSelected != null) {
              onSelected!(option);
            } else if (onSelectedSet != null) {
              onSelectedSet!(option);
            }
          },
        );
      }).toList(),
    );
  }
}

class _DaysPerWeekSelector extends StatelessWidget {
  const _DaysPerWeekSelector({
    required this.selected,
    required this.onSelected,
  });

  final int? selected;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(7, (index) {
        final day = index + 1;
        final isSelected = selected == day;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelected(day),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: AppSizing.metricTileMinWidth,
              minHeight: AppSizing.metricTileHeight * 0.8,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorScheme.secondaryContainer
                  : context.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected
                    ? context.colorScheme.secondary
                    : context.colorScheme.outlineVariant,
                width: AppSizing.divider,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: AppTextStyles.headlineMd.copyWith(
                    color: isSelected
                        ? context.colorScheme.onSecondaryContainer
                        : context.colorScheme.onSurface,
                  ),
                ),
                Text(
                  day == 1 ? 'Day' : 'Days',
                  style: AppTextStyles.labelSm.copyWith(
                    color: isSelected
                        ? context.colorScheme.onSecondaryContainer
                        : context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({required this.selected, required this.onSelected});

  final String selected;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Metric'),
          selected: selected == 'metric',
          onSelected: (_) => onSelected('metric'),
        ),
        AppWhiteSpace.wSm,
        ChoiceChip(
          label: const Text('Imperial'),
          selected: selected == 'imperial',
          onSelected: (_) => onSelected('imperial'),
        ),
      ],
    );
  }
}

class _FormField extends StatefulWidget {
  const _FormField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
    this.hintText,
    this.suffixText,
    this.maxLines,
  });

  final String label;
  final String initialValue;
  final void Function(String) onChanged;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? suffixText;
  final int? maxLines;

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: AppSizing.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label.isNotEmpty) ...[
            Text(
              widget.label,
              style: AppTextStyles.labelMd.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            AppWhiteSpace.hSm,
          ],
          TextField(
            controller: _controller,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              hintText: widget.hintText,
              suffixText: widget.suffixText,
            ),
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}

class _ExerciseSelector extends StatelessWidget {
  const _ExerciseSelector({
    required this.selectedIds,
    required this.hintText,
    required this.onTap,
  });

  final List<int> selectedIds;
  final String hintText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedIds.isEmpty
                    ? hintText
                    : '${selectedIds.length} ${AppStrings.exercisesSelected}',
                style: AppTextStyles.bodyMd.copyWith(
                  color: selectedIds.isEmpty
                      ? context.colorScheme.onSurfaceVariant
                      : context.colorScheme.onSurface,
                ),
              ),
            ),
            SvgPicture.asset(
              OutlinedSvgAssets.chevronRight,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ExerciseSelectMode { favorites, substitutions }

Future<void> _showExerciseMultiSelect({
  required BuildContext context,
  required WidgetRef ref,
  required ProfileEditDraft draft,
  required ProfileController controller,
  required _ExerciseSelectMode mode,
}) async {
  final exercises = await ref
      .read(AppProviders.exerciseDaoProvider)
      .getAllExercises();
  if (!context.mounted) return;

  final currentIds = switch (mode) {
    _ExerciseSelectMode.favorites => List<int>.from(draft.favoriteExerciseIds),
    _ExerciseSelectMode.substitutions => List<int>.from(
      draft.substitutedExerciseIds,
    ),
  };

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final tempIds = Set<int>.from(currentIds);
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            builder: (_, scrollController) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      mode == _ExerciseSelectMode.favorites
                          ? AppStrings.selectFavorites
                          : AppStrings.selectSubstitutions,
                      style: AppTextStyles.headlineMd,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: exercises.map((e) {
                        return CheckboxListTile(
                          title: Text(e.name),
                          value: tempIds.contains(e.id),
                          onChanged: (checked) {
                            setSheetState(() {
                              if (checked == true) {
                                tempIds.add(e.id);
                              } else {
                                tempIds.remove(e.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          controller
                              .updateDraft(switch (mode) {
                                _ExerciseSelectMode.favorites => draft.copyWith(
                                  favoriteExerciseIds: tempIds.toList(),
                                ),
                                _ExerciseSelectMode.substitutions =>
                                  draft.copyWith(
                                    substitutedExerciseIds: tempIds.toList(),
                                  ),
                              })
                              .then((_) {
                                if (ctx.mounted) Navigator.of(ctx).pop();
                              });
                        },
                        child: const Text(AppStrings.done),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}
