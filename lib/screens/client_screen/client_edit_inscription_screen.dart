import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../utils/font_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/user_model.dart';

class ClientEditInscriptionScreen extends StatefulWidget {
  const ClientEditInscriptionScreen({Key? key}) : super(key: key);

  @override
  _ClientEditInscriptionScreenState createState() =>
      _ClientEditInscriptionScreenState();
}

class _ClientEditInscriptionScreenState
    extends State<ClientEditInscriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers infos établissement
  late TextEditingController _nomEtablissementController;
  late TextEditingController _adresseController;
  late TextEditingController _codePostalController;
  late TextEditingController _villeController;
  late TextEditingController _telephoneEtablissementController;
  late TextEditingController _capaciteController;

  // Controllers infos responsable
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _fonctionController;

  String? _selectedTypeEtablissement;

  // Documents
  _DocumentFile? _contratFile;
  _DocumentFile? _planLocauxFile;
  _DocumentFile? _reglementFile;

  // URLs actuelles des documents (pour affichage)
  String? _currentContratUrl;
  String? _currentPlanLocauxUrl;
  String? _currentReglementUrl;

  bool _isSaving = false;

  final Color _primaryGreen = const Color(0xFF4CA054);
  final Color _lightGreen = const Color(0xFFE8F5E9);

  final List<String> _typesEtablissement = [
    'EHPAD',
    'Résidence Autonomie',
    'Foyer-Logement',
    'Clinique',
    'Hôpital',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _initControllers(user);
  }

  void _initControllers(User? user) {
    _nomEtablissementController =
        TextEditingController(text: user?.nomEtablissement ?? '');
    _adresseController =
        TextEditingController(text: user?.adresse ?? user?.address ?? '');
    _codePostalController =
        TextEditingController(text: user?.codePostal ?? '');
    _villeController = TextEditingController(text: user?.ville ?? '');
    _telephoneEtablissementController =
        TextEditingController(text: user?.telephoneEtablissement ?? '');
    _capaciteController =
        TextEditingController(text: user?.capacite ?? '');
    _firstNameController =
        TextEditingController(text: user?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _fonctionController =
        TextEditingController(text: user?.fonction ?? '');

    _selectedTypeEtablissement = user?.typeEtablissement;

    // URLs actuelles
    _currentContratUrl = user?.contratPrestationPath;
    _currentPlanLocauxUrl = user?.planLocauxPath;
    _currentReglementUrl = user?.reglementInterieurPath;
  }

  @override
  void dispose() {
    _nomEtablissementController.dispose();
    _adresseController.dispose();
    _codePostalController.dispose();
    _villeController.dispose();
    _telephoneEtablissementController.dispose();
    _capaciteController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fonctionController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(String type) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final docFile = _DocumentFile(
          name: file.name,
          bytes: file.bytes,
          path: file.path,
        );

        setState(() {
          switch (type) {
            case 'contrat':
              _contratFile = docFile;
              break;
            case 'plan':
              _planLocauxFile = docFile;
              break;
            case 'reglement':
              _reglementFile = docFile;
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection du fichier : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final Map<String, dynamic> data = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'adresse': _adresseController.text.trim(),
      'nom_etablissement': _nomEtablissementController.text.trim(),
      'type_etablissement': _selectedTypeEtablissement ?? '',
      'code_postal': _codePostalController.text.trim(),
      'ville': _villeController.text.trim(),
      'telephone_etablissement': _telephoneEtablissementController.text.trim(),
      'capacite': _capaciteController.text.trim(),
      'fonction': _fonctionController.text.trim(),
    };

    // Ajouter les fichiers si sélectionnés
    if (_contratFile != null) {
      data['contrat_prestation_path'] = _contratFile!.toUploadData();
    }
    if (_planLocauxFile != null) {
      data['plan_locaux_path'] = _planLocauxFile!.toUploadData();
    }
    if (_reglementFile != null) {
      data['reglement_interieur_path'] = _reglementFile!.toUploadData();
    }

    final success = await authProvider.updateProfile(data);

    setState(() => _isSaving = false);

    if (!mounted) return;

    // DEBUG
    User.debugLog('=== EDIT INSCRIPTION RESULT ===');
    User.debugLog('success: $success');
    User.debugLog('errorMessage: ${authProvider.errorMessage}');
    User.debugLog('user after update: ${authProvider.user?.nomEtablissement}');
    User.debugLog('================================');

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Informations mises à jour avec succès ✓',
            style: getSourceSerifProStyle(
                fontSize: 14.sp, color: Colors.white),
          ),
          backgroundColor: _primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); // true = données modifiées
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Erreur lors de la mise à jour',
            style:
                getSourceSerifProStyle(fontSize: 14.sp, color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 40.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section établissement
                      _buildSectionTitle(
                          'Informations de l\'établissement', Icons.business),
                      SizedBox(height: 12.h),
                      _buildCard(children: [
                        _buildTextField(
                          controller: _nomEtablissementController,
                          label: 'Nom de l\'établissement',
                          icon: Icons.business_outlined,
                          required: true,
                        ),
                        SizedBox(height: 14.h),
                        _buildDropdown(),
                        SizedBox(height: 14.h),
                        _buildTextField(
                          controller: _adresseController,
                          label: 'Adresse',
                          icon: Icons.location_on_outlined,
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: _buildTextField(
                                controller: _codePostalController,
                                label: 'Code postal',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 5,
                              child: _buildTextField(
                                controller: _villeController,
                                label: 'Ville',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        _buildTextField(
                          controller: _telephoneEtablissementController,
                          label: 'Téléphone établissement',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 14.h),
                        _buildTextField(
                          controller: _capaciteController,
                          label: 'Capacité (résidents)',
                          icon: Icons.people_outline,
                          keyboardType: TextInputType.number,
                        ),
                      ]),

                      SizedBox(height: 20.h),

                      // Section responsable
                      _buildSectionTitle(
                          'Informations du responsable', Icons.person_outline),
                      SizedBox(height: 12.h),
                      _buildCard(children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _firstNameController,
                                label: 'Prénom',
                                required: true,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildTextField(
                                controller: _lastNameController,
                                label: 'Nom',
                                required: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          required: true,
                          isEmail: true,
                        ),
                        SizedBox(height: 14.h),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Téléphone',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 14.h),
                        _buildTextField(
                          controller: _fonctionController,
                          label: 'Fonction',
                          icon: Icons.badge_outlined,
                        ),
                      ]),

                      SizedBox(height: 20.h),

                      // Section documents
                      _buildSectionTitle('Documents', Icons.description_outlined),
                      SizedBox(height: 12.h),
                      _buildCard(children: [
                        _buildDocumentRow(
                          label: 'Contrat de prestation',
                          type: 'contrat',
                          currentUrl: _currentContratUrl,
                          selectedFile: _contratFile,
                        ),
                        Divider(height: 24.h, color: Colors.grey[100]),
                        _buildDocumentRow(
                          label: 'Plan des locaux',
                          type: 'plan',
                          currentUrl: _currentPlanLocauxUrl,
                          selectedFile: _planLocauxFile,
                        ),
                        Divider(height: 24.h, color: Colors.grey[100]),
                        _buildDocumentRow(
                          label: 'Règlement intérieur',
                          type: 'reglement',
                          currentUrl: _currentReglementUrl,
                          selectedFile: _reglementFile,
                        ),
                      ]),

                      SizedBox(height: 32.h),

                      // Bouton sauvegarder
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSaving
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Enregistrer les modifications',
                                  style: getSourceSerifProStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
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

  Widget _buildHeader() {
    return Container(
      color: _primaryGreen,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top > 0 ? 8.h : 24.h,
                left: 12.w,
                right: 12.w,
              ),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              child: Row(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modifier mon dossier',
                          style: getSourceSerifProStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Informations & documents',
                          style: getSourceSerifProStyle(
                            fontSize: 12.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isSaving)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  else
                    GestureDetector(
                      onTap: _save,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sauvegarder',
                          style: getSourceSerifProStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _primaryGreen, size: 18.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: getSourceSerifProStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
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
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label *' : label,
          style: getSourceSerifProStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: _primaryGreen.withOpacity(0.6), size: 18.sp)
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _primaryGreen, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return 'Ce champ est requis';
            }
            if (isEmail &&
                value != null &&
                value.isNotEmpty &&
                !value.contains('@')) {
              return 'Email invalide';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type d\'établissement',
          style: getSourceSerifProStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: _typesEtablissement.contains(_selectedTypeEtablissement)
              ? _selectedTypeEtablissement
              : null,
          hint: Text(
            'Sélectionner un type',
            style: getSourceSerifProStyle(
                fontSize: 14.sp, color: Colors.grey[400]),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _primaryGreen, width: 1.5),
            ),
          ),
          items: _typesEtablissement
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(
                      type,
                      style: getSourceSerifProStyle(
                          fontSize: 14.sp, color: Colors.black87),
                    ),
                  ))
              .toList(),
          onChanged: (value) =>
              setState(() => _selectedTypeEtablissement = value),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          isExpanded: true,
          style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildDocumentRow({
    required String label,
    required String type,
    String? currentUrl,
    _DocumentFile? selectedFile,
  }) {
    final bool hasExisting = currentUrl != null && currentUrl.isNotEmpty;
    final bool hasNew = selectedFile != null;

    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: hasNew
                ? _lightGreen
                : hasExisting
                    ? const Color(0xFFE3F2FD)
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.description_outlined,
            color: hasNew
                ? _primaryGreen
                : hasExisting
                    ? const Color(0xFF1565C0)
                    : Colors.grey[400],
            size: 18.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: getSourceSerifProStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                hasNew
                    ? selectedFile!.name
                    : hasExisting
                        ? 'Document existant'
                        : 'Aucun document',
                style: getSourceSerifProStyle(
                  fontSize: 11.sp,
                  color: hasNew
                      ? _primaryGreen
                      : hasExisting
                          ? Colors.grey[500]
                          : Colors.grey[400],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () => _pickDocument(type),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hasNew || hasExisting ? 'Changer' : 'Ajouter',
              style: getSourceSerifProStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _primaryGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Classe utilitaire pour gérer un fichier sélectionné
class _DocumentFile {
  final String name;
  final Uint8List? bytes;
  final String? path;

  _DocumentFile({required this.name, this.bytes, this.path});

  /// Retourne les données dans le format attendu par AuthService.updateProfile
  dynamic toUploadData() {
    if (bytes != null) {
      return {'bytes': bytes, 'name': name};
    }
    if (path != null) {
      return path;
    }
    return null;
  }
}
