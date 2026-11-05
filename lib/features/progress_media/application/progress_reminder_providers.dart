import 'dart:async';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/application/progress_reminder_service.dart';
import 'package:aedify/features/progress_media/data/progress_reminder_repository.dart';
import 'package:aedify/features/progress_media/data/progress_reminder_scheduler.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class ProgressReminderProviders {
  static final repositoryProvider = Provider<ProgressReminderRepository>(
    (ref) =>
        ProgressReminderRepository(ref.watch(AppProviders.appDatabaseProvider)),
  );
  static final changesProvider = StreamProvider<int>(
    (ref) => ref.watch(repositoryProvider).watchChanges(),
    retry: (_, _) => null,
  );
  static final schedulerProvider = Provider<ProgressReminderScheduler>((ref) {
    final scheduler = LocalProgressReminderScheduler();
    ref.onDispose(() => unawaited(scheduler.dispose()));
    return scheduler;
  });
  static final serviceProvider = Provider<ProgressReminderService>((ref) {
    final service = ProgressReminderService(
      repository: ref.watch(repositoryProvider),
      scheduler: ref.watch(schedulerProvider),
      now: ref.watch(ProgressMediaProviders.clockProvider),
      featureAllowed: () =>
          ref.read(AppProviders.featureFlagsProvider).progressMediaEnabled,
    );
    ref.onDispose(() => unawaited(service.dispose()));
    return service;
  });
  static final controllerProvider =
      AsyncNotifierProvider<ProgressReminderController, ProgressReminderView>(
        ProgressReminderController.new,
        retry: (_, _) => null,
      );
}

class ProgressReminderController extends AsyncNotifier<ProgressReminderView> {
  Future<void>? _refreshing;
  bool _again = false;
  bool _choosing = false;
  @override
  Future<ProgressReminderView> build() async {
    final service = ref.watch(ProgressReminderProviders.serviceProvider);
    final sub = ref
        .read(ProgressReminderProviders.schedulerProvider)
        .events
        .listen((event) => unawaited(_action(event)));
    ref.onDispose(() => unawaited(sub.cancel()));
    ref.listen(ProgressReminderProviders.changesProvider, (_, next) {
      if (next.hasValue) unawaited(refresh());
    });
    return service.refresh();
  }

  Future<void> refresh() async {
    if (_choosing) {
      _again = true;
      return;
    }
    if (_refreshing != null) {
      _again = true;
      return _refreshing;
    }
    final task = _refresh();
    _refreshing = task;
    try {
      await task;
    } finally {
      _refreshing = null;
    }
    if (_again && ref.mounted) {
      _again = false;
      await refresh();
    }
  }

  Future<void> _refresh() async {
    try {
      final value = await ref
          .read(ProgressReminderProviders.serviceProvider)
          .refresh();
      if (ref.mounted && !_choosing) state = AsyncData(value);
    } catch (_) {
      if (ref.mounted && !_choosing) {
        state = AsyncError(ProgressReminderFailure.storage, StackTrace.empty);
      }
    }
  }

  Future<void> choose(ProgressReminderCadence cadence) async {
    final current = state.asData?.value;
    if (_choosing ||
        current == null ||
        current.busy ||
        !current.context.hasSessions) {
      return;
    }
    _choosing = true;
    state = AsyncData(
      ProgressReminderView(
        context: current.context,
        status: current.status,
        busy: true,
      ),
    );
    try {
      final value = await ref
          .read(ProgressReminderProviders.serviceProvider)
          .refresh(
            choice: cadence,
            request: cadence != ProgressReminderCadence.off,
          );
      if (ref.mounted) state = AsyncData(value);
    } catch (_) {
      if (ref.mounted) {
        state = AsyncData(
          ProgressReminderView(
            context: current.context,
            status: ProgressReminderStatus.failed,
            failure: ProgressReminderFailure.storage,
          ),
        );
      }
    } finally {
      _choosing = false;
      if (_again && ref.mounted) {
        _again = false;
        await refresh();
      }
    }
  }

  Future<void> _action(ProgressReminderEvent event) async {
    try {
      final value = await ref
          .read(ProgressReminderProviders.serviceProvider)
          .refresh(event: event);
      if (ref.mounted) state = AsyncData(value);
    } catch (_) {
      if (ref.mounted) {
        state = AsyncError(ProgressReminderFailure.storage, StackTrace.empty);
      }
    }
  }
}
