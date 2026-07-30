import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/bodymap/domain/bodymap_bucket.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/data/onboarding_repository.dart';
import 'package:aedify/features/onboarding/presentation/onboarding_screen.dart';
import 'package:aedify/features/onboarding/presentation/widgets/onboarding_selection_pill.dart';
import 'package:aedify/features/settings/data/byok_repository.dart';
import 'package:aedify/features/settings/domain/byok_config_view_data.dart';
import 'package:aedify/features/settings/domain/byok_edit_draft.dart';
import 'package:aedify/features/settings/domain/byok_model_option.dart';
import 'package:aedify/features/settings/domain/byok_provider_option.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/constants/image_assets.dart';
import 'package:aedify/shared/constants/svg_assets_outlined.dart';
import 'package:aedify/shared/domain/ai_provider_name.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/exercise_modality.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/app_text_styles.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  bool _completed = false;
  OnboardingDraft? _saved;

  @override
  Future<bool> isOnboardingCompleted() async => _completed;

  @override
  Future<OnboardingDraft?> loadOnboardingDraft() async => _saved;

  @override
  Future<void> saveOnboardingDraft(OnboardingDraft draft) async {
    _saved = draft;
  }

  @override
  Future<void> completeOnboarding(OnboardingDraft draft) async {
    _saved = draft;
    _completed = true;
  }

  @override
  Future<void> clearOnboardingDraft() async {
    _saved = null;
  }
}

class _FakeByokRepository implements ByokRepository {
  _FakeByokRepository({this.validationResult = true});

  bool validationResult;
  final events = <String>[];
  String? validatedKey;
  ByokEditDraft? savedDraft;

  @override
  Future<void> clearActiveConfig() async {}

  @override
  Future<void> deleteConfig(String configId) async {}

  @override
  Future<ByokConfigViewData?> getActiveConfig() async => null;

  @override
  Future<List<ByokConfigViewData>> getConfigs() async => const [];

  @override
  Future<List<ByokProviderOption>> getProviderOptions() async => const [
    ByokProviderOption(
      id: 'openai',
      providerName: AiProviderName.openai,
      displayName: AppStrings.byokProviderNameOpenAi,
      description: AppStrings.byokProviderOpenAiDescription,
      models: [
        ByokModelOption(
          id: 'gpt-4o',
          displayName: AppStrings.byokModelGpt4o,
          inputCostPer1kTokens: 0.0025,
          outputCostPer1kTokens: 0.01,
        ),
        ByokModelOption(
          id: 'gpt-4o-mini',
          displayName: AppStrings.byokModelGpt4oMini,
          inputCostPer1kTokens: 0.00015,
          outputCostPer1kTokens: 0.0006,
        ),
      ],
    ),
  ];

  @override
  Future<bool> hasKey(String configId) async => savedDraft != null;

  @override
  Future<void> rotateKey({
    required String configId,
    required AiProviderName providerName,
    required String newApiKey,
  }) async {}

  @override
  Future<String> saveConfig(ByokEditDraft draft) async {
    events.add('save');
    savedDraft = draft;
    return 'onboarding-test-config';
  }

  @override
  Future<void> setActiveConfig(String configId) async {}

  @override
  Future<bool> validateKey({
    required AiProviderName providerName,
    required String apiKey,
  }) async {
    events.add('validate');
    validatedKey = apiKey;
    return validationResult;
  }
}

ExerciseDetailViewData exerciseDetail(int id, String name) {
  return ExerciseDetailViewData(
    id: id,
    name: name,
    difficulty: null,
    primaryMuscles: const [],
    muscleGroups: const <BodymapBucket>{},
    category: null,
    modality: ExerciseModality.strength,
    equipment: null,
    force: null,
    mechanic: null,
    grips: const [],
    steps: const [],
    videos: const [],
    isFavorite: false,
    isSubstitutedOut: false,
  );
}

Widget createTestApp(
  OnboardingRepository repository, {
  Map<int, String> exerciseNames = const {},
  ByokRepository? byokRepository,
}) {
  return ProviderScope(
    overrides: [
      AppProviders.onboardingRepositoryProvider.overrideWithValue(repository),
      if (byokRepository != null)
        AppProviders.byokRepositoryProvider.overrideWithValue(byokRepository),
      AppProviders.exerciseDetailControllerProvider.overrideWith((ref, id) {
        final name = exerciseNames[id];
        return Future.value(name == null ? null : exerciseDetail(id, name));
      }),
    ],
    child: const MaterialApp(home: OnboardingScreen()),
  );
}

void useFixedMobileSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> pumpUntilLoaded(
  WidgetTester tester, {
  Map<int, String> exerciseNames = const {},
  ByokRepository? byokRepository,
}) async {
  useFixedMobileSurface(tester);
  await tester.pumpWidget(
    createTestApp(
      _FakeOnboardingRepository(),
      exerciseNames: exerciseNames,
      byokRepository: byokRepository,
    ),
  );
  await tester.pump();
  await tester.pump();
}

Finder assetImage(String assetName) {
  return find.byWidgetPredicate((widget) {
    return widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == assetName;
  });
}

Future<void> tapPrimaryButton(
  WidgetTester tester, {
  String label = AppStrings.continueLabel,
}) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
}

Future<void> tapVisibleText(WidgetTester tester, String label) async {
  final target = find.text(label).first;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pump();
}

Future<void> advanceToExperience(WidgetTester tester) async {
  await tapPrimaryButton(tester, label: AppStrings.onboardingInitializeSpace);
  await tapPrimaryButton(tester);
}

Future<void> advanceToSchedule(WidgetTester tester) async {
  await advanceToExperience(tester);
  await tapVisibleText(tester, AppStrings.onboardingExperienceAdept);
  await tapPrimaryButton(tester);
}

Future<void> advanceToLimitations(WidgetTester tester) async {
  await advanceToSchedule(tester);
  await selectTrainingDays(tester, const [TrainingDay.monday]);
  await tapPrimaryButton(tester);
  await tapPrimaryButton(tester);
}

Future<void> advanceToMetrics(WidgetTester tester) async {
  await advanceToLimitations(tester);
  await tapPrimaryButton(tester, label: AppStrings.onboardingNextStep);
}

Future<void> advanceToByok(WidgetTester tester) async {
  await advanceToMetrics(tester);
  await tapPrimaryButton(tester);
  await tester.pumpAndSettle();
}

