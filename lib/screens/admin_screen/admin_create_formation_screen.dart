import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/font_helper.dart';
import '../../models/formation_model.dart';
import '../../models/user_model.dart';
import '../../services/formation_service.dart';
import '../../services/auth_service.dart';

class AdminCreateFormationScreen extends StatefulWidget {
  final FormationModel? formationToEdit;
  const AdminCreateFormationScreen({Key? key, this.formationToEdit})
      : super(key: key);

  @override
  _AdminCreateFormationScreenState createState() =>
      _AdminCreateFormationScreenState();
}

class _AdminCreateFormationScreenState
    extends State<AdminCreateFormationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryPurple = const Color(0xFF7C39D3);
  bool _isLoading = false;
  bool _isLoadingPros = true;

  late TextEditingController _titleController;
  late TextEditingController _videoController;
  late TextEditingController _durationController;

  String _selectedType = 'recommandée';
  final List<String> _types = ['obligatoire', 'recommandée'];

  List<User> _professionals = [];
  int? _selectedProId;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.formationToEdit?.titre ?? '');
    _videoController =
        TextEditingController(text: widget.formationToEdit?.videoUrl ?? '');
    _durationController =
        TextEditingController(text: widget.formationToEdit?.duree ?? '');
    _selectedType = widget.formationToEdit?.typeFormation ?? 'recommandée';
    _selectedProId = widget.formationToEdit?.professionnelId;

    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    try {
      final pros = await AuthService().getProfessionals();
      setState(() {
        _professionals = pros;
        _isLoadingPros = false;
      });
    } catch (e) {
      setState(() => _isLoadingPros = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _videoController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  String? _extractYoutubeId(String url) {
    if (url.length == 11) return url; // Already an ID
    final regExp = RegExp(
      r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  Future<void> _saveFormation() async {
    if (!_formKey.currentState!.validate()) return;

    final youtubeId = _extractYoutubeId(_videoController.text);
    if (youtubeId == null || youtubeId.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('ID YouTube invalide (doit être 11 caractères)')));
      return;
    }

    setState(() => _isLoading = true);

    final formationData = {
      'titre': _titleController.text,
      'type_formation': _selectedType,
      'video_url': youtubeId,
      'duree': _durationController.text,
      'professionnel_id': _selectedProId,
      'statutValidation':
          widget.formationToEdit?.statutValidation ?? 'A compléter',
    };

    try {
      if (widget.formationToEdit != null) {
        await FormationService()
            .updateFormation(widget.formationToEdit!.id, formationData);
      } else {
        await FormationService().createFormation(formationData);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildHeader() {
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
          Padding(
            padding: EdgeInsets.only(
                top: 16.h, left: 12.w, right: 12.w, bottom: 20.h),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.formationToEdit != null
                        ? 'Modifier la formation'
                        : 'Nouvelle formation',
                    textAlign: TextAlign.center,
                    style: getSourceSerifProStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)),
                  )
                else
                  TextButton(
                    onPressed: _saveFormation,
                    child: const Text('ENREGISTRER',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(_titleController, 'Titre de la formation',
                          Icons.school,
                          validator: (v) => v!.isEmpty ? 'Requis' : null),
                      SizedBox(height: 16.h),
                      _buildTextField(_videoController,
                          'Lien YouTube ou ID (Clé)', Icons.play_circle_fill,
                          helperText: 'Ex: aqz-KE-BPKQ ou URL complète'),
                      SizedBox(height: 16.h),
                      _buildTextField(
                          _durationController, 'Durée estimée', Icons.timer,
                          helperText: 'Ex: 15 min'),
                      SizedBox(height: 16.h),
                      _buildTypeDropdown(),
                      SizedBox(height: 24.h),
                      Text('Assigner à un professionnel',
                          style: getSourceSerifProStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: _primaryPurple)),
                      SizedBox(height: 12.h),
                      _buildProfessionalDropdown(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {String? helperText, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20.sp),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type de formation',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              items: _types
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                  .toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
          ),
        ),
      ],
    );
  }

  void _showProfessionalSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Rechercher un professionnel...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                _searchQuery = val;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: controller,
                            itemCount: _professionals
                                    .where((pro) => pro.fullName
                                        .toLowerCase()
                                        .contains(_searchQuery.toLowerCase()))
                                    .length +
                                1,
                            itemBuilder: (context, index) {
                              final filtered = _professionals
                                  .where((pro) => pro.fullName
                                      .toLowerCase()
                                      .contains(_searchQuery.toLowerCase()))
                                  .toList();
                              
                              if (index == 0) {
                                return ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.people, color: Colors.white),
                                  ),
                                  title: const Text('Tous (Formation générale)'),
                                  selected: _selectedProId == null,
                                  onTap: () {
                                    setState(() => _selectedProId = null);
                                    Navigator.pop(context);
                                  },
                                );
                              }
                              final pro = filtered[index - 1];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _primaryPurple.withOpacity(0.1),
                                  child: Text(pro.fullName.substring(0, 1).toUpperCase(),
                                      style: TextStyle(color: _primaryPurple)),
                                ),
                                title: Text(pro.fullName),
                                selected: _selectedProId == pro.professionnelId,
                                onTap: () {
                                  setState(() => _selectedProId = pro.professionnelId);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _searchQuery = '';

  Widget _buildProfessionalDropdown() {
    if (_isLoadingPros) return const Center(child: CircularProgressIndicator());

    String proName = 'Tous (Formation générale)';
    if (_selectedProId != null) {
      try {
        proName = _professionals.firstWhere((p) => p.professionnelId == _selectedProId).fullName;
      } catch (_) {}
    }

    return InkWell(
      onTap: _showProfessionalSearch,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
        decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                proName,
                style: TextStyle(fontSize: 14.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
