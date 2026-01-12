import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/font_helper.dart';
import '../../utils/header_color_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../auth/login_screen_2.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _currentTime = '16:04';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Mettre à jour l'heure chaque minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  Widget _buildMissionsIcon(bool isActive) {
    return Image.asset(
      isActive 
        ? 'assets/images/icon_missions_active.png'
        : 'assets/images/icon_missions_non_active.png',
      width: 24.w,
      height: 24.h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          isActive ? Icons.work : Icons.work_outline,
          color: isActive ? Color(0xFF0059AB) : Colors.grey,
          size: 24.sp,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    
    // Obtenir l'utilisateur connecté pour déterminer la couleur du header
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    // Obtenir la couleur du header selon l'utilisateur connecté
    // Type 'professionnel' car nous sommes dans les écrans professionnel
    final headerColor = HeaderColorHelper.getHeaderColor(
      userType: 'professionnel',
      userEmail: user?.email,
      userId: user?.id,
      userRole: 'chef', // Peut être récupéré depuis le backend
    );
    
    final statusBarIconBrightness = HeaderColorHelper.getStatusBarIconBrightness(headerColor);
    
    // Configuration de la barre de statut système
    // statusBarColor correspond à la couleur du header pour une intégration visuelle parfaite
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: headerColor, // Couleur dynamique selon l'utilisateur
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            _buildMissionsTab(),
            _buildFormationTab(),
            _buildProfileTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF0059AB),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/missions.png',
              width: 24.w,
              height: 24.h,
              fit: BoxFit.contain,
              color: Colors.grey,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.work_outline, color: Colors.grey);
              },
            ),
            activeIcon: Image.asset(
              'assets/images/missions.png',
              width: 24.w,
              height: 24.h,
              fit: BoxFit.contain,
              color: Color(0xFF0059AB),
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.work, color: Color(0xFF0059AB));
              },
            ),
            label: 'Missions',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icon_formation.png',
              width: 24.w,
              height: 24.h,
              color: Colors.grey,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.school_outlined, color: Colors.grey);
              },
            ),
            activeIcon: Image.asset(
              'assets/images/icon_formation.png',
              width: 24.w,
              height: 24.h,
              color: Color(0xFF0059AB),
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.school, color: Color(0xFF0059AB));
              },
            ),
            label: 'Formation',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icon_profil_non_active.png',
              width: 24.w,
              height: 24.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.person_outline, color: Colors.grey);
              },
            ),
            activeIcon: Image.asset(
              'assets/images/icon_profil_active.png',
              width: 24.w,
              height: 24.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.person, color: Color(0xFF0059AB));
              },
            ),
            label: 'Profil',
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Container(
      color: Color(0xFFF4F6F9), // Fond gris très clair
      child: Column(
        children: [
          // Header avec fond bleu qui s'étend jusqu'en haut
          _buildHeader(),
          
          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Prochaine Mission
                  _buildNextMissionSection(),
                  
                  SizedBox(height: 20.h),
                  
                  // Section Formation en cours
                  _buildCurrentTrainingSection(),
                  
                  SizedBox(height: 20.h),
                  
                  // Section Missions
                  _buildMissionsSection(),
                  
                  SizedBox(height: 20.h),
                  
                  // Section Historique des paiements
                  _buildPaymentHistorySection(),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Grand header bleu qui s'étend depuis le haut
  Widget _buildHeader() {
    // Obtenir la couleur du header selon l'utilisateur connecté
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    // Type 'professionnel' car nous sommes dans les écrans professionnel
    final headerColor = HeaderColorHelper.getHeaderColor(
      userType: 'professionnel',
      userEmail: user?.email,
      userId: user?.id,
      userRole: 'chef', // Peut être récupéré depuis le backend
    );
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: headerColor, // Couleur dynamique selon l'utilisateur
      ),
      child: SafeArea(
        bottom: false,
        top: false,
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
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de statut et navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icône menu à gauche
                      Icon(
                        Icons.menu,
                        size: 24.sp,
                        color: Colors.white,
                      ),
              
              // Droite : Icônes de statut + Notification
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icônes de statut (Wi-Fi, batterie)
                  Icon(
                    Icons.wifi,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.battery_full,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.w),
                  // Notification avec badge rouge
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          size: 24.sp,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Navigation vers notifications
                        },
                      ),
                      Positioned(
                        right: 8.w,
                        top: 8.h,
                        child: Container(
                          width: 18.w,
                          height: 18.h,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '2',
                              style: getSourceSerifProStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // "TABLEAU DE BORD" centré sous les icônes
          Center(
            child: Text(
              'TABLEAU DE BORD',
              style: getSourceSerifProStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          SizedBox(height: 30.h),
          
          // Message de bienvenue et photo de profil
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonne gauche : Message de bienvenue
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenu,',
                      style: getSourceSerifProStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Joe Doué',
                      style: getSourceSerifProStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Photo de profil circulaire à droite
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/icon_personne.png',
                    width: 60.w,
                    height: 60.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 40.sp,
                        color: Color(0xFF0053A6),
                      );
                    },
                  ),
                ),
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

  // Section Bienvenue avec photo de profil
  Widget _buildWelcomeSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color(0xFF0053A6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Bienvenu,',
                    style: getSourceSerifProStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: '\nJoe Doué',
                    style: getSourceSerifProStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Photo de profil circulaire
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/icon_personne.png',
                width: 60.w,
                height: 60.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: 40.sp,
                    color: Color(0xFF0053A6),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Prochaine Mission - Carte blanche avec coins arrondis
  Widget _buildNextMissionSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Mask - Image de chef en arrière-plan à droite, très subtile
          Positioned(
            right: 10.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'assets/images/Mask.png',
                  width: 100.w,
                  height: 100.h,
                  fit: BoxFit.contain,
                  color: Color(0xFF0053A6).withOpacity(0.15),
                  colorBlendMode: BlendMode.srcATop,
                ),
              ),
            ),
          ),
          // Contenu principal
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre avec icône
              Row(
                children: [
                  Image.asset(
                    'assets/images/icon_missions_non_active.png',
                    width: 24.w,
                    height: 24.h,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.description_outlined,
                        size: 24.sp,
                        color: Color(0xFF0053A6),
                      );
                    },
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Prochaine Mission',
                    style: getSourceSerifProStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0053A6),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // Date et heure
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18.sp,
                    color: Color(0xFF0053A6),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Le 26 Juin à 13h30',
                    style: getSourceSerifProStyle(
                      fontSize: 15.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Lieu
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18.sp,
                    color: Color(0xFF0053A6),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Hopital Phillipe Madileine Senghor',
                      style: getSourceSerifProStyle(
                        fontSize: 15.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section Formation en cours avec carte de module
  Widget _buildCurrentTrainingSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Formation en cours:',
            style: getSourceSerifProStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Numéro du module en haut - aligné avec "Module Hygiène HACCP"
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Espace équivalent à Vector (40.w) + espacement (12.w) pour aligner avec le texte
                    SizedBox(width: 40.w + 12.w),
                    // Icône livre
                    Icon(
                      Icons.book,
                      size: 20.sp,
                      color: Color(0xFF0053A6),
                    ),
                    SizedBox(width: 2.w),
                    // Texte "Module: 4/5" aligné avec "Module Hygiène HACCP"
                    Text(
                      'Module: 4/5',
                      style: getSourceSerifProStyle(
                        fontSize: 15.sp,
                        color: Color(0xFF0053A6).withOpacity(0.8),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // Ligne avec image Vector + titre + indicateur de progression - tous alignés verticalement au centre
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image Vector
                    Image.asset(
                      'assets/images/Vector.png',
                      width: 40.w,
                      height: 40.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 4.w),
                    // Titre du module - aligné verticalement au centre avec Vector
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Module Hygiène HACCP',
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    // Image Group pour remplacer le pourcentage
                    Image.asset(
                      'assets/images/Group.png',
                      width: 50.w,
                      height: 50.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // Bouton Continuez aligné avec "Module Hygiène HACCP"
                Row(
                  children: [
                    // Espace équivalent à Vector (40.w) + espacement (12.w) pour aligner avec le texte
                    SizedBox(width: 40.w + 12.w),
                    ElevatedButton(
                      onPressed: () {
                        // Action pour continuer la formation
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0053A6),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continuez',
                            style: getSourceSerifProStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.arrow_forward, size: 18.sp),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Indicateur de progression circulaire en pointillés
  Widget _buildDashedCircularProgress(int percentage) {
    return CustomPaint(
      size: Size(70.w, 70.h),
      painter: DashedCircularProgressPainter(
        progress: percentage / 100,
        color: Color(0xFF0053A6),
      ),
      child: Center(
        child: Text(
          '$percentage %',
          style: getSourceSerifProStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0053A6),
          ),
        ),
      ),
    );
  }

  // Section Missions en liste verticale
  Widget _buildMissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Missions',
                style: getSourceSerifProStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigation vers toutes les missions
                },
                child: Text(
                  'Voir plus',
                  style: getSourceSerifProStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _buildMissionCard(),
              SizedBox(height: 12.h),
              _buildMissionCard(),
              SizedBox(height: 12.h),
              _buildMissionCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne 1: Préparation et 9 heures
          Row(
            children: [
              Icon(
                Icons.dining,
                size: 18.sp,
                color: Colors.grey[700],
              ),
              SizedBox(width: 6.w),
              Text(
                'Préparation',
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Spacer(),
              Icon(
                Icons.access_time,
                size: 16.sp,
                color: Colors.grey[600],
              ),
              SizedBox(width: 4.w),
              Text(
                '9 heures',
                style: getSourceSerifProStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // Ligne 2: Hôpital
          Row(
            children: [
              Icon(
                Icons.apartment,
                size: 16.sp,
                color: Colors.grey[600],
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Hopital saint joseph',
                  style: getSourceSerifProStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Ligne 3: Date/Heure et boutons sur la même ligne
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month,
                size: 16.sp,
                color: Colors.grey[600],
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  'Le 25/02/2025 à 16:30',
                  style: getSourceSerifProStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Bouton Refuser
              ElevatedButton(
                onPressed: () {
                  // Action refuser
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  minimumSize: Size(0, 32.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Refuser',
                  style: getSourceSerifProStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              // Bouton Valider
              ElevatedButton(
                onPressed: () {
                  // Action valider
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0053A6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  minimumSize: Size(0, 32.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Valider',
                  style: getSourceSerifProStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section Historique des paiements
  Widget _buildPaymentHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historique des paiements',
                style: getSourceSerifProStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigation vers historique complet
                },
                child: Text(
                  'Voir plus',
                  style: getSourceSerifProStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF0053A6),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _buildPaymentItem('Préparation', '13 Octobre 2022', '200 €', hasDelete: false),
              SizedBox(height: 8.h),
              _buildPaymentItem('Préparation', '13 Octobre 2022', '200 €', hasDelete: false),
              SizedBox(height: 8.h),
              _buildPaymentItem('Préparation', '13 Octobre 2022', '200 €', hasDelete: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(String type, String date, String amount, {required bool hasDelete}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Partie gauche avec icône et informations
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  if (!hasDelete)
                    Icon(
                      Icons.download_outlined,
                      size: 24.sp,
                      color: Color(0xFF0053A6),
                    )
                  else
                    Icon(
                      Icons.download_outlined,
                      size: 24.sp,
                      color: Color(0xFF0053A6),
                    ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          date,
                          style: getSourceSerifProStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amount,
                    style: getSourceSerifProStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Partie droite avec fond rouge et icône poubelle (seulement pour hasDelete)
          if (hasDelete)
            Container(
              width: 60.w,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 24.sp,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Action supprimer
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMissionsTab() {
    return Column(
      children: [
        _buildSimpleHeader('Mes Missions'),
        Expanded(
          child: Center(
            child: Text(
              'Mes Missions',
              style: getSourceSerifProStyle(
                fontSize: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormationTab() {
    return Column(
      children: [
        _buildSimpleHeader('Mes Formations'),
        Expanded(
          child: Center(
            child: Text(
              'Formation',
              style: getSourceSerifProStyle(
                fontSize: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return Column(
      children: [
        _buildSimpleHeader('Mon Profil'),
        Expanded(
          child: Center(
            child: Text(
              'Profil',
              style: getSourceSerifProStyle(
                fontSize: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleHeader(String title) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF0059AB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
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
            child: Center(
              child: Text(
                title,
                style: getSourceSerifProStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter pour l'indicateur de progression circulaire en pointillés
class DashedCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  DashedCircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Dessiner le cercle complet en pointillés
    final dashWidth = 4.0;
    final dashSpace = 4.0;
    final circumference = 2 * 3.14159 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final dashAngle = (2 * 3.14159) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final endAngle = startAngle + (dashAngle * dashWidth / (dashWidth + dashSpace));
      
      if (i / dashCount <= progress) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle - 3.14159 / 2, // Commencer en haut
          endAngle - startAngle,
          false,
          paint,
        );
      } else {
        // Partie non complétée en gris
        final grayPaint = Paint()
          ..color = Colors.grey[300]!
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle - 3.14159 / 2,
          endAngle - startAngle,
          false,
          grayPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter pour la ligne pointillée
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter pour les lignes diagonales
// Painter pour la flèche circulaire autour de l'ampoule
class CircularArrowPainter extends CustomPainter {
  final Color color;

  CircularArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Dessiner un arc circulaire en pointillés avec une flèche à la fin
    // Arc de cercle qui commence en haut-droite et tourne vers le bas-droite (environ 270 degrés)
    final startAngle = -0.785; // -45 degrés en radians (commence en haut-droite)
    final sweepAngle = 4.71; // 270 degrés en radians
    
    // Dessiner l'arc en pointillés
    final dashWidth = 3.0;
    final dashSpace = 2.0;
    final totalAngle = sweepAngle;
    final numDashes = 20; // Nombre de segments pour créer l'effet pointillé
    
    for (int i = 0; i < numDashes; i++) {
      final progress = i / numDashes;
      final nextProgress = (i + 0.6) / numDashes; // 60% de chaque segment est un tiret
      
      if (nextProgress > 1.0) break;
      
      final angle1 = startAngle + (totalAngle * progress);
      final angle2 = startAngle + (totalAngle * math.min(nextProgress, 1.0));
      
      final x1 = center.dx + radius * math.cos(angle1);
      final y1 = center.dy + radius * math.sin(angle1);
      final x2 = center.dx + radius * math.cos(angle2);
      final y2 = center.dy + radius * math.sin(angle2);
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Dessiner la flèche à la fin de l'arc (en bas-droite)
    final arrowSize = 5.0;
    final arrowAngle = startAngle + sweepAngle; // Fin de l'arc
    final arrowX = center.dx + radius * math.cos(arrowAngle);
    final arrowY = center.dy + radius * math.sin(arrowAngle);

    final arrowPath = Path();
    arrowPath.moveTo(arrowX, arrowY);
    arrowPath.lineTo(
      arrowX - arrowSize * math.cos(arrowAngle - 0.5),
      arrowY - arrowSize * math.sin(arrowAngle - 0.5),
    );
    arrowPath.moveTo(arrowX, arrowY);
    arrowPath.lineTo(
      arrowX - arrowSize * math.cos(arrowAngle + 0.5),
      arrowY - arrowSize * math.sin(arrowAngle + 0.5),
    );

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


class DiagonalLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF0059AB).withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    double startY = -size.width;

    // Lignes diagonales de haut-gauche vers bas-droite
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(size.width, startY + size.width),
        paint,
      );
      startY += spacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
