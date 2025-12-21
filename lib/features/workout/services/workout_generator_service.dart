import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_ai_service.dart';
import '../../profile/models/user_profile.dart';
import '../models/workout_plan.dart';

class WorkoutGeneratorService extends BaseAiService {
  WorkoutGeneratorService() : super(model: 'gemini-1.5-flash');

  Future<WorkoutPlan> generatePlan(
    UserProfile profile, {
    String? userNotes,
  }) async {
    try {
      final prompt = _constructPrompt(profile, userNotes: userNotes);
      
      final responseText = await generateJsonContent(prompt);

      if (responseText == null) {
        throw Exception('AI returned empty response');
      }

      // With JSON mode enabled in BaseAiService, responseText SHOULD be clean JSON.
      // However, we still do a basic cleanup just in case.
      String cleanedText = responseText.trim();
      if (cleanedText.startsWith('```')) {
          cleanedText = cleanedText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      }

      final Map<String, dynamic> jsonData = jsonDecode(cleanedText);
      return _parseWorkoutPlan(jsonData, profile);
      
    } catch (e) {
      // In a real app, you might want to log this to Crashlytics/Sentry
      return _generateFallbackPlan(profile);
    }
  }

  String _constructPrompt(
    UserProfile profile, {
    String? userNotes,
  }) {
    final extraNotes = (userNotes != null && userNotes.trim().isNotEmpty)
        ? '\n\nUser Preferences / Constraints:\n$userNotes\n'
        : '';

    return '''
Generate a personalized 7-day weekly workout plan in JSON format.
Return ONLY valid JSON that matches the specified structure. Do not include markdown formatting or extra text.

User Profile:
- Age: ${profile.basicInfo.age}, Gender: ${profile.basicInfo.gender}
- Goal: ${profile.fitnessProfile.primaryGoal}
- Level: ${profile.fitnessProfile.fitnessLevel}
- Equipment: ${profile.fitnessProfile.availableEquipment.isEmpty ? 'None' : profile.fitnessProfile.availableEquipment.join(', ')}
- Injuries: ${profile.healthLifestyle.injuries}$extraNotes

Requirements:
1. 7-day plan (Monday - Sunday). 4-5 workout days, 2-3 rest days.
2. Each exercise MUST have: name, sets, reps (or durationSeconds: int), restSeconds (int), notes, and "steps" (list of strings).
3. "steps" should be 3-5 detailed instructional steps.

JSON Structure:
{
  "weeklySchedule": [
    {
      "dayOfWeek": "string",
      "focus": "string",
      "durationMinutes": int,
      "isRestDay": bool,
      "blocks": [
        {
          "type": "Warmup|Main Lift|Cooldown",
          "exercises": [
            {
              "name": "string",
              "sets": int,
              "reps": int,
              "restSeconds": int,
              "notes": "string",
              "steps": ["step 1", "step 2", "step 3"]
            }
          ]
        }
      ]
    }
  ]
}

CRITICAL: For every exercise, you MUST provide at least 3-5 detailed, clear instruction steps in the "steps" array. 
The steps should focus on form, breathing, and movement.
Do not skip the "steps" array.
''';
  }

  WorkoutPlan _parseWorkoutPlan(Map<String, dynamic> jsonData, UserProfile profile) {
    final now = DateTime.now();
    final weeklySchedule = (jsonData['weeklySchedule'] as List?)
            ?.map((day) => DailyWorkout.fromJson(day))
            .toList() ??
        [];

    return WorkoutPlan(
      id: 'ai_plan_${now.millisecondsSinceEpoch}',
      userId: profile.uid,
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
      goal: profile.fitnessProfile.primaryGoal,
      weeklySchedule: weeklySchedule,
    );
  }

  WorkoutPlan _generateFallbackPlan(UserProfile profile) {
    final now = DateTime.now();
    return WorkoutPlan(
      id: 'fallback_plan_${now.millisecondsSinceEpoch}',
      userId: profile.uid,
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
      goal: profile.fitnessProfile.primaryGoal,
      weeklySchedule: [
        DailyWorkout(
          dayOfWeek: 'Monday',
          focus: 'Full Body',
          durationMinutes: 45,
          blocks: [
            ExerciseBlock(
              type: 'Warmup',
              exercises: [
                Exercise(name: 'Jumping Jacks', sets: 2, reps: 20, restSeconds: 30, notes: 'Warm up', steps: ['Stand with feet together', 'Jump and spread legs while clapping hands overhead', 'Jump back to start']),
              ],
            ),
          ],
        ),
        // Simplification for brevity in fallback
        DailyWorkout(dayOfWeek: 'Tuesday', focus: 'Rest', durationMinutes: 0, isRestDay: true, blocks: []),
        DailyWorkout(dayOfWeek: 'Wednesday', focus: 'Upper Body', durationMinutes: 40, blocks: []),
        DailyWorkout(dayOfWeek: 'Thursday', focus: 'Rest', durationMinutes: 0, isRestDay: true, blocks: []),
        DailyWorkout(dayOfWeek: 'Friday', focus: 'Lower Body', durationMinutes: 40, blocks: []),
        DailyWorkout(dayOfWeek: 'Saturday', focus: 'Rest', durationMinutes: 0, isRestDay: true, blocks: []),
        DailyWorkout(dayOfWeek: 'Sunday', focus: 'Rest', durationMinutes: 0, isRestDay: true, blocks: []),
      ],
    );
  }
}

final workoutGeneratorServiceProvider = Provider<WorkoutGeneratorService>((ref) {
  return WorkoutGeneratorService();
});
