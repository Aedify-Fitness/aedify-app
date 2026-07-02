import 'package:flutter/material.dart';
import 'package:aedify/features/exercise_library/presentation/exercise_library_screen.dart';
import 'package:aedify/features/programmes/presentation/saved_workout_library_screen.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class LibraryHubScreen extends StatefulWidget {
  const LibraryHubScreen({super.key});

  @override
  State<LibraryHubScreen> createState() => _LibraryHubScreenState();
}

class _LibraryHubScreenState extends State<LibraryHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.exerciseLibrary),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.exerciseLibrary),
            Tab(text: AppStrings.savedWorkouts),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ExerciseLibraryScreen(), SavedWorkoutLibraryScreen()],
      ),
    );
  }
}
