import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // Instance singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // Définir le token d'authentification
  void setToken(String token) {
    _token = token;
  }

  // Supprimer le token
  void clearToken() {
    _token = null;
  }

  // Méthode générique pour les requêtes GET
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: ApiConfig.getHeaders(token: _token),
      ).timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode générique pour les requêtes POST
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: ApiConfig.getHeaders(token: _token),
        body: jsonEncode(data),
      ).timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode générique pour les requêtes PUT
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: ApiConfig.getHeaders(token: _token),
        body: jsonEncode(data),
      ).timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode générique pour les requêtes DELETE
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: ApiConfig.getHeaders(token: _token),
      ).timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode pour upload de fichiers
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath,
    String fieldName,
    Map<String, String>? additionalFields,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      );

      // Ajouter les headers
      request.headers.addAll(ApiConfig.getHeaders(token: _token));
      request.headers.remove('Content-Type'); // MultipartRequest le gère automatiquement

      // Ajouter le fichier
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      // Ajouter les autres champs
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(ApiConfig.receiveTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  // Gestion de la réponse
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = jsonDecode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else if (statusCode == 401) {
      // Token expiré ou invalide
      clearToken();
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    } else {
      throw Exception(
        responseBody['message'] ?? 'Erreur serveur: $statusCode',
      );
    }
  }
}

