import 'package:aedify/features/programmes/data/programme_repository.dart';
import 'package:aedify/features/programmes/domain/programme_list_item.dart';
import 'package:aedify/shared/domain/program_status.dart';

class ListProgrammesUseCase {
  const ListProgrammesUseCase({
    required ProgrammeRepository programmeRepository,
  }) : _programmeRepository = programmeRepository;

  final ProgrammeRepository _programmeRepository;

  Future<List<ProgrammeListItem>> execute() async {
    final aggregates = await _programmeRepository.listProgrammes(
      status: 'active',
    );
    return aggregates.map((a) {
      final p = a.program;
      return ProgrammeListItem(
        id: p.id,
        name: p.name,
        status: ProgramStatus.fromDb(p.status),
        active: p.active,
        weeksTotal: p.weeksTotal,
        daysPerWeek: p.daysPerWeek,
        updatedAt: p.updatedAt,
        description: p.description,
      );
    }).toList();
  }
}
