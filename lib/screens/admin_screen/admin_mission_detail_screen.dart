import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';
import 'admin_edit_mission_screen.dart';

class AdminMissionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> mission;
  final Function(Map<String, dynamic>)? onMissionUpdated;
  final Function()? onMissionDeleted;

  const AdminMissionDetailScreen({
    Key? key,
    required this.mission,
    this.onMissionUpdated,
    this.onMissionDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final Color _primaryPurple = const Color(0xFF7C39D3);
    
    // Déterminer les couleurs selon le statut
    Color statusBgColor;
    Color statusTextColor;
    
    if (mission['status'] == 'En cours') {
      statusBgColor = const Color(0xFFE2FBE9);
      statusTextColor = const Color(0xFF009814);
    } else if (mission['status'] == 'Réfusé') {
      statusBgColor = const Color(0xFFFAE3E3);
      statusTextColor = const Color(0xFFFF0000);
    } else if (mission['status'] == 'Confirmée') {
      statusBgColor = const Color(0xFFDEEAFC);
      statusTextColor = const Color(0xFF0059AB);
    } else {
      statusBgColor = Colors.grey[200]!;
      statusTextColor = Colors.grey[700]!;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(context, _primaryPurple),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte de mission
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mission['establishment'] ?? '',
                                    style: getSourceSerifProStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.grey[600],
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Text(
                                          mission['address'] ?? '',
                                          style: getSourceSerifProStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                mission['status'] ?? '',
                                style: getSourceSerifProStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: statusTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        // Section des détails
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                Icons.person_outline,
                                'Professionnel',
                                mission['professional'] ?? '',
                              ),
                              SizedBox(height: 16.h),
                              _buildDetailRow(
                                Icons.access_time,
                                'Horaire',
                                mission['schedule'] ?? '',
                              ),
                              SizedBox(height: 16.h),
                              _buildDetailRow(
                                Icons.calendar_today_outlined,
                                'Date',
                                mission['date'] ?? '',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color _primaryPurple) {
    return Container(
      decoration: BoxDecoration(
        color: _primaryPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top + 8.h : 32.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Détails de la mission',
                    textAlign: TextAlign.center,
                    style: getSourceSerifProStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminEditMissionScreen(
                          mission: mission,
                          onMissionUpdated: onMissionUpdated,
                        ),
                      ),
                    ).then((_) {
                      if (onMissionUpdated != null) {
                        Navigator.pop(context);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20.sp),
        SizedBox(width: 12.w),
        Text(
          label,
          style: getSourceSerifProStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: getSourceSerifProStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
