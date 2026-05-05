import '../config/api_config.dart';
import '../models/recipe_model.dart';
import 'api_service.dart';

class RecipeService {
  final ApiService _apiService = ApiService();

  // Récupérer toutes les recettes ou filtrer par recherche/type
  Future<List<RecipeModel>> getRecipes({String? search, String? type, String? mealType}) async {
    try {
      String endpoint = ApiConfig.recipes;
      List<String> params = [];
      if (search != null && search.isNotEmpty) {
        params.add('search=${Uri.encodeComponent(search)}');
      }
      if (type != null && type.isNotEmpty) {
        params.add('type=$type');
      }
      if (mealType != null && mealType.isNotEmpty) {
        params.add('meal_type=$mealType');
      }
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }
      print("RecipeService: GET $endpoint");
      final response = await _apiService.get(endpoint);
      print("RecipeService: Response data length = ${response['data']?.length ?? 0}");
      
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => RecipeModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des recettes: $e');
    }
  }

  // Créer une nouvelle recette
  Future<RecipeModel> createRecipe(Map<String, dynamic> recipeData) async {
    try {
      final response = await _apiService.post(ApiConfig.recipes, recipeData);
      return RecipeModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Erreur lors de la création de la recette: $e');
    }
  }

  // Récupérer une recette par ID
  Future<RecipeModel> getRecipeById(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.recipes}/$id');
      return RecipeModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la recette: $e');
    }
  }

  // Mettre à jour une recette
  Future<RecipeModel> updateRecipe(int id, Map<String, dynamic> recipeData) async {
    try {
      final response = await _apiService.put('${ApiConfig.recipes}/$id', recipeData);
      return RecipeModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la recette: $e');
    }
  }

  // Supprimer une recette
  Future<void> deleteRecipe(int id) async {
    try {
      await _apiService.delete('${ApiConfig.recipes}/$id');
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la recette: $e');
    }
  }
}
