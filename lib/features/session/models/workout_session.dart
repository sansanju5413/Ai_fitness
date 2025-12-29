import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSession {
  final String id;
  final String userId;
  final String workoutDay;
  final String workoutFocus;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final Map<String, List<Map<String, dynamic>>> exerciseLogs;
  final bool isCompleted;
  final int currentBlockIndex;
  final int currentExerciseIndex;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.workoutDay,
    required this.workoutFocus,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.exerciseLogs,
    this.isCompleted = false,
    this.currentBlockIndex = 0,
    this.currentExerciseIndex = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'workoutDay': workoutDay,
        'workoutFocus': workoutFocus,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
        'durationSeconds': duration.inSeconds,
        'exerciseLogs': exerciseLogs,
        'isCompleted': isCompleted,
        'currentBlockIndex': currentBlockIndex,
        'currentExerciseIndex': currentExerciseIndex,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final Map<String, List<Map<String, dynamic>>> logs = {};
    final rawLogs = json['exerciseLogs'];
    if (rawLogs != null && rawLogs is Map) {
      rawLogs.forEach((key, value) {
        if (value is List) {
          logs[key.toString()] = value.map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{};
          }).toList();
        }
      });
    }
    
    return WorkoutSession(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      workoutDay: json['workoutDay'] ?? '',
      workoutFocus: json['workoutFocus'] ?? '',
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: json['endTime'] != null ? (json['endTime'] as Timestamp).toDate() : null,
      duration: Duration(seconds: json['durationSeconds'] ?? 0),
      exerciseLogs: logs,
      isCompleted: json['isCompleted'] ?? false,
      currentBlockIndex: json['currentBlockIndex'] ?? 0,
      currentExerciseIndex: json['currentExerciseIndex'] ?? 0,
    );
  }

  WorkoutSession copyWith({
    String? id,
    String? userId,
    String? workoutDay,
    String? workoutFocus,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    Map<String, List<Map<String, dynamic>>>? exerciseLogs,
    bool? isCompleted,
    int? currentBlockIndex,
    int? currentExerciseIndex,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workoutDay: workoutDay ?? this.workoutDay,
      workoutFocus: workoutFocus ?? this.workoutFocus,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
      isCompleted: isCompleted ?? this.isCompleted,
      currentBlockIndex: currentBlockIndex ?? this.currentBlockIndex,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
    );
  }
}
