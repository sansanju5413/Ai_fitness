import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_ai_service.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../session/repositories/session_repository.dart';

class AiInsightsService extends BaseAiService {
  AiInsightsService() : super(model: 'gemini-1.5-flash');

  Future<String> generateDailySuggestion({
    required UserProfile? profile,
    required List<WorkoutSession> recentSessions,
  }) async {
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
      final responseText = await generateJsonContent(prompt);
      if (responseText != null) {
        String cleanedText = responseText.trim();
        if (cleanedText.startsWith('```')) {
            cleanedText = cleanedText
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
        }
        final Map<String, dynamic> data = jsonDecode(cleanedText);
        return data['suggestion'] ?? 'Keep pushing toward your ${profile.fitnessProfile.primaryGoal} goal!';
      }
    } catch (e) {
      // Fallback to static logic if AI fails
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
  return AiInsightsService();
});

final dailyAiSuggestionProvider = FutureProvider<String>((ref) async {
  final aiService = ref.watch(aiInsightsServiceProvider);
  final profile = ref.watch(profileStreamProvider).valueOrNull;
  
  // We need workoutSessionsStreamProvider which is in session_repository.dart
  // Usually it's better to watch the data if possible.
  final sessionsAsync = ref.watch(workoutSessionsStreamProvider);
  final sessions = sessionsAsync.valueOrNull ?? [];
  
  return aiService.generateDailySuggestion(
    profile: profile,
    recentSessions: sessions,
  );
});
