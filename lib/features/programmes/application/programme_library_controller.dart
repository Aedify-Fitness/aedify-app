import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/application/programme_library_state.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class ProgrammeLibraryController extends AsyncNotifier<ProgrammeLibraryState> {
  @override
  Future<ProgrammeLibraryState> build() async {
    return _load();
  }

  Future<ProgrammeLibraryState> _load() async {
    try {
      final useCase = ref.read(AppProviders.listProgrammesUseCaseProvider);
      final items = await useCase.execute();
      return ProgrammeLibraryState(items: items, isLoading: false);
    } catch (e) {
      return ProgrammeLibraryState(
        items: [],
        isLoading: false,
        errorCode: AppErrorCodes.loadFailed,
        errorMessage: AppStrings.programmesLoadFailed,
      );
    }
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> archiveProgramme(String id) async {
    try {
      final repo = ref.read(AppProviders.programmeRepositoryProvider);
      await repo.archiveProgramme(id);
      await reload();
    } catch (e) {
      // silently fail; user can retry
    }
  }

  Future<void> deleteProgramme(String id) async {
    try {
      final repo = ref.read(AppProviders.programmeRepositoryProvider);
      await repo.deleteProgramme(id);
      await reload();
    } catch (e) {
      // silently fail; user can retry
    }
  }
}
