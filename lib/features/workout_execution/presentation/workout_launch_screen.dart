import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/features/workout_execution/application/workout_launch_providers.dart';
import 'package:aedify/features/workout_execution/domain/workout_launch_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Starts a standalone or repeated session through the application boundary.
class WorkoutLaunchScreen extends ConsumerStatefulWidget {
  const WorkoutLaunchScreen({super.key, this.sourceSessionId});
  final String? sourceSessionId;

  @override
  ConsumerState<WorkoutLaunchScreen> createState() =>
      _WorkoutLaunchScreenState();
}

class _WorkoutLaunchScreenState extends ConsumerState<WorkoutLaunchScreen> {
  bool _navigating = false;
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    final provider = WorkoutLaunchProviders.launch(widget.sourceSessionId);
    ref.invalidate(provider);
    try {
      await ref.read(provider.future);
    } catch (_) {
      // The provider exposes a recoverable error without private payloads.
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  void _open(String sessionId) {
    if (_navigating) return;
    _navigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.pushReplacementNamed(
          AppRoutes.workoutRunnerActive().name,
          extra: sessionId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = WorkoutLaunchProviders.launch(widget.sourceSessionId);
    final state = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.logWorkout)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: state.when(
              skipLoadingOnRefresh: false,
              loading: () => const _LaunchProgress(),
              error: (_, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    AppErrorStrings.workoutStartFailed,
                    style: AppTextStyles.bodyMd,
                    textAlign: TextAlign.center,
                  ),
                  AppWhiteSpace.hMd,
                  FilledButton(
                    onPressed: _retrying ? null : _retry,
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
              data: (result) {
                if (!result.alreadyActive) {
                  _open(result.sessionId);
                  return const _LaunchProgress();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      WorkoutLaunchStrings.activeConflict,
                      style: AppTextStyles.bodyMd,
                      textAlign: TextAlign.center,
                    ),
                    AppWhiteSpace.hMd,
                    FilledButton(
                      onPressed: () => _open(result.sessionId),
                      child: const Text(AppStrings.resumeWorkout),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LaunchProgress extends StatelessWidget {
  const _LaunchProgress();

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircularProgressIndicator(),
      AppWhiteSpace.hMd,
      Text(WorkoutLaunchStrings.starting, style: AppTextStyles.bodyMd),
    ],
  );
}
