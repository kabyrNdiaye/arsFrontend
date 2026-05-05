import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../models/mission_model.dart';
import '../../services/mission_service.dart';
import '../../providers/language_provider.dart';

class AdminMissionChecklistScreen extends StatefulWidget {
  final int missionId;
  final String title;

  const AdminMissionChecklistScreen({
    Key? key,
    required this.missionId,
    required this.title,
  }) : super(key: key);

  @override
  _AdminMissionChecklistScreenState createState() => _AdminMissionChecklistScreenState();
}

class _AdminMissionChecklistScreenState extends State<AdminMissionChecklistScreen> {
  final MissionService _missionService = MissionService();
  bool _isLoading = true;
  MissionModel? _mission;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMission();
  }

  Future<void> _fetchMission() async {
    try {
      final data = await _missionService.getMissionById(widget.missionId);
      setState(() {
        _mission = MissionModel.fromJson(data['data'] ?? data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching mission: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: getInterStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C39D3)))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48.sp, color: Colors.red[300]),
                        SizedBox(height: 16.h),
                        Text('Erreur lors du chargement: $_error', textAlign: TextAlign.center),
                        SizedBox(height: 24.h),
                        ElevatedButton(onPressed: _fetchMission, child: const Text('Réessayer')),
                      ],
                    ),
                  ),
                )
              : _buildContent(lang),
    );
  }

  Widget _buildContent(LanguageProvider lang) {
    if (_mission == null) return const Center(child: Text('Mission non trouvée'));

    final checklist = _mission!.checklistJournee ?? {};
    final isFinished = _mission!.status.toLowerCase() == 'terminé';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(isFinished),
          SizedBox(height: 24.h),
          Text(
            'Checklist de la journée',
            style: getInterStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          Text(
            'Suivi des tâches effectuées par le professionnel en temps réel.',
            style: getInterStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 24.h),
          if (checklist.isEmpty)
            _buildEmptyChecklist()
          else
            ...checklist.entries.map((entry) {
              final key = entry.key.toLowerCase() == 'ouverture' ? 'opening' : 
                          entry.key.toLowerCase() == 'frigos' ? 'fridges' :
                          entry.key.toLowerCase() == 'préparation' ? 'preparation' :
                          entry.key.toLowerCase() == 'textures' ? 'textures' :
                          entry.key.toLowerCase() == 'dressage' ? 'plating' :
                          entry.key.toLowerCase() == 'nettoyage' ? 'cleaning' :
                          entry.key.toLowerCase() == 'signature' ? 'signature' : entry.key;
              return _buildChecklistItem(lang.translate(key) ?? entry.key, entry.value);
            }),
            
          if (isFinished && _mission!.heureFin != null) ...[
            SizedBox(height: 32.h),
            _buildFinishInfo(),
          ],
          
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isFinished) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isFinished ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isFinished ? 'MISSION TERMINÉE' : 'MISSION EN COURS',
        style: getInterStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: isFinished ? Colors.green[700] : Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String label, bool isChecked) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isChecked ? Colors.green.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked ? Colors.green.withOpacity(0.2) : Colors.grey[100]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: isChecked ? Colors.green : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isChecked ? Colors.green : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: isChecked
                ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                : null,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              label,
              style: getInterStyle(
                fontSize: 14.sp,
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.w400,
                color: isChecked ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChecklist() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.checklist_rtl_rounded, size: 48.sp, color: Colors.grey[200]),
          SizedBox(height: 16.h),
          Text(
            'Aucune tâche enregistrée',
            style: getInterStyle(color: Colors.grey[400], fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, color: Colors.orange[700], size: 20.sp),
              SizedBox(width: 10.w),
              Text(
                'Conclusion de mission',
                style: getInterStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.orange[900]),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Heure de fin réelle enregistrée :',
            style: getInterStyle(fontSize: 12.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 4.h),
          Text(
            _mission!.heureFin ?? '-',
            style: getInterStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
