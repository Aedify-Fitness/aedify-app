import 'package:aedify/core/validation/draft_validation_code.dart';
import 'package:aedify/core/validation/draft_validation_issue.dart';
import 'package:aedify/core/validation/draft_validation_path.dart';
import 'package:aedify/core/validation/draft_validation_result.dart';
import 'package:aedify/core/validation/draft_validation_scope.dart';
import 'package:aedify/features/programmes/application/programme_builder_validation_adapter.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final adapter = const ProgrammeBuilderValidationAdapter();

  ProgrammeBuilderDraft draftBuilder({
    String name = 'Test',
    List<ProgrammeBuilderWeekDraft> weeks = const [],
    List<String> templates = const [],
  }) {
    return ProgrammeBuilderDraft(
      id: 'p1',
      name: name,
      source: WorkoutSource.manual,
      creationMethod: CreationMethod.manual,
      status: ProgramStatus.draft,
      weeks: weeks,
      templates: templates,
    );
  }

  ProgrammeExerciseDraft exercise({
    String id = 'e1',
    int exerciseId = 1,
    String? exerciseRef,
    List<SetPrescriptionDraft> sets = const [],
    String? supersetGroupId,
    int? supersetOrder,
  }) {
    return ProgrammeExerciseDraft(
      id: id,
      exerciseId: exerciseId,
      sortOrder: 0,
      sets: sets,
      exerciseRef: exerciseRef,
      supersetGroupId: supersetGroupId,
      supersetOrder: supersetOrder,
    );
  }

  SetPrescriptionDraft setPrescription({
    String id = 's1',
    SetType setType = SetType.working,
    int? repsMin,
    double? weightKg,
  }) {
    return SetPrescriptionDraft(
      id: id,
      setIndex: 0,
      setType: setType,
      prescribedRepsMin: repsMin,
      prescribedWeightKg: weightKg,
    );
  }

  group('ProgrammeBuilderValidationAdapter — toValidatedDraft', () {
    test('maps name and empty weeks/templates', () {
      final draft = draftBuilder(name: 'My Programme');
      final validated = adapter.toValidatedDraft(draft);

      expect(validated.name, 'My Programme');
      expect(validated.weeks, isEmpty);
      expect(validated.templates, isEmpty);
    });

    test('maps weeks with slots and templates', () {
      final template = ProgrammeBuilderTemplateDraft(
        id: 't1',
        templateKey: 't1',
        name: 'Push Day',
        exercises: [
          exercise(
            id: 'e1',
            exerciseId: 1,
            exerciseRef: 'Bench Press',
            sets: [setPrescription(repsMin: 8, weightKg: 60.0)],
          ),
        ],
      );

      final draft = draftBuilder(
        name: 'Plan',
        weeks: [
          ProgrammeBuilderWeekDraft(
            id: 'w1',
            weekNumber: 1,
            slots: [
              ProgrammeBuilderWorkoutSlotDraft(
                slotIndex: 0,
                scheduledDayIndex: 0,
                template: template,
              ),
            ],
          ),
        ],
        templates: ['t1'],
      );

      final validated = adapter.toValidatedDraft(draft);

      expect(validated.name, 'Plan');
      expect(validated.weeks.length, 1);
      expect(validated.weeks[0].weekNumber, 1);
      expect(validated.weeks[0].slots.length, 1);
      expect(validated.weeks[0].slots[0].templateKey, 't1');
      expect(validated.weeks[0].slots[0].dayIndex, 0);
      expect(validated.templates.length, 1);
      expect(validated.templates[0].templateKey, 't1');
      expect(validated.templates[0].exercises.length, 1);
      expect(validated.templates[0].exercises[0].id, 'e1');
      expect(validated.templates[0].exercises[0].modality, 'strength');
    });

    test('preserves superset fields in template exercises', () {
      final template = ProgrammeBuilderTemplateDraft(
        id: 't1',
        templateKey: 't1',
        name: 'Push Day',
        exercises: [
          exercise(
            id: 'e1',
            supersetGroupId: 'g1',
            supersetOrder: 0,
            sets: [setPrescription()],
          ),
          exercise(
            id: 'e2',
            supersetGroupId: 'g1',
            supersetOrder: 1,
            sets: [setPrescription()],
          ),
        ],
      );

      final draft = draftBuilder(
        weeks: [
          ProgrammeBuilderWeekDraft(
            id: 'w1',
            weekNumber: 1,
            slots: [
              ProgrammeBuilderWorkoutSlotDraft(
                slotIndex: 0,
                scheduledDayIndex: 0,
                template: template,
              ),
            ],
          ),
        ],
        templates: ['t1'],
      );

      final validated = adapter.toValidatedDraft(draft);

      final vEx1 = validated.templates[0].exercises[0];
      final vEx2 = validated.templates[0].exercises[1];
      expect(vEx1.supersetGroupId, 'g1');
      expect(vEx1.supersetOrder, 0);
      expect(vEx2.supersetGroupId, 'g1');
      expect(vEx2.supersetOrder, 1);
    });

    test('handles missing weeks gracefully', () {
      final draft = draftBuilder(weeks: [], templates: []);
      final validated = adapter.toValidatedDraft(draft);

      expect(validated.weeks, isEmpty);
      expect(validated.templates, isEmpty);
    });
  });

  group('ProgrammeBuilderValidationAdapter — toFeatureErrors', () {
    test('maps shared issue to feature error with path', () {
      final result = DraftValidationResult(
        issues: [
          DraftValidationIssue(
            scope: DraftValidationScope.week,
            code: DraftValidationCode.nonSequentialWeek,
            message: 'Week numbers must be sequential.',
            path: DraftValidationPath(weekIndex: 1),
          ),
          DraftValidationIssue(
            scope: DraftValidationScope.workoutSlot,
            code: DraftValidationCode.missingTemplate,
            message: 'Select a template.',
            path: DraftValidationPath(weekIndex: 0, slotIndex: 2),
          ),
          DraftValidationIssue(
            scope: DraftValidationScope.root,
            code: DraftValidationCode.missingName,
            message: 'Programme name is required.',
          ),
        ],
      );

      final errors = adapter.toFeatureErrors(result);

      expect(errors.length, 3);
      expect(errors[0].scope, ProgrammeBuilderValidationScope.week);
      expect(errors[0].code, DraftValidationCode.nonSequentialWeek);
      expect(errors[0].weekIndex, 1);
      expect(errors[1].scope, ProgrammeBuilderValidationScope.workoutSlot);
      expect(errors[1].code, DraftValidationCode.missingTemplate);
      expect(errors[1].weekIndex, 0);
      expect(errors[1].slotIndex, 2);
      expect(errors[2].scope, ProgrammeBuilderValidationScope.programme);
      expect(errors[2].code, DraftValidationCode.missingName);
    });
  });
}
