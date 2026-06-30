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
    this.description,
  });

  final String id;
  final String name;
  final ProgramStatus status;
  final bool active;
  final int? weeksTotal;
  final int? daysPerWeek;
  final DateTime updatedAt;
  final String? description;
}
