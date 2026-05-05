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
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../providers/mission_provider.dart';
import '../../providers/notification_provider.dart';

class AdminEquipeScreen extends StatefulWidget {
  const AdminEquipeScreen({Key? key}) : super(key: key);

  @override
  _AdminEquipeScreenState createState() => _AdminEquipeScreenState();
}

class _AdminEquipeScreenState extends State<AdminEquipeScreen> with WidgetsBindingObserver {
  int _currentIndex = 2; // Équipe est l'onglet actif
  final TextEditingController _searchController = TextEditingController();
  final Color _primaryPurple = Color(0xFF7C39D3);
  final Color _lightPurple = Color(0xFF9058D4);
  String _searchQuery = '';
  final AuthService _authService = AuthService();
  List<User> _professionals = [];
  bool _isLoading = true;
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
    _loadProfessionals();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _lastLifecycleState != AppLifecycleState.resumed) {
      _loadProfessionals();
    }
    _lastLifecycleState = state;
  }

  Future<void> _loadProfessionals() async {
    setState(() => _isLoading = true);
    final professionals = await _authService.getProfessionals();
    setState(() {
      _professionals = professionals;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
  List<User> get _filteredProfessionals {
    if (_searchQuery.isEmpty) {
      return _professionals;
    }
    final query = _searchQuery.toLowerCase();
    return _professionals.where((professional) {
      return professional.fullName.toLowerCase().contains(query) ||
          professional.displayFunction.toLowerCase().contains(query);
    }).toList();
  }

  bool _isMissionConfirmed(Map<String, dynamic>? mission) {
    if (mission == null) return false;
    final status = mission['user_status']?.toString().toLowerCase() ??
        mission['status']?.toString().toLowerCase() ??
        mission['statut']?.toString().toLowerCase();
    return status == 'confirmé' || status == 'confirmed' || status == 'en cours';
  }

  // Compter les professionnels disponibles
  int get _availableCount {
    return _professionals.where((p) => !_isMissionConfirmed(p.currentMission)).length;
  }

  // Compter les professionnels en mission
  int get _onMissionCount {
    return _professionals.where((p) => _isMissionConfirmed(p.currentMission)).length;
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
                    child: _buildStatCard('$_availableCount',
                        langProvider.translate('available'), _primaryPurple),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                        '$_onMissionCount',
                        langProvider.translate('in_progress'),
                        Color(0xFF4CAF50)),
                  ),
                ],
              ),
            ),
            // Liste des professionnels
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: _primaryPurple))
                  : _filteredProfessionals.isEmpty
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
                                  langProvider
                                      .translate('no_professional_found'),
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
                              child: _buildProfessionalCard(
                                  _filteredProfessionals[index], langProvider),
                            );
                          },
                        ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(langProvider),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: _primaryPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
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
                    Consumer2<NotificationProvider, MissionProvider>(
                      builder: (context, notifProvider, missionProvider, child) {
                        final totalUnread = missionProvider.totalUnreadMessagesCount + missionProvider.newMissionsCount;
                        
                        return GestureDetector(
                          onTap: () {
                            // Navigation désactivée - Indicateur uniquement
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 26.sp,
                              ),
                              if (totalUnread > 0)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF5252),
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 16.w,
                                      minHeight: 16.w,
                                    ),
                                    child: Center(
                                      child: Text(
                                        totalUnread > 9 ? '9+' : totalUnread.toString(),
                                        style: getSourceSerifProStyle(
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
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
                      hintText:
                          langProvider.translate('search_professional_hint'),
                      hintStyle: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.white.withOpacity(0.9), size: 22.sp),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
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
        ],
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

  Widget _buildProfessionalCard(
      User professional, LanguageProvider langProvider) {
    final currentMission = professional.currentMission;
    final isOnMission = _isMissionConfirmed(currentMission);
    final status = isOnMission
        ? (langProvider.currentLanguage == 'fr'
            ? 'En mission'
            : langProvider.translate('in_progress'))
        : langProvider.translate('available');

    return InkWell(
      onTap: () {},
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
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFEDE7F6),
                    shape: BoxShape.circle,
                  ),
                  child: professional.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            professional.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person_outline,
                              color: _primaryPurple,
                              size: 26.sp,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person_outline,
                          color: _primaryPurple,
                          size: 26.sp,
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        professional.fullName,
                        style: getSourceSerifProStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        professional.displayFunction,
                        style: getSourceSerifProStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isOnMission
                              ? Color(0xFFE8F5E9)
                              : Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: getSourceSerifProStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: isOnMission
                                ? Color(0xFF4CAF50)
                                : Color(0xFF2196F3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isOnMission && currentMission != null) ...[
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      '${langProvider.translate('mission')} : ',
                      style: getSourceSerifProStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        currentMission['nom_etablissement'] ??
                            currentMission['structure_name'] ??
                            currentMission['structureName'] ??
                            '',
                        style: getSourceSerifProStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label,
      int index, LanguageProvider langProvider) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? _primaryPurple : Colors.grey[400];

    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => AdminMissionsScreen()));
        } else if (index == 3) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const AdminSettingsScreen()));
        } else if (index == 4) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const AdminProfilScreen()));
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
