import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/notification_provider.dart';
import '../../utils/font_helper.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final Color _primaryPurple = const Color(0xFF7C39D3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(context, notificationProvider),
          Expanded(
            child: _buildBody(notificationProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotificationProvider provider) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // On force une hauteur minimum si statusBarHeight est nulle (ex: web)
    final double safeTop = statusBarHeight > 0 ? statusBarHeight : 24.h;

    return Container(
      width: double.infinity,
      color: _primaryPurple,
      padding: EdgeInsets.only(
        top: safeTop + 16.h, // Pousse le texte 16.h sous la barre de statut
        bottom: 20.h,        // Fait descendre le fond violet de 20.h sous le texte
        left: 4.w,
        right: 4.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: 8.w),
              Text(
                'Notifications',
                style: getSourceSerifProStyle(
                  fontSize: 22.sp, // Légèrement plus grand
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (provider.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white),
              tooltip: 'Tout marquer comme lu',
              onPressed: () {
                provider.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Toutes les notifications ont été marquées comme lues')),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBody(NotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: _primaryPurple),
      );
    }

    if (provider.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, color: Colors.grey[400], size: 64.sp),
            SizedBox(height: 16.h),
            Text(
              'Aucune notification',
              style: getSourceSerifProStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchNotifications(),
      color: _primaryPurple,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          final notification = provider.notifications[index];
          final bool isUnread = !notification.isRead;

          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            elevation: isUnread ? 2 : 0,
            color: isUnread ? Colors.white : Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isUnread 
                  ? BorderSide(color: _primaryPurple.withOpacity(0.3), width: 1)
                  : BorderSide.none,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.w),
              leading: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: _primaryPurple.withOpacity(isUnread ? 0.1 : 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForType(notification.type),
                  color: isUnread ? _primaryPurple : Colors.grey[500],
                ),
              ),
              title: Text(
                notification.title,
                style: getSourceSerifProStyle(
                  fontSize: 16.sp,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  color: isUnread ? Colors.black87 : Colors.grey[700],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6.h),
                  Text(
                    notification.body ?? '',
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      color: isUnread ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _formatDate(notification.timestamp),
                    style: getSourceSerifProStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              onTap: () {
                if (isUnread) {
                  provider.markAsRead(notification.id);
                }
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(String? type) {
    if (type == null) return Icons.notifications;
    
    // Basé sur les types renvoyés par le backend
    if (type.contains('new_user')) return Icons.person_add;
    if (type.contains('new_mission')) return Icons.work_outline;
    if (type.contains('chat')) return Icons.chat_bubble_outline;
    return Icons.notifications;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(date);
  }
}
