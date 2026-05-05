import '../config/api_config.dart';
import 'api_service.dart';

class IncidentService {
  final ApiService _apiService = ApiService();

  /// POST /api/incidents — Signaler un incident
  Future<Map<String, dynamic>> createIncident({
    required int missionId,
    required String type,
    required String description,
    String gravite = 'Moyenne',
    String statut = 'Signalé',
  }) async {
    try {
      final response = await _apiService.post('/incidents', {
        'mission_id': missionId,
        'type': type,
        'description': description,
        'gravite': gravite,
        'statut': statut,
      });
      return response['data'] ?? response;
    } catch (e) {
      throw Exception('Erreur lors du signalement de l\'incident: $e');
    }
  }

  /// GET /api/incidents — Récupérer tous les incidents (admin)
  Future<List<Map<String, dynamic>>> getIncidents() async {
    try {
      final response = await _apiService.get('/incidents');
      final List<dynamic> data = response['data'] ?? [];
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des incidents: $e');
    }
  }

  /// GET /api/incidents?mission_id={id} — Incidents d'une mission
  Future<List<Map<String, dynamic>>> getIncidentsByMission(int missionId) async {
    try {
      final response = await _apiService.get('/incidents?mission_id=$missionId');
      final List<dynamic> data = response['data'] ?? [];
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des incidents: $e');
    }
  }
}
