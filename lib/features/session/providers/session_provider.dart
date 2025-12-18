import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../workout/models/workout_plan.dart';
import '../repositories/session_repository.dart';

// --- State Model ---
class SessionState {
  final DailyWorkout? activeWorkout;
  final int currentBlockIndex;
  final int currentExerciseIndex;
  final int currentSetNumber;
  final Duration elapsedDuration;
  final bool isResting;
  final int restTimeRemaining;
  final bool isCompleted;
  final Map<String, List<Map<String, dynamic>>> logs; // {'exercise_name': [{'set': 1, 'reps': 10, 'weight': 50}]}
  final DateTime? startTime;

  SessionState({
    this.activeWorkout,
    this.currentBlockIndex = 0,
    this.currentExerciseIndex = 0,
    this.currentSetNumber = 1,
    this.elapsedDuration = Duration.zero,
    this.isResting = false,
    this.restTimeRemaining = 0,
    this.isCompleted = false,
    this.logs = const {},
    this.startTime,
  });

  SessionState copyWith({
    DailyWorkout? activeWorkout,
    int? currentBlockIndex,
    int? currentExerciseIndex,
    int? currentSetNumber,
    Duration? elapsedDuration,
    bool? isResting,
    int? restTimeRemaining,
    bool? isCompleted,
    Map<String, List<Map<String, dynamic>>>? logs,
    DateTime? startTime,
  }) {
    return SessionState(
      activeWorkout: activeWorkout ?? this.activeWorkout,
      currentBlockIndex: currentBlockIndex ?? this.currentBlockIndex,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSetNumber: currentSetNumber ?? this.currentSetNumber,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      isResting: isResting ?? this.isResting,
      restTimeRemaining: restTimeRemaining ?? this.restTimeRemaining,
      isCompleted: isCompleted ?? this.isCompleted,
      logs: logs ?? this.logs,
      startTime: startTime ?? this.startTime,
    );
  }
}

// --- Notifier ---
class SessionNotifier extends StateNotifier<SessionState> {
  Timer? _workoutTimer;
  Timer? _restTimer;
  final SessionRepository? _sessionRepository;

  SessionNotifier(this._sessionRepository) : super(SessionState());

  // Start Session
  void startSession(DailyWorkout workout) {
     state = SessionState(
       activeWorkout: workout,
       startTime: DateTime.now(),
     );
     _startWorkoutTimer();
  }

