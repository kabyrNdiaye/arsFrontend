import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../utils/font_helper.dart';
import '../../providers/mission_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/mission_service.dart';
import '../../services/incident_service.dart';
import '../../services/retour_service.dart';
import '../../models/mission_model.dart';
import 'admin_incidents_screen.dart';
import 'admin_create_formation_screen.dart';
import 'admin_profil_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_missions_screen.dart';
import 'admin_equipe_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_create_mission_screen.dart';
import 'admin_mission_detail_screen.dart';
import 'admin_edit_mission_screen.dart';
import 'admin_mission_chat_screen.dart';
import 'admin_notifications_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  
  // Couleurs
  final Color _primaryPurple = Color(0xFF7C39D3);
  final Color _lightPurple = Color(0xFF9C27B0);
  final Color _statCardPurple = Color(0xFF9A64E1);
  final Color _primaryBlue = Color(0xFF3366E3);
  final Color _greenStatus = Color(0xFF4CAF50);
  final Color _redStatus = Color(0xFFF44336);
  final Color _blueStatus = Color(0xFF2196F3);
  
  // Service et données réelles
  final MissionService _missionService = MissionService();
  Map<String, dynamic> _stats = {};
  bool _isStatsLoading = true;
  Map<String, dynamic>? _lastIncident;
  Map<String, dynamic>? _lastFeedback;
  Map<String, dynamic>? _lastCancellation;
  bool _alertsLoading = false;
  AppLifecycleState? _lastLifecycleState;

  // Timers pour le rafraîchissement automatique
  Timer? _statsPollingTimer;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    // Polling toutes les 15s pour les nouveaux messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MissionProvider>(context, listen: false).startPolling();
    });
    // Polling stats toutes les 30 secondes
    _statsPollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadStats();
    });
    // Timer minuit — recharge les stats quand le jour change
    _scheduleMidnightRefresh();
  }

  /// Planifie un rechargement automatique à minuit (remise à 0 des missions du jour)
  void _scheduleMidnightRefresh() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = midnight.difference(now);
    _midnightTimer = Timer(durationUntilMidnight, () {
      if (mounted) {
        _loadStats();
        // Replanifier pour le lendemain
        _scheduleMidnightRefresh();
      }
    });
  }

  @override
  void dispose() {
    _statsPollingTimer?.cancel();
    _midnightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    Provider.of<MissionProvider>(context, listen: false).stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _lastLifecycleState != AppLifecycleState.resumed) {
      // L'app reprend du premier plan, recharger les données
      _loadStats();
      Provider.of<MissionProvider>(context, listen: false).fetchMissions();
    }
    _lastLifecycleState = state;
  }

  Future<void> _loadData() async {
    // Charger missions, stats et alertes en parallèle pour aller plus vite
    await Future.wait([
      Provider.of<MissionProvider>(context, listen: false).fetchMissions(),
      _loadLatestAlerts(),
    ]);
    // Charger les stats après les missions (pour le fallback local)
    await _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isStatsLoading = true);
    try {
      final stats = await _missionService.getAdminStats();
      if (mounted && stats.isNotEmpty) {
        setState(() {
          _stats = stats;
          _isStatsLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('AdminHomeScreen: stats API indisponible, calcul local -> $e');
    }

    // Calcul local depuis les données déjà en mémoire (MissionProvider)
    if (mounted) _computeStatsFromProvider();
  }

  void _computeStatsFromProvider() {
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    final missions = missionProvider.missions;
    final today = DateTime.now();

    // 1. Missions du jour
    final missionsToday = missions.where((m) {
      if (m.horaireMission == null) return false;
      final d = m.horaireMission!;
      return d.year == today.year &&
             d.month == today.month &&
             d.day == today.day;
    }).length;

    // 2. Professionnels disponibles = pros avec au moins une mission validée
    //    (ceux qui apparaissent dans les missions chargées)
    final proIds = missions
        .where((m) => m.professionnelId != null)
        .map((m) => m.professionnelId!)
        .toSet();
    final availablePros = proIds.length;

    // 3. Sites actifs = structures distinctes qui ont des missions
    final siteNames = missions
        .where((m) => m.structureName != null && m.structureName!.isNotEmpty)
        .map((m) => m.structureName!)
        .toSet();
    final activeSites = siteNames.length;

    if (mounted) {
      setState(() {
        _stats = {
          'missions_today': missionsToday,
          'available_professionals': availablePros,
          'active_sites': activeSites,
        };
        _isStatsLoading = false;
      });
    }
  }

  Future<void> _loadLatestAlerts() async {
    setState(() => _alertsLoading = true);
    try {
      final missions = Provider.of<MissionProvider>(context, listen: false).missions;
      
      // Essayer d'abord les nouvelles routes dédiées
      try {
        final results = await Future.wait([
          IncidentService().getIncidents(),
          RetourService().getRetours(),
        ]);

        final incidents = results[0];
        final retours = results[1];

        if (incidents.isNotEmpty || retours.isNotEmpty) {
          incidents.sort((a, b) {
            final aDate = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(2000);
            final bDate = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });
          retours.sort((a, b) {
            final aDate = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(2000);
            final bDate = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });

          if (mounted) {
            setState(() {
              // Normaliser l'incident : le backend retourne 'description', pas 'content'
              _lastIncident = incidents.isNotEmpty
                  ? {
                      ...incidents.first,
                      'content': incidents.first['description']?.toString() ?? '',
                      '_mission_name': incidents.first['mission']?['structure']?['nom_etablissement']
                          ?? incidents.first['mission']?['structure']?['user']?['name']
                          ?? incidents.first['mission']?['establishment']
                          ?? '',
                      'sender_name': () {
                        final u = incidents.first['mission']?['professionnel']?['user'];
                        if (u?['prenom'] != null) return '${u['prenom']} ${u['nom'] ?? ''}'.trim();
                        return u?['name'] ?? '';
                      }(),
                    }
                  : null;

              // Normaliser le retour : le backend retourne 'note' et 'commentaire', pas 'content'
              _lastFeedback = retours.isNotEmpty
                  ? {
                      ...retours.first,
                      'content': retours.first['commentaire']?.toString() ?? '',
                      '_mission_name': retours.first['mission']?['structure']?['nom_etablissement']
                          ?? retours.first['mission']?['structure']?['user']?['name']
                          ?? '',
                      'sender_name': () {
                        final u = retours.first['mission']?['professionnel']?['user'];
                        if (u?['prenom'] != null) return '${u['prenom']} ${u['nom'] ?? ''}'.trim();
                        return u?['name'] ?? '';
                      }(),
                    }
                  : null;
              // Dernière annulation depuis les missions
              final missionProvider = Provider.of<MissionProvider>(context, listen: false);
              final cancelled = missionProvider.missions
                  .where((m) =>
                      m.userStatus == 'refusé' ||
                      m.status?.toLowerCase() == 'annulé' ||
                      m.status?.toLowerCase() == 'annulée')
                  .toList()
                ..sort((a, b) => (b.horaireMission ?? DateTime(2000))
                    .compareTo(a.horaireMission ?? DateTime(2000)));
              _lastCancellation = cancelled.isNotEmpty
                  ? {
                      '_mission_name': cancelled.first.structureName ?? 'Mission',
                      'sender_name': cancelled.first.professionnelNom ?? 'Professionnel',
                      'content': cancelled.first.commentaires ?? cancelled.first.adminComments ?? '',
                      'created_at': cancelled.first.horaireMission?.toIso8601String(),
                    }
                  : null;
              _alertsLoading = false;
            });
          }
          return;
        }
      } catch (_) {
        // Fallback : charger depuis les messages de chat
      }

      // Fallback : ancienne méthode via messages de chat
      final List<Map<String, dynamic>> allMessages = [];
      await Future.wait(missions.map((mission) async {
        try {
          final messages = await _missionService.getChatMessages(mission.id);
          for (final msg in messages) {
            allMessages.add({
              ...msg,
              '_mission_name': mission.structureName ?? 'Mission inconnue',
              '_mission_id': mission.id,
            });
          }
        } catch (_) {}
      }));

      final incidentMessages = allMessages.where((msg) => msg['type'] == 'incident').toList();
      final feedbackMessages = allMessages.where((msg) => msg['type'] == 'feedback').toList();

      incidentMessages.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(2000);
        final bDate = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
      feedbackMessages.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(2000);
        final bDate = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      if (mounted) {
        setState(() {
          _lastIncident = incidentMessages.isNotEmpty ? incidentMessages.first : null;
          _lastFeedback = feedbackMessages.isNotEmpty ? feedbackMessages.first : null;
          _alertsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('AdminHomeScreen: erreur chargement des alertes -> $e');
      if (mounted) setState(() => _alertsLoading = false);
    }
  }

  // Suppression de _loadMissions car géré par le provider

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    final missionProvider = Provider.of<MissionProvider>(context);
    
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
            _buildHeader(langProvider, missionProvider),
            // Contenu scrollable
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    missionProvider.fetchMissions(),
                    Provider.of<NotificationProvider>(context, listen: false).fetchNotifications(),
                    _loadStats(),
                    _loadLatestAlerts(),
                  ]);
                },
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
          ),
          // Navigation en bas
            _buildBottomNav(langProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider, MissionProvider missionProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.user?.fullName ?? 'Admin';

    return Container(
      decoration: BoxDecoration(
        color: _primaryPurple,
        borderRadius: BorderRadius.only(
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
          // Profil et notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profil
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminProfilScreen()),
                      );
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: authProvider.user?.photoProfil != null
                              ? Image.network(
                                  authProvider.user!.photoProfil!,
                                  width: 50.w,
                                  height: 50.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.person_outline,
                                    color: Colors.grey[600],
                                    size: 28.sp,
                                  ),
                                )
                              : Icon(
                                  Icons.person_outline,
                                  color: Colors.grey[600],
                                  size: 28.sp,
                                ),
                        ),
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
                        userName,
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
              Row(
                children: [
                  // Notifications
                  Consumer2<NotificationProvider, MissionProvider>(
                    builder: (context, notifProvider, missionProvider, child) {
                      // Badge cloche = messages non lus + nouvelles missions non vues + nouvelles notifications API
                      final totalUnread = missionProvider.totalUnreadMessagesCount +
                          missionProvider.newMissionsCount +
                          notifProvider.unreadCount;
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminNotificationsScreen()),
                          );
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
                  SizedBox(width: 16.w),
                  // Chat
                  Consumer<MissionProvider>(
                    builder: (context, missionProvider, child) {
                      final chatUnread = missionProvider.totalUnreadMessagesCount;
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminChatListScreen()),
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 26.sp,
                            ),
                            if (chatUnread > 0)
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
                                    chatUnread > 9 ? '9+' : chatUnread.toString(),
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
            ],
          ),
          SizedBox(height: 24.h),
          // Cartes de statistiques
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildStatCard(_stats['missions_today']?.toString() ?? '0', langProvider.translate('mission_today'))),
              SizedBox(width: 8.w),
              Expanded(child: _buildStatCard(_stats['available_professionals']?.toString() ?? '0', langProvider.translate('available_professionals'))),
              SizedBox(width: 8.w),
              Expanded(child: _buildStatCard(_stats['active_sites']?.toString() ?? '0', langProvider.translate('active_sites'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
  return Container(
    height: 94.w,
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
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
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminCreateMissionScreen(
                    onMissionCreated: (newMission) {},
                  ),
                ),
              );
              await Future.wait([
                _loadStats(),
                Provider.of<MissionProvider>(context, listen: false).fetchMissions(),
                _loadLatestAlerts(),
              ]);
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
                Flexible(
                   child: Text(
                     langProvider.translate('create_mission'),
                     style: getSourceSerifProStyle(
                       fontSize: 11.sp,
                       fontWeight: FontWeight.w600,
                       color: Colors.white,
                     ),
                     textAlign: TextAlign.center,
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminCreateFormationScreen(),
                ),
              );
              if (result == true) {
                // Si une formation a été créée, on peut rafraîchir les stats
                _loadStats();
              }
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
                Flexible(
                  child: Text(
                    langProvider.translate('create_training'),
                    style: getSourceSerifProStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
    final missionProvider = Provider.of<MissionProvider>(context);
    final missions = missionProvider.missions;

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
                _showAllMissions(langProvider, missionProvider);
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
        if (missionProvider.isLoading && missions.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: CircularProgressIndicator(color: _primaryPurple),
            ),
          )
        else if (missionProvider.error != null)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 32.sp),
                  SizedBox(height: 8.h),
                  Text(
                    langProvider.translate('error_loading'),
                    style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.red),
                  ),
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: missionProvider.fetchMissions,
                    child: Text(langProvider.translate('retry')),
                  ),
                ],
              ),
            ),
          )
        else if (missions.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: Text(
                langProvider.translate('no_mission_yet'),
                style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...missions.take(3).map((mission) {
            final professionnelName = (mission.professionnelNom ?? '').trim();
            final missionMap = {
              'id': mission.id,
              'establishment': mission.structureName ?? langProvider.translate('not_defined'),
              'professional': professionnelName.isNotEmpty ? professionnelName : langProvider.translate('not_assigned'),
              'status': mission.status,
              'schedule': mission.horaireMission != null
                  ? '${DateFormat('HH:mm').format(mission.horaireMission!)}${mission.heureFin != null ? ' - ${mission.heureFin}' : ''}'
                  : '',
              'date': mission.horaireMission != null
                  ? DateFormat('dd/MM/yyyy').format(mission.horaireMission!)
                  : DateFormat('dd/MM/yyyy').format(mission.createdAt),
            };
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildMissionCard(
                missionMap['establishment'] as String,
                missionMap['professional'] as String,
                missionMap['status'] as String,
                missionMap,
                langProvider,
                missionModel: mission,
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildMissionCard(String title, String professional, String status, Map<String, dynamic>? missionData, LanguageProvider langProvider, {MissionModel? missionModel}) {
    final mission = missionData ?? {
      'establishment': title,
      'professional': professional,
      'status': status,
    };
    final String missionStatus = missionModel?.status ?? status;
    final bool isTerminee = missionStatus == 'terminé';
    final bool isAssigned = professional.trim().isNotEmpty && 
                           professional != 'Thomas Martin' &&
                           professional != 'Non assigné';

    final Color statusBgColor;
    final Color statusTextColor;
    final String statusLabel;

    if (isTerminee) {
      statusBgColor = const Color(0xFFF3F4F6); // Gris clair
      statusTextColor = const Color(0xFF6B7280); // Gris foncé
      statusLabel = langProvider.translate('finished');
    } else if (isAssigned) {
      statusBgColor = const Color(0xFFE8F5E9); // Vert clair
      statusTextColor = const Color(0xFF4CAF50); // Vert
      statusLabel = langProvider.translate('in_progress');
    } else {
      statusBgColor = const Color(0xFFE3F2FD); // Bleu clair
      statusTextColor = const Color(0xFF0059AB); // Bleu
      statusLabel = langProvider.translate('planned');
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAssigned ? Icons.access_time : Icons.calendar_today,
                      size: 11.sp,
                      color: statusTextColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      statusLabel,
                      style: getSourceSerifProStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: statusTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: _primaryPurple,
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  mission['professional'] ?? langProvider.translate('not_assigned'),
                  style: getSourceSerifProStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // _buildCompactMenuBlock(missionModel ?? MissionModel.fromJson(missionData ?? {}), langProvider),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    // Marquer la mission comme vue → badge disparaît
                    Provider.of<MissionProvider>(context, listen: false)
                        .markMissionAsViewed(missionModel?.id ?? 0);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminMissionDetailScreen(
                          mission: missionModel ?? MissionModel.fromJson(missionData ?? {}),
                          onMissionUpdated: (updatedMission) {
                            Provider.of<MissionProvider>(context, listen: false).fetchMissions();
                          },
                        ),
                      ),
                    );
                    _loadStats();
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
                  onPressed: () async {
                    // Marquer la mission comme vue → badge disparaît
                    Provider.of<MissionProvider>(context, listen: false)
                        .markMissionAsViewed(mission['id'] as int? ?? 0);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminEditMissionScreen(
                          mission: mission,
                          onMissionUpdated: (updatedMission) {
                            Provider.of<MissionProvider>(context, listen: false).fetchMissions();
                          },
                        ),
                      ),
                    );
                    _loadStats();
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
              SizedBox(width: 8.w),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        if (missionModel != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminMissionChatScreen(mission: missionModel),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFE0F2F1),
                        foregroundColor: const Color(0xFF00796B),
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
                            Icons.chat_bubble_outline,
                            size: 16.sp,
                            color: const Color(0xFF00796B),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            langProvider.translate('chat'),
                            style: getSourceSerifProStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00796B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((missionModel?.unreadMessagesCount ?? 0) > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
                          child: Center(
                            child: Text(
                              (missionModel!.unreadMessagesCount) > 99
                                  ? '99+'
                                  : missionModel.unreadMessagesCount.toString(),
                              style: TextStyle(
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllMissions(LanguageProvider langProvider, MissionProvider missionProvider) {
    if (missionProvider.missions.isEmpty) {
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
                  itemCount: missionProvider.missions.length,
                  itemBuilder: (context, index) {
                    final mission = missionProvider.missions[index];
                    final professionnelName = (mission.professionnelNom ?? '').trim();
                    final missionMap = {
                      'id': mission.id,
                      'establishment': mission.structureName ?? 'Structure inconnue',
                      'professional': professionnelName.isNotEmpty ? professionnelName : 'Non assigné',
                      'status': mission.status,
                      'schedule': mission.horaireMission != null
                          ? '${DateFormat('HH:mm').format(mission.horaireMission!)}${mission.heureFin != null ? ' - ${mission.heureFin}' : ''}'
                          : '',
                      'date': mission.horaireMission != null
                          ? DateFormat('dd/MM/yyyy').format(mission.horaireMission!)
                          : DateFormat('dd/MM/yyyy').format(mission.createdAt),
                      'nb_residents': mission.nbResidentsJour,
                      'types_repas': mission.typesRepas,
                      'regimes_speciaux': mission.regimesSpeciaux,
                    };
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildMissionCard(
                        missionMap['establishment'] as String,
                        missionMap['professional'] as String,
                        missionMap['status'] as String,
                        missionMap,
                        langProvider,
                        missionModel: mission,
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
    // Afficher un skeleton pendant le chargement
    if (_alertsLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                langProvider.translate('recent_alerts'),
                style: getSourceSerifProStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Skeleton card incident
          _buildSkeletonCard(),
          SizedBox(height: 12.h),
          // Skeleton card feedback
          _buildSkeletonCard(),
          SizedBox(height: 12.h),
          // Skeleton card annulation
          _buildSkeletonCard(),
        ],
      );
    }

    final incidentText = _getAlertPreview(_lastIncident, true);
    final feedbackText = _getAlertPreview(_lastFeedback, false);
    final cancellationText = _lastCancellation != null
        ? (_lastCancellation!['_mission_name']?.toString() ?? 'Mission annulée')
        : 'Aucune annulation récente';
    final incidentMeta = _getAlertMeta(_lastIncident);
    final feedbackMeta = _getAlertMeta(_lastFeedback);
    final cancellationMeta = _lastCancellation != null
        ? '${_lastCancellation!['sender_name'] ?? ''} • ${_getAlertMeta(_lastCancellation)}'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              langProvider.translate('recent_alerts'),
              style: getSourceSerifProStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminIncidentsScreen(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'Voir tout',
                      style: getSourceSerifProStyle(
                        fontSize: 13.sp,
                        color: _primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right, size: 16.sp, color: _primaryPurple),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminIncidentsScreen(),
              ),
            );
          },
          child: _buildAlertCard(
            Icons.warning_amber_rounded,
            Color(0xFFFFEBEE),
            Color(0xFFEF5350),
            incidentText,
            incidentMeta.isNotEmpty ? incidentMeta : 'Voir tous les incidents',
            showArrow: true,
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminIncidentsScreen(),
              ),
            );
          },
          child: _buildAlertCard(
            Icons.star_rounded,
            Color(0xFFFFF8E1),
            Color(0xFFFFB300),
            feedbackText,
            feedbackMeta.isNotEmpty ? feedbackMeta : 'Voir tous les avis',
            showArrow: true,
          ),
        ),
        SizedBox(height: 12.h),
        // Carte Annulations — toujours visible
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminIncidentsScreen(initialTabIndex: 2),
              ),
            );
          },
          child: _buildAlertCard(
            Icons.cancel_outlined,
            const Color(0xFFFFF3E0),
            Colors.orange,
            _lastCancellation != null
                ? cancellationText
                : 'Aucune annulation récente',
            _lastCancellation != null && cancellationMeta.isNotEmpty
                ? cancellationMeta
                : 'Voir toutes les annulations',
            showArrow: true,
          ),
        ),
      ],
    );
  }

  String _getAlertPreview(Map<String, dynamic>? msg, bool isIncident) {
    if (msg == null) {
      return isIncident ? 'Aucun incident récent' : 'Aucun retour récent';
    }

    final content = msg['content']?.toString() ?? '';

    // Nettoyer tous les préfixes possibles
    String cleanContent = content
        .replaceAll(RegExp(r'^🚨 INCIDENT:\s*\[[^\]]+\]\s*'), '')
        .replaceAll(RegExp(r'^⭐ FEEDBACK:\s*\[Note:\s*\d+\.?\d*/5\]\s*'), '')
        .replaceAll(RegExp(r'^\[Note:\s*\d+\.?\d*/5\]\s*'), '')
        .replaceAll(RegExp(r'^\[Note:\s*\d+\]\s*'), '')
        .trim();

    if (cleanContent.isEmpty) {
      // Essayer de récupérer depuis d'autres champs
      final description = msg['description']?.toString() ?? '';
      final commentaire = msg['commentaire']?.toString() ?? '';
      cleanContent = description.isNotEmpty ? description : commentaire;
    }

    if (cleanContent.isEmpty) {
      return isIncident ? 'Aucun incident récent' : 'Aucun retour récent';
    }

    return cleanContent.length > 80
        ? '${cleanContent.substring(0, 80)}...'
        : cleanContent;
  }

  String _getAlertMeta(Map<String, dynamic>? msg) {
    if (msg == null) return '';
    final missionName = msg['_mission_name']?.toString() ?? '';
    final senderName = msg['sender_name']?.toString() ?? '';
    final createdAt = msg['created_at'] != null
        ? DateTime.tryParse(msg['created_at'].toString())
        : null;
    final date = createdAt != null
        ? DateFormat('dd/MM HH:mm').format(createdAt)
        : '';

    final parts = [
      if (missionName.isNotEmpty) missionName,
      if (senderName.isNotEmpty) senderName,
      if (date.isNotEmpty) date,
    ];
    return parts.join(' • ');
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 10.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(IconData icon, Color iconBg, Color iconColor, String text, String time, {bool showArrow = false}) {
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
          if (showArrow)
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildMissionDetailItem(IconData icon, String label, String value) {
    final bool isDate = label.toLowerCase().contains('date');
    final bool isProfessional = label.toLowerCase().contains('professionnel');
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
        if (isProfessional)
          Expanded(
            child: Text(
              value,
              style: getInterStyle(
                fontSize: 13.sp,
                color: Colors.black.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(
            value,
            style: isDate
            ? getInterStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.8),
                height: 1.0,
              )
            : getSourceSerifProStyle(
                fontSize: 13.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
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
                  langProvider.translate(mainRepas.typeRepas.toLowerCase().trim().replaceAll(' ', '_')).toUpperCase(),
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
            _buildMenuRowsForMeal(mainRepas, langProvider),
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

