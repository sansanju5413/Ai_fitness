import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_plan.dart';
import '../services/workout_generator_service.dart';
import '../../profile/models/user_profile.dart';

class WorkoutRepository {
  final WorkoutGeneratorService? _generatorService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WorkoutRepository({
    WorkoutGeneratorService? generatorService,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _generatorService = generatorService,
        _firestore = firestore,
        _auth = auth;

  String? get _userId => _auth.currentUser?.uid;

  Future<WorkoutPlan?> getCurrentPlan() async {
    if (_userId == null) {
      return _generateMockPlan();
    }

    try {
      // Try to fetch active plan from Firestore
      final plansSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_plans')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (plansSnapshot.docs.isNotEmpty) {
        final planData = plansSnapshot.docs.first.data();
        planData['id'] = plansSnapshot.docs.first.id;
        planData['userId'] = _userId!;
        return WorkoutPlan.fromJson(planData);
      }

      // If no active plan found, return mock plan
      return _generateMockPlan();
    } catch (e) {
      print('Error fetching workout plan: $e');
      // Fallback to mock plan on error
      return _generateMockPlan();
    }
  }

  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    if (_userId == null) {
      throw Exception('User must be logged in to save workout plan');
    }

    // Deactivate all other plans
    final activePlans = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('workout_plans')
        .where('isActive', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (var doc in activePlans.docs) {
      batch.update(doc.reference, {'isActive': false});
    }

    // Save new plan as active
    final planData = plan.toJson();
    planData['isActive'] = true;
    planData['createdAt'] = FieldValue.serverTimestamp();

    batch.set(
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_plans')
          .doc(plan.id),
      planData,
    );

    await batch.commit();
  }
  
  // Generate new plan using AI
  Future<WorkoutPlan> generateNewPlan(
    UserProfile profile, {
    String? userNotes,
  }) async {
    if (_generatorService != null) {
      try {
        final plan = await _generatorService!.generatePlan(
          profile,
          userNotes: userNotes,
        );
        // Save the generated plan to Firestore
        await saveWorkoutPlan(plan);
        return plan;
      } catch (e) {
        print('Error generating AI plan: $e');
        // Fallback to mock plan
        final mockPlan = _generateMockPlan();
        if (_userId != null) {
          try {
            await saveWorkoutPlan(mockPlan);
          } catch (saveError) {
            print('Error saving mock plan: $saveError');
          }
        }
        return mockPlan;
      }
    }
    // Fallback if no generator service
    await Future.delayed(const Duration(seconds: 2));
    final mockPlan = _generateMockPlan();
    if (_userId != null) {
      try {
        await saveWorkoutPlan(mockPlan);
      } catch (saveError) {
        print('Error saving mock plan: $saveError');
      }
    }
    return mockPlan;
  }

  WorkoutPlan _generateMockPlan() {
    final now = DateTime.now();
    return WorkoutPlan(
      id: 'mock_plan_1',
      userId: 'mock_user',
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
      goal: 'Balanced Strength & Conditioning',
      weeklySchedule: [
        DailyWorkout(
          dayOfWeek: 'Monday',
          focus: 'Beginner Full Body',
          durationMinutes: 55,
          imageAsset: 'assets/images/Beginners_Workout_Plan_for_Weight_Gain_at_Home.jpg',
          blocks: [
            ExerciseBlock(
              type: 'Warmup',
              exercises: [
                Exercise(name: 'Jumping Jacks', sets: 2, reps: 30, restSeconds: 20, notes: 'Light pace'),
                Exercise(name: 'World’s Greatest Stretch', sets: 2, reps: 8, restSeconds: 20, notes: 'Per side'),
                Exercise(name: 'Glute Bridges', sets: 2, reps: 12, restSeconds: 30, notes: 'Squeeze at top'),
              ],
            ),
            ExerciseBlock(
              type: 'Main Lift',
              exercises: [
                Exercise(name: 'Goblet Squat', sets: 3, reps: 12, restSeconds: 75, notes: 'Hold dumbbell close'),
                Exercise(name: 'Push-ups', sets: 3, reps: 12, restSeconds: 60, notes: 'Knees on floor if needed'),
                Exercise(name: 'Bent-Over Row', sets: 3, reps: 12, restSeconds: 75, notes: 'Flat back, slow lower'),
                Exercise(name: 'Plank', sets: 3, reps: 30, durationSeconds: 30, restSeconds: 45, notes: 'Stay braced'),
              ],
            ),
            ExerciseBlock(
              type: 'Cooldown',
              exercises: [
                Exercise(name: 'Child’s Pose', sets: 1, reps: 60, durationSeconds: 60, restSeconds: 0, notes: 'Deep breaths'),
                Exercise(name: 'Hamstring Stretch', sets: 1, reps: 45, durationSeconds: 45, restSeconds: 0, notes: 'Per side'),
              ],
            ),
          ],
        ),
        DailyWorkout(
          dayOfWeek: 'Tuesday',
          focus: 'Upper Body Strength',
          durationMinutes: 60,
          imageAsset: 'assets/images/download.jpg',
          blocks: [
            ExerciseBlock(
              type: 'Warmup',
              exercises: [
                Exercise(name: 'Band Pull Apart', sets: 2, reps: 15, restSeconds: 20, notes: 'Open chest'),
                Exercise(name: 'Scap Push-up', sets: 2, reps: 12, restSeconds: 20, notes: 'Short range'),
              ],
            ),
            ExerciseBlock(
              type: 'Main Lift',
              exercises: [
                Exercise(name: 'Dumbbell Bench Press', sets: 4, reps: 10, restSeconds: 90, notes: 'Control tempo'),
                Exercise(name: 'Single Arm Row', sets: 3, reps: 12, restSeconds: 75, notes: 'Per arm'),
                Exercise(name: 'Seated Shoulder Press', sets: 3, reps: 10, restSeconds: 75, notes: 'Neutral grip'),
                Exercise(name: 'Hammer Curl', sets: 3, reps: 12, restSeconds: 60, notes: 'No swing'),
                Exercise(name: 'Triceps Rope Pushdown', sets: 3, reps: 12, restSeconds: 60, notes: 'Elbows tucked'),
              ],
            ),
            ExerciseBlock(
              type: 'Cooldown',
              exercises: [
                Exercise(name: 'Doorway Chest Stretch', sets: 1, reps: 45, durationSeconds: 45, restSeconds: 0, notes: 'Per side'),
                Exercise(name: 'Upper Trap Stretch', sets: 1, reps: 30, durationSeconds: 30, restSeconds: 0, notes: 'Per side'),
              ],
            ),
          ],
        ),
        DailyWorkout(
          dayOfWeek: 'Wednesday',
          focus: 'Lower Body Power',
          durationMinutes: 60,
          imageAsset: 'assets/images/download_1.jpg',
          blocks: [
            ExerciseBlock(
              type: 'Warmup',
              exercises: [
                Exercise(name: 'Bodyweight Squat', sets: 2, reps: 15, restSeconds: 20, notes: 'Sit tall'),
                Exercise(name: 'Walking Lunge', sets: 2, reps: 10, restSeconds: 20, notes: 'Per leg'),
              ],
            ),
            ExerciseBlock(
              type: 'Main Lift',
              exercises: [
                Exercise(name: 'Barbell Back Squat', sets: 4, reps: 8, restSeconds: 120, notes: 'Drive through heels'),
                Exercise(name: 'Romanian Deadlift', sets: 3, reps: 10, restSeconds: 90, notes: 'Hinge pattern'),
                Exercise(name: 'Reverse Lunge', sets: 3, reps: 10, restSeconds: 75, notes: 'Per leg'),
                Exercise(name: 'Calf Raise', sets: 4, reps: 15, restSeconds: 60, notes: 'Pause at top'),
              ],
            ),
            ExerciseBlock(
              type: 'Cooldown',
              exercises: [
                Exercise(name: 'Pigeon Stretch', sets: 1, reps: 45, durationSeconds: 45, restSeconds: 0, notes: 'Per side'),
                Exercise(name: 'Quad Stretch', sets: 1, reps: 30, durationSeconds: 30, restSeconds: 0, notes: 'Per side'),
              ],
            ),
          ],
        ),
        DailyWorkout(
          dayOfWeek: 'Thursday',
          focus: 'HIIT Cardio Blast',
          durationMinutes: 35,
          imageAsset: 'assets/images/download_2.jpg',
          blocks: [
            ExerciseBlock(
              type: 'Warmup',
              exercises: [
                Exercise(name: 'High Knees', sets: 2, reps: 30, durationSeconds: 30, restSeconds: 20, notes: 'Light bounce'),
                Exercise(name: 'Butt Kicks', sets: 2, reps: 30, durationSeconds: 30, restSeconds: 20, notes: 'Quick feet'),
              ],
            ),
            ExerciseBlock(
              type: 'Main Lift',
              exercises: [
                Exercise(name: 'Sprint / Bike', sets: 8, reps: 20, durationSeconds: 20, restSeconds: 40, notes: '20s on / 40s off'),
                Exercise(name: 'Kettlebell Swing', sets: 3, reps: 15, restSeconds: 60, notes: 'Explosive hips'),
                Exercise(name: 'Mountain Climbers', sets: 3, reps: 30, durationSeconds: 30, restSeconds: 45, notes: 'Keep core tight'),
              ],
            ),
            ExerciseBlock(
              type: 'Cooldown',
              exercises: [
                Exercise(name: 'Box Breathing', sets: 1, reps: 60, durationSeconds: 60, restSeconds: 0, notes: '4-4-4-4'),
              ],
            ),
          ],
        ),
        DailyWorkout(
          dayOfWeek: 'Friday',
          focus: 'Core & Abs Focus',
          durationMinutes: 45,
          imageAsset: 'assets/images/download_3.jpg',
          blocks: [
            ExerciseBlock(
              type: 'Warmup',
              exercises: [
                Exercise(name: 'Dead Bug', sets: 2, reps: 12, restSeconds: 20, notes: 'Opposite limbs'),
                Exercise(name: 'Cat Cow', sets: 2, reps: 10, restSeconds: 20, notes: 'Mobilize spine'),
              ],
            ),
            ExerciseBlock(
              type: 'Main Lift',
              exercises: [
                Exercise(name: 'Plank', sets: 3, reps: 45, durationSeconds: 45, restSeconds: 45, notes: 'Glutes tight'),
                Exercise(name: 'Side Plank', sets: 3, reps: 30, durationSeconds: 30, restSeconds: 30, notes: 'Per side'),
                Exercise(name: 'Hanging Knee Raise', sets: 3, reps: 12, restSeconds: 60, notes: 'Slow lower'),
                Exercise(name: 'Russian Twist', sets: 3, reps: 20, restSeconds: 45, notes: 'Light weight'),
              ],
            ),
            ExerciseBlock(
              type: 'Cooldown',
              exercises: [
                Exercise(name: 'Cobra Stretch', sets: 1, reps: 45, durationSeconds: 45, restSeconds: 0, notes: 'Open abs'),
                Exercise(name: 'Seated Forward Fold', sets: 1, reps: 45, durationSeconds: 45, restSeconds: 0, notes: 'Breathe slow'),
              ],
            ),
          ],
        ),
        DailyWorkout(
          dayOfWeek: 'Saturday',
          focus: 'Flexibility & Mobility',
          durationMinutes: 40,
          imageAsset: 'assets/images/download_4.jpg',
          blocks: [
            ExerciseBlock(
              type: 'Warmup',
              exercises: [
                Exercise(name: 'Foam Roll (Quads/Glutes)', sets: 1, reps: 5, durationSeconds: 300, restSeconds: 0, notes: '5 min total'),
              ],
            ),
            ExerciseBlock(
              type: 'Main Lift',
              exercises: [
                Exercise(name: 'World’s Greatest Stretch', sets: 3, reps: 8, restSeconds: 30, notes: 'Per side'),
                Exercise(name: '90/90 Hip Switch', sets: 3, reps: 12, restSeconds: 30, notes: 'Controlled'),
                Exercise(name: 'Thoracic Open Books', sets: 3, reps: 10, restSeconds: 30, notes: 'Per side'),
              ],
            ),
            ExerciseBlock(
              type: 'Cooldown',
              exercises: [
                Exercise(name: 'Box Breathing', sets: 1, reps: 90, durationSeconds: 90, restSeconds: 0, notes: 'Reset nervous system'),
              ],
            ),
          ],
        ),
        DailyWorkout(
          dayOfWeek: 'Sunday',
          focus: 'Rest & Recovery',
          durationMinutes: 0,
          isRestDay: true,
          imageAsset: 'assets/images/Symactive_10Kg_Adjustable_Dumbbell_Set___PVC_Weights_plus_14_Rod_Pair___Home_Workout_Kit___Black.jpg',
          blocks: [],
        ),
      ],
    );
  }
}

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository(
    generatorService: ref.watch(workoutGeneratorServiceProvider),
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final currentWorkoutPlanProvider = FutureProvider<WorkoutPlan?>((ref) async {
  return ref.read(workoutRepositoryProvider).getCurrentPlan();
});
