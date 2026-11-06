import 'package:aedify/features/progress_media/application/progress_deletion_providers.dart';
import 'package:aedify/features/progress_media/domain/progress_deletion.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum ProgressDeleteScope { item, session, all }

class ProgressDeleteButton extends ConsumerStatefulWidget {
  const ProgressDeleteButton({
    super.key,
    required this.scope,
    this.sessionId,
    this.itemId,
    this.onDeleted,
  });
  final ProgressDeleteScope scope;
  final String? sessionId;
  final String? itemId;
  final ValueChanged<ProgressCleanupStatus>? onDeleted;
  @override
  ConsumerState<ProgressDeleteButton> createState() =>
      _ProgressDeleteButtonState();
}

class _ProgressDeleteButtonState extends ConsumerState<ProgressDeleteButton> {
  bool _busy = false;
  String? _error;
  String get _label => switch (widget.scope) {
    ProgressDeleteScope.item => AppStrings.progressDeleteItem,
    ProgressDeleteScope.session => AppStrings.progressDeleteSession,
    ProgressDeleteScope.all => AppStrings.progressDeleteAll,
  };
  Future<void> _delete() async {
    final scope = widget.scope;
    final sessionId = widget.sessionId;
    final itemId = widget.itemId;
    final label = _label;
    final callback = widget.onDeleted;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(label),
        content: Text(
          scope == ProgressDeleteScope.item
              ? AppStrings.progressDeleteItemConfirm
              : scope == ProgressDeleteScope.session
              ? AppStrings.progressDeleteSessionConfirm
              : AppStrings.progressDeleteAllConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            key: const ValueKey('progress_confirm_delete'),
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
    if (!mounted ||
        confirmed != true ||
        widget.scope != scope ||
        widget.sessionId != sessionId ||
        widget.itemId != itemId) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final controller = ref.read(
        ProgressDeletionProviders.controllerProvider.notifier,
      );
      final result = await switch (scope) {
        ProgressDeleteScope.item => controller.deleteItem(sessionId!, itemId!),
        ProgressDeleteScope.session => controller.deleteSession(sessionId!),
        ProgressDeleteScope.all => controller.deleteAll(),
      };
      if (mounted) {
        setState(() {
          _busy = false;
          _error = result.pending
              ? AppStrings.progressDeletedPending
              : AppStrings.progressDeleted;
        });
      }
      callback?.call(result);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = ProgressDeletionFailure.unavailable.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextButton(
        key: ValueKey(
          'progress_delete_${widget.itemId ?? widget.sessionId ?? 'all'}',
        ),
        onPressed: _busy ? null : _delete,
        style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
        child: Text(_busy ? AppStrings.progressPhotoWorking : _label),
      ),
      if (_error != null) Semantics(liveRegion: true, child: Text(_error!)),
    ],
  );
}
