import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_filter_state.dart';
import 'package:aedify/features/exercise_library/domain/exercise_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseSearchState {
  const ExerciseSearchState({
    required this.filters,
    required this.items,
    required this.isLoading,
    this.errorCode,
    this.errorMessage,
  });

  final ExerciseFilterState filters;
  final List<ExerciseListItem> items;
  final bool isLoading;
  final String? errorCode;
  final String? errorMessage;

  bool get isEmpty => items.isEmpty && !isLoading;

  ExerciseSearchState copyWith({
    ExerciseFilterState? filters,
    List<ExerciseListItem>? items,
    bool? isLoading,
    String? errorCode,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExerciseSearchState(
      filters: filters ?? this.filters,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ExerciseSearchController extends Notifier<ExerciseSearchState> {
  @override
  ExerciseSearchState build() {
    _loadInitial();
    return const ExerciseSearchState(
      filters: ExerciseFilterState(),
      items: [],
      isLoading: true,
    );
  }

  Future<void> _loadInitial() async {
    try {
      final repository = ref.read(AppProviders.exerciseRepositoryProvider);
      final filters = const ExerciseFilterState();
      final items = await repository.searchExercises(filters);
      state = ExerciseSearchState(
        filters: filters,
        items: items,
        isLoading: false,
      );
    } catch (e) {
      state = ExerciseSearchState(
        filters: const ExerciseFilterState(),
        items: [],
        isLoading: false,
        errorCode: 'load_failed',
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateSearchQuery(String query) async {
    final updatedFilters = state.filters.copyWith(searchQuery: query);
    await _reloadWithFilters(updatedFilters);
  }

  Future<void> updateFilters(ExerciseFilterState filters) async {
    await _reloadWithFilters(filters);
  }

  Future<void> clearFilters() async {
    await _reloadWithFilters(const ExerciseFilterState());
  }

  Future<void> reload() async {
    await _reloadWithFilters(state.filters);
  }

  Future<void> _reloadWithFilters(ExerciseFilterState filters) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = ref.read(AppProviders.exerciseRepositoryProvider);
      final items = await repository.searchExercises(filters);
      state = ExerciseSearchState(
        filters: filters,
        items: items,
        isLoading: false,
      );
    } catch (e) {
      state = ExerciseSearchState(
        filters: filters,
        items: state.items,
        isLoading: false,
        errorCode: 'search_failed',
        errorMessage: e.toString(),
      );
    }
  }
}
