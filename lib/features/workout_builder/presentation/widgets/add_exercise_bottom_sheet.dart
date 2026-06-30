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

class AddExerciseBottomSheet extends ConsumerWidget {
  const AddExerciseBottomSheet({super.key, required this.onSelectExercise});

  final ValueChanged<ExerciseReference> onSelectExercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(
      AppProviders.exerciseSearchControllerProvider,
    );
    final searchController = ref.read(
      AppProviders.exerciseSearchControllerProvider.notifier,
    );

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
          Text(AppStrings.addExercise, style: AppTextStyles.headlineMd),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: TextEditingController.fromValue(
              TextEditingValue(text: searchState.filters.searchQuery),
            ),
            decoration: InputDecoration(
              hintText: AppStrings.searchExercises,
              prefixIcon: const Icon(Icons.search),
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
                      child: Text(AppStrings.retry),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
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
                  return ListTile(
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
                    onTap: () {
                      onSelectExercise(
                        ExerciseReference(
                          exerciseId: item.id,
                          name: item.name,
                          modality: item.modality.dbValue,
                          equipment: item.equipment?.dbValue,
                          isCustom: item.isCustom,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          if (searchState.items.isEmpty)
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
