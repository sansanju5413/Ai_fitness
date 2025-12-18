import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/workout_plan.dart';

// Mock list of exercises for demo
final allExercises = [
  Exercise(name: 'Push Up', sets: 3, reps: 15, restSeconds: 60, notes: 'Chest/Triceps'),
  Exercise(name: 'Bench Press', sets: 4, reps: 8, restSeconds: 90, notes: 'Chest'),
  Exercise(name: 'Pull Up', sets: 3, reps: 8, restSeconds: 60, notes: 'Back'),
  Exercise(name: 'Squat', sets: 4, reps: 10, restSeconds: 90, notes: 'Legs'),
  Exercise(name: 'Deadlift', sets: 3, reps: 5, restSeconds: 120, notes: 'Back/Legs'),
  Exercise(name: 'Plank', sets: 3, reps: 60, restSeconds: 30, notes: 'Core'),
  Exercise(name: 'Lunge', sets: 3, reps: 12, restSeconds: 60, notes: 'Legs'),
  Exercise(name: 'Shoulder Press', sets: 3, reps: 10, restSeconds: 60, notes: 'Shoulders'),
  Exercise(name: 'Bicep Curl', sets: 3, reps: 12, restSeconds: 45, notes: 'Biceps'),
  Exercise(name: 'Tricep Extension', sets: 3, reps: 12, restSeconds: 45, notes: 'Triceps'),
];

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final _filters = ['All', 'Chest', 'Back', 'Legs', 'Core', 'Arms', 'Shoulders'];

  List<Exercise> get _filteredExercises {
    return allExercises.where((ex) {
      final matchesSearch = ex.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' || 
          ex.notes.contains(_selectedFilter) || // Simple logic: notes usually contain muscle group
          (ex.notes.contains('Biceps') && _selectedFilter == 'Arms') ||
          (ex.notes.contains('Triceps') && _selectedFilter == 'Arms');
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (bool selected) {
                        setState(() => _selectedFilter = filter);
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter ? AppColors.textPrimary : AppColors.textSecondary
                      ),
                    ),
                  )
                ).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredExercises.length,
                itemBuilder: (context, index) {
                  final ex = _filteredExercises[index];
                  return Card(
                    color: AppColors.surface,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fitness_center, color: AppColors.primary),
                      ),
                      title: Text(ex.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      subtitle: Text(ex.notes, style: const TextStyle(color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                      onTap: () {
                         // Open detailed view (Phase 6 or future)
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected: ${ex.name}')));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
