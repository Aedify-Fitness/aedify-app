import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/program_status.dart';

class ProgrammeListItem {
  const ProgrammeListItem({
    required this.id,
    required this.name,
    required this.status,
    required this.active,
    required this.weeksTotal,
    required this.daysPerWeek,
    required this.updatedAt,
    this.startDateLocal,
    this.description,
    this.source,
    this.imported = false,
    this.goalTags = const {},
  });

  final String id;
  final String name;
  final ProgramStatus status;
  final bool active;
  final int? weeksTotal;
  final int? daysPerWeek;
  final DateTime updatedAt;
  final String? startDateLocal;
  final String? description;
  final String? source;
  final bool imported;
  final Set<GoalTag> goalTags;
}
