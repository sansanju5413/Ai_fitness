import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../services/ai_food_service.dart';
import '../models/meal.dart';
import '../repositories/nutrition_repository.dart';

class FoodLoggerScreen extends ConsumerStatefulWidget {
  const FoodLoggerScreen({super.key});

  @override
  ConsumerState<FoodLoggerScreen> createState() => _FoodLoggerScreenState();
}

class _FoodLoggerScreenState extends ConsumerState<FoodLoggerScreen> {
  final _descriptionController = TextEditingController();
  bool _isAnalyzing = false;
  List<FoodItem>? _analyzedItems;

  Future<void> _analyze() async {
    if (_descriptionController.text.isEmpty) return;
    
    setState(() => _isAnalyzing = true);
    try {
      final items = await ref.read(aiFoodServiceProvider).analyzeFood(_descriptionController.text);
      if (mounted) {
        setState(() {
          _analyzedItems = items;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not analyze meal: $e')),
        );
      }
    }
  }

  Future<void> _saveLog() async {
     if (_analyzedItems == null || _analyzedItems!.isEmpty) return;

     final meal = Meal(
       id: DateTime.now().toIso8601String(), 
       name: 'Snack', // Simplified for now
       time: DateTime.now(), 
       items: _analyzedItems!
     );

     await ref.read(nutritionRepositoryProvider).logMeal(meal);
     
     // Invalidate the provider so dashboard refreshes
     // Since we are using a cached variable in repo, simpler to just refetch or rely on same instance.
     // In Riverpod FutureProvider, we need to invalidate with the date parameter
     final today = DateTime.now();
     final normalized = DateTime(today.year, today.month, today.day);
     ref.invalidate(dailyLogProvider(normalized));

     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Meal saved to today\'s log!')),
       );
       context.pop();
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Food'), backgroundColor: Colors.transparent),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Input Area
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Describe your meal (e.g., "2 eggs and toast")...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Analyze Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyze,
                icon: _isAnalyzing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(_isAnalyzing ? 'AI is Analyzing...' : 'Analyze with AI'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            // Results Area
            if (_analyzedItems != null) ...[
               const Align(alignment: Alignment.centerLeft, child: Text("RESULTS", style: TextStyle(color: AppColors.textSecondary))),
               const SizedBox(height: 16),
               Expanded(
                 child: ListView.builder(
                   itemCount: _analyzedItems!.length,
                   itemBuilder: (context, index) {
                     final item = _analyzedItems![index];
                     return Card(
                       color: AppColors.surface,
                       child: ListTile(
                         title: Text(item.name, style: const TextStyle(color: AppColors.textPrimary)),
                         subtitle: Text('${item.macros.calories} kcal • ${item.macros.protein}g P', style: const TextStyle(color: AppColors.textSecondary)),
                         trailing: const Icon(Icons.check_circle, color: AppColors.primary),
                       ),
                     );
                   },
                 ),
               ),
               
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: _saveLog,
                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                   child: const Text('Save to Log'),
                 ),
               ).animate().fadeIn(),
            ]
          ],
        ),
      ),
    );
  }
}
