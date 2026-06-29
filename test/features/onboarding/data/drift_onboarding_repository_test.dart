import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/features/onboarding/application/onboarding_state.dart';
import 'package:aedify/features/onboarding/data/drift_onboarding_repository.dart';
import 'package:aedify/shared/domain/equipment_tag.dart';
import 'package:aedify/shared/domain/experience_level.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import '../../../support/privacy/privacy_sentinel_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftOnboardingRepository', () {
    late AppDatabase db;
    late DriftOnboardingRepository repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = DriftOnboardingRepository(database: db);
    });

    tearDown(() {
      db.close();
    });

    OnboardingDraft makeDraft({
      ExperienceLevel? experienceLevel = ExperienceLevel.intermediate,
      Set<GoalTag> goals = const {GoalTag.buildMuscle},
      int? trainingDaysPerWeek = 4,
      Set<EquipmentTag> equipment = const {EquipmentTag.dumbbell},
      PreferredUnit? preferredUnits = PreferredUnit.metric,
      double? heightCm = 175,
      double? bodyweightKg = 70,
      List<String> limitations = const [],
      String? notes,
    }) {
      return OnboardingDraft(
        experienceLevel: experienceLevel,
        goals: goals,
        trainingDaysPerWeek: trainingDaysPerWeek,
        equipmentAccess: equipment,
        preferredUnits: preferredUnits,
        heightCm: heightCm,
        bodyweightKg: bodyweightKg,
        limitations: limitations,
        notes: notes,
      );
    }

    test('isOnboardingCompleted returns false by default', () async {
      final completed = await repository.isOnboardingCompleted();
      expect(completed, isFalse);
    });

    test('saveOnboardingDraft persists draft values', () async {
      final draft = makeDraft();

      await repository.saveOnboardingDraft(draft);

      final loaded = await repository.loadOnboardingDraft();
      expect(loaded, isNotNull);
      expect(loaded!.experienceLevel, ExperienceLevel.intermediate);
      expect(loaded.goals, {GoalTag.buildMuscle});
      expect(loaded.trainingDaysPerWeek, 4);
      expect(loaded.equipmentAccess, {EquipmentTag.dumbbell});
      expect(loaded.preferredUnits, PreferredUnit.metric);
      expect(loaded.heightCm, 175);
      expect(loaded.bodyweightKg, 70);
    });

    test('loadOnboardingDraft returns null when no profile exists', () async {
      final loaded = await repository.loadOnboardingDraft();
      expect(loaded, isNull);
    });

    test('loadOnboardingDraft returns saved values', () async {
      final draft = makeDraft(
        experienceLevel: ExperienceLevel.beginner,
        goals: {GoalTag.loseWeight, GoalTag.generalFitness},
        trainingDaysPerWeek: 3,
        equipment: {EquipmentTag.bands},
        preferredUnits: PreferredUnit.imperial,
        heightCm: null,
        bodyweightKg: null,
      );

      await repository.saveOnboardingDraft(draft);
      final loaded = await repository.loadOnboardingDraft();

      expect(loaded, isNotNull);
      expect(loaded!.experienceLevel, ExperienceLevel.beginner);
      expect(loaded.goals, {GoalTag.loseWeight, GoalTag.generalFitness});
      expect(loaded.trainingDaysPerWeek, 3);
      expect(loaded.equipmentAccess, {EquipmentTag.bands});
      expect(loaded.preferredUnits, PreferredUnit.imperial);
      expect(loaded.heightCm, isNull);
      expect(loaded.bodyweightKg, isNull);
    });

    test('completeOnboarding persists completion flag and data', () async {
      final draft = makeDraft();

      await repository.completeOnboarding(draft);

      final completed = await repository.isOnboardingCompleted();
      expect(completed, isTrue);

      final loaded = await repository.loadOnboardingDraft();
      expect(loaded, isNotNull);
      expect(loaded!.experienceLevel, ExperienceLevel.intermediate);

      final profile = await db.select(db.userProfile).get();
      expect(profile.length, 1);
      expect(profile.first.onboardingCompleted, isTrue);
      expect(profile.first.onboardingCompletedAt, isNotNull);
    });

    test('clearOnboardingDraft removes temporary progress', () async {
      final draft = makeDraft(notes: 'Temporary notes');
      await repository.saveOnboardingDraft(draft);

      await repository.clearOnboardingDraft();

      final loaded = await repository.loadOnboardingDraft();
      expect(loaded, isNotNull);
      expect(loaded!.experienceLevel, isNull);
      expect(loaded.goals, isEmpty);
      expect(loaded.trainingDaysPerWeek, isNull);
      expect(loaded.notes, isNull);
    });

    test('clearOnboardingDraft preserves onboarding completed flag', () async {
      final draft = makeDraft();
      await repository.completeOnboarding(draft);

      await repository.clearOnboardingDraft();

      final completed = await repository.isOnboardingCompleted();
      expect(completed, isTrue);
    });

    test('JSON list decode handles empty and valid data', () async {
      await repository.saveOnboardingDraft(
        makeDraft(goals: const <GoalTag>{}, limitations: []),
      );
      final loaded = await repository.loadOnboardingDraft();
      expect(loaded!.goals, isEmpty);
      expect(loaded.limitations, isEmpty);
    });

    test(
      'onboarding draft stores private values only in Drift-backed profile state',
      () async {
        final draft = makeDraft(
          notes: PrivacySentinelValues.fakeProfileNote,
          limitations: [PrivacySentinelValues.fakeInjuryNote],
          bodyweightKg: 98.7,
        );

        await repository.saveOnboardingDraft(draft);

        final saved = await db.select(db.userProfile).get();
        expect(saved.length, 1);
        expect(
          saved.first.otherNotes,
          contains(PrivacySentinelValues.fakeProfileNote),
        );
        expect(
          saved.first.injuriesLimitationsJson,
          contains(PrivacySentinelValues.fakeInjuryNote),
        );
        expect(saved.first.bodyweightKg, 98.7);
      },
    );

    test(
      'clearing onboarding draft removes transient private notes as expected',
      () async {
        final draft = makeDraft(
          notes: PrivacySentinelValues.fakeProfileNote,
          limitations: [PrivacySentinelValues.fakeInjuryNote],
        );
        await repository.saveOnboardingDraft(draft);

        await repository.clearOnboardingDraft();

        final loaded = await repository.loadOnboardingDraft();
        expect(loaded!.notes, isNull);
      },
    );

    test(
      'onboarding completion does not write sensitive values to preferences',
      () async {
        final draft = makeDraft(
          notes: PrivacySentinelValues.fakeProfileNote,
          bodyweightKg: 98.7,
        );
        await repository.completeOnboarding(draft);

        final profile = await db.select(db.userProfile).get();
        expect(profile.length, 1);
        expect(profile.first.bodyweightKg, 98.7);
        expect(profile.first.onboardingCompleted, isTrue);
      },
    );

    test('JSON list decode handles malformed data gracefully', () async {
      final now = DateTime.now();
      await db
          .into(db.userProfile)
          .insert(
            UserProfileCompanion(
              id: const Value('default'),
              experienceLevel: const Value('intermediate'),
              goalsJson: const Value('not valid json'),
              equipmentAccessJson: const Value('["dumbbell"]'),
              injuriesLimitationsJson: const Value('[]'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      final loaded = await repository.loadOnboardingDraft();
      expect(loaded, isNotNull);
      expect(loaded!.goals, isEmpty);
      expect(loaded.equipmentAccess, {EquipmentTag.dumbbell});
    });
  });
}
