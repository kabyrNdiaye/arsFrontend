import 'dart:async';
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

  String? get token => _token;

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
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWithRetry(
    String endpoint, {int maxRetries = 3}) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await get(endpoint)
            .timeout(const Duration(seconds: 15));
      } on TimeoutException {
        attempt++;
        if (attempt == maxRetries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Impossible de joindre le serveur.');
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
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  }

  // Méthode pour upload de fichiers
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String? filePath,
    String fieldName, {
    Map<String, String>? additionalFields,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      );

      // Ajouter les headers
      request.headers.addAll(ApiConfig.getHeaders(token: _token));
      request.headers.remove('Content-Type'); // MultipartRequest le gère automatiquement

      // Ajouter le fichier (Path ou Bytes)
      if (fileBytes != null && fileName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: fileName,
        ));
      } else if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      }

      // Ajouter les autres champs
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(ApiConfig.receiveTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Gestion de la réponse
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    Map<String, dynamic> responseBody = {};
    
    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      // Si le corps n'est pas du JSON
    }

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else if (statusCode == 401) {
      // Token expiré ou identifiants invalides
      clearToken();
      final message = responseBody['message'] ?? 'Session expirée ou identifiants invalides.';
      throw message;
    } else {
      final message = responseBody['message'] ?? 'Erreur serveur: $statusCode';
      throw message;
    }
  }
}

