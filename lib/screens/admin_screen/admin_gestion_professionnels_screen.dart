import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../providers/mission_provider.dart';
import '../../providers/notification_provider.dart';
import 'admin_incidents_screen.dart';
import 'admin_professionnel_detail_screen.dart';

class AdminGestionProfessionnelsScreen extends StatefulWidget {
  const AdminGestionProfessionnelsScreen({Key? key}) : super(key: key);

  @override
  _AdminGestionProfessionnelsScreenState createState() =>
      _AdminGestionProfessionnelsScreenState();
}

class _AdminGestionProfessionnelsScreenState
    extends State<AdminGestionProfessionnelsScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final Color _primaryPurple = const Color(0xFF7C39D3);
  final Color _lightPurple = const Color(0xFF9058D4);
  String _searchQuery = '';
  final AuthService _authService = AuthService();
  List<User> _professionals = [];
  bool _isLoading = true;
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
    _loadProfessionals();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _lastLifecycleState != AppLifecycleState.resumed) {
      _loadProfessionals();
    }
    _lastLifecycleState = state;
  }

  Future<void> _loadProfessionals() async {
    setState(() => _isLoading = true);
    final professionals = await _authService.getProfessionals();
    setState(() {
      _professionals = professionals;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  // Compter les professionnels en attente de validation
  int get _pendingValidationCount {
    return _professionals
        .where((p) => p.statutValidation == 'en_attente')
        .length;
  }

  // Compter les professionnels en mission
  int get _onMissionCount {
    return _professionals.where((p) => p.currentMission != null).length;
  }

  // Filtrer les professionnels selon la recherche uniquement
  List<User> get _filteredProfessionals {
    if (_searchQuery.isEmpty) return _professionals;
    
    final query = _searchQuery.toLowerCase();
    return _professionals.where((professional) {
      return professional.fullName.toLowerCase().contains(query) ||
          (professional.fonctionPrincipale ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Column(
          children: [
            _buildHeader(langProvider),
            // Stats
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '${_professionals.length}',
                      'Total',
                      _primaryPurple,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildStatCard(
                      '$_pendingValidationCount',
                      'À valider',
                      const Color(0xFFFFA000),
                    ),
                  ),
                ],
              ),
            ),
            // Liste
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: _primaryPurple),
                    )
                  : _filteredProfessionals.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64.sp, color: Colors.grey[400]),
                                SizedBox(height: 16.h),
                                Text(
                                  langProvider
                                      .translate('no_professional_found'),
                                  style: getSourceSerifProStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                          itemCount: _filteredProfessionals.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _buildProfessionalCard(
                                  _filteredProfessionals[index], langProvider),
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: _primaryPurple,
          child: Icon(Icons.add, color: Colors.white, size: 28.sp),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: _primaryPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
      child: Column(
        children: [
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
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Bouton retour
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18.sp),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Gestion des Professionnels',
                        style: getSourceSerifProStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Consumer2<NotificationProvider, MissionProvider>(
                      builder: (context, notifProvider, missionProvider, child) {
                        // Icône notifications retirée
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Barre de recherche
                Container(
                  decoration: BoxDecoration(
                    color: _lightPurple.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: langProvider
                          .translate('search_professional_hint'),
                      hintStyle: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.white.withOpacity(0.9), size: 22.sp),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                    ),
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color valueColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: getSourceSerifProStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: getSourceSerifProStyle(
              fontSize: 11.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildProfessionalCard(
      User professional, LanguageProvider langProvider) {
    final currentMission = professional.currentMission;
    final isOnMission = currentMission != null;
    final isPendingValidation =
        professional.statutValidation == 'en_attente';

    return InkWell(
      onTap: () async {
        // Naviguer vers le détail et rafraîchir si validation effectuée
        final refreshed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => AdminProfessionnelDetailScreen(
              professional: professional,
            ),
          ),
        );
        if (refreshed == true) {
          _loadProfessionals();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                // Avatar
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE7F6),
                    shape: BoxShape.circle,
                  ),
                  child: professional.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            professional.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.person_outline,
                                    color: _primaryPurple, size: 26.sp),
                          ),
                        )
                      : Icon(Icons.person_outline,
                          color: _primaryPurple, size: 26.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        professional.fullName,
                        style: getSourceSerifProStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        professional.displayFunction,
                        style: getSourceSerifProStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (isPendingValidation) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            _buildBadge('À valider', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: Colors.grey[400], size: 24.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: getSourceSerifProStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
