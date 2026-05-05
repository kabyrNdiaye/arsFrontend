import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'inscription_client_step3_screen.dart';

class InscriptionClientStep2Screen extends StatefulWidget {
  final Map<String, dynamic>? step1Data;
  
  const InscriptionClientStep2Screen({Key? key, this.step1Data}) : super(key: key);
  
  @override
  _InscriptionClientStep2ScreenState createState() => _InscriptionClientStep2ScreenState();
}

class _InscriptionClientStep2ScreenState extends State<InscriptionClientStep2Screen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _fonctionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Couleur verte principale
  final Color _primaryGreen = Color(0xFF4CA054);
  final Color _lightGreen = Color(0xFFE8F5E9);

  // Photo de profil (optionnelle)
  String? _selectedPhotoPath;
  Uint8List? _selectedPhotoBytes;

  Future<void> _pickPhoto() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedPhotoPath = result.files.single.name;
          _selectedPhotoBytes = result.files.single.bytes;
        });
      }
    } catch (e) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('photo_pick_error')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _fonctionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final lang = Provider.of<LanguageProvider>(context);
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isIPad = shortestSide >= 600 && shortestSide <= 1024;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(lang),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isIPad ? 40.w : 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: isIPad ? 40.h : 30.h),
                            
                            // Icône maison
                            Container(
                              width: isIPad ? 80.w : 70.w,
                              height: isIPad ? 80.h : 70.h,
                              decoration: BoxDecoration(
                                color: _lightGreen,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/icon_client.png',
                                  color: _primaryGreen,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: isIPad ? 24.h : 20.h),
                            
                            // Titre
                            Text(
                              lang.translate('responsible_title'),
                              style: getSourceSerifProStyle(
                                fontSize: isIPad ? 22.sp : 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            // Sous-titre
                            Text(
                              lang.translate('responsible_coords'),
                              style: getSourceSerifProStyle(
                                fontSize: isIPad ? 14.sp : 13.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: isIPad ? 32.h : 24.h),
                            
                            // Card Responsable de l'établissement
                            _buildResponsableCard(isIPad, lang),
                            
                            SizedBox(height: isIPad ? 32.h : 24.h),
                            
                            // Formulaire
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Nom
                                  _buildTextField(
                                    controller: _nomController,
                                    label: lang.translate('Nom'),
                                    hint: 'Jackop',
                                    isIPad: isIPad,
                                    lang: lang,
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Prénom
                                  _buildTextField(
                                    controller: _prenomController,
                                    label: lang.translate('Prenom'),
                                    hint: 'Pierre',
                                    isIPad: isIPad,
                                    lang: lang,
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Email professionnel
                                  _buildTextField(
                                    controller: _emailController,
                                    label: lang.translate('email_prof_label'),
                                    hint: 'm.Pierre@etablissement.fr',
                                    icon: Icons.mail_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    isIPad: isIPad,
                                    lang: lang,
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                    _buildTextField(
                                      controller: _telephoneController,
                                      label: lang.translate('phone_label'),
                                      hint: '06 12 34 56 78',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      isIPad: isIPad,
                                      lang: lang,
                                    ),

                                    SizedBox(height: 20.h),

                                    // Fonction
                                    _buildTextField(
                                      controller: _fonctionController,
                                      label: lang.translate('function_label'),
                                      hint: lang.translate('director_hint'),
                                      isIPad: isIPad,
                                      lang: lang,
                                    ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: isIPad ? 50.h : 40.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Bouton Continuer
                  Padding(
                    padding: EdgeInsets.all(isIPad ? 24.w : 20.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isIPad ? 400.w : 350.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Navigation vers step 3
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InscriptionClientStep3Screen(
                                    previousData: {
                                      ...?widget.step1Data,
                                      'nom': _nomController.text,
                                      'prenom': _prenomController.text,
                                      'email': _emailController.text,
                                      'telephone': _telephoneController.text,
                                      'fonction': _fonctionController.text,
                                      'photoPath': _selectedPhotoPath,
                                      'photoBytes': _selectedPhotoBytes,
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                lang.translate('continue'),
                                style: getSourceSerifProStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildHeader(LanguageProvider lang) {
    return Container(
      width: double.infinity,
      height: 100.h,
      color: _primaryGreen,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Trait horizontal en haut
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top > 0 ? 8.h : 32.h,
                left: 12.w,
                right: 12.w,
              ),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // Flèche retour et "Retour" à gauche, "Étape 2/5" à droite
                  Positioned(
                    bottom: 20.h,
                    left: 16.w,
                    right: 16.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Retour à gauche
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios, color: Colors.white, size: 18.sp),
                              SizedBox(width: 4.w),
                              Text(
                                lang.translate('back'),
                                style: getSourceSerifProStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Étape 2/4 à droite
                        Text(
                          '${lang.translate('step')} 2/4',
                          style: getSourceSerifProStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Barre de progression
                  Positioned(
                    bottom: 6.h,
                    left: 16.w,
                    right: 16.w,
                    child: Container(
                      height: 4.h,
                      child: Stack(
                        children: [
                          // Ligne de fond
                          Container(
                            width: double.infinity,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2.h),
                            ),
                          ),
                          // Ligne de progression (40%)
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.5,
                            child: Container(
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2.h),
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
          ],
        ),
      ),
    );
  }

  Widget _buildResponsableCard(bool isIPad, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Header avec icône et titre
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.person,
                  color: _primaryGreen,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                lang.translate('responsible_card_title'),
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          // Avatar avec icône caméra (cliquable)
          GestureDetector(
            onTap: _pickPhoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cercle avatar
                Container(
                  width: 90.w,
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                    border: _selectedPhotoBytes != null 
                        ? Border.all(color: _primaryGreen, width: 2)
                        : null,
                  ),
                  child: _selectedPhotoBytes != null
                      ? ClipOval(
                          child: Image.memory(
                            _selectedPhotoBytes!,
                            width: 90.w,
                            height: 90.h,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: Color(0xFF9E9E9E),
                          size: 45.sp,
                        ),
                ),
                // Icône caméra en bas à droite
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 26.w,
                    height: 26.h,
                    decoration: BoxDecoration(
                      color: _primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Texte "Photo optionnelle"
          Text(
            _selectedPhotoBytes != null ? lang.translate('change_photo') : lang.translate('optional_photo'),
            style: getSourceSerifProStyle(
              fontSize: 12.sp,
              color: _primaryGreen,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    required bool isIPad,
    required LanguageProvider lang,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getSourceSerifProStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: getSourceSerifProStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey[500], size: 20.sp) : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryGreen, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
          style: getSourceSerifProStyle(
            fontSize: 14.sp,
            color: Colors.black87,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return lang.translate('field_required_err');
            }
            if (label.contains(lang.translate('email_prof_label').replaceAll(' *', '')) && !value.contains('@')) {
              return lang.translate('invalid_email_err');
            }
            return null;
          },
        ),
      ],
    );
  }
}

