import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itea_app/models/mission_model.dart';
import 'package:itea_app/services/mission_service.dart';

class MissionProvider with ChangeNotifier {
  final MissionService _missionService = MissionService();
  
  List<MissionModel> _missions = [];
  Map<String, dynamic> _adminStats = {};
  Map<String, dynamic> _structureStats = {};
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;

  // IDs des missions déjà vues par l'admin (stockés localement)
  Set<int> _viewedMissionIds = {};
  static const String _viewedKey = 'admin_viewed_mission_ids';

  List<MissionModel> get missions => _missions;
  Map<String, dynamic> get adminStats => _adminStats;
  Map<String, dynamic> get structureStats => _structureStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MissionProvider() {
    _loadViewedMissions();
  }

  /// Charge les IDs des missions vues depuis SharedPreferences
  Future<void> _loadViewedMissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> ids = prefs.getStringList(_viewedKey) ?? [];
      _viewedMissionIds = ids.map((id) => int.tryParse(id) ?? 0).toSet();
    } catch (_) {}
  }

  /// Marque une mission comme vue par l'admin
  Future<void> markMissionAsViewed(int missionId) async {
    if (_viewedMissionIds.contains(missionId)) return;
    _viewedMissionIds.add(missionId);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _viewedKey,
        _viewedMissionIds.map((id) => id.toString()).toList(),
      );
    } catch (_) {}
  }

  /// Démarre le polling automatique toutes les 15 secondes
  /// Si un polling est déjà actif, ne fait rien
  void startPolling() {
    if (_pollingTimer != null && _pollingTimer!.isActive) {
      return; // Polling déjà actif, ne pas en créer un second
    }
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _silentFetch();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Fetch silencieux (sans mettre _isLoading à true) pour le polling
  Future<void> _silentFetch() async {
    try {
      final updated = await _missionService.getMissions();

      // Comparer les compteurs de messages non lus
      bool hasNewMessages = false;
      for (final newM in updated) {
        final existing = _missions.firstWhere(
          (m) => m.id == newM.id,
          orElse: () => newM,
        );
        if (newM.unreadMessagesCount > existing.unreadMessagesCount) {
          hasNewMessages = true;
          debugPrint('MissionProvider: nouveau message sur mission ${newM.id}');
          break;
        }
      }

      // Préserver les missions localement marquées comme lues
      // (ne pas écraser unreadMessagesCount=0 si on vient de lire)
      for (int i = 0; i < updated.length; i++) {
        final local = _missions.firstWhere(
          (m) => m.id == updated[i].id,
          orElse: () => updated[i],
        );
        // Si localement on a mis à 0 mais le backend renvoie encore > 0,
        // garder 0 (l'utilisateur vient de lire, le backend n'est pas encore sync)
        if (local.unreadMessagesCount == 0 && updated[i].unreadMessagesCount > 0) {
          updated[i] = updated[i].copyWith(unreadMessagesCount: 0);
        }
      }

      _missions = updated;
      if (hasNewMessages) notifyListeners();
      else notifyListeners(); // Toujours notifier pour les nouvelles missions
    } catch (e) {
      debugPrint('MissionProvider._silentFetch error: $e');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  bool get hasOngoingMission => _missions.any((m) => 
    (m.status.toLowerCase() == 'en cours' || m.userStatus == 'confirmé') && 
    m.status.toLowerCase() != 'terminé' &&
    m.status.toLowerCase() != 'terminée'
  );

  int get totalUnreadMessagesCount {
    int total = 0;
    for (var m in _missions) {
      final status = m.status.toLowerCase().trim();
      // Exclure les missions terminées — leurs messages sont déjà lus
      if (status != 'terminé' && status != 'terminée' &&
          status != 'finished' && status != 'termine') {
        total += m.unreadMessagesCount;
      }
    }
    return total;
  }

  /// Nombre de nouvelles missions (< 48h) non vues — pour admin, structures ET professionnels
  int get newMissionsCount {
    final now = DateTime.now();
    return _missions.where((m) {
      final status = m.status.toLowerCase().trim();
      final isActive = status != 'terminé' &&
          status != 'terminée' &&
          status != 'finished' &&
          status != 'termine' &&
          status != 'refusé' &&
          status != 'refuse';
      final isRecent = now.difference(m.createdAt).inHours < 48;
      return isActive && isRecent && !_viewedMissionIds.contains(m.id);
    }).length;
  }

  Future<void> fetchMissions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _missions = await _missionService.getMissions();
      debugPrint('MissionProvider: fetched ${_missions.length} missions');
    } catch (e, st) {
      _error = e.toString();
      debugPrint('MissionProvider.fetchMissions error: $_error');
      debugPrint(st.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MissionModel?> createMission(Map<String, dynamic> missionData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMission = await _missionService.createMission(missionData);
      _missions.insert(0, newMission); // Ajouter la nouvelle mission en haut de la liste
      debugPrint('MissionProvider: added mission id=${newMission.id}');
      return newMission;
    } catch (e, st) {
      _error = e.toString();
      debugPrint('MissionProvider.createMission error: $_error');
      debugPrint(st.toString());
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptMission(int missionId) async {
    try {
      await _missionService.acceptMission(missionId);
      // Optionnel: Mettre à jour l'état local si nécessaire ou re-fetch
      await fetchMissions();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectMission(int missionId) async {
    try {
      await _missionService.rejectMission(missionId);
      await fetchMissions();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<MissionModel?> updateMission(int missionId, Map<String, dynamic> data) async {
    try {
      final updated = await _missionService.updateMission(missionId, data);
      final index = _missions.indexWhere((m) => m.id == missionId);
      if (index != -1) {
        _missions[index] = updated;
        notifyListeners();
      }
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void markMissionAsReadLocal(int missionId) {
    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index != -1) {
      _missions[index] = _missions[index].copyWith(unreadMessagesCount: 0);
      notifyListeners();
    }
    // Appel asynchrone au service pour le backend sans attendre
    _missionService.markChatAsRead(missionId);
  }

  Future<void> markAllMessagesAsRead() async {
    // Parcourir toutes les missions pour mettre le compteur à zéro localement
    for (int i = 0; i < _missions.length; i++) {
      if (_missions[i].unreadMessagesCount > 0) {
        _missions[i] = _missions[i].copyWith(unreadMessagesCount: 0);
      }
    }
    notifyListeners();

    // Appeler le service pour marquer tout comme lu sur le serveur
    try {
      await _missionService.markAllChatsAsRead();
    } catch (e) {
      debugPrint('MissionProvider.markAllMessagesAsRead error: $e');
    }
  }

  Future<void> fetchAdminStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _adminStats = await _missionService.getAdminStats();
      debugPrint('MissionProvider: fetched admin stats');
    } catch (e) {
      _error = e.toString();
      debugPrint('MissionProvider.fetchAdminStats error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStructureStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _structureStats = await _missionService.getStructureStats();
      debugPrint('MissionProvider: fetched structure stats');
    } catch (e) {
      _error = e.toString();
      debugPrint('MissionProvider.fetchStructureStats error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
