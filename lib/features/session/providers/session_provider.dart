import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_fitness_app/features/workout/models/workout_plan.dart';
import 'package:ai_fitness_app/features/session/models/workout_session.dart';
import 'package:ai_fitness_app/features/session/repositories/session_repository.dart';

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
  final Map<String, List<Map<String, dynamic>>> logs;
  final DateTime? startTime;
  final String? sessionId;

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
    this.sessionId,
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
    String? sessionId,
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
      sessionId: sessionId ?? this.sessionId,
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
     final sessionId = 'sess_${DateTime.now().millisecondsSinceEpoch}';
     state = SessionState(
       activeWorkout: workout,
       startTime: DateTime.now(),
       sessionId: sessionId,
     );
     _startWorkoutTimer();
     _autoSave();
  }

  Future<void> checkAndResumeSession() async {
    if (_sessionRepository == null) return;
    
    final activeSession = await _sessionRepository.getActiveSession();
    if (activeSession != null && !activeSession.isCompleted) {
      // Find the workout in the current plan or just use the one from the session
      // For now, we assume the session carries the necessary context or we might need to fetch the plan.
      // Since DailyWorkout doesn't have the full plan context here, we might need a better way.
      // However, for resume, we can just rebuild the state.
      
      // We need to find where they were. This might require storing block/exercise indices in WorkoutSession.
      // Let's update WorkoutSession model to include these.
      
      // For now, let's just restore the basic info.
      state = SessionState(
        activeWorkout: null, // We need to handle this
        startTime: activeSession.startTime,
        sessionId: activeSession.id,
        elapsedDuration: activeSession.duration,
        logs: activeSession.exerciseLogs,
      );
      _startWorkoutTimer();
    }
  }

  Future<void> _autoSave() async {
    if (_sessionRepository == null || state.activeWorkout == null || state.sessionId == null) return;

    final session = WorkoutSession(
      id: state.sessionId!,
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      workoutDay: state.activeWorkout!.dayOfWeek,
      workoutFocus: state.activeWorkout!.focus,
      startTime: state.startTime ?? DateTime.now(),
      duration: state.elapsedDuration,
      exerciseLogs: state.logs,
      isCompleted: state.isCompleted,
      currentBlockIndex: state.currentBlockIndex,
      currentExerciseIndex: state.currentExerciseIndex,
    );

    await _sessionRepository.saveOngoingSession(session);
  }

  Future<void> resumeSession(WorkoutSession session, DailyWorkout workout) async {
    state = SessionState(
      activeWorkout: workout,
      startTime: session.startTime,
      sessionId: session.id,
      elapsedDuration: session.duration,
      logs: session.exerciseLogs,
      currentBlockIndex: session.currentBlockIndex,
      currentExerciseIndex: session.currentExerciseIndex,
      currentSetNumber: 1, // We could also store this if needed
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
    _autoSave();

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
    
    if (_sessionRepository != null && 
        state.activeWorkout != null && 
        state.startTime != null &&
        state.sessionId != null) {
      try {
        final session = WorkoutSession(
          id: state.sessionId!,
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          workoutDay: state.activeWorkout!.dayOfWeek,
          workoutFocus: state.activeWorkout!.focus,
          startTime: state.startTime!,
          endTime: DateTime.now(),
          duration: state.elapsedDuration,
          exerciseLogs: state.logs,
          isCompleted: true,
        );
        
        await _sessionRepository.saveWorkoutSession(session);
      } catch (saveError) {
        print('[SessionNotifier] Error finishing session: $saveError');
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
