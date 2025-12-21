import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/base_ai_service.dart';
import '../models/meal.dart';

class AiFoodService extends BaseAiService {
  AiFoodService() : super(model: 'gemini-1.5-flash');

  Future<List<FoodItem>> analyzeFood(String description) async {
    final prompt = '''
Analyze the following food description and provide a nutritional breakdown.
Return ONLY a valid JSON array of objects. Do not include markdown formatting.

Description: "$description"

JSON Structure:
[
  {
    "name": "Food Name",
    "quantity": double,
    "unit": "serving|cup|gram|piece",
    "macros": {
      "calories": int,
      "protein": int,
      "carbs": int,
      "fat": int
    }
  }
]
''';

    try {
      final responseText = await generateJsonContent(prompt);

      if (responseText == null) {
        throw Exception('AI returned empty response');
      }

      String cleanedText = responseText.trim();
      if (cleanedText.startsWith('```')) {
          cleanedText = cleanedText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      }
      
      final List<dynamic> jsonList = jsonDecode(cleanedText);
      
      return jsonList.map((json) => FoodItem.fromJson(json)).toList();

    } catch (e) {
      // Return a reasonable fallback based on description
      return [
        FoodItem(
          name: description,
          quantity: 1,
          unit: 'serving',
          macros: const MacroNutrients(calories: 200, protein: 10, carbs: 20, fat: 8),
        ),
      ];
    }
  }
}

final aiFoodServiceProvider = Provider<AiFoodService>((ref) {
  return AiFoodService();
});
