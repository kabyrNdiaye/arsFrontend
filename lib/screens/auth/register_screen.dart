import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/font_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'login_screen_2.dart';
import '../client_inscription/inscription_client_step1_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _selectedProfile;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header bleu avec flèche retour et titre "Inscription"
            Container(
              width: double.infinity,
              color: Color(0xFF0059AB),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  // Flèche retour
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Titre "Inscription"
                  Expanded(
                    child: Text(
                      langProvider.translate('registration'),
                      style: getSourceSerifProStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Espace pour équilibrer avec la flèche
                  SizedBox(width: 48.w),
                ],
              ),
            ),
            
            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre "Choisissez Votre Profil"
                    Text(
                      langProvider.translate('choose_profile'),
                      style: getSourceSerifProStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0059AB),
                        height: 1.0, // Line height: 100%
                        letterSpacing: 0,
                      ),
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Sous-titre
                    Text(
                      langProvider.translate('choose_profile_desc'),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 24 / 14, // Line height: 24px / font size: 14px
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Carte Étudiant (Travailleur)
                    _buildProfileCard(
                      title: langProvider.translate('student_profile'),
                      description: langProvider.translate('student_profile_desc'),
                      icon: Icons.school_outlined,
                      backgroundColor: Color(0xFFFFF8E1), // Beige/crème clair
                      isSelected: _selectedProfile == 'student',
                      langProvider: langProvider,
                      onTap: () {
                        setState(() {
                          _selectedProfile = 'student';
                        });
                        // Navigation vers la suite de l'inscription pour étudiant
                        // Navigator.push(...);
                      },
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Carte Recruteur (Structure)
                    _buildProfileCard(
                      title: langProvider.translate('recruiter_profile'),
                      description: langProvider.translate('recruiter_profile_desc'),
                      icon: Icons.business_center_outlined,
                      backgroundColor: Color(0xFFE0F7FA), // Bleu clair/turquoise
                      isSelected: _selectedProfile == 'recruiter',
                      langProvider: langProvider,
                      onTap: () {
                        setState(() {
                          _selectedProfile = 'recruiter';
                        });
                        // Navigation vers la page Inscription1
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InscriptionClientStep1Screen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required String description,
    required IconData icon,
    required Color backgroundColor,
    required bool isSelected,
    required VoidCallback onTap,
    required LanguageProvider langProvider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Color(0xFF0059AB) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Icône en haut
            Icon(
              icon,
              size: 64.sp,
              color: Colors.black87,
            ),
            
            SizedBox(height: 20.h),
            
            // Titre
            Text(
              title,
              style: getSourceSerifProStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 12.h),
            
            // Description
            Text(
              description,
              style: getSourceSerifProStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 24.h),
            
            // Bouton "Continuer" avec flèche
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  langProvider.translate('continue'),
                  style: getSourceSerifProStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward,
                  size: 20.sp,
                  color: Colors.black87,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
