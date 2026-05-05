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
import 'package:provider/provider.dart';

class AdminIncidentsScreen extends StatefulWidget {
  const AdminIncidentsScreen({Key? key}) : super(key: key);

  @override
  _AdminIncidentsScreenState createState() => _AdminIncidentsScreenState();
}

class _AdminIncidentsScreenState extends State<AdminIncidentsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final Color _adminPurple = const Color(0xFF7C39D3);
  final MissionService _missionService = MissionService();

  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allIncidents = [];
  List<Map<String, dynamic>> _allFeedbacks = [];
  final Set<int> _markingHandled = {};
  AppLifecycleState? _lastLifecycleState;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _incidentScrollController = ScrollController();
  final ScrollController _feedbackScrollController = ScrollController();
  bool _showFab = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _incidentScrollController.addListener(_scrollListener);
    _feedbackScrollController.addListener(_scrollListener);
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
        : _feedbackScrollController;
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
        : _feedbackScrollController;
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
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

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

    // Récupérer les messages en parallèle pour toutes les missions
    try {
      final List<Future<void>> fetchTasks = missions.map((mission) async {
        try {
          final messages = await _missionService.getChatMessages(mission.id);
          for (final msg in messages) {
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
          debugPrint(
              'AdminIncidentsScreen: Error fetching messages for mission ${mission.id}: $e');
        }
      }).toList();

      await Future.wait(fetchTasks);
    } catch (e) {
      debugPrint(
          'AdminIncidentsScreen: Critical error during parallel fetch: $e');
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

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(filteredIncidents,
                              isIncident: true,
                              controller: _incidentScrollController),
                          _buildList(filteredFeedbacks,
                              isIncident: false,
                              controller: _feedbackScrollController),
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
          // Résumé rapide
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                _buildCounter(_allIncidents.length, 'Incidents',
                    Colors.red[200]!, Colors.red),
                SizedBox(width: 12.w),
                _buildCounter(_allFeedbacks.length, 'Retours',
                    Colors.amber[200]!, Colors.amber[800]!),
              ],
            ),
          ),
          SizedBox(height: 16.h),
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
      {required bool isIncident, required ScrollController controller}) {
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
        padding: EdgeInsets.all(16.w),
        itemCount: items.length,
        itemBuilder: (context, index) {
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
              try {
                await _missionService.markMessageAsHandled(messageId);
                setState(() {
                  msg['is_handled'] = true;
                  _markingHandled.remove(messageId);
                });
                
                // Marquer également comme lu dans le NotificationProvider pour décrémenter la cloche
                final missionId = msg['_mission_id'];
                if (missionId != null) {
                  final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
                  notifProvider.markAsReadByMissionId(missionId);
                  
                  // Et marquer localement dans MissionProvider pour le badge de la mission
                  final missionProvider = Provider.of<MissionProvider>(context, listen: false);
                  missionProvider.markMissionAsReadLocal(missionId);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isIncident
                          ? 'Incident marqué comme traité'
                          : 'Retour marqué comme lu'),
                      backgroundColor:
                          isIncident ? Colors.orange : Colors.green,
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

    // Extract rating from feedback content
    String? rating;
    if (!isIncident) {
      final ratingMatch =
          RegExp(r'\[Note: (\d+\.?\d*)/5\]').firstMatch(content);
      if (ratingMatch != null) rating = ratingMatch.group(1);
    }

    // Extract incident type
    String? incidentType;
    if (isIncident) {
      final typeMatch = RegExp(r'\[([^\]]+)\]').firstMatch(content);
      if (typeMatch != null) incidentType = typeMatch.group(1);
    }

    // Clean content
    String cleanContent = content
        .replaceAll(RegExp(r'^🚨 INCIDENT: \[[^\]]+\] '), '')
        .replaceAll(RegExp(r'^⭐ FEEDBACK: \[Note: \d+\.?\d*/5\] '), '')
        .trim();

    final Color cardBg = isIncident ? Colors.red[50]! : Colors.amber[50]!;
    final Color borderColor =
        isIncident ? Colors.red[200]! : Colors.amber[300]!;
    final Color accentColor = isIncident ? Colors.red : Colors.amber[800]!;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: type badge + heure
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isIncident
                          ? Icons.warning_amber_rounded
                          : Icons.star_rounded,
                      color: Colors.white,
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isIncident
                          ? (incidentType ?? 'Incident').toUpperCase()
                          : 'RETOUR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
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
                  style:
                      getInterStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
            ],
          ),
          SizedBox(height: 10.h),

          // Mission name
          Row(
            children: [
              Icon(Icons.apartment_outlined,
                  size: 14.sp, color: Colors.grey[600]),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  missionName,
                  style: getInterStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Sender
          Row(
            children: [
              Icon(Icons.person_outline, size: 14.sp, color: Colors.grey[600]),
              SizedBox(width: 6.w),
              Text(
                senderName,
                style: getInterStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),

          // Rating (feedback only)
          if (!isIncident && rating != null) ...[
            SizedBox(height: 10.h),
            Row(
              children: List.generate(5, (i) {
                final r = double.tryParse(rating!) ?? 0;
                return Icon(
                  i < r ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 20.sp,
                );
              }),
            ),
          ],

          // Content
          if (cleanContent.isNotEmpty) ...[
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cleanContent,
                      style: getInterStyle(
                        fontSize: 13.sp,
                        color: Colors.black87,
                        height: 1.4,
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
                          _isExpanded ? 'Voir moins' : 'Voir plus',
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

          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isHandled)
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isIncident ? 'Incident traité' : 'Retour traité',
                    style: getInterStyle(
                      fontSize: 12.sp,
                      color: Colors.green[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const SizedBox(),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor.withOpacity(0.25)),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'handle') {
                          widget.onMarkHandled();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'handle',
                          child: Text(isIncident
                              ? 'Marquer comme traité'
                              : 'Marquer comme lu'),
                        ),
                      ],
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        child: widget.isLoading
                            ? SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: accentColor))
                            : Row(
                                children: [
                                  Text(
                                    isIncident ? 'Traiter' : 'Lu',
                                    style: getInterStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: accentColor),
                                  ),
                                  Icon(Icons.arrow_drop_down,
                                      color: accentColor, size: 18.sp),
                                ],
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
    );
  }
}
