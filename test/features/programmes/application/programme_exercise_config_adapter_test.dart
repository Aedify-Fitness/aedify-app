import 'package:aedify/features/programmes/application/programme_exercise_config_adapter.dart';
import 'package:aedify/features/programmes/domain/programme_exercise_draft.dart';
import 'package:aedify/features/programmes/domain/set_prescription_draft.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'shared editor changes preserve programme metadata and clear targets',
    () {
      const original = SetPrescriptionDraft(
        id: 'set',
        setIndex: 0,
        setType: SetType.working,
        prescribedRepsExact: 8,
        prescribedWeightKg: 50,
        prescribedRpeMin: 7.5,
        prescribedRpeMax: 8.5,
        prescribedWeightPct1rm: 70,
        prescribedWeightPctWorking: 50,
        bodyweightMultiplier: 1,
        distanceMeters: 200,
        percent1rmMin: 65,
        percent1rmMax: 75,
        rpeMin: 7,
        rpeMax: 9,
        loadSelectionNote: 'Keep this local note',
        isCalibrationEstimate: true,
        derivedFromWorkingSetIndex: 0,
        warmupWeightRuleJson: '{}',
      );
      const exercise = ProgrammeExerciseDraft(
        id: 'exercise',
        exerciseId: 1,
        sortOrder: 0,
        exerciseRef: 'Bench Press',
        sets: [original],
        supersetGroupId: 'group',
        supersetOrder: 1,
        notes: 'Exercise notes',
      );
      final editor = ProgrammeExerciseConfigAdapter.toEditor(exercise, null);
      expect(editor.exercise.name, 'Bench Press');
      expect(editor.supersetGroupId, 'group');
      expect(editor.notes, 'Exercise notes');
      expect(editor.sets.single.prescribedRpeMin, 7.5);
      final edited = editor.sets.single
          .clearWeight()
          .clearTarget()
          .clearReps()
          .copyWith(
            setType: SetType.warmup,
            prescribedRepsMin: 10,
            prescribedRepsMax: 12,
          );
      final result = ProgrammeExerciseConfigAdapter.applyEdit(original, edited);
      expect(result.setType, SetType.warmup);
      expect(result.prescribedRepsExact, isNull);
      expect(result.prescribedRepsMin, 10);
      expect(result.prescribedRepsMax, 12);
      expect(result.prescribedWeightKg, isNull);
      expect(result.prescribedRpeMin, isNull);
      expect(result.prescribedRpeMax, isNull);
      expect(result.distanceMeters, 200);
      expect(result.prescribedWeightPct1rm, 70);
      expect(result.prescribedWeightPctWorking, 50);
      expect(result.bodyweightMultiplier, 1);
      expect(result.percent1rmMin, 65);
      expect(result.percent1rmMax, 75);
      expect(result.rpeMin, 7);
      expect(result.rpeMax, 9);
      expect(result.loadSelectionNote, 'Keep this local note');
      expect(result.isCalibrationEstimate, isTrue);
      expect(result.derivedFromWorkingSetIndex, 0);
      expect(result.warmupWeightRuleJson, '{}');
    },
  );

  test('duration prescriptions use the shared duration editor', () {
    const exercise = ProgrammeExerciseDraft(
      id: 'exercise',
      exerciseId: 1,
      sortOrder: 0,
      sets: [
        SetPrescriptionDraft(
          id: 'set',
          setIndex: 0,
          setType: SetType.working,
          durationSeconds: 75,
        ),
      ],
    );
    final editor = ProgrammeExerciseConfigAdapter.toEditor(exercise, null);
    expect(editor.exercise.loggingType, 'duration');
    final result = ProgrammeExerciseConfigAdapter.applyEdit(
      exercise.sets.single,
      editor.sets.single.copyWith(durationSeconds: 90),
    );
    expect(result.durationSeconds, 90);
  });
}
