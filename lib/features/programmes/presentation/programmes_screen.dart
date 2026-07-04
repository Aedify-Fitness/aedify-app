import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/features/programmes/presentation/widgets/archive_item_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/delete_item_dialog.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_list_tile.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ProgrammesScreen extends ConsumerStatefulWidget {
  const ProgrammesScreen({super.key});

  @override
  ConsumerState<ProgrammesScreen> createState() => _ProgrammesScreenState();
}

class _ProgrammesScreenState extends ConsumerState<ProgrammesScreen> {
  String _activeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(
      AppProviders.programmeLibraryControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.programmes)),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.pushNamed(AppRoutes.programmeBuilderCreate().name),
        child: SvgPicture.asset(
          OutlinedSvgAssets.plus,
          width: AppSizing.iconMd,
          height: AppSizing.iconMd,
        ),
      ),
      body: SafeArea(
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _ErrorView(
            message: AppStrings.programmesLoadFailed,
            onRetry: () => ref
                .read(AppProviders.programmeLibraryControllerProvider.notifier)
                .reload(),
          ),
          data: (state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorCode != null) {
              return _ErrorView(
                message: state.errorMessage ?? AppStrings.programmesLoadFailed,
                onRetry: () => ref
                    .read(
                      AppProviders.programmeLibraryControllerProvider.notifier,
                    )
                    .reload(),
              );
            }

            final items = _filteredItems(state.items);

            return Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                _FilterPills(
                  activeFilter: _activeFilter,
                  onChanged: (filter) {
                    setState(() => _activeFilter = filter);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: items.isEmpty
                      ? const _EmptyView()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ProgrammeListTile(
                              item: item,
                              onTap: () => context.pushNamed(
                                AppRoutes.programmeCalendar().name,
                                pathParameters: {'id': item.id},
                              ),
                              onEdit: () => context.pushNamed(
                                AppRoutes.programmeBuilderEdit().name,
                                pathParameters: {'id': item.id},
                              ),
                              onToggleActive: () => _toggleActive(item),
                              onArchive: () => _showArchiveDialog(item),
                              onDelete: () => _showDeleteDialog(item),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<ProgrammeListItem> _filteredItems(List<ProgrammeListItem> items) {
    if (_activeFilter == 'all') return items;

    return items.where((item) {
      if (_activeFilter == 'ai') return item.source == 'ai_generated';
      if (_activeFilter == 'custom') {
        return (item.source == 'manual' || item.source == null) &&
            !item.imported;
      }
      if (_activeFilter == 'imported') return item.imported;
      return true;
    }).toList();
  }

  Future<void> _toggleActive(ProgrammeListItem item) async {
    final controller = ref.read(
      AppProviders.programmeLibraryControllerProvider.notifier,
    );

    if (item.active) {
      await controller.deactivateProgramme(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.programmeDeactivated)),
      );
      return;
    }

    final items =
        ref
            .read(AppProviders.programmeLibraryControllerProvider)
            .asData
            ?.value
            .items ??
        const <ProgrammeListItem>[];
    ProgrammeListItem? existingActive;
    for (final entry in items) {
      if (entry.active) {
        existingActive = entry;
        break;
      }
    }
    if (existingActive != null && existingActive.id != item.id && mounted) {
      final activeName = existingActive.name;
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(AppStrings.activateProgramme),
          content: Text(
            '${AppStrings.activeProgrammeWarning} $activeName will be deactivated.',
          ),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(false),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => ctx.pop(true),
              child: const Text(AppStrings.activateProgramme),
            ),
          ],
        ),
      );
    }

    await controller.activateProgramme(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.programmeActivated)),
    );
  }

  void _showArchiveDialog(ProgrammeListItem item) {
    showDialog<void>(
      context: context,
      builder: (_) => ArchiveItemDialog(
        title: AppStrings.archiveProgrammeConfirm,
        message: '',
        onConfirm: () async {
          await ref
              .read(AppProviders.programmeLibraryControllerProvider.notifier)
              .archiveProgramme(item.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.programmeArchived)),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(ProgrammeListItem item) {
    showDialog<void>(
      context: context,
      builder: (_) => DeleteItemDialog(
        title: AppStrings.deleteProgrammeConfirm,
        message: '',
        confirmLabel: AppStrings.deleteProgramme,
        onConfirm: () async {
          await ref
              .read(AppProviders.programmeLibraryControllerProvider.notifier)
              .deleteProgramme(item.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.programmeDeleted)),
          );
        },
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  const _FilterPills({required this.activeFilter, required this.onChanged});

  final String activeFilter;
  final void Function(String) onChanged;

  static const _filters = [
    ('all', AppStrings.allFilter),
    ('ai', AppStrings.aiGenerated),
    ('custom', AppStrings.custom),
    ('imported', AppStrings.imported),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: _filters.map((filter) {
          final selected = activeFilter == filter.$1;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              selected: selected,
              label: Text(filter.$2),
              onSelected: (_) => onChanged(filter.$1),
              showCheckmark: false,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              selectedColor: context.colorScheme.secondary,
              labelStyle: context.textTheme.labelMedium?.copyWith(
                color: selected
                    ? context.colorScheme.onSecondary
                    : context.colorScheme.onSurfaceVariant,
              ),
              side: selected
                  ? BorderSide.none
                  : BorderSide(color: context.colorScheme.outlineVariant),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            OutlinedSvgAssets.exclamationCircle,
            width: AppSizing.iconLg,
            height: AppSizing.iconLg,
            colorFilter: ColorFilter.mode(
              context.colorScheme.error,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(message),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ],
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
            OutlinedSvgAssets.clipboardDocumentList,
            width: AppSizing.iconLg,
            height: AppSizing.iconLg,
            colorFilter: ColorFilter.mode(
              context.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.noProgrammesYet,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.noProgrammesYetHint,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
