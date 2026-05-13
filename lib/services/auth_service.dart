import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Pour kIsWeb

class AuthService {
  final ApiService _apiService = ApiService();

  // Connexion (retourne Map avec success, user, token)
  Future<Map<String, dynamic>> login(String email, String password) async {
    return loginWithCode(email, password);
  }

  // Connexion avancée — retourne le code d'erreur structuré même pour les erreurs HTTP 403
  Future<Map<String, dynamic>> loginWithCode(String email, String password) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(ApiConfig.receiveTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        if (body['access_token'] != null) {
          _apiService.setToken(body['access_token']);
        }
        return {
          'success': true,
          'user': User.fromJson(body['user']),
          'token': body['access_token'],
        };
      } else {
        // Retourner le code d'erreur du backend (ex: pending_validation)
        return {
          'success': false,
          'code': body['code'],
          'message': body['message'] ?? 'Erreur de connexion',
        };
      }
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
    required String password,
    String? phone,
    String? address,
    String? role,
    // Champs spécifiques CLIENT
    String? nomEtablissement,
    String? typeEtablissement,
    String? codePostal,
    String? ville,
    String? capacite,
    String? fonction,
    String? telephoneEtablissement,
    // Fichiers (Peuvent être String (path) ou PlatformFile/Uint8List (bytes))
    dynamic contratPrestationPath,
    dynamic planLocauxPath,
    dynamic reglementInterieurPath,
    // Champs spécifiques PROFESSIONNEL
    String? dateNaissance,
    String? diplome,
    String? anneesExperience,
    List<String>? specialites,
    dynamic photoProfilPath,
    List<dynamic>? diplomePaths, // Modifié pour accepter une liste
    dynamic certificatMedicalPath,
    dynamic permisConduirePath,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'));
      
      // Champs texte obligatoires
      request.fields['prenom'] = firstName;
      request.fields['nom'] = lastName;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = password;

      // Champs texte optionnels
      if (phone != null) request.fields['telephone'] = phone;
      if (address != null) request.fields['adresse'] = address;
      if (role != null) request.fields['role'] = role;
      
      // Champs CLIENT
      if (nomEtablissement != null) request.fields['nom_etablissement'] = nomEtablissement;
      if (typeEtablissement != null) request.fields['type_etablissement'] = typeEtablissement;
      if (codePostal != null) request.fields['code_postal'] = codePostal;
      if (ville != null) request.fields['ville'] = ville;
      if (capacite != null) request.fields['capacite'] = capacite;
      if (fonction != null) request.fields['fonction'] = fonction;
      if (telephoneEtablissement != null) request.fields['telephone_etablissement'] = telephoneEtablissement;
      
      // Champs PROFESSIONNEL
      if (dateNaissance != null) request.fields['date_naissance'] = dateNaissance;
      if (diplome != null) request.fields['diplome'] = diplome;
      if (anneesExperience != null) request.fields['annees_experience'] = anneesExperience;
      
      // Listes PROFESSIONNEL
      if (specialites != null) {
        for (int i = 0; i < specialites.length; i++) {
          request.fields['specialites[$i]'] = specialites[i];
        }
      }

      // Helper pour ajouter les fichiers
      Future<void> _addFile(String field, dynamic fileData) async {
        if (fileData == null) return;
        
        try {
          if (fileData is String) {
             // C'est un chemin de fichier (Mobile - String directe)
             if (fileData.contains('/') || fileData.contains('\\')) {
               request.files.add(await http.MultipartFile.fromPath(field, fileData));
             }
          } else if (fileData is List<int>) { 
             // Ce sont des bytes directs
             request.files.add(http.MultipartFile.fromBytes(field, fileData, filename: 'upload.jpg'));
          } else {
             // Essayer de traiter comme PlatformFile (de file_picker)
             // Sur le Web, on NE DOIT PAS accéder à .path sinon ça crash
             // On utilise kIsWeb pour être sûr
             if (kIsWeb) {
                final bytes = (fileData as dynamic).bytes;
                final name = (fileData as dynamic).name;
                if (bytes != null) {
                  request.files.add(http.MultipartFile.fromBytes(field, bytes, filename: name ?? 'upload.bin'));
                }
             } else {
                // Sur Mobile/Desktop, on préfère le chemin s'il existe
                final path = (fileData as dynamic).path;
                if (path != null) {
                  request.files.add(await http.MultipartFile.fromPath(field, path));
                } else {
                  // Fallback bytes si disponibles même hors web
                  final bytes = (fileData as dynamic).bytes;
                  final name = (fileData as dynamic).name;
                  if (bytes != null) {
                    request.files.add(http.MultipartFile.fromBytes(field, bytes, filename: name ?? 'upload.bin'));
                  }
                }
             }
          }
        } catch (e) {
           print('Erreur lors de l\'ajout du fichier ($field): $e');
        }
      }

      // Fichiers CLIENT
      await _addFile('contrat_prestation_path', contratPrestationPath);
      await _addFile('plan_locaux_path', planLocauxPath);
      await _addFile('reglement_interieur_path', reglementInterieurPath);

