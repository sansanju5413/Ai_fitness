import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_ai_service.dart';
import '../models/meal.dart';

class AiFoodService extends BaseAiService {
  AiFoodService() : super();

  /// Food analysis - accurate and fast
  Future<List<FoodItem>> analyzeFood(String description) async {
    print('[AiFoodService] 🍎 Analyzing: "$description"');
    
    // Clear, explicit prompt for accurate nutritional data
    final prompt = '''Food: "$description"

Return JSON array with EACH food item and ACCURATE calories:
- 1 egg = 70 cal, 6g protein, 0g carbs, 5g fat
- 1 cup tea = 2 cal, 0g protein, 0g carbs, 0g fat  
- 1 chapati = 120 cal, 3g protein, 20g carbs, 3g fat
- 100g chicken = 165 cal, 31g protein, 0g carbs, 4g fat
- 1 cup rice = 200 cal, 4g protein, 45g carbs, 0g fat

Format: [{"name":"Food","quantity":1,"unit":"piece","macros":{"calories":70,"protein":6,"carbs":0,"fat":5}}]

List EVERY item separately with correct values.''';

    try {
      // Use small maxTokens - food data is just numbers
      final responseText = await generateJsonContent(prompt, maxTokens: 500);

      if (responseText == null || responseText.isEmpty) {
        throw Exception('AI returned empty response');
      }

      print('[AiFoodService] 📊 Parsing JSON response...');
      print('[AiFoodService] Raw response: $responseText');
      
      // Parse the response - handle both array and object formats
      final decoded = jsonDecode(responseText);
      List<dynamic> jsonList;
      
      if (decoded is List) {
        // Response is already an array
        jsonList = decoded;
      } else if (decoded is Map) {
        // Response is an object - try to extract items array
        if (decoded.containsKey('foodItems')) {
          jsonList = decoded['foodItems'] as List<dynamic>;
        } else if (decoded.containsKey('items')) {
          jsonList = decoded['items'] as List<dynamic>;
        } else if (decoded.containsKey('foods')) {
          jsonList = decoded['foods'] as List<dynamic>;
        } else if (decoded.containsKey('food_items')) {
          jsonList = decoded['food_items'] as List<dynamic>;
        } else {
          // Single item wrapped in object, convert to list
          jsonList = [decoded];
        }
      } else {
        throw Exception('Unexpected response format');
      }
      
      if (jsonList.isEmpty) {
        throw Exception('AI returned empty food list');
      }
      
      final items = jsonList.map((json) => FoodItem.fromJson(json)).toList();
      
      // Validate parsed items
      if (!_validateFoodItems(items)) {
        throw Exception('Invalid food item data');
      }
      
      print('[AiFoodService] ✅ Successfully parsed ${items.length} food items');
      for (final item in items) {
        print('[AiFoodService]   - ${item.name}: ${item.macros.calories} kcal'
            ' (P: ${item.macros.protein}g, C: ${item.macros.carbs}g, F: ${item.macros.fat}g)');
      }
      
      return items;

    } catch (e) {
      print('[AiFoodService] ❌ Error analyzing food: $e');
      // Return a basic fallback instead of throwing
      return _createFallbackFood(description);
    }
  }

  /// Create fallback food item when AI fails
  List<FoodItem> _createFallbackFood(String description) {
    print('[AiFoodService] ⚠️ Using fallback food data');
    
    // Try to make an educated guess based on common foods
    final lowerDesc = description.toLowerCase();
    
    // Check for common food patterns
    if (lowerDesc.contains('egg')) {
      final count = _extractNumber(description) ?? 2;
      return [
        FoodItem(
          name: 'Eggs',
          quantity: count.toDouble(),
          unit: 'piece',
          macros: MacroNutrients(
            calories: 70 * count,
            protein: 6 * count,
            carbs: 0,
            fat: 5 * count,
          ),
        ),
      ];
    }
    
    if (lowerDesc.contains('chicken')) {
      return [
        FoodItem(
          name: 'Chicken',
          quantity: 150,
          unit: 'gram',
          macros: const MacroNutrients(
            calories: 248,
            protein: 47,
            carbs: 0,
            fat: 6,
          ),
        ),
      ];
    }
    
    if (lowerDesc.contains('rice')) {
      return [
        FoodItem(
          name: 'Rice',
          quantity: 1,
          unit: 'cup',
          macros: const MacroNutrients(
            calories: 200,
            protein: 4,
            carbs: 45,
            fat: 0,
          ),
        ),
      ];
    }
    
    if (lowerDesc.contains('banana')) {
      return [
        FoodItem(
          name: 'Banana',
          quantity: 1,
          unit: 'piece',
          macros: const MacroNutrients(
            calories: 105,
            protein: 1,
            carbs: 27,
            fat: 0,
          ),
        ),
      ];
    }
    
    // Generic fallback
    return [
      FoodItem(
        name: description,
        quantity: 1,
        unit: 'serving',
        macros: const MacroNutrients(
          calories: 300,
          protein: 15,
          carbs: 40,
          fat: 10,
        ),
      ),
    ];
  }

  /// Extract a number from a string (e.g., "2 eggs" -> 2)
  int? _extractNumber(String text) {
    final match = RegExp(r'\d+').firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }

  /// Validate parsed food items
  bool _validateFoodItems(List<FoodItem> items) {
    for (final item in items) {
      if (item.name.isEmpty) return false;
      if (item.quantity <= 0) return false;
      if (item.macros.calories < 0) return false;
    }
    return true;
  }
}

final aiFoodServiceProvider = Provider<AiFoodService>((ref) {
  return AiFoodService();
});
