import '../config/api_config.dart';
import 'api_service.dart';

class MissionService {
  final ApiService _apiService = ApiService();

  // Récupérer toutes les missions
  Future<List<dynamic>> getMissions() async {
    try {
      final response = await _apiService.get(ApiConfig.missions);
      return response['missions'] ?? response['data'] ?? [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des missions: $e');
    }
  }

  // Récupérer une mission par ID
  Future<Map<String, dynamic>> getMissionById(String id) async {
    try {
      return await _apiService.get('${ApiConfig.missions}/$id');
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la mission: $e');
    }
  }

  // Accepter une mission
  Future<Map<String, dynamic>> acceptMission(String missionId) async {
    try {
      return await _apiService.post(
        '${ApiConfig.missions}/$missionId/accept',
        {},
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'acceptation de la mission: $e');
    }
  }

  // Refuser une mission
  Future<Map<String, dynamic>> rejectMission(String missionId) async {
    try {
      return await _apiService.post(
        '${ApiConfig.missions}/$missionId/reject',
        {},
      );
    } catch (e) {
      throw Exception('Erreur lors du refus de la mission: $e');
    }
  }
}

