import 'package:aedify/features/programmes/domain/programme_aggregate.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/constants/svg_assets_solid.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

final _programmeListProvider = FutureProvider<List<ProgrammeAggregate>>((ref) {
  final repository = ref.read(AppProviders.programmeRepositoryProvider);
  return repository.listProgrammes();
});

class ProgrammesScreen extends ConsumerWidget {
  const ProgrammesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(_programmeListProvider);

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
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const _ProgrammesErrorView(),
        data: (programmes) => _ProgrammeContent(programmes: programmes),
      ),
    );
  }
}

class _ProgrammesErrorView extends ConsumerWidget {
  const _ProgrammesErrorView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Text(AppStrings.programmesLoadFailed),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => ref.invalidate(_programmeListProvider),
            child: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}

class _ProgrammeContent extends StatelessWidget {
  const _ProgrammeContent({required this.programmes});

  final List<ProgrammeAggregate> programmes;

  @override
  Widget build(BuildContext context) {
    if (programmes.isEmpty) {
      return const _EmptyProgrammesView();
    }
    return _ProgrammeListView(programmes: programmes);
  }
}

class _EmptyProgrammesView extends StatelessWidget {
  const _EmptyProgrammesView();

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

class _ProgrammeListView extends StatelessWidget {
  const _ProgrammeListView({required this.programmes});

  final List<ProgrammeAggregate> programmes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: programmes.length,
      itemBuilder: (context, index) {
        final aggregate = programmes[index];
        final program = aggregate.program;
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            title: Text(program.name),
            subtitle: Text(
              '${program.weeksTotal ?? 0} weeks, ${program.daysPerWeek ?? 0} days/week',
            ),
            trailing: program.active
                ? SvgPicture.asset(
                    SolidSvgAssets.checkCircle,
                    width: AppSizing.iconMd,
                    height: AppSizing.iconMd,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  )
                : null,
            onTap: () => context.pushNamed(
              AppRoutes.programmeBuilderEdit().name,
              pathParameters: {'id': program.id},
            ),
          ),
        );
      },
    );
  }
}
