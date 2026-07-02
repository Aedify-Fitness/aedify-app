import 'package:aedify/core/validation/draft_validation_service.dart';
import 'package:aedify/features/workout_builder/application/workout_builder_validation_adapter.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_draft.dart';
import 'package:aedify/features/workout_builder/domain/workout_builder_validation_error.dart';
import 'package:aedify/core/logging/app_logger.dart';

class WorkoutBuilderValidator {
  const WorkoutBuilderValidator({
    required this.validationService,
    required this.adapter,
  });

  static final _logger = AppLogger(name: 'WorkoutBuilderValidator');

  final DraftValidationService validationService;
  final WorkoutBuilderValidationAdapter adapter;

  List<WorkoutBuilderValidationError> validate(WorkoutBuilderDraft draft) {
    final validated = adapter.toValidatedDraft(draft);
    final result = validationService.validateWorkoutDraft(validated);
    _logger.debug('validate — ${result.issues.length} issues');
    return adapter.toFeatureErrors(result);
  }
}
