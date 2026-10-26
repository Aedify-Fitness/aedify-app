import 'package:aedify/core/validation/draft_validation_path.dart';
import 'package:aedify/core/validation/draft_validation_scope.dart';

class DraftValidationIssue {
  const DraftValidationIssue({
    required this.scope,
    required this.code,
    required this.message,
    this.path = const DraftValidationPath(),
  });

  final DraftValidationScope scope;
  final String code;
  final String message;
  final DraftValidationPath path;
}
