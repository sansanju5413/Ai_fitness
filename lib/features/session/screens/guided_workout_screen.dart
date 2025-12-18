import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../workout/models/workout_plan.dart';
import '../providers/session_provider.dart';

/// New guided workout screen with step-by-step exercise navigation
class GuidedWorkoutScreen extends ConsumerStatefulWidget {
  final DailyWorkout workout;
  
  const GuidedWorkoutScreen({super.key, required this.workout});

  @override
  ConsumerState<GuidedWorkoutScreen> createState() => _GuidedWorkoutScreenState();
}

class _GuidedWorkoutScreenState extends ConsumerState<GuidedWorkoutScreen> {
  bool _showPreview = true;
  
  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    
    if (_showPreview) {
      return _WorkoutPreviewScreen(
        workout: widget.workout,
        onStart: () {
          ref.read(sessionProvider.notifier).startSession(widget.workout);
          setState(() => _showPreview = false);
        },
        onCancel: () => context.pop(),
      );
    }
    
    if (sessionState.isCompleted) {
      return _WorkoutCompletionScreen(
        workout: widget.workout,
        duration: sessionState.elapsedDuration,
        logs: sessionState.logs,
        onFinish: () => context.pop(),
      );
    }
    
    return _GuidedExerciseScreen(workout: widget.workout);
  }
}

/// Preview screen showing workout template before starting
class _WorkoutPreviewScreen extends StatelessWidget {
  final DailyWorkout workout;
  final VoidCallback onStart;
  final VoidCallback onCancel;
  
  const _WorkoutPreviewScreen({
    required this.workout,
    required this.onStart,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final totalExercises = workout.blocks.fold<int>(
      0,
      (sum, block) => sum + block.exercises.length,
    );
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textPrimary),
                      onPressed: onCancel,
                    ),
                    const Spacer(),
                    Text(
                      'WORKOUT PREVIEW',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // Balance for close button
                  ],
                ),
              ),
              
              // Workout Details
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Title and Stats
                    Text(
                      workout.focus,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.2),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.access_time,
                          label: '${workout.durationMinutes} min',
                        ),
                        const SizedBox(width: 12),
                        _StatChip(
                          icon: Icons.fitness_center,
                          label: '$totalExercises exercises',
                        ),
                        const SizedBox(width: 12),
                        _StatChip(
                          icon: Icons.layers,
                          label: '${workout.blocks.length} blocks',
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                    
                    const SizedBox(height: 32),
                    
                    // Blocks breakdown
                    ...workout.blocks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final block = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  block.type,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...block.exercises.map((exercise) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${exercise.sets} × ${exercise.reps}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(begin: 0.1);
                    }),
                    
                    const SizedBox(height: 80), // Space for button
                  ],
                ),
              ),
              
              // Start Button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Begin Workout',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main guided exercise screen with step-by-step navigation
class _GuidedExerciseScreen extends ConsumerWidget {
  final DailyWorkout workout;
  
  const _GuidedExerciseScreen({required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    
    if (sessionState.activeWorkout == null ||
        sessionState.currentBlockIndex >= sessionState.activeWorkout!.blocks.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final currentBlock = sessionState.activeWorkout!.blocks[sessionState.currentBlockIndex];
    
    if (sessionState.currentExerciseIndex >= currentBlock.exercises.length) {
      return const Scaffold(
        body: Center(child: Text('Exercise index out of bounds')),
      );
    }
    
    final currentExercise = currentBlock.exercises[sessionState.currentExerciseIndex];
    final isLastExercise = _isLastExercise(sessionState);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header with timer
                  _WorkoutHeader(
                    duration: sessionState.elapsedDuration,
                    onClose: () => _showQuitDialog(context, ref),
                  ),
                  
                  // Progress indicator
                  _ProgressIndicator(workout: workout, sessionState: sessionState),
                  
                  // Exercise content
                  Expanded(
                    child: _ExerciseCard(
                      exercise: currentExercise,
                      blockType: currentBlock.type,
                      setNumber: sessionState.currentSetNumber,
                    ),
                  ),
                  
                  // Navigation and actions
                  _NavigationBar(
                    isLastExercise: isLastExercise,
                    canGoBack: sessionState.currentExerciseIndex > 0 || sessionState.currentBlockIndex > 0,
                    onPrevious: () => ref.read(sessionProvider.notifier).previousExercise(),
                    onNext: () async {
                      if (isLastExercise) {
                        await ref.read(sessionProvider.notifier).finishSession();
                      } else {
                        ref.read(sessionProvider.notifier).nextExerciseManual();
                      }
                    },
                  ),
                ],
              ),
              
              // Rest timer overlay
              if (sessionState.isResting) _RestOverlay(restTimeRemaining: sessionState.restTimeRemaining),
            ],
          ),
        ),
      ),
    );
  }
  
  bool _isLastExercise(SessionState state) {
    final isLastBlock = state.currentBlockIndex >= state.activeWorkout!.blocks.length - 1;
    if (!isLastBlock) return false;
    
    final lastBlock = state.activeWorkout!.blocks[state.currentBlockIndex];
    return state.currentExerciseIndex >= lastBlock.exercises.length - 1 &&
           state.currentSetNumber >= lastBlock.exercises[state.currentExerciseIndex].sets;
  }
  
  void _showQuitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Quit Workout?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Your progress won\'t be saved if you quit now.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Quit', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

