import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/programmes/presentation/widgets/programme_template_quick_create_sheet.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/exercise_search_controller.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';

Future<ProgrammeBuilderTemplateDraft?> _showSheet(WidgetTester tester) async {
  ProgrammeBuilderTemplateDraft? result;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        AppProviders.exerciseSearchControllerProvider.overrideWith(
          () => _StubExerciseSearchController(),
        ),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result =
                    await showModalBottomSheet<ProgrammeBuilderTemplateDraft>(
                      context: context,
                      builder: (_) => const ProgrammeTemplateQuickCreateSheet(),
                    );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pump();
  return result;
}

class _StubExerciseSearchController extends Notifier<ExerciseSearchState>
    implements ExerciseSearchController {
  @override
  ExerciseSearchState build() {
    return const ExerciseSearchState(
      filters: ExerciseFilterState(),
      items: [],
      isLoading: false,
    );
  }

  @override
  Future<void> updateSearchQuery(String query) async {}

  @override
  Future<void> updateFilters(ExerciseFilterState filters) async {}

  @override
  Future<void> clearFilters() async {}

  @override
  Future<void> reload() async {}
}

void main() {
  group('ProgrammeTemplateQuickCreateSheet', () {
    testWidgets('shows create template title', (tester) async {
      await _showSheet(tester);
      expect(find.text(AppStrings.createTemplate), findsAtLeast(1));
    });

    testWidgets('shows template name field', (tester) async {
      await _showSheet(tester);
      expect(find.text(AppStrings.templateName), findsOneWidget);
      expect(find.text(AppStrings.templateNameHint), findsOneWidget);
    });

    testWidgets('shows add exercises button', (tester) async {
      await _showSheet(tester);
      expect(find.text(AppStrings.selectExercisesForTemplate), findsOneWidget);
    });

    testWidgets('create template button is disabled when name is empty', (
      tester,
    ) async {
      await _showSheet(tester);
      final createButton = find.widgetWithText(
        FilledButton,
        AppStrings.createTemplate,
      );
      expect(tester.widget<FilledButton>(createButton).enabled, isFalse);
    });

    testWidgets(
      'create template button stays disabled with name but no exercises',
      (tester) async {
        await _showSheet(tester);
        await tester.enterText(find.byType(TextField).first, 'My Template');
        await tester.pump();
        final createButton = find.widgetWithText(
          FilledButton,
          AppStrings.createTemplate,
        );
        expect(tester.widget<FilledButton>(createButton).enabled, isFalse);
      },
    );
  });
}
