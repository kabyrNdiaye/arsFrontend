import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';
import 'login_screen_2.dart';
import '../professionnel_inscription/inscription_professionnel_step1_screen.dart';
import '../client_inscription/inscription_client_step1_screen.dart';
import 'dart:math' as math;

class LoginScreen22 extends StatefulWidget {
  @override
  _LoginScreen22State createState() => _LoginScreen22State();
}

class _LoginScreen22State extends State<LoginScreen22> {
  String? _selectedProfile; // Aucun profil sélectionné par défaut

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    
    // Détecter la taille de l'écran et le type d'appareil
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    
    // Déterminer le type d'appareil - meilleure détection pour iPad
    // iPad mini: 768x1024, iPad: 810x1080, iPad Pro: 1024x1366
    final isTablet = shortestSide >= 600 && shortestSide < 1200;
    final isDesktop = screenWidth >= 1200;
    final isIPad = shortestSide >= 600 && shortestSide <= 1024; // Détection spécifique iPad
    
    // Largeur maximale adaptative
    double maxWidth;
    if (isDesktop) {
      maxWidth = 500;
    } else if (isTablet) {
      maxWidth = 550;
    } else {
      maxWidth = double.infinity;
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: Column(
                  children: [
                    // Header bleu avec logo
                    _buildBlueHeader(screenHeight, isTablet, isDesktop),
                    
                    // Contenu principal
                    Expanded(
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlueHeader(double screenHeight, bool isTablet, bool isDesktop) {
    // Hauteur adaptative selon le type d'appareil
    double headerHeight;
    double logoHeight;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isIPad = shortestSide >= 600 && shortestSide <= 1024;
    
    if (isDesktop) {
      headerHeight = 320.h;
      logoHeight = 250.h;
    } else if (isIPad) {
      // Optimisé pour iPad (mini, pro, max)
      headerHeight = screenHeight * 0.30;
      logoHeight = screenHeight * 0.20;
    } else if (isTablet) {
      headerHeight = screenHeight * 0.35;
      logoHeight = screenHeight * 0.22;
    } else {
      headerHeight = screenHeight * 0.33;
      logoHeight = screenHeight * 0.24;
    }
    
    // Limites pour éviter les tailles extrêmes - ajustées pour iPad
    if (isIPad) {
      headerHeight = headerHeight.clamp(280.h, 380.h);
      logoHeight = logoHeight.clamp(180.h, 280.h);
    } else {
      headerHeight = headerHeight.clamp(250.h, 400.h);
      logoHeight = logoHeight.clamp(200.h, 350.h);
    }
    
    final logoWidth = logoHeight * 1.4;
    
    return ClipPath(
      clipper: HeaderBottomWaveClipper22(),
      child: Container(
        height: headerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFF0059AB),
        ),
        child: Stack(
          children: [
            // Pattern de grille en arrière-plan
            CustomPaint(
              size: Size(double.infinity, headerHeight),
              painter: GridPatternPainter22(),
            ),
            // Logo ARS centré
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ARS centré - taille adaptative
                  Image.asset(
                    'assets/images/logo.png',
                    height: logoHeight,
                    width: logoWidth,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => _buildARSLogo(),
                  ),
                  
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARSLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ARS',
          style: getSourceSerifProStyle(
            fontSize: 48.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= 600 && shortestSide < 1200;
    final isIPad = shortestSide >= 600 && shortestSide <= 1024;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isIPad ? 40.w : 24.w, vertical: isTablet ? 10.h : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Texte d'instruction - style minimaliste et espacé
            Padding(
              padding: EdgeInsets.only(top: isIPad ? 24.h : (isTablet ? 20.h : 24.h)),
              child: Text(
                'Choisissez votre profil pour commencer',
                style: getSourceSerifProStyle(
                  fontSize: isIPad ? 20.sp : 18.sp,
                  color: Colors.black87,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: isIPad ? 32.h : (isTablet ? 30.h : 35.h)),
            
            // Carte Professionnel
            _buildProfileCard(
              title: 'Professionnel',
              subtitle: 'Cuisinier – Chef – Agent',
              description: 'Je cherche des missions en cuisine',
              iconPath: 'assets/images/icon_personne.png',
              iconColor: Color(0xFFE0F7FA), // Bleu clair
              isSelected: _selectedProfile == 'professionnel',
              onTap: () {
                setState(() {
                  _selectedProfile = 'professionnel';
                });
              },
            ),
            
            SizedBox(height: 24.h),
            
            // Carte Client
            _buildProfileCard(
              title: 'Client',
              subtitle: 'EHPAD – Clinique – Restaurant',
              description: 'Je cherche des professionnels qualifiés',
              iconPath: 'assets/images/icon_client.png',
              iconColor: Color(0xFFE8F5E9), // Vert clair
              isSelected: _selectedProfile == 'client',
              onTap: () {
                setState(() {
                  _selectedProfile = 'client';
                });
              },
            ),
            
            SizedBox(height: isIPad ? 28.h : (isTablet ? 24.h : 30.h)),
            
            // Bouton Continuer - bleu et actif
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isIPad ? 320.w : 280.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedProfile != null ? () {
                    // Navigation vers la suite de l'inscription selon le profil sélectionné
                    if (_selectedProfile == 'professionnel') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InscriptionProfessionnelStep1Screen(),
                        ),
                      );
                    } else if (_selectedProfile == 'client') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InscriptionClientStep1Screen(),
                        ),
                      );
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0059AB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[700],
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continuer',
                        style: getSourceSerifProStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: _selectedProfile != null ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward, 
                        size: 20.sp, 
                        color: _selectedProfile != null ? Colors.white : Colors.grey[700],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: isTablet ? 16.h : 20.h),
            
            // Lien de connexion - sur deux lignes séparées
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Vous avez déjà un compte ?',
                  style: getSourceSerifProStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen2()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Connectez-vous.',
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      color: Color(0xFF0059AB),
                      fontWeight: FontWeight.w600,
                    ).copyWith(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            
            // Padding en bas
            SizedBox(height: isTablet ? 30.h : 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required String subtitle,
    required String description,
    required String iconPath,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isIPad = shortestSide >= 600 && shortestSide <= 1024;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Permet de cliquer sur toute la surface
      child: Container(
        width: isIPad ? 320.w : 280.w,
        padding: EdgeInsets.symmetric(horizontal: isIPad ? 20.w : 16.w, vertical: isIPad ? 20.h : 16.h),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF0059AB) : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Row(
          children: [
            // Image circulaire
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  iconPath,
                  width: 50.w,
                  height: 50.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 24.sp,
                    );
                  },
                ),
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Contenu texte
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titre - Inter, 700, 16px, #000000
                  Text(
                    title,
                    style: getInterStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000000),
                      height: 1.0, // Line height: 100%
                      letterSpacing: 0.0,
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Sous-titre - Inter, 500, Italic, 9px, #6C7278
                  Text(
                    subtitle,
                    style: getInterStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF6C7278),
                      height: 1.0, // Line height: 100%
                      letterSpacing: 0.0,
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Description - Inter, 600, Italic, 10px, #000000 - détachée en bas, occupe une ligne entière, alignée avec le début
                  Text(
                    description,
                    style: getInterStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF000000),
                      height: 1.0, // Line height: 100%
                      letterSpacing: 0.0,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter pour le motif de grille et points blancs subtils
class GridPatternPainter22 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 0.5;

    // Grille subtile
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // Points blancs subtils (effet réseau)
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Clipper pour créer une forme ovale parfaite en bas du header
class HeaderBottomWaveClipper22 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Commence en haut à gauche
    path.moveTo(0, 0);
    
    // Ligne droite le long du côté gauche jusqu'au début de l'ovale
    path.lineTo(0, size.height - 50);
    
    // Créer une forme ovale parfaite en bas
    final ovalHeight = 120.0; // Hauteur de l'ovale
    final ovalRect = Rect.fromLTWH(
      -size.width * 0.1,  // Commence légèrement avant le bord gauche
      size.height - 50,    // Position verticale du début de l'ovale
      size.width * 1.2,   // Largeur de l'ovale (plus large que l'écran)
      ovalHeight,          // Hauteur de l'ovale
    );
    
    // Dessiner l'arc supérieur de l'ellipse (la partie visible)
    path.arcTo(ovalRect, math.pi, math.pi, false);
    
    // Ligne droite le long du côté droit jusqu'en haut à droite
    path.lineTo(size.width, 0);
    
    // Ferme le path en revenant au point de départ
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

