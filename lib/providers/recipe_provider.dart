import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  
  List<RecipeModel> _recipes = [];
  bool _isLoading = false;
  String? _error;

  List<RecipeModel> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRecipes({String? type, String? mealType, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _recipeService.getRecipes(type: type, mealType: mealType, search: search);
      if (kDebugMode) debugPrint("RecipeProvider: Successfully loaded ${_recipes.length} recipes");
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) debugPrint("RecipeProvider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<RecipeModel> getRecipesByType(String type) {
    return _recipes.where((r) => r.type?.toLowerCase() == type.toLowerCase()).toList();
  }
}
