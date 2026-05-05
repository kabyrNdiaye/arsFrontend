import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../utils/header_color_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../auth/login_screen_2.dart';
import 'admin_home_screen.dart';
import 'admin_missions_screen.dart';
import 'admin_equipe_screen.dart';
import 'admin_parametres_screen.dart';
import 'admin_profil_screen.dart';
import 'admin_gestion_professionnels_screen.dart';
import 'admin_gestion_structures_screen.dart';
import 'admin_menus_screen.dart';
import 'admin_recipes_screen.dart';
import 'admin_formations_screen.dart';
import 'admin_incidents_screen.dart';
import 'admin_feedbacks_screen.dart';
import '../../providers/mission_provider.dart';
import '../../providers/notification_provider.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  _AdminSettingsScreenState createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  int _currentIndex = 3; 
  final Color _primaryPurple = const Color(0xFF7C39D3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MissionProvider>(context, listen: false).fetchAdminStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final langProvider = Provider.of<LanguageProvider>(context);
    final user = authProvider.user;
    
    final headerColor = HeaderColorHelper.getHeaderColor(
      userType: 'admin',
      userEmail: user?.email,
      userId: user?.id,
    );
    
    final statusBarIconBrightness = HeaderColorHelper.getStatusBarIconBrightness(headerColor);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: headerColor,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            _buildHeader(langProvider),
            Expanded(
              child: Consumer<MissionProvider>(
                builder: (context, missionProvider, child) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatisticsSection(langProvider, missionProvider),
                        SizedBox(height: 24.h),
                        _buildResourceManagementSection(langProvider, missionProvider),
                        SizedBox(height: 24.h),
                        _buildSettingsItem(langProvider),
                        SizedBox(height: 16.h),
                        _buildLogoutButton(langProvider),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildBottomNav(langProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    final headerColor = HeaderColorHelper.getHeaderColor(
      userType: 'admin',
      userEmail: user?.email,
      userId: user?.id,
    );
    
    return Container(
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      langProvider.translate('administration'),
                      style: getSourceSerifProStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      langProvider.translate('manage_resources'),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Consumer2<NotificationProvider, MissionProvider>(
                builder: (context, notifProvider, missionProvider, child) {
                  final totalUnread = missionProvider.totalUnreadMessagesCount + missionProvider.newMissionsCount;
                  
                  return GestureDetector(
                    onTap: () {
                      // Navigation désactivée - Indicateur uniquement
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 26.sp,
                        ),
                        if (totalUnread > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: EdgeInsets.all(2),
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
                                  totalUnread > 9 ? '9+' : totalUnread.toString(),
                                  style: getSourceSerifProStyle(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(LanguageProvider langProvider, MissionProvider missionProvider) {
    final stats = missionProvider.adminStats;
    final missions = stats['total_missions']?.toString() ?? '0';
    final satisfaction = '${stats['satisfaction_percentage'] ?? 100}%';
    final pros = stats['total_professionals']?.toString() ?? '0';
    final incidents = stats['total_incidents']?.toString() ?? '0';

    return Container(
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
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: _primaryPurple,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                langProvider.translate('monthly_stats'),
                style: getSourceSerifProStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  missions,
                  langProvider.translate('missions'),
                  const Color(0xFFF3E5F5),
                  _primaryPurple,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  satisfaction,
                  langProvider.translate('satisfaction'),
                  const Color(0xFFE3F2FD),
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  pros,
                  langProvider.translate('pros_active'),
                  const Color(0xFFE8F5E9),
                  const Color(0xFF4CAF50),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  incidents,
                  langProvider.translate('incidents'),
                  const Color(0xFFFFF3E0),
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color bgColor, Color valueColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: getSourceSerifProStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: getSourceSerifProStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceManagementSection(LanguageProvider langProvider, MissionProvider missionProvider) {
    final stats = missionProvider.adminStats;
    final profCount = stats['total_professionals']?.toString() ?? '0';
    final sitesCount = stats['total_structures']?.toString() ?? '0';
    final menusCount = stats['total_menus']?.toString() ?? '0';
    final recipesCount = stats['total_recipes']?.toString() ?? '0';
    final formationsCount = stats['total_formations']?.toString() ?? '0';
    final incidentsCount = stats['total_incidents']?.toString() ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langProvider.translate('manage_resources'),
          style: getSourceSerifProStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminGestionProfessionnelsScreen(),
              ),
            );
          },
          child: _buildResourceItem(langProvider.translate('prof_management'), profCount),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminGestionStructuresScreen(),
              ),
            );
          },
          child: _buildResourceItem(langProvider.translate('sites_management'), sitesCount),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminMenusScreen())),
          child: _buildResourceItem(langProvider.translate('menus_management'), menusCount),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminRecipesScreen())),
          child: _buildResourceItem(langProvider.translate('recipes_management'), recipesCount),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminFormationsScreen())),
          child: _buildResourceItem(langProvider.translate('trainings_management'), formationsCount),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminIncidentsScreen())),
          child: _buildResourceItem(langProvider.translate('incidents_management'), incidentsCount),
        ),
      ],
    );
  }

  Widget _buildResourceItem(String label, String count) {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: Color(0xFFF3E5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              color: _primaryPurple,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: getSourceSerifProStyle(
                fontSize: 15.sp,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: getSourceSerifProStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: 16.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(LanguageProvider langProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminParametresScreen(),
          ),
        );
      },
      child: Container(
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
        child: Row(
          children: [
            Icon(
              Icons.settings_outlined,
              color: _primaryPurple,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                langProvider.translate('settings'),
                style: getSourceSerifProStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLogoutButton(LanguageProvider langProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen2()),
          (route) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFCF3F2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout,
              color: Colors.red,
              size: 20,
            ),
            SizedBox(width: 8.w),
            Text(
              langProvider.translate('logout'),
              style: getSourceSerifProStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, langProvider.translate('home'), 0),
              _buildNavItem(Icons.work_outline, Icons.work, langProvider.translate('missions'), 1),
              _buildNavItem(Icons.people_outline, Icons.people, langProvider.translate('team'), 2),
              _buildNavItem(Icons.settings_outlined, Icons.settings, langProvider.translate('admin_panel'), 3),
              _buildNavItem(Icons.person_outline, Icons.person, langProvider.translate('profile'), 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? _primaryPurple : Colors.grey[400];
    
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminHomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminMissionsScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminEquipeScreen()));
        } else if (index == 4) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminProfilScreen()));
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSelected ? activeIcon : icon, color: color, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            style: getSourceSerifProStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
