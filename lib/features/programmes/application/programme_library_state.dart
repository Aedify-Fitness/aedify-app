import 'package:aedify/features/programmes/domain/programme_list_item.dart';

class ProgrammeLibraryState {
  const ProgrammeLibraryState({
    required this.items,
    required this.isLoading,
    this.errorCode,
    this.errorMessage,
  });

  final List<ProgrammeListItem> items;
  final bool isLoading;
  final String? errorCode;
  final String? errorMessage;

  bool get isEmpty => items.isEmpty && !isLoading && errorCode == null;
}
