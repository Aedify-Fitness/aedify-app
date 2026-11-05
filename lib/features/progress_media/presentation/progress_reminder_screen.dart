import 'package:aedify/features/progress_media/application/progress_reminder_providers.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:aedify/features/progress_media/domain/progress_reminder.dart';
import 'package:aedify/features/progress_media/presentation/progress_gallery_components.dart';
import 'package:aedify/features/progress_media/presentation/progress_photo_components.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

abstract final class ProgressReminderLabels {
  static String cadence(ProgressReminderCadence cadence) => switch (cadence) {
    ProgressReminderCadence.twoWeeks => AppStrings.progressReminderTwoWeeks,
    ProgressReminderCadence.monthly => AppStrings.progressReminderMonthly,
    ProgressReminderCadence.threeMonths =>
      AppStrings.progressReminderThreeMonths,
    ProgressReminderCadence.off => AppStrings.disabled,
  };
  static String status(ProgressReminderView view) => switch (view.status) {
    ProgressReminderStatus.noSession => AppStrings.progressReminderNoSession,
    ProgressReminderStatus.off => AppStrings.progressReminderOff,
    ProgressReminderStatus.appDisabled =>
      AppStrings.progressReminderAppDisabled,
    ProgressReminderStatus.permissionDenied =>
      AppStrings.progressReminderPermission,
    ProgressReminderStatus.unsupported =>
      AppStrings.progressReminderUnsupported,
    ProgressReminderStatus.failed =>
      view.failure?.message ?? AppErrorStrings.progressReminderPlatform,
    ProgressReminderStatus.scheduled => AppStrings.progressReminderNext(
      DateFormat.yMMMd().add_jm().format(
        view.context.reminder.nextReminderAt!.toLocal(),
      ),
    ),
  };
}

class ProgressReminderScreen extends StatelessWidget {
  const ProgressReminderScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.progressReminderTitle)),
    body: const SafeArea(
      top: false,
      child: ProgressGalleryBody(children: [ProgressReminderPanel()]),
    ),
  );
}

class ProgressReminderSummary extends ConsumerWidget {
  const ProgressReminderSummary({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref
        .watch(ProgressReminderProviders.controllerProvider)
        .asData
        ?.value;
    if (view?.context.reminder.canPrompt == true) {
      return const ProgressReminderPanel();
    }
    return TextButton(
      key: const ValueKey('progress_reminders'),
      onPressed: () => context.pushNamed(AppRoutes.progressReminders().name),
      child: const Text(AppStrings.progressReminderTitle),
    );
  }
}

class ProgressReminderPanel extends ConsumerStatefulWidget {
  const ProgressReminderPanel({super.key});
  @override
  ConsumerState<ProgressReminderPanel> createState() =>
      _ProgressReminderPanelState();
}

class _ProgressReminderPanelState extends ConsumerState<ProgressReminderPanel> {
  ProgressReminderCadence? _selected;
  @override
  Widget build(BuildContext context) {
    final provider = ProgressReminderProviders.controllerProvider;
    return ref
        .watch(provider)
        .when(
          skipLoadingOnRefresh: false,
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: LinearProgressIndicator(),
          ),
          error: (_, _) => ProgressGalleryMessage(
            message: AppErrorStrings.progressReminderStorage,
            retry: () => ref.read(provider.notifier).refresh(),
          ),
          data: (view) {
            final controller = ref.read(provider.notifier);
            final current = view.context.reminder;
            final selected =
                _selected ?? current.cadence ?? ProgressReminderCadence.off;
            return ProgressPhotoPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProgressGalleryHeading(
                    current.canPrompt
                        ? AppStrings.progressReminderPrompt
                        : AppStrings.progressReminderTitle,
                  ),
                  const Text(AppStrings.progressReminderHint),
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      ProgressReminderLabels.status(view),
                      key: const ValueKey('reminder_status'),
                    ),
                  ),
                  if (view.context.hasSessions) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final cadence in ProgressReminderCadence.values)
                          ChoiceChip(
                            key: ValueKey('reminder_${cadence.name}'),
                            label: Text(
                              ProgressReminderLabels.cadence(cadence),
                            ),
                            selected: selected == cadence,
                            onSelected: view.busy
                                ? null
                                : (_) => setState(() => _selected = cadence),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      key: const ValueKey('reminder_apply'),
                      onPressed: view.busy
                          ? null
                          : () => controller.choose(selected),
                      child: Text(
                        view.busy
                            ? AppStrings.progressPhotoWorking
                            : selected == ProgressReminderCadence.off
                            ? AppStrings.progressReminderApply
                            : AppStrings.progressReminderEnable,
                      ),
                    ),
                    if (view.status == ProgressReminderStatus.failed ||
                        view.status == ProgressReminderStatus.permissionDenied)
                      TextButton(
                        onPressed: view.busy ? null : controller.refresh,
                        child: const Text(AppStrings.retry),
                      ),
                  ],
                ],
              ),
            );
          },
        );
  }
}
