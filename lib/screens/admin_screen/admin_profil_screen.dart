import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen_2.dart';
import 'admin_edit_profil_screen.dart';
import 'admin_home_screen.dart';
import 'admin_missions_screen.dart';
import 'admin_equipe_screen.dart';
import 'admin_settings_screen.dart';

class AdminProfilScreen extends StatefulWidget {
  const AdminProfilScreen({Key? key}) : super(key: key);

  @override
  _AdminProfilScreenState createState() => _AdminProfilScreenState();
}

class _AdminProfilScreenState extends State<AdminProfilScreen> {
  final int _currentIndex = 4;
  final Color _primaryPurple = const Color(0xFF7C39D3);

  void _deconnexion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen2()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final user = authProvider.user;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryPurple,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Column(
          children: [
            _buildHeader(user?.fullName ?? langProvider.translate('administrator'), langProvider),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildInfoCard(
                      name: user?.fullName ?? 'Sophie Martin',
                      email: user?.email ?? 'sophie.martin@itea.fr',
                      langProvider: langProvider,
                    ),
                    SizedBox(height: 24.h),
                    _buildActionBtn(
                      icon: Icons.edit_outlined,
                      label: langProvider.translate('modify_info'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminEditProfilScreen()),
                        );
                      },
                    ),
                    _buildActionBtn(
                      icon: Icons.lock_outline,
                      label: langProvider.translate('change_password'),
                      onTap: () {},
                    ),
                    SizedBox(height: 32.h),
                    _buildLogoutBtn(langProvider),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(langProvider),
      ),
    );
  }

  Widget _buildHeader(String name, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: _primaryPurple),
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
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 30.h),
            child: Column(
              children: [
                Text(
                  langProvider.translate('my_profile'),
                  style: getSourceSerifProStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_outline,
                      color: _primaryPurple,
                      size: 50.sp,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  name,
                  style: getSourceSerifProStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String name, required String email, required LanguageProvider langProvider}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(langProvider.translate('full_name'), name),
          const Divider(),
          _buildInfoRow(langProvider.translate('email'), email),
          const Divider(),
          _buildInfoRow(langProvider.translate('role'), langProvider.translate('administrator')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: getSourceSerifProStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: getSourceSerifProStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(icon, color: _primaryPurple, size: 22.sp),
              SizedBox(width: 16.w),
              Text(
                label,
                style: getSourceSerifProStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutBtn(LanguageProvider langProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _deconnexion,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          langProvider.translate('logout'),
          style: getSourceSerifProStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, langProvider.translate('home'), 0, langProvider),
              _buildNavItem(Icons.card_giftcard_outlined, Icons.card_giftcard, langProvider.translate('missions'), 1, langProvider, imagePath: 'assets/images/missions.png'),
              _buildNavItem(Icons.people_outline, Icons.people, langProvider.translate('team'), 2, langProvider),
              _buildNavItem(Icons.settings_outlined, Icons.settings, langProvider.translate('admin_panel'), 3, langProvider),
              _buildNavItem(Icons.person_outline, Icons.person, langProvider.translate('profile'), 4, langProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData iconOutline, IconData iconFilled, String label, int index, LanguageProvider langProvider, {String? imagePath}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminHomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminMissionsScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminEquipeScreen()));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminSettingsScreen()));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          imagePath != null
              ? Image.asset(
                  imagePath,
                  width: 24.w,
                  height: 24.w,
                  color: isSelected ? _primaryPurple : Colors.grey[400],
                  fit: BoxFit.contain,
                )
              : Icon(
                  isSelected ? iconFilled : iconOutline,
                  color: isSelected ? _primaryPurple : Colors.grey[400],
                  size: 24.sp,
                ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: getSourceSerifProStyle(
              fontSize: 11.sp,
              color: isSelected ? _primaryPurple : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
