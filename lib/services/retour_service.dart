import '../config/api_config.dart';
import 'api_service.dart';

class RetourService {
  final ApiService _apiService = ApiService();

  /// POST /api/retours — Soumettre un feedback/retour
  Future<Map<String, dynamic>> createRetour({
    required int missionId,
    required int note,
    required String commentaire,
    String? heureDebutEffectif,
    String? heureFinEffectif,
  }) async {
    try {
      final response = await _apiService.post('/retours', {
        'mission_id': missionId,
        'note': note,
        'commentaire': commentaire,
        if (heureDebutEffectif != null) 'heureDebutEffectif': heureDebutEffectif,
        if (heureFinEffectif != null) 'heureFinEffectif': heureFinEffectif,
      });
      return response['data'] ?? response;
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du retour: $e');
    }
  }

  /// GET /api/retours — Récupérer tous les retours (admin)
  Future<List<Map<String, dynamic>>> getRetours() async {
    try {
      final response = await _apiService.get('/retours');
      final List<dynamic> data = response['data'] ?? [];
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des retours: $e');
    }
  }

  /// GET /api/retours?mission_id={id} — Retours d'une mission
  Future<List<Map<String, dynamic>>> getRetoursByMission(int missionId) async {
    try {
      final response = await _apiService.get('/retours?mission_id=$missionId');
      final List<dynamic> data = response['data'] ?? [];
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des retours: $e');
    }
  }
}
