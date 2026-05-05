import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../services/formation_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/formation_model.dart';
import 'youtube_player_screen.dart';
import '../../providers/notification_provider.dart';
import '../../providers/mission_provider.dart';

class FormationsScreen extends StatefulWidget {
  const FormationsScreen({Key? key}) : super(key: key);

  @override
  _FormationsScreenState createState() => _FormationsScreenState();
}

class _FormationsScreenState extends State<FormationsScreen> {
  final FormationService _formationService = FormationService();
  bool _isLoading = true;
  List<FormationModel> _allFormations = [];

  @override
  void initState() {
    super.initState();
    _fetchFormations();
  }

  Future<void> _fetchFormations() async {
    try {
      final formations = await _formationService.getFormations();
      setState(() {
        _allFormations = formations;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  List<FormationModel> _getFilteredFormations(int? userId) {
    // Ne montrer que les formations assignées à cet utilisateur OU les formations générales (null)
    return _allFormations.where((f) => f.professionnelId == null || f.professionnelId == userId).toList();
  }

  List<FormationModel> _getObligatoires(List<FormationModel> filtered) {
    return filtered.where((f) => f.typeFormation.toLowerCase() == 'obligatoire').toList();
  }

  List<FormationModel> _getRecommandees(List<FormationModel> filtered) {
    return filtered.where((f) => f.typeFormation.toLowerCase() != 'obligatoire').toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final professionnelId = authProvider.user?.professionnelId;
    final filtered = _getFilteredFormations(professionnelId);
    final obligatoires = _getObligatoires(filtered);
    final recommandees = _getRecommandees(filtered);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0059AB),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0059AB)))
                : filtered.isEmpty
                  ? Center(child: Padding(padding: EdgeInsets.only(top: 100.h), child: const Text('Aucune formation disponible')))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          if (obligatoires.isNotEmpty) _buildSection('Obligatoires', obligatoires),
                          if (obligatoires.isNotEmpty && recommandees.isNotEmpty) SizedBox(height: 24.h),
                          if (recommandees.isNotEmpty) _buildSection('Recommandées', recommandees),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF0059AB)),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          children: [
            // Trait horizontal standard (Pro)
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Formations', style: getInterStyle(fontSize: 24.sp, color: Colors.white, fontWeight: FontWeight.w700)),
                  Consumer2<NotificationProvider, MissionProvider>(
                    builder: (context, notifProvider, missionProvider, child) {
                      final int totalUnread = missionProvider.totalUnreadMessagesCount + missionProvider.newMissionsCount;
                      
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
                              size: 28.sp,
                            ),
                            if (totalUnread > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16.w,
                                    minHeight: 16.w,
                                  ),
                                  child: Center(
                                    child: Text(
                                      totalUnread > 9 ? '9+' : totalUnread.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<FormationModel> formations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(title, style: getInterStyle(fontSize: 16.sp, color: Colors.black87, fontWeight: FontWeight.w700)),
        ),
        SizedBox(height: 12.h),
        ...formations.map((f) => _buildFormationCard(f)).toList(),
      ],
    );
  }

  Widget _buildFormationCard(FormationModel formation) {
    final thumbnailUrl = formation.videoUrl != null 
        ? 'https://img.youtube.com/vi/${formation.videoUrl}/0.jpg'
        : null;

    return InkWell(
      onTap: () {
        if (formation.videoUrl != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => YouTubePlayerScreen(videoId: formation.videoUrl!, title: formation.titre),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              child: Container(
                width: 110.w,
                height: 90.h,
                color: Colors.black12,
                child: thumbnailUrl != null 
                  ? Image.network(thumbnailUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.play_circle_outline))
                  : const Icon(Icons.school_outlined),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formation.titre, style: getInterStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined, size: 14.sp, color: Colors.grey[500]),
                        SizedBox(width: 4.w),
                        Text(formation.duree ?? 'N/A', style: getInterStyle(fontSize: 12.sp, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }
}
