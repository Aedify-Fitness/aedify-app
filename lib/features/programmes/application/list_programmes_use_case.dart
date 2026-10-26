import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/shared/domain/enum_codec.dart';
import 'package:aedify/shared/domain/goal_tag.dart';
import 'package:aedify/shared/domain/program_status.dart';

class ListProgrammesUseCase {
  const ListProgrammesUseCase({
    required ProgrammeRepository programmeRepository,
  }) : _programmeRepository = programmeRepository;

  final ProgrammeRepository _programmeRepository;

  Future<List<ProgrammeListItem>> execute() async {
    final aggregates = await _programmeRepository.listProgrammes();
    return aggregates.map((a) {
      final p = a.program;
      final goalTags = EnumCodec.decodeSet(p.goalTagsJson, GoalTag.fromDb);
      return ProgrammeListItem(
        id: p.id,
        name: p.name,
        status: ProgramStatus.fromDb(p.status),
        active: p.active,
        weeksTotal: p.weeksTotal,
        daysPerWeek: p.daysPerWeek,
        updatedAt: p.updatedAt,
        startDateLocal: p.startDateLocal,
        description: p.description,
        source: p.source,
        imported: p.imported,
        goalTags: goalTags,
      );
    }).toList();
  }
}
