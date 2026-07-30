import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/lift_log/domain/workout_history_list_item.dart';
import 'package:aedify/features/lift_log/presentation/widgets/history_error_banner.dart';
import 'package:aedify/features/lift_log/presentation/widgets/workout_history_list_tile.dart';
import 'package:aedify/shared/components/app_empty_state.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LiftLogScreen extends ConsumerWidget {
  const LiftLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(AppProviders.workoutHistoryControllerProvider);
    final reload = ref
        .read(AppProviders.workoutHistoryControllerProvider.notifier)
        .reload;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HistoryHeader(),
            Expanded(
              child: asyncState.when(
                loading: () => const _LoadingView(),
                error: (error, stack) => HistoryErrorBanner(
                  message: AppStrings.workoutHistoryLoadFailed,
                  onRetry: reload,
                ),
                data: (state) {
                  if (state.isLoading) {
                    return const _LoadingView();
                  }
                  if (state.errorCode != null) {
                    return HistoryErrorBanner(
                      message:
                          state.errorMessage ??
                          AppStrings.workoutHistoryLoadFailed,
                      onRetry: reload,
                    );
                  }
                  if (state.isEmpty) {
                    return _EmptyView(onRefresh: reload);
                  }
                  return _HistoryListView(
                    items: state.items,
                    onRefresh: reload,
                    onTap: (sessionId) => context.pushNamed(
                      AppRoutes.workoutHistoryDetail().name,
                      pathParameters: {'sessionId': sessionId},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        top: AppSpacing.sm,
        right: AppSpacing.md,
        bottom: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.liftLog,
            style: AppTextStyles.headlineLgMobile.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          AppWhiteSpace.hXs,
          Text(
            AppStrings.completedWorkouts,
            style: AppTextStyles.bodySm.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: AppSpacing.xl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          top: AppSpacing.sm,
          right: AppSpacing.md,
          bottom: AppSizing.navBarHeight + AppSpacing.xl,
        ),
        children: const [
          AppEmptyState(
            iconAsset: OutlinedSvgAssets.clock,
            title: AppStrings.noWorkoutHistoryYet,
            message: AppStrings.noWorkoutHistoryYetHint,
          ),
        ],
      ),
    );
  }
}

class _HistoryListView extends StatelessWidget {
  const _HistoryListView({
    required this.items,
    required this.onRefresh,
    required this.onTap,
  });

  final List<WorkoutHistoryListItem> items;
  final Future<void> Function() onRefresh;
  final void Function(String sessionId) onTap;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSizing.navBarHeight + AppSpacing.xl,
        ),
        itemCount: items.length,
        separatorBuilder: (context, index) => AppWhiteSpace.hMd,
        itemBuilder: (context, index) {
          final item = items[index];
          return WorkoutHistoryListTile(
            item: item,
            onTap: () => onTap(item.sessionId),
          );
        },
      ),
    );
  }
}
