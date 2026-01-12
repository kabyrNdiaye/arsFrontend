import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';

class FormationsScreen extends StatefulWidget {
  const FormationsScreen({Key? key}) : super(key: key);

  @override
  _FormationsScreenState createState() => _FormationsScreenState();
}

class _FormationsScreenState extends State<FormationsScreen> {
  // Données de démonstration (en attendant le backend)
  // TODO: Remplacer par les données du backend quand disponible
  final List<Map<String, dynamic>> _formationsObligatoires = [
    {
      'titre': 'Hygiène en cuisine',
      'duree': '45 mn',
      'statut': 'a_completer',
      'image': 'assets/images/formation_hygiene.jpg',
    },
  ];

  final List<Map<String, dynamic>> _formationsRecommandees = [
    {
      'titre': 'Gestion des textures',
      'duree': '30 mn',
      'statut': 'non_commence',
      'image': 'assets/images/formation_textures.jpg',
    },
    {
      'titre': 'Dressage professionnel',
      'duree': '30 mn',
      'statut': 'non_commence',
      'image': 'assets/images/formation_dressage.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0059AB), // Même couleur que le header
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Column(
          children: [
            // Header bleu
            _buildHeader(),
            
            // Contenu
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    
                    // Section Obligatoires
                    _buildSection('Obligatoires', _formationsObligatoires),
                    
                    SizedBox(height: 24.h),
                    
                    // Section Recommandées
                    _buildSection('Recommandées', _formationsRecommandees),
                    
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF0059AB),
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
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Formations',
                    style: getInterStyle(
                      fontSize: 24.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Icône notification
                  Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 26.sp,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 16.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '2',
                              style: getInterStyle(
                                fontSize: 9.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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

  Widget _buildSection(String title, List<Map<String, dynamic>> formations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            title,
            style: getInterStyle(
              fontSize: 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        ...formations.map((formation) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildFormationCard(formation),
        )).toList(),
      ],
    );
  }

  Widget _buildFormationCard(Map<String, dynamic> formation) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Container(
              width: 100.w,
              height: 90.h,
              color: Color(0xFF0059AB).withOpacity(0.1),
              child: Stack(
                children: [
                  // Image placeholder avec icône
                  Center(
                    child: Image.asset(
                      'assets/images/icon_formation.png',
                      width: 40.w,
                      height: 40.h,
                      color: Color(0xFF0059AB).withOpacity(0.5),
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.school_outlined,
                          size: 40.sp,
                          color: Color(0xFF0059AB).withOpacity(0.5),
                        );
                      },
                    ),
                  ),
                  // Icône play
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF0059AB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Contenu
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formation['titre'],
                    style: getInterStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 14.sp,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Durée : ${formation['duree']}',
                        style: getInterStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  if (formation['statut'] == 'a_completer') ...[
                    SizedBox(height: 8.h),
                    _buildStatusBadge(formation['statut']),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String statut) {
    Color bgColor;
    Color textColor;
    String text;
    
    switch (statut) {
      case 'a_completer':
        bgColor = Color(0xFFFFF3E0);
        textColor = Color(0xFFFF9800);
        text = 'A compléter';
        break;
      case 'en_cours':
        bgColor = Color(0xFFE3F2FD);
        textColor = Color(0xFF0059AB);
        text = 'En cours';
        break;
      case 'termine':
        bgColor = Color(0xFFE8F5E9);
        textColor = Color(0xFF4CAF50);
        text = 'Terminé';
        break;
      default:
        return SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: getInterStyle(
          fontSize: 11.sp,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


