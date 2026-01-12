import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'admin_home_screen.dart';
import 'admin_create_mission_screen.dart';
import 'admin_mission_detail_screen.dart';
import 'admin_edit_mission_screen.dart';
import 'admin_equipe_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_profil_screen.dart';

class AdminMissionsScreen extends StatefulWidget {
  const AdminMissionsScreen({Key? key}) : super(key: key);

  @override
  _AdminMissionsScreenState createState() => _AdminMissionsScreenState();
}

class _AdminMissionsScreenState extends State<AdminMissionsScreen> {
  int _currentIndex = 1; // Missions est l'onglet actif
  final TextEditingController _searchController = TextEditingController();
  final Color _primaryPurple = Color(0xFF7C39D3);
  final Color _lightPurple = Color(0xFF9A64E1);
  
  // État des filtres
  String _selectedFilter = 'Tous'; // 'Tous', 'Aujourd\'hui', 'Cette semaine', 'En cours', 'Confirmée', 'Réfusé'
  String _searchQuery = '';

  // Liste complète des missions (mutable)
  List<Map<String, dynamic>> _allMissions = [
    {
      'establishment': 'EHPAD Les Jardins',
      'address': '12 Rue de la Santé, Paris',
      'status': 'En cours',
      'professional': 'Jean Dupont',
      'schedule': '7h30 - 16h00',
      'date': '17 Nov 2025',
    },
    {
      'establishment': 'EHPAD Les Jardins',
      'address': '12 Rue de la Santé, Paris',
      'status': 'En cours',
      'professional': 'Marie Leroy',
      'schedule': '8h00 - 17h00',
      'date': '18 Nov 2025',
    },
    {
      'establishment': 'Résidence Soleil',
      'address': '45 Avenue des Fleurs, Lyon',
      'status': 'Confirmée',
      'professional': 'Pierre Bernard',
      'schedule': '9h00 - 18h00',
      'date': '19 Nov 2025',
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

  // Filtrer les missions selon la recherche et le filtre sélectionné
  List<Map<String, dynamic>> get _filteredMissions {
    List<Map<String, dynamic>> filtered = List.from(_allMissions);

    // Filtre par statut (si sélectionné dans le dialog)
    if (_selectedFilter == 'En cours' || 
        _selectedFilter == 'Confirmée' || 
        _selectedFilter == 'Réfusé') {
      filtered = filtered.where((mission) {
        return mission['status'] == _selectedFilter;
      }).toList();
    }

    // Filtre par période (si pas un filtre de statut)
    if (_selectedFilter == 'Aujourd\'hui' || _selectedFilter == 'Today' || _selectedFilter == 'Hoy') {
      final today = DateTime.now();
      filtered = filtered.where((mission) {
        // Comparer avec la date d'aujourd'hui (simplifié pour l'exemple)
        return mission['date'].toString().contains('${today.day}');
      }).toList();
    } else if (_selectedFilter == 'Cette semaine' || _selectedFilter == 'This week' || _selectedFilter == 'Esta semana') {
      final now = DateTime.now();
      // Filtrer les missions de cette semaine (simplifié)
      filtered = filtered.where((mission) {
        // Pour l'exemple, on garde toutes les missions
        // À adapter selon vos besoins réels
        return true;
      }).toList();
    }

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((mission) {
        return mission['establishment'].toString().toLowerCase().contains(query) ||
               mission['address'].toString().toLowerCase().contains(query) ||
               mission['professional'].toString().toLowerCase().contains(query) ||
               mission['status'].toString().toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
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
        backgroundColor: const Color(0xFFFAFAFA),
        body: Column(
          children: [
            // Header violet
            _buildHeader(langProvider),
            // Liste des missions
            Expanded(
              child: _filteredMissions.isEmpty
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
                              langProvider.translate('search_no_results'),
                              style: getSourceSerifProStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              langProvider.translate('search_no_results_desc'),
                              style: getSourceSerifProStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _filteredMissions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildMissionCard(_filteredMissions[index], langProvider),
                        );
                      },
                    ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(langProvider),
        floatingActionButton: FloatingActionButton(
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
          backgroundColor: _primaryPurple,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: _primaryPurple,
      ),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
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
          SizedBox(height: 12.h),
          // Titre et notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                langProvider.translate('mission_management'),
                style: getSourceSerifProStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '2',
                          style: getSourceSerifProStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: langProvider.translate('search_mission_hint'),
                hintStyle: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              style: getSourceSerifProStyle(
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Boutons de filtre
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterButton(langProvider.translate('filters'), Icons.filter_alt_outlined, 'Filtres', langProvider),
                SizedBox(width: 8.w),
                _buildFilterButton(langProvider.translate('today'), null, langProvider.translate('today'), langProvider),
                SizedBox(width: 8.w),
                _buildFilterButton(langProvider.translate('this_week'), null, langProvider.translate('this_week'), langProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, IconData? icon, String filterValue, LanguageProvider langProvider) {
    final isSelected = _selectedFilter == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (filterValue == 'Filtres' || filterValue == 'Filters' || filterValue == 'Filtros') {
            _showFilterDialog(langProvider);
          } else {
            _selectedFilter = filterValue;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.white.withOpacity(0.5), width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18.sp),
              SizedBox(width: 6.w),
            ],
            Text(
              text,
              style: getSourceSerifProStyle(
                fontSize: 13.sp,
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(LanguageProvider langProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                langProvider.translate('filters'),
                style: getSourceSerifProStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20.h),
              _buildFilterOption(langProvider.translate('all_filter'), langProvider.translate('all_filter')),
              _buildFilterOption(langProvider.translate('in_progress'), langProvider.translate('in_progress')),
              _buildFilterOption(langProvider.translate('confirmed'), langProvider.translate('confirmed')),
              _buildFilterOption(langProvider.translate('refused'), langProvider.translate('refused')),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? _primaryPurple.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: _primaryPurple, width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: getSourceSerifProStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: _primaryPurple, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission, LanguageProvider langProvider) {
    Color statusBgColor;
    Color statusTextColor;
    
    if (mission['status'] == 'En cours') {
      statusBgColor = const Color(0xFFE2FBE9);
      statusTextColor = const Color(0xFF009814);
    } else if (mission['status'] == 'Réfusé') {
      statusBgColor = const Color(0xFFFAE3E3);
      statusTextColor = const Color(0xFFFF0000);
    } else if (mission['status'] == 'Confirmée') {
      statusBgColor = const Color(0xFFDEEAFC);
      statusTextColor = const Color(0xFF0059AB);
    } else {
      statusBgColor = Colors.grey[200]!;
      statusTextColor = Colors.grey[700]!;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission['establishment'],
                      style: getSourceSerifProStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.grey[400], size: 16.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            mission['address'],
                            style: getSourceSerifProStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mission['status'],
                  style: getSourceSerifProStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildMissionDetailItem(Icons.person_outline, 'Professionnel', mission['professional']),
                SizedBox(height: 8.h),
                _buildMissionDetailItem(Icons.access_time, 'Horaire', mission['schedule']),
                SizedBox(height: 8.h),
                _buildMissionDetailItem(Icons.calendar_today_outlined, 'Date', mission['date']),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Voir',
                  Icons.visibility_outlined,
                  Colors.black,
                  const Color(0xFFF2F3F5),
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
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionButton(
                  'Modifier',
                  Icons.edit_note_rounded,
                  _primaryPurple,
                  const Color(0xFFF7F0FF),
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
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionButton(
                  'Suppr.',
                  Icons.delete_outline_rounded,
                  const Color(0xFFFF5252),
                  const Color(0xFFFFEFEF),
                  onPressed: () {
                    _confirmDelete(mission, langProvider);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 18.sp),
        SizedBox(width: 10.w),
        Text(
          label,
          style: getSourceSerifProStyle(
            fontSize: 13.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: getSourceSerifProStyle(
            fontSize: 13.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, Color bgColor, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16.sp),
          SizedBox(width: 2.w),
          Flexible(
            child: Text(
              text,
              style: getSourceSerifProStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> mission, LanguageProvider langProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(langProvider.translate('delete_mission')),
        content: Text('${langProvider.translate('confirm_delete_mission')} ${mission['establishment']} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(langProvider.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allMissions.removeWhere((m) => 
                  m['establishment'] == mission['establishment'] &&
                  m['professional'] == mission['professional']
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(langProvider.translate('mission_deleted'))),
              );
            },
            child: Text(langProvider.translate('delete'), style: TextStyle(color: Colors.red)),
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
              _buildNavItem(Icons.home_outlined, Icons.home, langProvider.translate('home'), 0, langProvider),
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
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminHomeScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminEquipeScreen()));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminSettingsScreen()));
        } else if (index == 4) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminProfilScreen()));
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
