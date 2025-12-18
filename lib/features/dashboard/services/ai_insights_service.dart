import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/models/user_profile.dart';
import '../../session/repositories/session_repository.dart';

class AiInsightsService {
  String generateDailySuggestion({
    required UserProfile? profile,
    required List<WorkoutSession> recentSessions,
  }) {
    if (profile == null) {
      return 'Complete your profile setup to get personalized AI insights tailored to your fitness goals.';
    }

    final goal = profile.fitnessProfile.primaryGoal;
    final level = profile.fitnessProfile.fitnessLevel;
    
    // Check recent activity (last 7 days)
    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    final recentWorkouts = recentSessions
        .where((s) => s.startTime.isAfter(last7Days) && s.isCompleted)
        .length;
    
    // Check today's activity
    final today = DateTime(now.year, now.month, now.day);
    final workoutToday = recentSessions.any((s) {
      final sessionDay = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
      return sessionDay == today && s.isCompleted;
    });

    // Generate contextual suggestion
    if (workoutToday) {
      return 'Great work today! 💪 You\'ve completed your workout. Consider some light stretching or a walk to aid recovery. Stay hydrated!';
    }

    if (recentWorkouts == 0) {
      return 'Ready to start your fitness journey? Begin with a $level-level workout focusing on ${goal.toLowerCase()}. Consistency is key!';
    }

    if (recentWorkouts < 2) {
      return 'You\'ve worked out $recentWorkouts time this week. Aim for 3-4 sessions to see progress toward your $goal goal. You\'ve got this!';
    }

    if (recentWorkouts >= 3 && recentWorkouts < 5) {
      return 'Excellent consistency! $recentWorkouts workouts this week. To maximize your $goal results, maintain this rhythm and ensure adequate rest.';
    }

    if (recentWorkouts >= 5) {
      return 'Outstanding effort with $recentWorkouts workouts! For optimal recovery and muscle growth, consider taking a rest day. Listen to your body.';
    }

    // Default suggestion based on fitness level
    final suggestions = {
      'beginner': 'Focus on form over intensity. Aim for 3 full-body workouts this week with rest days in between.',
      'intermediate': 'Challenge yourself with progressive overload. Add weight or reps to your key lifts this week.',
      'advanced': 'Optimize your training split and nutrition. Track your volume and ensure you\'re recovering adequately.',
    };

    final levelSuggestion = suggestions[level.toLowerCase()] ?? 
        'Stay consistent with your training and track your progress!';

    return '$levelSuggestion Your goal: $goal.';
  }

  String getMotivationalMessage(int streak) {
    if (streak == 0) {
      return 'Every journey begins with a single step. Start today!';
    }
    if (streak == 1) {
      return 'Great start! Keep the momentum going.';
    }
    if (streak < 7) {
      return '$streak-day streak! You\'re building a habit.';
    }
    if (streak < 30) {
      return '$streak days strong! Consistency is your superpower.';
    }
    return '$streak-day streak! You\'re unstoppable! 🔥';
  }
}

final aiInsightsServiceProvider = Provider<AiInsightsService>((ref) {
  return AiInsightsService();
});
