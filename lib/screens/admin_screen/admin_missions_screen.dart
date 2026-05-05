import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import '../../services/mission_service.dart';
import '../../models/mission_model.dart';
import 'admin_home_screen.dart';
import 'admin_create_mission_screen.dart';
import 'admin_mission_detail_screen.dart';
import 'admin_edit_mission_screen.dart';
import 'admin_equipe_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_profil_screen.dart';
import 'admin_mission_chat_screen.dart';
import '../../providers/mission_provider.dart';
import '../../providers/notification_provider.dart';

class AdminMissionsScreen extends StatefulWidget {
  const AdminMissionsScreen({Key? key}) : super(key: key);

  @override
  _AdminMissionsScreenState createState() => _AdminMissionsScreenState();
}

class _AdminMissionsScreenState extends State<AdminMissionsScreen> {
  int _currentIndex = 1; // Missions est l'onglet actif
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Color _primaryPurple = Color(0xFF7C39D3);
  final Color _lightPurple = Color(0xFF9A64E1);
  
  // État des filtres
  String _selectedFilter = 'Tous';
  String _searchQuery = '';

  // Pagination (afficher un nombre limité de missions)
  int _missionDisplayCount = 4;

  // Missions depuis l'API
  // Missions depuis l'API gérées par MissionProvider
  // Les variables locales _missionModels, _isLoading et _errorMessage sont supprimées

