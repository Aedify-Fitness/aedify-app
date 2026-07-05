import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_error_banner.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_list_tile.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class LiftLogScreen extends ConsumerWidget {
  const LiftLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(AppProviders.workoutHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.liftLog)),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => HistoryErrorBanner(
          message: AppStrings.workoutHistoryLoadFailed,
          onRetry: () => ref
              .read(AppProviders.workoutHistoryControllerProvider.notifier)
              .reload(),
        ),
        data: (state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorCode != null) {
            return HistoryErrorBanner(
              message:
                  state.errorMessage ?? AppStrings.workoutHistoryLoadFailed,
              onRetry: () => ref
                  .read(AppProviders.workoutHistoryControllerProvider.notifier)
                  .reload(),
            );
          }
          if (state.isEmpty) {
            return const _EmptyView();
          }
          return _HistoryListView(
            items: state.items,
            onTap: (sessionId) => context.pushNamed(
              AppRoutes.workoutHistoryDetail().name,
              pathParameters: {'sessionId': sessionId},
            ),
          );
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.clock,
            width: AppSizing.iconLg,
            height: AppSizing.iconLg,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          AppWhiteSpace.hMd,
          Text(
            AppStrings.noWorkoutHistoryYet,
            style: context.textTheme.titleMedium,
          ),
          AppWhiteSpace.hSm,
          Text(
            AppStrings.noWorkoutHistoryYetHint,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HistoryListView extends StatelessWidget {
  const _HistoryListView({required this.items, required this.onTap});

  final List items;
  final void Function(String sessionId) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return WorkoutHistoryListTile(
          item: item,
          onTap: () => onTap(item.sessionId),
        );
      },
    );
  }
}
