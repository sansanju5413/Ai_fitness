class UserProfile {
  final String uid;
  final BasicInfo basicInfo;
  final BodyMetrics bodyMetrics;
  final FitnessProfile fitnessProfile;
  final NutritionProfile nutritionProfile;
  final HealthLifestyle healthLifestyle;
  final bool isProfileComplete;

  UserProfile({
    required this.uid,
    required this.basicInfo,
    required this.bodyMetrics,
    required this.fitnessProfile,
    required this.nutritionProfile,
    required this.healthLifestyle,
    this.isProfileComplete = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'basicInfo': basicInfo.toJson(),
      'bodyMetrics': bodyMetrics.toJson(),
      'fitnessProfile': fitnessProfile.toJson(),
      'nutritionProfile': nutritionProfile.toJson(),
      'healthLifestyle': healthLifestyle.toJson(),
      'isProfileComplete': isProfileComplete,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      basicInfo: BasicInfo.fromJson(json['basicInfo'] ?? {}),
      bodyMetrics: BodyMetrics.fromJson(json['bodyMetrics'] ?? {}),
      fitnessProfile: FitnessProfile.fromJson(json['fitnessProfile'] ?? {}),
      nutritionProfile: NutritionProfile.fromJson(json['nutritionProfile'] ?? {}),
      healthLifestyle: HealthLifestyle.fromJson(json['healthLifestyle'] ?? {}),
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }
}

class BasicInfo {
  final String fullName;
  final int age;
  final String gender;
  final String? photoUrl;

  BasicInfo({
    required this.fullName,
    required this.age,
    required this.gender,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'age': age,
        'gender': gender,
        'photoUrl': photoUrl,
      };

  factory BasicInfo.fromJson(Map<String, dynamic> json) => BasicInfo(
        fullName: json['fullName'] ?? '',
        age: json['age'] ?? 0,
        gender: json['gender'] ?? 'Prefer not to say',
        photoUrl: json['photoUrl'],
      );
}

class BodyMetrics {
  final double height; // in cm
  final double weight; // in kg
  final double targetWeight; // in kg
  final String bodyType; // Ectomorph, Mesomorph, Endomorph

  BodyMetrics({
    required this.height,
    required this.weight,
    required this.targetWeight,
    required this.bodyType,
  });

  Map<String, dynamic> toJson() => {
        'height': height,
        'weight': weight,
        'targetWeight': targetWeight,
        'bodyType': bodyType,
      };

  factory BodyMetrics.fromJson(Map<String, dynamic> json) => BodyMetrics(
        height: (json['height'] ?? 0).toDouble(),
        weight: (json['weight'] ?? 0).toDouble(),
        targetWeight: (json['targetWeight'] ?? 0).toDouble(),
        bodyType: json['bodyType'] ?? 'Mesomorph',
      );
}

class FitnessProfile {
  final String primaryGoal;
  final String fitnessLevel; // Beginner, Intermediate, Advanced
  final String activityLevel; // Sedentary to Athlete
  final List<String> availableEquipment;
  final String workoutLocation;
  final String durationPreference; // 30-45 mins etc.

  FitnessProfile({
    required this.primaryGoal,
    required this.fitnessLevel,
    required this.activityLevel,
    required this.availableEquipment,
    required this.workoutLocation,
    required this.durationPreference,
  });

  Map<String, dynamic> toJson() => {
        'primaryGoal': primaryGoal,
        'fitnessLevel': fitnessLevel,
        'activityLevel': activityLevel,
        'availableEquipment': availableEquipment,
        'workoutLocation': workoutLocation,
        'durationPreference': durationPreference,
      };

  factory FitnessProfile.fromJson(Map<String, dynamic> json) => FitnessProfile(
        primaryGoal: json['primaryGoal'] ?? 'General Health',
        fitnessLevel: json['fitnessLevel'] ?? 'Beginner',
        activityLevel: json['activityLevel'] ?? 'Moderately Active',
        availableEquipment: List<String>.from(json['availableEquipment'] ?? []),
        workoutLocation: json['workoutLocation'] ?? 'Home',
        durationPreference: json['durationPreference'] ?? '30-45 minutes',
      );
}

class NutritionProfile {
  final String dietaryPreference; // Vegetarian, Vegan, etc.
  final List<String> allergies;
  final int mealsPerDay;
  final double waterIntakeGoal; // in Liters

  NutritionProfile({
    required this.dietaryPreference,
    required this.allergies,
    required this.mealsPerDay,
    required this.waterIntakeGoal,
  });

  Map<String, dynamic> toJson() => {
        'dietaryPreference': dietaryPreference,
        'allergies': allergies,
        'mealsPerDay': mealsPerDay,
        'waterIntakeGoal': waterIntakeGoal,
      };

  factory NutritionProfile.fromJson(Map<String, dynamic> json) => NutritionProfile(
        dietaryPreference: json['dietaryPreference'] ?? 'No preference',
        allergies: List<String>.from(json['allergies'] ?? []),
        mealsPerDay: json['mealsPerDay'] ?? 3,
        waterIntakeGoal: (json['waterIntakeGoal'] ?? 2.5).toDouble(),
      );
}

class HealthLifestyle {
  final List<String> medicalConditions;
  final String injuries;
  final int sleepHours;
  final int stressLevel; // 1-10

  HealthLifestyle({
    required this.medicalConditions,
    required this.injuries,
    required this.sleepHours,
    required this.stressLevel,
  });

  Map<String, dynamic> toJson() => {
        'medicalConditions': medicalConditions,
        'injuries': injuries,
        'sleepHours': sleepHours,
        'stressLevel': stressLevel,
      };

  factory HealthLifestyle.fromJson(Map<String, dynamic> json) => HealthLifestyle(
        medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
        injuries: json['injuries'] ?? 'None',
        sleepHours: json['sleepHours'] ?? 7,
        stressLevel: json['stressLevel'] ?? 5,
      );
}
