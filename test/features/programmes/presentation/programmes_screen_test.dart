import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/programmes/application/list_programmes_use_case.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/features/programmes/presentation/programmes_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _ListProgrammes implements ListProgrammesUseCase {
  @override
  Future<List<ProgrammeListItem>> execute() async => [
    for (final status in [ProgramStatus.draft, ProgramStatus.inactive])
      ProgrammeListItem(
        id: status.name,
        name: status == ProgramStatus.draft
            ? 'Unfinished plan'
            : 'Published plan',
        status: status,
        active: false,
        weeksTotal: 2,
        daysPerWeek: 3,
        updatedAt: DateTime(2026),
      ),
  ];
}

class _Harness {
  _Harness._();

  static Future<GoRouter> load(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const ProgrammesScreen()),
        GoRoute(
          path: AppRoutes.programmeBuilderEdit().path,
          name: AppRoutes.programmeBuilderEdit().name,
          builder: (_, state) =>
              Scaffold(body: Text('Editing ${state.pathParameters['id']}')),
        ),
        GoRoute(
          path: AppRoutes.programmeCalendar().path,
          name: AppRoutes.programmeCalendar().name,
          builder: (_, state) =>
              Scaffold(body: Text('Calendar ${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          AppProviders.listProgrammesUseCaseProvider.overrideWithValue(
            _ListProgrammes(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }
}

void main() {
  testWidgets(
    'draft badge opens the builder while published plans open calendars',
    (tester) async {
      final router = await _Harness.load(tester);
      expect(find.text(AppStrings.programmeDraft), findsOneWidget);
      await tester.tap(find.text('Unfinished plan'));
      await tester.pumpAndSettle();
      expect(find.text('Editing draft'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Published plan'));
      await tester.tap(find.text('Published plan'));
      await tester.pumpAndSettle();
      expect(find.text('Calendar inactive'), findsOneWidget);
    },
  );

  testWidgets(
    'Drafts filter shows resumable drafts without an activation action',
    (tester) async {
      await _Harness.load(tester);
      await tester.tap(find.text(AppStrings.programmeDrafts));
      await tester.pumpAndSettle();
      expect(find.text('Unfinished plan'), findsOneWidget);
      expect(find.text('Published plan'), findsNothing);
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.edit), findsOneWidget);
      expect(find.text(AppStrings.activateProgramme), findsNothing);
      expect(find.text(AppStrings.deleteProgramme), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
