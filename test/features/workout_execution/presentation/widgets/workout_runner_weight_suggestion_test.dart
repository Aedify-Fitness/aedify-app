import 'package:go_router/go_router.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/workout_execution/application/weight_suggestion_providers.dart';
import 'package:aedify/features/workout_execution/data/weight_suggestion_repository.dart';
import 'package:aedify/features/workout_execution/domain/weight_suggestion.dart';
import 'package:aedify/features/workout_execution/presentation/weight_suggestion_strings.dart';
import 'package:aedify/features/workout_execution/presentation/widgets/workout_runner_weight_suggestion.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/workout_execution/weight_suggestion_fixtures.dart';

class _Evidence implements WeightSuggestionRepository {
  const _Evidence(this.evidence);
  final WeightSuggestionEvidence evidence;
  @override
  Stream<WeightSuggestionEvidence> watchEvidence(int exerciseId) =>
      Stream.value(evidence);
}

void main() {
  Widget app({
    required ValueChanged<WeightSuggestion> onUse,
    bool targets = true,
    double? entered,
    bool enabled = true,
    bool history = true,
    bool dark = false,
    double scale = 1,
    SetType type = SetType.working,
  }) {
    final set = WeightSuggestionFixtures.set(
      targets: targets,
      weight: entered,
      type: type,
    );
    final member = WeightSuggestionFixtures.exercise(sets: [set]);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(
              child: WorkoutRunnerWeightSuggestion(
                session: WeightSuggestionFixtures.session(member: member),
                exercise: member,
                set: set,
                enabled: enabled,
                onUse: onUse,
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    return ProviderScope(
      overrides: [
        WeightSuggestionProviders.repositoryProvider.overrideWithValue(
          _Evidence(
            WeightSuggestionEvidence(
              supported: true,
              references: history ? [WeightSuggestionFixtures.reference()] : [],
            ),
          ),
        ),
        WeightSuggestionProviders.clockProvider.overrideWithValue(
          () => WeightSuggestionFixtures.now,
        ),
      ],
      child: MaterialApp.router(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        routerConfig: router,
      ),
    );
  }

  testWidgets(
    'planned target shows a proposal and only Use invokes the callback',
    (tester) async {
      WeightSuggestion? applied;
      await tester.pumpWidget(app(onUse: (value) => applied = value));
      await tester.pumpAndSettle();
      expect(find.text('Suggested 95 kg'), findsOneWidget);
      expect(applied, isNull);
      await tester.tap(find.byKey(const Key('runner_use_suggested_weight')));
      expect(applied!.weightKg, 95);
      expect(applied!.target.reps, 5);
      expect(applied!.target.rpe, 8);
    },
  );
  testWidgets('entered weights and paused logging cannot be overwritten', (
    tester,
  ) async {
    for (final config in [(42.0, true), (null, false)]) {
      var calls = 0;
      await tester.pumpWidget(
        app(onUse: (_) => calls++, entered: config.$1, enabled: config.$2),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const Key('runner_use_suggested_weight')),
            )
            .onPressed,
        isNull,
      );
      expect(calls, 0);
    }
  });
  testWidgets(
    'standalone target picker validates inputs then offers a weight without applying it',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(app(targets: false, onUse: (_) => calls++));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('runner_choose_weight_target')));
      await tester.pumpAndSettle();
      final reps = find.descendant(
        of: find.byKey(const Key('weight_estimate_target_reps')),
        matching: find.byType(TextField),
      );
      await tester.enterText(reps, '0');
      await tester.tap(find.byKey(const Key('weight_estimate_calculate')));
      await tester.pumpAndSettle();
      expect(
        find.text(AppErrorStrings.weightSuggestionTargetInvalid),
        findsOneWidget,
      );
      await tester.enterText(reps, '5');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('weight_estimate_calculate')));
      await tester.pumpAndSettle();
      expect(find.text('Suggested 95 kg'), findsOneWidget);
      expect(calls, 0);
    },
  );
  testWidgets(
    'missing history leaves manual logging alone and warmups have no prompt',
    (tester) async {
      await tester.pumpWidget(app(history: false, onUse: (_) {}));
      await tester.pumpAndSettle();
      expect(find.text(WeightSuggestionStrings.noHistory), findsOneWidget);
      expect(
        find.byKey(const Key('runner_use_suggested_weight')),
        findsNothing,
      );
      await tester.pumpWidget(app(type: SetType.warmup, onUse: (_) {}));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('runner_weight_suggestion')), findsNothing);
    },
  );
  for (final dark in [false, true]) {
    testWidgets(
      'hint and provenance fit a small phone at 2x text: dark=$dark',
      (tester) async {
        tester.view.physicalSize = const Size(320, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(app(dark: dark, scale: 2, onUse: (_) {}));
        await tester.pumpAndSettle();
        final why = find.byKey(const Key('runner_weight_suggestion_reason'));
        await tester.ensureVisible(why);
        await tester.tap(why);
        await tester.pumpAndSettle();
        expect(find.textContaining('100 kg × 5 @ RPE 9'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
