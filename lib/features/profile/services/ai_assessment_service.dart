import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_ai_service.dart';
import '../models/user_profile.dart';

class AiAssessmentService extends BaseAiService {
  AiAssessmentService() : super(model: 'gemini-1.5-flash');

  Future<String> generateAssessment(UserProfile profile) async {
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

    final result = await generatePlainContent(prompt);
    return result ?? _getFallbackAssessment(profile);
  }

  String _getFallbackAssessment(UserProfile profile) {
    return 'Based on your goal of ${profile.fitnessProfile.primaryGoal}, we recommend a balanced approach to training and nutrition. Stay consistent and track your progress!';
  }
}

final aiAssessmentServiceProvider = Provider<AiAssessmentService>((ref) {
  return AiAssessmentService();
});
