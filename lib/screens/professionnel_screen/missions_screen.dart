import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../utils/header_color_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/mission_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/mission_service.dart';
import '../../models/mission_model.dart';
import 'mission_detail_screen.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({Key? key}) : super(key: key);

  @override
  _MissionsScreenState createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _fetchMissions();
  }

  Future<void> _fetchMissions() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      await Provider.of<MissionProvider>(context, listen: false).fetchMissions();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${langProvider.translate('error')}: $e')),
        );
      }
    }
  }

  Future<void> _handleAction(int missionId, String action) async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final provider = Provider.of<MissionProvider>(context, listen: false);
    bool success = false;
    
    setState(() => _isLoading = true);
    
    if (action == 'accept') {
      success = await provider.acceptMission(missionId);
    } else {
      success = await provider.rejectMission(missionId);
    }
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'accept' ? langProvider.translate('mission_confirmed') : langProvider.translate('mission_refused')),
            backgroundColor: action == 'accept' ? Colors.green : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${langProvider.translate('error')} : ${provider.error}')),
        );
      }
    }
  }

  List<MissionModel> _getFilteredMissions() {
    final allMissions = Provider.of<MissionProvider>(context).missions;
    switch (_selectedTabIndex) {
      case 0: // À venir (disponibles ou acceptées mais pas encore commencées)
        return allMissions.where((m) => 
          (m.status.toLowerCase() == 'en attente' || m.status.toLowerCase() == 'confirmé') && 
          m.userStatus != 'refusé').toList();
      case 1: // En cours
        return allMissions.where((m) => m.status.toLowerCase() == 'en cours').toList();
      case 2: // Terminées
        return allMissions.where((m) => m.status.toLowerCase() == 'terminé').toList();
      default:
        return allMissions;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);

    // Obtenir la couleur du header selon l'utilisateur connecté
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    final headerColor = HeaderColorHelper.getHeaderColor(
      userEmail: user?.email,
      userId: user?.id,
    );
    
    final statusBarIconBrightness = HeaderColorHelper.getStatusBarIconBrightness(headerColor);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: headerColor, // Couleur dynamique selon l'utilisateur
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: Column(
          children: [
            // Header bleu
            _buildHeader(langProvider),
            
            // Contenu
            Expanded(
              child: _buildMissionsList(langProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider) {
    // Obtenir la couleur du header selon l'utilisateur connecté
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    // Type 'professionnel' car nous sommes dans les écrans professionnel
    final headerColor = HeaderColorHelper.getHeaderColor(
      userType: 'professionnel',
      userEmail: user?.email,
      userId: user?.id,
    );
    
    final tabs = _getTabs(langProvider);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: headerColor, // Couleur dynamique selon l'utilisateur
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          children: [
            // Trait horizontal en haut, juste sous la barre de statut
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et notification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Titre aligné à gauche
                      Text(
                        langProvider.translate('my_missions'),
                        style: getInterStyle(
                          fontSize: 22.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      
                      // Icône notification avec badge
                      Consumer2<NotificationProvider, MissionProvider>(
                        builder: (context, notifProvider, missionProvider, child) {
                          final int totalUnread = missionProvider.totalUnreadMessagesCount + missionProvider.newMissionsCount;
                          
                          return GestureDetector(
                            onTap: null, // La cloche n'ouvre plus de page
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

                  SizedBox(height: 16.h),
                  
                  // Onglets
                  Row(
                    children: List.generate(tabs.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: _buildTab(index, tabs),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, List<String> tabs) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Text(
          tabs[index],
          style: getInterStyle(
            fontSize: 15.sp,
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMissionsList(LanguageProvider langProvider) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF0059AB)));
    }

    final missions = _getFilteredMissions();

    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 60.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              langProvider.translate('no_missions') == 'no_missions' ? 'Aucune mission' : langProvider.translate('no_missions'),
              style: getInterStyle(
                fontSize: 16.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildMissionCard(mission, langProvider),
        );
      },
    );
  }

  Widget _buildMissionCard(MissionModel mission, LanguageProvider langProvider) {
    final nomStructure = mission.structureName ?? langProvider.translate('not_defined');
    final adresse = mission.structureAddress ?? langProvider.translate('not_defined');
    final horaires = '${mission.horaireMission?.hour.toString().padLeft(2, '0')}:${mission.horaireMission?.minute.toString().padLeft(2, '0')} - ${mission.heureFin ?? "..."}';
    final displayProf = mission.professionnelNom ?? langProvider.translate('not_assigned');
    
    final bool isActedUpon = mission.userStatus == 'confirmé' || 
                             mission.userStatus == 'refusé' ||
                             mission.professionnelId != null;

    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    final bool hasOngoing = missionProvider.hasOngoingMission;
    final bool isCurrentlyOngoing = mission.status.toLowerCase() == 'en cours';
    
    // Fallback status text for badge
    final badgeStatus = mission.userStatus ?? 'en attente';

    // compute relative day description
    String relativeDate() {
      if (mission.horaireMission == null) return '';
      final now = DateTime.now();
      final mDate = DateTime(mission.horaireMission!.year, mission.horaireMission!.month, mission.horaireMission!.day);
      final diff = mDate.difference(DateTime(now.year, now.month, now.day)).inDays;
      if (diff == 0) return langProvider.translate('today');
      if (diff == 1) return langProvider.translate('tomorrow');
      if (diff == -1) return langProvider.translate('yesterday');
      return '';
    }
    final dateLabel = relativeDate();
    final formattedDate = mission.horaireMission != null
        ? '${mission.horaireMission!.day.toString().padLeft(2,'0')} ${_monthName(mission.horaireMission!.month)} ${mission.horaireMission!.year}'
        : '';

    return Container(
      width: double.infinity,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // premier bloc : date et structure
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isActedUpon && dateLabel.isNotEmpty)
                    Text(
                      '$dateLabel${formattedDate.isNotEmpty ? ' - ' + formattedDate : ''}',
                      style: getInterStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.8),
                        height: 1.0,
                      ),
                    ),
                  if (!isActedUpon && dateLabel.isNotEmpty) SizedBox(height: 4.h),
                  Text(
                    nomStructure,
                    style: getInterStyle(fontSize: 16.sp, color: Colors.black87, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Row(
                children: [
                  if (mission.unreadMessagesCount > 0)
                    Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        mission.unreadMessagesCount.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  _buildStatusBadge(badgeStatus, langProvider),
                ],
              ),
            ],
          ),
          
          if (!isActedUpon) SizedBox(height: 8.h),
          // Professionnel assigné
          if (!isActedUpon)
            Row(
              children: [
                Icon(Icons.person_outline, size: 16.sp, color: Colors.grey[500]),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    displayProf,
                    style: getInterStyle(
                      fontSize: 13.sp, 
                      color: Colors.grey[600], 
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          SizedBox(height: 8.h),
          // Adresse
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16.sp,
                color: Colors.grey[500],
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  adresse,
                  style: getInterStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Horaires
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16.sp,
                color: Colors.grey[500],
              ),
              SizedBox(width: 6.w),
              Text(
                horaires,
                style: getInterStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          _buildCompactMenuBlock(mission, langProvider),
          SizedBox(height: 16.h),
          
          // Lien et boutons d'action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lien voir la mission
              GestureDetector(
                onTap: () async {
                  // Marquer la mission comme vue → badge disparaît
                  Provider.of<MissionProvider>(context, listen: false)
                      .markMissionAsViewed(mission.id);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MissionDetailScreen(
                        mission: mission,
                      ),
                    ),
                  );
                  if (result == true) {
                    _fetchMissions();
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      langProvider.translate('see_mission') == 'see_mission' ? 'Voir la mission' : langProvider.translate('see_mission'),
                      style: getInterStyle(
                        fontSize: 13.sp,
                        color: Color(0xFF0059AB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right, size: 18.sp, color: Color(0xFF0059AB)),
                  ],
                ),
              ),
              
              if (!isActedUpon)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(langProvider.translate('refuse'), Colors.red, () {
                      _handleAction(mission.id, 'reject');
                    }),
                    SizedBox(width: 8.w),
                    _buildActionButton(
                      langProvider.translate('confirm'), 
                      hasOngoing ? Colors.grey : Colors.green, 
                      hasOngoing 
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Terminez votre mission en cours avant d\'en accepter une nouvelle.')),
                              );
                            }
                          : () => _handleAction(mission.id, 'accept'),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String statut, LanguageProvider langProvider) {
    final String s = statut.toLowerCase().trim();
    Color bgColor;
    Color textColor;
    String text;

    if (s == 'terminé' || s == 'terminée' || s == 'finished') {
      text = langProvider.translate('finished');
      bgColor = const Color(0xFFF5F5F5);
      textColor = Colors.grey[600]!;
    } else if (s == 'réfusé' || s == 'refusé' || s == 'refused' || s == 'annulé' || s == 'annulée') {
      text = langProvider.translate('refused');
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
    } else if (s == 'en cours' || s == 'in_progress') {
      text = langProvider.translate('in_progress');
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF4CAF50);
    } else if (s == 'confirmé' || s == 'confirmée' || s == 'confirmed') {
      text = langProvider.translate('confirmed');
      bgColor = const Color(0xFFDCEEFB);
      textColor = const Color(0xFF1565C0);
    } else {
      // Par défaut ou 'en attente' / 'planned'
      text = s == 'en attente' ? langProvider.translate('pending_status') : s;
      bgColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF0059AB);
    }

    return Container(
      width: 55.w,
      height: 19.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5), // Radius: 5px
      ),
      child: Text(
        text,
        style: getInterStyle(
          fontSize: 8.sp, // Réduit pour tenir dans 19px de hauteur
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: getInterStyle(
            fontSize: 11.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<String> _getTabs(LanguageProvider langProvider) {
    return [
      langProvider.translate('upcoming'),
      langProvider.translate('in_progress'),
      langProvider.translate('completed'),
    ];
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
                style: getInterStyle(
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
                    color: Color(0xFF0059AB).withOpacity(0.6),
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

  String _monthName(int month) {
    const names = [
      '',
      'Jan', 'Fév', 'Mars', 'Avr', 'Mai', 'Juin',
      'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return (month >= 1 && month <= 12) ? names[month] : '';
  }
}

