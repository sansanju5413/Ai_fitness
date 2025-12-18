import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/session_provider.dart';
import '../../workout/models/workout_plan.dart';

class ExerciseTrackerCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  final int setNumber;

  const ExerciseTrackerCard({
    super.key,
    required this.exercise,
    required this.setNumber,
  });

  @override
  ConsumerState<ExerciseTrackerCard> createState() => _ExerciseTrackerCardState();
}

class _ExerciseTrackerCardState extends ConsumerState<ExerciseTrackerCard> {
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repsController.text = widget.exercise.reps.toString();
    _weightController.text = '0'; // Default, ideally fetch from history
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _logSet() {
    final reps = int.tryParse(_repsController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    
    if (reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number of reps'),
          backgroundColor: AppColors.accent,
        ),
      );
      return;
    }
    
    ref.read(sessionProvider.notifier).logSet(reps: reps, weight: weight);
    
    // Clear inputs for next set
    _repsController.text = widget.exercise.reps.toString();
    _weightController.text = weight.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
         boxShadow: [
          BoxShadow(
            color: AppColors.background.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.exercise.name,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Set ${widget.setNumber} of ${widget.exercise.sets}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              // Weight Input
              Expanded(
                child: Column(
                  children: [
                    const Text('WEIGHT (KG)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Reps Input
              Expanded(
                child: Column(
                  children: [
                    const Text('REPS', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                       style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                         fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logSet,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Log Set', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
