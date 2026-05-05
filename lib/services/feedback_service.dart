import '../config/api_config.dart';
import 'api_service.dart';

class FeedbackService {
  final ApiService _apiService = ApiService();

  // Envoyer un retour global (depuis l'accueil client)
  Future<Map<String, dynamic>> submitFeedback({
    required int rating,
    required String comment,
    String? type = 'general',
  }) async {
    try {
      final Map<String, dynamic> data = {
        'rating': rating,
        'comment': comment,
        'type': type,
      };
      
      print("FeedbackService: POST /feedbacks with data: $data");
      final response = await _apiService.post('/feedbacks', data);
      print("FeedbackService: Response: $response");
      
      return response['data'] ?? response;
    } catch (e) {
      print("FeedbackService Error: $e");
      throw Exception('Erreur lors de l\'envoi du retour: $e');
    }
  }

  // Récupérer les retours d'un utilisateur (optionnel, pour admin/professionnel)
  Future<List<Map<String, dynamic>>> getFeedbacks() async {
    try {
      final response = await _apiService.get('/feedbacks');
      final List<dynamic> data = response['data'] ?? [];
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des retours: $e');
    }
  }
}
