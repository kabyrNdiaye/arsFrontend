import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/font_helper.dart';

class ClientSharedHeader extends StatelessWidget {
  final Map<String, String>? stats; // ex: {'48': 'Missions', '115': 'Résidents', '12': 'Chefs'}
  final int notifCount;

  const ClientSharedHeader({
    Key? key,
    this.stats,
    this.notifCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final userName = user?.fullName ?? '';
    final etablissementName = user?.nomEtablissement ?? '';
    final fonction = user?.fonction ?? lang.translate('director');
    final primaryGreen = const Color(0xFF4CA054);
    final lightGreen = const Color(0xFF6ABF6E);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne principale : icône | infos | cloche
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône maison
                  Container(
                    width: 58.w,
                    height: 58.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryGreen, width: 2),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Image.asset(
                          'assets/images/icon_structure.png',
                          width: 40.w,
                          height: 40.h,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.home_work_outlined, color: primaryGreen, size: 26.sp);
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Nom + badge (Expanded pour éviter l'overflow)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          etablissementName.isEmpty ? 'Structure' : etablissementName,
                          style: getSourceSerifProStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          userName,
                          style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 6.h),
                        // Badge fonction
                        IntrinsicWidth(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              fonction,
                              style: getSourceSerifProStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Notification cloche
                  Consumer<NotificationProvider>(
                    builder: (context, notifProvider, child) {
                      return GestureDetector(
                        onTap: null, // La cloche n'ouvre plus de page
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                            if (notifProvider.unreadCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16.w,
                                    minHeight: 16.w,
                                  ),
                                  child: Center(
                                    child: Text(
                                      notifProvider.unreadCount > 9 ? '9+' : notifProvider.unreadCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),


              // Stats (si fournies)
              if (stats != null && stats!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Row(
                  children: stats!.entries.map((e) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              e.key,
                              style: getSourceSerifProStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              e.value,
                              style: getSourceSerifProStyle(fontSize: 10.sp, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