      // Fichiers PROFESSIONNEL
      await _addFile('photo_profil_path', photoProfilPath);
      
      // Envoi de multiples diplômes
      if (diplomePaths != null && diplomePaths.isNotEmpty) {
        for (int i = 0; i < diplomePaths.length; i++) {
          await _addFile('diplome_path[]', diplomePaths[i]);
        }
      }
      
      await _addFile('certificat_medical_path', certificatMedicalPath);
      await _addFile('permis_conduire_path', permisConduirePath);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      final responseBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseBody['access_token'] != null) {
          _apiService.setToken(responseBody['access_token']);
        }
        return {
          'success': true,
          'user': User.fromJson(responseBody['user']),
          'token': responseBody['access_token'],
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Erreur lors de l\'inscription',
          'errors': responseBody['errors'], // Propager les erreurs
        };
      }
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
      // Clés de fichiers gérées en multipart
      const fileKeys = [
        'photo_profil_path',
        'contrat_prestation_path',
        'plan_locaux_path',
        'reglement_interieur_path',
      ];

      // Extraire les fichiers du map
      final Map<String, dynamic> files = {};
      for (final key in fileKeys) {
        if (data.containsKey(key)) {
          files[key] = data.remove(key);
        }
      }

      // Toujours utiliser multipart (Laravel gère mieux _method=PUT)
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiConfig.baseUrl}${ApiConfig.updateProfileEndpoint}'));
      request.headers.addAll(ApiConfig.getHeaders(token: _apiService.token));
      request.headers.remove('Content-Type');

      // Spoofing de la méthode PUT pour Laravel
      request.fields['_method'] = 'PUT';

      // Champs texte — mapping exact vers les noms attendus par le backend
      data.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          // Mapper les clés Flutter → clés backend Laravel
          final backendKey = _mapFieldKey(key);
          request.fields[backendKey] = value.toString();
        }
      });

      // Ajouter chaque fichier
      for (final entry in files.entries) {
        final key = entry.key;
        final fileData = entry.value;
        if (fileData == null) continue;

        if (fileData is String) {
          if (!kIsWeb) {
            request.files.add(await http.MultipartFile.fromPath(key, fileData));
          }
        } else if (fileData is Map<String, dynamic> &&
            fileData.containsKey('bytes')) {
          request.files.add(http.MultipartFile.fromBytes(
            key,
            fileData['bytes'],
            filename: fileData['name'] ?? 'upload.bin',
          ));
        }
      }

      // DEBUG
      User.debugLog('=== UPDATE PROFILE ===');
      User.debugLog('URL: ${ApiConfig.baseUrl}${ApiConfig.updateProfileEndpoint}');
      User.debugLog('Fields: ${request.fields}');
      User.debugLog('Files: ${request.files.map((f) => f.field).toList()}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      User.debugLog('Status: ${response.statusCode}');
      User.debugLog('Response: ${response.body.length > 800 ? response.body.substring(0, 800) : response.body}');
      User.debugLog('======================');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'user': User.fromJson(responseBody['user'] ?? responseBody),
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Erreur ${response.statusCode}',
          'errors': responseBody['errors'],
        };
      }
    } catch (e) {
      User.debugLog('=== UPDATE PROFILE ERROR: $e ===');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Mappe les clés Flutter vers les noms de champs attendus par le backend
  String _mapFieldKey(String key) {
    const map = {
      'firstName': 'prenom',
      'lastName': 'nom',
      'phone': 'telephone',
      // Les autres clés sont déjà au bon format snake_case
    };
    return map[key] ?? key;
  }

  // Récupérer la liste des professionnels
  Future<List<User>> getProfessionals() async {
    try {
      final response = await _apiService.get(ApiConfig.professionals);
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des professionnels: $e');
      return [];
    }
  }

  // Récupérer la liste des structures
  Future<List<User>> getStructures() async {
    try {
      final response = await _apiService.get(ApiConfig.structures);
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des structures: $e');
      return [];
    }
  }

  // Récupérer une structure par son ID (données fraîches)
  Future<User?> getStructureById(String userId) async {
    try {
      final response = await _apiService.get('${ApiConfig.structures}/$userId');
      if (response['data'] != null) {
        return User.fromJson(response['data']);
      }
      if (response['user'] != null) {
        return User.fromJson(response['user']);
      }
      // Fallback : la réponse est directement l'objet user
      if (response['id'] != null) {
        return User.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la structure $userId: $e');
      return null;
    }
  }

  // Valider ou refuser un utilisateur (Admin)
  Future<Map<String, dynamic>> validateUser(String userId, String statut) async {
    try {
      final response = await _apiService.put(
        '/users/$userId/validate',
        {'statut_validation': statut},
      );
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Supprimer définitivement un utilisateur (Admin)
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await _apiService.delete('/users/$userId');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Changer le mot de passe
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.put('/user/password', {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      });
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Mot de passe oublié
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiService.post('/forgot-password', {
        'email': email,
      });
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Réinitialiser le mot de passe
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post('/reset-password', {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': confirmPassword,
      });
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
