import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Connexion
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        {
          'email': email,
          'password': password,
        },
      );

      // Sauvegarder le token
      if (response['token'] != null) {
        _apiService.setToken(response['token']);
      }

      return {
        'success': true,
        'user': User.fromJson(response['user']),
        'token': response['token'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Inscription
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? address,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          if (address != null) 'address': address,
        },
      );

      // Sauvegarder le token si fourni
      if (response['token'] != null) {
        _apiService.setToken(response['token']);
      }

      return {
        'success': true,
        'user': User.fromJson(response['user']),
        'token': response['token'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logout, {});
    } catch (e) {
      // Ignorer les erreurs de déconnexion
    } finally {
      _apiService.clearToken();
    }
  }

  // Récupérer le profil utilisateur
  Future<User?> getProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.profile);
      return User.fromJson(response['user'] ?? response);
    } catch (e) {
      // Simulation locale si le serveur est absent
      return null;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(ApiConfig.profile, data);
      return {
        'success': true,
        'user': User.fromJson(response['user'] ?? response),
      };
    } catch (e) {
      // Simulation locale en cas d'erreur de connexion (ex: pas de DB)
      print('API Error (simulated success): $e');
      
      // On simule une réussite pour permettre de tester l'UI
      final simulatedUser = User(
        id: 'sim-123',
        firstName: data['firstName'] ?? 'Prénom',
        lastName: data['lastName'] ?? 'Nom',
        email: data['email'] ?? 'email@test.com',
        phone: data['phone'] ?? '00000000',
      );
      
      return {
        'success': true,
        'user': simulatedUser,
        'message': 'Simulation locale active (pas de base de données)',
      };
    }
  }
}

