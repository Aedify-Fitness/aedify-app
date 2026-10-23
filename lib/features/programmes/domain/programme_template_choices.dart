import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';

/// Builds assignment choices without changing stored programme templates.
abstract final class ProgrammeTemplateChoices {
  /// Keeps the first template for each exercise collection.
  ///
  /// Exercise order, assignment IDs, names, and prescriptions do not create
  /// additional choices. Repeated occurrences of an exercise remain significant.
  static List<ProgrammeBuilderTemplateDraft> distinctByExercises(
    Iterable<ProgrammeBuilderTemplateDraft> templates,
  ) {
    final seen = <String>{};
    return [
      for (final template in templates)
        if (seen.add(_exerciseKey(template))) template,
    ];
  }

  static String _exerciseKey(ProgrammeBuilderTemplateDraft template) {
    final ids =
        template.exercises.map((exercise) => exercise.exerciseId).toList()
          ..sort();
    return ids.join(',');
  }
}