  void _startWorkoutTimer() {
    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedDuration: state.elapsedDuration + const Duration(seconds: 1));
    });
  }

  // Log Set & Handle Progression
  void logSet({required int reps, required double weight}) {
    if (state.activeWorkout == null) return;
    
    // Bounds checking
    if (state.currentBlockIndex >= state.activeWorkout!.blocks.length ||
        state.activeWorkout!.blocks.isEmpty) {
      finishSession(); // Fire and forget - async save happens in background
      return;
    }

    final currentBlock = state.activeWorkout!.blocks[state.currentBlockIndex];
    
    if (state.currentExerciseIndex >= currentBlock.exercises.length ||
        currentBlock.exercises.isEmpty) {
      _nextExercise();
      return;
    }
    
    final currentExercise = currentBlock.exercises[state.currentExerciseIndex];

    // Log Logic
    final newLogs = Map<String, List<Map<String, dynamic>>>.from(state.logs);
    if (!newLogs.containsKey(currentExercise.name)) {
      newLogs[currentExercise.name] = [];
    }
    
    newLogs[currentExercise.name]!.add({
      'set': state.currentSetNumber,
      'reps': reps,
      'weight': weight,
    });

    state = state.copyWith(logs: newLogs);

    // Progression Logic
    if (state.currentSetNumber < currentExercise.sets) {
      // Next Set -> Start Rest
      _startRestTimer(currentExercise.restSeconds);
      state = state.copyWith(currentSetNumber: state.currentSetNumber + 1);
    } else {
      // Finished Exercise
      _nextExercise();
    }
  }

  void _nextExercise() {
     if (state.activeWorkout == null) return;
     
     // Bounds checking
     if (state.currentBlockIndex >= state.activeWorkout!.blocks.length ||
         state.activeWorkout!.blocks.isEmpty) {
       finishSession(); // Fire and forget - async save happens in background
       return;
     }
     
     final currentBlock = state.activeWorkout!.blocks[state.currentBlockIndex];

     if (state.currentExerciseIndex < currentBlock.exercises.length - 1) {
       // Next Exercise in Block
       state = state.copyWith(
         currentExerciseIndex: state.currentExerciseIndex + 1,
         currentSetNumber: 1,
       );
     } else {
       // Finished Block -> Next Block
       if (state.currentBlockIndex < state.activeWorkout!.blocks.length - 1) {
          final nextBlockIndex = state.currentBlockIndex + 1;
          if (nextBlockIndex < state.activeWorkout!.blocks.length) {
            final nextBlock = state.activeWorkout!.blocks[nextBlockIndex];
            if (nextBlock.exercises.isNotEmpty) {
              state = state.copyWith(
                currentBlockIndex: nextBlockIndex,
                currentExerciseIndex: 0,
                currentSetNumber: 1,
              );
            } else {
              // Next block has no exercises, try next block or finish
              finishSession(); // Fire and forget - async save happens in background
            }
          } else {
            finishSession(); // Fire and forget - async save happens in background
          }
       } else {
         // Workout Complete
         finishSession(); // Fire and forget - async save happens in background
       }
     }
  }

  void _startRestTimer(int seconds) {
    state = state.copyWith(isResting: true, restTimeRemaining: seconds);
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.restTimeRemaining > 0) {
        state = state.copyWith(restTimeRemaining: state.restTimeRemaining - 1);
      } else {
        skipRest();
      }
    });
  }

  void skipRest() {
    _restTimer?.cancel();
    state = state.copyWith(isResting: false, restTimeRemaining: 0);
  }

  // Manual navigation for guided workout flow
  void nextExerciseManual() {
    if (state.activeWorkout == null) return;
    
    // Skip rest if active
    if (state.isResting) {
      skipRest();
    }
    
    // Bounds checking
    if (state.currentBlockIndex >= state.activeWorkout!.blocks.length ||
        state.activeWorkout!.blocks.isEmpty) {
      return;
    }
    
    final currentBlock = state.activeWorkout!.blocks[state.currentBlockIndex];
    final currentExercise = currentBlock.exercises[state.currentExerciseIndex];
    
    // Log the current set before moving
    if (state.currentSetNumber <= currentExercise.sets) {
      logSet(reps: currentExercise.reps, weight: 0);
    } else {
      _nextExercise();
    }
  }

  void previousExercise() {
    if (state.activeWorkout == null) return;
    
    // Skip rest if active
    if (state.isResting) {
      skipRest();
    }
    
    // Can't go back if at first exercise of first block
    if (state.currentBlockIndex == 0 && state.currentExerciseIndex == 0) {
      return;
    }
    
    // Go to previous exercise in current block
    if (state.currentExerciseIndex > 0) {
      final prevExercise = state.activeWorkout!.blocks[state.currentBlockIndex]
          .exercises[state.currentExerciseIndex - 1];
      state = state.copyWith(
        currentExerciseIndex: state.currentExerciseIndex - 1,
        currentSetNumber: 1, // Reset to first set of previous exercise
      );
    } else {
      // Go to last exercise of previous block
      if (state.currentBlockIndex > 0) {
        final prevBlockIndex = state.currentBlockIndex - 1;
        final prevBlock = state.activeWorkout!.blocks[prevBlockIndex];
        if (prevBlock.exercises.isNotEmpty) {
          state = state.copyWith(
            currentBlockIndex: prevBlockIndex,
            currentExerciseIndex: prevBlock.exercises.length - 1,
            currentSetNumber: 1,
          );
        }
      }
    }
  }

  Future<void> finishSession() async {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    
    // Save session to Firebase if repository is available
    if (_sessionRepository != null && 
        state.activeWorkout != null && 
        state.startTime != null &&
        state.logs.isNotEmpty) {
      try {
        await _sessionRepository!.saveWorkoutSession(
          workout: state.activeWorkout!,
          startTime: state.startTime!,
          duration: state.elapsedDuration,
          exerciseLogs: state.logs,
        );
      } catch (e) {
        // Log error but don't prevent session completion
        print('Error saving workout session: $e');
      }
    }
    
    state = state.copyWith(isCompleted: true);
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(
    ref.read(firestoreProvider),
    ref.read(firebaseAuthProvider),
  );
});

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref.read(sessionRepositoryProvider));
});
