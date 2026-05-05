import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final String? type;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type,
    this.data,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return NotificationItem(
      id: json['id'],
      title: data['title'] ?? 'Notification',
      body: data['body'] ?? '',
      timestamp: DateTime.parse(json['created_at']),
      isRead: json['read_at'] != null,
      type: data['type'],
      data: data,
    );
  }
}

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Timer? _timer;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    _startPolling();
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchNotifications();
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  Future<void> fetchNotifications() async {
    final api = ApiService();
    _isLoading = true;
    notifyListeners();

    try {
      final response = await api.get('/notifications');
      final List<dynamic> data = response['data'] ?? [];
      final List<NotificationItem> fetched = data.map((json) => NotificationItem.fromJson(json)).toList();
      
      for (var n in fetched) {
        if (!_notifications.any((existing) => existing.id == n.id)) {
          NotificationService.showNotification(
            id: n.id.hashCode,
            title: n.title,
            body: n.body,
          );
        }
      }
      
      _notifications = fetched;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final api = ApiService();
    try {
      await api.post('/notifications/$id/mark-read', {});
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAsReadByMissionId(int missionId) async {
    // Collecter les IDs des notifications non lues liées à cette mission
    final List<String> toMark = _notifications
        .where((n) {
          if (n.isRead || n.data == null) return false;
          final mId = n.data!['mission_id'] ?? n.data!['id_mission'];
          return mId?.toString() == missionId.toString();
        })
        .map((n) => n.id)
        .toList();

    if (toMark.isEmpty) return;

    debugPrint('NotificationProvider: Marking ${toMark.length} notifications as read for mission $missionId');
    
    // Marquer localement immédiatement pour la réactivité
    for (var id in toMark) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index].isRead = true;
      }
    }
    notifyListeners();

    // Appeler l'API pour chaque (ou batch si existant, mais ici on fait séquentiel/parallèle simple)
    try {
      await Future.wait(toMark.map((id) => ApiService().post('/notifications/$id/mark-read', {})));
      // Optionnel: Re-fetch pour être sûr de la synchronisation avec le serveur
      fetchNotifications();
    } catch (e) {
      debugPrint('Error marking multiple notifications as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final api = ApiService();
    try {
      await api.post('/notifications/mark-all-read', {});
      for (var n in _notifications) {
        n.isRead = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
