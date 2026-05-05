import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/font_helper.dart';
import '../../models/formation_model.dart';
import '../../services/formation_service.dart';
import 'admin_create_formation_screen.dart';

class AdminFormationsScreen extends StatefulWidget {
  const AdminFormationsScreen({Key? key}) : super(key: key);

  @override
  _AdminFormationsScreenState createState() => _AdminFormationsScreenState();
}

class _AdminFormationsScreenState extends State<AdminFormationsScreen> {
  final Color _primaryPurple = const Color(0xFF7C39D3);
  final FormationService _formationService = FormationService();
  List<FormationModel> _formations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchFormations();
  }

  Future<void> _fetchFormations() async {
    setState(() => _isLoading = true);
    try {
      final formations = await _formationService.getFormations();
      setState(() {
        _formations = formations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    final filteredFormations = _formations.where((f) {
      final query = _searchQuery.toLowerCase();
      return f.titre.toLowerCase().contains(query) || 
             (f.typeFormation ?? '').toLowerCase().contains(query);
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            _buildHeader(lang),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : filteredFormations.isEmpty
                  ? Center(child: Text(lang.translate('no_training_yet') == 'no_training_yet' ? 'Aucune formation trouvée' : lang.translate('no_training_yet')))
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: filteredFormations.length,
                      itemBuilder: (context, index) {
                        final formation = filteredFormations[index];
                        return _buildFormationCard(formation, lang);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider lang) {
    return Container(
      decoration: BoxDecoration(
        color: _primaryPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      child: Column(
        children: [
          // Trait horizontal standard
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          SizedBox(height: 12.h),
          // Titre et Action
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  lang.translate('trainings_management'),
                  textAlign: TextAlign.center,
                  style: getSourceSerifProStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminCreateFormationScreen()),
                  );
                  if (result == true) _fetchFormations();
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Barre de recherche
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: lang.translate('search'),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14.sp),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.white70, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormationCard(FormationModel formation, LanguageProvider lang) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  formation.titre,
                  style: getSourceSerifProStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
              ),
              _buildTypeBadge(formation.typeFormation),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.video_collection_outlined, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text("ID: ${formation.videoUrl ?? 'Non défini'}", style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              SizedBox(width: 16.w),
              Icon(Icons.timer_outlined, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(formation.duree ?? 'N/A', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text("Assigné à ID Pro: ${formation.professionnelId ?? 'Tous'}", style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Supprimer la formation'),
                      content: Text('Voulez-vous vraiment supprimer "${formation.titre}" ?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULER')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _formationService.deleteFormation(formation.id);
                    _fetchFormations();
                  }
                }, 
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20)
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminCreateFormationScreen(formationToEdit: formation)),
                  );
                  if (result == true) _fetchFormations();
                },
                child: Text(lang.translate('edit'), style: TextStyle(color: _primaryPurple)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color = type.toLowerCase() == 'obligatoire' ? Colors.red : Colors.green;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(type.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10.sp)),
    );
  }
}
