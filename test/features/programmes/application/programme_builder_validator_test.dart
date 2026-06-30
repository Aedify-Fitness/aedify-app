import 'package:flutter_test/flutter_test.dart';
import 'package:aedify/features/programmes/domain/programme_builder_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_week_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_workout_slot_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/features/programmes/domain/programme_builder_validation_error.dart';
import 'package:aedify/features/programmes/application/programme_builder_validator.dart';
import 'package:aedify/shared/domain/workout_source.dart';
import 'package:aedify/shared/domain/creation_method.dart';
import 'package:aedify/shared/domain/program_status.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';

ProgrammeBuilderDraft _baseDraft() {
  return ProgrammeBuilderDraft(
    id: 'test-id',
    name: 'My Programme',
    source: WorkoutSource.manual,
    creationMethod: CreationMethod.manual,
    status: ProgramStatus.draft,
    weeks: [
      ProgrammeBuilderWeekDraft(
        id: 'week-1',
        weekNumber: 1,
        slots: [
          ProgrammeBuilderWorkoutSlotDraft(
            slotIndex: 0,
            scheduledDayIndex: 0,
            template: ProgrammeBuilderTemplateDraft(
              id: 't-1',
              templateKey: 't-1',
              name: 'Push Day',
            ),
          ),
        ],
      ),
    ],
    templates: ['t-1'],
  );
}

