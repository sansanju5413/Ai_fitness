import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../models/workout_plan.dart';
import '../../profile/repositories/profile_repository.dart';
import '../repositories/workout_repository.dart';
import '../widgets/generation_progress_dialog.dart';

class WorkoutCreateScreen extends ConsumerStatefulWidget {
  const WorkoutCreateScreen({super.key});

  @override
  ConsumerState<WorkoutCreateScreen> createState() => _WorkoutCreateScreenState();
}

class _WorkoutCreateScreenState extends ConsumerState<WorkoutCreateScreen> {
  late WorkoutPlan _plan;
  bool _isInitialized = false;
  final _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDefaultPlan();
  }

  void _initializeDefaultPlan() {
    final now = DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final profile = ref.read(profileStreamProvider).valueOrNull;
    
    _plan = WorkoutPlan(
      id: 'custom_${now.millisecondsSinceEpoch}',
      userId: profile?.uid ?? '',
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
      goal: 'General Health',
      weeklySchedule: dayNames.map((day) => DailyWorkout(
        dayOfWeek: day,
        focus: 'Rest',
        durationMinutes: 0,
        isRestDay: true,
        blocks: [],
      )).toList(),
    );
    _goalController.text = _plan.goal;
    _isInitialized = true;
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _generateWithAI() async {
    final repository = ref.read(workoutRepositoryProvider);
    final profileStream = ref.read(profileStreamProvider);
    final profile = profileStream.valueOrNull;

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete your profile first')),
      );
      return;
    }

    // Show generation progress dialog
    final WorkoutPlan? generatedPlan = await showDialog<WorkoutPlan>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GenerationProgressDialog(
        generationStream: repository.generateNewPlanStream(profile, userNotes: _goalController.text),
        onCancel: () {},
      ),
    );

    if (generatedPlan != null) {
      setState(() {
        _plan = generatedPlan;
        _goalController.text = _plan.goal;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ AI Plan Generated! Don\'t forget to click "Save Plan" below.'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _savePlan() async {
    final repository = ref.read(workoutRepositoryProvider);
    try {
      await repository.saveWorkoutPlan(_plan);
      ref.invalidate(currentWorkoutPlanProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workout plan saved!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving plan: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGoalInput(),
                      const SizedBox(height: 24),
                      Text(
                        'Weekly Schedule',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._plan.weeklySchedule.asMap().entries.map((entry) {
                        return _buildDayCard(entry.key, entry.value);
                      }),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Create Workout Plan',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Goal / Focus',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _goalController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'e.g. Strength Training, Weight Loss...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
            ),
            onChanged: (val) => _plan = _plan.copyWith(goal: val),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(int index, DailyWorkout day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: day.isRestDay ? AppColors.surfaceLight : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: day.isRestDay ? AppColors.surfaceLight : AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  day.dayOfWeek,
                  style: TextStyle(
                    color: day.isRestDay ? AppColors.textPrimary : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _editDayFocus(index, day),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.isRestDay ? 'Rest & Recovery' : day.focus,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: day.isRestDay ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      if (!day.isRestDay) 
                        GestureDetector(
                          onTap: () => _editDayDuration(index, day),
                          child: Text(
                            '${day.durationMinutes} mins',
                            style: const TextStyle(color: AppColors.primary, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Switch(
                value: !day.isRestDay,
                onChanged: (val) {
                  setState(() {
                    final newSchedule = List<DailyWorkout>.from(_plan.weeklySchedule);
                    newSchedule[index] = DailyWorkout(
                      dayOfWeek: day.dayOfWeek,
                      focus: val ? 'Workout' : 'Rest',
                      durationMinutes: val ? 45 : 0,
                      isRestDay: !val,
                      blocks: val ? day.blocks : [],
                    );
                    _plan = _plan.copyWith(weeklySchedule: newSchedule);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (!day.isRestDay) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.surfaceLight),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${day.durationMinutes} mins',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const Spacer(),
                const Icon(Icons.fitness_center, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${day.blocks.expand((b) => b.exercises).length} Exercises',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
  }

  void _editDayDuration(int index, DailyWorkout day) async {
    final controller = TextEditingController(text: day.durationMinutes.toString());
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Duration (mins)', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. 45',
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final mins = int.tryParse(result);
      if (mins != null) {
        setState(() {
          final newSchedule = List<DailyWorkout>.from(_plan.weeklySchedule);
          newSchedule[index] = DailyWorkout(
            dayOfWeek: day.dayOfWeek,
            focus: day.focus,
            durationMinutes: mins,
            isRestDay: day.isRestDay,
            blocks: day.blocks,
          );
          _plan = _plan.copyWith(weeklySchedule: newSchedule);
        });
      }
    }
  }

  void _editDayFocus(int index, DailyWorkout day) async {
    if (day.isRestDay) return;
    
    final controller = TextEditingController(text: day.focus);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Workout Focus', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. Chest & Triceps',
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        final newSchedule = List<DailyWorkout>.from(_plan.weeklySchedule);
        newSchedule[index] = DailyWorkout(
          dayOfWeek: day.dayOfWeek,
          focus: result,
          durationMinutes: day.durationMinutes,
          isRestDay: day.isRestDay,
          blocks: day.blocks,
        );
        _plan = _plan.copyWith(weeklySchedule: newSchedule);
      });
    }
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _generateWithAI,
              icon: const Icon(Icons.auto_awesome, color: Colors.black, size: 20),
              label: const Text('AI Populate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _savePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save Plan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

extension WorkoutPlanExtension on WorkoutPlan {
  WorkoutPlan copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? goal,
    List<DailyWorkout>? weeklySchedule,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goal: goal ?? this.goal,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
    );
  }
}
