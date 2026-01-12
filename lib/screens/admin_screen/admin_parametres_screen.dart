import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'admin_langue_screen.dart';
import 'admin_a_propos_screen.dart';
import 'admin_politique_screen.dart';
import 'admin_aide_support_screen.dart';

class AdminParametresScreen extends StatelessWidget {
  const AdminParametresScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final Color _primaryPurple = const Color(0xFF7C39D3);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: Column(
          children: [
            _buildHeader(context, langProvider, _primaryPurple),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: Icons.translate_rounded,
                        label: langProvider.translate('language'),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLangueScreen())),
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.public_rounded,
                        label: langProvider.translate('about'),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAProposScreen())),
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.privacy_tip_outlined,
                        label: langProvider.translate('privacy'),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPolitiqueScreen())),
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.help_outline_rounded,
                        label: langProvider.translate('help_support'),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAideSupportScreen())),
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.share_rounded,
                        label: langProvider.translate('share_app'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(langProvider.translate('pending_feature') ?? 'Fonctionnalité de partage à venir')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LanguageProvider langProvider, Color primaryPurple) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryPurple,
      ),
      padding: EdgeInsets.only(bottom: 40.h),
      child: Column(
        children: [
          // Bouton Retour
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 16.w,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    SizedBox(width: 8.w),
                    Text(
                      langProvider.translate('back'),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Logo ARS
          Image.asset(
            'assets/images/ARS.png',
            height: 100.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'ARS',
                style: getSourceSerifProStyle(
                  fontSize: 60.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final Color _primaryPurple = const Color(0xFF7C39D3);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Icône de gauche avec fond lavande
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _primaryPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: _primaryPurple,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 16.w),
            // Libellé
            Expanded(
              child: Text(
                label,
                style: getSourceSerifProStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Flèche de droite style bouton
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: _primaryPurple,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