void main() {
  const validator = ProgrammeBuilderValidator();

  group('ProgrammeBuilderValidator', () {
    test('returns no errors for a valid draft', () {
      final draft = _baseDraft();
      final errors = validator.validate(draft);
      expect(errors, isEmpty);
    });

    group('name validation', () {
      test('returns missingName error when name is empty', () {
        final draft = _baseDraft().copyWith(name: '');
        final errors = validator.validate(draft);
        expect(errors, hasLength(1));
        expect(errors[0].code, AppErrorCodes.missingName);
        expect(errors[0].scope, ProgrammeBuilderValidationScope.programme);
      });

      test('returns missingName error when name is only whitespace', () {
        final draft = _baseDraft().copyWith(name: '   ');
        final errors = validator.validate(draft);
        expect(errors, hasLength(1));
        expect(errors[0].code, AppErrorCodes.missingName);
      });
    });

    group('weeks validation', () {
      test('returns noWeeks error when weeks is null', () {
        final draft = ProgrammeBuilderDraft(
          id: 'test-id',
          name: 'My Programme',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.draft,
          weeks: null,
          templates: ['t-1'],
        );
        final errors = validator.validate(draft);
        expect(
          errors.any(
            (e) =>
                e.code == AppErrorCodes.noWeeks &&
                e.scope == ProgrammeBuilderValidationScope.programme,
          ),
          isTrue,
        );
      });

      test('returns noWeeks error when weeks is empty', () {
        final draft = _baseDraft().copyWith(weeks: []);
        final errors = validator.validate(draft);
        expect(errors.any((e) => e.code == AppErrorCodes.noWeeks), isTrue);
      });

      test('returns nonSequentialWeek when week numbers are out of order', () {
        final draft = _baseDraft().copyWith(
          weeks: [
            ProgrammeBuilderWeekDraft(
              id: 'week-2',
              weekNumber: 2,
              slots: [
                ProgrammeBuilderWorkoutSlotDraft(
                  slotIndex: 0,
                  scheduledDayIndex: 0,
                  template: ProgrammeBuilderTemplateDraft(
                    id: 't-1',
                    templateKey: 't-1',
                    name: 'Push Day',
                  ),
                ),
              ],
            ),
          ],
        );
        final errors = validator.validate(draft);
        expect(
          errors.any(
            (e) =>
                e.code == AppErrorCodes.nonSequentialWeek && e.weekIndex == 0,
          ),
          isTrue,
        );
      });

      test('returns noSlots when a week has null slots', () {
        final draft = _baseDraft().copyWith(
          weeks: [
            ProgrammeBuilderWeekDraft(id: 'week-1', weekNumber: 1, slots: null),
          ],
        );
        final errors = validator.validate(draft);
        expect(
          errors.any(
            (e) => e.code == AppErrorCodes.noSlots && e.weekIndex == 0,
          ),
          isTrue,
        );
      });

      test('returns noSlots when a week has empty slots', () {
        final draft = _baseDraft().copyWith(
          weeks: [
            ProgrammeBuilderWeekDraft(id: 'week-1', weekNumber: 1, slots: []),
          ],
        );
        final errors = validator.validate(draft);
        expect(
          errors.any(
            (e) => e.code == AppErrorCodes.noSlots && e.weekIndex == 0,
          ),
          isTrue,
        );
      });

      test('returns missingTemplate when a slot has no template', () {
        final draft = _baseDraft().copyWith(
          weeks: [
            ProgrammeBuilderWeekDraft(
              id: 'week-1',
              weekNumber: 1,
              slots: [
                ProgrammeBuilderWorkoutSlotDraft(
                  slotIndex: 0,
                  scheduledDayIndex: 0,
                  template: null,
                ),
              ],
            ),
          ],
        );
        final errors = validator.validate(draft);
        expect(
          errors.any(
            (e) =>
                e.code == AppErrorCodes.missingTemplate &&
                e.weekIndex == 0 &&
                e.slotIndex == 0,
          ),
          isTrue,
        );
      });
    });

    group('templates validation', () {
      test('returns noTemplates error when templates is null', () {
        final draft = ProgrammeBuilderDraft(
          id: 'test-id',
          name: 'My Programme',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.draft,
          weeks: [
            ProgrammeBuilderWeekDraft(
              id: 'week-1',
              weekNumber: 1,
              slots: [
                ProgrammeBuilderWorkoutSlotDraft(
                  slotIndex: 0,
                  scheduledDayIndex: 0,
                  template: ProgrammeBuilderTemplateDraft(
                    id: 't-1',
                    templateKey: 't-1',
                    name: 'Push Day',
                  ),
                ),
              ],
            ),
          ],
          templates: null,
        );
        final errors = validator.validate(draft);
        expect(
          errors.any(
            (e) =>
                e.code == AppErrorCodes.noTemplates &&
                e.scope == ProgrammeBuilderValidationScope.programme,
          ),
          isTrue,
        );
      });

      test('returns noTemplates error when templates is empty', () {
        final draft = _baseDraft().copyWith(templates: []);
        final errors = validator.validate(draft);
        expect(errors.any((e) => e.code == AppErrorCodes.noTemplates), isTrue);
      });
    });

    group('multiple errors', () {
      test('returns all validation errors for a completely empty draft', () {
        final draft = ProgrammeBuilderDraft(
          id: '',
          name: '',
          source: WorkoutSource.manual,
          creationMethod: CreationMethod.manual,
          status: ProgramStatus.draft,
          weeks: null,
          templates: null,
        );
        final errors = validator.validate(draft);
        final codes = errors.map((e) => e.code).toSet();
        expect(codes, contains(AppErrorCodes.missingName));
        expect(codes, contains(AppErrorCodes.noWeeks));
        expect(codes, contains(AppErrorCodes.noTemplates));
        expect(errors.length, greaterThanOrEqualTo(3));
      });

      test('returns errors for multiple weeks with issues', () {
        final draft = _baseDraft().copyWith(
          weeks: [
            ProgrammeBuilderWeekDraft(id: 'week-1', weekNumber: 1, slots: null),
            ProgrammeBuilderWeekDraft(
              id: 'week-2',
              weekNumber: 3,
              slots: [
                ProgrammeBuilderWorkoutSlotDraft(
                  slotIndex: 0,
                  scheduledDayIndex: 0,
                  template: null,
                ),
              ],
            ),
          ],
        );
        final errors = validator.validate(draft);
        expect(errors.length, greaterThanOrEqualTo(2));
        expect(
          errors.where((e) => e.code == AppErrorCodes.noSlots),
          hasLength(1),
        );
        expect(
          errors.where((e) => e.code == AppErrorCodes.nonSequentialWeek),
          hasLength(1),
        );
        expect(
          errors.where((e) => e.code == AppErrorCodes.missingTemplate),
          hasLength(1),
        );
      });
    });
  });
}
