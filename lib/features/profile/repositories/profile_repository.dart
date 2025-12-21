
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

const String _kGeminiApiKey = 'AIzaSyBVWSJXVBqPGpMnXXiZt4BQ4VhaHs8IHOY';

class ProfileRepository {
  late final GenerativeModel _model;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRepository(this._firestore, this._auth) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _kGeminiApiKey,
    );
  }

  String? get _userId => _auth.currentUser?.uid;

  Future<void> saveProfile(UserProfile profile) async {
    if (_userId == null) {
      throw Exception('User must be logged in to save profile');
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .set(profile.toJson(), SetOptions(merge: true));
  }

  Future<UserProfile?> getProfile() async {
    if (_userId == null) {
      return null;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  Stream<UserProfile?> watchProfile() {
    if (_userId == null) {
      return Stream.value(null);
    }

    try {
      return _firestore
          .collection('users')
          .doc(_userId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return null;
        }
        try {
          return UserProfile.fromJson(snapshot.data()!);
        } catch (e) {
          return null;
        }
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  Future<String> generateAiAssessment(UserProfile profile) async {
    try {
      final prompt = '''
You are a professional fitness and nutrition coach. Analyze this user profile and provide a comprehensive, personalized assessment.

User Profile:
- Name: ${profile.basicInfo.fullName}
- Age: ${profile.basicInfo.age}, Gender: ${profile.basicInfo.gender}
- Height: ${profile.bodyMetrics.height}cm
- Current Weight: ${profile.bodyMetrics.weight}kg
- Target Weight: ${profile.bodyMetrics.targetWeight}kg
- Body Type: ${profile.bodyMetrics.bodyType}

Fitness Profile:
- Primary Goal: ${profile.fitnessProfile.primaryGoal}
- Fitness Level: ${profile.fitnessProfile.fitnessLevel}
- Activity Level: ${profile.fitnessProfile.activityLevel}
- Available Equipment: ${profile.fitnessProfile.availableEquipment.isEmpty ? 'Bodyweight only' : profile.fitnessProfile.availableEquipment.join(', ')}
- Workout Duration: ${profile.fitnessProfile.durationPreference}

Nutrition Profile:
- Dietary Preference: ${profile.nutritionProfile.dietaryPreference}
- Allergies: ${profile.nutritionProfile.allergies.isEmpty ? 'None' : profile.nutritionProfile.allergies.join(', ')}
- Meals Per Day: ${profile.nutritionProfile.mealsPerDay}
- Water Intake Goal: ${profile.nutritionProfile.waterIntakeGoal}L

Health & Lifestyle:
- Medical Conditions: ${profile.healthLifestyle.medicalConditions.isEmpty ? 'None' : profile.healthLifestyle.medicalConditions.join(', ')}
- Injuries: ${profile.healthLifestyle.injuries.isEmpty ? 'None' : profile.healthLifestyle.injuries}
- Sleep Hours: ${profile.healthLifestyle.sleepHours}h/day
- Stress Level: ${profile.healthLifestyle.stressLevel}/10

Provide a detailed, encouraging assessment that includes:
1. Personalized goal analysis (is it realistic? timeline?)
2. Recommended workout strategy (frequency, intensity, focus areas)
3. Nutrition recommendations (calorie target, macro split, meal timing)
4. Recovery and lifestyle tips (sleep, stress management)
5. Key milestones and expectations
6. Motivational message

Write in a friendly, professional tone. Format with clear sections and bullet points where appropriate.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null) {
        throw Exception('Failed to generate AI assessment');
      }

      return responseText;
    } catch (e) {
      // Return fallback assessment
      return '''
Based on your profile, here is your personalized assessment:

Your goal of ${profile.fitnessProfile.primaryGoal} is achievable with a consistent plan. 
As a ${profile.bodyMetrics.bodyType}, we will focus on ${profile.fitnessProfile.primaryGoal == 'Muscle Gain' ? 'hypertrophy and caloric surplus' : 'metabolic conditioning and caloric deficit'}.

Recommended Strategy:
- Workout split: ${profile.fitnessProfile.durationPreference} sessions, ${profile.fitnessProfile.fitnessLevel == 'Beginner' ? '3x' : '4-5x'} per week.
- Nutrition: Focus on high protein intake and moderate carbs.
- Water: Aim for ${profile.nutritionProfile.waterIntakeGoal}L daily.
- Recovery: Ensure ${profile.healthLifestyle.sleepHours}h of quality sleep.
''';
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});