  // Liste des missions formatées pour l'affichage
  List<Map<String, dynamic>> _formatMissions(List<MissionModel> models) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    return models.map((mission) {
      return {
        'id': mission.id,
        'establishment': mission.structureName ?? langProvider.translate('not_defined'),
        'address': mission.structureAddress ?? '',
        'professional': (mission.professionnelNom ?? '').toString().trim().isNotEmpty ? mission.professionnelNom : langProvider.translate('not_assigned'),
        'status': mission.status,
        'schedule': mission.horaireMission != null
            ? '${DateFormat('HH:mm').format(mission.horaireMission!)}${mission.heureFin != null ? ' - ${mission.heureFin}' : ''}'
            : '',
        'date': mission.horaireMission != null
            ? DateFormat('dd/MM/yyyy').format(mission.horaireMission!)
            : DateFormat('dd/MM/yyyy').format(mission.createdAt),
        'created_at_date': DateFormat('dd/MM/yyyy').format(mission.createdAt),
        'nb_residents': mission.nbResidentsJour,
        'types_repas': mission.typesRepas,
        'regimes_speciaux': mission.regimesSpeciaux,
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadMissions();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    Provider.of<MissionProvider>(context, listen: false).fetchMissions();
    Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  // Filtrer les missions selon la recherche et le filtre sélectionné
  List<Map<String, dynamic>> _getFilteredMissions(List<Map<String, dynamic>> allMissions) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    List<Map<String, dynamic>> filtered = List.from(allMissions);

    final todayKey = langProvider.translate('today');
    final weekKey = langProvider.translate('this_week');

    // Filtre par période
    if (_selectedFilter == todayKey) {
      final todayStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
      filtered = filtered.where((mission) {
        return mission['date'].toString() == todayStr ||
               mission['created_at_date'].toString() == todayStr;
      }).toList();
    } else if (_selectedFilter == weekKey) {
      final now = DateTime.now();
      // Lundi de la semaine courante
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final mondayStart = DateTime(monday.year, monday.month, monday.day);
      final sundayEnd = mondayStart.add(const Duration(days: 7));
      filtered = filtered.where((mission) {
        try {
          final parts = mission['date'].toString().split('/');
          if (parts.length != 3) return false;
          final missionDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          return missionDate.isAfter(mondayStart.subtract(const Duration(seconds: 1))) &&
              missionDate.isBefore(sundayEnd);
        } catch (_) {
          return false;
        }
      }).toList();
    } else {
      // Filtre par statut
      final filter = _selectedFilter.toLowerCase();
      if (filter.isNotEmpty &&
          filter != 'tous' &&
          filter != langProvider.translate('all_filter').toLowerCase()) {
        filtered = filtered.where((mission) {
          return (mission['status']?.toString().toLowerCase() ?? '') == filter;
        }).toList();
      }
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
    final missionProvider = Provider.of<MissionProvider>(context);
    
    // Formater et filtrer
    final allFormattedMissions = _formatMissions(missionProvider.missions);
    final filteredMissions = _getFilteredMissions(allFormattedMissions);

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
              child: RefreshIndicator(
                onRefresh: () async {
                  await missionProvider.fetchMissions();
                },
                child: missionProvider.isLoading && missionProvider.missions.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(color: _primaryPurple),
                      )
                    : missionProvider.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 48.sp, color: Colors.red[300]),
                                SizedBox(height: 12.h),
                                Text(langProvider.translate('error_loading'), style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[600])),
                                SizedBox(height: 8.h),
                                TextButton(
                                  onPressed: missionProvider.fetchMissions,
                                  child: Text(langProvider.translate('retry'), style: getSourceSerifProStyle(fontSize: 14.sp, color: _primaryPurple)),
                                ),
                              ],
                            ),
                          )
                        : filteredMissions.isEmpty
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
                              controller: _scrollController,
                              padding: EdgeInsets.all(16.w),
                              itemCount: (filteredMissions.length < _missionDisplayCount)
                                  ? filteredMissions.length
                                  : _missionDisplayCount,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: _buildMissionCard(filteredMissions[index], langProvider, missionProvider),
                                );
                              },
                            ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(langProvider),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'scroll_top',
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_upward, color: _primaryPurple),
            ),
            if (_missionDisplayCount < filteredMissions.length) ...[
              SizedBox(height: 10.h),
              FloatingActionButton(
                heroTag: 'see_more_missions',
                onPressed: () {
                  setState(() {
                    _missionDisplayCount = (_missionDisplayCount + 3).clamp(0, filteredMissions.length);
                  });
                },
                backgroundColor: _primaryPurple,
                child: Icon(Icons.add, color: Colors.white),
              ),
            ],
          ],
        ),
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
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 40.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          SizedBox(height: 24.h),
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
              Consumer2<NotificationProvider, MissionProvider>(
                builder: (context, notifProvider, missionProvider, child) {
                  final totalUnread = missionProvider.totalUnreadMessagesCount + missionProvider.newMissionsCount;
                  
                  return GestureDetector(
                    onTap: () {
                      // Marquer toutes les notifications système comme lues
                      if (notifProvider.unreadCount > 0) {
                        notifProvider.markAllAsRead();
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                        if (totalUnread > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: _primaryPurple, width: 1.5),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16.w,
                                minHeight: 16.w,
                              ),
                              child: Text(
                                totalUnread > 9 ? '9+' : totalUnread.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
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

  Widget _buildMissionCard(Map<String, dynamic> mission, LanguageProvider langProvider, MissionProvider missionProvider) {
    final String statusValue = (mission['status'] ?? '').toString();
    final String s = statusValue.toLowerCase().trim();
    final String statusLabel;
    Color statusBgColor;
    Color statusTextColor;

    if (s == 'terminé' || s == 'terminée' || s == 'finished') {
      statusLabel = langProvider.translate('finished');
      statusBgColor = const Color(0xFFF3F4F6);
      statusTextColor = const Color(0xFF6B7280);
    } else if (s == 'réfusé' || s == 'refusé' || s == 'refused' || s == 'annulé' || s == 'annulée') {
      statusLabel = langProvider.translate('refused');
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFD32F2F);
    } else if (s == 'en cours' || s == 'in_progress') {
      statusLabel = langProvider.translate('in_progress');
      statusBgColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF2E7D32);
    } else if (s == 'confirmé' || s == 'confirmée' || s == 'confirmed') {
      statusLabel = langProvider.translate('confirmed');
      statusBgColor = const Color(0xFFDCEEFB);
      statusTextColor = const Color(0xFF1565C0);
    } else if (s == 'demande envoyée') {
      statusLabel = langProvider.translate('request_sent') ?? 'Demande envoyée';
      statusBgColor = const Color(0xFFFFF3E0);
      statusTextColor = const Color(0xFFE65100);
    } else if (s == 'validé' || s == 'validée' || s == 'validated') {
      statusLabel = langProvider.translate('validated');
      statusBgColor = const Color(0xFFE0F2F1);
      statusTextColor = const Color(0xFF00695C);
    } else {
      // Par défaut ou 'en attente'
      statusLabel = s.isEmpty ? langProvider.translate('pending_status') : s;
      statusBgColor = const Color(0xFFE8EAF6);
      statusTextColor = const Color(0xFF3949AB);
    }

    final String professional = (mission['professional'] ?? langProvider.translate('not_assigned')).toString();


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
                         Icon(Icons.location_on, color: Colors.grey, size: 16.sp),
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
                  statusLabel,
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
                _buildMissionDetailItem(Icons.person_outline, langProvider.translate('professional'), mission['professional']),
                SizedBox(height: 8.h),
                _buildMissionDetailItem(Icons.access_time, langProvider.translate('schedule'), mission['schedule']),
                SizedBox(height: 8.h),
                _buildMissionDetailItem(Icons.calendar_today_outlined, langProvider.translate('date'), mission['date']),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // _buildCompactMenuBlock(missionProvider.missions.firstWhere((m) => m.id == mission['id']), langProvider),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  langProvider.translate('see'),
                  Icons.visibility_outlined,
                  Colors.black,
                  const Color(0xFFF2F3F5),
                  onPressed: () {
                    // Marquer comme vue → badge disparaît
                    missionProvider.markMissionAsViewed(mission['id'] as int);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminMissionDetailScreen(
                          mission: missionProvider.missions.firstWhere((m) => m.id == mission['id']),
                          onMissionUpdated: (updatedMission) {
                            missionProvider.fetchMissions();
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
                  langProvider.translate('edit'),
                  Icons.edit_note_rounded,
                  _primaryPurple,
                  const Color(0xFFF7F0FF),
                  onPressed: () {
                    // Marquer comme vue → badge disparaît
                    missionProvider.markMissionAsViewed(mission['id'] as int);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminEditMissionScreen(
                          mission: mission,
                          onMissionUpdated: (updatedMission) {
                            missionProvider.fetchMissions();
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
                  langProvider.translate('chat'),
                  Icons.chat_bubble_outline,
                  const Color(0xFF00796B),
                  const Color(0xFFE0F2F1),
                  showBadge: missionProvider.missions.any((m) => m.id == mission['id'] && m.unreadMessagesCount > 0),
                  onPressed: () {
                    final missionModel = missionProvider.missions.firstWhere((m) => m.id == mission['id']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminMissionChatScreen(mission: missionModel),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionButton(
                  langProvider.translate('delete_short'),
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
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: getSourceSerifProStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: getInterStyle(
                    fontSize: 13.sp,
                    color: Colors.black.withOpacity(0.9),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, Color bgColor, {required VoidCallback onPressed, bool showBadge = false}) {
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 16.sp),
              if (showBadge)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Supprimer la Mission',
              style: getSourceSerifProStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          '${langProvider.translate('confirm_delete_mission')} "${mission['establishment']}" ?',
          style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(langProvider.translate('cancel'), style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final missionService = MissionService();
                await missionService.deleteMission(mission['id'] as int);
                _loadMissions();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(langProvider.translate('mission_deleted')),
                      backgroundColor: Colors.green[600],
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression : $e'),
                      backgroundColor: Colors.red[600],
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              langProvider.translate('delete'),
              style: getSourceSerifProStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmValidate(Map<String, dynamic> mission, LanguageProvider langProvider, MissionProvider missionProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: const Color(0xFF2E7D32), size: 24.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Valider la Mission',
                style: getSourceSerifProStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir valider cette mission ? Elle sera envoyée à tous les professionnels.',
          style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(langProvider.translate('cancel'), style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final missionService = MissionService();
                await missionService.processMission(mission['id'] as int, {
                  'statut': 'confirmé',
                });
                missionProvider.fetchMissions();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8.w),
                          const Expanded(child: Text('Mission validée et envoyée aux professionnels !')),
                        ],
                      ),
                      backgroundColor: const Color(0xFF2E7D32),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la validation : $e'),
                      backgroundColor: Colors.red[600],
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Valider',
              style: getSourceSerifProStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMenuBlock(MissionModel mission, LanguageProvider langProvider) {
    final mainRepas = mission.getMainRepas();
    final bool hasMenu = mainRepas != null;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MENU',
                style: getSourceSerifProStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              if (hasMenu)
                Text(
                  langProvider.translate(mainRepas!.typeRepas.toLowerCase().trim().replaceAll(' ', '_')).toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    color: _primaryPurple.withOpacity(0.6),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          if (!hasMenu)
            Text(
              langProvider.translate('menu_not_communicated') == 'menu_not_communicated' ? 'Menu non communiqué' : langProvider.translate('menu_not_communicated'),
              style: TextStyle(
                fontSize: 13.sp, 
                color: Colors.grey[400], 
                fontStyle: FontStyle.italic,
              ),
            )
          else
            _buildMenuRowsForMeal(mainRepas!, langProvider),
        ],
      ),
    );
  }

  Widget _buildMenuRowsForMeal(RepasModel repas, LanguageProvider langProvider) {
    return Column(
      children: [
        _buildSimplifiedMenuRow(langProvider.translate('starter_label'), repas.getDisplayName('entree')),
        _buildSimplifiedMenuRow(langProvider.translate('dish_label'), repas.getDisplayName('plat')),
        _buildSimplifiedMenuRow(langProvider.translate('side_label'), repas.getDisplayName('accompagnement')),
        _buildSimplifiedMenuRow(langProvider.translate('dessert_label'), repas.getDisplayName('dessert')),
      ],
    );
  }

  Widget _buildSimplifiedMenuRow(String label, String value) {
    if (value.isEmpty || value == '--') return const SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF666666),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
