import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'langue_screen.dart';
import 'a_propos_screen.dart';
import 'politique_screen.dart';
import 'aide_support_screen.dart';

class ParametresScreen extends StatelessWidget {
  const ParametresScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    const Color primaryBlue = Color(0xFF0059AB);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: primaryBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: Column(
          children: [
            // Header bleu avec logo
            _buildHeader(context, langProvider, primaryBlue),
            
            // Contenu
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    
                    // Menu des paramètres
                    _buildMenuSection(context, langProvider, primaryBlue),
                    
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LanguageProvider langProvider, Color primaryBlue) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryBlue,
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
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bouton Retour
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                        SizedBox(width: 4.w),
                        Text(
                          langProvider.translate('back'),
                          style: getInterStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 10.h),
                  
                  // Logo ARS centré
                  Center(
                    child: Image.asset(
                      'assets/images/ARS.png',
                      height: 120.h,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'ARS',
                          style: getInterStyle(
                            fontSize: 48.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, LanguageProvider langProvider, Color primaryBlue) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context: context,
            iconPath: 'assets/images/icon_langue_p.png',
            fallbackIcon: Icons.language,
            title: langProvider.translate('language'),
            primaryBlue: primaryBlue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LangueScreen()),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            iconPath: 'assets/images/icon_propos_p.png',
            fallbackIcon: Icons.info_outline,
            title: langProvider.translate('about'),
            primaryBlue: primaryBlue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AProposScreen()),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            iconPath: 'assets/images/icon_politique_p.png',
            fallbackIcon: Icons.security,
            title: langProvider.translate('privacy'),
            primaryBlue: primaryBlue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PolitiqueScreen()),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            iconPath: 'assets/images/icon_aide_p.png',
            fallbackIcon: Icons.help_outline,
            title: langProvider.translate('help_support'),
            primaryBlue: primaryBlue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AideSupportScreen()),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            iconPath: 'assets/images/icon_partager_p.png',
            fallbackIcon: Icons.share_outlined,
            title: langProvider.translate('share_app'),
            primaryBlue: primaryBlue,
            onTap: () async {
              await Share.share(
                langProvider.translate('share_message'),
                subject: langProvider.translate('share_subject'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String iconPath,
    required IconData fallbackIcon,
    required String title,
    required Color primaryBlue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Icône avec fond bleu très clair
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 40.w,
                  height: 40.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      fallbackIcon,
                      color: primaryBlue,
                      size: 20.sp,
                    );
                  },
                ),
              ),
            ),
            
            SizedBox(width: 14.w),
            
            // Titre
            Expanded(
              child: Text(
                title,
                style: getInterStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Flèche bleue circulaire
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

