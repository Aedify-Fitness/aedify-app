import 'package:aedify/core/validation/draft_validation_issue.dart';

class DraftValidationResult {
  const DraftValidationResult({required this.issues});

  final List<DraftValidationIssue> issues;

  bool get isValid => issues.isEmpty;
}
