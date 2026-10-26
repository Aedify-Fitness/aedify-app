import 'package:aedify/core/validation/default_draft_validation_service.dart';
import 'package:aedify/core/validation/draft_validation_code.dart';
import 'package:aedify/core/validation/validated_exercise_draft.dart';
import 'package:aedify/core/validation/validated_programme_draft.dart';
import 'package:aedify/core/validation/validated_programme_slot_draft.dart';
import 'package:aedify/core/validation/validated_programme_template_draft.dart';
import 'package:aedify/core/validation/validated_programme_week_draft.dart';
import 'package:aedify/core/validation/validated_set_draft.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = const DefaultDraftValidationService();

  ValidatedSetDraft setHelper() {
    return ValidatedSetDraft(
      id: 's1',
      setType: SetType.working,
      prescribedRepsMin: 8,
      prescribedWeightKg: 60.0,
      restSeconds: 90,
    );
  }

  ValidatedExerciseDraft exHelper({
    String id = 'e1',
    List<ValidatedSetDraft> sets = const [],
    String? supersetGroupId,
  }) {
    return ValidatedExerciseDraft(
      id: id,
      modality: 'strength',
      sets: sets,
      supersetGroupId: supersetGroupId,
    );
  }

  ValidatedProgrammeTemplateDraft templateHelper({
    String key = 't1',
    List<ValidatedExerciseDraft> exercises = const [],
  }) {
    return ValidatedProgrammeTemplateDraft(
      templateKey: key,
      exercises: exercises,
    );
  }

  ValidatedProgrammeSlotDraft slotHelper({
    String? templateKey,
    int dayIndex = 0,
  }) {
    return ValidatedProgrammeSlotDraft(
      templateKey: templateKey,
      dayIndex: dayIndex,
    );
  }

  ValidatedProgrammeWeekDraft weekHelper({
    int weekNumber = 1,
    List<ValidatedProgrammeSlotDraft> slots = const [],
  }) {
    return ValidatedProgrammeWeekDraft(weekNumber: weekNumber, slots: slots);
  }

  group('DefaultDraftValidationService — programme', () {
    test('valid programme passes', () {
      final draft = ValidatedProgrammeDraft(
        name: 'My Programme',
        templates: [
          templateHelper(
            exercises: [
              exHelper(sets: [setHelper()]),
            ],
          ),
        ],
        weeks: [
          weekHelper(slots: [slotHelper(templateKey: 't1')]),
        ],
      );
      final result = service.validateProgrammeDraft(draft);
      expect(result.isValid, isTrue);
    });

    test('empty name invalid', () {
      final draft = ValidatedProgrammeDraft(name: '', templates: [], weeks: []);
      final result = service.validateProgrammeDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.missingName),
        isTrue,
      );
    });

    test('whitespace-only name invalid', () {
      final draft = ValidatedProgrammeDraft(
        name: '   ',
        templates: [],
        weeks: [],
      );
      final result = service.validateProgrammeDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.missingName),
        isTrue,
      );
    });

    test('no weeks invalid', () {
      final draft = ValidatedProgrammeDraft(
        name: 'My Programme',
        templates: [templateHelper()],
        weeks: [],
      );
      final result = service.validateProgrammeDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.noWeeks),
        isTrue,
      );
    });

    test('no templates invalid', () {
      final draft = ValidatedProgrammeDraft(
        name: 'My Programme',
        templates: [],
        weeks: [
          weekHelper(slots: [slotHelper(templateKey: 't1')]),
        ],
      );
      final result = service.validateProgrammeDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.noTemplates),
        isTrue,
      );
    });

    test('non-sequential week numbers invalid', () {
      final draft = ValidatedProgrammeDraft(
        name: 'My Programme',
        templates: [
          templateHelper(
            exercises: [
              exHelper(sets: [setHelper()]),
            ],
          ),
        ],
        weeks: [
          weekHelper(weekNumber: 1, slots: [slotHelper(templateKey: 't1')]),
          weekHelper(weekNumber: 3, slots: [slotHelper(templateKey: 't1')]),
        ],
      );
      final result = service.validateProgrammeDraft(draft);
      expect(
        result.issues.any(
          (i) => i.code == DraftValidationCode.nonSequentialWeek,
        ),
        isTrue,
      );
    });

    test('sequential week numbers pass', () {
      final draft = ValidatedProgrammeDraft(
        name: 'My Programme',
        templates: [
          templateHelper(
            exercises: [
              exHelper(sets: [setHelper()]),
            ],
          ),
        ],
        weeks: [
          weekHelper(weekNumber: 1, slots: [slotHelper(templateKey: 't1')]),
          weekHelper(weekNumber: 2, slots: [slotHelper(templateKey: 't1')]),
        ],
      );
      final result = service.validateProgrammeDraft(draft);
      expect(
        result.issues.any(
          (i) => i.code == DraftValidationCode.nonSequentialWeek,
        ),
        isFalse,
      );
    });

    test('missing template reference in slot invalid', () {
      final draft = ValidatedProgrammeDraft(
        name: 'My Programme',
        templates: [templateHelper(key: 't1')],
        weeks: [
          weekHelper(slots: [slotHelper(templateKey: null)]),
        ],
      );
      final result = service.validateProgrammeDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.missingTemplate),
        isTrue,
      );
    });

    test('nonexistent template reference in slot invalid', () {
      final draft = ValidatedProgrammeDraft(
        name: 'My Programme',
        templates: [templateHelper(key: 't1')],
        weeks: [
          weekHelper(slots: [slotHelper(templateKey: 't99')]),
        ],
      );
      final result = service.validateProgrammeDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.missingTemplate),
        isTrue,
      );
    });

    test('template exercises with errors propagate', () {
      final draft = ValidatedProgrammeDraft(
        name: 'My Programme',
        templates: [
          templateHelper(
            key: 't1',
            exercises: [exHelper(id: 'e1', sets: [])],
          ),
        ],
        weeks: [
          weekHelper(slots: [slotHelper(templateKey: 't1')]),
        ],
      );
      final result = service.validateProgrammeDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.noSets),
        isTrue,
      );
    });

    test('superset validation runs for template exercises', () {
      final draft = ValidatedProgrammeDraft(
        name: 'Superset Programme',
        templates: [
          templateHelper(
            key: 't1',
            exercises: [
              exHelper(id: 'e1', supersetGroupId: 'g1', sets: [setHelper()]),
              exHelper(id: 'e2', sets: [setHelper()]),
            ],
          ),
        ],
        weeks: [
          weekHelper(slots: [slotHelper(templateKey: 't1')]),
        ],
      );
      final result = service.validateProgrammeDraft(draft);
      expect(
        result.issues.any((i) => i.code == DraftValidationCode.invalidSuperset),
        isTrue,
      );
    });

    test('fully valid programme with multiple weeks/slots passes', () {
      final draft = ValidatedProgrammeDraft(
        name: '12 Week Plan',
        templates: [
          templateHelper(
            key: 't1',
            exercises: [
              exHelper(sets: [setHelper()]),
            ],
          ),
          templateHelper(
            key: 't2',
            exercises: [
              exHelper(sets: [setHelper()]),
            ],
          ),
        ],
        weeks: [
          weekHelper(
            weekNumber: 1,
            slots: [
              slotHelper(templateKey: 't1', dayIndex: 0),
              slotHelper(templateKey: 't2', dayIndex: 1),
            ],
          ),
          weekHelper(
            weekNumber: 2,
            slots: [
              slotHelper(templateKey: 't1', dayIndex: 0),
              slotHelper(templateKey: 't2', dayIndex: 1),
            ],
          ),
        ],
      );
      final result = service.validateProgrammeDraft(draft);
      expect(result.isValid, isTrue);
    });
  });
}
