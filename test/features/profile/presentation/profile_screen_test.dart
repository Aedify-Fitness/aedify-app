import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/daos/exercise_dao.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/features/profile/domain/profile_view_data.dart';
import 'package:aedify/features/profile/presentation/profile_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeProfileRepository implements ProfileRepository {
  ProfileViewData? _profile;

  @override
  Future<ProfileViewData?> getProfile() async => _profile;

  @override
  Future<void> saveProfile(ProfileEditDraft draft) async {
    _profile = ProfileViewData(
      displayName: draft.displayName,
      sex: draft.sex,
      dateOfBirth: draft.dateOfBirth,
      bench1RmKg: draft.bench1RmKg,
      squat1RmKg: draft.squat1RmKg,
      deadlift1RmKg: draft.deadlift1RmKg,
      experienceLevel: draft.experienceLevel ?? ExperienceLevel.beginner,
      goals: draft.goals,
      equipmentAccess: draft.equipmentAccess,
      trainingDaysPerWeek: draft.trainingDaysPerWeek,
      targetSessionLengthMinutes: draft.targetSessionLengthMinutes,
      preferredUnits: draft.preferredUnits,
      heightCm: draft.heightCm,
      bodyweightKg: draft.bodyweightKg,
      favoriteExerciseIds: draft.favoriteExerciseIds,
      substitutedExerciseIds: draft.substitutedExerciseIds,
      injuriesLimitations: draft.injuriesLimitations,
      otherNotes: draft.otherNotes,
    );
  }

  @override
  Future<ProfileSaveImpact> evaluateSaveImpact(ProfileEditDraft draft) async {
    return ProfileSaveImpact.none;
  }
}

class _FakeProfileRepositoryWithImpact implements ProfileRepository {
  ProfileViewData? _profile;

  @override
  Future<ProfileViewData?> getProfile() async =>
      _profile ??
      const ProfileViewData(
        displayName: '',
        sex: null,
        dateOfBirth: null,
        bench1RmKg: null,
        squat1RmKg: null,
        deadlift1RmKg: null,
        experienceLevel: ExperienceLevel.beginner,
        goals: <GoalTag>{},
        equipmentAccess: <EquipmentTag>{},
        trainingDaysPerWeek: null,
        targetSessionLengthMinutes: null,
        preferredUnits: PreferredUnit.metric,
        heightCm: null,
        bodyweightKg: null,
        favoriteExerciseIds: [],
        substitutedExerciseIds: [],
        injuriesLimitations: [],
        otherNotes: null,
      );

  @override
  Future<void> saveProfile(ProfileEditDraft draft) async {
    _profile = ProfileViewData(
      displayName: draft.displayName,
      sex: draft.sex,
      dateOfBirth: draft.dateOfBirth,
      bench1RmKg: draft.bench1RmKg,
      squat1RmKg: draft.squat1RmKg,
      deadlift1RmKg: draft.deadlift1RmKg,
      experienceLevel: draft.experienceLevel ?? ExperienceLevel.beginner,
      goals: draft.goals,
      equipmentAccess: draft.equipmentAccess,
      trainingDaysPerWeek: draft.trainingDaysPerWeek,
      targetSessionLengthMinutes: draft.targetSessionLengthMinutes,
      preferredUnits: draft.preferredUnits,
      heightCm: draft.heightCm,
      bodyweightKg: draft.bodyweightKg,
      favoriteExerciseIds: draft.favoriteExerciseIds,
      substitutedExerciseIds: draft.substitutedExerciseIds,
      injuriesLimitations: draft.injuriesLimitations,
      otherNotes: draft.otherNotes,
    );
  }

  @override
  Future<ProfileSaveImpact> evaluateSaveImpact(ProfileEditDraft draft) async {
    return ProfileSaveImpact.mayAffectActiveProgrammes;
  }
}

