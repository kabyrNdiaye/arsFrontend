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
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: getSourceSerifProStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (notificationProvider.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Tout marquer comme lu',
              onPressed: () {
                notificationProvider.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Toutes les notifications ont été marquées comme lues')),
                );
              },
            ),
        ],
      ),
      body: _buildBody(notificationProvider),
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
