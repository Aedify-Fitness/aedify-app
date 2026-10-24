import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_card.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_library_style.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_bodymap.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/shared/widgets/app_bottom_navigation_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Browses local exercises as a standalone page or inside the library hub.
class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  late final TextEditingController _searchController;
  final _searchFocus = FocusNode();
  bool _creating = false;
  bool _openingBodymap = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref
          .read(AppProviders.exerciseSearchControllerProvider)
          .filters
          .searchQuery,
    );
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createExercise() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      await context.pushNamed<bool>(AppRoutes.customExerciseCreate().name);
      if (mounted) {
        await ref
            .read(AppProviders.exerciseSearchControllerProvider.notifier)
            .reload();
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _openBodymap() async {
    if (_openingBodymap) return;
    setState(() => _openingBodymap = true);
    try {
      await context.pushNamed(AppRoutes.bodymap().name);
    } finally {
      if (mounted) setState(() => _openingBodymap = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(AppProviders.exerciseSearchControllerProvider, (previous, next) {
      final query = next.filters.searchQuery;
      if (previous?.filters.searchQuery != query &&
          !_searchFocus.hasFocus &&
          _searchController.text != query) {
        _searchController.value = TextEditingValue(
          text: query,
          selection: TextSelection.collapsed(offset: query.length),
        );
      }
    });
    final search = ref.watch(AppProviders.exerciseSearchControllerProvider);
    final notifier = ref.read(
      AppProviders.exerciseSearchControllerProvider.notifier,
    );
    final clearance = widget.embedded
        ? AppBottomNavigationScope.contentClearance(
            context,
            fallback: AppSpacing.lg,
          )
        : AppBottomNavigationScope.contentClearanceWithFloatingActionButton(
            context,
            fallback: AppSpacing.xxxl * 2,
          );
    final content = SafeArea(
      top: !widget.embedded,
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppExerciseLibraryTokens.maxContentWidth,
          ),
          child: CustomScrollView(
            key: const ValueKey('exercise_library_scroll'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppWhiteSpace.hMd,
                      if (!widget.embedded) ...[
                        Semantics(
                          header: true,
                          child: Text(
                            AppStrings.exerciseLibrary,
                            style: ExerciseLibraryStyle.heading(context),
                          ),
                        ),
                        AppWhiteSpace.hMd,
                      ],
                      _SearchField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: notifier.updateSearchQuery,
                      ),
                      AppWhiteSpace.hSm,
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.md,
                        children: [
                          Text(
                            AppStrings.browseByMuscle,
                            style: ExerciseLibraryStyle.label(context),
                          ),
                          TextButton.icon(
                            key: const ValueKey('exercise_library_bodymap'),
                            onPressed: _openingBodymap ? null : _openBodymap,
                            style: TextButton.styleFrom(
                              foregroundColor: ExerciseLibraryStyle.accent(
                                context,
                              ),
                              minimumSize: const Size(
                                AppExerciseLibraryTokens.controlSize,
                                AppExerciseLibraryTokens.controlSize,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.controlGap,
                                vertical: AppSpacing.controlGap,
                              ),
                              textStyle: ExerciseLibraryStyle.label(
                                context,
                              ).copyWith(inherit: false),
                            ),
                            icon: SvgPicture.asset(
                              BodymapSvgAssets.front,
                              width: AppSizing.iconMd,
                              height: AppSizing.iconMd,
                              colorFilter: ColorFilter.mode(
                                ExerciseLibraryStyle.accent(context),
                                BlendMode.srcIn,
                              ),
                            ),
                            label: const Text(AppStrings.bodymap),
                          ),
                        ],
                      ),
                      AppWhiteSpace.hSm,
                      _MuscleGroupChips(
                        selectedBucket: search.filters.muscleGroup,
                        selectedModality: search.filters.modality,
                        onSelected: (bucket, modality) =>
                            notifier.updateFilters(
                              search.filters.copyWith(
                                muscleGroup: bucket,
                                modality: modality,
                                clearMuscleGroup: bucket == null,
                                clearModality: modality == null,
                              ),
                            ),
                      ),
                      AppWhiteSpace.hMd,
                      if (!search.isLoading &&
                          search.errorCode == null &&
                          !search.isEmpty) ...[
                        Text(
                          AppStrings.exerciseLibraryResults(
                            search.items.length,
                          ),
                          style: ExerciseLibraryStyle.caption(context),
                        ),
                        AppWhiteSpace.hMd,
                      ],
                    ],
                  ),
                ),
              ),
              if (search.isLoading)
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: AppSpacing.xxxl * 2,
                    child: Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: AppStrings.loading,
                      ),
                    ),
                  ),
                )
              else if (search.errorCode != null)
                SliverToBoxAdapter(
                  child: _LibraryMessage(
                    title: AppStrings.exerciseLibraryLoadFailed,
                    icon: OutlinedSvgAssets.exclamationCircle,
                    actionLabel: AppStrings.tryAgain,
                    onAction: notifier.reload,
                  ),
                )
              else if (search.isEmpty)
                SliverToBoxAdapter(
                  child: _LibraryMessage(
                    title: AppStrings.noExercisesFound,
                    message: AppStrings.exerciseLibraryEmptyHint,
                    icon: OutlinedSvgAssets.magnifyingGlass,
                    actionLabel: search.filters.hasActiveFilters
                        ? AppStrings.clearFilters
                        : null,
                    onAction: search.filters.hasActiveFilters
                        ? notifier.clearFilters
                        : null,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverList.separated(
                    itemCount: search.items.length,
                    separatorBuilder: (_, _) => AppWhiteSpace.hMd,
                    itemBuilder: (context, index) => ExerciseCard(
                      item: search.items[index],
                      onTap: () => context.pushNamed(
                        AppRoutes.exerciseDetail().name,
                        pathParameters: {'id': '${search.items[index].id}'},
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  key: const ValueKey(
                    'exercise_library_bottom_navigation_clearance',
                  ),
                  height: clearance,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (widget.embedded) return content;
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: content,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: AppBottomNavigationScope.floatingActionButtonLift(context),
        ),
        child: FloatingActionButton(
          key: const Key('create_action_fab'),
          tooltip: AppStrings.createCustomExercise,
          onPressed: _creating ? null : _createExercise,
          backgroundColor: ExerciseLibraryStyle.actionFill(context),
          foregroundColor: ExerciseLibraryStyle.actionForeground(context),
          elevation: 0,
          child: SvgPicture.asset(
            OutlinedSvgAssets.plusSmall,
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
            colorFilter: ColorFilter.mode(
              ExerciseLibraryStyle.actionForeground(context),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide.none,
    );
    return Semantics(
      label: AppStrings.searchExercises,
      child: TextField(
        key: const ValueKey('exercise_library_search'),
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: (_) => focusNode.unfocus(),
        onTapOutside: (_) => focusNode.unfocus(),
        textInputAction: TextInputAction.search,
        style: ExerciseLibraryStyle.body(context),
        decoration: InputDecoration(
          hintText: AppStrings.searchExercises,
          hintStyle: ExerciseLibraryStyle.body(
            context,
          ).copyWith(color: context.colorScheme.onSurfaceVariant),
          prefixIcon: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.controlGap,
              ),
              child: SvgPicture.asset(
                OutlinedSvgAssets.magnifyingGlass,
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: AppExerciseLibraryTokens.controlSize,
            minHeight: AppExerciseLibraryTokens.controlSize,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(
              color: ExerciseLibraryStyle.accent(context),
              width: AppSizing.strokeWidth,
            ),
          ),
          filled: true,
          fillColor: ExerciseLibraryStyle.panel(context),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

class _FilterChipData {
  const _FilterChipData({
    required this.label,
    this.muscleBucket,
    this.modality,
  });
  final String label;
  final BodymapBucket? muscleBucket;
  final ExerciseModality? modality;

  static const items = [
    _FilterChipData(label: AppStrings.filterAll),
    _FilterChipData(
      label: AppStrings.filterChest,
      muscleBucket: BodymapBucket.chest,
    ),
    _FilterChipData(
      label: AppStrings.filterBack,
      muscleBucket: BodymapBucket.back,
    ),
    _FilterChipData(
      label: AppStrings.filterLegs,
      muscleBucket: BodymapBucket.quads,
    ),
    _FilterChipData(
      label: AppStrings.filterShoulders,
      muscleBucket: BodymapBucket.shoulders,
    ),
    _FilterChipData(
      label: AppStrings.filterArms,
      muscleBucket: BodymapBucket.biceps,
    ),
    _FilterChipData(
      label: AppStrings.filterCore,
      muscleBucket: BodymapBucket.core,
    ),
    _FilterChipData(
      label: AppStrings.filterCardio,
      modality: ExerciseModality.cardio,
    ),
  ];
}

class _MuscleGroupChips extends StatelessWidget {
  const _MuscleGroupChips({
    required this.selectedBucket,
    required this.selectedModality,
    required this.onSelected,
  });
  final BodymapBucket? selectedBucket;
  final ExerciseModality? selectedModality;
  final void Function(BodymapBucket?, ExerciseModality?) onSelected;

  @override
  Widget build(BuildContext context) {
    final choices = _FilterChipData.items.map((chip) {
      final selected =
          chip.muscleBucket == selectedBucket &&
          chip.modality == selectedModality;
      return MergeSemantics(
        child: Semantics(
          selected: selected,
          inMutuallyExclusiveGroup: true,
          child: TextButton(
            key: ValueKey('exercise_library_filter_${chip.label}'),
            onPressed: () => onSelected(chip.muscleBucket, chip.modality),
            style: TextButton.styleFrom(
              foregroundColor: selected
                  ? ExerciseLibraryStyle.actionForeground(context)
                  : context.colorScheme.onSurfaceVariant,
              backgroundColor: selected
                  ? ExerciseLibraryStyle.actionFill(context)
                  : ExerciseLibraryStyle.panel(context),
              minimumSize: const Size(
                AppExerciseLibraryTokens.controlSize,
                AppExerciseLibraryTokens.controlSize,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.controlGap,
              ),
              textStyle: ExerciseLibraryStyle.label(
                context,
              ).copyWith(inherit: false),
              shape: const StadiumBorder(),
            ),
            child: Text(chip.label),
          ),
        ),
      );
    }).toList();
    final largeText =
        MediaQuery.textScalerOf(context).scale(AppFontSizes.sm) >
        AppFontSizes.sm * AppExerciseLibraryTokens.largeTextBreakpoint;
    if (largeText) {
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: choices,
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < choices.length; index++) ...[
            if (index > 0) AppWhiteSpace.wSm,
            choices[index],
          ],
        ],
      ),
    );
  }
}

class _LibraryMessage extends StatelessWidget {
  const _LibraryMessage({
    required this.title,
    required this.icon,
    this.message,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String icon;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.lg,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: SvgPicture.asset(
            icon,
            width: AppSizing.iconXxl,
            height: AppSizing.iconXxl,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
        ),
        AppWhiteSpace.hMd,
        Semantics(
          liveRegion: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: ExerciseLibraryStyle.title(context),
          ),
        ),
        if (message != null) ...[
          AppWhiteSpace.hSm,
          Text(
            message!,
            textAlign: TextAlign.center,
            style: ExerciseLibraryStyle.small(context),
          ),
        ],
        if (onAction != null && actionLabel != null) ...[
          AppWhiteSpace.hMd,
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: ExerciseLibraryStyle.accent(context),
              minimumSize: const Size.fromHeight(
                AppExerciseLibraryTokens.controlSize,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.controlGap,
              ),
              textStyle: ExerciseLibraryStyle.label(
                context,
              ).copyWith(inherit: false),
            ),
            child: Text(actionLabel!, textAlign: TextAlign.center),
          ),
        ],
      ],
    ),
  );
}
