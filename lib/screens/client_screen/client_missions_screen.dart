import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class ClientMissionsScreen extends StatefulWidget {
  final String? userName;
  final String? etablissementName;
  
  const ClientMissionsScreen({
    Key? key,
    this.userName,
    this.etablissementName,
  }) : super(key: key);

  @override
  _ClientMissionsScreenState createState() => _ClientMissionsScreenState();
}

class _ClientMissionsScreenState extends State<ClientMissionsScreen> {
  // Couleurs
  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(langProvider),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    // Mission Aujourd'hui
                    _buildMissionCard(
                      date: langProvider.translate('today') + " - 17 Nov 2025",
                      professionalName: "Thomas Martin",
                      time: "7h30 - 16h00",
                      status: langProvider.translate('in_progress'),
                      statusColor: _primaryGreen,
                      langProvider: langProvider,
                      menu: {
                        langProvider.translate('starter'): 'Salade composée',
                        langProvider.translate('dish'): 'Poulet rôti',
                        langProvider.translate('side'): 'Riz pilaf',
                        langProvider.translate('dessert'): 'Compote de pommes',
                      },
                    ),
                    SizedBox(height: 16.h),
                    // Mission Demain 1
                    _buildMissionCard(
                      date: langProvider.translate('tomorrow') + " - 18 Nov 2025",
                      professionalName: "Sophie Bernard",
                      time: "8h00 - 16h30",
                      status: langProvider.translate('scheduled'),
                      statusColor: const Color(0xFF0059AB),
                      badgeBgColor: const Color(0xFFDEEAFC),
                      langProvider: langProvider,
                      menu: {
                        langProvider.translate('starter'): 'Potage de légumes',
                        langProvider.translate('dish'): 'Boeuf bourguignon',
                        langProvider.translate('side'): 'Pomme vapeur',
                        langProvider.translate('dessert'): 'Yaourt nature',
                      },
                    ),
                    SizedBox(height: 16.h),
                    // Mission Demain 2
                    _buildMissionCard(
                      date: langProvider.translate('tomorrow') + " - 18 Nov 2025",
                      professionalName: "Marc Lemoine",
                      time: "8h00 - 16h30",
                      status: langProvider.translate('scheduled'),
                      statusColor: const Color(0xFF0059AB),
                      badgeBgColor: const Color(0xFFDEEAFC),
                      langProvider: langProvider,
                      menu: {
                        langProvider.translate('starter'): 'Salade de tomates',
                        langProvider.translate('dish'): 'Dos de cabillaud',
                        langProvider.translate('side'): 'Haricots verts',
                        langProvider.translate('dessert'): 'Fruit de saison',
                      },
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          children: [
            // Trait horizontal en haut
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
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icône structure
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _primaryGreen, width: 2),
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Image.asset(
                              'assets/images/icon_structure.png',
                              width: 44.w,
                              height: 44.h,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: CustomPaint(
                                    size: Size(40.w, 40.h),
                                    painter: HouseWithPlusPainter(color: _primaryGreen),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      // Infos
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.etablissementName ?? 'EHPAD Les Jardins',
                              style: getSourceSerifProStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.userName ?? 'Marie Dubois',
                              style: getSourceSerifProStyle(
                                fontSize: 15.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            // Badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6ABF6E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                langProvider.translate('director'),
                                style: getSourceSerifProStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notifications
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 30.sp,
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 20.w,
                              height: 20.h,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: _primaryGreen, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '2',
                                  style: getSourceSerifProStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100.w,
                        child: _buildStatCard('48', langProvider.translate('missions')),
                      ),
                      SizedBox(width: 12.w),
                      SizedBox(
                        width: 100.w,
                        child: _buildStatCard('115', langProvider.translate('residents')),
                      ),
                      SizedBox(width: 12.w),
                      SizedBox(
                        width: 100.w,
                        child: _buildStatCard('12', langProvider.translate('chefs')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFF6ABF6E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: getSourceSerifProStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: getSourceSerifProStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard({
    required String date,
    required String professionalName,
    required String time,
    required String status,
    required Color statusColor,
    required Map<String, String> menu,
    required LanguageProvider langProvider,
    Color? badgeBgColor,
  }) {
    final bool isInProgress = status == langProvider.translate('in_progress');
    final Color badgeBackground = isInProgress ? const Color(0xFFE8F5E9) : const Color(0xFFDEEAFC);
    final Color badgeTextColor = isInProgress ? _primaryGreen : const Color(0xFF0059AB);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: getSourceSerifProStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      professionalName,
                      style: getSourceSerifProStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: badgeBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isInProgress) ...[
                      Icon(
                        Icons.access_time,
                        size: 14.sp,
                        color: badgeTextColor,
                      ),
                    ] else ...[
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14.sp,
                        color: badgeTextColor,
                      ),
                    ],
                    SizedBox(width: 6.w),
                    Text(
                      status,
                      style: getSourceSerifProStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.grey[400],
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                time,
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MENU',
                  style: getSourceSerifProStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                ...menu.entries.map((entry) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key} : ',
                        style: getSourceSerifProStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: getSourceSerifProStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Voir les détails',
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward_ios, size: 12.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HouseWithPlusPainter extends CustomPainter {
  final Color color;
  HouseWithPlusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final roofPath = Path();
    roofPath.moveTo(size.width / 2, 0);
    roofPath.lineTo(size.width, size.height * 0.4);
    roofPath.lineTo(0, size.height * 0.4);
    roofPath.close();
    canvas.drawPath(roofPath, paint);
    final housePath = Path();
    housePath.addRect(Rect.fromLTWH(size.width * 0.15, size.height * 0.4, size.width * 0.7, size.height * 0.55));
    canvas.drawPath(housePath, paint);
    final plusPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height * 0.675;
    final plusWidth = size.width * 0.25;
    final plusThickness = size.height * 0.08;
    canvas.drawRect(Rect.fromCenter(center: Offset(centerX, centerY), width: plusWidth, height: plusThickness), plusPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(centerX, centerY), width: plusThickness, height: plusWidth), plusPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
