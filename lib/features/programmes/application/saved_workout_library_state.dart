import 'package:aedify/features/programmes/domain/saved_workout_list_item.dart';

class SavedWorkoutLibraryState {
  const SavedWorkoutLibraryState({
    required this.items,
    required this.isLoading,
    this.errorCode,
    this.errorMessage,
  });

  final List<SavedWorkoutListItem> items;
  final bool isLoading;
  final String? errorCode;
  final String? errorMessage;

  bool get isEmpty => items.isEmpty && !isLoading && errorCode == null;
}
