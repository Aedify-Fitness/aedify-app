import 'package:aedify/features/progress_media/application/progress_deletion_providers.dart';
import 'package:aedify/features/progress_media/presentation/progress_delete_controls.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_components.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressStorageScreen extends ConsumerStatefulWidget {
  const ProgressStorageScreen({super.key});
  @override
  ConsumerState<ProgressStorageScreen> createState() =>
      _ProgressStorageScreenState();
}

class _ProgressStorageScreenState extends ConsumerState<ProgressStorageScreen> {
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(_refresh);
  }

  Future<void> _refresh() async {
    if (!mounted || _busy) return;
    setState(() => _busy = true);
    await ref
        .read(ProgressDeletionProviders.controllerProvider.notifier)
        .recover();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.progressStorage)),
    body: SafeArea(
      top: false,
      child: ref
          .watch(ProgressDeletionProviders.controllerProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => ProgressGalleryMessage(
              message: AppErrorStrings.progressCleanupFailed,
              retry: _refresh,
            ),
            data: (status) => ProgressGalleryBody(
              children: [
                const ProgressGalleryHeading(AppStrings.progressStorage),
                Text(
                  AppStrings.progressStorageSummary(
                    status.sessionCount,
                    _size(status.activeBytes),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(AppStrings.progressStorageHint),
                if (status.pending) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const Text(AppErrorStrings.progressCleanupPending),
                  Text(
                    AppStrings.progressPendingSummary(
                      status.pendingFiles,
                      _size(status.pendingBytes),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  key: const ValueKey('progress_retry_cleanup'),
                  onPressed: _busy ? null : _refresh,
                  child: Text(
                    _busy
                        ? AppStrings.progressPhotoWorking
                        : AppStrings.progressRetryCleanup,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (status.sessionCount > 0 && !_busy)
                  const ProgressDeleteButton(scope: ProgressDeleteScope.all),
              ],
            ),
          ),
    ),
  );
  String _size(int bytes) =>
      AppStrings.progressSizeMiB((bytes / (1024 * 1024)).toStringAsFixed(2));
}
