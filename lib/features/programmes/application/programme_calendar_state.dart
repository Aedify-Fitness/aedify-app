import 'package:aedify/features/programmes/domain/programme_calendar_view_data.dart';

class ProgrammeCalendarState {
  const ProgrammeCalendarState({
    this.isLoading = false,
    this.viewData,
    this.errorMessage,
  });

  final bool isLoading;
  final ProgrammeCalendarViewData? viewData;
  final String? errorMessage;

  ProgrammeCalendarState copyWith({
    bool? isLoading,
    ProgrammeCalendarViewData? viewData,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProgrammeCalendarState(
      isLoading: isLoading ?? this.isLoading,
      viewData: viewData ?? this.viewData,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
