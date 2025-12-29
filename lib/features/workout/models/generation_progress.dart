/// Model classes for tracking workout plan generation progress.
/// 
/// Used to provide real-time feedback during AI plan generation.

import 'workout_plan.dart';

/// Represents the current state of workout plan generation
class GenerationProgress {
  /// Current generation status
  final GenerationStatus status;
  
  /// User-friendly message to display
  final String message;
  
  /// Progress from 0.0 to 1.0
  final double progress;
  
  /// Partial plan being built (for live preview)
  final List<DailyWorkout>? partialPlan;
  
  /// Complete plan when generation finishes
  final WorkoutPlan? completePlan;
  
  /// Error message if generation failed
  final String? errorMessage;
  
  /// Current day being generated (1-7)
  final int? currentDay;
  
  const GenerationProgress({
    required this.status,
    required this.message,
    required this.progress,
    this.partialPlan,
    this.completePlan,
    this.errorMessage,
    this.currentDay,
  });

  /// Factory for initial state
  factory GenerationProgress.initial() {
    return const GenerationProgress(
      status: GenerationStatus.initializing,
      message: '🤔 Analyzing your fitness profile...',
      progress: 0.0,
    );
  }

  /// Factory for generating day state
  factory GenerationProgress.generatingDay(int day, List<DailyWorkout> partial) {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return GenerationProgress(
      status: GenerationStatus.generatingDay,
      message: '💪 Creating Day $day: ${dayNames[day - 1]}...',
      progress: (day - 1) / 7,
      currentDay: day,
      partialPlan: partial,
    );
  }

  /// Factory for day complete state
  factory GenerationProgress.dayComplete(int day, List<DailyWorkout> partial) {
    return GenerationProgress(
      status: GenerationStatus.generatingDay,
      message: '✅ Day $day complete!',
      progress: day / 7,
      currentDay: day,
      partialPlan: partial,
    );
  }

  /// Factory for validating state
  factory GenerationProgress.validating() {
    return const GenerationProgress(
      status: GenerationStatus.validating,
      message: '🔧 Finalizing your workout plan...',
      progress: 0.95,
    );
  }

  /// Factory for complete state
  factory GenerationProgress.complete(WorkoutPlan plan) {
    return GenerationProgress(
      status: GenerationStatus.complete,
      message: '🎉 Your personalized plan is ready!',
      progress: 1.0,
      completePlan: plan,
    );
  }

  /// Factory for error state
  factory GenerationProgress.error(String errorMessage) {
    return GenerationProgress(
      status: GenerationStatus.error,
      message: '❌ Generation failed',
      progress: 0.0,
      errorMessage: errorMessage,
    );
  }

  /// Factory for cancelled state
  factory GenerationProgress.cancelled() {
    return const GenerationProgress(
      status: GenerationStatus.cancelled,
      message: 'Generation cancelled',
      progress: 0.0,
    );
  }
}

/// Status of the generation process
enum GenerationStatus {
  initializing,
  generatingDay,
  validating,
  complete,
  error,
  cancelled,
}

/// Tracks progress of a single day's generation
class DayProgress {
  final int dayNumber;
  final String dayName;
  final DayStatus status;
  
  const DayProgress({
    required this.dayNumber,
    required this.dayName,
    required this.status,
  });
  
  DayProgress copyWith({
    int? dayNumber,
    String? dayName,
    DayStatus? status,
  }) {
    return DayProgress(
      dayNumber: dayNumber ?? this.dayNumber,
      dayName: dayName ?? this.dayName,
      status: status ?? this.status,
    );
  }

  /// Create list of all 7 days in pending state
  static List<DayProgress> createWeek() {
    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return List.generate(7, (i) => DayProgress(
      dayNumber: i + 1,
      dayName: dayNames[i],
      status: DayStatus.pending,
    ));
  }
}

/// Status of a single day's generation
enum DayStatus {
  pending,
  generating,
  complete,
}
