import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_ai_service.dart';
import '../../profile/models/user_profile.dart';
import '../models/workout_plan.dart';

class WorkoutGeneratorService extends BaseAiService {
  WorkoutGeneratorService() : super();

  Future<WorkoutPlan> generatePlan(
    UserProfile profile, {
    String? userNotes,
  }) async {
    print('[WorkoutGenerator] 🏋️ Generating plan for ${profile.basicInfo.fullName}...');
    
    try {
      final prompt = _constructEnhancedPrompt(profile, userNotes: userNotes);
      
      // Limit to 3000 tokens - enough for 7 days with 3-5 exercises each
      final responseText = await generateJsonContent(prompt, maxTokens: 3000);

      if (responseText == null || responseText.isEmpty) {
        throw Exception('AI returned empty response');
      }

      print('[WorkoutGenerator] 📝 Parsing response...');
      final Map<String, dynamic> jsonData = jsonDecode(responseText);
      
      // Validate response structure
      if (!_validateWorkoutJson(jsonData)) {
        throw Exception('Invalid workout plan structure from AI');
      }
      
      final plan = _parseWorkoutPlan(jsonData, profile);
      print('[WorkoutGenerator] ✅ Plan generated with ${plan.weeklySchedule.length} days');
      
      // Validate that all exercises have proper steps
      _validateExerciseSteps(plan);
      
      return plan;
      
    } catch (e) {
      print('[WorkoutGenerator] ❌ Error generating plan: $e');
      print('[WorkoutGenerator] ⚠️ Using enhanced fallback plan');
      return _generateEnhancedFallbackPlan(profile);
    }
  }

  /// Generate a single day's workout for incremental/streaming generation.
  /// 
  /// This allows the UI to show progress as each day is generated.
  Future<DailyWorkout?> generateSingleDay(
    UserProfile profile, {
    required int dayIndex,
    String? userNotes,
  }) async {
    print('[WorkoutGenerator] 💪 Generating day ${dayIndex + 1}...');
    
    try {
      final prompt = _constructSingleDayPrompt(profile, dayIndex, userNotes);
      final responseText = await generateJsonContent(prompt, maxTokens: 800);
      
      if (responseText == null || responseText.isEmpty) {
        print('[WorkoutGenerator] ⚠️ Empty response for day ${dayIndex + 1}');
        return null;
      }
      
      final Map<String, dynamic> jsonData = jsonDecode(responseText);
      final day = DailyWorkout.fromJson(jsonData);
      print('[WorkoutGenerator] ✅ Day ${dayIndex + 1} generated: ${day.focus}');
      return day;
      
    } catch (e) {
      print('[WorkoutGenerator] ❌ Error generating day ${dayIndex + 1}: $e');
      return null;
    }
  }

