import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'admin_home_screen.dart';
import 'admin_missions_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_profil_screen.dart';

class AdminEquipeScreen extends StatefulWidget {
  const AdminEquipeScreen({Key? key}) : super(key: key);

  @override
  _AdminEquipeScreenState createState() => _AdminEquipeScreenState();
}

class _AdminEquipeScreenState extends State<AdminEquipeScreen> {
  int _currentIndex = 2; // Équipe est l'onglet actif
  final TextEditingController _searchController = TextEditingController();
  final Color _primaryPurple = Color(0xFF7C39D3);
  final Color _lightPurple = Color(0xFF9058D4);
  String _searchQuery = '';

  // Liste des professionnels
  List<Map<String, dynamic>> _allProfessionals = [
    {
      'name': 'Jean Dupont',
      'role': 'Cuisinier',
      'status': 'En mission',
      'mission': 'EHPAD Les Jardins',
    },
    {
      'name': 'Marie Leroy',
      'role': 'Chef de cuisine',
      'status': 'En mission',
      'mission': 'Restaurant Le Gourmet',
    },
    {
      'name': 'Marie Leroy',
      'role': 'Chef de cuisine',
      'status': 'En mission',
      'mission': 'Restaurant Le Gourmet',
    },
    {
      'name': 'Pierre Bernard',
      'role': 'Chef de cuisine',
      'status': 'Disponible',
    },
    {
      'name': 'Sophie Moreau',
      'role': 'Pâtissière',
      'status': 'Disponible',
    },
    {
      'name': 'Jean Pierre',
      'role': 'Cuisinier',
      'status': 'Disponible',
    },
    {
      'name': 'Marie Moreau',
      'role': 'Cuisinier',
      'status': 'Disponible',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  // Filtrer les professionnels selon la recherche
  List<Map<String, dynamic>> get _filteredProfessionals {
    if (_searchQuery.isEmpty) {
      return _allProfessionals;
    }
    final query = _searchQuery.toLowerCase();
    return _allProfessionals.where((professional) {
      return professional['name'].toString().toLowerCase().contains(query) ||
             professional['role'].toString().toLowerCase().contains(query);
    }).toList();
  }

  // Compter les professionnels disponibles
  int get _availableCount {
    return _allProfessionals.where((p) => p['status'] == 'Disponible' || p['status'] == 'Available' || p['status'] == 'Disponibles').length;
  }

  // Compter les professionnels en mission
  int get _onMissionCount {
    return _allProfessionals.where((p) => p['status'] == 'En mission' || p['status'] == 'On mission' || p['status'] == 'En misión').length;
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: Column(
          children: [
            // Header violet
            _buildHeader(langProvider),
            // Cartes de statistiques
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard('$_availableCount', langProvider.translate('available'), _primaryPurple),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard('$_onMissionCount', langProvider.translate('in_progress'), Color(0xFF4CAF50)),
                  ),
                ],
              ),
            ),
            // Liste des professionnels
            Expanded(
              child: _filteredProfessionals.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              langProvider.translate('no_professional_found'),
                              style: getSourceSerifProStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                      itemCount: _filteredProfessionals.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildProfessionalCard(_filteredProfessionals[index], langProvider),
                        );
                      },
                    ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(langProvider),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Ajouter un professionnel
          },
          backgroundColor: _primaryPurple,
          child: Icon(Icons.add, color: Colors.white, size: 28.sp),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _primaryPurple,
            _primaryPurple,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre et notifications
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    langProvider.translate('team_management'),
                    style: getSourceSerifProStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 26.sp,
                      ),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF5252),
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 18.w,
                            minHeight: 18.w,
                          ),
                          child: Center(
                            child: Text(
                              '2',
                              style: getSourceSerifProStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Barre de recherche
              Container(
                decoration: BoxDecoration(
                  color: _lightPurple.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: langProvider.translate('search_professional_hint'),
                    hintStyle: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.9), size: 22.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  ),
                  style: getSourceSerifProStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color valueColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: getSourceSerifProStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: getSourceSerifProStyle(
              fontSize: 13.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(Map<String, dynamic> professional, LanguageProvider langProvider) {
    final isOnMission = professional['status'] == 'En mission';

    return InkWell(
      onTap: () {
        // TODO: Naviguer vers les détails du professionnel
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section principale avec avatar, nom, rôle, statut
            Row(
              children: [
                // Avatar circulaire avec fond violet clair
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFEDE7F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: _primaryPurple,
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom en gras
                      Text(
                        professional['name'] ?? '',
                        style: getSourceSerifProStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Rôle en gris
                      Text(
                        professional['role'] ?? '',
                        style: getSourceSerifProStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      // Badge de statut
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isOnMission ? Color(0xFFE8F5E9) : Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          professional['status'] ?? '',
                          style: getSourceSerifProStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: isOnMission ? Color(0xFF4CAF50) : Color(0xFF2196F3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Flèche à droite
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 24.sp,
                ),
              ],
            ),
            // Section mission (si en mission)
            if (isOnMission && professional['mission'] != null) ...[
              SizedBox(height: 12.h),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${langProvider.translate('mission')} : ',
                      style: getSourceSerifProStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: professional['mission'] ?? '',
                      style: getSourceSerifProStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, langProvider.translate('home'), 0, langProvider),
              _buildNavItem(Icons.work_outline, Icons.work, langProvider.translate('missions'), 1, langProvider),
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
    
    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminHomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminMissionsScreen()));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminSettingsScreen()));
        } else if (index == 4) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminProfilScreen()));
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon, 
              color: color, 
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: getSourceSerifProStyle(
                fontSize: 10.sp,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

