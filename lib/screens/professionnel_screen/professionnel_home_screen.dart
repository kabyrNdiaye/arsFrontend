import 'package:flutter/material.dart';
import '../../models/mission_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'mission_detail_screen.dart';
import 'missions_screen.dart';
import 'formations_screen.dart';
import 'profil_screen.dart';
import '../../providers/notification_provider.dart';
import '../../providers/mission_provider.dart';
import 'package:intl/intl.dart';
import 'professionnel_incidents_screen.dart';

class ProfessionnelHomeScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;

  const ProfessionnelHomeScreen({
    Key? key,
    this.userName,
    this.userEmail,
  }) : super(key: key);

  @override
  _ProfessionnelHomeScreenState createState() =>
      _ProfessionnelHomeScreenState();
}

class _ProfessionnelHomeScreenState extends State<ProfessionnelHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mp = Provider.of<MissionProvider>(context, listen: false);
      mp.fetchMissions();
      mp.startPolling(); // Polling toutes les 15s pour les nouveaux messages
    });
  }

  @override
  void dispose() {
    Provider.of<MissionProvider>(context, listen: false).stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final userName = user?.fullName ?? widget.userName ?? 'Utilisateur';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0059AB), // Même couleur que le header
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildAccueilTab(userName, langProvider),
            _buildMissionsTab(),
            _buildFormationsTab(),
            _buildProfilTab(userName, langProvider),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(langProvider),
      ),
    );
  }

  Widget _buildBottomNavBar(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded,
                  langProvider.translate('home')),
              _buildNavItem(
                1,
                Icons.cases_outlined,
                Icons.cases_rounded,
                langProvider.translate('missions'),
                imagePath: 'assets/images/missions.png',
              ),
              _buildNavItem(
                2,
                Icons.menu_book_outlined,
                Icons.menu_book,
                langProvider.translate('training'),
                imagePath: 'assets/images/icon_formation.png',
              ),
              _buildNavItem(
                3,
                Icons.person_outline_rounded,
                Icons.person_rounded,
                langProvider.translate('profile'),
                activeImagePath: 'assets/images/icon_profil_active.png',
                inactiveImagePath: 'assets/images/icon_profil_non_active.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    String? imagePath,
    String? activeImagePath,
    String? inactiveImagePath,
  }) {
    final isSelected = _currentIndex == index;

    Widget buildIcon() {
      // Cas spécifique pour Profil avec images différentes (active/inactive)
      if (activeImagePath != null && inactiveImagePath != null) {
        return Image.asset(
          isSelected ? activeImagePath : inactiveImagePath,
          width: 24.w,
          height: 24.h,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? Color(0xFF0059AB) : Colors.grey[500],
            size: 24.sp,
          ),
        );
      }

      // Cas avec une seule image (qu'on colore)
      if (imagePath != null) {
        return Image.asset(
          imagePath,
          width: 24.w,
          height: 24.h,
          color: isSelected ? Color(0xFF0059AB) : Colors.grey[500],
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? Color(0xFF0059AB) : Colors.grey[500],
            size: 24.sp,
          ),
        );
      }

      // Cas par défaut avec icône
      return Icon(
        isSelected ? activeIcon : icon,
        color: isSelected ? Color(0xFF0059AB) : Colors.grey[500],
        size: 24.sp,
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildIcon(),
          SizedBox(height: 4.h),
          Text(
            label,
            style: getInterStyle(
              fontSize: 10.sp,
              color: isSelected ? Color(0xFF0059AB) : Colors.grey[500],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccueilTab(String userName, LanguageProvider langProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bleu
          _buildHeaderOnly(userName, langProvider),

          // Carte Mission du jour (superposée visuellement avec Transform)
          Consumer<MissionProvider>(
            builder: (context, missionProvider, child) {
              // Filtrer les missions "en cours" pour le bandeau du haut
              final inProgressMissions = missionProvider.missions
                  .where((m) =>
                      m.professionnelId != null &&
                      m.userStatus == 'confirmé' &&
                      m.status?.toLowerCase() == 'en cours')
                  .toList();

              // Filtrer les missions à venir (y compris open pour tous)
              final upcomingMissions = missionProvider.missions
                  .where((m) =>
                      m.userStatus != 'refusé' &&
                      m.status?.toLowerCase() != 'en cours' &&
                      m.status?.toLowerCase() != 'terminé')
                  .toList();

              // Trier les missions à venir par date
              upcomingMissions.sort((a, b) =>
                  (a.horaireMission ?? DateTime.now())
                      .compareTo(b.horaireMission ?? DateTime.now()));

              final currentMission = inProgressMissions.isNotEmpty
                  ? inProgressMissions.first
                  : null;
              final otherMissions = upcomingMissions;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Transform.translate(
                    offset: Offset(0, -30.h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildMissionDuJour(
                          context, langProvider, currentMission),
                    ),
                  ),

                  // Section Missions à venir
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              langProvider.translate('upcoming_missions') ??
                                  'Missions à venir',
                              style: getInterStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _currentIndex = 1),
                              child: Text(
                                'Voir tout',
                                style: getInterStyle(
                                  fontSize: 12.sp,
                                  color: Color(0xFF0059AB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        if (otherMissions.isEmpty)
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Aucune mission à venir pour le moment",
                              style: getInterStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        else
                          ...otherMissions
                              .take(5)
                              .map((m) => Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: _buildMissionAVenirItem(mission: m),
                                  ))
                              .toList(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 24.h),

          // Section Accès rapides
          _buildAccesRapides(langProvider),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildHeaderOnly(String userName, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 40.h),
      decoration: BoxDecoration(
        color: Color(0xFF0059AB),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          children: [
            // Trait horizontal en haut, juste sous la barre de statut
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top > 0
                    ? MediaQuery.of(context).padding.top + 8.h
                    : 32.h,
                left: 12.w,
                right: 12.w,
              ),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Row(
                children: [
                  // Photo de profil
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          final photoUrl = auth.user?.photoProfil;
                          if (photoUrl != null) {
                            return Image.network(
                              photoUrl,
                              width: 48.w,
                              height: 48.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 28.sp,
                                  color: Colors.grey[600],
                                );
                              },
                            );
                          }
                          return Image.asset(
                            'assets/images/icon_personne.png',
                            width: 48.w,
                            height: 48.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 28.sp,
                                color: Colors.grey[600],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Texte de bienvenue
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          langProvider.translate('hello'),
                          style: getInterStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userName,
                          style: getInterStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Icône notification avec badge (uniquement pour les messages)
                  Consumer<MissionProvider>(
                    builder: (context, missionProvider, child) {
                      final int totalUnread =
                          missionProvider.totalUnreadMessagesCount + missionProvider.newMissionsCount;

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
                                      totalUnread > 9
                                          ? '9+'
                                          : totalUnread.toString(),
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

  Widget _buildMissionDuJour(BuildContext context,
      LanguageProvider langProvider, MissionModel? mission) {
    final String heureDebut = mission?.horaireMission != null
        ? DateFormat('HH\'h\'mm').format(mission!.horaireMission!)
        : '-';
    final String heureFin = mission?.heureFin ?? '-';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Bordure gauche bleue #0085FF
            Container(
              width: 6.w,
              decoration: BoxDecoration(
                color: const Color(0xFF0085FF),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Contenu de la carte
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: mission == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 8.h),
                          Text(
                            "Pas de mission pour le moment.",
                            textAlign: TextAlign.center,
                            style: getInterStyle(
                              fontSize: 15.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Patientez, une mission vous sera assignée par l'agence ARS. Merci de votre patience.",
                            textAlign: TextAlign.center,
                            style: getInterStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[500]!,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Titre et badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                langProvider.translate('mission_of_day') ??
                                    'Mission du jour',
                                style: getInterStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              // Badge "En cours"
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Color(0xFF009814).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  langProvider.translate('in_progress'),
                                  style: getInterStyle(
                                    fontSize: 10.sp,
                                    color: Color(0xFF009814),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // Nom de l'établissement
                          Text(
                            mission.structureName ?? 'Établissement inconnu',
                            style: getInterStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          // Adresse
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16.sp,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  mission.structureAddress ??
                                      'Adresse non renseignée',
                                  style: getInterStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 4.h),

                          // Horaires
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: 16.sp,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '$heureDebut - $heureFin',
                                style: getInterStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Bouton bleu #0059AB
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      MissionDetailScreen(
                                    mission: mission,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: Color(0xFF0059AB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/chef.png',
                                    width: 20.w,
                                    height: 20.h,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.restaurant_menu,
                                        size: 20.sp,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    langProvider.translate('access_mission'),
                                    style: getInterStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionAVenirItem({
    required MissionModel mission,
  }) {
    final String dateStr = mission.horaireMission != null
        ? DateFormat('dd MMM', 'fr_FR').format(mission.horaireMission!)
        : '-';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                MissionDetailScreen(mission: mission),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.structureName ?? 'Établissement inconnu',
                    style: getInterStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: getInterStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (mission.professionnelId == null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Disponible',
                            style: getInterStyle(
                              fontSize: 10.sp,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Flèche
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccesRapides(LanguageProvider langProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            langProvider.translate('quick_access'),
            style: getInterStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // Formations
              Expanded(
                child: _buildAccesRapideItemWithImage(
                  imagePath: 'assets/images/icon_formation.png',
                  label: langProvider.translate('training'),
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),

              SizedBox(width: 12.w),

              // Incidents
              Expanded(
                child: _buildAccesRapideItemWithImage(
                  imagePath: 'assets/images/icon_incident.png',
                  label: langProvider.translate('incidents'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ProfessionnelIncidentsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccesRapideItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: Color(0xFF0059AB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Color(0xFF0059AB),
                size: 24.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: getInterStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccesRapideItemWithImage({
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: 24.w,
                  height: 24.h,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.report_outlined,
                      color: Color(0xFF0059AB),
                      size: 24.sp,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: getInterStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionsTab() {
    return MissionsScreen();
  }

  Widget _buildFormationsTab() {
    return FormationsScreen();
  }

  Widget _buildProfilTab(String userName, LanguageProvider langProvider) {
    return ProfilScreen(
      userName: userName,
      userRole: langProvider.translate('professional_cook'),
    );
  }
}
