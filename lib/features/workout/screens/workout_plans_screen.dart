import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/workout_plan.dart';
import '../models/predefined_workouts.dart';
import '../repositories/workout_repository.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/screens/profile_screen.dart';

/// Currently selected workout category filter for the weekly plan.
final selectedWorkoutCategoryProvider = StateProvider<String>((_) => 'All');

class WorkoutPlansScreen extends ConsumerWidget {
  const WorkoutPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutPlanAsync = ref.watch(currentWorkoutPlanProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const _WorkoutsHeader(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: TabBar(
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        tabs: [
                          Tab(text: 'Weekly Plan'),
                          Tab(text: 'Exercise Plans'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Weekly Plan Tab
                          Column(
                            children: [
                              const _CategoryChips(),
                              const SizedBox(height: 16),
                              Expanded(
                                child: workoutPlanAsync.when(
                                  data: (plan) {
                                    if (plan == null) {
                                      return _buildEmptyPlanView();
                                    }
                                    if (plan.weeklySchedule.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'Workout plan is empty',
                                          style: TextStyle(color: AppColors.textPrimary),
                                        ),
                                      );
                                    }
                                    return _WorkoutPlanView(plan: plan);
                                  },
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(color: AppColors.primary),
                                  ),
                                  error: (err, stack) => _buildErrorView(err),
                                ),
                              ),
                            ],
                          ),
                          // Exercises Tab
                          const _PredefinedPlansView(),
                        ],
                      ),
                    ),
                  ],
                ),

                // "+ Add Workout" floating button
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingActionButton.extended(
                    onPressed: () => _showAddWorkoutSheet(context, ref),
                    backgroundColor: AppColors.primary,
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Add Workout',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlanView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text(
            'No workout plan found',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate a new plan to get started',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.accent),
          const SizedBox(height: 16),
          const Text(
            'Error loading workout plan',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            err.toString(),
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WorkoutsHeader extends ConsumerStatefulWidget {
  const _WorkoutsHeader();

  @override
  ConsumerState<_WorkoutsHeader> createState() => _WorkoutsHeaderState();
}

class _WorkoutsHeaderState extends ConsumerState<_WorkoutsHeader> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.go('/home'),
              ),
              Expanded(
                child: Text(
                  'Workouts',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.library_books, color: AppColors.textPrimary),
                onPressed: () => context.push('/exercises'),
                tooltip: 'Exercise Library',
              ),
              IconButton(
                icon: const Icon(Icons.auto_awesome, color: AppColors.primary),
                onPressed: () async {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generating AI workout plan...'),
                      backgroundColor: AppColors.primary,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  final repository = ref.read(workoutRepositoryProvider);
                  try {
                    // Prefer the real profile from Firestore, fall back to default.
                    final profileStream = ref.read(profileStreamProvider);
                    final profile =
                        profileStream.valueOrNull ?? _defaultProfile();
                    await repository.generateNewPlan(profile);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('New AI plan ready!'),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                      ref.invalidate(currentWorkoutPlanProvider);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not generate plan: $e'),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                    }
                  }
                },
                tooltip: 'Generate AI Plan',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Workouts',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.calendar_today, color: AppColors.primary),
                onPressed: () => _selectDate(context),
                tooltip: 'Select Date',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Selected: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

UserProfile _defaultProfile() {
  return UserProfile(
    uid: 'mock-user',
    basicInfo: BasicInfo(fullName: 'Guest', age: 28, gender: 'Prefer not to say'),
    bodyMetrics: BodyMetrics(height: 170, weight: 70, targetWeight: 70, bodyType: 'Mesomorph'),
    fitnessProfile: FitnessProfile(
      primaryGoal: 'General Health',
      fitnessLevel: 'Beginner',
      activityLevel: 'Moderately Active',
      availableEquipment: const ['Dumbbells', 'Mat'],
      workoutLocation: 'Home',
      durationPreference: '30-45 mins',
    ),
    nutritionProfile: NutritionProfile(
      dietaryPreference: 'No preference',
      allergies: const [],
      mealsPerDay: 3,
      waterIntakeGoal: 2.5,
    ),
    healthLifestyle: HealthLifestyle(
      medicalConditions: const [],
      injuries: 'None',
      sleepHours: 7,
      stressLevel: 5,
    ),
    isProfileComplete: false,
  );
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ['All', 'Full Body', 'Abs', 'Legs', 'Glutes', 'Yoga'];
    final selected = ref.watch(selectedWorkoutCategoryProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => ref.read(selectedWorkoutCategoryProvider.notifier).state = category,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: AppColors.textSecondary),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? AppColors.background : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WorkoutPlanView extends ConsumerWidget {
  final WorkoutPlan plan;
  const _WorkoutPlanView({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedWorkoutCategoryProvider);

    final days = selected == 'All'
        ? plan.weeklySchedule
        : plan.weeklySchedule
            .where((d) => d.focus.toLowerCase().contains(selected.toLowerCase()))
            .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final dailyWorkout = days[index];
        return _DailyWorkoutCard(dailyWorkout: dailyWorkout, dayIndex: index);
      },
    );
  }
}

class _DailyWorkoutCard extends StatelessWidget {
  final DailyWorkout dailyWorkout;
  final int dayIndex;

  const _DailyWorkoutCard({required this.dailyWorkout, required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    if (dailyWorkout.isRestDay) {
       return Container(
         height: 100,
         margin: const EdgeInsets.only(bottom: 16),
         padding: const EdgeInsets.all(20),
         decoration: BoxDecoration(
           color: AppColors.surface.withValues(alpha: 0.5),
           borderRadius: BorderRadius.circular(24),
           border: Border.all(color: AppColors.surfaceLight),
         ),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const Icon(Icons.spa, color: AppColors.textSecondary, size: 32),
             const SizedBox(width: 16),
             Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   dailyWorkout.dayOfWeek,
                   style: const TextStyle(
                     color: AppColors.textPrimary,
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 const SizedBox(height: 4),
                 Text(
                   'Rest Day - Recovery',
                   style: const TextStyle(
                     color: AppColors.textSecondary,
                     fontSize: 14,
                   ),
                 ),
               ],
             ),
           ],
         ),
       ).animate().fadeIn(delay: (dayIndex * 100).ms);
    }

    return InkWell(
      onTap: () => _showWorkoutPreview(context, dailyWorkout),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: dailyWorkout.imageAsset != null
                ? AssetImage(dailyWorkout.imageAsset!)
                : const AssetImage('assets/images/download.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.1),
                AppColors.background.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                dailyWorkout.focus,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                     color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Engage your core with this quick...',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Tag(icon: Icons.fitness_center, text: '${dailyWorkout.blocks.length} blocks'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, color: AppColors.background, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Start',
                          style: TextStyle(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (dayIndex * 100).ms).slideY(begin: 0.1);
  }
}

void _showWorkoutPreview(BuildContext context, DailyWorkout workout) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.focus,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${workout.durationMinutes} min · ${workout.blocks.length} blocks',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.surfaceLight),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.all(20),
                    itemCount: workout.blocks.length,
                    itemBuilder: (_, blockIndex) {
                      final block = workout.blocks[blockIndex];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              block.type,
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...block.exercises.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.fitness_center, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.name,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${e.sets} x ${e.reps}${e.durationSeconds != null ? ' · ${e.durationSeconds}s' : ''} · Rest ${e.restSeconds}s',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (e.notes.isNotEmpty)
                                            Text(
                                              e.notes,
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 11,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.surfaceLight),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Close Plan'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            GoRouter.of(context).push('/guided-workout', extra: workout);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Start Workout',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> _showAddWorkoutSheet(BuildContext context, WidgetRef ref) async {
  final goalOptions = ['Strength', 'Fat Loss', 'Endurance', 'Mobility', 'General Health'];
  String selectedGoal = goalOptions.first;
  final notesController = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Workout',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose a body goal and share any preferences. AI will generate a guided plan that fits your profile.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: goalOptions.map((g) {
                            final isSelected = g == selectedGoal;
                            return ChoiceChip(
                              label: Text(g),
                              selected: isSelected,
                              onSelected: (_) => setState(() => selectedGoal = g),
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.black : AppColors.textPrimary,
                              ),
                              backgroundColor: AppColors.surface,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Custom preferences (optional)',
                            hintText: 'e.g. no jumping, focus on dumbbells and core, 30 mins max...',
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  side: const BorderSide(color: AppColors.surfaceLight),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final repository = ref.read(workoutRepositoryProvider);
                                  final profileStream = ref.read(profileStreamProvider);
                                  final baseProfile =
                                      profileStream.valueOrNull ?? _defaultProfile();

                                  // Create a lightweight customized profile with the selected goal.
                                  final customizedProfile = UserProfile(
                                    uid: baseProfile.uid,
                                    basicInfo: baseProfile.basicInfo,
                                    bodyMetrics: baseProfile.bodyMetrics,
                                    fitnessProfile: FitnessProfile(
                                      primaryGoal: selectedGoal,
                                      fitnessLevel: baseProfile.fitnessProfile.fitnessLevel,
                                      activityLevel: baseProfile.fitnessProfile.activityLevel,
                                      availableEquipment: baseProfile.fitnessProfile.availableEquipment,
                                      workoutLocation: baseProfile.fitnessProfile.workoutLocation,
                                      durationPreference: baseProfile.fitnessProfile.durationPreference,
                                    ),
                                    nutritionProfile: baseProfile.nutritionProfile,
                                    healthLifestyle: baseProfile.healthLifestyle,
                                    isProfileComplete: baseProfile.isProfileComplete,
                                  );

                                  try {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Generating personalized workout...'),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );

                                    await repository.generateNewPlan(
                                      customizedProfile,
                                      userNotes: notesController.text.trim().isEmpty
                                          ? null
                                          : notesController.text.trim(),
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('New workout plan ready!'),
                                          backgroundColor: AppColors.secondary,
                                        ),
                                      );
                                    }
                                    if (context.mounted) Navigator.of(ctx).pop();
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Could not generate plan: $e'),
                                          backgroundColor: AppColors.accent,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  'Generate Plan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );

  notesController.dispose();
}

class _PredefinedPlansView extends StatelessWidget {
  const _PredefinedPlansView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: predefinedWorkouts.length,
      itemBuilder: (context, index) {
        final workout = predefinedWorkouts[index];
        return _DailyWorkoutCard(dailyWorkout: workout, dayIndex: index);
      },
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Tag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