/// Workout completion summary screen
class _WorkoutCompletionScreen extends StatelessWidget {
  final DailyWorkout workout;
  final Duration duration;
  final Map<String, List<Map<String, dynamic>>> logs;
  final VoidCallback onFinish;
  
  const _WorkoutCompletionScreen({
    required this.workout,
    required this.duration,
    required this.logs,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final exercisesCompleted = logs.keys.length;
    final totalSets = logs.values.fold<int>(0, (sum, sets) => sum + sets.length);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: AppColors.primary,
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  'Workout Complete!',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: 16),
                
                Text(
                  workout.focus,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 48),
                
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CompletionStat(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: _formatDuration(duration),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                    
                    _CompletionStat(
                      icon: Icons.fitness_center,
                      label: 'Exercises',
                      value: '$exercisesCompleted',
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
                    
                    _CompletionStat(
                      icon: Icons.repeat,
                      label: 'Total Sets',
                      value: '$totalSets',
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

// Supporting Widgets

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutHeader extends StatelessWidget {
  final Duration duration;
  final VoidCallback onClose;
  
  const _WorkoutHeader({required this.duration, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: onClose,
          ),
          Column(
            children: [
              Text('WORKOUT TIME', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(
                _formatDuration(duration),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48), // Balance
        ],
      ),
    );
  }
  
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }
}

class _ProgressIndicator extends StatelessWidget {
  final DailyWorkout workout;
  final SessionState sessionState;
  
  const _ProgressIndicator({required this.workout, required this.sessionState});

  @override
  Widget build(BuildContext context) {
    final totalExercises = workout.blocks.fold<int>(0, (sum, block) => sum + block.exercises.length);
    int currentExerciseNumber = 0;
    
    for (int i = 0; i < sessionState.currentBlockIndex; i++) {
      currentExerciseNumber += workout.blocks[i].exercises.length;
    }
    currentExerciseNumber += sessionState.currentExerciseIndex + 1;
    
    final progress = (currentExerciseNumber / totalExercises).clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise $currentExerciseNumber of $totalExercises',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String blockType;
  final int setNumber;
  
  const _ExerciseCard({
    required this.exercise,
    required this.blockType,
    required this.setNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                blockType.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              exercise.name,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ExerciseDetail(
                  label: 'SET',
                  value: '$setNumber / ${exercise.sets}',
                ),
                const SizedBox(width: 32),
                _ExerciseDetail(
                  label: 'REPS',
                  value: '${exercise.reps}',
                ),
                if (exercise.durationSeconds != null) ...[
                  const SizedBox(width: 32),
                  _ExerciseDetail(
                    label: 'TIME',
                    value: '${exercise.durationSeconds}s',
                  ),
                ],
              ],
            ),
            
            if (exercise.notes.isNotEmpty) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exercise.notes,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
    );
  }
}

class _ExerciseDetail extends StatelessWidget {
  final String label;
  final String value;
  
  const _ExerciseDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _NavigationBar extends ConsumerWidget {
  final bool isLastExercise;
  final bool canGoBack;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  
  const _NavigationBar({
    required this.isLastExercise,
    required this.canGoBack,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (canGoBack)
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.surfaceLight),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 20),
                      SizedBox(width: 8),
                      Text('Previous'),
                    ],
                  ),
                ),
              ),
            if (canGoBack) const SizedBox(width: 12),
            Expanded(
              flex: canGoBack ? 1 : 2,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLastExercise ? AppColors.secondary : AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastExercise ? 'Finish' : 'Next',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLastExercise ? Icons.check : Icons.arrow_forward,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestOverlay extends ConsumerWidget {
  final int restTimeRemaining;
  
  const _RestOverlay({required this.restTimeRemaining});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'REST',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$restTimeRemaining',
              style: GoogleFonts.inter(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'seconds',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            OutlinedButton(
              onPressed: () => ref.read(sessionProvider.notifier).skipRest(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Skip Rest'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}

class _CompletionStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _CompletionStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceLight),
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
