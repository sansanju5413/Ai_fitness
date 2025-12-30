import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_repository.dart';
import '../models/workout_session.dart';

class SessionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SessionRepository(this._firestore, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  /// Save or update an ongoing workout session to Firestore
  Future<void> saveOngoingSession(WorkoutSession session) async {
    if (_userId == null) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('active_session')
        .doc('current')
        .set(session.toJson());
  }

  /// Get the active session if it exists (e.g., to resume after crash)
  Future<WorkoutSession?> getActiveSession() async {
    if (_userId == null) return null;
    
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('active_session')
        .doc('current')
        .get();
    
    if (doc.exists && doc.data() != null) {
      return WorkoutSession.fromJson(doc.data()!);
    }
    return null;
  }

  /// Delete the active session record (call when finishing or abandoning)
  Future<void> clearActiveSession() async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('active_session')
        .doc('current')
        .delete();
  }

  /// Save a completed workout session to history
  Future<void> saveWorkoutSession(WorkoutSession session) async {
    if (_userId == null) {
      throw Exception('User must be logged in to save workout session');
    }

    final batch = _firestore.batch();
    
    // 1. Add to history
    final historyRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('workouts')
        .doc(session.id);
    
    batch.set(historyRef, session.toJson());
    
    // 2. Clear from active
    final activeRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('active_session')
        .doc('current');
    
    batch.delete(activeRef);

    await batch.commit();
  }

  /// Get all workout sessions for the current user
  Stream<List<WorkoutSession>> getWorkoutSessions([String? userId]) {
    final uid = userId ?? _userId;
    if (uid == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(uid)
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
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(<WorkoutSession>[]);
      return ref.read(sessionRepositoryProvider).getWorkoutSessions(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (error, stack) => Stream.error(error, stack),
  );
});
