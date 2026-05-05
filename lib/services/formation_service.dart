import '../config/api_config.dart';
import 'api_service.dart';
import '../models/formation_model.dart';

class FormationService {
  final ApiService _apiService = ApiService();

  // Récupérer toutes les formations
  Future<List<FormationModel>> getFormations() async {
    try {
      final response = await _apiService.get(ApiConfig.formations);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => FormationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des formations: $e');
    }
  }

  // Créer une formation
  Future<FormationModel> createFormation(Map<String, dynamic> formationData) async {
    try {
      final response = await _apiService.post(ApiConfig.formations, formationData);
      return FormationModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Erreur lors de la création de la formation: $e');
    }
  }

  // Mettre à jour une formation
  Future<FormationModel> updateFormation(int id, Map<String, dynamic> formationData) async {
    try {
      final response = await _apiService.put('${ApiConfig.formations}/$id', formationData);
      return FormationModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la formation: $e');
    }
  }

  // Supprimer une formation
  Future<void> deleteFormation(int id) async {
    try {
      await _apiService.delete('${ApiConfig.formations}/$id');
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la formation: $e');
    }
  }

  // Récupérer une formation par ID
  Future<FormationModel> getFormationById(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.formations}/$id');
      return FormationModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la formation: $e');
    }
  }
}
