import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/mission_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/mission_model.dart';
import 'package:intl/intl.dart';
import 'mission_chat_screen.dart';
import 'mission_details_screen.dart';
import '../../utils/font_helper.dart';
import '../../providers/notification_provider.dart';

class ClientMissionsScreen extends StatefulWidget {
  final String? userName;
  final String? etablissementName;
  
  const ClientMissionsScreen({
    Key? key,
    this.userName,
    this.etablissementName,
  }) : super(key: key);

  @override
  _ClientMissionsScreenState createState() => _ClientMissionsScreenState();
}

class _ClientMissionsScreenState extends State<ClientMissionsScreen> {
  final Color _primaryGreen = const Color(0xFF4CA054);
  bool _showAllMissions = false;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 400 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 400 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MissionProvider>(context, listen: false).fetchMissions();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildHeader(langProvider),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<MissionProvider>(
                          builder: (context, missionProvider, child) {
                            if (missionProvider.isLoading && missionProvider.missions.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.h),
                                  child: CircularProgressIndicator(color: _primaryGreen),
                                ),
                              );
                            }

                            if (missionProvider.error != null) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.error_outline, size: 60.sp, color: Colors.red[300]),
                                      SizedBox(height: 12.h),
                                      Text(
                                        langProvider.translate('error_loading_missions') ?? 'Erreur lors du chargement',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                      if (missionProvider.error != null) ...[
                                        SizedBox(height: 8.h),
                                        Text(
                                          missionProvider.error!,
                                          style: TextStyle(color: Colors.red[800], fontSize: 12.sp),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                      SizedBox(height: 8.h),
                                      TextButton(
                                        onPressed: () => missionProvider.fetchMissions(),
                                        child: Text(
                                          langProvider.translate('retry') ?? 'Réessayer',
                                          style: TextStyle(color: _primaryGreen, fontSize: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (missionProvider.missions.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 60.h),
                                  child: Column(
                                    children: [
                                      Icon(Icons.assignment_outlined, size: 60.sp, color: Colors.grey[300]),
                                      SizedBox(height: 16.h),
                                      Text(
                                        langProvider.translate('no_mission_yet') ?? 'Aucune mission pour le moment',
                                        style: getSourceSerifProStyle(color: Colors.grey, fontSize: 16.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Sort missions by createdAt descending
                            final sortedMissions = List<MissionModel>.from(missionProvider.missions);
                            sortedMissions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                            final displayMissions = _showAllMissions 
                                ? sortedMissions 
                                : sortedMissions.take(3).toList();

                            return Column(
                              children: [
                                ...displayMissions.map((mission) {
                                  return _buildDynamicMissionCard(mission, langProvider);
                                }).toList(),
                                if (!_showAllMissions && sortedMissions.length > 3)
                                  Padding(
                                    padding: EdgeInsets.only(top: 20.h, bottom: 40.h),
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _showAllMissions = true),
                                        child: Container(
                                          width: 48.w,
                                          height: 48.w,
                                          decoration: BoxDecoration(
                                            color: _primaryGreen,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: _primaryGreen.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Icon(Icons.add, color: Colors.white, size: 28.sp),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_showBackToTop)
              Positioned(
                bottom: 24.h,
                right: 16.w,
                child: FloatingActionButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  backgroundColor: _primaryGreen,
                  elevation: 6,
                  child: Icon(Icons.arrow_upward, color: Colors.white, size: 24.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final userName = user?.fullName ?? widget.userName ?? langProvider.translate('user_default');
    final etablissementName = user?.nomEtablissement ?? widget.etablissementName ?? langProvider.translate('structure_default');
    final fonction = user?.fonction ?? langProvider.translate('director');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top + 8.h : 32.h,
                left: 12.w,
                right: 12.w,
              ),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icône structure
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _primaryGreen, width: 2),
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Image.asset(
                              'assets/images/icon_structure.png',
                              width: 44.w,
                              height: 44.h,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: CustomPaint(
                                    size: Size(40.w, 40.h),
                                    painter: HouseWithPlusPainter(color: _primaryGreen),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      // Nom établissement & utilisateur
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              etablissementName,
                              style: getSourceSerifProStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              userName,
                              style: getSourceSerifProStyle(
                                fontSize: 15.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6ABF6E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                fonction,
                                style: getSourceSerifProStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                  size: 30.sp,
                                  semanticLabel: 'Notifications',
                                ),
                                if (totalUnread > 0)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      width: 20.w,
                                      height: 20.h,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          totalUnread > 9 ? '9+' : totalUnread.toString(),
                                          style: getSourceSerifProStyle(
                                            fontSize: 11.sp,
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
                  // Stats
                  Consumer<MissionProvider>(
                    builder: (context, missionProvider, child) {
                      final stats = missionProvider.structureStats;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildStatCard('${stats['total_missions'] ?? '--'}', langProvider.translate('missions')),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildStatCard('${stats['total_residents'] ?? '--'}', langProvider.translate('residents')),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildStatCard('${stats['total_chefs'] ?? '--'}', langProvider.translate('chefs')),
                          ),
                        ],
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
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFF6ABF6E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(height: 2.h),
          Text(
            label,
            style: getSourceSerifProStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(LanguageProvider lang) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 24.h, 4.w, 16.h),
      child: Text(
        lang.translate('mes_missions') ?? lang.translate('my_missions'),
        style: getSourceSerifProStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDynamicMissionCard(MissionModel mission, LanguageProvider langProvider) {
    // Calcul du statut et des couleurs basé sur le statut réel de la base de données
    String statusLabel;
    Color badgeColor;
    Color textColor;
    IconData? statusIcon;

    final String s = (mission.status ?? '').toLowerCase().trim();

    if (s == 'terminé' || s == 'terminée' || s == 'finished') {
      statusLabel = langProvider.translate('finished');
      badgeColor = const Color(0xFFF5F5F5);
      textColor = Colors.grey[600]!;
      statusIcon = Icons.check_circle_outline;
    } else if (s == 'réfusé' || s == 'refusé' || s == 'refused' || s == 'annulé' || s == 'annulée') {
      statusLabel = langProvider.translate('refused');
      badgeColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
      statusIcon = Icons.cancel_outlined;
    } else if (s == 'en cours' || s == 'in_progress') {
      statusLabel = langProvider.translate('in_progress');
      badgeColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF4CAF50);
      statusIcon = Icons.access_time;
    } else if (s == 'confirmé' || s == 'confirmée' || s == 'confirmed') {
      statusLabel = langProvider.translate('confirmed');
      badgeColor = const Color(0xFFDCEEFB);
      textColor = const Color(0xFF1565C0);
      statusIcon = Icons.check_circle_outlined;
    } else {
      // Par défaut ou 'en attente' / 'planned'
      statusLabel = langProvider.translate('planned');
      badgeColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF0059AB);
      statusIcon = Icons.calendar_today_outlined;
    }

    final DateTime dateToUse = mission.horaireMission ?? mission.createdAt;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateToUse.year, dateToUse.month, dateToUse.day);
    final difference = targetDate.difference(today).inDays;

    String dateLabel = "";
    if (difference == 0) dateLabel = "${langProvider.translate('today')} - ";
    else if (difference == 1) dateLabel = "${langProvider.translate('tomorrow')} - ";
    
    dateLabel += DateFormat('d MMM yyyy', langProvider.currentLanguage).format(dateToUse);

    final String startTime = mission.horaireMission != null
        ? DateFormat('HH:mm').format(mission.horaireMission!).replaceFirst(':', 'h')
        : "7h30";
        
    final String endTime = mission.heureFin != null 
        ? mission.heureFin!.replaceFirst(':', 'h') 
        : "16h00";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  style: getSourceSerifProStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 75.w,
                height: 19.h,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (statusIcon != null) ...[
                      Icon(statusIcon, size: 8.sp, color: textColor),
                      SizedBox(width: 4.w),
                    ],
                    Text(
                      statusLabel,
                      style: getInterStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            mission.professionnelNom ?? langProvider.translate('not_assigned'),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Icon(Icons.access_time_outlined, color: Colors.grey[400], size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                '$startTime - $endTime',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildCompactMenuBlock(mission),
          SizedBox(height: 20.h),
          Center(
            child: SizedBox(
              width: 319.w,
              height: 31.h,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Marquer la mission comme vue → badge disparaît
                        Provider.of<MissionProvider>(context, listen: false)
                            .markMissionAsViewed(mission.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MissionDetailsScreen(mission: mission),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        langProvider.translate('see_details'),
                        style: getSourceSerifProStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MissionChatScreen(mission: mission),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _primaryGreen, width: 1.5),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              langProvider.translate('chat'),
                              style: getSourceSerifProStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: _primaryGreen,
                              ),
                            ),
                          ),
                        ),
                        if (mission.unreadMessagesCount > 0)
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
                                  mission.unreadMessagesCount > 99
                                      ? '99+'
                                      : mission.unreadMessagesCount.toString(),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMenuBlock(MissionModel mission) {
    final mainRepas = mission.getMainRepas();
    final bool hasMenu = mainRepas != null;
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lang.translate('menu_upper'),
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
              if (hasMenu)
                Text(
                  lang.translate(mainRepas.typeRepas.toLowerCase().trim().replaceAll(' ', '_')).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: _primaryGreen.withOpacity(0.6),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          if (!hasMenu)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Text(
                lang.translate('menu_not_communicated'),
                style: TextStyle(
                  fontSize: 15.sp, 
                  color: Colors.grey[400], 
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.2,
                ),
              ),
            )
          else
            _buildMenuRowsForMeal(mainRepas),
        ],
      ),
    );
  }

  Widget _buildMenuRowsForMeal(RepasModel repas) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    return Column(
      children: [
        _buildSimplifiedMenuRow(lang.translate('starter_label'), repas.getDisplayName('entree'), lang),
        _buildSimplifiedMenuRow(lang.translate('dish_label'), repas.getDisplayName('plat'), lang),
        _buildSimplifiedMenuRow(lang.translate('side_label'), repas.getDisplayName('accompagnement'), lang),
        _buildSimplifiedMenuRow(lang.translate('dessert_label'), repas.getDisplayName('dessert'), lang),
      ],
    );
  }

  Widget _buildSimplifiedMenuRow(String label, String value, LanguageProvider lang) {
    if (value.isEmpty || value == '--') return const SizedBox.shrink();
    
    double labelWidth = 75.w;
    if (label == lang.translate('dish_label')) labelWidth = 50.w;
    else if (label == lang.translate('side_label')) labelWidth = 140.w;
    else if (label == lang.translate('dessert_label')) labelWidth = 85.w;

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              '$label : ',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D2D),
                height: 1.1,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showMissionDetailsModal(MissionModel mission, LanguageProvider lang) {
    // Calcul du statut pour le badge d'en-tête
    String statusLabel;
    Color badgeColor;
    Color textColor;
    final String s = mission.status.toLowerCase();

    // translate status using language provider when possible
    String statusKey = s.replaceAll(' ', '_');
    statusLabel = lang.translate(statusKey) ?? mission.status;

    // Calcule du statut selon si un professionnel est assigné
    final bool isAssigned = mission.professionnelNom != null && 
                           mission.professionnelNom!.trim().isNotEmpty && 
                           mission.professionnelNom != 'Thomas Martin' &&
                           mission.professionnelNom != 'Non assigné';

    if (isAssigned) {
      statusLabel = 'En cours';
      badgeColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF4CAF50);
    } else {
      statusLabel = 'Planifiée';
      badgeColor = const Color(0xFFDEEAFC);
      textColor = const Color(0xFF0059AB);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFFBFBFB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Détails Mission',
                          style: getSourceSerifProStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if (mission.structureAddress != null)
                          Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, size: 14.sp, color: _primaryGreen),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    mission.structureAddress!,
                                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[400], size: 24.sp),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    _buildFullRecapSection(mission, lang),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullRecapSection(MissionModel mission, LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('INFORMATIONS GÉNÉRALES'),
        _buildGeneralInfoSection(mission, lang),
        SizedBox(height: 16.h),
        _buildInfoGrid(mission, lang),
        SizedBox(height: 32.h),

        if (mission.horaireMission != null) ...[
          _buildSectionHeader('HORAIRES PRÉVUS'),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: _primaryGreen, size: 20.sp),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Début : ${mission.horaireMission!.hour.toString().padLeft(2, '0')}:${mission.horaireMission!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    if (mission.heureFin != null)
                      Text(
                        'Fin : ${mission.heureFin}',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
        ],
        
        _buildSectionHeader('PLANNING DES REPAS'),
        _buildRecapSection(mission, lang),
        SizedBox(height: 32.h),

        if (mission.recipes.isNotEmpty) ...[
          _buildSectionHeader('RECETTES ASSOCIÉES'),
          ...mission.recipes.map((recipe) => Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _primaryGreen.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(color: _primaryGreen.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.menu_book, color: _primaryGreen, size: 20.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.nom, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                      if (recipe.type != null)
                        Text(recipe.type!, style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[300]),
              ],
            ),
          )).toList(),
          SizedBox(height: 32.h),
        ],

        if (mission.regimesSpeciaux.isNotEmpty) ...[
          _buildSectionHeader('RÉGIMES SPÉCIAUX'),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: mission.regimesSpeciaux.map((diet) {
              // try to translate each diet label
              final key = diet.toLowerCase().replaceAll(' ', '_');
              final label = lang.translate(key) ?? diet;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primaryGreen.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  label,
                  style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 32.h),
        ],

        if ((mission.commentaires != null && mission.commentaires!.trim().isNotEmpty) ||
            (mission.adminComments != null && mission.adminComments!.trim().isNotEmpty)) ...[
          _buildSectionHeader('NOTES & COMMENTAIRES'),
          if (mission.commentaires != null && mission.commentaires!.trim().isNotEmpty)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFCEA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1EBC3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sticky_note_2_outlined, color: Colors.orange[300], size: 18.sp),
                      SizedBox(width: 8.w),
                      Text('STRUCTURE', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.orange[400])),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    mission.commentaires!,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.5),
                  ),
                ],
              ),
            ),
          if (mission.adminComments != null && mission.adminComments!.trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE1BEE7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings_outlined, color: Colors.purple[300], size: 18.sp),
                      SizedBox(width: 8.w),
                      Text('ADMINISTRATEUR', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.purple[400])),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    mission.adminComments!,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.5),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildRecapSection(MissionModel mission, LanguageProvider lang) {
    if (mission.repas.isEmpty) return const SizedBox.shrink();
    return Column(
      children: mission.repas.asMap().entries.map((entry) {
        final index = entry.key;
        final repas = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mission.repas.length > 1)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  'Repas ${index + 1}',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
              ),
            _buildMealCard(repas, lang),
            SizedBox(height: 12.h),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMealCard(RepasModel repas, LanguageProvider lang) {
    String mealKey = repas.typeRepas.toLowerCase();
    String label = repas.typeRepas;
    if (mealKey == 'breakfast') label = lang.translate('breakfast') ?? 'Petit-déjeuner';
    if (mealKey == 'lunch') label = lang.translate('lunch') ?? 'Déjeuner';
    if (mealKey == 'snack') label = lang.translate('snack') ?? 'Goûter';
    if (mealKey == 'dinner') label = lang.translate('dinner') ?? 'Dîner';

    bool isSimple = mealKey == 'breakfast' || mealKey == 'snack';
    bool hasAny = isSimple 
        ? repas.getDisplayName('simple').isNotEmpty
        : (repas.getDisplayName('entree').isNotEmpty ||
           repas.getDisplayName('plat').isNotEmpty ||
           repas.getDisplayName('accompagnement').isNotEmpty ||
           repas.getDisplayName('dessert').isNotEmpty);
    
    if (!hasAny) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 16.h,
                decoration: BoxDecoration(color: _primaryGreen, borderRadius: BorderRadius.circular(2)),
              ),
              SizedBox(width: 8.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 0.5),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (isSimple)
            _buildMealItemRow('DESCRIPTION', repas.getDisplayName('simple'))
          else ...[
            _buildMealItemRow('ENTRÉE', repas.getDisplayName('entree')),
            _buildMealItemRow('PLAT DE RÉSISTANCE', repas.getDisplayName('plat')),
            _buildMealItemRow('ACCOMPAGNEMENT', repas.getDisplayName('accompagnement')),
            _buildMealItemRow('DESSERT', repas.getDisplayName('dessert')),
          ],
        ],
      ),
    );
  }

  Widget _buildMealItemRow(String label, String value) {
    if (value.isEmpty || value == '--') return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 0.5),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 15.sp, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Text(
            title,
            style: getSourceSerifProStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Divider(color: Colors.grey[200])),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(MissionModel mission, LanguageProvider lang) {
    return Row(
      children: [
        Expanded(child: _buildStatCardPremium(Icons.people_outline, "${mission.nbResidentsJour}", "Résidents")),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatCardPremium(Icons.person_search_rounded, "${mission.nbChefs}", "Chefs")),
      ],
    );
  }

  Widget _buildStatCardPremium(IconData icon, String value, String label) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: _primaryGreen.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(icon, color: _primaryGreen, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black)),
                Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Informations supplémentaires pour le récapitulatif complet
  Widget _buildGeneralInfoSection(MissionModel mission, LanguageProvider lang) {
    // traduit une liste de valeurs s'il existe une clé correspondante
    String translateList(List<String> items) {
      return items
          .map((e) {
            final key = e.toLowerCase().replaceAll(' ', '_');
            return lang.translate(key) ?? e;
          })
          .toList()
          .join(', ');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mission.structureName != null && mission.structureName!.isNotEmpty)
          _buildMenuRow(lang.translate('structure') ?? 'Structure', mission.structureName!),
        _buildMenuRow(lang.translate('avg_residents_day'), mission.nbResidentsJour.toString()),
        if (mission.typesRepas.isNotEmpty)
          _buildMenuRow(lang.translate('meal_types'), translateList(mission.typesRepas)),
        if (mission.regimesSpeciaux.isNotEmpty)
          _buildMenuRow(lang.translate('special_diets'), translateList(mission.regimesSpeciaux)),
        if (mission.professionnelNom != null && mission.professionnelNom!.isNotEmpty)
          _buildMenuRow(lang.translate('professional') ?? 'Professionnel', mission.professionnelNom!),
        _buildMenuRow('Créée le', DateFormat('dd/MM/yyyy').format(mission.createdAt)),
      ],
    );
  }
  Widget _buildMenuRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label : ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            TextSpan(
              text: (value == null || value.isEmpty) ? '--' : value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class HouseWithPlusPainter extends CustomPainter {
  final Color color;
  HouseWithPlusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final roofPath = Path();
    roofPath.moveTo(size.width / 2, 0);
    roofPath.lineTo(size.width, size.height * 0.4);
    roofPath.lineTo(0, size.height * 0.4);
    roofPath.close();
    canvas.drawPath(roofPath, paint);
    final housePath = Path();
    housePath.addRect(Rect.fromLTWH(size.width * 0.15, size.height * 0.4, size.width * 0.7, size.height * 0.55));
    canvas.drawPath(housePath, paint);
    final plusPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height * 0.675;
    final plusWidth = size.width * 0.25;
    final plusThickness = size.height * 0.08;
    canvas.drawRect(Rect.fromCenter(center: Offset(centerX, centerY), width: plusWidth, height: plusThickness), plusPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(centerX, centerY), width: plusThickness, height: plusWidth), plusPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
