import 'package:aedify/core/validation/validated_programme_template_draft.dart';
import 'package:aedify/core/validation/validated_programme_week_draft.dart';

class ValidatedProgrammeDraft {
  const ValidatedProgrammeDraft({
    required this.name,
    required this.templates,
    required this.weeks,
  });

  final String name;
  final List<ValidatedProgrammeTemplateDraft> templates;
  final List<ValidatedProgrammeWeekDraft> weeks;
}
