import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/meal.dart';

const String _kGeminiApiKey = 'AIzaSyBVWSJXVBqPGpMnXXiZt4BQ4VhaHs8IHOY';

class AiFoodService {
  late final GenerativeModel _model;

  AiFoodService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _kGeminiApiKey,
    );
  }

  Future<List<FoodItem>> analyzeFood(String description) async {
    final prompt = '''
    Analyze the following food description and provide a nutritional breakdown.
    Description: "$description"
    
    Return a JSON array of objects with the following structure:
    [
      {
        "name": "Food Name",
        "quantity": 1.0,
        "unit": "serving/cup/gram",
        "macros": {
          "calories": 0,
          "protein": 0,
          "carbs": 0,
          "fat": 0
        }
      }
    ]
    
    Give reasonable estimates. Only return the JSON. Do not include markdown formatting.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null) {
        throw Exception('Failed to generate content');
      }

      // Cleanup potential markdown code blocks
      final cleanedText = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      
      try {
        final List<dynamic> jsonList = jsonDecode(cleanedText);
        
        if (jsonList.isEmpty) {
          throw Exception('No food items found in AI response');
        }
        
        return jsonList.map((json) {
          try {
            return FoodItem.fromJson(json);
          } catch (e) {
            // Return a default food item if parsing fails
            return FoodItem(
              name: json['name']?.toString() ?? 'Unknown Food',
              quantity: (json['quantity'] ?? 1).toDouble(),
              unit: json['unit']?.toString() ?? 'serving',
              macros: MacroNutrients.fromJson(json['macros'] ?? {}),
            );
          }
        }).toList();
      } catch (e) {
        // Return a fallback food item based on description
        return [
          FoodItem(
            name: description,
            quantity: 1,
            unit: 'serving',
            macros: const MacroNutrients(calories: 200, protein: 10, carbs: 30, fat: 5),
          ),
        ];
      }

    } catch (e) {
      // Return a fallback instead of rethrowing to prevent crashes
      return [
        FoodItem(
          name: description,
          quantity: 1,
          unit: 'serving',
          macros: const MacroNutrients(calories: 200, protein: 10, carbs: 30, fat: 5),
        ),
      ];
    }
  }
}

final aiFoodServiceProvider = Provider<AiFoodService>((ref) {
  return AiFoodService();
});
