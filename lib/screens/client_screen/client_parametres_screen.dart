import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'client_langue_screen.dart';
import 'client_a_propos_screen.dart';
import 'client_politique_screen.dart';
import 'client_aide_support_screen.dart';

class ClientParametresScreen extends StatelessWidget {
  const ClientParametresScreen({Key? key}) : super(key: key);

  // Couleurs du thème client
  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Column(
          children: [
            // Header vert avec logo
            _buildHeader(context, langProvider),
            
            // Contenu
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    
                    // Menu des paramètres
                    _buildMenuSection(context, langProvider),
                    
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

  Widget _buildHeader(BuildContext context, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryGreen,
      ),
      child: Column(
        children: [
          // Trait horizontal en haut, juste sous la barre de statut
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
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Logo ARS centré
              Center(
                child: Image.asset(
                  'assets/images/ARS.png',
                  height: 180.h,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'ARS',
                      style: getSourceSerifProStyle(
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
  );
}

  Widget _buildMenuSection(BuildContext context, LanguageProvider langProvider) {
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItemImage(
            context: context,
            imagePath: 'assets/images/langue.png',
            bgColor: const Color(0xFFF7F2FF), // Violet très clair
            title: langProvider.translate('language'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientLangueScreen()),
              );
            },
          ),
          _buildMenuItemImage(
            context: context,
            imagePath: 'assets/images/propos.png',
            bgColor: const Color(0xFFE8F5E9), // Vert très clair
            title: langProvider.translate('about'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientAProposScreen()),
              );
            },
          ),
          _buildMenuItemImage(
            context: context,
            imagePath: 'assets/images/politique.png',
            bgColor: const Color(0xFFE8F5E9), // Vert très clair
            title: langProvider.translate('privacy'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientPolitiqueScreen()),
              );
            },
          ),
          _buildMenuItemImage(
            context: context,
            imagePath: 'assets/images/aide.png',
            bgColor: const Color(0xFFE8F5E9), // Vert très clair
            title: langProvider.translate('help_support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientAideSupportScreen()),
              );
            },
          ),
          _buildMenuItemImage(
            context: context,
            imagePath: 'assets/images/partager.png',
            bgColor: const Color(0xFFE8F5E9), // Vert très clair
            title: langProvider.translate('share_app'),
            onTap: () async {
              // Partager l'application
              await Share.share(
                '${langProvider.translate('share_text')}\n\n'
                'Téléchargez l\'application :\n'
                '📱 iOS : https://apps.apple.com/app/ars-app\n'
                '📱 Android : https://play.google.com/store/apps/details?id=com.ars.app\n\n'
                '${langProvider.translate('share_app_footer') ?? 'Simplifiez la gestion de vos missions de restauration !'}',
                subject: 'ARS App',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemImage({
    required BuildContext context,
    required String imagePath,
    required Color bgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Image dans un conteneur avec coins arrondis
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: 24.w,
                  height: 24.h,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported, color: _primaryGreen, size: 20.sp);
                  },
                ),
              ),
            ),
            
            SizedBox(width: 14.w),
            
            // Titre
            Expanded(
              child: Text(
                title,
                style: getInterStyle( // Utilisation de Inter pour le menu
                  fontSize: 15.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            
            // Flèche dans un petit carré vert arrondi (chevron droit)
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: const Color(0xFF6ABF6E), // Vert clair selon capture
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
