import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_library_screen.dart';
import 'package:aedify/features/programmes/presentation/saved_workout_library_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/theme/app_durations.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:aedify/shared/theme/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Collects exercise browsing and saved workouts in one local library.
class LibraryHubScreen extends ConsumerStatefulWidget {
  const LibraryHubScreen({super.key});

  @override
  ConsumerState<LibraryHubScreen> createState() => _LibraryHubScreenState();
}

class _LibraryHubScreenState extends ConsumerState<LibraryHubScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _tabController = _controller(AppDurations.segmentedControl);
  }

  TabController _controller(Duration duration) => TabController(
    length: 2,
    initialIndex: _selectedIndex,
    animationDuration: duration,
    vsync: this,
  )..addListener(_onTabChanged);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final duration = _LibraryStyle.motionDuration(context);
    if (_tabController.animationDuration != duration) {
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      _tabController = _controller(duration);
    }
  }

  void _onTabChanged() {
    if (_selectedIndex == _tabController.index || !mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selectedIndex = _tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_creating) return;
    final exercise = _selectedIndex == 0;
    setState(() => _creating = true);
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      await context.pushNamed<bool>(
        exercise
            ? AppRoutes.customExerciseCreate().name
            : AppRoutes.workoutBuilderCreate().name,
      );
      if (!mounted) return;
      if (exercise) {
        await ref
            .read(AppProviders.exerciseSearchControllerProvider.notifier)
            .reload();
      } else {
        await ref
            .read(AppProviders.savedWorkoutLibraryControllerProvider.notifier)
            .reload();
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colorScheme.surface,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const _LibraryHeading(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLibraryTokens.maxContentWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: _LibraryControls(
                  selectedIndex: _selectedIndex,
                  creating: _creating,
                  onCreate: _create,
                  onSelected: (index) => _tabController.animateTo(index),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _LibraryPane(
                  key: ValueKey('library_hub_exercises_pane'),
                  child: ExerciseLibraryScreen(embedded: true),
                ),
                _LibraryPane(
                  key: ValueKey('library_hub_workouts_pane'),
                  child: SavedWorkoutLibraryScreen(embedded: true),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _LibraryHeading extends StatelessWidget {
  const _LibraryHeading();

  @override
  Widget build(BuildContext context) {
    final largeText =
        MediaQuery.textScalerOf(context).scale(AppFontSizes.sm) >
        AppFontSizes.sm * AppLibraryTokens.largeTextBreakpoint;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppLibraryTokens.maxContentWidth,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: largeText ? AppSpacing.sm : AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  AppStrings.navLibrary,
                  style:
                      (largeText
                              ? AppTextStyles.headlineLg.copyWith(
                                  fontSize: AppFontSizes.xl,
                                )
                              : AppTextStyles.headlineLg)
                          .copyWith(color: context.colorScheme.onSurface),
                ),
              ),
              if (!largeText) ...[
                AppWhiteSpace.hSm,
                Text(
                  AppStrings.libraryHubSubtitle,
                  style: _LibraryStyle.body(
                    context,
                  ).copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryControls extends StatelessWidget {
  const _LibraryControls({
    required this.selectedIndex,
    required this.creating,
    required this.onCreate,
    required this.onSelected,
  });
  final int selectedIndex;
  final bool creating;
  final VoidCallback onCreate;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact =
          constraints.maxWidth < AppLibraryTokens.stackedActionsBreakpoint ||
          MediaQuery.textScalerOf(context).scale(AppFontSizes.sm) >
              AppFontSizes.sm * AppLibraryTokens.largeTextBreakpoint;
      final tabs = Material(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _LibraryTab(
                    selectionKey: const ValueKey('library_hub_exercises_tab'),
                    label: AppStrings.exercisesLabel,
                    selected: selectedIndex == 0,
                    onPressed: () => onSelected(0),
                  ),
                ),
                AppWhiteSpace.wXs,
                Expanded(
                  child: _LibraryTab(
                    selectionKey: const ValueKey('library_hub_workouts_tab'),
                    label: AppStrings.programmeWorkoutSlotsTitle,
                    selected: selectedIndex == 1,
                    onPressed: () => onSelected(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final label = selectedIndex == 0
          ? AppStrings.createExercise
          : AppStrings.createWorkout;
      final icon = creating
          ? SizedBox.square(
              dimension: AppSizing.iconSm,
              child: CircularProgressIndicator(
                color: _LibraryStyle.actionForeground(context),
                strokeWidth: AppSizing.strokeWidth,
                semanticsLabel: AppStrings.loading,
              ),
            )
          : SvgPicture.asset(
              OutlinedSvgAssets.plus,
              width: AppSizing.iconMd,
              height: AppSizing.iconMd,
              colorFilter: ColorFilter.mode(
                _LibraryStyle.actionForeground(context),
                BlendMode.srcIn,
              ),
            );
      final create = Tooltip(
        message: label,
        child: IconButton.filled(
          key: const ValueKey('library_hub_create_action'),
          onPressed: creating ? null : onCreate,
          style: IconButton.styleFrom(
            backgroundColor: _LibraryStyle.actionFill(context),
            foregroundColor: _LibraryStyle.actionForeground(context),
            minimumSize: const Size.square(AppLibraryTokens.controlSize),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          icon: icon,
        ),
      );
      return compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tabs,
                AppWhiteSpace.hSm,
                Align(alignment: AlignmentDirectional.centerEnd, child: create),
              ],
            )
          : Row(
              children: [
                Expanded(child: tabs),
                AppWhiteSpace.wControlGap,
                create,
              ],
            );
    },
  );
}

class _LibraryTab extends StatelessWidget {
  const _LibraryTab({
    required this.selectionKey,
    required this.label,
    required this.selected,
    required this.onPressed,
  });
  final Key selectionKey;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final highContrast = MediaQuery.highContrastOf(context);
    final dark = context.theme.brightness == Brightness.dark;
    final fill = highContrast
        ? (dark ? context.colorScheme.primary : context.colorScheme.secondary)
        : (dark
              ? context.colorScheme.surfaceContainerHigh
              : context.colorScheme.surfaceContainerLowest);
    final foreground = selected && highContrast
        ? (dark
              ? context.colorScheme.onPrimary
              : context.colorScheme.onSecondary)
        : selected
        ? _LibraryStyle.accent(context)
        : context.colorScheme.onSurfaceVariant;
    return Semantics(
      key: selectionKey,
      selected: selected,
      button: true,
      inMutuallyExclusiveGroup: true,
      label: label,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: _LibraryStyle.motionDuration(context),
          decoration: BoxDecoration(
            color: selected ? fill : fill.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Material(
            color: fill.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppLibraryTokens.controlSize,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.controlGap,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: _LibraryStyle.label(
                        context,
                      ).copyWith(color: foreground),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryPane extends StatefulWidget {
  const _LibraryPane({super.key, required this.child});
  final Widget child;
  @override
  State<_LibraryPane> createState() => _LibraryPaneState();
}

class _LibraryPaneState extends State<_LibraryPane>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

abstract final class _LibraryStyle {
  static bool _isDark(BuildContext context) =>
      context.theme.brightness == Brightness.dark;
  static TextStyle body(BuildContext context) =>
      (_isDark(context) ? AppTextStylesDark.bodyMd : AppTextStyles.bodyMd)
          .copyWith(color: context.colorScheme.onSurface);
  static TextStyle label(BuildContext context) =>
      (_isDark(context) ? AppTextStylesDark.labelMd : AppTextStyles.labelMd)
          .copyWith(color: context.colorScheme.onSurface);
  static Color accent(BuildContext context) => _isDark(context)
      ? context.colorScheme.primary
      : context.colorScheme.secondary;
  static Color actionFill(BuildContext context) => _isDark(context)
      ? context.colorScheme.primaryContainer
      : context.colorScheme.secondary;
  static Color actionForeground(BuildContext context) => _isDark(context)
      ? context.colorScheme.onPrimaryContainer
      : context.colorScheme.onSecondary;
  static Duration motionDuration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ||
          MediaQuery.accessibleNavigationOf(context)
      ? Duration.zero
      : AppDurations.segmentedControl;
}
