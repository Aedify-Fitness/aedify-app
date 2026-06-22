import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      AppProviders.exerciseDetailControllerProvider(exerciseId),
    );
    final colorScheme = context.colorScheme;
    final detail = detailAsync.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(detail?.name ?? ''),
        actions: [
          if (detail != null) ...[
            IconButton(
              icon: Icon(
                detail.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: detail.isFavorite ? colorScheme.error : null,
              ),
              onPressed: () async {
                try {
                  final repository = ref.read(
                    AppProviders.exerciseRepositoryProvider,
                  );
                  await repository.setFavorite(
                    exerciseId: detail.id,
                    isFavorite: !detail.isFavorite,
                  );
                  ref.invalidate(
                    AppProviders.exerciseDetailControllerProvider(exerciseId),
                  );
                } catch (_) {}
              },
              tooltip: 'Toggle favorite',
            ),
            IconButton(
              icon: Icon(
                detail.isSubstitutedOut
                    ? Icons.block
                    : Icons.check_circle_outline,
              ),
              onPressed: () async {
                try {
                  final repository = ref.read(
                    AppProviders.exerciseRepositoryProvider,
                  );
                  await repository.setSubstitutedOut(
                    exerciseId: detail.id,
                    isSubstitutedOut: !detail.isSubstitutedOut,
                  );
                  ref.invalidate(
                    AppProviders.exerciseDetailControllerProvider(exerciseId),
                  );
                } catch (_) {}
              },
              tooltip: 'Toggle substitution',
            ),
          ],
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Could not load exercise.',
                  style: context.textTheme.bodyLarge,
                ),
                SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(
                      AppProviders.exerciseDetailControllerProvider(exerciseId),
                    );
                  },
                  child: const Text(AppStrings.tryAgain),
                ),
              ],
            ),
          ),
        ),
        data: (loaded) {
          if (loaded == null) {
            return const Center(child: Text('Exercise not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loaded.name, style: context.textTheme.headlineSmall),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (loaded.difficulty != null)
                      _MetaChip(label: loaded.difficulty!),
                    _MetaChip(label: _formatModality(loaded.modality)),
                    if (loaded.equipment != null)
                      _MetaChip(label: loaded.equipment!),
                    if (loaded.category != null)
                      _MetaChip(label: loaded.category!),
                    if (loaded.force != null) _MetaChip(label: loaded.force!),
                    if (loaded.mechanic != null)
                      _MetaChip(label: loaded.mechanic!),
                  ],
                ),
                if (loaded.muscleGroups.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    AppStrings.muscleGroups,
                    style: context.textTheme.titleSmall,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: loaded.muscleGroups
                        .map(
                          (g) => Chip(
                            label: Text(
                              g,
                              style: const TextStyle(fontSize: 12),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (loaded.primaryMuscles.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    AppStrings.primaryMuscles,
                    style: context.textTheme.titleSmall,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: loaded.primaryMuscles
                        .map(
                          (m) => Chip(
                            label: Text(
                              m,
                              style: const TextStyle(fontSize: 12),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (loaded.steps.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    AppStrings.instructions,
                    style: context.textTheme.titleSmall,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  ...loaded.steps.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text(entry.value)),
                        ],
                      ),
                    ),
                  ),
                ],
                if (loaded.videos.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.lg),
                  Text('Videos', style: context.textTheme.titleSmall),
                  SizedBox(height: AppSpacing.sm),
                  ...loaded.videos.map(
                    (video) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.videocam),
                        title: Text(video.angle ?? AppStrings.videoUnavailable),
                        subtitle: Text(video.gender ?? ''),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatModality(String modality) {
    return modality
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
