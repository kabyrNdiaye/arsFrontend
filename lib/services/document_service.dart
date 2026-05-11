import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'api_service.dart';

/// Modèle léger pour un document retourné par /api/my-documents
class DocumentItem {
  final int id;
  final String nom;
  final String url;
  final String statut;

  DocumentItem({
    required this.id,
    required this.nom,
    required this.url,
    required this.statut,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nom: json['nom']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      statut: json['statut']?.toString() ?? 'actif',
    );
  }

  /// Nom d'affichage lisible (traduit les clés techniques)
  String get displayName {
    switch (nom) {
      case 'diplome_path':
      case 'Diplôme de cuisine':     return 'Diplôme de cuisine';
      case 'certificat_medical_path':
      case 'Certificat médical':     return 'Certificat médical';
      case 'permis_conduire_path':
      case 'Permis de conduire':    return 'Permis de conduire';
      case 'cv_path':
      case 'Curriculum Vitae(CV)':   return 'Curriculum Vitae(CV)';
      case 'identite_path':
      case 'Carte d\'identité':      return 'Carte d\'identité';
      default:                       return nom;
    }
  }

  bool get isFixed =>
      nom == 'diplome_path' || nom == 'Diplôme de cuisine' ||
      nom == 'certificat_medical_path' || nom == 'Certificat médical' ||
      nom == 'permis_conduire_path' || nom == 'Permis de conduire' ||
      nom == 'cv_path' || nom == 'Curriculum Vitae(CV)' ||
      nom == 'identite_path' || nom == 'Carte d\'identité';
}

class DocumentService {
  final ApiService _apiService = ApiService();

  Map<String, String> get _authHeaders {
    final token = ApiService().token;
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // ─── GET /api/my-documents ───────────────────────────────────────────────
  /// Retourne tous les documents du professionnel connecté avec leurs IDs
  Future<List<DocumentItem>> getMyDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.myDocuments}'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> all = body['all'] ?? [];
        return all.map((d) => DocumentItem.fromJson(d)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur récupération documents: $e');
    }
  }

  // ─── POST /api/documents ─────────────────────────────────────────────────
  /// Ajoute un nouveau document
  Future<DocumentItem> addDocument({
    required String nom,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    String type = 'document',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documents}'),
      );
      request.headers.addAll(_authHeaders);
      request.fields['nom'] = nom;
      request.fields['type'] = type;

      await _attachFile(request, 'document', filePath, fileBytes, fileName);

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DocumentItem.fromJson(body['document']);
      } else {
        throw Exception(body['message'] ?? 'Erreur ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur ajout document: $e');
    }
  }

  // ─── POST /api/documents/{id} (_method=PUT) ──────────────────────────────
  /// Remplace le fichier d'un document existant (par son ID)
  Future<DocumentItem> updateDocument({
    required int id,
    String? nom,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documents}/$id'),
      );
      request.headers.addAll(_authHeaders);
      request.fields['_method'] = 'PUT';

      if (nom != null) request.fields['nom'] = nom;

      if (filePath != null || fileBytes != null) {
        await _attachFile(request, 'document', filePath, fileBytes, fileName);
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return DocumentItem.fromJson(body['document']);
      } else {
        throw Exception(body['message'] ?? 'Erreur ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur modification document: $e');
    }
  }

  // ─── DELETE /api/documents/{id} ──────────────────────────────────────────
  Future<void> deleteDocument(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documents}/$id'),
        headers: _authHeaders,
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Erreur ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur suppression document: $e');
    }
  }

  // ─── Ancienne méthode conservée pour compatibilité ───────────────────────
  Future<List<dynamic>> getDocuments() async {
    try {
      final response = await _apiService.get(ApiConfig.documents);
      return response['data'] ?? [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des documents: $e');
    }
  }

  Future<Map<String, dynamic>> uploadDocument(
    String? filePath,
    String type, {
    List<int>? fileBytes,
    String? fileName,
  }) async {
    try {
      final String nomDocument =
          fileName ?? (filePath != null ? filePath.split('/').last : 'Document');
      return await _apiService.uploadFile(
        ApiConfig.documents,
        filePath,
        'document',
        additionalFields: {'type': type, 'nom': nomDocument},
        fileBytes: fileBytes,
        fileName: fileName,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du document: $e');
    }
  }

  // ─── Helper privé ────────────────────────────────────────────────────────
  Future<void> _attachFile(
    http.MultipartRequest request,
    String field,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  ) async {
    if (kIsWeb && fileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        field,
        fileBytes,
        filename: fileName ?? 'document',
      ));
    } else if (!kIsWeb && filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(field, filePath));
    }
  }
}
