import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/meal.dart';
import '../repositories/nutrition_repository.dart';

class NutritionDashboardScreen extends ConsumerWidget {
  const NutritionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    // Normalize date to just year-month-day for consistent caching
    final normalizedDate = DateTime(today.year, today.month, today.day);
    final logAsync = ref.watch(dailyLogProvider(normalizedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/log-food'),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: logAsync.when(
          data: (log) => _NutritionContent(log: log),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) {
            // Show error with retry option
            final retryDate = DateTime(today.year, today.month, today.day);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.accent),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading nutrition data',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      err.toString(),
                      style: const TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(dailyLogProvider(retryDate));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/log-food'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}

class _NutritionContent extends StatelessWidget {
  final MealLog log;
  const _NutritionContent({required this.log});

  @override
  Widget build(BuildContext context) {
    final total = log.totalMacros;
    // Targets (Mocked for now, should come from Profile)
    const targetCalories = 2200;
    const targetProtein = 160;
    const targetCarbs = 250;
    const targetFat = 70;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie Summary Card
          _CalorieRing(
            current: total.calories, 
            target: targetCalories,
            protein: total.protein, targetProtein: targetProtein,
            carbs: total.carbs, targetCarbs: targetCarbs,
            fat: total.fat, targetFat: targetFat,
          ),
          const SizedBox(height: 32),
          
          Text(
            "TODAY'S MEALS",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          
          ...log.meals.map((meal) => _MealCard(meal: meal, date: log.date)),
          
          if (log.meals.isEmpty)
             Padding(
               padding: const EdgeInsets.all(32.0),
               child: Column(
                 children: [
                   const Text("No meals logged yet today.", style: TextStyle(color: AppColors.textSecondary)),
                   const SizedBox(height: 12),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton.icon(
                       icon: const Icon(Icons.add),
                       onPressed: () => context.push('/log-food'),
                       style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                       label: const Text('Add your first meal'),
                     ),
                   ),
                 ],
               ),
             ),
             
          const SizedBox(height: 80), // Fab space
        ],
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  final int current;
  final int target;
  final int protein, targetProtein;
  final int carbs, targetCarbs;
  final int fat, targetFat;

  const _CalorieRing({
    required this.current,
    required this.target,
    required this.protein, required this.targetProtein,
    required this.carbs, required this.targetCarbs,
    required this.fat, required this.targetFat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
         color: AppColors.surface,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [
           BoxShadow(color: AppColors.background.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
         ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Calories", style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$current', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text(' / $target kcal', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  value: (current / target).clamp(0.0, 1.0),
                  backgroundColor: AppColors.surfaceLight,
                  color: AppColors.primary,
                  strokeWidth: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _MacroBar(label: 'Protein', current: protein, target: targetProtein, color: AppColors.primary),
              const SizedBox(width: 16),
              _MacroBar(label: 'Carbs', current: carbs, target: targetCarbs, color: AppColors.secondary),
              const SizedBox(width: 16),
              _MacroBar(label: 'Fat', current: fat, target: targetFat, color: AppColors.accent),
            ],
          )
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final int current;
  final int target;
  final Color color;

  const _MacroBar({required this.label, required this.current, required this.target, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (current / target).clamp(0.0, 1.0),
            backgroundColor: AppColors.surfaceLight,
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text('${current}g', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MealCard extends ConsumerWidget {
  final Meal meal;
  final DateTime date;
  
  const _MealCard({required this.meal, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('meal_${meal.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(nutritionRepositoryProvider).deleteMeal(meal.id, date);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${meal.name} deleted')),
        );
      },
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(meal.name, style: Theme.of(context).textTheme.titleMedium),
                Text('${meal.totalMacros.calories} kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const Divider(color: AppColors.surfaceLight, height: 24),
            ...meal.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.name, style: const TextStyle(color: AppColors.textSecondary)),
                  Text('${item.quantity} ${item.unit}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            )),
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
