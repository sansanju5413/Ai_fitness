import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_fitness_app/core/services/base_ai_service.dart';
import 'package:ai_fitness_app/features/profile/models/user_profile.dart';
import 'package:ai_fitness_app/features/profile/repositories/profile_repository.dart';
import 'package:ai_fitness_app/features/session/repositories/session_repository.dart';
import 'package:ai_fitness_app/features/session/models/workout_session.dart';

class AiInsightsService extends BaseAiService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AiInsightsService(this._firestore, this._auth) : super();

  String? get _userId => _auth.currentUser?.uid;

  Future<String> generateDailySuggestion({
    required UserProfile? profile,
    required List<WorkoutSession> recentSessions,
  }) async {
    if (profile == null || _userId == null) {
      return 'Complete your profile setup to get personalized AI insights tailored to your fitness goals.';
    }

    // Check Firestore first for today's suggestion
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('daily_insights')
          .doc(dateStr)
          .get();
          
      if (doc.exists && doc.data() != null) {
        return doc.data()!['suggestion'] as String;
      }
    } catch (e) {
      print('[AiInsightsService] Error checking cache: $e');
    }
    if (profile == null) {
      return 'Complete your profile setup to get personalized AI insights tailored to your fitness goals.';
    }

    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    final completedSessions = recentSessions
        .where((s) => s.startTime.isAfter(last7Days) && s.isCompleted)
        .toList();

    final prompt = '''
You are a professional fitness AI coach. Generate a concise, motivational daily suggestion (1-2 sentences) for a user on their dashboard.

User Data:
- Goal: ${profile.fitnessProfile.primaryGoal}
- Level: ${profile.fitnessProfile.fitnessLevel}
- Workouts this week: ${completedSessions.length}
- Last workout: ${completedSessions.isEmpty ? 'None' : completedSessions.last.startTime.toIso8601String()}

Return ONLY a JSON object:
{
  "suggestion": "Your personalized message here"
}
''';

    try {
      print('[AiInsightsService] 📤 Generating daily suggestion...');
      final responseText = await generateJsonContent(prompt);
      
      if (responseText != null) {
        String cleanedText = responseText.trim();
        if (cleanedText.startsWith('```')) {
          cleanedText = cleanedText
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
        }
        final Map<String, dynamic> data = json.decode(cleanedText);
        final suggestion = data['suggestion'] as String?;
        
        if (suggestion != null) {
          // Save to Firestore
          await _firestore
              .collection('users')
              .doc(_userId)
              .collection('daily_insights')
              .doc(dateStr)
              .set({
            'suggestion': suggestion,
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          print('[AiInsightsService] ✅ Suggestion saved: $suggestion');
          return suggestion;
        }
      }
    } catch (e) {
      print('[AiInsightsService] ❌ Error generating suggestion: $e');
    }

    return _getStaticSuggestion(profile, completedSessions);
  }

  String _getStaticSuggestion(UserProfile profile, List<WorkoutSession> completedSessions) {
    if (completedSessions.isEmpty) {
      return 'Ready to start? Begin with a ${profile.fitnessProfile.fitnessLevel} workout today!';
    }
    return 'Great job on your ${completedSessions.length} workouts this week! Keep it up.';
  }

  String getMotivationalMessage(int streak) {
    if (streak == 0) return 'Every journey begins with a single step. Start today!';
    if (streak == 1) return 'Great start! Keep the momentum going.';
    return '$streak-day streak! Consistency is your superpower. 🔥';
  }
}

final aiInsightsServiceProvider = Provider<AiInsightsService>((ref) {
  return AiInsightsService(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final dailyAiSuggestionProvider = FutureProvider<String>((ref) async {
  final aiService = ref.watch(aiInsightsServiceProvider);
  final profile = ref.watch(profileStreamProvider).valueOrNull;
  
  final sessionsAsync = ref.watch(workoutSessionsStreamProvider);
  final sessions = sessionsAsync.valueOrNull ?? [];
  
  return aiService.generateDailySuggestion(
    profile: profile,
    recentSessions: sessions,
  );
});
