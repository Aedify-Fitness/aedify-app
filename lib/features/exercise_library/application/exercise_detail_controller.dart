import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/domain/exercise_detail_view_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exerciseDetailProvider =
    FutureProvider.family<ExerciseDetailViewData?, int>((ref, id) async {
      final repository = ref.read(AppProviders.exerciseRepositoryProvider);
      return repository.getExerciseDetail(id);
    });
