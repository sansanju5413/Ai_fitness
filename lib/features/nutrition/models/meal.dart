import 'package:cloud_firestore/cloud_firestore.dart';

class MealLog {
  final String id;
  final String userId;
  final DateTime date;
  final List<Meal> meals;

  MealLog({
    required this.id,
    required this.userId,
    required this.date,
    this.meals = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'date': Timestamp.fromDate(date),
        'meals': meals.map((e) => e.toJson()).toList(),
      };

  factory MealLog.fromJson(Map<String, dynamic> json) => MealLog(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        date: (json['date'] as Timestamp).toDate(),
        meals: (json['meals'] as List? ?? []).map((e) => Meal.fromJson(e)).toList(),
      );
  
  // Helpers
  MacroNutrients get totalMacros {
    return meals.fold(
      MacroNutrients.zero(),
      (prev, element) => prev + element.totalMacros,
    );
  }
}

class Meal {
  final String id;
  final String name; // Breakfast, Lunch, Snack
  final DateTime time; // Time of day
  final List<FoodItem> items;

  Meal({
    required this.id,
    required this.name,
    required this.time,
    required this.items,
  });

   Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'time': Timestamp.fromDate(time),
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        time: (json['time'] as Timestamp).toDate(),
        items: (json['items'] as List? ?? []).map((e) => FoodItem.fromJson(e)).toList(),
      );

  MacroNutrients get totalMacros {
     return items.fold(
      MacroNutrients.zero(),
      (prev, element) => prev + element.macros,
    );
  }
}

class FoodItem {
  final String name;
  final double quantity; // e.g. 1
  final String unit; // e.g. serving, grams
  final MacroNutrients macros;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.macros,
  });

   Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'macros': macros.toJson(),
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        name: json['name'] ?? '',
        quantity: (json['quantity'] ?? 0).toDouble(),
        unit: json['unit'] ?? 'g',
        macros: MacroNutrients.fromJson(json['macros'] ?? {}),
      );
}

class MacroNutrients {
  final int calories;
  final int protein; // grams
  final int carbs; // grams
  final int fat; // grams

  const MacroNutrients({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MacroNutrients.zero() => const MacroNutrients(calories: 0, protein: 0, carbs: 0, fat: 0);

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory MacroNutrients.fromJson(Map<String, dynamic> json) => MacroNutrients(
        calories: json['calories'] ?? 0,
        protein: json['protein'] ?? 0,
        carbs: json['carbs'] ?? 0,
        fat: json['fat'] ?? 0,
      );

  MacroNutrients operator +(MacroNutrients other) {
    return MacroNutrients(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
    );
  }
}
