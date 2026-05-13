import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:itea_app/config/api_config.dart';
import 'package:itea_app/models/mission_model.dart';
import 'package:itea_app/services/api_service.dart';

class MissionService {
  final ApiService _apiService = ApiService();

  // Récupérer toutes les missions
  Future<List<MissionModel>> getMissions() async {
    try {
      final response = await _apiService.get(ApiConfig.missions);
      debugPrint('MissionService.getMissions: raw response = $response');
      final List<dynamic> data = response is List ? response : (response['data'] ?? []);
      debugPrint('MissionService.getMissions: data length = ${data.length}');
      return data.map((json) {
        if (json is String) {
          try {
            json = jsonDecode(json);
          } catch (_) {}
        }
        return MissionModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des missions: $e');
    }
  }

  // Créer une nouvelle mission
  Future<MissionModel> createMission(Map<String, dynamic> missionData) async {
    try {
      debugPrint('=== CREATE MISSION ===');
      debugPrint('Data envoyée: $missionData');
      final response = await _apiService.post(ApiConfig.missions, missionData);
      debugPrint('Réponse: $response');
      return MissionModel.fromJson(response['data']);
    } catch (e) {
      debugPrint('ERREUR createMission: $e');
      throw Exception('Erreur lors de la création de la mission: $e');
    }
  }

  // Récupérer une mission par ID
  Future<Map<String, dynamic>> getMissionById(int id) async {
    try {
      return await _apiService.get('${ApiConfig.missions}/$id');
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la mission: $e');
    }
  }

  // Accepter une mission
  Future<Map<String, dynamic>> acceptMission(int missionId) async {
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
  Future<Map<String, dynamic>> rejectMission(int missionId) async {
    try {
      return await _apiService.post(
        '${ApiConfig.missions}/$missionId/reject',
        {},
      );
    } catch (e) {
      throw Exception('Erreur lors du refus de la mission: $e');
    }
  }

  // Mettre à jour une mission
  Future<MissionModel> updateMission(int id, Map<String, dynamic> missionData) async {
    try {
      final response = await _apiService.put('${ApiConfig.missions}/$id', missionData);
      return MissionModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la mission: $e');
    }
  }

  // Traiter une mission (Admin)
  Future<MissionModel> processMission(int id, Map<String, dynamic> processData) async {
    try {
      final response = await _apiService.put('${ApiConfig.missions}/$id/process', processData);
      return MissionModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Erreur lors du traitement de la mission: $e');
    }
  }

  // Supprimer une mission (Admin)
  Future<void> deleteMission(int id) async {
    try {
      await _apiService.delete('${ApiConfig.missions}/$id');
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la mission: $e');
    }
  }

  // Récupérer les statistiques globales (Admin)
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final t = DateTime.now().millisecondsSinceEpoch;
      final response = await _apiService.get('${ApiConfig.adminStats}?t=$t');
      return response['data'] ?? {};
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
  
  // Récupérer les statistiques de la structure (Client)
  Future<Map<String, dynamic>> getStructureStats() async {
    try {
      final response = await _apiService.get(ApiConfig.structureStats);
      return response['data'] ?? {};
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques structure: $e');
    }
  }

  // --- Gestion du Chat ---

  // Récupérer les messages d'une mission
  Future<List<Map<String, dynamic>>> getChatMessages(int missionId) async {
    try {
      final response = await _apiService.get('${ApiConfig.missions}/$missionId/messages');
      // On retourne directement la liste des messages (data)
      return List<Map<String, dynamic>>.from(response is List ? response : (response['data'] ?? []));
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }

  // Envoyer un message pour une mission
  Future<Map<String, dynamic>> sendChatMessage(
    int missionId, 
    String? content, {
    String type = 'text',
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final Map<String, String> fields = {
        'type': type,
        if (content != null) 'content': content,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      if (filePath != null || fileBytes != null) {
        final response = await _apiService.uploadFile(
          '${ApiConfig.missions}/$missionId/messages',
          filePath,
          'file',
          additionalFields: fields,
          fileBytes: fileBytes,
          fileName: fileName,
        );
        return response['data'] ?? response;
      } else {
        final response = await _apiService.post(
          '${ApiConfig.missions}/$missionId/messages',
          fields,
        );
        return response['data'] ?? response;
      }
    } catch (e) {
      throw Exception('Erreur lors de l’envoi du message: $e');
    }
  }

  // Marquer les messages comme lus pour une mission spécifique
  Future<void> markChatAsRead(int missionId) async {
    try {
      await _apiService.put('${ApiConfig.missions}/$missionId/messages/read', {});
    } catch (e) {
      debugPrint('Erreur lors du marquage comme lu (mission $missionId): $e');
    }
  }

  // Marquer TOUS les messages comme lus (toutes les missions)
  Future<void> markAllChatsAsRead() async {
    try {
      await _apiService.put('${ApiConfig.missions}/messages/read-all', {});
    } catch (e) {
      debugPrint('Erreur lors du marquage de tous les messages comme lus: $e');
      // Optionnel: Rejeter si c'est important, mais ici on gère en silence
    }
  }

  // Marquer un message spécifique comme traité (Admin)
  Future<void> markMessageAsHandled(int messageId) async {
    try {
      await _apiService.put('/messages/$messageId/handled', {});
    } catch (e) {
      debugPrint('Erreur lors du marquage comme traité: $e');
      throw Exception('Erreur lors du marquage comme traité: $e');
    }
  }

  // Mettre à jour la checklist de la mission
  Future<void> updateChecklist(int missionId, Map<String, bool> checklist) async {
    try {
      await _apiService.put(
        '${ApiConfig.missions}/$missionId/checklist',
        {'checklist_journee': checklist},
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la checklist: $e');
    }
  }

  // Terminer une mission
  Future<void> finishMission(int missionId) async {
    try {
      await _apiService.post(
        '${ApiConfig.missions}/$missionId/finish',
        {},
      );
    } catch (e) {
      throw Exception('Erreur lors de la fin de la mission: $e');
    }
  }

  /// Valider la fin de mission via QR Code (côté structure)
  Future<void> completeMissionByQr(
      int missionId, Map<String, dynamic> qrPayload) async {
    try {
      await _apiService.post(
        '${ApiConfig.missions}/$missionId/complete-by-qr',
        qrPayload,
      );
    } catch (e) {
      throw Exception('Erreur lors de la validation QR : $e');
    }
  }

  // Annuler une mission acceptée (professionnel)
  Future<Map<String, dynamic>> cancelMission(int missionId, String motif) async {
    try {
      return await _apiService.post(
        '${ApiConfig.missions}/$missionId/cancel',
        {'motif': motif},
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la mission: $e');
    }
  }
}

