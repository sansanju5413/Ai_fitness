import 'workout_plan.dart';

final List<DailyWorkout> predefinedWorkouts = [
  DailyWorkout(
    dayOfWeek: 'Custom',
    focus: 'Chest Specialist',
    durationMinutes: 45,
    imageAsset: 'assets/workouts/chest.png',
    blocks: [
      ExerciseBlock(
        type: 'Warmup',
        exercises: [
          Exercise(
            name: 'Arm Circles',
            sets: 2,
            reps: 20,
            restSeconds: 30,
            notes: 'Loosen up shoulder joints',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0002.mp4',
            steps: [
              'Stand tall with your feet shoulder-width apart.',
              'Extend your arms straight out to the sides at shoulder height.',
              'Make small, controlled circular motions with your arms.',
              'Slowly increase the size of the circles to loosen the joints.'
            ],
          ),
          Exercise(
            name: 'Push-up (Dynamic)',
            sets: 2,
            reps: 10,
            restSeconds: 30,
            notes: 'Prime the chest muscles',
            steps: [
              'Get into a high plank position with hands slightly wider than shoulders.',
              'Lower your body until your chest nearly touches the floor.',
              'Push back up explosively while maintaining a straight line from head to heels.',
              'Focus on the mind-muscle connection with your chest.'
            ],
          ),
        ],
      ),
      ExerciseBlock(
        type: 'Main Work',
        exercises: [
          Exercise(
            name: 'Incline Bench Press',
            sets: 4,
            reps: 10,
            restSeconds: 90,
            notes: 'Focus on upper chest. Control the weight.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0003.mp4',
            steps: [
              'Lie back on an incline bench set to 30-45 degrees.',
              'Grip the barbell slightly wider than shoulder-width.',
              'Lower the bar slowly to your upper chest.',
              'Press the bar back up to the starting position without locking elbows.'
            ],
          ),
          Exercise(
            name: 'Dumbbell Flyes',
            sets: 3,
            reps: 12,
            restSeconds: 60,
            notes: 'Deep stretch at the bottom.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0004.mp4',
            steps: [
              'Lie on a flat bench holding dumbbells above your chest.',
              'Lower the weights out to your sides in a wide arc.',
              'Maintain a slight bend in your elbows throughout.',
              'Squeeze your chest muscles to bring the weights back together.'
            ],
          ),
          Exercise(
            name: 'Cable Crossover',
            sets: 3,
            reps: 15,
            restSeconds: 60,
            notes: 'Squeeze hard at the peak contraction.',
          ),
        ],
      ),
      ExerciseBlock(
        type: 'Cooldown',
        exercises: [
          Exercise(
            name: 'Chest Stretch',
            sets: 1,
            reps: 60,
            durationSeconds: 60,
            restSeconds: 0,
            notes: 'Hold each side against a doorway.',
          ),
        ],
      ),
    ],
  ),
  DailyWorkout(
    dayOfWeek: 'Custom',
    focus: 'Back Dominance',
    durationMinutes: 50,
    imageAsset: 'assets/workouts/back.png',
    blocks: [
      ExerciseBlock(
        type: 'Warmup',
        exercises: [
          Exercise(
            name: 'Cat-Cow',
            sets: 2,
            reps: 12,
            restSeconds: 30,
            notes: 'Mobilize the spine.',
          ),
        ],
      ),
      ExerciseBlock(
        type: 'Main Work',
        exercises: [
          Exercise(
            name: 'Deadlift',
            sets: 3,
            reps: 5,
            restSeconds: 150,
            notes: 'Classic power move. Keep back flat.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0020.mp4',
            steps: [
              'Stand with feet hip-width apart, barbell over mid-foot.',
              'Bend at hips and knees to grip the bar with a flat back.',
              'Lift the bar by extending hips and knees to a full standing position.',
              'Lower the bar under control back to the floor.'
            ],
          ),
          Exercise(
            name: 'Lat Pulldown',
            sets: 4,
            reps: 10,
            restSeconds: 75,
            notes: 'Pull with your elbows.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0028.mp4',
          ),
          Exercise(
            name: 'Seated Cable Row',
            sets: 3,
            reps: 12,
            restSeconds: 60,
            notes: 'Bring handle to your lower abdomen.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0029.mp4',
          ),
        ],
      ),
      ExerciseBlock(
        type: 'Cooldown',
        exercises: [
          Exercise(
            name: 'Child\'s Pose',
            sets: 1,
            reps: 60,
            durationSeconds: 60,
            restSeconds: 0,
            notes: 'Relax the lower back.',
          ),
        ],
      ),
    ],
  ),
  DailyWorkout(
    dayOfWeek: 'Custom',
    focus: 'Leg Powerhouse',
    durationMinutes: 60,
    imageAsset: 'assets/workouts/upperlegs.jpg',
    blocks: [
      ExerciseBlock(
        type: 'Warmup',
        exercises: [
          Exercise(
            name: 'Bodyweight Squats',
            sets: 2,
            reps: 15,
            restSeconds: 30,
            notes: 'Warm up the knees.',
          ),
        ],
      ),
      ExerciseBlock(
        type: 'Main Work',
        exercises: [
          Exercise(
            name: 'Barbell Back Squat',
            sets: 4,
            reps: 8,
            restSeconds: 120,
            notes: 'Go below parallel if possible.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0031.mp4',
            steps: [
              'Rest the barbell on your upper traps, feet shoulder-width apart.',
              'Lower your hips by bending knees and pushing hips back.',
              'Descend until thighs are at least parallel to the floor.',
              'Drive back up to the starting position through your heels.'
            ],
          ),
          Exercise(
            name: 'Leg Press',
            sets: 3,
            reps: 12,
            restSeconds: 90,
            notes: 'Explode up, controlled down.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0034.mp4',
          ),
          Exercise(
            name: 'Walking Lunges',
            sets: 3,
            reps: 20,
            restSeconds: 60,
            notes: '10 steps per leg.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0042.mp4',
          ),
        ],
      ),
      ExerciseBlock(
        type: 'Cooldown',
        exercises: [
          Exercise(
            name: 'Quad (Couch) Stretch',
            sets: 1,
            reps: 45,
            durationSeconds: 45,
            restSeconds: 0,
            notes: 'Per leg.',
          ),
        ],
      ),
    ],
  ),
  DailyWorkout(
    dayOfWeek: 'Custom',
    focus: 'Shoulder Boulder',
    durationMinutes: 40,
    imageAsset: 'assets/workouts/shoulders.png',
    blocks: [
      ExerciseBlock(
        type: 'Warmup',
        exercises: [
          Exercise(
            name: 'Face Pulls (Light)',
            sets: 2,
            reps: 15,
            restSeconds: 30,
            notes: 'Active rear delts.',
          ),
        ],
      ),
      ExerciseBlock(
        type: 'Main Work',
        exercises: [
          Exercise(
            name: 'Overhead Press',
            sets: 4,
            reps: 8,
            restSeconds: 90,
            notes: 'Stable core, push high.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0055.mp4',
          ),
          Exercise(
            name: 'Side Lateral Raise',
            sets: 3,
            reps: 15,
            restSeconds: 45,
            notes: 'Leading with elbows.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0056.mp4',
          ),
          Exercise(
            name: 'Reverse Flyes',
            sets: 3,
            reps: 15,
            restSeconds: 45,
            notes: 'Target rear shoulders.',
          ),
        ],
      ),
      ExerciseBlock(
        type: 'Cooldown',
        exercises: [
          Exercise(
            name: 'Cross-Body Stretch',
            sets: 1,
            reps: 30,
            durationSeconds: 30,
            restSeconds: 0,
            notes: 'Gentle pull.',
          ),
        ],
      ),
    ],
  ),
  DailyWorkout(
    dayOfWeek: 'Custom',
    focus: 'Arm Pump',
    durationMinutes: 35,
    imageAsset: 'assets/workouts/upperarms.png',
    blocks: [
      ExerciseBlock(
        type: 'Main Work',
        exercises: [
          Exercise(
            name: 'Barbell Bicep Curls',
            sets: 3,
            reps: 10,
            restSeconds: 60,
            notes: 'No swinging!',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0060.mp4',
          ),
          Exercise(
            name: 'Tricep Rope Pushdown',
            sets: 3,
            reps: 12,
            restSeconds: 60,
            notes: 'Full lock out.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0061.mp4',
          ),
          Exercise(
            name: 'Hammer Curls',
            sets: 3,
            reps: 12,
            restSeconds: 60,
            notes: 'Develop the forearms.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0062.mp4',
          ),
        ],
      ),
      ExerciseBlock(
        type: 'Cooldown',
        exercises: [
          Exercise(
            name: 'Bicep/Tricep Stretch',
            sets: 1,
            reps: 30,
            durationSeconds: 30,
            restSeconds: 0,
            notes: 'Release tension.',
          ),
        ],
      ),
    ],
  ),
  DailyWorkout(
    dayOfWeek: 'Custom',
    focus: 'Full Body HIIT',
    durationMinutes: 30,
    imageAsset: 'assets/workouts/cardio.png',
    blocks: [
      ExerciseBlock(
        type: 'Main Work',
        exercises: [
          Exercise(
            name: 'Burpees',
            sets: 4,
            reps: 12,
            restSeconds: 45,
            notes: 'Max effort.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0064.mp4',
          ),
          Exercise(
            name: 'Mountain Climbers',
            sets: 3,
            reps: 30,
            durationSeconds: 30,
            restSeconds: 30,
            notes: 'Fast feet.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0065.mp4',
          ),
          Exercise(
            name: 'Jump Squats',
            sets: 3,
            reps: 15,
            restSeconds: 45,
            notes: 'Land softly.',
          ),
        ],
      ),
      ExerciseBlock(
        type: 'Cooldown',
        exercises: [
          Exercise(
            name: 'Deep Breathing',
            sets: 1,
            reps: 5,
            durationSeconds: 120,
            restSeconds: 0,
            notes: 'Slow down heart rate.',
          ),
        ],
      ),
    ],
  ),
  DailyWorkout(
    dayOfWeek: 'Custom',
    focus: 'Core Sculpt',
    durationMinutes: 20,
    imageAsset: 'assets/workouts/waist.jpg',
    blocks: [
      ExerciseBlock(
        type: 'Main Work',
        exercises: [
          Exercise(
            name: 'Plank',
            sets: 3,
            reps: 60,
            durationSeconds: 60,
            restSeconds: 30,
            notes: 'Brace your abs.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0066.mp4',
          ),
          Exercise(
            name: 'Russian Twists',
            sets: 3,
            reps: 20,
            restSeconds: 30,
            notes: 'Controlled rotation.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0067.mp4',
          ),
          Exercise(
            name: 'Leg Raises',
            sets: 3,
            reps: 12,
            restSeconds: 45,
            notes: 'Keep lower back on ground.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0068.mp4',
          ),
        ],
      ),
      ExerciseBlock(
        type: 'Cooldown',
        exercises: [
          Exercise(
            name: 'Cobra Stretch',
            sets: 1,
            reps: 45,
            durationSeconds: 45,
            restSeconds: 0,
            notes: 'Extend the core.',
          ),
        ],
      ),
    ],
  ),
  DailyWorkout(
    dayOfWeek: 'Custom',
    focus: 'Neck & Mobility',
    durationMinutes: 15,
    imageAsset: 'assets/workouts/neck.png',
    blocks: [
      ExerciseBlock(
        type: 'Routine',
        exercises: [
          Exercise(
            name: 'Neck Tilts',
            sets: 2,
            reps: 10,
            restSeconds: 15,
            notes: 'Side to side. Slow.',
            videoUrl: 'assets/workouts/gymvisualcom-20251219-0069.mp4',
          ),
          Exercise(
            name: 'Shoulder Shrugs',
            sets: 2,
            reps: 15,
            restSeconds: 15,
            notes: 'Up and down motion.',
          ),
          Exercise(
            name: 'Thoracic Rotations',
            sets: 2,
            reps: 10,
            restSeconds: 20,
            notes: 'Improve back mobility.',
          ),
        ],
      ),
    ],
  ),
  DailyWorkout(
    dayOfWeek: 'Custom',
    focus: 'Complete Recovery',
    durationMinutes: 20,
    imageAsset: 'assets/workouts/daily_recovery_session1.png',
    blocks: [
      ExerciseBlock(
        type: 'Recovery',
        exercises: [
          Exercise(
            name: 'Light Walking',
            sets: 1,
            reps: 600,
            durationSeconds: 600,
            restSeconds: 0,
            notes: 'Active recovery pace.',
          ),
          Exercise(
            name: 'Static Hamstring Stretch',
            sets: 2,
            reps: 45,
            durationSeconds: 45,
            restSeconds: 15,
            notes: 'Deep breaths.',
          ),
          Exercise(
            name: 'Meditation',
            sets: 1,
            reps: 300,
            durationSeconds: 300,
            restSeconds: 0,
            notes: 'Focus on breathing.',
          ),
        ],
      ),
    ],
  ),
];
