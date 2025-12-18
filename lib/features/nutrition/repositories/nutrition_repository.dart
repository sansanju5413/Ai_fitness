import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal.dart';

class NutritionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NutritionRepository(this._firestore, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  String _docId(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Realtime stream of a single day's meal log for the current user.
  Stream<MealLog> watchDailyLog(DateTime date) {
    final userId = _userId;
    final normalized = DateTime(date.year, date.month, date.day);

    if (userId == null) {
      return Stream.value(MealLog(
        id: _docId(normalized),
        userId: '',
        date: normalized,
        meals: const [],
      ));
    }

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('foodLogs')
        .doc(_docId(normalized));

    return docRef.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return MealLog(
          id: _docId(normalized),
          userId: userId,
          date: normalized,
          meals: const [],
        );
      }
      final data = {...snap.data()!, 'id': snap.id, 'userId': userId};
      return MealLog.fromJson(data);
    });
  }

  /// Add a meal to the given day in Firestore (ADD only, no remove).
  Future<void> logMeal(Meal meal) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User must be logged in to log meals');
    }

    final normalized = DateTime(meal.time.year, meal.time.month, meal.time.day);
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('foodLogs')
        .doc(_docId(normalized));

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      MealLog current;
      if (snap.exists && snap.data() != null) {
        final data = {...snap.data()!, 'id': snap.id, 'userId': userId};
        current = MealLog.fromJson(data);
      } else {
        current = MealLog(
          id: _docId(normalized),
          userId: userId,
          date: normalized,
          meals: const [],
        );
      }

      final updated = MealLog(
        id: current.id,
        userId: current.userId,
        date: current.date,
        meals: [...current.meals, meal],
      );

      tx.set(docRef, updated.toJson());
    });
  }
}

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final dailyLogProvider = StreamProvider.family<MealLog, DateTime>((ref, date) {
  return ref.read(nutritionRepositoryProvider).watchDailyLog(date);
});
