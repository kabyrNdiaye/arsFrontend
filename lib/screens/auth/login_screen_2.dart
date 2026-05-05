import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import '../professionnel_screen/home_screen.dart';
import 'login_screen22.dart';
import '../professionnel_screen/professionnel_home_screen.dart';
import '../client_screen/client_home_screen.dart';
import '../admin_screen/admin_home_screen.dart';
import 'forgot_password_screen.dart';
import 'pending_validation_screen.dart';
import 'dart:math' as math;

class LoginScreen2 extends StatefulWidget {
  @override
  _LoginScreen2State createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
    Future<void> _handleLogin() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final result = await authProvider.loginWithCode(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        final code = result['code'];
        final success = result['success'] == true;

        if (code == 'pending_validation') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PendingValidationScreen(
                isRefused: false,
                userRole: result['role'] ?? 'professionnel',
              ),
            ),
          );
          return;
        }

        if (code == 'account_refused') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PendingValidationScreen(
                isRefused: true,
                userRole: result['role'] ?? 'professionnel',
              ),
            ),
          );
          return;
        }

        if (success) {
          final user = authProvider.user;
          
          if (user?.role == 'client') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ClientHomeScreen()));
          } else if (user?.role == 'professionnel') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ProfessionnelHomeScreen()));
          } else if (user?.role == 'admin') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => AdminHomeScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(langProvider.translate("role_not_recognized"))),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? authProvider.errorMessage ?? langProvider.translate("login_failed")),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    
    // Détecter la taille de l'écran et le type d'appareil
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Déterminer le type d'appareil
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final isPhone = screenWidth < 600;
    
    // Largeur maximale adaptative
    double maxWidth;
    if (isDesktop) {
      maxWidth = 500;
    } else if (isTablet) {
      maxWidth = 550;
    } else {
      maxWidth = double.infinity;
    }
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0059AB),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: Column(
                  children: [
                    // Header bleu avec logo et texte ARS - hauteur adaptative
                    _buildBlueHeader(screenHeight, isTablet, isDesktop),
                    
                    // Formulaire de connexion
                    Expanded(
                      child: _buildLoginForm(langProvider),
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
    double fontSize;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isIPad = shortestSide >= 600 && shortestSide <= 1024;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    if (isDesktop) {
      headerHeight = 320.h + statusBarHeight;
      logoHeight = 250.h;
      fontSize = 24.sp;
    } else if (isIPad) {
      // Optimisé pour iPad (mini, pro, max)
      headerHeight = screenHeight * 0.30 + statusBarHeight;
      logoHeight = screenHeight * 0.20;
      fontSize = 24.sp;
    } else if (isTablet) {
      headerHeight = screenHeight * 0.35 + statusBarHeight;
      logoHeight = screenHeight * 0.22;
      fontSize = 24.sp;
    } else {
      headerHeight = screenHeight * 0.33 + statusBarHeight;
      logoHeight = screenHeight * 0.24;
      fontSize = 28.sp;
    }
    
    // Limites pour éviter les tailles extrêmes - ajustées pour iPad
    if (isIPad) {
      headerHeight = headerHeight.clamp(280.h + statusBarHeight, 380.h + statusBarHeight);
      logoHeight = logoHeight.clamp(180.h, 280.h);
    } else {
      headerHeight = headerHeight.clamp(250.h + statusBarHeight, 400.h + statusBarHeight);
      logoHeight = logoHeight.clamp(200.h, 350.h);
    }
    fontSize = fontSize.clamp(20.sp, 28.sp);
    
    final logoWidth = logoHeight * 1.4;
    
    return ClipPath(
      clipper: HeaderBottomWaveClipper2(),
      child: Container(
        height: headerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFF0059AB),
        ),
        child: Stack(
          children: [
            // Logo ARS centré avec textes en dessous
            Padding(
              padding: EdgeInsets.only(top: statusBarHeight),
              child: Center(
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
                  ],
                ),
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

  Widget _buildLoginForm(LanguageProvider langProvider) {
    // Détecter si c'est une tablette pour ajuster les espacements
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: isTablet ? 10.h : 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Texte d'instruction
              Padding(
                padding: EdgeInsets.only(top: isTablet ? 20.h : 30.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 285.w),
                  child: Text(
                    langProvider.translate('login_instructions'),
                    style: getSourceSerifProStyle(
                      fontSize: 16.sp,
                      color: Colors.black87,
                      height: 1.0, // Line height: 100%
                      fontWeight: FontWeight.w400, // Regular (400)
                      letterSpacing: 0.0, // Letter spacing: 0%
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              SizedBox(height: isTablet ? 30.h : 40.h),
              
              // Champ Email - sans label, placeholder simple
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 280.w),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: langProvider.translate('email'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF0059AB), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return langProvider.translate('error_email');
                    }
                    if (!value.contains('@')) {
                      return langProvider.translate('error_email_invalid');
                    }
                    return null;
                  },
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Champ Mot de passe - sans label, placeholder simple
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 280.w),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: langProvider.translate('password'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF0059AB), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return langProvider.translate('error_password');
                    }
                    if (value.length < 6) {
                      return langProvider.translate('error_password_short');
                    }
                    return null;
                  },
                ),
              ),
              
              SizedBox(height: 12.h),
              
              // Lien mot de passe oublié aligné à droite
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 280.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    langProvider.translate('forgot_password'),
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ),
              ),
              
              SizedBox(height: isTablet ? 30.h : 40.h),
              
              // Bouton de connexion
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 280.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0059AB),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            langProvider.translate('login'),
                            style: getSourceSerifProStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
              
              SizedBox(height: isTablet ? 24.h : 28.h),
              
              // Lien d'inscription - sur deux lignes séparées
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    langProvider.translate('no_account'),
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen22()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      langProvider.translate('register_link'),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF0059AB),
                        fontWeight: FontWeight.w600,
                      ).copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              
              // Padding en bas pour éviter le débordement
              SizedBox(height: isTablet ? 30.h : 40.h),
            ],
          ),
        ),
      ),
    );
  }

}

// Painter pour le motif de grille et points blancs subtils
class GridPatternPainter2 extends CustomPainter {
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
class HeaderBottomWaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Commence en haut à gauche
    path.moveTo(0, 0);
    
    // Ligne droite le long du côté gauche jusqu'au début de l'ovale
    path.lineTo(0, size.height - 50);
    
    // Créer une forme ovale parfaite en bas
    // Utiliser une ellipse pour créer un ovale parfait
    // L'ovale commence à gauche, descend au centre, puis remonte à droite
    final ovalHeight = 120.0; // Hauteur de l'ovale augmentée
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