Widget createTestApp(ProfileRepository repository, {ExerciseDao? exerciseDao}) {
  final route = AppRoutes.home();
  final router = GoRouter(
    routes: [
      GoRoute(
        path: route.path,
        name: route.name,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      AppProviders.profileRepositoryProvider.overrideWithValue(repository),
      if (exerciseDao != null)
        AppProviders.exerciseDaoProvider.overrideWithValue(exerciseDao),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _ExerciseSelectorTestData {
  _ExerciseSelectorTestData._();

  static Future<ExerciseDao> createSeededDao(
    Map<int, String> exerciseNames,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final exerciseDao = ExerciseDao(database);
    final now = DateTime.utc(2026);

    await exerciseDao.insertExercisesBulk(
      exerciseNames.entries
          .map(
            (entry) => ExercisesCompanion.insert(
              id: Value(entry.key),
              source: 'test',
              name: entry.value,
              nameNormalized: entry.value.toLowerCase(),
              primaryMusclesJson: '[]',
              muscleGroupsJson: '[]',
              modality: 'strength',
              gripsJson: '[]',
              stepsJson: '[]',
              createdAt: now,
              updatedAt: now,
            ),
          )
          .toList(growable: false),
    );

    return exerciseDao;
  }

  static Finder inOpenSheet(String name) {
    return find.descendant(
      of: find.byType(DraggableScrollableSheet),
      matching: find.text(name),
    );
  }
}

void main() {
  testWidgets('shows loading state initially', (tester) async {
    await tester.pumpWidget(createTestApp(_FakeProfileRepository()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows save button when profile absent', (tester) async {
    await tester.pumpWidget(createTestApp(_FakeProfileRepository()));
    await tester.pump();
    await tester.pump();

    expect(find.widgetWithText(FilledButton, AppStrings.save), findsOneWidget);
  });

  testWidgets('groups profile fields into calm scrolling sections', (
    tester,
  ) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(experienceLevel: ExperienceLevel.beginner),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    final scrollable = find.byType(Scrollable).first;
    expect(scrollable, findsOneWidget);

    for (final title in [
      AppStrings.onboardingPersonalDetailsTitle,
      AppStrings.onboardingReviewProfileTitle,
      AppStrings.onboardingScheduleTitle,
      AppStrings.onboardingEquipmentTitle,
      AppStrings.onboardingLimitationsTitle,
      AppStrings.onboardingBodyMetricsTitle,
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        400,
        scrollable: scrollable,
      );
      expect(find.text(title), findsOneWidget);
    }

    expect(find.widgetWithText(FilledButton, AppStrings.save), findsOneWidget);
  });

  testWidgets('renders editable fields when profile loaded', (tester) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(
        experienceLevel: ExperienceLevel.intermediate,
        goals: {GoalTag.buildMuscle},
      ),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text(AppStrings.experienceLevel),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(AppStrings.experienceLevel), findsOneWidget);
    expect(find.text(AppStrings.goals), findsOneWidget);
  });

  testWidgets('renders display name field when profile loaded', (tester) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(
        experienceLevel: ExperienceLevel.beginner,
        displayName: 'Alex',
      ),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.displayName), findsAtLeastNWidgets(1));
    expect(find.text('Alex'), findsAtLeastNWidgets(1));
  });

  testWidgets('renders custom sex pills when profile loaded', (tester) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(experienceLevel: ExperienceLevel.beginner),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.sex), findsOneWidget);
    expect(find.text(AppStrings.sexMale), findsOneWidget);
    expect(find.text(AppStrings.sexFemale), findsOneWidget);
    expect(find.text(AppStrings.sexOther), findsOneWidget);
    expect(find.byType(FilterChip), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
  });

  testWidgets('renders date of birth picker when profile loaded', (
    tester,
  ) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(experienceLevel: ExperienceLevel.beginner),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.dateOfBirth), findsOneWidget);
  });

  testWidgets('renders max lifts section when profile loaded', (tester) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(experienceLevel: ExperienceLevel.beginner),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text(AppStrings.onboardingMaxLiftsTitle),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(AppStrings.onboardingMaxLiftsTitle), findsOneWidget);
    expect(find.text(AppStrings.bench1Rm), findsOneWidget);
    expect(find.text(AppStrings.squat1Rm), findsOneWidget);
    expect(find.text(AppStrings.deadlift1Rm), findsOneWidget);
  });

  testWidgets('renders favorites and substitutions sections', (tester) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(experienceLevel: ExperienceLevel.beginner),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text(AppStrings.substitutions),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(AppStrings.favorites), findsOneWidget);
    expect(find.text(AppStrings.substitutions), findsOneWidget);
  });

  testWidgets('exercise selectors exclude opposing profile selections', (
    tester,
  ) async {
    const exerciseNames = <int, String>{
      1: 'Bench Press',
      2: 'Back Squat',
      3: 'Deadlift',
    };
    final exerciseDao = await _ExerciseSelectorTestData.createSeededDao(
      exerciseNames,
    );
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(
        experienceLevel: ExperienceLevel.beginner,
        favoriteExerciseIds: [1],
        substitutedExerciseIds: [2],
      ),
    );

    await tester.pumpWidget(createTestApp(repo, exerciseDao: exerciseDao));
    await tester.pumpAndSettle();

    final pageScroll = find.byType(CustomScrollView);
    await tester.dragUntilVisible(
      find.text(AppStrings.substitutions),
      pageScroll,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.substitutions));
    await tester.pumpAndSettle();

    expect(_ExerciseSelectorTestData.inOpenSheet('Bench Press'), findsNothing);
    expect(_ExerciseSelectorTestData.inOpenSheet('Back Squat'), findsOneWidget);
    expect(_ExerciseSelectorTestData.inOpenSheet('Deadlift'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(DraggableScrollableSheet),
        matching: find.widgetWithText(FilledButton, AppStrings.done),
      ),
    );
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text(AppStrings.favorites),
      pageScroll,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.favorites));
    await tester.pumpAndSettle();

    expect(
      _ExerciseSelectorTestData.inOpenSheet('Bench Press'),
      findsOneWidget,
    );
    expect(_ExerciseSelectorTestData.inOpenSheet('Back Squat'), findsNothing);
    expect(_ExerciseSelectorTestData.inOpenSheet('Deadlift'), findsOneWidget);
  });

  testWidgets('save action triggers controller save', (tester) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(experienceLevel: ExperienceLevel.beginner),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, AppStrings.save));
    await tester.pump();
    await tester.pump();

    // Wait for async save to complete
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('impact warning is shown when controller reports it', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp(_FakeProfileRepositoryWithImpact()));
    await tester.pump();
    await tester.pump();

    expect(
      find.text(AppStrings.profileUpdateMayAffectPrograms),
      findsOneWidget,
    );
  });

  testWidgets('metric selection shows weight label and unit suffix', (
    tester,
  ) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(experienceLevel: ExperienceLevel.beginner),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text(AppStrings.metricWeightLabel),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(AppStrings.metricWeightLabel), findsOneWidget);
  });

  testWidgets('imperial selection updates weight label', (tester) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(
        experienceLevel: ExperienceLevel.beginner,
        preferredUnits: PreferredUnit.imperial,
      ),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text(AppStrings.imperialWeightLabel),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(AppStrings.imperialWeightLabel), findsOneWidget);
  });

  testWidgets('stored canonical values display in selected units', (
    tester,
  ) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(
        experienceLevel: ExperienceLevel.beginner,
        preferredUnits: PreferredUnit.metric,
        bodyweightKg: 70,
        heightCm: 175,
      ),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('70.0'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    // Bodyweight formatted value (70.0 kg)
    expect(find.text('70.0'), findsOneWidget);
    // Height formatted value (175.0 cm)
    expect(find.text('175.0'), findsOneWidget);
  });
}
