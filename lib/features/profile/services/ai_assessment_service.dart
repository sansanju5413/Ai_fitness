import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_ai_service.dart';
import '../models/user_profile.dart';

class AiAssessmentService extends BaseAiService {
  AiAssessmentService() : super();

  Future<String> generateAssessment(UserProfile profile) async {
    print('[AiAssessmentService] 📊 Generating assessment for ${profile.basicInfo.fullName}...');
    
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

Provide a detailed, encouraging assessment that includes:
1. Personalized goal analysis
2. Recommended workout strategy
3. Nutrition recommendations
4. Recovery and lifestyle tips
5. Motivational message

Write in a friendly, professional tone. Format with clear sections and bullet points.
''';

    try {
      final result = await generatePlainContent(prompt);
      
      if (result != null && result.isNotEmpty) {
        print('[AiAssessmentService] ✅ Assessment generated (${result.length} chars)');
        return result;
      }
      
      print('[AiAssessmentService] ⚠️ Empty response, using fallback');
      return _getFallbackAssessment(profile);
      
    } catch (e) {
      print('[AiAssessmentService] ❌ Error: $e');
      return _getFallbackAssessment(profile);
    }
  }

  String _getFallbackAssessment(UserProfile profile) {
    return '''
🎯 **Your Fitness Assessment**

Based on your goal of ${profile.fitnessProfile.primaryGoal}, here's your personalized plan:

**Current Status:**
• Weight: ${profile.bodyMetrics.weight}kg → Target: ${profile.bodyMetrics.targetWeight}kg
• Fitness Level: ${profile.fitnessProfile.fitnessLevel}
• Activity: ${profile.fitnessProfile.activityLevel}

**Recommended Approach:**
• Start with ${profile.fitnessProfile.fitnessLevel.toLowerCase()}-level workouts
• Focus on progressive overload
• Track your nutrition and stay consistent

**Next Steps:**
1. Complete your first workout
2. Log your meals daily
3. Check in weekly to track progress

Stay consistent and trust the process! 💪
''';
  }
}

final aiAssessmentServiceProvider = Provider<AiAssessmentService>((ref) {
  return AiAssessmentService();
});
