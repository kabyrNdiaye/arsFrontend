import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../services/mission_service.dart';
import '../../providers/mission_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/mission_model.dart';
import 'mission_detail_screen.dart';

class ProfessionnelIncidentsScreen extends StatefulWidget {
  const ProfessionnelIncidentsScreen({Key? key}) : super(key: key);

  @override
  _ProfessionnelIncidentsScreenState createState() => _ProfessionnelIncidentsScreenState();
}

class _ProfessionnelIncidentsScreenState extends State<ProfessionnelIncidentsScreen>
    with SingleTickerProviderStateMixin {
  final Color _iteaBlue = const Color(0xFF0059AB);
  final MissionService _missionService = MissionService();
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _myIncidents = [];
  List<Map<String, dynamic>> _myFeedbacks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    
    // Ensure missions are loaded
    if (missionProvider.missions.isEmpty) {
      await missionProvider.fetchMissions();
    }

    final missions = missionProvider.missions;
    List<Map<String, dynamic>> incidents = [];
    List<Map<String, dynamic>> feedbacks = [];

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
              '_mission_object': mission, // To navigate back
            };
            if (msg['type'] == 'incident') {
              incidents.add(enriched);
            } else if (msg['type'] == 'feedback') {
              feedbacks.add(enriched);
            }
          }
        } catch (e) {
          debugPrint('Error fetching messages for mission ${mission.id}: $e');
        }
      }).toList();

      await Future.wait(fetchTasks);
    } catch (e) {
      debugPrint('Critical error during parallel fetch: $e');
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
        _myIncidents = incidents;
        _myFeedbacks = feedbacks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _iteaBlue,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Column(
          children: [
            _buildHeader(lang),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: _iteaBlue))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(_myIncidents, isIncident: true, lang: lang),
                        _buildList(_myFeedbacks, isIncident: false, lang: lang),
                      ],
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showMissionsSelector(lang),
          backgroundColor: _iteaBlue,
          icon: const Icon(Icons.add_alert, color: Colors.white),
          label: Text(lang.translate('report_incident') ?? 'Signaler un incident', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider lang) {
    return Container(
      decoration: BoxDecoration(
        color: _iteaBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 10.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  lang.translate('incidents') ?? 'Mes Incidents',
                  style: getInterStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadData,
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: lang.translate('incidents') ?? 'Incidents'),
              Tab(text: lang.translate('feedbacks') ?? 'Retours'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, {required bool isIncident, required LanguageProvider lang}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isIncident ? Icons.check_circle_outline : Icons.sentiment_satisfied_alt,
              size: 64.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              isIncident ? 'Aucun incident signalé' : 'Aucun retour envoyé',
              style: getInterStyle(fontSize: 16.sp, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildCard(items[index], isIncident: isIncident),
    );
  }

  Widget _buildCard(Map<String, dynamic> msg, {required bool isIncident}) {
    final String content = msg['content'] ?? '';
    final String missionName = msg['_mission_name'] ?? 'Mission';
    final DateTime? createdAt = msg['created_at'] != null ? DateTime.tryParse(msg['created_at']) : null;
    final MissionModel mission = msg['_mission_object'];

    // Clean content (remove prefix if matches)
    String cleanContent = content
        .replaceAll(RegExp(r'^🚨 INCIDENT: \[[^\]]+\] '), '')
        .replaceAll(RegExp(r'^⭐ FEEDBACK: \[Note: \d+\.?\d*/5\] '), '')
        .trim();

    final Color accentColor = isIncident ? Colors.red : Colors.amber[800]!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MissionDetailScreen(mission: mission)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  missionName,
                  style: getInterStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _iteaBlue),
                ),
                if (createdAt != null)
                  Text(
                    DateFormat('dd/MM HH:mm').format(createdAt),
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(isIncident ? Icons.warning_amber_rounded : Icons.star_rounded, 
                  color: accentColor, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    cleanContent,
                    style: getInterStyle(fontSize: 13.sp, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMissionsSelector(LanguageProvider lang) {
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    final activeMissions = missionProvider.missions.where((m) => m.status != 'terminé').toList();

    if (activeMissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune mission active pour signaler un incident'))
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Sélectionnez une mission", 
              style: getInterStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 20.h),
            ...activeMissions.map((m) => ListTile(
              leading: const Icon(Icons.apartment, color: Color(0xFF0059AB)),
              title: Text(m.structureName ?? 'Mission', style: getInterStyle(fontSize: 14.sp)),
              subtitle: Text(m.horaireMission != null ? DateFormat('dd/MM/yyyy').format(m.horaireMission!) : ''),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MissionDetailScreen(mission: m)),
                );
              },
            )).toList(),
          ],
        ),
      ),
    );
  }
}
