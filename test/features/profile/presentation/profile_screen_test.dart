import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/profile/data/profile_repository.dart';
import 'package:aedify/features/profile/domain/profile_edit_draft.dart';
import 'package:aedify/features/profile/domain/profile_save_impact.dart';
import 'package:aedify/features/profile/domain/profile_view_data.dart';
import 'package:aedify/features/profile/presentation/profile_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

Widget createTestApp(ProfileRepository repository) {
  return ProviderScope(
    overrides: [
      AppProviders.profileRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(home: ProfileScreen()),
  );
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

    expect(find.text(AppStrings.saveProfile), findsOneWidget);
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

  testWidgets('renders sex chips when profile loaded', (tester) async {
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
    expect(find.text(AppStrings.sexNotSpecified), findsOneWidget);
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

    expect(find.text(AppStrings.maxLifts), findsOneWidget);
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

    expect(find.text(AppStrings.favorites), findsOneWidget);
    expect(find.text(AppStrings.substitutions), findsOneWidget);
  });

  testWidgets('save action triggers controller save', (tester) async {
    final repo = _FakeProfileRepository();
    await repo.saveProfile(
      const ProfileEditDraft(experienceLevel: ExperienceLevel.beginner),
    );

    await tester.pumpWidget(createTestApp(repo));
    await tester.pump();
    await tester.pump();

    await tester.ensureVisible(find.text(AppStrings.saveProfile));
    await tester.pump();
    await tester.tap(find.text(AppStrings.saveProfile));
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

    // Bodyweight formatted value (70.0 kg)
    expect(find.text('70.0'), findsOneWidget);
    // Height formatted value (175.0 cm)
    expect(find.text('175.0'), findsOneWidget);
  });
}
