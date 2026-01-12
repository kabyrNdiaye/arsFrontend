import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'admin_missions_screen.dart';
import 'admin_create_mission_screen.dart';
import 'admin_mission_detail_screen.dart';
import 'admin_edit_mission_screen.dart';
import 'admin_equipe_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_profil_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  
  // Couleurs
  final Color _primaryPurple = Color(0xFF7C39D3);
  final Color _lightPurple = Color(0xFF9C27B0);
  final Color _statCardPurple = Color(0xFF9A64E1);
  final Color _primaryBlue = Color(0xFF3366E3);
  final Color _greenStatus = Color(0xFF4CAF50);
  final Color _redStatus = Color(0xFFF44336);
  final Color _blueStatus = Color(0xFF2196F3);
  
  // Liste de toutes les missions (mutable)
  List<Map<String, dynamic>> _allMissions = [
    {
      'establishment': 'EHPAD Les Jardins',
      'address': '12 Rue de la Santé, Paris',
      'professional': 'Jean Dupont',
      'status': 'En cours',
      'schedule': '7h30 - 16h00',
      'date': '17 Nov 2025',
    },
    {
      'establishment': 'EHPAD Les Jardins',
      'address': '12 Rue de la Santé, Paris',
      'professional': 'Marie Leroy',
      'status': 'Réfusé',
      'schedule': '8h00 - 17h00',
      'date': '18 Nov 2025',
    },
    {
      'establishment': 'EHPAD Les Jardins',
      'address': '12 Rue de la Santé, Paris',
      'professional': 'Pierre Bernard',
      'status': 'Confirmée',
      'schedule': '9h00 - 18h00',
      'date': '19 Nov 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header violet
            _buildHeader(langProvider),
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    // Boutons d'action
                    _buildActionButtons(langProvider),
                    SizedBox(height: 24.h),
                    // Section Missions du jour
                    _buildMissionsSection(langProvider),
                    SizedBox(height: 24.h),
                    // Section Alertes récentes
                    _buildAlertsSection(langProvider),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            // Navigation en bas
            _buildBottomNav(langProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: _primaryPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      child: Column(
        children: [
          // Trait horizontal en haut
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top > 0 ? 8.h : 32.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          SizedBox(height: 16.h),
          // Profil et notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profil
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.grey[600],
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        langProvider.translate('hello'),
                        style: getSourceSerifProStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Sophie Martin',
                        style: getSourceSerifProStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Notifications
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: _primaryPurple, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '2',
                          style: getSourceSerifProStyle(
                            fontSize: 9.sp,
                            color: Colors.white,
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
          SizedBox(height: 24.h),
          // Cartes de statistiques
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard('8', langProvider.translate('mission_today')),
              SizedBox(width: 8.w),
              _buildStatCard('24', langProvider.translate('available_professionals')),
              SizedBox(width: 8.w),
              _buildStatCard('12', langProvider.translate('active_sites')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
  return Container(
    width: 104.w,
    height: 94.w, // Hauteur légèrement augmentée pour éviter l'overflow
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h), // Padding réduit
    decoration: BoxDecoration(
      color: _statCardPurple,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: getSourceSerifProStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: getSourceSerifProStyle(
            fontSize: 11.sp,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

  Widget _buildActionButtons(LanguageProvider langProvider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminCreateMissionScreen(
                    onMissionCreated: (newMission) {
                      setState(() {
                        _allMissions.insert(0, newMission);
                      });
                    },
                  ),
                ),
              );
              if (result != null) {
                setState(() {
                  _allMissions.insert(0, result);
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 32.sp, color: Colors.white),
                SizedBox(height: 8.h),
                Text(
                  langProvider.translate('create_mission'),
                  style: getSourceSerifProStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Créer formation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_outlined, size: 32.sp, color: Colors.white),
                SizedBox(height: 8.h),
                Text(
                  langProvider.translate('create_training'),
                  style: getSourceSerifProStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionsSection(LanguageProvider langProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              langProvider.translate('missions_of_day'),
              style: getSourceSerifProStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () {
                _showAllMissions(langProvider);
              },
              child: Text(
                langProvider.translate('see_all'),
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ..._allMissions.take(3).map((mission) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildMissionCard(
            mission['establishment'] ?? '',
            mission['professional'] ?? '',
            mission['status'] ?? '',
            mission,
            langProvider,
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildMissionCard(String title, String professional, String status, Map<String, dynamic>? missionData, LanguageProvider langProvider) {
    final mission = missionData ?? {
      'establishment': title,
      'professional': professional,
      'status': status,
    };
    // Déterminer les couleurs selon le statut
    Color statusBgColor;
    Color statusTextColor;
    
    if (status == 'En cours') {
      statusBgColor = Color(0xFFE2FBE9);
      statusTextColor = Color(0xFF009814);
    } else if (status == 'Réfusé') {
      statusBgColor = Color(0xFFFAE3E3);
      statusTextColor = Color(0xFFFF0000);
    } else if (status == 'Confirmée') {
      statusBgColor = Color(0xFFDEEAFC);
      statusTextColor = Color(0xFF0059AB);
    } else {
      statusBgColor = Colors.grey[200]!;
      statusTextColor = Colors.grey[700]!;
    }
    return Container(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: getSourceSerifProStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minWidth: 80.w, // Largeur minimale uniforme
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: getSourceSerifProStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: statusTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.grey[600],
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  mission['address'] ?? '',
                  style: getSourceSerifProStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminMissionDetailScreen(
                          mission: mission,
                          onMissionUpdated: (updatedMission) {
                            setState(() {
                              final index = _allMissions.indexWhere((m) => 
                                m['establishment'] == mission['establishment'] &&
                                m['professional'] == mission['professional']
                              );
                              if (index != -1) {
                                _allMissions[index] = updatedMission;
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Color(0xFFF9F6FE),
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 16.sp,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        langProvider.translate('see'),
                        style: getSourceSerifProStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminEditMissionScreen(
                          mission: mission,
                          onMissionUpdated: (updatedMission) {
                            setState(() {
                              final index = _allMissions.indexWhere((m) => 
                                m['establishment'] == mission['establishment'] &&
                                m['professional'] == mission['professional']
                              );
                              if (index != -1) {
                                _allMissions[index] = updatedMission;
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Color(0xFFF9F6FE),
                    foregroundColor: _primaryPurple,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide.none,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 16.sp,
                        color: _primaryPurple,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        langProvider.translate('edit'),
                        style: getSourceSerifProStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllMissions(LanguageProvider langProvider) {
    if (_allMissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('no_mission_available')),
          backgroundColor: Colors.grey[600],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Barre de drag
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Titre
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      langProvider.translate('all_missions'),
                      style: getSourceSerifProStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Liste des missions
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _allMissions.length,
                  itemBuilder: (context, index) {
                    final mission = _allMissions[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildMissionCard(
                        mission['establishment'] ?? '',
                        mission['professional'] ?? '',
                        mission['status'] ?? '',
                        mission,
                        langProvider,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertsSection(LanguageProvider langProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langProvider.translate('recent_alerts'),
          style: getSourceSerifProStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        _buildAlertCard(
          Icons.warning_amber_rounded,
          Color(0xFFFFEBEE), // Light red background
          Color(0xFFEF5350), // Red icon
          langProvider.translate('incident_reported') + ' - EHPAD Les Jardins',
          '10:30',
        ),
        SizedBox(height: 12.h),
        _buildAlertCard(
          Icons.notifications_outlined,
          Color(0xFFE3F2FD), // Light blue background
          Color(0xFF2196F3), // Blue icon
          langProvider.translate('new_note') + ' de Jean Dupont',
          '09:15',
        ),
        SizedBox(height: 12.h),
        _buildAlertCard(
          Icons.menu_book_outlined,
          Color(0xFFFFF3E0), // Light orange background
          Color(0xFFFF9800), // Orange icon
          '3 ' + langProvider.translate('trainings_to_validate'),
          'Hier', // TODO: Traduire date
        ),
      ],
    );
  }

  Widget _buildAlertCard(IconData icon, Color iconBg, Color iconColor, String text, String time) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône dans un cercle coloré
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Texte et timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: getSourceSerifProStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  style: getSourceSerifProStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, Icons.home, langProvider.translate('home'), 0, langProvider),
              _buildNavItem(Icons.card_giftcard_rounded, Icons.card_giftcard, langProvider.translate('missions'), 1, langProvider),
              _buildNavItem(Icons.people_outline, Icons.people, langProvider.translate('team'), 2, langProvider),
              _buildNavItem(Icons.settings_outlined, Icons.settings, langProvider.translate('admin_panel'), 3, langProvider),
              _buildNavItem(Icons.person_outline, Icons.person, langProvider.translate('profile'), 4, langProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index, LanguageProvider langProvider) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? _primaryPurple : Colors.grey[400];
    
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminMissionsScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminEquipeScreen()));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminSettingsScreen()));
        } else if (index == 4) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminProfilScreen()));
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSelected ? activeIcon : icon, color: color, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            style: getSourceSerifProStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