Future<void> advanceToReview(WidgetTester tester) async {
  await advanceToByok(tester);
  await tapPrimaryButton(tester);
  await tester.pumpAndSettle();
}

Future<void> selectTrainingDays(
  WidgetTester tester,
  Iterable<TrainingDay> days,
) async {
  for (final day in days) {
    await tapVisibleText(tester, day.displayLabel);
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  group('OnboardingScreen', () {
    testWidgets('fresh install shows onboarding welcome', (tester) async {
      await pumpUntilLoaded(tester);

      expect(
        find.text(AppStrings.onboardingWelcomeHeroDescription),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, AppStrings.onboardingInitializeSpace),
        findsOneWidget,
      );
      expect(assetImage(ImageAssets.onboardingWelcomeGym), findsNothing);
    });

    testWidgets('welcome retains logo and uses the nine-segment stepper', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);

      final logo = find.byWidgetPredicate((widget) {
        if (widget is! Image || widget.image is! AssetImage) {
          return false;
        }
        final assetName = (widget.image as AssetImage).assetName;
        return assetName == ImageAssets.logoLight ||
            assetName == ImageAssets.logoDark;
      });
      expect(logo, findsOneWidget);
      expect(find.text(AppStrings.onboardingStepLabel(1, 9)), findsOneWidget);

      final progressSegments = find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith('onboarding_progress_segment_');
      });
      expect(progressSegments, findsNWidgets(9));
      for (var index = 0; index < 9; index++) {
        expect(
          find.byKey(ValueKey<String>('onboarding_progress_segment_$index')),
          findsOneWidget,
        );
      }
    });

    testWidgets('goal pills expose distinct selected and unselected states', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);

      await advanceToExperience(tester);

      final selectedGoal = find.widgetWithText(
        OnboardingSelectionPill,
        AppStrings.onboardingGoalBuildMuscle,
      );
      final unselectedGoal = find.widgetWithText(
        OnboardingSelectionPill,
        AppStrings.onboardingGoalLoseWeight,
      );
      await tester.ensureVisible(selectedGoal);
      await tester.pump();

      expect(
        tester.widget<OnboardingSelectionPill>(selectedGoal).selected,
        isFalse,
      );
      expect(
        find.descendant(of: selectedGoal, matching: find.byType(SvgPicture)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: selectedGoal,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SvgPicture &&
                widget.bytesLoader is SvgAssetLoader &&
                (widget.bytesLoader as SvgAssetLoader).assetName ==
                    OutlinedSvgAssets.materialWorkspacePremium,
          ),
        ),
        findsOneWidget,
      );

      await tester.tap(selectedGoal);
      await tester.pump();

      expect(
        tester.widget<OnboardingSelectionPill>(selectedGoal).selected,
        isTrue,
      );
      expect(
        tester.widget<OnboardingSelectionPill>(unselectedGoal).selected,
        isFalse,
      );
      expect(
        find.descendant(of: selectedGoal, matching: find.byType(SvgPicture)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: selectedGoal,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SvgPicture &&
                widget.bytesLoader is SvgAssetLoader &&
                (widget.bytesLoader as SvgAssetLoader).assetName ==
                    OutlinedSvgAssets.materialCheck,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('step three uses path cards and Continue action copy', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);
      await advanceToExperience(tester);

      expect(
        find.text(AppStrings.onboardingExperiencePathDisplayTitle),
        findsOneWidget,
      );
      expect(find.text(AppStrings.onboardingExperienceNovice), findsOneWidget);
      expect(find.text(AppStrings.onboardingExperienceAdept), findsOneWidget);
      expect(find.text(AppStrings.onboardingExperienceElite), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, AppStrings.continueLabel),
        findsOneWidget,
      );
    });

    testWidgets('step four uses rhythm bento layout and action copy', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);
      await advanceToSchedule(tester);

      expect(
        find.text(AppStrings.onboardingRhythmDisplayTitle),
        findsOneWidget,
      );
      expect(find.text(AppStrings.onboardingTotalWeeklyLoad), findsOneWidget);
      expect(find.text(AppStrings.onboardingScheduleHours(0)), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, AppStrings.continueLabel),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextButton, AppStrings.backLabel),
        findsOneWidget,
      );
      final durationRulerMarks = find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith('schedule_duration_ruler_');
      });
      expect(durationRulerMarks, findsNWidgets(10));
      final weeklyLoadBars = find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith('onboarding_schedule_bar_');
      });
      expect(weeklyLoadBars, findsNWidgets(7));
      expect(
        find.text(AppStrings.onboardingScheduleEndurance.toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.onboardingScheduleIntensity.toUpperCase()),
        findsOneWidget,
      );
    });

    testWidgets('core identity Material Symbol SVGs are bundled and rendered', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);
      await tapPrimaryButton(
        tester,
        label: AppStrings.onboardingInitializeSpace,
      );

      const coreIdentityAssets = [
        OutlinedSvgAssets.materialMale,
        OutlinedSvgAssets.materialFemale,
        OutlinedSvgAssets.materialTransgender,
      ];
      for (final asset in coreIdentityAssets) {
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is SvgPicture &&
                widget.bytesLoader is SvgAssetLoader &&
                (widget.bytesLoader as SvgAssetLoader).assetName == asset,
          ),
          findsOneWidget,
        );

        final svgMarkup = await rootBundle.loadString(asset);
        expect(svgMarkup.trimLeft(), startsWith('<svg'));
        expect(svgMarkup, contains('<path'));
      }
    });

    testWidgets('action bar stays pinned while core identity content scrolls', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);

      final welcomeAction = find.widgetWithText(
        FilledButton,
        AppStrings.onboardingInitializeSpace,
      );
      expect(tester.getBottomRight(welcomeAction).dy, lessThanOrEqualTo(844));

      await tester.tap(welcomeAction);
      await tester.pump();

      final continueAction = find.widgetWithText(
        FilledButton,
        AppStrings.continueLabel,
      );
      final backAction = find.widgetWithText(TextButton, AppStrings.backLabel);
      final initialTop = tester.getTopLeft(continueAction).dy;
      expect(
        tester.getTopLeft(continueAction).dy,
        lessThan(tester.getTopLeft(backAction).dy),
      );

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -AppSpacing.xxxl),
      );
      await tester.pump();

      expect(tester.getTopLeft(continueAction).dy, initialTop);
    });

    testWidgets('measurement selector uses inset selected treatment', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);
      await tapPrimaryButton(
        tester,
        label: AppStrings.onboardingInitializeSpace,
      );

      AnimatedContainer choiceContainer(String label) {
        return tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
      }

      final metricDecoration =
          choiceContainer(AppStrings.onboardingMetricChoice).decoration
              as BoxDecoration;
      final imperialDecoration =
          choiceContainer(AppStrings.onboardingImperialChoice).decoration
              as BoxDecoration;

      expect(metricDecoration.boxShadow, isNotEmpty);
      expect(imperialDecoration.boxShadow, isNull);

      final imperialChoice = find.text(AppStrings.onboardingImperialChoice);
      await tester.ensureVisible(imperialChoice);
      await tester.tap(imperialChoice);
      await tester.pumpAndSettle();

      final selectedImperialDecoration =
          choiceContainer(AppStrings.onboardingImperialChoice).decoration
              as BoxDecoration;
      expect(selectedImperialDecoration.boxShadow, isNotEmpty);
    });

    testWidgets('continue advances to experience step', (tester) async {
      await pumpUntilLoaded(tester);

      await tapPrimaryButton(
        tester,
        label: AppStrings.onboardingInitializeSpace,
      );

      expect(find.text(AppStrings.onboardingCoreIdentityTitle), findsWidgets);
      await tapPrimaryButton(tester);

      expect(find.text(AppStrings.experienceLevel), findsOneWidget);
    });

    testWidgets('continue blocked when experienceLevel is missing', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);

      await advanceToExperience(tester);
      await tapPrimaryButton(tester);
      await tester.pump();

      expect(
        find.text(AppStrings.onboardingValidationRequired),
        findsOneWidget,
      );
      expect(find.text(AppStrings.experienceLevel), findsOneWidget);
    });

    testWidgets('step transitions work through full flow', (tester) async {
      await pumpUntilLoaded(tester);

      await advanceToSchedule(tester);
      await selectTrainingDays(tester, const [
        TrainingDay.monday,
        TrainingDay.tuesday,
        TrainingDay.wednesday,
        TrainingDay.thursday,
      ]);
      await tapPrimaryButton(tester);
      expect(find.text(AppStrings.onboardingGymEnvironmentTitle), findsWidgets);

      await tapPrimaryButton(tester);
      expect(find.text(AppStrings.onboardingSafetyFirst), findsOneWidget);

      await tapPrimaryButton(tester, label: AppStrings.onboardingNextStep);
      expect(find.text(AppStrings.onboardingEliteBaselineTitle), findsWidgets);

      await tapPrimaryButton(tester);
      expect(
        find.text(AppStrings.onboardingIntelligenceLayerTitle),
        findsWidgets,
      );

      await tapPrimaryButton(tester);
      expect(find.text(AppStrings.onboardingFinalReviewTitle), findsWidgets);
    });

    testWidgets('Continue from BYOK advances to review', (tester) async {
      await pumpUntilLoaded(tester);

      await advanceToSchedule(tester);
      await selectTrainingDays(tester, const [TrainingDay.monday]);
      await tapPrimaryButton(tester);
      expect(tester.takeException(), isNull, reason: 'gym environment');
      await tapPrimaryButton(tester);
      expect(tester.takeException(), isNull, reason: 'limitations');
      await tapPrimaryButton(tester, label: AppStrings.onboardingNextStep);
      expect(tester.takeException(), isNull, reason: 'metrics');
      await tapPrimaryButton(tester);
      expect(tester.takeException(), isNull, reason: 'BYOK');

      expect(
        find.text(AppStrings.onboardingIntelligenceLayerTitle),
        findsWidgets,
      );
      await tapPrimaryButton(tester);
      expect(tester.takeException(), isNull, reason: 'review');

      expect(find.text(AppStrings.onboardingFinalReviewTitle), findsWidgets);
    });

    testWidgets('back button navigates from schedule to experience goals', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);

      await advanceToSchedule(tester);

      await tapVisibleText(tester, AppStrings.backLabel);

      expect(find.text(AppStrings.experienceLevel), findsOneWidget);
    });

    testWidgets('validation message is shown for invalid step', (tester) async {
      await pumpUntilLoaded(tester);

      await advanceToExperience(tester);
      await tapPrimaryButton(tester);
      await tester.pump();

      expect(
        find.text(AppStrings.onboardingValidationRequired),
        findsOneWidget,
      );
    });

    testWidgets('weekday choices derive the selected weekly frequency', (
      tester,
    ) async {
      final repo = _FakeOnboardingRepository();
      useFixedMobileSurface(tester);
      await tester.pumpWidget(createTestApp(repo));
      await tester.pump();
      await tester.pump();
      await advanceToSchedule(tester);

      for (final day in TrainingDay.values) {
        expect(find.text(day.displayLabel), findsOneWidget);
      }
      for (var count = 1; count <= TrainingDay.values.length; count++) {
        expect(find.text('$count'), findsNothing);
      }

      const selectedDays = [
        TrainingDay.monday,
        TrainingDay.wednesday,
        TrainingDay.saturday,
      ];
      await selectTrainingDays(tester, selectedDays);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(OnboardingScreen)),
      );
      final currentDraft = container
          .read(AppProviders.onboardingControllerProvider)
          .requireValue
          .draft;
      expect(currentDraft.trainingDays, selectedDays);
      expect(currentDraft.trainingDaysPerWeek, selectedDays.length);

      await tester.pump(const Duration(milliseconds: 500));
      expect(repo._saved?.trainingDays, selectedDays);
      expect(repo._saved?.trainingDaysPerWeek, selectedDays.length);
    });

    testWidgets('gym environment includes supplied images and SVG symbols', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);
      await advanceToSchedule(tester);
      await selectTrainingDays(tester, const [TrainingDay.monday]);
      await tapPrimaryButton(tester);

      const equipmentImages = [
        ImageAssets.onboardingDumbbells,
        ImageAssets.onboardingBarbell,
        ImageAssets.onboardingBench,
        ImageAssets.onboardingSquatRack,
        ImageAssets.onboardingKettlebells,
        ImageAssets.onboardingResistanceBands,
        ImageAssets.onboardingPullUpBar,
        ImageAssets.onboardingCableMachine,
        ImageAssets.onboardingSmithMachine,
        ImageAssets.onboardingCardioMachine,
      ];
      for (final imageAsset in equipmentImages) {
        expect(assetImage(imageAsset), findsOneWidget);
      }

      const gymSymbolAssets = [
        OutlinedSvgAssets.materialHome,
        OutlinedSvgAssets.materialInventory2,
        OutlinedSvgAssets.materialSettings,
      ];
      for (final asset in gymSymbolAssets) {
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is SvgPicture &&
                widget.bytesLoader is SvgAssetLoader &&
                (widget.bytesLoader as SvgAssetLoader).assetName == asset,
          ),
          findsAtLeastNWidgets(1),
        );

        final svgMarkup = await rootBundle.loadString(asset);
        expect(svgMarkup.trimLeft(), startsWith('<svg'));
        expect(svgMarkup, contains('<path'));
      }
    });

    testWidgets('step six follows the precision constraints section order', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);
      await advanceToLimitations(tester);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == AppStrings.onboardingPrecisionConstraintsTitle &&
              widget.style == AppTextStyles.headlineXl,
        ),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.onboardingPrecisionConstraintsDescription),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, AppStrings.onboardingNextStep),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextButton, AppStrings.backLabel),
        findsOneWidget,
      );

      const orderedSectionKeys = [
        'onboarding_safety_first_section',
        'onboarding_injury_flags_section',
        'onboarding_favorite_exercises_section',
        'onboarding_avoid_exercises_section',
        'onboarding_other_notes_section',
      ];
      final sectionTops = orderedSectionKeys.map((key) {
        final keyedFinder = find.byKey(
          ValueKey<String>(key),
          skipOffstage: false,
        );
        expect(keyedFinder, findsOneWidget);
        return tester.getTopLeft(keyedFinder).dy;
      }).toList();

      for (var index = 1; index < sectionTops.length; index++) {
        expect(sectionTops[index], greaterThan(sectionTops[index - 1]));
      }
    });

    testWidgets('step six limitation tiles preserve draft selection', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);
      await advanceToLimitations(tester);

      await tapVisibleText(tester, AppStrings.onboardingLimitationLowerBack);
      var container = ProviderScope.containerOf(
        tester.element(find.byType(OnboardingScreen)),
      );
      expect(
        container
            .read(AppProviders.onboardingControllerProvider)
            .requireValue
            .draft
            .limitations,
        contains(AppStrings.onboardingLimitationLowerBack),
      );

      await tapVisibleText(tester, AppStrings.onboardingLimitationLowerBack);
      container = ProviderScope.containerOf(
        tester.element(find.byType(OnboardingScreen)),
      );
      expect(
        container
            .read(AppProviders.onboardingControllerProvider)
            .requireValue
            .draft
            .limitations,
        isNot(contains(AppStrings.onboardingLimitationLowerBack)),
      );
    });

    testWidgets('step six exercise chips show names and consolidate overflow', (
      tester,
    ) async {
      final exerciseNames = <int, String>{
        for (var id = 1; id <= 20; id++) id: 'Exercise $id',
      };
      await pumpUntilLoaded(tester, exerciseNames: exerciseNames);
      await advanceToLimitations(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(OnboardingScreen)),
      );
      final controller = container.read(
        AppProviders.onboardingControllerProvider.notifier,
      );
      var draft = container
          .read(AppProviders.onboardingControllerProvider)
          .requireValue
          .draft;

      controller.updateDraft(
        draft.copyWith(
          favoriteExerciseIds: List<int>.generate(8, (index) => index + 1),
          substitutedExerciseIds: const [11, 12, 13],
        ),
      );
      await tester.pumpAndSettle();

      for (var id = 1; id <= 8; id++) {
        expect(find.text('Exercise $id'), findsOneWidget);
      }
      for (var id = 11; id <= 13; id++) {
        expect(find.text('Exercise $id'), findsOneWidget);
      }
      expect(find.text('1 selected'), findsNothing);
      expect(find.text('2 selected'), findsNothing);

      draft = container
          .read(AppProviders.onboardingControllerProvider)
          .requireValue
          .draft;
      controller.updateDraft(
        draft.copyWith(
          favoriteExerciseIds: List<int>.generate(9, (index) => index + 1),
          substitutedExerciseIds: List<int>.generate(10, (index) => index + 11),
        ),
      );
      await tester.pumpAndSettle();

      for (var id = 1; id <= 8; id++) {
        expect(find.text('Exercise $id'), findsOneWidget);
      }
      for (var id = 11; id <= 18; id++) {
        expect(find.text('Exercise $id'), findsOneWidget);
      }
      expect(find.text('Exercise 9'), findsNothing);
      expect(find.text('Exercise 19'), findsNothing);
      expect(find.text('Exercise 20'), findsNothing);
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('2 selected'), findsOneWidget);
    });

    testWidgets('step seven follows the elite baseline card hierarchy', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);
      await advanceToMetrics(tester);

      expect(
        find.text(AppStrings.onboardingEliteBaselineEyebrow.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(AppStrings.onboardingEliteBaselineTitle), findsWidgets);
      expect(
        find.text(AppStrings.onboardingEliteBaselineDescription),
        findsOneWidget,
      );
      expect(find.text(AppStrings.onboardingBenchPressLabel), findsOneWidget);
      expect(find.text(AppStrings.onboardingBackSquatLabel), findsOneWidget);
      expect(find.text(AppStrings.onboardingDeadliftLabel), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, AppStrings.continueLabel),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextButton, AppStrings.backLabel),
        findsOneWidget,
      );

      const orderedCardKeys = [
        'onboarding_baseline_weight_card',
        'onboarding_baseline_height_card',
        'onboarding_baseline_max_lifts_card',
      ];
      final cardTops = orderedCardKeys.map((key) {
        final finder = find.byKey(ValueKey<String>(key), skipOffstage: false);
        expect(finder, findsOneWidget);
        return tester.getTopLeft(finder).dy;
      }).toList();
      expect(cardTops[1], greaterThan(cardTops[0]));
      expect(cardTops[2], greaterThan(cardTops[1]));
    });

    testWidgets('step seven unit controls stay synchronized', (tester) async {
      await pumpUntilLoaded(tester);
      await advanceToMetrics(tester);

      final weightCard = find.byKey(
        const ValueKey<String>('onboarding_baseline_weight_card'),
      );
      final weightField = find.descendant(
        of: weightCard,
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(weightField);
      await tester.enterText(weightField, '100');
      await tester.pump();

      await tapVisibleText(tester, AppStrings.imperialWeightUnit);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(OnboardingScreen)),
      );
      final draft = container
          .read(AppProviders.onboardingControllerProvider)
          .requireValue
          .draft;
      expect(draft.preferredUnits, PreferredUnit.imperial);
      expect(draft.bodyweightKg, closeTo(100, 0.001));

      final imperialWeightButtons = find.text(
        AppStrings.imperialWeightUnit,
        skipOffstage: false,
      );
      final imperialHeightButtons = find.text(
        AppStrings.imperialHeightUnit,
        skipOffstage: false,
      );
      expect(imperialWeightButtons, findsAtLeastNWidgets(2));
      expect(imperialHeightButtons, findsAtLeastNWidgets(2));
    });

    testWidgets('step seven max lifts matches the supplied input treatment', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);
      await advanceToMetrics(tester);

      expect(AppStrings.onboardingMaxLiftsTitle, 'Max Lifts (Optional)');
      expect(find.text(AppStrings.onboardingMaxLiftsHelper), findsOneWidget);

      final heightCard = find.byKey(
        const ValueKey<String>('onboarding_baseline_height_card'),
      );
      final maxLiftsCard = find.byKey(
        const ValueKey<String>('onboarding_baseline_max_lifts_card'),
      );
      expect(
        tester.getTopLeft(maxLiftsCard).dy -
            tester.getBottomLeft(heightCard).dy,
        AppSpacing.xl + AppSpacing.sm,
      );

      final glassSurface = find.byKey(
        const ValueKey<String>('onboarding_max_lifts_glass_surface'),
      );
      final glassDecoration =
          tester.widget<DecoratedBox>(glassSurface).decoration as BoxDecoration;
      expect(glassDecoration.borderRadius, BorderRadius.circular(AppRadius.md));
      expect(glassDecoration.boxShadow, isNotEmpty);

      final accuracyBadge = find.byKey(
        const ValueKey<String>('onboarding_max_lifts_accuracy_badge'),
      );
      expect(accuracyBadge, findsOneWidget);
      final maxLiftsTitle = find.text(AppStrings.onboardingMaxLiftsTitle);
      final maxLiftsHelper = find.text(AppStrings.onboardingMaxLiftsHelper);
      final benchLabel = find.text(AppStrings.onboardingBenchPressLabel);
      expect(
        tester.getTopLeft(maxLiftsHelper).dy -
            tester.getBottomLeft(maxLiftsTitle).dy,
        0,
      );
      expect(
        tester.getTopLeft(accuracyBadge).dy -
            tester.getBottomLeft(maxLiftsHelper).dy,
        AppSpacing.md,
      );
      expect(
        tester.getTopLeft(benchLabel).dy -
            tester.getBottomLeft(accuracyBadge).dy,
        AppSpacing.xl,
      );
      final badgeContainer = tester.widget<Container>(accuracyBadge);
      expect(
        badgeContainer.padding,
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      );
      final badgeDecoration = badgeContainer.decoration as BoxDecoration;
      expect(badgeDecoration.border, isNotNull);
      expect(
        badgeDecoration.borderRadius,
        BorderRadius.circular(AppRadius.full),
      );

      const inputKeys = [
        'onboarding_bench_press_1rm_input',
        'onboarding_back_squat_1rm_input',
        'onboarding_deadlift_1rm_input',
      ];
      final colorScheme = Theme.of(tester.element(maxLiftsCard)).colorScheme;
      final inputTops = <double>[];
      for (final key in inputKeys) {
        final input = find.byKey(ValueKey<String>(key));
        expect(input, findsOneWidget);
        expect(
          tester.getSize(input).height,
          AppSizing.onboardingMaxLiftFieldHeight,
        );
        final decoration =
            tester.widget<AnimatedContainer>(input).decoration as BoxDecoration;
        expect(
          decoration.borderRadius,
          BorderRadius.circular(AppRadius.defaultRadius),
        );
        expect(decoration.color, colorScheme.surfaceContainerLow);
        expect(decoration.border, isNull);

        final textField = tester.widget<TextField>(
          find.descendant(of: input, matching: find.byType(TextField)),
        );
        expect(
          textField.decoration?.suffixStyle?.color,
          colorScheme.onSurfaceVariant,
        );
        inputTops.add(tester.getTopLeft(input).dy);
      }
      expect(inputTops[1], greaterThan(inputTops[0]));
      expect(inputTops[2], greaterThan(inputTops[1]));

      final benchInput = find.byKey(
        const ValueKey<String>('onboarding_bench_press_1rm_input'),
      );
      await tester.ensureVisible(benchInput);
      final benchTextField = find.descendant(
        of: benchInput,
        matching: find.byType(TextField),
      );
      await tester.tap(benchTextField);
      await tester.pumpAndSettle();

      final focusedDecoration =
          tester.widget<AnimatedContainer>(benchInput).decoration
              as BoxDecoration;
      expect(focusedDecoration.border?.top.color, colorScheme.secondary);
      expect(focusedDecoration.border?.top.width, AppSizing.strokeWidth);
      expect(focusedDecoration.color, colorScheme.surfaceContainerLowest);

      await tester.enterText(benchTextField, '120');
      await tester.pump();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(OnboardingScreen)),
      );
      final draft = container
          .read(AppProviders.onboardingControllerProvider)
          .requireValue
          .draft;
      expect(draft.bench1RmKg, closeTo(120, 0.001));

      await tapVisibleText(tester, AppStrings.imperialWeightUnit);
      await tester.pumpAndSettle();
      await tester.ensureVisible(benchInput);
      final imperialBenchTextField = find.descendant(
        of: benchInput,
        matching: find.byType(TextField),
      );
      expect(
        tester.widget<TextField>(imperialBenchTextField).controller?.text,
        '264.6',
      );
      expect(
        container
            .read(AppProviders.onboardingControllerProvider)
            .requireValue
            .draft
            .bench1RmKg,
        closeTo(120, 0.001),
      );

      await tester.enterText(imperialBenchTextField, '');
      await tester.pump();
      expect(
        container
            .read(AppProviders.onboardingControllerProvider)
            .requireValue
            .draft
            .bench1RmKg,
        isNull,
      );
    });

    testWidgets(
      'step seven rulers move like analogue dials and control values',
      (tester) async {
        await pumpUntilLoaded(tester);
        await advanceToMetrics(tester);

        final container = ProviderScope.containerOf(
          tester.element(find.byType(OnboardingScreen)),
        );
        var draft = container
            .read(AppProviders.onboardingControllerProvider)
            .requireValue
            .draft;
        expect(draft.bodyweightKg, isNull);
        expect(draft.heightCm, isNull);

        final weightRuler = find.byKey(
          const ValueKey<String>('onboarding_weight_ruler'),
        );
        await tester.ensureVisible(weightRuler);
        final weightReferenceTick = find.byKey(
          const ValueKey<String>('onboarding_weight_ruler_tick_77'),
        );
        final initialWeightTickX = tester.getCenter(weightReferenceTick).dx;
        final weightGesture = await tester.startGesture(
          tester.getCenter(weightRuler),
        );
        await weightGesture.moveBy(const Offset(AppSpacing.lg, 0));
        await tester.pump();

        expect(
          tester.getCenter(weightReferenceTick).dx,
          greaterThan(initialWeightTickX),
        );

        draft = container
            .read(AppProviders.onboardingControllerProvider)
            .requireValue
            .draft;
        expect(draft.bodyweightKg, closeTo(77.5, 0.001));

        await weightGesture.up();
        await tester.pumpAndSettle();

        final heightRuler = find.byKey(
          const ValueKey<String>('onboarding_height_ruler'),
        );
        await tester.ensureVisible(heightRuler);
        final heightReferenceTick = find.byKey(
          const ValueKey<String>('onboarding_height_ruler_tick_82'),
        );
        final initialHeightTickX = tester.getCenter(heightReferenceTick).dx;
        final heightGesture = await tester.startGesture(
          tester.getCenter(heightRuler),
        );
        await heightGesture.moveBy(const Offset(AppSpacing.lg, 0));
        await tester.pump();

        expect(
          tester.getCenter(heightReferenceTick).dx,
          greaterThan(initialHeightTickX),
        );

        draft = container
            .read(AppProviders.onboardingControllerProvider)
            .requireValue
            .draft;
        expect(draft.heightCm, closeTo(180, 0.001));

        await heightGesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('step eight matches the intelligence layer composition', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);
      await advanceToByok(tester);

      final intro = find.byKey(const ValueKey<String>('onboarding_byok_intro'));
      expect(intro, findsOneWidget);
      expect(
        find.descendant(
          of: intro,
          matching: find.text(AppStrings.configLabel.toUpperCase()),
        ),
        findsOneWidget,
      );

      final introTitle = find.descendant(
        of: intro,
        matching: find.text(AppStrings.onboardingIntelligenceLayerTitle),
      );
      expect(introTitle, findsOneWidget);
      expect(
        tester.widget<Text>(introTitle).style?.fontSize,
        AppFontSizes.displayMd,
      );
      expect(
        find.text(AppStrings.onboardingIntelligenceLayerDescription),
        findsOneWidget,
      );

      final privateBenefit = find.byKey(
        const ValueKey<String>('onboarding_byok_benefit_private'),
      );
      final byokBenefit = find.byKey(
        const ValueKey<String>('onboarding_byok_benefit_byok'),
      );
      final optionalBenefit = find.byKey(
        const ValueKey<String>('onboarding_byok_benefit_optional'),
      );
      expect(
        tester.getTopLeft(privateBenefit).dy,
        lessThan(tester.getTopLeft(byokBenefit).dy),
      );
      expect(
        tester.getTopLeft(byokBenefit).dy,
        lessThan(tester.getTopLeft(optionalBenefit).dy),
      );

      final setupCard = find.byKey(
        const ValueKey<String>('onboarding_byok_setup_card'),
      );
      expect(setupCard, findsOneWidget);
      expect(find.text(AppStrings.onboardingSelectProvider), findsOneWidget);

      final setupSurface = find.descendant(
        of: setupCard,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.padding ==
                  const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
        ),
      );
      final setupDecoration =
          tester.widget<Container>(setupSurface.first).decoration
              as BoxDecoration;
      expect(setupDecoration.borderRadius, BorderRadius.circular(AppRadius.md));
      expect(setupDecoration.border, isNotNull);
      expect(setupDecoration.boxShadow, isNotEmpty);

      final openAiCard = find.byKey(
        const ValueKey<String>('onboarding_byok_provider_openai'),
      );
      final anthropicCard = find.byKey(
        const ValueKey<String>('onboarding_byok_provider_anthropic'),
      );
      final googleCard = find.byKey(
        const ValueKey<String>('onboarding_byok_provider_google'),
      );
      expect(openAiCard, findsOneWidget);
      expect(anthropicCard, findsOneWidget);
      expect(googleCard, findsOneWidget);
      expect(
        tester.getTopLeft(openAiCard).dy,
        lessThan(tester.getTopLeft(anthropicCard).dy),
      );
      expect(
        tester.getTopLeft(anthropicCard).dy,
        lessThan(tester.getTopLeft(googleCard).dy),
      );

      final colorScheme = Theme.of(tester.element(openAiCard)).colorScheme;
      var openAiDecoration =
          tester.widget<AnimatedContainer>(openAiCard).decoration
              as BoxDecoration;
      var anthropicDecoration =
          tester.widget<AnimatedContainer>(anthropicCard).decoration
              as BoxDecoration;
      expect(openAiDecoration.color, colorScheme.surfaceContainerLow);
      expect(openAiDecoration.border?.top.color, colorScheme.secondary);
      expect(openAiDecoration.border?.top.width, AppSizing.strokeWidth);
      expect(anthropicDecoration.border?.top.width, AppSizing.divider);
      expect(find.text(AppStrings.byokModelGpt4oMini), findsOneWidget);
      expect(find.text(AppStrings.onboardingOpenAiApiKeyLabel), findsOneWidget);

      await tester.ensureVisible(anthropicCard);
      await tester.tap(anthropicCard);
      await tester.pumpAndSettle();

      openAiDecoration =
          tester.widget<AnimatedContainer>(openAiCard).decoration
              as BoxDecoration;
      anthropicDecoration =
          tester.widget<AnimatedContainer>(anthropicCard).decoration
              as BoxDecoration;
      expect(openAiDecoration.border?.top.width, AppSizing.divider);
      expect(anthropicDecoration.color, colorScheme.surfaceContainerLow);
      expect(anthropicDecoration.border?.top.color, colorScheme.secondary);
      expect(anthropicDecoration.border?.top.width, AppSizing.strokeWidth);
      expect(
        find.text(AppStrings.onboardingAnthropicApiKeyLabel),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.onboardingAnthropicApiKeyHint),
        findsOneWidget,
      );
      expect(find.text(AppStrings.byokModelClaudeHaiku45), findsOneWidget);

      final apiKeyField = find.byKey(
        const ValueKey<String>('onboarding_byok_api_key_field'),
      );
      await tester.ensureVisible(apiKeyField);
      var textField = tester.widget<TextField>(
        find.descendant(of: apiKeyField, matching: find.byType(TextField)),
      );
      expect(
        tester.getSize(apiKeyField).height,
        AppSizing.onboardingByokFieldHeight,
      );
      expect(textField.obscureText, isTrue);

      await tester.tap(find.byTooltip(AppStrings.showApiKey));
      await tester.pump();
      textField = tester.widget<TextField>(
        find.descendant(of: apiKeyField, matching: find.byType(TextField)),
      );
      expect(textField.obscureText, isFalse);

      await tester.enterText(
        find.descendant(of: apiKeyField, matching: find.byType(TextField)),
        'sk-ant-api03-test',
      );
      await tester.pump();
      final secureConnection = find.byKey(
        const ValueKey<String>('onboarding_byok_secure_connection'),
      );
      expect(
        tester.widget<FilledButton>(secureConnection).onPressed,
        isNotNull,
      );
      expect(
        find.text(AppStrings.onboardingApiKeySecureHelper),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('onboarding_byok_secure_divider')),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(
          FilledButton,
          AppStrings.onboardingSecureConnection,
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, AppStrings.continueLabel),
        findsOneWidget,
      );
      expect(find.text(AppStrings.backLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('step eight validates before saving the provider key', (
      tester,
    ) async {
      final byokRepository = _FakeByokRepository(validationResult: false);
      await pumpUntilLoaded(tester, byokRepository: byokRepository);
      await advanceToByok(tester);

      final apiKeyField = find.byKey(
        const ValueKey<String>('onboarding_byok_api_key_field'),
      );
      await tester.ensureVisible(apiKeyField);
      final textField = find.descendant(
        of: apiKeyField,
        matching: find.byType(TextField),
      );
      await tester.enterText(textField, 'sk-test-rejected');
      await tester.pump();

      final secureConnection = find.byKey(
        const ValueKey<String>('onboarding_byok_secure_connection'),
      );
      await tester.ensureVisible(secureConnection);
      await tester.tap(secureConnection);
      await tester.pumpAndSettle();

      expect(byokRepository.events, ['validate']);
      expect(byokRepository.savedDraft, isNull);
      expect(
        find.text(AppErrorStrings.byokKeyValidationFailed),
        findsOneWidget,
      );

      byokRepository.validationResult = true;
      await tester.enterText(textField, ' sk-test-valid ');
      await tester.pump();
      await tester.tap(secureConnection);
      await tester.pumpAndSettle();

      expect(byokRepository.events, ['validate', 'validate', 'save']);
      expect(byokRepository.validatedKey, 'sk-test-valid');
      expect(byokRepository.savedDraft?.apiKey, 'sk-test-valid');
      expect(byokRepository.savedDraft?.selectedModel, 'gpt-4o-mini');
      expect(find.text(AppStrings.byokOnboardingSaved), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('step nine matches review design and card navigation', (
      tester,
    ) async {
      await pumpUntilLoaded(tester);
      await advanceToReview(tester);

      final intro = find.byKey(
        const ValueKey<String>('onboarding_review_intro'),
      );
      final introTitle = find.descendant(
        of: intro,
        matching: find.text(AppStrings.onboardingFinalReviewTitle),
      );
      final introDescription = find.descendant(
        of: intro,
        matching: find.text(AppStrings.onboardingReviewDescription),
      );
      expect(introTitle, findsOneWidget);
      expect(introDescription, findsOneWidget);
      expect(
        tester.widget<Text>(introTitle).style?.fontSize,
        AppFontSizes.displayMd,
      );
      expect(
        tester.widget<Text>(introDescription).style?.fontSize,
        AppFontSizes.lg,
      );

      final experienceCard = find.byKey(
        const ValueKey<String>('onboarding_review_experience_card'),
      );
      final aiCard = find.byKey(
        const ValueKey<String>('onboarding_review_ai_card'),
      );
      final scheduleCard = find.byKey(
        const ValueKey<String>('onboarding_review_schedule_card'),
      );
      final equipmentCard = find.byKey(
        const ValueKey<String>('onboarding_review_equipment_card'),
      );
      final metricCard = find.byKey(
        const ValueKey<String>('onboarding_review_metric_card'),
      );

      expect(
        tester.getTopLeft(experienceCard).dy - tester.getBottomLeft(intro).dy,
        AppSpacing.xxl,
      );
      final cards = [
        experienceCard,
        aiCard,
        scheduleCard,
        equipmentCard,
        metricCard,
      ];
      for (var index = 1; index < cards.length; index++) {
        expect(
          tester.getTopLeft(cards[index]).dy -
              tester.getBottomLeft(cards[index - 1]).dy,
          AppSpacing.lg,
        );
      }

      final experienceContainer = tester.widget<Container>(experienceCard);
      expect(
        experienceContainer.padding,
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
      );
      final experienceDecoration =
          experienceContainer.decoration as BoxDecoration;
      expect(
        experienceDecoration.borderRadius,
        BorderRadius.circular(AppRadius.md),
      );
      expect(experienceDecoration.boxShadow, isNotEmpty);
      expect(
        find.descendant(
          of: experienceCard,
          matching: find.text(AppStrings.modify),
        ),
        findsOneWidget,
      );

      const factTileKeys = [
        'onboarding_review_tier_tile',
        'onboarding_review_focus_tile',
        'onboarding_review_duration_tile',
      ];
      for (final key in factTileKeys) {
        final tile = find.byKey(ValueKey<String>(key));
        expect(
          find.descendant(
            of: tile,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Padding &&
                  widget.padding ==
                      const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.buttonVertical,
                      ),
            ),
          ),
          findsOneWidget,
        );
      }

      expect(
        find.descendant(of: aiCard, matching: find.text(AppStrings.modify)),
        findsNothing,
      );
      expect(
        find.descendant(of: metricCard, matching: find.text(AppStrings.modify)),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: aiCard,
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.button == true,
          ),
        ),
        findsWidgets,
      );
      expect(
        find.ancestor(
          of: metricCard,
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.button == true,
          ),
        ),
        findsWidgets,
      );

      expect(
        find.descendant(
          of: scheduleCard,
          matching: find.text(AppStrings.onboardingReviewScheduleLabel),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: scheduleCard, matching: find.text(AppStrings.edit)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: equipmentCard,
          matching: find.text(AppStrings.onboardingReviewEquipmentLabel),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: equipmentCard,
          matching: find.text(AppStrings.update),
        ),
        findsOneWidget,
      );

      final colorScheme = Theme.of(tester.element(metricCard)).colorScheme;
      final metricDecoration =
          tester.widget<Container>(metricCard).decoration as BoxDecoration;
      expect(metricDecoration.color, colorScheme.surfaceContainerHigh);
      expect(
        metricDecoration.borderRadius,
        BorderRadius.circular(AppRadius.md),
      );
      expect(
        metricDecoration.border?.top.color,
        colorScheme.surfaceContainerHighest,
      );
      expect(metricDecoration.border?.top.width, AppSizing.divider);

      final metricIcon = find.descendant(
        of: metricCard,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints?.minWidth == AppSizing.reviewMetricIcon &&
              widget.constraints?.maxWidth == AppSizing.reviewMetricIcon &&
              widget.constraints?.minHeight == AppSizing.reviewMetricIcon &&
              widget.constraints?.maxHeight == AppSizing.reviewMetricIcon,
        ),
      );
      expect(metricIcon, findsOneWidget);
      expect(
        tester.getSize(metricIcon),
        const Size.square(AppSizing.reviewMetricIcon),
      );
      expect(
        find.widgetWithText(
          FilledButton,
          AppStrings.onboardingInitializeWorkspace,
        ),
        findsOneWidget,
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(OnboardingScreen)),
      );
      await tester.ensureVisible(aiCard);
      await tester.tap(aiCard);
      await tester.pumpAndSettle();
      expect(
        container
            .read(AppProviders.onboardingControllerProvider)
            .requireValue
            .currentStep,
        OnboardingStep.byokOptional,
      );

      container
          .read(AppProviders.onboardingControllerProvider.notifier)
          .jumpToStep(OnboardingStep.review);
      await tester.pumpAndSettle();
      final refreshedMetricCard = find.byKey(
        const ValueKey<String>('onboarding_review_metric_card'),
      );
      await tester.ensureVisible(refreshedMetricCard);
      await tester.tap(refreshedMetricCard);
      await tester.pumpAndSettle();
      expect(
        container
            .read(AppProviders.onboardingControllerProvider)
            .requireValue
            .currentStep,
        OnboardingStep.unitsMetrics,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('welcome step has no back button', (tester) async {
      await pumpUntilLoaded(tester);

      expect(find.text(AppStrings.backLabel), findsNothing);
    });

    testWidgets('resume opens at core identity when experience is missing', (
      tester,
    ) async {
      final repo = _FakeOnboardingRepository();
      useFixedMobileSurface(tester);
      await repo.saveOnboardingDraft(
        const OnboardingDraft(goals: {GoalTag.buildMuscle}),
      );

      await tester.pumpWidget(createTestApp(repo));
      await tester.pump();
      await tester.pump();

      expect(find.text(AppStrings.onboardingCoreIdentityTitle), findsWidgets);
    });

    testWidgets('resume opens at schedule when draft has experienceLevel', (
      tester,
    ) async {
      final repo = _FakeOnboardingRepository();
      useFixedMobileSurface(tester);
      await repo.saveOnboardingDraft(
        const OnboardingDraft(experienceLevel: ExperienceLevel.intermediate),
      );

      await tester.pumpWidget(createTestApp(repo));
      await tester.pump();
      await tester.pump();

      expect(find.text(AppStrings.onboardingSessionDuration), findsOneWidget);
    });

    testWidgets('minimal onboarding completes successfully', (tester) async {
      final repo = _FakeOnboardingRepository();
      useFixedMobileSurface(tester);

      await tester.pumpWidget(createTestApp(repo));
      await tester.pump();
      await tester.pump();

      await advanceToSchedule(tester);
      await selectTrainingDays(tester, const [
        TrainingDay.monday,
        TrainingDay.tuesday,
        TrainingDay.wednesday,
        TrainingDay.thursday,
      ]);
      await tapPrimaryButton(tester);
      await tapPrimaryButton(tester);
      await tapPrimaryButton(tester, label: AppStrings.onboardingNextStep);
      await tapPrimaryButton(tester);
      await tapPrimaryButton(tester);

      expect(find.text(AppStrings.onboardingFinalReviewTitle), findsWidgets);

      await tapPrimaryButton(
        tester,
        label: AppStrings.onboardingInitializeWorkspace,
      );
      await tester.pump();

      expect(await repo.isOnboardingCompleted(), isTrue);
    });

    testWidgets('full onboarding with all fields completes', (tester) async {
      final repo = _FakeOnboardingRepository();
      useFixedMobileSurface(tester);

      await tester.pumpWidget(createTestApp(repo));
      await tester.pump();
      await tester.pump();

      // Welcome and Core Identity -> Experience & goals
      await advanceToExperience(tester);
      await tapVisibleText(tester, AppStrings.onboardingExperienceAdept);
      await tester.ensureVisible(
        find.text(AppStrings.onboardingGoalBuildMuscle),
      );
      await tester.pump();
      await tester.tap(find.text(AppStrings.onboardingGoalBuildMuscle));
      await tester.pump();
      await tapPrimaryButton(tester);

      // Schedule
      await selectTrainingDays(tester, const [
        TrainingDay.monday,
        TrainingDay.tuesday,
        TrainingDay.wednesday,
        TrainingDay.thursday,
      ]);
      await tapPrimaryButton(tester);

      // Equipment (select dumbbells)
      await tapVisibleText(tester, AppStrings.onboardingEquipmentDumbbells);
      await tapPrimaryButton(tester);

      // Limitations (select none)
      await tapVisibleText(tester, AppStrings.onboardingLimitationNone);
      await tapPrimaryButton(tester, label: AppStrings.onboardingNextStep);

      // Metrics (accept optional defaults)
      await tapPrimaryButton(tester);

      // BYOK optional -> continue (skip)
      await tapPrimaryButton(tester);

      // Review -> finish
      expect(find.text(AppStrings.onboardingFinalReviewTitle), findsWidgets);
      await tapPrimaryButton(
        tester,
        label: AppStrings.onboardingInitializeWorkspace,
      );
      await tester.pump();

      expect(await repo.isOnboardingCompleted(), isTrue);
    });
  });
}
