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
import 'admin_structure_detail_screen.dart';

class AdminGestionStructuresScreen extends StatefulWidget {
  const AdminGestionStructuresScreen({Key? key}) : super(key: key);

  @override
  _AdminGestionStructuresScreenState createState() =>
      _AdminGestionStructuresScreenState();
}

class _AdminGestionStructuresScreenState
    extends State<AdminGestionStructuresScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final Color _primaryPurple = const Color(0xFF7C39D3);
  final Color _lightPurple = const Color(0xFF9058D4);
  String _searchQuery = '';
  final AuthService _authService = AuthService();
  List<User> _structures = [];
  bool _isLoading = true;
  String _selectedType = 'Tous';
  String _selectedStatus = 'Tous';
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
    _loadStructures();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _lastLifecycleState != AppLifecycleState.resumed) {
      _loadStructures();
    }
    _lastLifecycleState = state;
  }

  Future<void> _loadStructures() async {
    setState(() => _isLoading = true);
    final structures = await _authService.getStructures();
    setState(() {
      _structures = structures;
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

  // Compter les structures en attente de validation
  int get _pendingValidationCount {
    return _structures
        .where((s) => s.statutValidation == 'en_attente')
        .length;
  }

  // Filtrer les structures selon la recherche + filtres
  List<User> get _filteredStructures {
    final query = _searchQuery.toLowerCase();
    return _structures.where((structure) {
      final matchesSearch = _searchQuery.isEmpty ||
          (structure.nomEtablissement ?? '').toLowerCase().contains(query) ||
          structure.fullName.toLowerCase().contains(query);

      final matchesType = _selectedType == 'Tous' ||
          (structure.typeEtablissement ?? '') == _selectedType;

      final matchesStatus = _selectedStatus == 'Tous' ||
          (_selectedStatus == 'Validé' && structure.statutValidation == 'valide') ||
          (_selectedStatus == 'À valider' && structure.statutValidation == 'en_attente') ||
          (_selectedStatus == 'Refusé' && structure.statutValidation == 'refuse');

      return matchesSearch && matchesType && matchesStatus;
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
                      '${_structures.length}',
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
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildStatCard(
                      '${_structures.length - _pendingValidationCount}',
                      'Actifs',
                      const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            // Filtres
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildFilterLabel('Catégories'),
                   _buildTypeFilters(),
                   SizedBox(height: 12.h),
                   _buildFilterLabel('Statuts'),
                   _buildStatusFilters(),
                ],
              ),
            ),
            // Liste
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: _primaryPurple),
                    )
                  : _filteredStructures.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.business_outlined,
                                    size: 64.sp, color: Colors.grey[400]),
                                SizedBox(height: 16.h),
                                Text(
                                  'Aucun site trouvé',
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
                          itemCount: _filteredStructures.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _buildStructureCard(
                                  _filteredStructures[index], langProvider),
                            );
                          },
                        ),
            ),
          ],
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
                        'Gestion des Sites',
                        style: getSourceSerifProStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Consumer2<NotificationProvider, MissionProvider>(
                      builder: (context, notifProvider, missionProvider, child) {
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  decoration: BoxDecoration(
                    color: _lightPurple.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un site...',
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

  Widget _buildTypeFilters() {
    final types = [
      'Tous',
      'EHPAD',
      'Résidence Autonomie',
      'Foyer-Logement',
      'Clinique',
      'Hôpital'
    ];
    return SizedBox(
      height: 38.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedType == types[index];
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(types[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedType = types[index]);
              },
              selectedColor: _primaryPurple.withOpacity(0.15),
              labelStyle: getSourceSerifProStyle(
                fontSize: 12.sp,
                color: isSelected ? _primaryPurple : Colors.black54,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color:
                        isSelected ? _primaryPurple : Colors.grey[300]!),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusFilters() {
    final statuses = ['Tous', 'À valider', 'Validé', 'Refusé'];
    return SizedBox(
      height: 38.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedStatus == statuses[index];
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(statuses[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedStatus = statuses[index]);
              },
              selectedColor: _primaryPurple.withOpacity(0.15),
              labelStyle: getSourceSerifProStyle(
                fontSize: 12.sp,
                color: isSelected ? _primaryPurple : Colors.black54,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color:
                        isSelected ? _primaryPurple : Colors.grey[300]!),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStructureCard(User structure, LanguageProvider langProvider) {
    final isPendingValidation =
        structure.statutValidation == 'en_attente';
    final isRefused = structure.statutValidation == 'refuse';

    return InkWell(
      onTap: () async {
        // Toujours recharger après retour du détail (validation OU modification des infos)
        await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => AdminStructureDetailScreen(
              structure: structure,
            ),
          ),
        );
        // Recharger dans tous les cas pour avoir les données fraîches
        _loadStructures();
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE7F6),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.business,
                  color: _primaryPurple, size: 26.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    structure.nomEtablissement ?? 'Sans nom',
                    style: getSourceSerifProStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${structure.typeEtablissement ?? ''} • ${structure.ville ?? ''}',
                    style: getSourceSerifProStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      if (isPendingValidation)
                        _buildBadge('À valider',
                            const Color(0xFFFFF3E0), const Color(0xFFE65100))
                      else if (isRefused)
                        _buildBadge('Refusé',
                            const Color(0xFFFFEBEE), const Color(0xFFC62828))
                      else
                        _buildBadge('Validé',
                            const Color(0xFFE8F5E9), const Color(0xFF4CAF50)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Colors.grey[400], size: 24.sp),
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

  Widget _buildFilterLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
      child: Text(
        label,
        style: getSourceSerifProStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