  /// Construct a detailed prompt for generating a single day's workout.
  String _constructSingleDayPrompt(UserProfile profile, int dayIndex, String? userNotes) {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayFocuses = _getDayFocuses(profile.fitnessProfile.primaryGoal);
    
    final equipment = profile.fitnessProfile.availableEquipment.isEmpty 
        ? 'Bodyweight only' 
        : profile.fitnessProfile.availableEquipment.join(', ');
    
    final injuries = profile.healthLifestyle.injuries.isEmpty || profile.healthLifestyle.injuries == 'None'
        ? 'None'
        : profile.healthLifestyle.injuries;
    
    // Check if this should be a rest day
    final isRestDay = _shouldBeRestDay(dayIndex, profile.fitnessProfile.fitnessLevel);
    
    if (isRestDay) {
      return '''Generate a REST DAY JSON for ${dayNames[dayIndex]}:
{"dayOfWeek":"${dayNames[dayIndex]}","focus":"Rest & Recovery","durationMinutes":0,"isRestDay":true,"blocks":[]}
Return ONLY this JSON, no explanation.''';
    }
    
    final extraNotes = (userNotes != null && userNotes.trim().isNotEmpty) ? '\nNotes: $userNotes' : '';
    
    return '''Create a structured workout JSON for ${dayNames[dayIndex]} with the following profile:
- Age: ${profile.basicInfo.age}
- Fitness Level: ${profile.fitnessProfile.fitnessLevel}
- Primary Goal: ${profile.fitnessProfile.primaryGoal}
- Focus Area: ${dayFocuses[dayIndex]}
- Available Equipment: $equipment
- Injuries/Limitations: $injuries
$extraNotes

JSON STRUCTURE (Return ONLY the JSON):
{
  "dayOfWeek": "${dayNames[dayIndex]}",
  "focus": "${dayFocuses[dayIndex]}",
  "durationMinutes": 45,
  "isRestDay": false,
  "blocks": [
    {
      "type": "Warmup",
      "exercises": [
        {"name": "Dynamic Stretch", "sets": 2, "reps": 10, "restSeconds": 30, "notes": "Gentle movement"}
      ]
    },
    {
      "type": "Main",
      "exercises": [
        {"name": "Primary Exercise", "sets": 3, "reps": 12, "restSeconds": 60, "notes": "Focus on form"}
      ]
    },
    {
      "type": "Cooldown",
      "exercises": [
        {"name": "Static Stretch", "sets": 1, "reps": 1, "durationSeconds": 30, "restSeconds": 0, "notes": "Relax"}
      ]
    }
  ]
}

IMPORTANT: Ensure "blocks" is a list containing "Warmup", "Main", and "Cooldown" types. Each block MUST have an "exercises" list. Return valid JSON only.''';
  }

  /// Get focus areas for each day based on goal
  List<String> _getDayFocuses(String goal) {
    switch (goal.toLowerCase()) {
      case 'weight loss':
        return ['Full Body HIIT', 'Rest', 'Upper Body', 'Cardio', 'Lower Body', 'Active Recovery', 'Rest'];
      case 'muscle building':
        return ['Chest & Triceps', 'Back & Biceps', 'Rest', 'Legs & Glutes', 'Shoulders & Arms', 'Full Body', 'Rest'];
      case 'strength training':
        return ['Push Day', 'Pull Day', 'Rest', 'Legs', 'Upper Body', 'Rest', 'Active Recovery'];
      case 'flexibility':
        return ['Full Body Stretch', 'Yoga Flow', 'Rest', 'Lower Body Mobility', 'Upper Body Mobility', 'Active Recovery', 'Rest'];
      default:
        return ['Full Body', 'Upper Body', 'Rest', 'Lower Body', 'Core & Cardio', 'Active Recovery', 'Rest'];
    }
  }

  /// Determine if a day should be a rest day based on index and fitness level
  bool _shouldBeRestDay(int dayIndex, String fitnessLevel) {
    // Beginners get more rest
    if (fitnessLevel == 'Beginner') {
      return dayIndex == 1 || dayIndex == 3 || dayIndex == 6; // Tue, Thu, Sun
    }
    // Others get 2 rest days
    return dayIndex == 2 || dayIndex == 6; // Wed, Sun
  }
  String _constructEnhancedPrompt(
    UserProfile profile, {
    String? userNotes,
  }) {
    final equipment = profile.fitnessProfile.availableEquipment.isEmpty 
        ? 'Bodyweight only (no equipment)' 
        : profile.fitnessProfile.availableEquipment.join(', ');
        
    final injuries = profile.healthLifestyle.injuries.isEmpty
        ? 'None'
        : profile.healthLifestyle.injuries;
    
    final extraNotes = (userNotes != null && userNotes.trim().isNotEmpty)
        ? 'Notes: $userNotes'
        : '';

    // Minimal prompt - only essential data needed by the app
    return '''Generate 7-day workout plan JSON for:
Goal: ${profile.fitnessProfile.primaryGoal}
Level: ${profile.fitnessProfile.fitnessLevel}
Equipment: $equipment
$extraNotes

Format:
{"weeklySchedule":[
{"dayOfWeek":"Monday","focus":"Upper Body","durationMinutes":45,"isRestDay":false,"blocks":[
{"type":"Main","exercises":[{"name":"Push-ups","sets":3,"reps":12,"restSeconds":60,"notes":"Keep core tight"}]}
]}
]}

Return ONLY JSON with 7 days. Each day has blocks (Warmup/Main/Cooldown) with exercises.
Include 2-3 rest days. Keep exercises simple: name, sets, reps, restSeconds, notes.''';
  }

