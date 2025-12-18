import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../workout/repositories/workout_repository.dart';
import 'package:go_router/go_router.dart';

class QuickActionsGrid extends ConsumerWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      {'icon': Icons.play_arrow_rounded, 'label': 'Start Workout', 'color': AppColors.primary},
      {'icon': Icons.add_a_photo_outlined, 'label': 'Log Meal', 'color': AppColors.accent},
      {'icon': Icons.chat_bubble_outline, 'label': 'Ask AI', 'color': AppColors.secondary},
      {'icon': Icons.calendar_month_outlined, 'label': 'Plan', 'color': AppColors.primary},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
         GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () async {
                if (action['label'] == 'Start Workout') {
                   // Fetch mock plan
                   final plan = await ref.read(workoutRepositoryProvider).getCurrentPlan();
                   if (plan != null && context.mounted) {
                     // Find first non-rest day workout
                     final workout = plan.weeklySchedule.firstWhere(
                       (w) => !w.isRestDay,
                       orElse: () => plan.weeklySchedule.first,
                     );
                     if (context.mounted) {
                       context.push('/session', extra: workout);
                     }
                   } else if (context.mounted) {
                     // If no plan, go to workouts screen
                     context.go('/workouts');
                   }
                } else if (action['label'] == 'Log Meal') {
                  context.push('/log-food');
                } else if (action['label'] == 'Ask AI') {
                  // Navigate to AI chat or show AI suggestions
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text('AI Coach', style: TextStyle(color: AppColors.textPrimary)),
                      content: const Text(
                        'Get personalized workout and nutrition advice from your AI coach. '
                        'Complete your profile setup for the best recommendations!',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/profile-setup');
                          },
                          child: const Text('Complete Profile'),
                        ),
                      ],
                    ),
                  );
                } else if (action['label'] == 'Plan') {
                  context.go('/workouts');
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action['icon'] as IconData, color: action['color'] as Color),
                    const SizedBox(width: 12),
                    Text(
                      action['label'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (600 + (index * 100)).ms).scale();
          },
        ),
      ],
    );
  }
}
