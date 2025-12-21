import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../profile/models/user_profile.dart';
import '../models/workout_plan.dart';

const String _kGeminiApiKey = 'AIzaSyBVWSJXVBqPGpMnXXiZt4BQ4VhaHs8IHOY';

class WorkoutGeneratorService {
  late final GenerativeModel _model;

  WorkoutGeneratorService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _kGeminiApiKey,
    );
  }

  Future<WorkoutPlan> generatePlan(
    UserProfile profile, {
    String? userNotes,
  }) async {
    try {
      // Construct comprehensive prompt
      final prompt = _constructPrompt(profile, userNotes: userNotes);
      
      // Call Gemini API
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null) {
        throw Exception('Failed to generate workout plan from AI');
      }

      // Cleanup potential markdown code blocks
      String cleanedText = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Try to extract JSON if wrapped in text
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanedText);
      if (jsonMatch != null) {
        cleanedText = jsonMatch.group(0)!;
      }

      // Parse JSON Response
      final Map<String, dynamic> jsonData = jsonDecode(cleanedText);
      
      // Convert to WorkoutPlan
      return _parseWorkoutPlan(jsonData, profile);
      
    } catch (e) {
      // Return fallback plan if AI fails
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
You are a professional fitness coach. Generate a personalized 7-day weekly workout plan in JSON format.

User Profile:
- Age: ${profile.basicInfo.age}, Gender: ${profile.basicInfo.gender}
- Height: ${profile.bodyMetrics.height}cm, Weight: ${profile.bodyMetrics.weight}kg, Target Weight: ${profile.bodyMetrics.targetWeight}kg
- Primary Goal: ${profile.fitnessProfile.primaryGoal}
- Fitness Level: ${profile.fitnessProfile.fitnessLevel}
- Activity Level: ${profile.fitnessProfile.activityLevel}
- Available Equipment: ${profile.fitnessProfile.availableEquipment.isEmpty ? 'Bodyweight only' : profile.fitnessProfile.availableEquipment.join(', ')}
- Workout Duration Preference: ${profile.fitnessProfile.durationPreference}
- Injuries/Limitations: ${profile.healthLifestyle.injuries.isEmpty ? 'None' : profile.healthLifestyle.injuries}
- Sleep Hours: ${profile.healthLifestyle.sleepHours}h/day
- Stress Level: ${profile.healthLifestyle.stressLevel}/10$extraNotes

Requirements:
1. Create a 7-day plan (Monday through Sunday)
2. Include 4-5 workout days and 2-3 rest days
3. Each workout should have:
   - Warmup block (2-3 exercises, 5-10 minutes)
   - Main workout blocks (3-5 exercises, 30-45 minutes)
   - Cooldown block (2-3 exercises, 5 minutes)
4. Rest days should be marked with isRestDay: true
5. Exercises should include: name, sets, reps (or durationSeconds for time-based), restSeconds, notes
6. Focus on progressive overload appropriate for ${profile.fitnessProfile.fitnessLevel} level
7. Consider the goal: ${profile.fitnessProfile.primaryGoal}

Return ONLY valid JSON in this exact format (no markdown, no explanations):
{
  "weeklySchedule": [
    {
      "dayOfWeek": "Monday",
      "focus": "Upper Body Strength",
      "durationMinutes": 45,
      "isRestDay": false,
      "isCompleted": false,
      "blocks": [
        {
          "type": "Warmup",
          "exercises": [
            {
              "name": "Arm Circles",
              "sets": 2,
              "reps": 20,
              "restSeconds": 0,
              "notes": "Forward and backward circles"
            }
          ]
        },
        {
          "type": "Main Lift",
          "exercises": [
            {
              "name": "Push-ups",
              "sets": 3,
              "reps": 12,
              "restSeconds": 60,
              "notes": "Keep core tight"
            }
          ]
        }
      ]
    }
  ]
}

Generate the complete 7-day plan now:
''';
  }

  WorkoutPlan _parseWorkoutPlan(Map<String, dynamic> jsonData, UserProfile profile) {
    final now = DateTime.now();
    final weeklySchedule = (jsonData['weeklySchedule'] as List?)
            ?.map((day) => DailyWorkout.fromJson(day))
            .toList() ??
        [];

    // Ensure we have 7 days
    if (weeklySchedule.length < 7) {
      // Fill missing days with rest days
      final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      for (int i = weeklySchedule.length; i < 7; i++) {
        weeklySchedule.add(DailyWorkout(
          dayOfWeek: daysOfWeek[i],
          focus: 'Rest Day',
          durationMinutes: 0,
          isRestDay: true,
          blocks: [],
        ));
      }
    }

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
                Exercise(name: 'Jumping Jacks', sets: 2, reps: 20, restSeconds: 30, notes: 'Warm up'),
              ],
            ),
            ExerciseBlock(
              type: 'Main Lift',
              exercises: [
                Exercise(name: 'Push-ups', sets: 3, reps: 12, restSeconds: 60, notes: 'Full body'),
                Exercise(name: 'Squats', sets: 3, reps: 15, restSeconds: 60, notes: 'Legs'),
              ],
            ),
          ],
        ),
        DailyWorkout(dayOfWeek: 'Tuesday', focus: 'Rest', durationMinutes: 0, isRestDay: true, blocks: []),
        DailyWorkout(
          dayOfWeek: 'Wednesday',
          focus: 'Upper Body',
          durationMinutes: 40,
          blocks: [
            ExerciseBlock(
              type: 'Main Lift',
              exercises: [
                Exercise(name: 'Push-ups', sets: 4, reps: 10, restSeconds: 60, notes: 'Chest'),
              ],
            ),
          ],
        ),
        DailyWorkout(dayOfWeek: 'Thursday', focus: 'Rest', durationMinutes: 0, isRestDay: true, blocks: []),
        DailyWorkout(
          dayOfWeek: 'Friday',
          focus: 'Lower Body',
          durationMinutes: 40,
          blocks: [
            ExerciseBlock(
              type: 'Main Lift',
              exercises: [
                Exercise(name: 'Squats', sets: 4, reps: 12, restSeconds: 90, notes: 'Legs'),
              ],
            ),
          ],
        ),
        DailyWorkout(dayOfWeek: 'Saturday', focus: 'Cardio', durationMinutes: 30, blocks: []),
        DailyWorkout(dayOfWeek: 'Sunday', focus: 'Rest', durationMinutes: 0, isRestDay: true, blocks: []),
      ],
    );
  }
}

final workoutGeneratorServiceProvider = Provider<WorkoutGeneratorService>((ref) {
  return WorkoutGeneratorService();
});
