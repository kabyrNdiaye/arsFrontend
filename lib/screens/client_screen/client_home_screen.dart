import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import '../auth/login_screen_2.dart';
import 'client_parametres_screen.dart';
import 'client_missions_screen.dart';

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
          _buildBody(langProvider), // Profil (index 0)
          ClientMissionsScreen(
            userName: widget.userName,
            etablissementName: widget.etablissementName,
          ), // Missions (index 1)
          _buildHistoriqueBody(langProvider), // Historique (index 2)
        ],
      ),
      bottomNavigationBar: _buildBottomNav(langProvider),
      ),
    );
  }

  Widget _buildBody(LanguageProvider langProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderWithStats(langProvider),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildInformationsSection(langProvider),
                SizedBox(height: 16.h),
                _buildDocumentsSection(langProvider),
                SizedBox(height: 16.h),
                _buildActionsSection(langProvider),
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

  Widget _buildHeaderWithStats(LanguageProvider langProvider) {
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
                              painter: HouseWithPlusPainter(color: _primaryGreen),
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
                        widget.etablissementName ?? 'EHPAD Les Jardins',
                        style: getSourceSerifProStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.userName ?? 'Marie Dubois',
                        style: getSourceSerifProStyle(
                          fontSize: 15.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      // Badge Directrice en vert clair
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Color(0xFF6ABF6E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
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
                // Icône notification avec badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: _primaryGreen, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '2',
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
              ],
            ),
            SizedBox(height: 16.h),
            // Stats section avec cartes individuelles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100.w,
                  child: _buildStatCard('48', langProvider.translate('missions')),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 100.w,
                  child: _buildStatCard('115', langProvider.translate('residents')),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 100.w,
                  child: _buildStatCard('12', langProvider.translate('chefs')),
                ),
              ],
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

  Widget _buildInformationsSection(LanguageProvider langProvider) {
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
                    return Icon(Icons.bar_chart, color: _emailColor, size: 16.sp);
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
            '45 Avenue de la République, 75011 Paris',
            _addressColor,
            Color(0xFFFFEBEE),
          ),
          _buildSeparator(),
          // Téléphone
          _buildInfoRowWithBg(
            Icons.phone,
            langProvider.translate('phone_label'),
            '+33 1 42 45 67 89',
            _phoneColor,
            _lightGreen,
          ),
          _buildSeparator(),
          // Email
          _buildInfoRowWithBg(
            Icons.email,
            langProvider.translate('email'),
            widget.userEmail ?? 'm.dubois@ehpad.fr',
            _emailColor,
            Color(0xFFE3F2FD),
          ),
          _buildSeparator(),
          // Capacité
          _buildInfoRowWithBg(
            Icons.people,
            langProvider.translate('capacity'),
            '120 ' + langProvider.translate('residents'),
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

  Widget _buildInfoRowWithBg(IconData icon, String label, String value, Color iconColor, Color bgColor) {
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

  Widget _buildDocumentsSection(LanguageProvider langProvider) {
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
                  color: Color(0xFFFFEBEE),
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
          _buildDocumentRowStyled(langProvider.translate('service_contract'), '2.4 MB', langProvider),
          _buildDocSeparator(),
          _buildDocumentRowStyled(langProvider.translate('premises_plan'), '1.8 MB', langProvider),
          _buildDocSeparator(),
          _buildDocumentRowStyled(langProvider.translate('kitchen_plan'), '956 KB', langProvider),
          _buildDocSeparator(),
          _buildDocumentRowStyled(langProvider.translate('internal_rules'), '1.2 MB', langProvider),
          _buildDocSeparator(),
          _buildDocumentRowStyled(langProvider.translate('safety_instructions'), '890 KB', langProvider),
        ],
      ),
    );
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

  Widget _buildDocumentRowStyled(String title, String size, LanguageProvider langProvider) {
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
        // Bouton téléchargement
        Container(
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
      ],
    );
  }

  Widget _buildActionsSection(LanguageProvider langProvider) {
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
            'Actions',
            style: getSourceSerifProStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 14.h),
          // Bouton Envoyer un retour (vert)
          _buildActionButton(
            'Envoyer un retour',
            Icons.chat_bubble_outline,
            _primaryGreen,
            langProvider,
          ),
          SizedBox(height: 10.h),
          // Bouton Signaler un incident (orange)
          _buildActionButtonWithImage(
            'Signaler un incident',
            'assets/images/icon_incident.png',
            _orangeColor,
            langProvider,
          ),
          SizedBox(height: 10.h),
          // Bouton Paramètres (gris)
          _buildActionButtonGrey(
            'Paramètres',
            Icons.settings_outlined,
            langProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bgColor, LanguageProvider langProvider) {
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

  Widget _buildActionButtonWithImage(String label, String imagePath, Color bgColor, LanguageProvider langProvider) {
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
                return Icon(Icons.error_outline, color: Colors.white, size: 20.sp);
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

  Widget _buildActionButtonGrey(String label, IconData icon, LanguageProvider langProvider) {
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
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barre de drag
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Titre
                    Center(
                      child: Text(
                        langProvider.translate('send_feedback'),
                        style: getSourceSerifProStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Votre satisfaction
                    Text(
                      langProvider.translate('your_satisfaction'),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Étoiles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedStars = index + 1;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Icon(
                              index < _selectedStars ? Icons.star : Icons.star_border,
                              color: index < _selectedStars ? Colors.amber : Colors.grey[400],
                              size: 32.sp,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 24.h),
                    // Votre commentaire
                    Text(
                      langProvider.translate('your_comment'),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Zone de texte
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: langProvider.translate('feedback_hint'),
                          hintStyle: getSourceSerifProStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16.w),
                        ),
                        style: getSourceSerifProStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Bouton Envoyer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(langProvider.translate('feedback_sent')),
                              backgroundColor: _primaryGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          langProvider.translate('send_feedback'),
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showIncidentBottomSheet(LanguageProvider langProvider) {
    final TextEditingController _descriptionController = TextEditingController();
    String? _selectedIncident;
    final Color _incidentOrange = Color(0xFFDA612B);
    final Color _selectedBlue = Color(0xFF6399E5);
    
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
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barre de drag
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Titre
                    Center(
                      child: Text(
                        langProvider.translate('report_incident'),
                        style: getSourceSerifProStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Type Incident
                    Text(
                      langProvider.translate('incident_type'),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Dropdown
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Color(0xFF676765), // Fond gris foncé
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedIncident,
                          hint: Text(
                            langProvider.translate('select_incident'),
                            style: getSourceSerifProStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                          dropdownColor: Color(0xFF676765), // Fond gris foncé pour la liste
                          borderRadius: BorderRadius.circular(8),
                          menuMaxHeight: 250.h,
                          items: _incidentTypes.map((String type) {
                            final bool isSelected = _selectedIncident == type;
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                                decoration: isSelected ? BoxDecoration(
                                  color: Color(0xFFDEEAFC), // Fond bleu clair pour l'option sélectionnée
                                  borderRadius: BorderRadius.circular(4),
                                ) : null,
                                child: Row(
                                  children: [
                                    if (isSelected) ...[
                                      Icon(Icons.check, color: Colors.white, size: 18.sp),
                                      SizedBox(width: 8.w),
                                    ],
                                    Expanded(
                                      child: Text(
                                        type,
                                        style: getSourceSerifProStyle(
                                          fontSize: 14.sp,
                                          color: isSelected ? Color(0xFF0059AB) : Colors.white, // Bleu pour sélectionné, blanc pour les autres
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return _incidentTypes.map<Widget>((String type) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  type,
                                  style: getSourceSerifProStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (String? newValue) {
                            setModalState(() {
                              _selectedIncident = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Description
                    Text(
                      langProvider.translate('description'),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Zone de texte
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Décrivez l\'incident en détail...',
                              hintStyle: getSourceSerifProStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12.w),
                            ),
                            style: getSourceSerifProStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          ),
                          Positioned(
                            bottom: 8.h,
                            right: 8.w,
                            child: Icon(
                              Icons.edit_outlined,
                              color: Colors.grey[400],
                              size: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Bouton Envoyer le signalement
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(langProvider.translate('incident_reported_success')),
                              backgroundColor: _incidentOrange,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _incidentOrange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              langProvider.translate('send_report'),
                              style: getSourceSerifProStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen2()),
          (route) => false,
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

  Widget _buildHistoriqueBody(LanguageProvider langProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderWithStats(langProvider),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                // Revenir sur le titre de la section
                Text(
                  langProvider.translate('mission_history'),
                  style: getSourceSerifProStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                // Historique items
                _buildHistoriqueItem(
                  name: 'Thomas Martin',
                  date: '15 Nov 2025',
                  comment: langProvider.translate('perfect_service_comment'),
                  menu: 'Salade vert / Poulet basquaise / Haricots vert / Mousse au chocolat',
                  residents: '118',
                  horaires: '7h30 - 16h15',
                  langProvider: langProvider,
                ),
                SizedBox(height: 16.h),
                _buildHistoriqueItem(
                  name: 'Sophie Bernard',
                  date: '12 Nov 2025',
                  comment: langProvider.translate('perfect_service_comment'),
                  menu: 'Potage / Boeuf / Riz / Fruit',
                  residents: '115',
                  horaires: '8h00 - 16h30',
                  langProvider: langProvider,
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriqueItem({
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
          // Bouton Voir le rapport complet en vert
          GestureDetector(
            onTap: () {
              // TODO: Voir le rapport
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  color: _primaryGreen,
                  size: 18.sp,
                ),
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
                iconOutline: Icons.menu_book,
                iconFilled: Icons.menu_book,
                label: langProvider.translate('history'),
                index: 2,
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