  bool _validateWorkoutJson(Map<String, dynamic> json) {
    if (!json.containsKey('weeklySchedule')) {
      print('[WorkoutGenerator] ❌ Missing weeklySchedule key');
      return false;
    }
    
    final schedule = json['weeklySchedule'];
    if (schedule is! List || schedule.length != 7) {
      print('[WorkoutGenerator] ❌ weeklySchedule must be a list of 7 days');
      return false;
    }
    
    return true;
  }

  void _validateExerciseSteps(WorkoutPlan plan) {
    for (final day in plan.weeklySchedule) {
      if (day.isRestDay) continue;
      
      for (final block in day.blocks) {
        for (final exercise in block.exercises) {
          if (exercise.steps == null || exercise.steps!.isEmpty) {
            print('[WorkoutGenerator] ⚠️ Exercise "${exercise.name}" has no steps');
          } else if (exercise.steps!.length < 3) {
            print('[WorkoutGenerator] ⚠️ Exercise "${exercise.name}" has only ${exercise.steps!.length} steps (should have 3-5)');
          }
        }
      }
    }
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

  WorkoutPlan _generateEnhancedFallbackPlan(UserProfile profile) {
    final now = DateTime.now();
    final isBeginnerLevel = profile.fitnessProfile.fitnessLevel == 'Beginner';
    
    return WorkoutPlan(
      id: 'fallback_plan_${now.millisecondsSinceEpoch}',
      userId: profile.uid,
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
      goal: profile.fitnessProfile.primaryGoal,
      weeklySchedule: _buildFallbackSchedule(isBeginnerLevel),
    );
  }

  List<DailyWorkout> _buildFallbackSchedule(bool isBeginnerLevel) {
    return [
      // Monday - Full Body
      DailyWorkout(
        dayOfWeek: 'Monday',
        focus: 'Full Body Strength',
        durationMinutes: isBeginnerLevel ? 35 : 50,
        blocks: [
          ExerciseBlock(
            type: 'Warmup',
            exercises: [
              Exercise(
                name: 'Jumping Jacks',
                sets: 2,
                reps: 20,
                restSeconds: 30,
                notes: 'Warm up your entire body',
                steps: [
                  'Stand with feet together, arms at sides',
                  'Jump while spreading legs shoulder-width apart and raising arms overhead',
                  'Jump back to starting position',
                  'Maintain steady rhythm and breathe naturally',
                  'Keep core engaged throughout'
                ],
              ),
              Exercise(
                name: 'Arm Circles',
                sets: 2,
                reps: 15,
                restSeconds: 20,
                notes: 'Forward and backward',
                steps: [
                  'Stand with arms extended to sides at shoulder height',
                  'Make small circles forward for 15 reps',
                  'Reverse direction for 15 reps',
                  'Keep shoulders relaxed',
                  'Gradually increase circle size'
                ],
              ),
            ],
          ),
          ExerciseBlock(
            type: 'Main',
            exercises: [
              Exercise(
                name: 'Bodyweight Squats',
                sets: isBeginnerLevel ? 3 : 4,
                reps: isBeginnerLevel ? 12 : 15,
                restSeconds: 60,
                notes: 'Focus on depth and control',
                steps: [
                  'Stand with feet shoulder-width apart, toes slightly out',
                  'Push hips back and bend knees to lower down',
                  'Keep chest up and core tight throughout',
                  'Lower until thighs are parallel to ground',
                  'Push through heels to return to standing'
                ],
              ),
              Exercise(
                name: 'Push-ups',
                sets: isBeginnerLevel ? 3 : 4,
                reps: isBeginnerLevel ? 8 : 12,
                restSeconds: 60,
                notes: 'Modify on knees if needed',
                steps: [
                  'Start in high plank position, hands slightly wider than shoulders',
                  'Keep body in straight line from head to heels',
                  'Lower chest toward ground by bending elbows',
                  'Keep elbows at 45-degree angle from body',
                  'Push back up to starting position'
                ],
              ),
              Exercise(
                name: 'Lunges',
                sets: 3,
                reps: 10,
                restSeconds: 45,
                notes: '10 reps per leg',
                steps: [
                  'Stand tall with feet hip-width apart',
                  'Step forward with right foot, lowering hips',
                  'Both knees should bend to 90 degrees',
                  'Front knee stays behind toes',
                  'Push through front heel to return'
                ],
              ),
              Exercise(
                name: 'Plank',
                sets: 3,
                reps: 1,
                durationSeconds: 30,
                restSeconds: 45,
                notes: 'Hold for 30 seconds',
                steps: [
                  'Start in forearm plank position',
                  'Keep body in straight line from head to heels',
                  'Engage core and squeeze glutes',
                  'Breathe steadily throughout',
                  'Do not let hips sag or pike up'
                ],
              ),
            ],
          ),
          ExerciseBlock(
            type: 'Cooldown',
            exercises: [
              Exercise(
                name: 'Standing Quad Stretch',
                sets: 1,
                reps: 2,
                durationSeconds: 30,
                restSeconds: 10,
                notes: 'Hold each leg for 30 seconds',
                steps: [
                  'Stand on one leg, use wall for balance if needed',
                  'Bend other knee and grab ankle behind you',
                  'Pull heel toward glutes gently',
                  'Keep knees together and hips forward',
                  'Hold stretch without bouncing'
                ],
              ),
            ],
          ),
        ],
      ),
      
      // Tuesday - Rest Day
      DailyWorkout(
        dayOfWeek: 'Tuesday',
        focus: 'Active Recovery',
        durationMinutes: 0,
        isRestDay: true,
        blocks: [],
      ),
      
      // Wednesday - Upper Body
      DailyWorkout(
        dayOfWeek: 'Wednesday',
        focus: 'Upper Body',
        durationMinutes: isBeginnerLevel ? 30 : 45,
        blocks: [
          ExerciseBlock(
            type: 'Warmup',
            exercises: [
              Exercise(
                name: 'Arm Swings',
                sets: 2,
                reps: 15,
                restSeconds: 20,
                notes: 'Front to back',
                steps: [
                  'Stand with feet shoulder-width apart',
                  'Swing both arms forward and up',
                  'Swing arms back and down',
                  'Use controlled, fluid movements',
                  'Increase range of motion gradually'
                ],
              ),
            ],
          ),
          ExerciseBlock(
            type: 'Main',
            exercises: [
              Exercise(
                name: 'Diamond Push-ups',
                sets: 3,
                reps: isBeginnerLevel ? 6 : 10,
                restSeconds: 60,
                notes: 'Targets triceps and chest',
                steps: [
                  'Start in push-up position',
                  'Place hands close together forming diamond shape with fingers',
                  'Lower body keeping elbows close to sides',
                  'Keep core tight and back straight',
                  'Push back up to starting position'
                ],
              ),
              Exercise(
                name: 'Pike Push-ups',
                sets: 3,
                reps: isBeginnerLevel ? 8 : 12,
                restSeconds: 60,
                notes: 'Targets shoulders',
                steps: [
                  'Start in downward dog position (hips high)',
                  'Keep legs straight, bend at hips',
                  'Lower head toward ground between hands',
                  'Push back up using shoulders and triceps',
                  'Maintain inverted V shape throughout'
                ],
              ),
              Exercise(
                name: 'Superman Hold',
                sets: 3,
                reps: isBeginnerLevel ? 8 : 12,
                restSeconds: 45,
                notes: 'Targets back muscles',
                steps: [
                  'Lie face down with arms extended overhead',
                  'Simultaneously lift arms, chest, and legs off ground',
                  'Squeeze back muscles at the top',
                  'Hold for 2-3 seconds',
                  'Lower with control'
                ],
              ),
            ],
          ),
          ExerciseBlock(
            type: 'Cooldown',
            exercises: [
              Exercise(
                name: 'Shoulder Stretch',
                sets: 2,
                reps: 1,
                durationSeconds: 30,
                restSeconds: 10,
                notes: 'Each arm',
                steps: [
                  'Pull one arm across body',
                  'Use other arm to gently press',
                  'Keep shoulders relaxed',
                  'Hold steady stretch',
                  'Switch arms and repeat'
                ],
              ),
            ],
          ),
        ],
      ),
      
      // Thursday - Rest Day
      DailyWorkout(
        dayOfWeek: 'Thursday',
        focus: 'Rest',
        durationMinutes: 0,
        isRestDay: true,
        blocks: [],
      ),
      
      // Friday - Lower Body
      DailyWorkout(
        dayOfWeek: 'Friday',
        focus: 'Lower Body',
        durationMinutes: isBeginnerLevel ? 35 : 50,
        blocks: [
          ExerciseBlock(
            type: 'Warmup',
            exercises: [
              Exercise(
                name: 'Leg Swings',
                sets: 2,
                reps: 15,
                restSeconds: 20,
                notes: 'Forward and side to side',
                steps: [
                  'Hold wall or chair for support',
                  'Swing one leg forward and back',
                  'Keep leg straight but not locked',
                  'Switch to side-to-side swings',
                  'Repeat on other leg'
                ],
              ),
            ],
          ),
          ExerciseBlock(
            type: 'Main',
            exercises: [
              Exercise(
                name: 'Bulgarian Split Squats',
                sets: 3,
                reps: 10,
                restSeconds: 60,
                notes: 'Per leg, use chair',
                steps: [
                  'Place rear foot on chair or bench',
                  'Front foot 2-3 feet forward',
                  'Lower down by bending front knee',
                  'Keep front knee behind toes',
                  'Push through front heel to stand'
                ],
              ),
              Exercise(
                name: 'Glute Bridges',
                sets: 3,
                reps: 15,
                restSeconds: 45,
                notes: 'Squeeze glutes at top',
                steps: [
                  'Lie on back with knees bent, feet flat',
                  'Place feet hip-width apart near glutes',
                  'Push through heels to lift hips up',
                  'Squeeze glutes hard at top',
                  'Lower with control'
                ],
              ),
              Exercise(
                name: 'Calf Raises',
                sets: 3,
                reps: 20,
                restSeconds: 30,
                notes: 'Can use step for more range',
                steps: [
                  'Stand with feet hip-width apart',
                  'Rise up onto toes as high as possible',
                  'Hold for 1 second at top',
                  'Lower with control',
                  'Use wall for balance if needed'
                ],
              ),
            ],
          ),
          ExerciseBlock(
            type: 'Cooldown',
            exercises: [
              Exercise(
                name: 'Seated Hamstring Stretch',
                sets: 2,
                reps: 1,
                durationSeconds: 30,
                restSeconds: 10,
                notes: 'Each leg',
                steps: [
                  'Sit with one leg extended',
                  'Bend other leg with foot against inner thigh',
                  'Reach toward extended foot',
                  'Keep back straight',
                  'Feel stretch in hamstring of extended leg'
                ],
              ),
            ],
          ),
        ],
      ),
      
      // Saturday - Active Recovery
      DailyWorkout(
        dayOfWeek: 'Saturday',
        focus: 'Active Recovery',
        durationMinutes: 20,
        blocks: [
          ExerciseBlock(
            type: 'Main',
            exercises: [
              Exercise(
                name: 'Light Walk or Yoga',
                sets: 1,
                reps: 1,
                durationSeconds: 1200,
                restSeconds: 0,
                notes: '20 minutes of gentle movement',
                steps: [
                  'Choose light activity you enjoy',
                  'Walk at comfortable pace',
                  'Or do gentle yoga/stretching',
                  'Focus on mobility and recovery',
                  'Keep intensity low'
                ],
              ),
            ],
          ),
        ],
      ),
      
      // Sunday - Rest Day
      DailyWorkout(
        dayOfWeek: 'Sunday',
        focus: 'Complete Rest',
        durationMinutes: 0,
        isRestDay: true,
        blocks: [],
      ),
    ];
  }
}

final workoutGeneratorServiceProvider = Provider<WorkoutGeneratorService>((ref) {
  return WorkoutGeneratorService();
});
