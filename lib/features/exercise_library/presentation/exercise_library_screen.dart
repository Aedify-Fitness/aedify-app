import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_filter_sheet.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ExerciseLibraryScreen extends ConsumerWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(
      AppProviders.exerciseSearchControllerProvider,
    );
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.exerciseLibrary),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(AppRoutes.bodymap().name),
            icon: SvgPicture.asset(
              OulinedSvgAssets.user,
              width: AppSpacing.lg,
              height: AppSpacing.lg,
            ),
            tooltip: AppStrings.bodymap,
          ),
        ],
      ),
      body: searchState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchState.errorCode != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      OulinedSvgAssets.exclamationCircle,
                      width: AppSpacing.xxl,
                      height: AppSpacing.xxl,
                      colorFilter: ColorFilter.mode(
                        colorScheme.error,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      searchState.errorMessage ??
                          AppStrings.exerciseLibraryLoadFailed,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge,
                    ),
                    SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () {
                        ref
                            .read(
                              AppProviders
                                  .exerciseSearchControllerProvider
                                  .notifier,
                            )
                            .reload();
                      },
                      child: Text(AppStrings.tryAgain),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                _SearchBar(
                  initialQuery: searchState.filters.searchQuery,
                  onChanged: (query) {
                    ref
                        .read(
                          AppProviders
                              .exerciseSearchControllerProvider
                              .notifier,
                        )
                        .updateSearchQuery(query);
                  },
                ),
                if (searchState.filters.hasActiveFilters)
                  _ActiveFilterBar(
                    filters: searchState.filters,
                    onClear: () {
                      ref
                          .read(
                            AppProviders
                                .exerciseSearchControllerProvider
                                .notifier,
                          )
                          .clearFilters();
                    },
                  ),
                Expanded(
                  child: searchState.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                OulinedSvgAssets.magnifyingGlassMinus,
                                width: AppSpacing.xxl,
                                height: AppSpacing.xxl,
                                colorFilter: ColorFilter.mode(
                                  colorScheme.onSurfaceVariant,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                AppStrings.noExercisesFound,
                                style: context.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(
                                  AppProviders
                                      .exerciseSearchControllerProvider
                                      .notifier,
                                )
                                .reload();
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            itemCount: searchState.items.length,
                            separatorBuilder: (_, _) =>
                                Divider(height: AppSizing.divider),
                            itemBuilder: (context, index) {
                              final item = searchState.items[index];
                              return _ExerciseListTile(
                                name: item.name,
                                difficulty: item.difficulty,
                                modality: item.modality,
                                equipment: item.equipment,
                                isFavorite: item.isFavorite,
                                onTap: () {
                                  context.pushNamed(
                                    AppRoutes.exerciseDetail().name,
                                    pathParameters: {'id': '${item.id}'},
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            builder: (_) =>
                ExerciseFilterSheet(initialFilters: searchState.filters),
          );
        },
        child: SvgPicture.asset(
          OulinedSvgAssets.funnel,
          width: AppSpacing.lg,
          height: AppSpacing.lg,
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.initialQuery, required this.onChanged});

  final String initialQuery;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: TextField(
        controller: TextEditingController(text: initialQuery),
        decoration: InputDecoration(
          hintText: AppStrings.searchExercises,
          prefixIcon: SvgPicture.asset(
            OulinedSvgAssets.magnifyingGlass,
            width: AppSpacing.lg,
            height: AppSpacing.lg,
            fit: BoxFit.scaleDown,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _ActiveFilterBar extends StatelessWidget {
  const _ActiveFilterBar({required this.filters, required this.onClear});

  final ExerciseFilterState filters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (filters.muscleGroup != null) {
      chips.add(_filterChip(filters.muscleGroup!));
    }
    if (filters.difficulty != null) {
      chips.add(_filterChip(filters.difficulty!));
    }
    if (filters.modality != null) {
      chips.add(_filterChip(filters.modality!));
    }
    if (filters.equipment != null) {
      chips.add(_filterChip(filters.equipment!));
    }
    if (filters.favoritesOnly) {
      chips.add(_filterChip(AppStrings.favorites));
    }
    if (filters.excludeSubstituted) {
      chips.add(_filterChip(AppStrings.noSubstituted));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: chips),
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              OulinedSvgAssets.xMark,
              width: AppSizing.iconXs,
              height: AppSizing.iconXs,
            ),
            onPressed: onClear,
            tooltip: AppStrings.clearFilters,
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: AppFontSizes.xs)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ExerciseListTile extends StatelessWidget {
  const _ExerciseListTile({
    required this.name,
    required this.difficulty,
    required this.modality,
    required this.equipment,
    required this.isFavorite,
    required this.onTap,
  });

  final String name;
  final String? difficulty;
  final String modality;
  final String? equipment;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return ListTile(
      title: Text(name),
      subtitle: Row(
        children: [
          if (difficulty != null) ...[
            Text(
              difficulty!,
              style: const TextStyle(fontSize: AppFontSizes.xs),
            ),
            AppWhiteSpace.wSm,
          ],
          Text(modality, style: const TextStyle(fontSize: AppFontSizes.xs)),
          if (equipment != null) ...[
            AppWhiteSpace.wSm,
            Text(equipment!, style: const TextStyle(fontSize: AppFontSizes.xs)),
          ],
        ],
      ),
      trailing: isFavorite
          ? SvgPicture.asset(
              SolidSvgAssets.heart,
              width: AppSizing.iconSm,
              height: AppSizing.iconSm,
              colorFilter: ColorFilter.mode(colorScheme.error, BlendMode.srcIn),
            )
          : null,
      onTap: onTap,
    );
  }
}
