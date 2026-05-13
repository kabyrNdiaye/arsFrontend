import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import '../auth/login_screen_2.dart';
import 'client_parametres_screen.dart';
import 'client_missions_screen.dart';
import 'client_create_mission_screen.dart';
import '../../models/user_model.dart';
import '../../providers/notification_provider.dart';
import '../../providers/mission_provider.dart';
import '../../models/mission_model.dart';
import 'mission_details_screen.dart';
import 'mission_chat_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import '../../services/mission_service.dart';
import '../../services/incident_service.dart';
import '../../services/retour_service.dart';
import '../shared/file_preview_screen.dart';
import '../../services/api_service.dart';
import 'client_edit_inscription_screen.dart';
import 'mission_qr_scanner_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? etablissementName;

  const ClientHomeScreen({
    Key? key,
    this.userName,
    this.userEmail,
    this.etablissementName,
  }) : super(key: key);

  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mp = Provider.of<MissionProvider>(context, listen: false);
      // Charger en parallèle pour aller plus vite
      Future.wait([
        Provider.of<NotificationProvider>(context, listen: false).fetchNotifications(),
        mp.fetchStructureStats(),
        mp.fetchMissions(),
      ]);
      mp.startPolling();
    });
  }

  @override
  void dispose() {
    Provider.of<MissionProvider>(context, listen: false).stopPolling();
    super.dispose();
  }

  // Couleurs
  final Color _primaryGreen = Color(0xFF4CA054);
  final Color _lightGreen = Color(0xFFE8F5E9);
  final Color _orangeColor = Color(0xFFE87834);
  final Color _folderColor = Color(0xFFCB3A32);
  final Color _addressColor = Color(0xFFCB3A32);
  final Color _phoneColor = Color(0xFF4CA054);
  final Color _emailColor = Color(0xFF0059AB);
  final Color _capacityColor = Color(0xFF7C39D3);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final userName = user?.fullName ??
        widget.userName ??
        langProvider.translate('user_default');
    final userEmail = user?.email ?? widget.userEmail ?? '';
    final userPhone = user?.phone ?? '';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildBody(langProvider, userName, userEmail, userPhone,
                user), // Profil (index 0)
            ClientMissionsScreen(
              userName: userName,
              etablissementName:
                  user?.nomEtablissement ?? widget.etablissementName,
            ), // Missions (index 1)
            ClientCreateMissionScreen(
              onMissionCreated: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ), // Créer une mission (index 2)
            _buildHistoriqueBody(
                langProvider, userName, user), // Historique (index 3)
          ],
        ),
        bottomNavigationBar: _buildBottomNav(langProvider),
      ),
    );
  }

  Widget _buildBody(LanguageProvider langProvider, String userName,
      String userEmail, String userPhone, User? user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderWithStats(langProvider, userName, user),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildInformationsSection(
                    langProvider, userEmail, userPhone, user),
                SizedBox(height: 16.h),
                _buildDocumentsSection(langProvider, user),
                SizedBox(height: 16.h),
                _buildActionsSection(langProvider, user),
                SizedBox(height: 24.h),
                _buildDeconnexionButton(langProvider),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithStats(
      LanguageProvider langProvider, String userName, User? user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icône structure dans cercle blanc avec contour vert
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
                                    painter: HouseWithPlusPainter(
                                        color: _primaryGreen),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      // Nom établissement, utilisateur et badge Directrice
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.nomEtablissement ??
                                  widget.etablissementName ??
                                  langProvider.translate('structure_default'),
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
                            // Badge Directrice en vert clair
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: Color(0xFF6ABF6E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user?.fonction ??
                                    langProvider.translate('director'),
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
                      // Icône notification avec badge (uniquement messages)
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
                                  size: 30.sp,
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
                                        border: Border.all(
                                            color: _primaryGreen, width: 1.5),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 18.w,
                                        minHeight: 18.w,
                                      ),
                                      child: Text(
                                        totalUnread > 9
                                            ? '9+'
                                            : totalUnread.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
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
                  // Stats section avec cartes individuelles
                  Consumer<MissionProvider>(
                    builder: (context, missionProvider, child) {
                      final stats = missionProvider.structureStats;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100.w,
                            child: _buildStatCard(
                                '${stats['total_missions'] ?? '--'}',
                                langProvider.translate('missions')),
                          ),
                          SizedBox(width: 12.w),
                          SizedBox(
                            width: 100.w,
                            child: _buildStatCard(
                                '${stats['total_residents'] ?? '--'}',
                                langProvider.translate('residents')),
                          ),
                          SizedBox(width: 12.w),
                          SizedBox(
                            width: 100.w,
                            child: _buildStatCard(
                                '${stats['total_chefs'] ?? '--'}',
                                langProvider.translate('chefs')),
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
        color: Color(0xFF6ABF6E), // Vert clair pour les cartes
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

  Widget _buildInformationsSection(LanguageProvider langProvider,
      String userEmail, String userPhone, User? user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Image.asset(
                  'assets/images/icon_informations.png',
                  width: 24.w,
                  height: 24.h,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.bar_chart,
                        color: _emailColor, size: 16.sp);
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                langProvider.translate('informations'),
                style: getSourceSerifProStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Adresse
          _buildInfoRowWithBg(
            Icons.location_on,
            langProvider.translate('address'),
            user?.fullAddress ?? '45 Avenue de la République, 75011 Paris',
            _capacityColor,
            Color(0xFFF3E5F5),
          ),
          _buildSeparator(),
          // Téléphone
          _buildInfoRowWithBg(
            Icons.phone,
            langProvider.translate('phone_label'),
            userPhone.isEmpty ? '+33 1 00 00 00 00' : userPhone,
            _phoneColor,
            _lightGreen,
          ),
          _buildSeparator(),
          // Email
          _buildInfoRowWithBg(
            Icons.email,
            langProvider.translate('email'),
            userEmail,
            _emailColor,
            Color(0xFFE3F2FD),
          ),
          _buildSeparator(),
          // Capacité
          _buildInfoRowWithBg(
            Icons.people,
            langProvider.translate('capacity'),
            '${user?.capacite ?? "120"} ' + langProvider.translate('residents'),
            _capacityColor,
            Color(0xFFF3E5F5),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Container(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  Widget _buildInfoRowWithBg(IconData icon, String label, String value,
      Color iconColor, Color bgColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: getSourceSerifProStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: getSourceSerifProStyle(
                  fontSize: 13.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(LanguageProvider langProvider, User? user) {
    if (user == null) return const SizedBox.shrink();

    final List<Map<String, String>> docs = [];

    // Documents explicites
    if (user.contratPrestationPath?.isNotEmpty == true) {
      docs.add({
        'title': langProvider.translate('service_contract'),
        'url': user.contratPrestationPath!
      });
    }
    if (user.planLocauxPath?.isNotEmpty == true) {
      docs.add({
        'title': langProvider.translate('premises_plan'),
        'url': user.planLocauxPath!
      });
    }
    if (user.reglementInterieurPath?.isNotEmpty == true) {
      docs.add({
        'title': langProvider.translate('internal_rules'),
        'url': user.reglementInterieurPath!
      });
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.folder, color: _folderColor, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                langProvider.translate('documents'),
                style: getSourceSerifProStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (docs.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  langProvider.translate('no_document_available'),
                  style: getSourceSerifProStyle(
                      fontSize: 13.sp, color: Colors.grey[500]),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (context, index) => _buildDocSeparator(),
              itemBuilder: (context, index) {
                return _buildDocumentRowStyled(docs[index]['title']!, 'PDF',
                    langProvider, docs[index]['url']);
              },
            ),
        ],
      ),
    );
  }

  String _formatDocTitle(String key) {
    // Transformer kbis_path ou KBIS en un libellé propre
    return key
        .replaceFirst('_path', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((s) {
      if (s.isEmpty) return s;
      return s[0].toUpperCase() + s.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildDocSeparator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Container(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  Widget _buildDocumentRowStyled(
      String title, String size, LanguageProvider langProvider,
      [String? url]) {
    return Row(
      children: [
        // Icône document avec fond rose
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.description_outlined,
            color: _folderColor,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 12.w),
        // Nom et taille du document
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: getSourceSerifProStyle(
                  fontSize: 13.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                size,
                style: getSourceSerifProStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        // Bouton téléchargement / Ouverture
        GestureDetector(
          onTap: () {
            if (url != null && url.isNotEmpty) {
              final String ext = url.split('.').last.toLowerCase();
              final String fileType =
                  (ext == 'jpg' || ext == 'jpeg' || ext == 'png')
                      ? 'image'
                      : 'pdf';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FilePreviewScreen(
                    fileUrl: url,
                    fileName: title,
                    fileType: fileType,
                    authToken: ApiService().token,
                  ),
                ),
              );
            }
          },
          child: Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.download_outlined,
              color: _primaryGreen,
              size: 20.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(LanguageProvider langProvider, User? user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre Actions
          Text(
            langProvider.translate('actions'),
            style: getSourceSerifProStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 14.h),
          // Bouton Envoyer un retour (vert)
          _buildActionButton(
            langProvider.translate('send_feedback'),
            Icons.chat_bubble_outline,
            _primaryGreen,
            langProvider,
          ),
          SizedBox(height: 10.h),
          // Bouton Signaler un incident (orange)
          _buildActionButtonWithImage(
            langProvider.translate('report_incident'),
            'assets/images/icon_incident.png',
            _orangeColor,
            langProvider,
          ),
          SizedBox(height: 10.h),
          // Bouton Modifier mon dossier (violet)
          _buildActionButtonEdit(langProvider),
          SizedBox(height: 10.h),
          // Bouton Scanner fin de mission (bleu)
          _buildActionButtonQrScan(langProvider),
          SizedBox(height: 10.h),
          // Bouton Paramètres (gris)
          _buildActionButtonGrey(
            langProvider.translate('settings'),
            Icons.settings_outlined,
            langProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bgColor,
      LanguageProvider langProvider) {
    return GestureDetector(
      onTap: () {
        if (label == 'Envoyer un retour') {
          _showRetourBottomSheet(langProvider);
        } else if (label == 'Signaler un incident') {
          _showIncidentBottomSheet(langProvider);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonWithImage(String label, String imagePath,
      Color bgColor, LanguageProvider langProvider) {
    return GestureDetector(
      onTap: () {
        if (label == 'Signaler un incident') {
          _showIncidentBottomSheet(langProvider);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 20.w,
              height: 20.h,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error_outline,
                    color: Colors.white, size: 20.sp);
              },
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonEdit(LanguageProvider langProvider) {
    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const ClientEditInscriptionScreen(),
          ),
        );
        // Si des données ont été modifiées, recharger le profil
        if (updated == true && mounted) {
          await Provider.of<AuthProvider>(context, listen: false).loadProfile();
          setState(() {}); // Rafraîchir l'affichage
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF7C39D3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.edit_outlined, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Modifier mon dossier',
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonQrScan(LanguageProvider langProvider) {
    return GestureDetector(
      onTap: () async {
        final validated = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const MissionQrScannerScreen(),
          ),
        );
        if (validated == true && mounted) {
          Provider.of<MissionProvider>(context, listen: false).fetchMissions();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0059AB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Scanner fin de mission',
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonGrey(
      String label, IconData icon, LanguageProvider langProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClientParametresScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16.sp),
          ],
        ),
      ),
    );
  }

  void _showRetourBottomSheet(LanguageProvider langProvider) {
    int _selectedStars = 0;
    final TextEditingController _commentController = TextEditingController();
    final TextEditingController _searchController = TextEditingController();
    bool _isSubmitting = false;
    final MissionService _missionService = MissionService();

    final missionProvider =
        Provider.of<MissionProvider>(context, listen: false);
    final allMissions = missionProvider.missions;
    MissionModel? _selectedMission;
    String _searchQuery = "";

    if (allMissions.length == 1) {
      _selectedMission = allMissions.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredMissions = allMissions.where((m) {
              final name = (m.structureName ?? "").toLowerCase();
              final date = m.horaireMission != null
                  ? DateFormat('dd/MM/yy')
                      .format(m.horaireMission!)
                      .toLowerCase()
                  : "";
              return name.contains(_searchQuery.toLowerCase()) ||
                  date.contains(_searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              langProvider.translate('send_feedback'),
                              style: getSourceSerifProStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: _primaryGreen,
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Sélection de la mission avec recherche
                          Text(
                            langProvider.translate('select_mission') ==
                                    'select_mission'
                                ? 'Sélectionner la mission'
                                : langProvider.translate('select_mission'),
                            style: getSourceSerifProStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) =>
                                  setModalState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText:
                                    langProvider.translate('search_mission') ??
                                        'Rechercher une mission...',
                                prefixIcon:
                                    Icon(Icons.search, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            height: 180.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: filteredMissions.isEmpty
                                ? Center(
                                    child: Text(langProvider
                                            .translate('no_mission_found') ??
                                        'Aucune mission trouvée'))
                                : ListView.separated(
                                    padding: EdgeInsets.all(8.w),
                                    itemCount: filteredMissions.length,
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                            height: 1, color: Colors.grey[100]),
                                    itemBuilder: (context, index) {
                                      final m = filteredMissions[index];
                                      final isSelected =
                                          _selectedMission?.id == m.id;
                                      final dateStr = m.horaireMission != null
                                          ? DateFormat('dd/MM/yy')
                                              .format(m.horaireMission!)
                                          : '';

                                      return InkWell(
                                        onTap: () => setModalState(
                                            () => _selectedMission = m),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w, vertical: 12.h),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? _primaryGreen.withOpacity(0.1)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8.w),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? _primaryGreen
                                                      : Colors.grey[100],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.business_center,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                  size: 16.sp,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      m.structureName ??
                                                          "Mission",
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight: isSelected
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        color: isSelected
                                                            ? _primaryGreen
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                    Text(
                                                      dateStr,
                                                      style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(Icons.check_circle,
                                                    color: _primaryGreen,
                                                    size: 20.sp),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          SizedBox(height: 24.h),
                          Text(
                            langProvider.translate('your_satisfaction'),
                            style: getSourceSerifProStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: _isSubmitting
                                    ? null
                                    : () {
                                        setModalState(() {
                                          _selectedStars = index + 1;
                                        });
                                      },
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  child: TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 300),
                                    tween: Tween(
                                        begin: 1.0,
                                        end:
                                            index < _selectedStars ? 1.2 : 1.0),
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Icon(
                                          index < _selectedStars
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          color: index < _selectedStars
                                              ? Colors.amber
                                              : Colors.grey[300],
                                          size: 40.sp,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            langProvider.translate('your_comment'),
                            style: getSourceSerifProStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: TextField(
                              controller: _commentController,
                              maxLines: 4,
                              enabled: !_isSubmitting,
                              decoration: InputDecoration(
                                hintText:
                                    langProvider.translate('feedback_hint'),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20.w),
                              ),
                              style: getSourceSerifProStyle(fontSize: 14.sp),
                            ),
                          ),
                          SizedBox(height: 32.h),
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ||
                                      _selectedStars == 0 ||
                                      _selectedMission == null
                                  ? null
                                  : () async {
                                      setModalState(() => _isSubmitting = true);
                                      try {
                                        final retourService = RetourService();
                                        await retourService.createRetour(
                                          missionId: _selectedMission!.id,
                                          note: _selectedStars,
                                          commentaire: _commentController.text.trim(),
                                        );
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(langProvider
                                                .translate('feedback_sent')),
                                            backgroundColor: _primaryGreen,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        );
                                      } catch (e) {
                                        setModalState(
                                            () => _isSubmitting = false);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Erreur: ${e.toString().replaceAll("Exception: ", "")}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryGreen,
                                foregroundColor: Colors.white,
                                shadowColor: _primaryGreen.withOpacity(0.3),
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              child: _isSubmitting
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      langProvider.translate('send_feedback'),
                                      style: getSourceSerifProStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showIncidentBottomSheet(LanguageProvider langProvider) {
    final TextEditingController _descriptionController =
        TextEditingController();
    final TextEditingController _searchController = TextEditingController();
    String? _selectedIncident;
    bool _isSubmitting = false;
    final Color _incidentOrange = Color(0xFFDA612B);
    final MissionService _missionService = MissionService();

    final missionProvider =
        Provider.of<MissionProvider>(context, listen: false);
    final allMissions = missionProvider.missions;
    MissionModel? _selectedMission;
    String _searchQuery = "";

    if (allMissions.length == 1) {
      _selectedMission = allMissions.first;
    }

    final List<String> _incidentTypes = [
      langProvider.translate('incident_professional_delay'),
      langProvider.translate('incident_quality_issue'),
      langProvider.translate('incident_equipment_failure'),
      langProvider.translate('incident_non_compliant_menu'),
      langProvider.translate('other'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredMissions = allMissions.where((m) {
              final name = (m.structureName ?? "").toLowerCase();
              final date = m.horaireMission != null
                  ? DateFormat('dd/MM/yy')
                      .format(m.horaireMission!)
                      .toLowerCase()
                  : "";
              return name.contains(_searchQuery.toLowerCase()) ||
                  date.contains(_searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              langProvider.translate('report_incident'),
                              style: getSourceSerifProStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: _incidentOrange,
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Sélection de la mission avec recherche
                          Text(
                            langProvider.translate('select_mission') ==
                                    'select_mission'
                                ? 'Sélectionner la mission'
                                : langProvider.translate('select_mission'),
                            style: getSourceSerifProStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) =>
                                  setModalState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText:
                                    langProvider.translate('search_mission') ??
                                        'Rechercher une mission...',
                                prefixIcon:
                                    Icon(Icons.search, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            height: 160.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: filteredMissions.isEmpty
                                ? Center(
                                    child: Text(langProvider
                                            .translate('no_mission_found') ??
                                        'Aucune mission trouvée'))
                                : ListView.separated(
                                    padding: EdgeInsets.all(8.w),
                                    itemCount: filteredMissions.length,
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                            height: 1, color: Colors.grey[100]),
                                    itemBuilder: (context, index) {
                                      final m = filteredMissions[index];
                                      final isSelected =
                                          _selectedMission?.id == m.id;
                                      final dateStr = m.horaireMission != null
                                          ? DateFormat('dd/MM/yy')
                                              .format(m.horaireMission!)
                                          : '';

                                      return InkWell(
                                        onTap: () => setModalState(
                                            () => _selectedMission = m),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w, vertical: 12.h),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? _incidentOrange
                                                    .withOpacity(0.1)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8.w),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? _incidentOrange
                                                      : Colors.grey[100],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.business_center,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                  size: 16.sp,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      m.structureName ??
                                                          "Mission",
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight: isSelected
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        color: isSelected
                                                            ? _incidentOrange
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                    Text(
                                                      dateStr,
                                                      style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(Icons.check_circle,
                                                    color: _incidentOrange,
                                                    size: 20.sp),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          SizedBox(height: 24.h),
                          Text(
                            langProvider.translate('incident_type'),
                            style: getSourceSerifProStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedIncident,
                                hint: Text(
                                  langProvider.translate('select_incident'),
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14.sp),
                                ),
                                isExpanded: true,
                                dropdownColor: Color(0xFF2C2C2C),
                                items: _incidentTypes
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.sp)),
                                        ))
                                    .toList(),
                                onChanged: _isSubmitting
                                    ? null
                                    : (val) => setModalState(
                                        () => _selectedIncident = val),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            langProvider.translate('description'),
                            style: getSourceSerifProStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: TextField(
                              controller: _descriptionController,
                              maxLines: 4,
                              enabled: !_isSubmitting,
                              decoration: InputDecoration(
                                hintText: langProvider
                                    .translate('incident_description_hint'),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20.w),
                              ),
                              style: getSourceSerifProStyle(fontSize: 14.sp),
                            ),
                          ),
                          SizedBox(height: 32.h),
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ||
                                      _selectedIncident == null ||
                                      _selectedMission == null
                                  ? null
                                  : () async {
                                      setModalState(() => _isSubmitting = true);
                                      try {
                                        final incidentService = IncidentService();
                                        await incidentService.createIncident(
                                          missionId: _selectedMission!.id,
                                          type: _selectedIncident!,
                                          description: _descriptionController.text.trim(),
                                          gravite: 'Moyenne',
                                        );
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(langProvider.translate(
                                                'incident_reported_success')),
                                            backgroundColor: _incidentOrange,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        );
                                      } catch (e) {
                                        setModalState(
                                            () => _isSubmitting = false);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Erreur: ${e.toString().replaceAll("Exception: ", "")}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _incidentOrange,
                                foregroundColor: Colors.white,
                                shadowColor: _incidentOrange.withOpacity(0.3),
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              child: _isSubmitting
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      langProvider.translate('send_report'),
                                      style: getSourceSerifProStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDeconnexionButton(LanguageProvider langProvider) {
    return GestureDetector(
      onTap: () {
        // Afficher un dialogue de confirmation
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(langProvider.translate('logout_confirmation_title')),
            content: Text(langProvider.translate('logout_confirmation_text')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(langProvider.translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  authProvider.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen2()),
                    (route) => false,
                  );
                },
                child: Text(langProvider.translate('logout_confirm'),
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Color(0xFFFCF3F2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.red,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              langProvider.translate('logout'),
              style: getSourceSerifProStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoriqueBody(
      LanguageProvider langProvider, String userName, User? user) {
    return Consumer<MissionProvider>(
      builder: (context, missionProvider, child) {
        if (missionProvider.isLoading && missionProvider.missions.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: CircularProgressIndicator(color: _primaryGreen),
            ),
          );
        }

        final historyMissions = missionProvider.missions.where((m) {
          final s = (m.status ?? '').toLowerCase().trim();
          return s == 'terminé' ||
              s == 'terminée' ||
              s == 'finished' ||
              s == 'validé' ||
              s == 'validée' ||
              s == 'validated' ||
              s == 'completed';
        }).toList();

        // Trier par date décroissante
        historyMissions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderWithStats(langProvider, userName, user),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      langProvider.translate('mission_history'),
                      style: getSourceSerifProStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (historyMissions.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.h),
                          child: Column(
                            children: [
                              Icon(Icons.history_outlined,
                                  size: 60.sp, color: Colors.grey[300]),
                              SizedBox(height: 16.h),
                              Text(
                                langProvider.translate('no_mission_yet'),
                                style: getSourceSerifProStyle(
                                    color: Colors.grey, fontSize: 16.sp),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...historyMissions.map((mission) {
                        // Construire le texte du menu
                        String menuText = "";
                        final mainRepas = mission.getMainRepas();
                        if (mainRepas != null) {
                          List<String> parts = [];
                          final entree = mainRepas.getDisplayName('entree');
                          final plat = mainRepas.getDisplayName('plat');
                          final acc =
                              mainRepas.getDisplayName('accompagnement');
                          final dessert = mainRepas.getDisplayName('dessert');

                          if (entree.isNotEmpty) parts.add(entree);
                          if (plat.isNotEmpty) parts.add(plat);
                          if (acc.isNotEmpty) parts.add(acc);
                          if (dessert.isNotEmpty) parts.add(dessert);

                          menuText = parts.join(' / ');
                        } else {
                          menuText =
                              langProvider.translate('menu_not_communicated');
                        }

                        // Formater les horaires
                        final String startTime = mission.horaireMission != null
                            ? DateFormat('HH:mm')
                                .format(mission.horaireMission!)
                                .replaceFirst(':', 'h')
                            : "7h30";
                        final String endTime = mission.heureFin != null
                            ? mission.heureFin!.replaceFirst(':', 'h')
                            : "16h00";

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _buildHistoriqueItem(
                            mission: mission,
                            name: mission.professionnelNom ??
                                langProvider.translate('professional'),
                            date: DateFormat(
                                    'd MMM yyyy', langProvider.currentLanguage)
                                .format(mission.horaireMission ??
                                    mission.createdAt),
                            comment: mission.commentaires ??
                                langProvider
                                    .translate('perfect_service_comment'),
                            menu: menuText,
                            residents: mission.nbResidentsJour.toString(),
                            horaires: '$startTime - $endTime',
                            langProvider: langProvider,
                          ),
                        );
                      }).toList(),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoriqueItem({
    required MissionModel mission,
    required String name,
    required String date,
    required String comment,
    required String menu,
    required String residents,
    required String horaires,
    required LanguageProvider langProvider,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec avatar et nom
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.grey[400],
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: getSourceSerifProStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    date,
                    style: getSourceSerifProStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Commentaire en gris clair avec texte en italique
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              comment,
              style: getSourceSerifProStyle(
                fontSize: 12.sp,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                langProvider.translate('menu_label') + ' : ',
                style: getSourceSerifProStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Expanded(
                child: Text(
                  menu,
                  style: getSourceSerifProStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // Résidents
          Row(
            children: [
              Text(
                langProvider.translate('residents') + ' : ',
                style: getSourceSerifProStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                residents,
                style: getSourceSerifProStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // Horaires
          Row(
            children: [
              Text(
                langProvider.translate('schedules_label') + ' : ',
                style: getSourceSerifProStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                horaires,
                style: getSourceSerifProStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Boutons : Chat (avec badge) + Voir le rapport
          Row(
            children: [
              // Bouton Chat avec badge
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MissionChatScreen(mission: mission),
                          ),
                        );
                      },
                      icon: Icon(Icons.chat_bubble_outline, size: 16.sp, color: _primaryGreen),
                      label: Text(
                        langProvider.translate('chat'),
                        style: getSourceSerifProStyle(
                          fontSize: 12.sp,
                          color: _primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _primaryGreen, width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                              mission.unreadMessagesCount > 99 ? '99+' : mission.unreadMessagesCount.toString(),
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
              SizedBox(width: 8.w),
              // Bouton Voir le rapport
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MissionDetailsScreen(mission: mission),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, color: _primaryGreen, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        langProvider.translate('see_full_report'),
                        style: getSourceSerifProStyle(
                          fontSize: 13.sp,
                          color: _primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                iconOutline: Icons.person_outline,
                iconFilled: Icons.person,
                label: langProvider.translate('profile'),
                index: 0,
                langProvider: langProvider,
              ),
              _buildNavItem(
                iconOutline: Icons.card_giftcard,
                iconFilled: Icons.card_giftcard,
                label: langProvider.translate('missions'),
                index: 1,
                langProvider: langProvider,
              ),
              _buildNavItem(
                iconOutline: Icons.add_circle_outline,
                iconFilled: Icons.add_circle,
                label: langProvider.translate('create_mission'),
                index: 2,
                langProvider: langProvider,
              ),
              _buildNavItem(
                iconOutline: Icons.menu_book,
                iconFilled: Icons.menu_book,
                label: langProvider.translate('history'),
                index: 3,
                langProvider: langProvider,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData iconOutline,
    required IconData iconFilled,
    required String label,
    required int index,
    required LanguageProvider langProvider,
    String? imagePath,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          imagePath != null
              ? Image.asset(
                  imagePath,
                  width: 26.sp,
                  height: 26.sp,
                  color: isSelected ? _primaryGreen : Colors.grey[400],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      isSelected ? iconFilled : iconOutline,
                      color: isSelected ? _primaryGreen : Colors.grey[400],
                      size: 26.sp,
                    );
                  },
                )
              : Icon(
                  isSelected ? iconFilled : iconOutline,
                  color: isSelected ? _primaryGreen : Colors.grey[400],
                  size: 26.sp,
                ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: getSourceSerifProStyle(
              fontSize: 11.sp,
              color: isSelected ? _primaryGreen : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter pour l'icône maison avec signe plus
class HouseWithPlusPainter extends CustomPainter {
  final Color color;

  HouseWithPlusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Dessiner la maison (toit)
    final roofPath = Path();
    roofPath.moveTo(size.width / 2, 0);
    roofPath.lineTo(size.width, size.height * 0.4);
    roofPath.lineTo(0, size.height * 0.4);
    roofPath.close();
    canvas.drawPath(roofPath, paint);

    // Dessiner le corps de la maison
    final housePath = Path();
    housePath.addRect(Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.4,
      size.width * 0.7,
      size.height * 0.55,
    ));
    canvas.drawPath(housePath, paint);

    // Dessiner le signe plus (blanc) au centre de la maison
    final plusPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height * 0.675;
    final plusWidth = size.width * 0.25;
    final plusThickness = size.height * 0.08;

    // Barre horizontale du plus
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: plusWidth,
        height: plusThickness,
      ),
      plusPaint,
    );

    // Barre verticale du plus
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: plusThickness,
        height: plusWidth,
      ),
      plusPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// CustomPainter pour l'icône maison avec croix médicale (gardé pour compatibilité)
class HouseWithCrossPainter extends CustomPainter {
  final Color color;

  HouseWithCrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Dessiner la maison (toit)
    final roofPath = Path();
    roofPath.moveTo(size.width / 2, 0);
    roofPath.lineTo(size.width, size.height * 0.4);
    roofPath.lineTo(0, size.height * 0.4);
    roofPath.close();
    canvas.drawPath(roofPath, paint);

    // Dessiner le corps de la maison
    final housePath = Path();
    housePath.addRect(Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.4,
      size.width * 0.7,
      size.height * 0.55,
    ));
    canvas.drawPath(housePath, paint);

    // Dessiner la croix médicale (blanche)
    final crossPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Barre horizontale de la croix
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.55),
        width: size.width * 0.35,
        height: size.height * 0.12,
      ),
      crossPaint,
    );

    // Barre verticale de la croix
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.55),
        width: size.height * 0.12,
        height: size.width * 0.35,
      ),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
