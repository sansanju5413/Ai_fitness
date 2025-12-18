import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';

class ProfileFormState {
  final int currentStep;
  // Basic Info
  final String fullName;
  final int age;
  final String gender;
  // Body Metrics
  final double height;
  final double weight;
  final double targetWeight;
  // Fitness
  final String primaryGoal;
  final String fitnessLevel;
  final String activityLevel;
  final List<String> availableEquipment;
  // Nutrition
  final String dietaryPreference;
  final List<String> allergies;
  final int mealsPerDay;
  final double waterIntakeGoal;
  // Health
  final List<String> medicalConditions;
  final String injuries;
  final int sleepHours;
  final int stressLevel;

  ProfileFormState({
    this.currentStep = 0,
    this.fullName = '',
    this.age = 25,
    this.gender = 'Male',
    this.height = 175,
    this.weight = 75,
    this.targetWeight = 70,
    this.primaryGoal = 'Fat Loss',
    this.fitnessLevel = 'Beginner',
    this.activityLevel = 'Moderately Active',
    this.availableEquipment = const [],
    this.dietaryPreference = 'No preference',
    this.allergies = const [],
    this.mealsPerDay = 3,
    this.waterIntakeGoal = 2.5,
    this.medicalConditions = const [],
    this.injuries = '',
    this.sleepHours = 7,
    this.stressLevel = 5,
  });

  ProfileFormState copyWith({
    int? currentStep,
    String? fullName,
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? targetWeight,
    String? primaryGoal,
    String? fitnessLevel,
    String? activityLevel,
    List<String>? availableEquipment,
    String? dietaryPreference,
    List<String>? allergies,
    int? mealsPerDay,
    double? waterIntakeGoal,
    List<String>? medicalConditions,
    String? injuries,
    int? sleepHours,
    int? stressLevel,
  }) {
    return ProfileFormState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      activityLevel: activityLevel ?? this.activityLevel,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      allergies: allergies ?? this.allergies,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      waterIntakeGoal: waterIntakeGoal ?? this.waterIntakeGoal,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      injuries: injuries ?? this.injuries,
      sleepHours: sleepHours ?? this.sleepHours,
      stressLevel: stressLevel ?? this.stressLevel,
    );
  }
}

class ProfileFormNotifier extends StateNotifier<ProfileFormState> {
  final ProfileRepository _repository;

  ProfileFormNotifier(this._repository) : super(ProfileFormState());

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  // Update Methods
  void updateBasicInfo({String? fullName, int? age, String? gender}) {
    state = state.copyWith(fullName: fullName, age: age, gender: gender);
  }

  void updateBodyMetrics({double? height, double? weight, double? targetWeight}) {
    state = state.copyWith(height: height, weight: weight, targetWeight: targetWeight);
  }

  void updateFitness({String? goal, String? level, String? activity, List<String>? equipment}) {
    state = state.copyWith(primaryGoal: goal, fitnessLevel: level, activityLevel: activity, availableEquipment: equipment);
  }

  void updateNutrition({String? diet, List<String>? allergies, int? meals, double? water}) {
    state = state.copyWith(dietaryPreference: diet, allergies: allergies, mealsPerDay: meals, waterIntakeGoal: water);
  }

  void updateHealth({List<String>? conditions, String? injuries, int? sleep, int? stress}) {
    state = state.copyWith(medicalConditions: conditions, injuries: injuries, sleepHours: sleep, stressLevel: stress);
  }

  Future<void> submitProfile(String uid) async {
    final profile = UserProfile(
      uid: uid,
      basicInfo: BasicInfo(
        fullName: state.fullName,
        age: state.age,
        gender: state.gender,
      ),
      bodyMetrics: BodyMetrics(
        height: state.height,
        weight: state.weight,
        targetWeight: state.targetWeight,
        bodyType: 'Mesomorph', // Could be calculated or asked
      ),
      fitnessProfile: FitnessProfile(
        primaryGoal: state.primaryGoal,
        fitnessLevel: state.fitnessLevel,
        activityLevel: state.activityLevel,
        availableEquipment: state.availableEquipment,
        workoutLocation: 'Home', // Assumed for now or add to state
        durationPreference: '45 mins', // Assumed
      ),
      nutritionProfile: NutritionProfile(
        dietaryPreference: state.dietaryPreference,
        allergies: state.allergies,
        mealsPerDay: state.mealsPerDay,
        waterIntakeGoal: state.waterIntakeGoal,
      ),
      healthLifestyle: HealthLifestyle(
        medicalConditions: state.medicalConditions,
        injuries: state.injuries,
        sleepHours: state.sleepHours,
        stressLevel: state.stressLevel,
      ),
      isProfileComplete: true,
    );

    await _repository.saveProfile(profile);
  }
}

final profileFormProvider = StateNotifierProvider<ProfileFormNotifier, ProfileFormState>((ref) {
  return ProfileFormNotifier(ref.read(profileRepositoryProvider));
});
