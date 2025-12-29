import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutPlan {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String goal;
  final List<DailyWorkout> weeklySchedule;
  final bool isAiGenerated;

  WorkoutPlan({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.goal,
    required this.weeklySchedule,
    this.isAiGenerated = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'goal': goal,
        'weeklySchedule': weeklySchedule.map((e) => e.toJson()).toList(),
        'isAiGenerated': isAiGenerated,
      };

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        startDate: (json['startDate'] as Timestamp).toDate(),
        endDate: (json['endDate'] as Timestamp).toDate(),
        goal: json['goal'] ?? '',
        weeklySchedule: (json['weeklySchedule'] as List)
            .map((e) => DailyWorkout.fromJson(e))
            .toList(),
        isAiGenerated: json['isAiGenerated'] == true,
      );
}

class DailyWorkout {
  final String dayOfWeek; // Monday, Tuesday, etc.
  final String focus; // Upper Body, Legs, Rest, etc.
  final int durationMinutes;
  final bool isRestDay;
  final bool isCompleted;
  final String? imageAsset;
  final List<ExerciseBlock> blocks;

  DailyWorkout({
    required this.dayOfWeek,
    required this.focus,
    required this.durationMinutes,
    this.isRestDay = false,
    this.isCompleted = false,
    this.imageAsset,
    required this.blocks,
  });

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'focus': focus,
        'durationMinutes': durationMinutes,
        'isRestDay': isRestDay,
        'isCompleted': isCompleted,
        'imageAsset': imageAsset,
        'blocks': blocks.map((e) => e.toJson()).toList(),
      };

  factory DailyWorkout.fromJson(Map<String, dynamic> json) => DailyWorkout(
        dayOfWeek: json['dayOfWeek']?.toString() ?? '',
        focus: json['focus']?.toString() ?? '',
        durationMinutes: _toInt(json['durationMinutes'], 30),
        isRestDay: json['isRestDay'] == true || json['isRestDay'] == 'true',
        isCompleted: json['isCompleted'] == true || json['isCompleted'] == 'true',
        imageAsset: json['imageAsset']?.toString(),
        blocks: (json['blocks'] as List? ?? [])
            .map((e) => ExerciseBlock.fromJson(e))
            .toList(),
      );
}

class ExerciseBlock {
  final String type; // Warmup, Main, Cooldown
  final List<Exercise> exercises;

  ExerciseBlock({required this.type, required this.exercises});

  Map<String, dynamic> toJson() => {
        'type': type,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory ExerciseBlock.fromJson(Map<String, dynamic> json) => ExerciseBlock(
        type: json['type']?.toString() ?? 'Main',
        exercises: (json['exercises'] as List? ?? [])
            .map((e) => Exercise.fromJson(e))
            .toList(),
      );
}

class Exercise {
  final String name;
  final int sets;
  final int reps; // Or seconds if time-based
  final int? durationSeconds;
  final int restSeconds;
  final String? videoUrl; // Placeholder for future
  final String notes;
  final List<String>? steps;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.durationSeconds,
    required this.restSeconds,
    this.videoUrl,
    required this.notes,
    this.steps,
  });

  List<String> get instructionSlides {
    if (steps != null && steps!.isNotEmpty) return steps!;
    if (notes.isEmpty) return ["Prepare for the exercise and maintain good form throughout."];
    
    // Split by common delimiters: period followed by space, semicolon, or newline
    final slides = notes.split(RegExp(r'\. |; |\n')).where((s) => s.trim().length > 3).toList();
    if (slides.isEmpty) return [notes];
    return slides;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'reps': reps,
        'durationSeconds': durationSeconds,
        'restSeconds': restSeconds,
        'videoUrl': videoUrl,
        'notes': notes,
        'steps': steps,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name']?.toString() ?? '',
        sets: _toInt(json['sets'], 3),
        reps: _toInt(json['reps'], 10),
        durationSeconds: json['durationSeconds'] != null ? _toInt(json['durationSeconds'], 0) : null,
        restSeconds: _toInt(json['restSeconds'], 60),
        videoUrl: json['videoUrl']?.toString(),
        notes: json['notes']?.toString() ?? '',
        steps: (json['steps'] as List?)?.map((e) => e.toString()).toList(),
      );
}

int _toInt(dynamic value, int defaultValue) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}
