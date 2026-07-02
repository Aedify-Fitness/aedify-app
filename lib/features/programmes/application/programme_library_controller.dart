import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/programmes/application/programme_library_state.dart';
import 'package:aedify/shared/constants/app_error_codes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/core/logging/app_logger.dart';

class ProgrammeLibraryController extends AsyncNotifier<ProgrammeLibraryState> {
  static final _logger = AppLogger(name: 'ProgrammeLibraryController');

  @override
  Future<ProgrammeLibraryState> build() async {
    _logger.info('build');
    return _load();
  }

  Future<ProgrammeLibraryState> _load() async {
    try {
      final useCase = ref.read(AppProviders.listProgrammesUseCaseProvider);
      final items = await useCase.execute();
      return ProgrammeLibraryState(items: items, isLoading: false);
    } catch (e) {
      _logger.error('_load — failure', error: e);
      return ProgrammeLibraryState(
        items: [],
        isLoading: false,
        errorCode: AppErrorCodes.loadFailed,
        errorMessage: AppStrings.programmesLoadFailed,
      );
    }
  }

  Future<void> reload() async {
    _logger.info('reload');
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> archiveProgramme(String id) async {
    _logger.info('archiveProgramme — id: $id');
    try {
      final repo = ref.read(AppProviders.programmeRepositoryProvider);
      await repo.archiveProgramme(id);
      await reload();
    } catch (e) {
      _logger.error('archiveProgramme — failure', error: e);
    }
  }

  Future<void> deleteProgramme(String id) async {
    _logger.info('deleteProgramme — id: $id');
    try {
      final repo = ref.read(AppProviders.programmeRepositoryProvider);
      await repo.deleteProgramme(id);
      await reload();
    } catch (e) {
      _logger.error('deleteProgramme — failure', error: e);
    }
  }

  Future<void> activateProgramme(String id) async {
    _logger.info('activateProgramme — id: $id');
    try {
      final repo = ref.read(AppProviders.programmeRepositoryProvider);
      await repo.activateProgramme(id);
      await reload();
    } catch (e) {
      _logger.error('activateProgramme — failure', error: e);
    }
  }

  Future<void> deactivateProgramme(String id) async {
    _logger.info('deactivateProgramme — id: $id');
    try {
      final repo = ref.read(AppProviders.programmeRepositoryProvider);
      await repo.deactivateProgramme(id);
      await reload();
    } catch (e) {
      _logger.error('deactivateProgramme — failure', error: e);
    }
  }
}
