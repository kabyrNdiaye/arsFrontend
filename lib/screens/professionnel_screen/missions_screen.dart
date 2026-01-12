import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../utils/header_color_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import 'mission_detail_screen.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({Key? key}) : super(key: key);

  @override
  _MissionsScreenState createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  int _selectedTabIndex = 0; // Par défaut sur "À venir"
  
  List<String> _getTabs(LanguageProvider langProvider) {
    return [
      langProvider.translate('upcoming'),
      langProvider.translate('in_progress'),
      langProvider.translate('completed'),
    ];
  }

  // Missions à venir
  final List<Map<String, dynamic>> _missionsAVenir = [
    {
      'etablissement': 'Hôpital Saint Joseph',
      'adresse': '185 Rue Raymond Losserand, Paris 75014',
      'horaires': '8h00 - 17h00',
      'statut': 'en_attente',
    },
    {
      'etablissement': 'EHPAD Les Jardins',
      'adresse': '12 Rue de la Santé, Paris 75014',
      'horaires': '7h30 - 16h00',
      'statut': 'en_attente',
    },
  ];

  // Missions en cours
  final List<Map<String, dynamic>> _missionsEnCours = [
    {
      'etablissement': 'EHPAD Les Jardins',
      'adresse': '12 Rue de la Santé, Paris 75014',
      'horaires': '7h30 - 16h00',
      'statut': 'en_attente',
    },
    {
      'etablissement': 'EHPAD Les Jardins',
      'adresse': '12 Rue de la Santé, Paris 75014',
      'horaires': '7h30 - 16h00',
      'statut': 'confirme',
    },
    {
      'etablissement': 'EHPAD Les Jardins',
      'adresse': '12 Rue de la Santé, Paris 75014',
      'horaires': '7h30 - 16h00',
      'statut': 'refuse',
    },
  ];

  // Missions terminées (vide pour l'instant)
  final List<Map<String, dynamic>> _missionsTerminees = [];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);

    // Obtenir la couleur du header selon l'utilisateur connecté
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    final headerColor = HeaderColorHelper.getHeaderColor(
      userEmail: user?.email,
      userId: user?.id,
    );
    
    final statusBarIconBrightness = HeaderColorHelper.getStatusBarIconBrightness(headerColor);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: headerColor, // Couleur dynamique selon l'utilisateur
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: Column(
          children: [
            // Header bleu
            _buildHeader(langProvider),
            
            // Contenu
            Expanded(
              child: _buildMissionsList(langProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider) {
    // Obtenir la couleur du header selon l'utilisateur connecté
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    // Type 'professionnel' car nous sommes dans les écrans professionnel
    final headerColor = HeaderColorHelper.getHeaderColor(
      userType: 'professionnel',
      userEmail: user?.email,
      userId: user?.id,
    );
    
    final tabs = _getTabs(langProvider);
    
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
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et notification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Titre aligné à gauche
                      Text(
                        langProvider.translate('missions'),
                        style: getInterStyle(
                          fontSize: 24.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // Icône notification
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 26.sp,
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
                                  style: getInterStyle(
                                    fontSize: 10.sp,
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
                  SizedBox(height: 16.h),
                  
                  // Onglets
                  Row(
                    children: List.generate(tabs.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: _buildTab(index, tabs),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, List<String> tabs) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF004A8F) : Color(0xFF3C80C0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          tabs[index],
          style: getInterStyle(
            fontSize: 13.sp,
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildMissionsList(LanguageProvider langProvider) {
    // Sélectionner la liste selon l'onglet actif
    List<Map<String, dynamic>> missions;
    switch (_selectedTabIndex) {
      case 0:
        missions = _missionsAVenir;
        break;
      case 1:
        missions = _missionsEnCours;
        break;
      case 2:
        missions = _missionsTerminees;
        break;
      default:
        missions = _missionsEnCours;
    }

    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 60.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              langProvider.translate('no_missions') == 'no_missions' ? 'Aucune mission' : langProvider.translate('no_missions'),
              style: getInterStyle(
                fontSize: 16.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildMissionCard(mission, langProvider),
        );
      },
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nom de l'établissement et badge de statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  mission['etablissement'],
                  style: getInterStyle(
                    fontSize: 16.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _buildStatusBadge(mission['statut'], langProvider),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Adresse
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16.sp,
                color: Colors.grey[500],
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  mission['adresse'],
                  style: getInterStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          // Horaires
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                size: 16.sp,
                color: Colors.grey[500],
              ),
              SizedBox(width: 6.w),
              Text(
                mission['horaires'],
                style: getInterStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Lien et boutons d'action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lien voir la mission
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MissionDetailScreen(
                        etablissement: mission['etablissement'],
                        adresse: mission['adresse'],
                        horaires: mission['horaires'],
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      langProvider.translate('see_mission') == 'see_mission' ? 'Voir la mission' : langProvider.translate('see_mission'),
                      style: getInterStyle(
                        fontSize: 13.sp,
                        color: Color(0xFF0059AB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right, size: 18.sp, color: Color(0xFF0059AB)),
                  ],
                ),
              ),
              
              // Boutons d'action pour "en_attente"
              if (mission['statut'] == 'en_attente')
                Row(
                  children: [
                    _buildActionButton(langProvider.translate('refuse') == 'refuse' ? 'Refuser' : langProvider.translate('refuse'), Color(0xFFE53935), () {}),
                    SizedBox(width: 8.w),
                    _buildActionButton(langProvider.translate('confirm') == 'confirm' ? 'Confirmer' : langProvider.translate('confirm'), Color(0xFF4CAF50), () {}),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String statut, LanguageProvider langProvider) {
    Color bgColor;
    Color textColor;
    String text;
    
    switch (statut) {
      case 'en_attente':
        bgColor = Color(0xFFFAFCE5);
        textColor = Color(0xFFBECB05);
        text = langProvider.translate('pending');
        break;
      case 'confirme':
        bgColor = Color(0xFFE8F5E9);
        textColor = Color(0xFF4CAF50);
        text = langProvider.translate('confirmed');
        break;
      case 'refuse':
        bgColor = Color(0xFFFAE3E3);
        textColor = Color(0xFFE53935);
        text = langProvider.translate('refused');
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[600]!;
        text = statut;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
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

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: getInterStyle(
            fontSize: 11.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

