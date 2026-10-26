import 'package:aedify/shared/domain/training_day.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/week_type.dart';

enum TrainingBlockFocus {
  base,
  accumulation,
  hypertrophyBiased,
  strengthBiased,
  peak,
  deload;

  String get dbValue => switch (this) {
    hypertrophyBiased => 'hypertrophy_biased',
    strengthBiased => 'strength_biased',
    _ => name,
  };

  String get label => switch (this) {
    base => AppStrings.blockFocusBase,
    accumulation => AppStrings.blockFocusAccumulation,
    hypertrophyBiased => AppStrings.blockFocusHypertrophy,
    strengthBiased => AppStrings.blockFocusStrength,
    peak => AppStrings.blockFocusPeak,
    deload => AppStrings.weekDeload,
  };

  WeekType get weekType => switch (this) {
    hypertrophyBiased => WeekType.hypertrophy,
    strengthBiased => WeekType.strength,
    peak => WeekType.test,
    deload => WeekType.deload,
    _ => WeekType.normal,
  };

  static TrainingBlockFocus fromDb(String value) =>
      values.firstWhere((focus) => focus.dbValue == value, orElse: () => base);
}

/// A sequential group of programme weeks with its own training focus.
class ProgrammeTrainingBlockDraft {
  const ProgrammeTrainingBlockDraft({
    required this.id,
    required this.name,
    required this.weekCount,
    this.focus = TrainingBlockFocus.base,
    this.progressionNotes = '',
    this.trainingDays = const {},
  });

  final String id;
  final String name;
  final int weekCount;
  final TrainingBlockFocus focus;
  final String progressionNotes;
  final Set<TrainingDay> trainingDays;

  static ProgrammeTrainingBlockDraft? forWeek(
    List<ProgrammeTrainingBlockDraft> blocks,
    int weekIndex,
  ) {
    var end = 0;
    for (final block in blocks) {
      end += block.weekCount;
      if (weekIndex >= 0 && weekIndex < end) return block;
    }
    return null;
  }

  ProgrammeTrainingBlockDraft copyWith({
    String? id,
    String? name,
    int? weekCount,
    TrainingBlockFocus? focus,
    String? progressionNotes,
    Set<TrainingDay>? trainingDays,
  }) => ProgrammeTrainingBlockDraft(
    id: id ?? this.id,
    name: name ?? this.name,
    weekCount: weekCount ?? this.weekCount,
    focus: focus ?? this.focus,
    progressionNotes: progressionNotes ?? this.progressionNotes,
    trainingDays: trainingDays ?? this.trainingDays,
  );
}
