import 'dart:convert';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/shared/components/app_text_field.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class OnboardingExerciseSelectionSheet extends StatefulWidget {
  const OnboardingExerciseSelectionSheet({
    super.key,
    required this.exercises,
    required this.initialIds,
    required this.onDone,
  });

  final List<Exercise> exercises;
  final Iterable<int> initialIds;
  final ValueChanged<List<int>> onDone;

  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required List<int> currentIds,
    required Iterable<int> excludedIds,
    required ValueChanged<List<int>> onDone,
  }) async {
    final exercises = await ref
        .read(AppProviders.exerciseDaoProvider)
        .getAllExercises();

    if (!context.mounted) return;
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.exerciseLibrarySyncUnavailableOffline),
        ),
      );
      return;
    }

    final excludedIdSet = excludedIds.toSet();
    final availableExercises = exercises
        .where((exercise) => !excludedIdSet.contains(exercise.id))
        .toList(growable: false);
    final availableIds = availableExercises
        .map((exercise) => exercise.id)
        .toSet();
    final initialIds = currentIds
        .where(availableIds.contains)
        .toList(growable: false);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.colorScheme.onSurface.withValues(alpha: 0.4),
      elevation: 0,
      showDragHandle: false,
      builder: (_) => OnboardingExerciseSelectionSheet(
        exercises: availableExercises,
        initialIds: initialIds,
        onDone: onDone,
      ),
    );
  }

  @override
  State<OnboardingExerciseSelectionSheet> createState() =>
      _OnboardingExerciseSelectionSheetState();
}

