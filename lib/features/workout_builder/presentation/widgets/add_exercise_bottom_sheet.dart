import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:aedify/features/workout_builder/domain/exercise_reference.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';

class AddExerciseBottomSheet extends ConsumerStatefulWidget {
  const AddExerciseBottomSheet({super.key, required this.onSelectExercises});

  final ValueChanged<List<ExerciseReference>> onSelectExercises;

  @override
  ConsumerState<AddExerciseBottomSheet> createState() =>
      _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState
    extends ConsumerState<AddExerciseBottomSheet> {
  late final TextEditingController _searchController;
  final _selected = <ExerciseReference>{};

  @override
  void initState() {
    super.initState();
    final initial = ref
        .read(AppProviders.exerciseSearchControllerProvider)
        .filters
        .searchQuery;
    _searchController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isSelected(ExerciseReference ex) {
    return _selected.any((s) => s.exerciseId == ex.exerciseId);
  }

  void _toggle(ExerciseListItem item) {
    final ex = ExerciseReference(
      exerciseId: item.id,
      name: item.name,
      modality: item.modality.dbValue,
      equipment: item.equipment?.dbValue,
      isCustom: item.isCustom,
    );
    setState(() {
      if (_isSelected(ex)) {
        _selected.remove(
          _selected.firstWhere((s) => s.exerciseId == ex.exerciseId),
        );
      } else {
        _selected.add(ex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(
      AppProviders.exerciseSearchControllerProvider,
    );
    final searchController = ref.read(
      AppProviders.exerciseSearchControllerProvider.notifier,
    );

    final doneLabel = _selected.isEmpty
        ? AppStrings.done
        : '${AppStrings.addExercise} (${_selected.length})';

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: AppSizing.handleWidth,
              height: AppSpacing.xs,
              decoration: BoxDecoration(
                color: context.theme.brightness == Brightness.light
                    ? AedifyLightColors.handleBarColor
                    : AedifyDarkColors.handleBarColor,
                borderRadius: BorderRadius.circular(AppRadius.xxs),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.addExercise,
                  style: AppTextStyles.headlineMd,
                ),
              ),
              FilledButton.tonal(
                onPressed: _selected.isNotEmpty
                    ? () {
                        widget.onSelectExercises(_selected.toList());
                        context.pop();
                      }
                    : null,
                child: Text(doneLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: AppStrings.searchExercises,
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (query) => searchController.updateSearchQuery(query),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (searchState.isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (searchState.errorCode != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Text(
                      searchState.errorMessage ?? AppStrings.searchFailed,
                      style: AppTextStyles.labelSm,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () => searchController.reload(),
                      child: const Text(AppStrings.retry),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                itemCount: searchState.items.length + 1,
                separatorBuilder: (_, _) =>
                    const Divider(height: AppSizing.divider),
                itemBuilder: (context, index) {
                  if (index == searchState.items.length) {
                    return ListTile(
                      leading: SvgPicture.asset(
                        OutlinedSvgAssets.plus,
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                      ),
                      title: Text(
                        AppStrings.createCustomExercise,
                        style: AppTextStyles.bodyMd,
                      ),
                      onTap: () async {
                        final result = await context.pushNamed(
                          AppRoutes.customExerciseCreate().name,
                        );
                        if (result == true && context.mounted) {
                          searchController.reload();
                        }
                      },
                    );
                  }
                  final item = searchState.items[index];
                  final ex = ExerciseReference(
                    exerciseId: item.id,
                    name: item.name,
                    modality: item.modality.dbValue,
                    equipment: item.equipment?.dbValue,
                    isCustom: item.isCustom,
                  );
                  final selected = _isSelected(ex);
                  return ListTile(
                    leading: Checkbox(
                      value: selected,
                      onChanged: (_) => _toggle(item),
                    ),
                    title: Text(item.name, style: AppTextStyles.bodyMd),
                    subtitle: item.equipment != null
                        ? Text(
                            '${item.modality.dbValue} · ${item.equipment!.dbValue}',
                            style: AppTextStyles.labelSm,
                          )
                        : Text(
                            item.modality.dbValue,
                            style: AppTextStyles.labelSm,
                          ),
                    onTap: () => _toggle(item),
                  );
                },
              ),
            ),
          if (searchState.items.isEmpty && !searchState.isLoading)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text(
                  AppStrings.noExercisesFound,
                  style: AppTextStyles.labelSm,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
