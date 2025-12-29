import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ai_fitness_app/core/theme/app_theme.dart';
import 'package:ai_fitness_app/features/session/providers/session_provider.dart';
import 'package:ai_fitness_app/features/session/widgets/exercise_tracker_card.dart';
import 'package:ai_fitness_app/features/session/widgets/rest_timer_overlay.dart';
import 'package:ai_fitness_app/features/session/repositories/session_repository.dart';
import 'package:ai_fitness_app/features/workout/models/workout_plan.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final DailyWorkout workout; // Passed from plan screen
  const WorkoutSessionScreen({super.key, required this.workout});

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  
  @override
  void initState() {
    super.initState();
    // Start session as soon as screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).startSession(widget.workout);
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    
    // Check if workout is finished?
    // In a real app we'd have a better 'finished' state flag loop.
    // For now we assume if we are looking at this screen, it's active unless...
    // We can check if logs are full or just handle 'Finish' button manual nav.
    
    if (sessionState.activeWorkout == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check if workout is completed
    if (sessionState.isCompleted) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 80, color: AppColors.primary),
                  const SizedBox(height: 24),
                  const Text(
                    'Workout Completed!',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Duration: ${_formatDuration(sessionState.elapsedDuration)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Invalidate providers to ensure fresh data on dashboard
                      ref.invalidate(workoutSessionsStreamProvider);
                      context.pop();
                    },
                    child: const Text('Return to Workouts'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Bounds checking to prevent crashes
    if (sessionState.currentBlockIndex >= sessionState.activeWorkout!.blocks.length ||
        sessionState.activeWorkout!.blocks.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: const Center(
            child: Text('Workout session completed!', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ),
      );
    }

    final currentBlock = sessionState.activeWorkout!.blocks[sessionState.currentBlockIndex];
    
    if (sessionState.currentExerciseIndex >= currentBlock.exercises.length ||
        currentBlock.exercises.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: const Center(
            child: Text('No exercises in this block.', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ),
      );
    }

    final currentExercise = currentBlock.exercises[sessionState.currentExerciseIndex];
    
    // Get next exercise name for display
    String? nextExerciseName;
    if (sessionState.currentSetNumber < currentExercise.sets) {
      nextExerciseName = currentExercise.name; // Same exercise, next set
    } else if (sessionState.currentExerciseIndex < currentBlock.exercises.length - 1) {
      nextExerciseName = currentBlock.exercises[sessionState.currentExerciseIndex + 1].name;
    } else if (sessionState.currentBlockIndex < sessionState.activeWorkout!.blocks.length - 1) {
      final nextBlock = sessionState.activeWorkout!.blocks[sessionState.currentBlockIndex + 1];
      if (nextBlock.exercises.isNotEmpty) {
        nextExerciseName = nextBlock.exercises[0].name;
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent sheet from resizing background
      body: Stack(
        children: [
          // Background
           Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ACTIVE WORKOUT', style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(height: 4),
                          Text(_formatDuration(sessionState.elapsedDuration), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'monospace')),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textPrimary),
                        onPressed: () {
                           // Show confirmation dialog to quit
                           context.pop();
                        },
                      )
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Center(
                      child: ExerciseTrackerCard(
                        key: ValueKey('${currentExercise.name}_${sessionState.currentSetNumber}'), // Rebuild on new set
                        exercise: currentExercise,
                        setNumber: sessionState.currentSetNumber,
                      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    ),
                  ),
                ),

                // Footer / Next Up
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text("NEXT UP", style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                      const SizedBox(height: 8),
                      Text(
                        nextExerciseName ?? "Workout Complete", 
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Overlays
          const RestTimerOverlay(),
        ],
      ),
    );
  }
}