class _OnboardingExerciseSelectionSheetState
    extends State<OnboardingExerciseSelectionSheet> {
  static const _filters = [
    AppStrings.filterAll,
    AppStrings.filterChest,
    AppStrings.filterBack,
    AppStrings.filterLegs,
    AppStrings.filterShoulders,
  ];

  static const _legBuckets = <BodymapBucket>{
    BodymapBucket.glutes,
    BodymapBucket.quads,
    BodymapBucket.hamstrings,
    BodymapBucket.calves,
    BodymapBucket.adductors,
    BodymapBucket.feet,
  };

  late final TextEditingController _searchController;
  late final Set<int> _selectedIds;
  String _selectedFilter = AppStrings.filterAll;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedIds = widget.initialIds.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _accentColor(BuildContext context) {
    return context.theme.brightness == Brightness.dark
        ? context.colorScheme.primary
        : context.colorScheme.secondary;
  }

  Color _onAccentColor(BuildContext context) {
    return context.theme.brightness == Brightness.dark
        ? context.colorScheme.onPrimary
        : context.colorScheme.onSecondary;
  }

  List<String> _decodeStringList(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! List) return const [];

      final values = <String>[];
      for (final value in decoded.whereType<String>()) {
        final trimmed = value.trim();
        final alreadyAdded = values.any(
          (existing) => existing.toLowerCase() == trimmed.toLowerCase(),
        );
        if (trimmed.isNotEmpty && !alreadyAdded) values.add(trimmed);
      }
      return values;
    } on FormatException {
      return const [];
    }
  }

  List<String> _muscleGroupsFor(Exercise exercise) {
    final groups = _decodeStringList(exercise.muscleGroupsJson);
    if (groups.isNotEmpty) return groups;
    return _decodeStringList(exercise.primaryMusclesJson);
  }

  BodymapBucket? _bucketForFilter(String filter) {
    return switch (filter) {
      AppStrings.filterChest => BodymapBucket.chest,
      AppStrings.filterBack => BodymapBucket.back,
      AppStrings.filterShoulders => BodymapBucket.shoulders,
      _ => null,
    };
  }

  bool _matchesSelectedFilter(Exercise exercise) {
    if (_selectedFilter == AppStrings.filterAll) return true;

    final groups = _muscleGroupsFor(
      exercise,
    ).map((group) => group.toLowerCase()).toSet();
    if (_selectedFilter == AppStrings.filterLegs) {
      return _legBuckets.any(
        (bucket) => groups.contains(bucket.label.toLowerCase()),
      );
    }

    final bucket = _bucketForFilter(_selectedFilter);
    return bucket != null && groups.contains(bucket.label.toLowerCase());
  }

  List<Exercise> get _filteredExercises {
    final query = _searchController.text.trim().toLowerCase();
    return widget.exercises
        .where(
          (exercise) =>
              (query.isEmpty || exercise.name.toLowerCase().contains(query)) &&
              _matchesSelectedFilter(exercise),
        )
        .toList(growable: false);
  }

  void _toggleExercise(int exerciseId) {
    setState(() {
      if (!_selectedIds.add(exerciseId)) _selectedIds.remove(exerciseId);
    });
  }

  void _commitSelection() {
    widget.onDone(_selectedIds.toList(growable: false));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor(context);
    final onAccentColor = _onAccentColor(context);
    final filteredExercises = _filteredExercises;

    return DraggableScrollableSheet(
      initialChildSize: AppSizing.onboardingExerciseSheetInitialHeightFactor,
      minChildSize: AppSizing.onboardingExerciseSheetMinHeightFactor,
      maxChildSize: AppSizing.onboardingExerciseSheetInitialHeightFactor,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          key: const ValueKey<String>('onboarding_exercise_selector_sheet'),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.shadow.withValues(alpha: 0.24),
                blurRadius: AppSizing.onboardingExerciseSheetShadowBlur,
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Container(
                  width: AppSizing.onboardingExerciseSheetHandleWidth,
                  height: AppSizing.onboardingExerciseSheetHandleHeight,
                  decoration: BoxDecoration(
                    color: context.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.colorScheme.outlineVariant.withValues(
                        alpha: 0.1,
                      ),
                      width: AppSizing.hairlineStrokeWidth,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.onboardingSelectExercises,
                      style: AppTextStyles.headlineMd.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    AppWhiteSpace.hMd,
                    SizedBox(
                      key: const ValueKey<String>(
                        'onboarding_exercise_selector_search',
                      ),
                      height: AppSizing.onboardingExerciseSheetSearchHeight,
                      child: AppTextField(
                        controller: _searchController,
                        hintText: AppStrings.searchExercises,
                        textInputAction: TextInputAction.search,
                        fillColor: context.colorScheme.surfaceContainerLow,
                        borderRadius: AppRadius.md,
                        contentPadding: const EdgeInsets.only(
                          right: AppSpacing.md,
                          top: AppSpacing.buttonVertical,
                          bottom: AppSpacing.buttonVertical,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.md,
                            right: AppSpacing.controlGap,
                          ),
                          child: SvgPicture.asset(
                            OutlinedSvgAssets.magnifyingGlass,
                            width: AppSizing.iconMd,
                            height: AppSizing.iconMd,
                            colorFilter: ColorFilter.mode(
                              context.colorScheme.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        style: AppTextStyles.bodyMd.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    AppWhiteSpace.hMd,
                    SizedBox(
                      height:
                          AppSizing.onboardingExerciseSheetFilterViewportHeight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (
                                var index = 0;
                                index < _filters.length;
                                index++
                              ) ...[
                                if (index > 0) AppWhiteSpace.wSm,
                                _OnboardingExerciseFilterChip(
                                  label: _filters[index],
                                  selected: _filters[index] == _selectedFilter,
                                  accentColor: accentColor,
                                  onAccentColor: onAccentColor,
                                  onTap: () => setState(
                                    () => _selectedFilter = _filters[index],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredExercises.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.noExercisesFound,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.lg,
                        ),
                        itemCount: filteredExercises.length,
                        separatorBuilder: (_, _) => AppWhiteSpace.hMd,
                        itemBuilder: (context, index) {
                          final exercise = filteredExercises[index];
                          return _OnboardingExerciseOption(
                            exercise: exercise,
                            muscleGroups: _muscleGroupsFor(exercise),
                            selected: _selectedIds.contains(exercise.id),
                            accentColor: accentColor,
                            onAccentColor: onAccentColor,
                            onTap: () => _toggleExercise(exercise.id),
                          );
                        },
                      ),
              ),
              Container(
                key: const ValueKey<String>(
                  'onboarding_exercise_selector_footer',
                ),
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  top: AppSpacing.lg,
                  right: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: context.colorScheme.outlineVariant.withValues(
                        alpha: 0.1,
                      ),
                      width: AppSizing.hairlineStrokeWidth,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppSizing.onboardingExerciseSheetActionHeight,
                    child: FilledButton(
                      key: const ValueKey<String>(
                        'onboarding_exercise_selector_confirm',
                      ),
                      onPressed: _commitSelection,
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: onAccentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        AppStrings.onboardingAddSelectedExercises,
                        style: AppTextStyles.labelMd.copyWith(
                          color: onAccentColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OnboardingExerciseFilterChip extends StatelessWidget {
  const _OnboardingExerciseFilterChip({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onAccentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final Color onAccentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        key: ValueKey<String>('onboarding_exercise_filter_$label'),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? accentColor
              : context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.full),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                label,
                maxLines: 1,
                style: AppTextStyles.labelMd.copyWith(
                  color: selected
                      ? onAccentColor
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingExerciseOption extends StatelessWidget {
  const _OnboardingExerciseOption({
    required this.exercise,
    required this.muscleGroups,
    required this.selected,
    required this.accentColor,
    required this.onAccentColor,
    required this.onTap,
  });

  final Exercise exercise;
  final List<String> muscleGroups;
  final bool selected;
  final Color accentColor;
  final Color onAccentColor;
  final VoidCallback onTap;

  String get _initial {
    final trimmed = exercise.name.trim();
    if (trimmed.isEmpty) return '';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey<String>('onboarding_exercise_option_${exercise.id}'),
      button: true,
      selected: selected,
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.1),
            width: AppSizing.hairlineStrokeWidth,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  // TODO(aedify): Replace exercise initials with dataset-backed
                  // exercise thumbnails when exercise image integration is scheduled.
                  Container(
                    key: ValueKey<String>(
                      'onboarding_exercise_initial_${exercise.id}',
                    ),
                    width: AppSizing.onboardingExerciseSheetAvatarSize,
                    height: AppSizing.onboardingExerciseSheetAvatarSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colorScheme.secondaryFixed.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppRadius.defaultRadius,
                      ),
                    ),
                    child: Text(
                      _initial,
                      style: AppTextStyles.headlineMd.copyWith(
                        color: accentColor,
                      ),
                    ),
                  ),
                  AppWhiteSpace.wMd,
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMd.copyWith(
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        if (muscleGroups.isNotEmpty)
                          Text(
                            muscleGroups.join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  AppWhiteSpace.wMd,
                  AnimatedContainer(
                    key: ValueKey<String>(
                      'onboarding_exercise_selection_${exercise.id}',
                    ),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: AppSizing.onboardingExerciseSheetSelectionSize,
                    height: AppSizing.onboardingExerciseSheetSelectionSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? accentColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: selected
                            ? accentColor
                            : context.colorScheme.outlineVariant,
                        width: AppSizing.hairlineStrokeWidth,
                      ),
                    ),
                    child: selected
                        ? SvgPicture.asset(
                            OutlinedSvgAssets.materialCheck,
                            width: AppSizing.iconXxs,
                            height: AppSizing.iconXxs,
                            colorFilter: ColorFilter.mode(
                              onAccentColor,
                              BlendMode.srcIn,
                            ),
                          )
                        : null,
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
