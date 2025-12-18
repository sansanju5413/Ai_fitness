import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_form_provider.dart';

// --- Helper Widgets ---

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.displayMedium).animate().fadeIn().slideY(),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium)
            .animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 32),
      ],
    );
  }
}

// --- Step 1: Basic Info ---

class Step1BasicInfo extends ConsumerWidget {
  const Step1BasicInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const _SectionTitle(title: 'Basic Info', subtitle: "Let's start with the basics."),
          TextFormField(
            initialValue: ref.read(profileFormProvider).fullName,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateBasicInfo(fullName: val),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: ref.read(profileFormProvider).age.toString(),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake)),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateBasicInfo(age: int.tryParse(val)),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
             value: ref.read(profileFormProvider).gender,
             dropdownColor: AppColors.surface,
             style: const TextStyle(color: AppColors.textPrimary),
             decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc)),
             items: ['Male', 'Female', 'Other', 'Prefer not to say']
                 .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
             onChanged: (val) => ref.read(profileFormProvider.notifier).updateBasicInfo(gender: val),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

// --- Step 2: Body Metrics ---

class Step2BodyMetrics extends ConsumerWidget {
  const Step2BodyMetrics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileFormProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const _SectionTitle(title: 'Body Metrics', subtitle: "Help us understand your current physique."),
          TextFormField(
            initialValue: state.height.toString(),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Height (cm)', prefixIcon: Icon(Icons.height)),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateBodyMetrics(height: double.tryParse(val)),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.weight.toString(),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Current Weight (kg)', prefixIcon: Icon(Icons.monitor_weight)),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateBodyMetrics(weight: double.tryParse(val)),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.targetWeight.toString(),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Target Weight (kg)', prefixIcon: Icon(Icons.flag)),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateBodyMetrics(targetWeight: double.tryParse(val)),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: 'Mesomorph', // Default, could be calculated
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Body Type', prefixIcon: Icon(Icons.accessibility_new)),
            items: ['Ectomorph', 'Mesomorph', 'Endomorph']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) {
              // Body type would need to be added to state if we want to track it
            },
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

// --- Step 3: Fitness Profile ---

class Step3FitnessProfile extends ConsumerStatefulWidget {
  const Step3FitnessProfile({super.key});

  @override
  ConsumerState<Step3FitnessProfile> createState() => _Step3FitnessProfileState();
}

class _Step3FitnessProfileState extends ConsumerState<Step3FitnessProfile> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileFormProvider);
    final equipmentOptions = ['Dumbbells', 'Barbell', 'Resistance Bands', 'Kettlebells', 'Pull-up Bar', 'Yoga Mat', 'None'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const _SectionTitle(title: 'Fitness Goals', subtitle: "What are you aiming for?"),
          DropdownButtonFormField<String>(
            value: state.primaryGoal,
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Primary Goal'),
            items: ['Fat Loss', 'Muscle Gain', 'Endurance', 'Flexibility', 'General Health']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateFitness(goal: val),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.fitnessLevel,
             dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Fitness Level'),
            items: ['Beginner', 'Intermediate', 'Advanced', 'Athlete']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateFitness(level: val),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.activityLevel,
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Activity Level'),
            items: ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active', 'Athlete']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateFitness(activity: val),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Available Equipment', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: equipmentOptions.map((equipment) {
              final isSelected = state.availableEquipment.contains(equipment);
              return FilterChip(
                label: Text(equipment),
                selected: isSelected,
                onSelected: (selected) {
                  final current = List<String>.from(state.availableEquipment);
                  if (selected) {
                    current.add(equipment);
                  } else {
                    current.remove(equipment);
                  }
                  ref.read(profileFormProvider.notifier).updateFitness(equipment: current);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.3),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

// --- Step 4: Nutrition Profile ---

class Step4NutritionProfile extends ConsumerStatefulWidget {
  const Step4NutritionProfile({super.key});

  @override
  ConsumerState<Step4NutritionProfile> createState() => _Step4NutritionProfileState();
}

class _Step4NutritionProfileState extends ConsumerState<Step4NutritionProfile> {
  final _allergyController = TextEditingController();
  
  @override
  void dispose() {
    _allergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileFormProvider);
    final commonAllergies = ['Peanuts', 'Tree Nuts', 'Dairy', 'Eggs', 'Gluten', 'Soy', 'Shellfish'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const _SectionTitle(title: 'Nutrition', subtitle: "Fueling your body right."),
          DropdownButtonFormField<String>(
            value: state.dietaryPreference,
             dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Dietary Preference'),
            items: ['No preference', 'Vegetarian', 'Vegan', 'Keto', 'Paleo', 'Mediterranean', 'Low Carb']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateNutrition(diet: val),
          ).animate().fadeIn(delay: 300.ms),
           const SizedBox(height: 16),
           TextFormField(
            initialValue: state.mealsPerDay.toString(),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Meals per Day', prefixIcon: Icon(Icons.restaurant)),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateNutrition(meals: int.tryParse(val)),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.waterIntakeGoal.toString(),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Water Intake Goal (Liters)', prefixIcon: Icon(Icons.water_drop)),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateNutrition(water: double.tryParse(val)),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Allergies', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: commonAllergies.map((allergy) {
              final isSelected = state.allergies.contains(allergy);
              return FilterChip(
                label: Text(allergy),
                selected: isSelected,
                onSelected: (selected) {
                  final current = List<String>.from(state.allergies);
                  if (selected) {
                    current.add(allergy);
                  } else {
                    current.remove(allergy);
                  }
                  ref.read(profileFormProvider.notifier).updateNutrition(allergies: current);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.3),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

// --- Step 5: Health & Lifestyle ---

class Step5HealthLifestyle extends ConsumerWidget {
  const Step5HealthLifestyle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const _SectionTitle(title: 'Health & Lifestyle', subtitle: "Optimizing for your well-being."),
          TextFormField(
            initialValue: ref.read(profileFormProvider).injuries,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Injuries (if any)', prefixIcon: Icon(Icons.medical_services)),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateHealth(injuries: val),
          ).animate().fadeIn(delay: 300.ms),
           const SizedBox(height: 16),
           TextFormField(
            initialValue: ref.read(profileFormProvider).sleepHours.toString(),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Avg Sleep (hours)', prefixIcon: Icon(Icons.bed)),
            onChanged: (val) => ref.read(profileFormProvider.notifier).updateHealth(sleep: int.tryParse(val)),
          ).animate().fadeIn(delay: 400.ms),
           const SizedBox(height: 16),
           Text('Stress Level (1-10)', style: Theme.of(context).textTheme.bodyMedium),
           Slider(
             value: ref.watch(profileFormProvider).stressLevel.toDouble(),
             min: 1,
             max: 10,
             divisions: 9,
             label: ref.watch(profileFormProvider).stressLevel.toString(),
             activeColor: AppColors.secondary,
             onChanged: (val) => ref.read(profileFormProvider.notifier).updateHealth(stress: val.round()),
           ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}
