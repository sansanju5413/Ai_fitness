import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../workout/models/workout_plan.dart';

class WorkoutSession {
  final String id;
  final String userId;
  final String workoutDay;
  final String workoutFocus;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final Map<String, List<Map<String, dynamic>>> exerciseLogs;
  final bool isCompleted;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.workoutDay,
    required this.workoutFocus,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.exerciseLogs,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'workoutDay': workoutDay,
        'workoutFocus': workoutFocus,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
        'durationSeconds': duration.inSeconds,
        'exerciseLogs': exerciseLogs,
        'isCompleted': isCompleted,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    // Properly deserialize exerciseLogs with type safety
    final Map<String, List<Map<String, dynamic>>> logs = {};
    final rawLogs = json['exerciseLogs'];
    if (rawLogs != null && rawLogs is Map) {
      rawLogs.forEach((key, value) {
        if (value is List) {
          logs[key.toString()] = value.map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{};
          }).toList();
        }
      });
    }
    
    return WorkoutSession(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      workoutDay: json['workoutDay'] ?? '',
      workoutFocus: json['workoutFocus'] ?? '',
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: json['endTime'] != null ? (json['endTime'] as Timestamp).toDate() : null,
      duration: Duration(seconds: json['durationSeconds'] ?? 0),
      exerciseLogs: logs,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class SessionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SessionRepository(this._firestore, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  /// Save a completed workout session to Firestore
  Future<void> saveWorkoutSession({
    required DailyWorkout workout,
    required DateTime startTime,
    required Duration duration,
    required Map<String, List<Map<String, dynamic>>> exerciseLogs,
  }) async {
    if (_userId == null) {
      throw Exception('User must be logged in to save workout session');
    }

    final sessionId = _firestore.collection('users').doc(_userId).collection('workouts').doc().id;
    
    final session = WorkoutSession(
      id: sessionId,
      userId: _userId!,
      workoutDay: workout.dayOfWeek,
      workoutFocus: workout.focus,
      startTime: startTime,
      endTime: DateTime.now(),
      duration: duration,
      exerciseLogs: exerciseLogs,
      isCompleted: true,
    );

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('workouts')
        .doc(sessionId)
        .set(session.toJson());
  }

  /// Get all workout sessions for the current user
  Stream<List<WorkoutSession>> getWorkoutSessions() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('workouts')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutSession.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Get workout sessions for a specific date range
  Future<List<WorkoutSession>> getWorkoutSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_userId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('workouts')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WorkoutSession.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final workoutSessionsStreamProvider = StreamProvider<List<WorkoutSession>>((ref) {
  return ref.read(sessionRepositoryProvider).getWorkoutSessions();
});
