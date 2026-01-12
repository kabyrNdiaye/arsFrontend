import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';
import '../auth/register_screen.dart';
import '../professionnel_screen/home_screen.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'henry.petavin@gmail.com');
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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      await Future.delayed(Duration(seconds: 1));
      
      setState(() => _isLoading = false);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    
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
                    // Header bleu avec logo et Connexion - hauteur adaptative
                    _buildBlueHeader(screenHeight, isTablet, isDesktop),
                    
                    // Formulaire de connexion
                    Expanded(
                      child: _buildLoginForm(),
                    ),
                    
                    // Barre de navigation en bas
                    _buildBottomNavigationBar(),
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
    
    if (isDesktop) {
      // Desktop : hauteur plus petite, logo moyen
      headerHeight = 250.h;
      logoHeight = 140.h;
      fontSize = 24.sp;
    } else if (isTablet) {
      // Tablette (iPad Pro, etc.) : hauteur réduite pour éviter le débordement
      headerHeight = screenHeight * 0.25;
      logoHeight = screenHeight * 0.10;
      fontSize = 24.sp;
    } else {
      // Téléphone : hauteur proportionnelle
      headerHeight = screenHeight * 0.35;
      logoHeight = screenHeight * 0.15;
      fontSize = 28.sp;
    }
    
    // Limites pour éviter les tailles extrêmes
    headerHeight = headerHeight.clamp(200.h, 350.h);
    logoHeight = logoHeight.clamp(80.h, 180.h);
    fontSize = fontSize.clamp(20.sp, 28.sp);
    
    final logoWidth = logoHeight * 1.4;
    
    return ClipPath(
      clipper: HeaderBottomWaveClipper(),
      child: Container(
        height: headerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFF0059AB),
        ),
        child: Stack(
          children: [
            // Motif de grille et points blancs subtils
            CustomPaint(
              size: Size(double.infinity, headerHeight),
              painter: GridPatternPainter(),
            ),
            
            // Logo ARS centré avec texte "Connexion" en dessous
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
                  
                  // Texte "Connexion" en dessous du logo - remonté avec Transform
                  Transform.translate(
                    offset: Offset(0, isTablet || isDesktop ? -12.h : -20.h),
                    child: Text(
                      'Connexion',
                      style: getSourceSerifProStyle(
                        fontSize: fontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildLoginForm() {
    // Détecter si c'est une tablette pour ajuster les espacements
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: isTablet ? 10.h : 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Texte d'instruction
              Padding(
                padding: EdgeInsets.only(top: isTablet ? 10.h : 0),
                child: Text(
                  'Entrez votre email et mot de passe pour accéder à votre compte.',
                  style: getSourceSerifProStyle(
                    fontSize: 14.sp,
                    color: Colors.black,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: isTablet ? 30.h : 40.h),
              
              // Label Email
              Text(
                'Adresse Email',
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              
              // Champ Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'henry.petavin@gmail.com',
                  suffixIcon: Icon(Icons.person_outline, color: Colors.grey[400], size: 20.sp),
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
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 24.h),
              
              // Label Mot de passe
              Text(
                'Mot de Passe',
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              
              // Champ Mot de passe
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey[400],
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
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
                    return 'Veuillez entrer votre mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: isTablet ? 15.h : 20.h),
              
              // Checkbox et lien mot de passe oublié
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() => _rememberMe = value ?? false);
                        },
                        activeColor: Color(0xFF0059AB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Text(
                        'Se souvenir de moi ?',
                        style: getSourceSerifProStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigation vers mot de passe oublié
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Mot de Passe Oublié ?',
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 25.h : 32.h),
              
              // Bouton de connexion
              ElevatedButton(
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
                        'SE CONNECTER',
                        style: getSourceSerifProStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
              
              SizedBox(height: isTablet ? 20.h : 24.h),
              
              // Lien d'inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vous n\'avez pas de compte ? ',
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Inscrivez-vous.',
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF0059AB),
                        fontWeight: FontWeight.w600,
                      ).copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 15.h : 20.h),
              
              // Padding en bas pour éviter le débordement sur iPad Pro
              SizedBox(height: isTablet ? 30.h : 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavIcon(Icons.home_outlined, 'Accueil', false),
          _buildNavIcon(Icons.menu_book_outlined, 'Missions', false),
          _buildNavIcon(Icons.search_outlined, 'Recherche', false),
          _buildNavIcon(Icons.person_outline, 'Profil', true), // Profil sélectionné avec ligne bleue
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isSelected)
          Container(
            width: 30.w,
            height: 3.h,
            color: Color(0xFF0059AB),
            margin: EdgeInsets.only(bottom: 4.h),
          )
        else
          SizedBox(height: 3.h + 4.h), // Espace pour aligner les icônes
        Icon(
          icon,
          color: Color(0xFF0059AB),
          size: 24.sp,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: getSourceSerifProStyle(
            fontSize: 10.sp,
            color: Color(0xFF0059AB),
          ),
        ),
      ],
    );
  }
}

// Painter pour le motif de grille et points blancs subtils
class GridPatternPainter extends CustomPainter {
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
class HeaderBottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Commence en haut à gauche
    path.moveTo(0, 0);
    
    // Ligne droite le long du côté gauche jusqu'au début de l'ovale
    path.lineTo(0, size.height - 40);
    
    // Créer une forme ovale parfaite en bas
    // Utiliser une ellipse pour créer un ovale parfait
    // L'ovale commence à gauche, descend au centre, puis remonte à droite
    final ovalHeight = 80.0; // Hauteur de l'ovale
    final ovalRect = Rect.fromLTWH(
      -size.width * 0.1,  // Commence légèrement avant le bord gauche
      size.height - 40,    // Position verticale du début de l'ovale
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
