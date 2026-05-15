import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../utils/font_helper.dart';
import '../../services/mission_service.dart';
import '../../providers/mission_provider.dart';
import '../../models/mission_model.dart';
import '../../providers/notification_provider.dart';
import '../../services/incident_service.dart';
import '../../services/feedback_service.dart';
import '../../services/retour_service.dart';
import 'package:provider/provider.dart';

class AdminIncidentsScreen extends StatefulWidget {
  final int initialTabIndex;

  const AdminIncidentsScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  _AdminIncidentsScreenState createState() => _AdminIncidentsScreenState();
}

class _AdminIncidentsScreenState extends State<AdminIncidentsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final Color _adminPurple = const Color(0xFF7C39D3);
  final MissionService _missionService = MissionService();
  final IncidentService _incidentService = IncidentService();
  final FeedbackService _feedbackService = FeedbackService();
  final RetourService _retourService = RetourService();

  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allIncidents = [];
  List<Map<String, dynamic>> _allFeedbacks = [];
  List<Map<String, dynamic>> _allCancellations = [];
  final Set<int> _markingHandled = {};
  AppLifecycleState? _lastLifecycleState;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _incidentScrollController = ScrollController();
  final ScrollController _feedbackScrollController = ScrollController();
  final ScrollController _cancellationScrollController = ScrollController();
  bool _showFab = false;
  String _searchQuery = '';

  // Pagination — nombre d'items visibles par onglet
  int _incidentDisplayCount = 3;
  int _feedbackDisplayCount = 3;
  int _cancellationDisplayCount = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(_handleTabSelection);
    _incidentScrollController.addListener(_scrollListener);
    _feedbackScrollController.addListener(_scrollListener);
    _cancellationScrollController.addListener(_scrollListener);
    _loadData();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _checkFabVisibility();
    }
  }

  void _scrollListener() {
    _checkFabVisibility();
  }

  void _checkFabVisibility() {
    ScrollController activeController = _tabController.index == 0
        ? _incidentScrollController
        : _tabController.index == 1
            ? _feedbackScrollController
            : _cancellationScrollController;
    if (activeController.hasClients) {
      if (activeController.offset > 50 && !_showFab) {
        setState(() => _showFab = true);
      } else if (activeController.offset <= 50 && _showFab) {
        setState(() => _showFab = false);
      }
    }
  }

  void _scrollToTop() {
    ScrollController activeController = _tabController.index == 0
        ? _incidentScrollController
        : _tabController.index == 1
            ? _feedbackScrollController
            : _cancellationScrollController;
    if (activeController.hasClients) {
      activeController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _lastLifecycleState != AppLifecycleState.resumed) {
      _loadData();
    }
    _lastLifecycleState = state;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _incidentScrollController.dispose();
    _feedbackScrollController.dispose();
    _cancellationScrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Charger les annulations immédiatement (sans attendre le reste)
    try {
      final cancellations = await _missionService.getCancellations();
      if (mounted) setState(() => _allCancellations = cancellations);
    } catch (e) {
      debugPrint('AdminIncidentsScreen: Cancellations error: $e');
    }

    final missionProvider =
        Provider.of<MissionProvider>(context, listen: false);

    // S'assurer que les missions sont chargées
    if (missionProvider.missions.isEmpty) {
      debugPrint('AdminIncidentsScreen: Missions list empty, fetching...');
      await missionProvider.fetchMissions();
    }

    final missions = missionProvider.missions;
    debugPrint('AdminIncidentsScreen: Processing ${missions.length} missions');

    List<Map<String, dynamic>> incidents = [];
    List<Map<String, dynamic>> feedbacks = [];

    try {
      // 1. Récupérer les données des tables dédiées (Backend tables)
      final List<Future<dynamic>> tableTasks = [
        _incidentService.getIncidents(),
        _feedbackService.getFeedbacks(),
        _retourService.getRetours(),
      ];

      final results = await Future.wait(tableTasks);
      
      // Mapper les incidents de la table
      final List<Map<String, dynamic>> tableIncidents = List<Map<String, dynamic>>.from(results[0]);
      for (var inc in tableIncidents) {
        // Nom établissement : chercher dans plusieurs chemins possibles
        final structureUser = inc['mission']?['structure']?['user'];
        final structureName = inc['mission']?['structure']?['nom_etablissement']
            ?? structureUser?['nom_etablissement']
            ?? structureUser?['name']
            ?? inc['mission']?['establishment']
            ?? 'Établissement inconnu';

        // Nom professionnel
        final proUser = inc['mission']?['professionnel']?['user'];
        final proName = proUser?['prenom'] != null
            ? '${proUser['prenom']} ${proUser['nom'] ?? ''}'.trim()
            : proUser?['name']
            ?? inc['mission']?['professionnel']?['name']
            ?? 'Professionnel inconnu';

        incidents.add({
          'id': inc['id'],
          'content': inc['description'] ?? '',
          'type': 'incident',
          'is_handled': inc['statut'] == 'Traité' || inc['statut'] == 'Résolu',
          'created_at': inc['created_at'],
          'sender_name': proName,
          '_mission_id': inc['mission_id'],
          '_mission_name': structureName,
          '_is_table_record': true,
          '_incident_type': inc['type'],
        });
      }

      // Mapper les feedbacks de la table
      final List<Map<String, dynamic>> tableFeedbacks = List<Map<String, dynamic>>.from(results[1]);
      for (var f in tableFeedbacks) {
        final structureUser = f['mission']?['structure']?['user'];
        final fbStructureName = f['mission']?['structure']?['nom_etablissement']
            ?? structureUser?['nom_etablissement']
            ?? structureUser?['name']
            ?? f['mission']?['establishment']
            ?? '';

        final fbProUser = f['mission']?['professionnel']?['user'];
        final fbProName = fbProUser?['prenom'] != null
            ? '${fbProUser['prenom']} ${fbProUser['nom'] ?? ''}'.trim()
            : fbProUser?['name']
            ?? f['user']?['name']
            ?? '';

        feedbacks.add({
          'id': f['id'],
          'content': '[Note: ${f['rating']}/5] ' + (f['comment'] ?? ''),
          'type': 'feedback',
          'is_handled': false,
          'created_at': f['created_at'],
          'sender_name': fbProName,
          '_mission_name': fbStructureName,
          '_mission_id': f['mission_id'],
          '_is_table_record': true,
        });
      }

      // Mapper les retours de mission de la table
      final List<Map<String, dynamic>> tableRetours = List<Map<String, dynamic>>.from(results[2]);
      for (var r in tableRetours) {
        final structureUser = r['mission']?['structure']?['user'];
        final structureName = r['mission']?['structure']?['nom_etablissement']
            ?? structureUser?['nom_etablissement']
            ?? structureUser?['name']
            ?? 'Établissement inconnu';

        final proUser = r['mission']?['professionnel']?['user'];
        final proName = proUser?['prenom'] != null
            ? '${proUser['prenom']} ${proUser['nom'] ?? ''}'.trim()
            : proUser?['name']
            ?? 'Professionnel inconnu';

        feedbacks.add({
          'id': r['id'],
          'content': '[Note: ${r['note']}/5] ' + (r['commentaire'] ?? ''),
          'type': 'feedback',
          'is_handled': false,
          'created_at': r['created_at'],
          'sender_name': proName,
          '_mission_id': r['mission_id'],
          '_mission_name': structureName,
          '_is_table_record': true,
        });
      }

      // 2. Récupérer les messages de chat (Ancien système ou messages en temps réel)
      final List<Future<void>> chatTasks = missions.map((mission) async {
        try {
          final messages = await _missionService.getChatMessages(mission.id);
          for (final msg in messages) {
            // Éviter les doublons si possible (mais le type de record est différent)
            final enriched = {
              ...msg,
              '_mission_id': mission.id,
              '_mission_name': mission.structureName ?? 'Structure inconnue',
              '_mission_date': mission.horaireMission,
            };
            if (msg['type'] == 'incident') {
              incidents.add(enriched);
            } else if (msg['type'] == 'feedback') {
              feedbacks.add(enriched);
            }
          }
        } catch (e) {
          debugPrint('AdminIncidentsScreen: Chat fetch error for mission ${mission.id}: $e');
        }
      }).toList();

      await Future.wait(chatTasks);
    } catch (e) {
      debugPrint('AdminIncidentsScreen: Critical error during fetch: $e');
    }

    // Sort by date (newest first)
    incidents.sort((a, b) {
      final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
      final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });
    feedbacks.sort((a, b) {
      final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
      final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    if (mounted) {
      setState(() {
        _allIncidents = incidents;
        _allFeedbacks = feedbacks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _adminPurple,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        floatingActionButton: _showFab
            ? FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: _adminPurple,
                elevation: 4,
                child: const Icon(Icons.arrow_upward,
                    color: Colors.white, size: 28),
              )
            : null,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: _adminPurple))
                  : Builder(builder: (context) {
                      final filteredIncidents = _allIncidents.where((item) {
                        final content = (item['content'] ?? '').toLowerCase();
                        final mission =
                            (item['_mission_name'] ?? '').toLowerCase();
                        final sender =
                            (item['user']?['name'] ?? item['sender_name'] ?? '')
                                .toLowerCase();
                        return content.contains(_searchQuery) ||
                            mission.contains(_searchQuery) ||
                            sender.contains(_searchQuery);
                      }).toList();

                      final filteredFeedbacks = _allFeedbacks.where((item) {
                        final content = (item['content'] ?? '').toLowerCase();
                        final mission =
                            (item['_mission_name'] ?? '').toLowerCase();
                        final sender =
                            (item['user']?['name'] ?? item['sender_name'] ?? '')
                                .toLowerCase();
                        return content.contains(_searchQuery) ||
                            mission.contains(_searchQuery) ||
                            sender.contains(_searchQuery);
                      }).toList();

                      final filteredCancellations = _allCancellations.where((item) {
                        final content = (item['content'] ?? '').toLowerCase();
                        final mission = (item['_mission_name'] ?? '').toLowerCase();
                        final sender = (item['sender_name'] ?? '').toLowerCase();
                        return content.contains(_searchQuery) ||
                            mission.contains(_searchQuery) ||
                            sender.contains(_searchQuery);
                      }).toList();

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(filteredIncidents,
                              isIncident: true,
                              controller: _incidentScrollController,
                              displayCount: _incidentDisplayCount,
                              onLoadMore: () => setState(() => _incidentDisplayCount += 3)),
                          _buildList(filteredFeedbacks,
                              isIncident: false,
                              controller: _feedbackScrollController,
                              displayCount: _feedbackDisplayCount,
                              onLoadMore: () => setState(() => _feedbackDisplayCount += 3)),
                          _buildCancellationList(filteredCancellations,
                              controller: _cancellationScrollController,
                              displayCount: _cancellationDisplayCount,
                              onLoadMore: () => setState(() => _cancellationDisplayCount += 3)),
                        ],
                      );
                    }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: _adminPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
      child: Column(
        children: [
          // Trait horizontal standard
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Incidents & Retours',
                  style: getInterStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white, size: 22.sp),
                  onPressed: _loadData,
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                style: getInterStyle(color: Colors.white, fontSize: 14.sp),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                    // Réinitialiser la pagination à chaque nouvelle recherche
                    _incidentDisplayCount = 3;
                    _feedbackDisplayCount = 3;
                    _cancellationDisplayCount = 3;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle:
                      getInterStyle(color: Colors.white60, fontSize: 13.sp),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.white70, size: 20.sp),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              color: Colors.white70, size: 18.sp),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // TabBar
          TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text('Incidents (${_allIncidents.length})',
                        style: getInterStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text('Retours (${_allFeedbacks.length})',
                        style: getInterStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cancel_outlined, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text('Annulations (${_allCancellations.length})',
                        style: getInterStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(
      int count, String label, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                      color: textColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(label,
                style: getInterStyle(
                    fontSize: 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items,
      {required bool isIncident,
      required ScrollController controller,
      required int displayCount,
      required VoidCallback onLoadMore}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isIncident
                  ? Icons.check_circle_outline
                  : Icons.sentiment_satisfied_alt,
              size: 64.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              isIncident ? 'Aucun incident signalé' : 'Aucun retour reçu',
              style: getInterStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8.h),
            Text(
              isIncident
                  ? 'Tout se passe bien !'
                  : 'Les professionnels n\'ont pas encore partagé leur avis',
              style: getInterStyle(fontSize: 13.sp, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _adminPurple,
      child: ListView.builder(
        controller: controller,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        itemCount: items.take(displayCount).length + (items.length > displayCount ? 1 : 0),
        itemBuilder: (context, index) {
          // Bouton "Voir plus"
          if (index == items.take(displayCount).length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: onLoadMore,
                  icon: Icon(Icons.expand_more, color: _adminPurple),
                  label: Text(
                    'Voir ${items.length - displayCount > 3 ? 3 : items.length - displayCount} de plus',
                    style: getInterStyle(
                        fontSize: 13.sp,
                        color: _adminPurple,
                        fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _adminPurple),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 10.h),
                  ),
                ),
              ),
            );
          }

          final msg = items[index];
          final messageId = msg['id'] is int
              ? msg['id'] as int
              : (msg['id'] is String
                  ? int.tryParse(msg['id']) ?? msg.hashCode
                  : msg.hashCode);

          return _MessageCard(
            msg: msg,
            isIncident: isIncident,
            isHandled: msg['is_handled'] == true,
            isLoading: _markingHandled.contains(messageId),
            onMarkHandled: () async {
              if (_markingHandled.contains(messageId)) return;

              setState(() => _markingHandled.add(messageId));
              final isCurrentlyHandled = msg['is_handled'] == true;

              try {
                if (msg['_is_table_record'] == true) {
                  if (msg['type'] == 'incident') {
                    final newStatut = isCurrentlyHandled ? 'En attente' : 'Traité';
                    await _incidentService.updateIncident(messageId, {'statut': newStatut});
                  }
                  // Pour les feedbacks : toggle UI uniquement
                } else {
                  if (!isCurrentlyHandled) {
                    await _missionService.markMessageAsHandled(messageId);
                  }
                }

                setState(() {
                  msg['is_handled'] = !isCurrentlyHandled;
                  _markingHandled.remove(messageId);
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isCurrentlyHandled
                            ? (isIncident ? 'Traitement annulé' : 'Marqué comme non lu')
                            : (isIncident ? 'Incident marqué comme traité' : 'Retour marqué comme lu'),
                      ),
                      backgroundColor: isCurrentlyHandled
                          ? Colors.orange
                          : (isIncident ? Colors.orange : Colors.green),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                setState(() => _markingHandled.remove(messageId));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Erreur : $e'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
  Widget _buildCancellationList(List<Map<String, dynamic>> items,
      {required ScrollController controller,
      required int displayCount,
      required VoidCallback onLoadMore}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              'Aucune annulation',
              style: getInterStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8.h),
            Text(
              'Aucune mission n\'a été annulée',
              style: getInterStyle(fontSize: 13.sp, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _adminPurple,
      child: ListView.builder(
        controller: controller,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        itemCount: items.take(displayCount).length + (items.length > displayCount ? 1 : 0),
        itemBuilder: (context, index) {
          // Bouton "Voir plus"
          if (index == items.take(displayCount).length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: onLoadMore,
                  icon: Icon(Icons.expand_more, color: _adminPurple),
                  label: Text(
                    'Voir ${items.length - displayCount > 3 ? 3 : items.length - displayCount} de plus',
                    style: getInterStyle(
                        fontSize: 13.sp,
                        color: _adminPurple,
                        fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _adminPurple),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 10.h),
                  ),
                ),
              ),
            );
          }

          final item = items[index];
          final String missionName = item['_mission_name'] ?? 'Mission';
          final String senderName = item['sender_name'] ?? 'Professionnel';
          final String motif = item['content'] ?? 'Aucun motif renseigné';
          final bool isLate = item['is_late'] == true || item['is_late'] == 1;
          final DateTime? date = item['created_at'] != null
              ? DateTime.tryParse(item['created_at'].toString())
              : null;
          final String dateStr = date != null
              ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
              : '-';

          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.orange[700],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cancel_outlined, color: Colors.white, size: 12.sp),
                              SizedBox(width: 4.w),
                              Text('ANNULATION',
                                  style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        if (isLate) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.red[700],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('TARDIVE',
                                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Text(dateStr,
                        style: getInterStyle(
                            fontSize: 11.sp, color: Colors.grey[500])),
                  ],
                ),
                SizedBox(height: 10.h),
                // Structure
                Row(
                  children: [
                    Icon(Icons.business_outlined, size: 14.sp, color: Colors.orange[700]),
                    SizedBox(width: 6.w),
                    Text('Structure : ',
                        style: getInterStyle(fontSize: 12.sp, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                    Expanded(
                      child: Text(missionName,
                          style: getInterStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                // Professionnel
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14.sp, color: Colors.orange[700]),
                    SizedBox(width: 6.w),
                    Text('Professionnel : ',
                        style: getInterStyle(fontSize: 12.sp, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                    Expanded(
                      child: Text(senderName,
                          style: getInterStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    motif,
                    style: getInterStyle(fontSize: 13.sp, color: Colors.black87),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MessageCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isIncident;
  final bool isHandled;
  final bool isLoading;
  final VoidCallback onMarkHandled;

  const _MessageCard({
    Key? key,
    required this.msg,
    required this.isIncident,
    required this.isHandled,
    this.isLoading = false,
    required this.onMarkHandled,
  }) : super(key: key);

  @override
  __MessageCardState createState() => __MessageCardState();
}

class __MessageCardState extends State<_MessageCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
    final isIncident = widget.isIncident;
    final isHandled = widget.isHandled;

    final String content = msg['content'] ?? '';
    final String missionName = msg['_mission_name'] ?? 'Mission';
    final DateTime? createdAt =
        msg['created_at'] != null ? DateTime.tryParse(msg['created_at']) : null;
    final String senderName =
        msg['user']?['name'] ?? msg['sender_name'] ?? 'Professionnel';

    // Note pour les retours
    String? rating;
    if (!isIncident) {
      final ratingMatch = RegExp(r'\[Note: (\d+\.?\d*)/5\]').firstMatch(content);
      if (ratingMatch != null) rating = ratingMatch.group(1);
    }

    // Contenu nettoyé
    String cleanContent = content
        .replaceAll(RegExp(r'^🚨 INCIDENT: \[[^\]]+\] '), '')
        .replaceAll(RegExp(r'^⭐ FEEDBACK: \[Note: \d+\.?\d*/5\] '), '')
        .trim();

    // Couleurs selon type
    final Color accentColor = isIncident
        ? const Color(0xFFE53935)
        : const Color(0xFF7C39D3);
    final Color bgColor = isIncident
        ? const Color(0xFFFFF5F5)
        : const Color(0xFFF5F0FF);
    final Color borderColor = isIncident
        ? const Color(0xFFFFCDD2)
        : const Color(0xFFD1C4E9);
    final Color badgeBg = isIncident
        ? const Color(0xFFE53935)
        : const Color(0xFF7C39D3);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Bande colorée en haut ──────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Badge type
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isIncident ? Icons.warning_amber_rounded : Icons.star_rounded,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isIncident ? 'INCIDENT' : 'RETOUR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (createdAt != null)
                  Text(
                    DateFormat('dd/MM à HH:mm').format(createdAt),
                    style: getInterStyle(fontSize: 11.sp, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),

          // ── Corps de la carte ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Établissement
                Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.business_outlined,
                          color: accentColor, size: 16.sp),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Établissement',
                            style: getInterStyle(
                                fontSize: 10.sp, color: Colors.grey[400]),
                          ),
                          Text(
                            missionName,
                            style: getInterStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),
                Divider(height: 1, color: Colors.grey[100]),
                SizedBox(height: 10.h),

                // Professionnel en charge
                Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0059AB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person_outline,
                          color: const Color(0xFF0059AB), size: 16.sp),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Professionnel en charge',
                            style: getInterStyle(
                                fontSize: 10.sp, color: Colors.grey[400]),
                          ),
                          Text(
                            senderName,
                            style: getInterStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0059AB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Note étoiles (retours uniquement)
                if (!isIncident && rating != null) ...[
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Text('Note : ',
                          style: getInterStyle(
                              fontSize: 12.sp, color: Colors.grey[500])),
                      ...List.generate(5, (i) {
                        final r = double.tryParse(rating!) ?? 0;
                        return Icon(
                          i < r ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 18.sp,
                        );
                      }),
                      SizedBox(width: 4.w),
                      Text('$rating/5',
                          style: getInterStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[800])),
                    ],
                  ),
                ],

                // Message
                if (cleanContent.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cleanContent,
                            style: getInterStyle(
                              fontSize: 13.sp,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            maxLines: _isExpanded ? null : 3,
                            overflow: _isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          if (cleanContent.length > 120)
                            Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: Text(
                                _isExpanded ? '▲ Voir moins' : '▼ Voir plus',
                                style: getInterStyle(
                                  fontSize: 11.sp,
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 12.h),

                // Footer : statut + bouton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isHandled)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.green[700], size: 13.sp),
                            SizedBox(width: 4.w),
                            Text(
                              isIncident ? 'Traité' : 'Lu',
                              style: getInterStyle(
                                fontSize: 11.sp,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(),
                    // Bouton traiter
                    Container(
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'handle' || value == 'unhandle') {
                            widget.onMarkHandled();
                          }
                        },
                        itemBuilder: (context) => [
                          if (!isHandled)
                            PopupMenuItem(
                              value: 'handle',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Colors.green, size: 18),
                                  SizedBox(width: 8),
                                  Text(isIncident
                                      ? 'Marquer comme traité'
                                      : 'Marquer comme lu'),
                                ],
                              ),
                            )
                          else
                            PopupMenuItem(
                              value: 'unhandle',
                              child: Row(
                                children: [
                                  Icon(Icons.undo, color: Colors.orange, size: 18),
                                  SizedBox(width: 8),
                                  Text(isIncident
                                      ? 'Annuler le traitement'
                                      : 'Marquer comme non lu'),
                                ],
                              ),
                            ),
                        ],
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 8.h),
                          child: widget.isLoading
                              ? SizedBox(
                                  width: 14.w,
                                  height: 14.w,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: accentColor))
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isHandled
                                          ? (isIncident ? 'Annuler' : 'Non lu')
                                          : (isIncident ? 'Traiter' : 'Marquer lu'),
                                      style: getInterStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isHandled ? Colors.orange : accentColor,
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down,
                                        color: isHandled ? Colors.orange : accentColor,
                                        size: 18.sp),
                                  ],
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
    );
  }
}
