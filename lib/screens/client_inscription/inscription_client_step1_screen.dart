import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'inscription_client_step2_screen.dart';

class InscriptionClientStep1Screen extends StatefulWidget {
  @override
  _InscriptionClientStep1ScreenState createState() => _InscriptionClientStep1ScreenState();
}

class _InscriptionClientStep1ScreenState extends State<InscriptionClientStep1Screen> {
  final TextEditingController _nomEtablissementController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _codePostalController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _capaciteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedTypeEtablissement;
  
  final List<String> _typesEtablissementKeys = [
    'ehpad',
    'residence_seniors',
    'hospital',
    'clinic',
    'foyer',
    'other',
  ];

  // Couleur verte principale
  final Color _primaryGreen = Color(0xFF4CA054);
  final Color _lightGreen = Color(0xFFE8F5E9);
  
  bool get isIPad => MediaQuery.of(context).size.width >= 600;

  @override
  void dispose() {
    _nomEtablissementController.dispose();
    _adresseController.dispose();
    _codePostalController.dispose();
    _villeController.dispose();
    _telephoneController.dispose();
    _capaciteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final lang = Provider.of<LanguageProvider>(context);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
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
                            
                            // Icône établissement
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
                              lang.translate('your_establishment'),
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
                              lang.translate('establishment_info_title'),
                              style: getSourceSerifProStyle(
                                fontSize: isIPad ? 14.sp : 13.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: isIPad ? 40.h : 32.h),
                            
                            // Formulaire
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Nom de l'établissement
                                  _buildTextField(
                                    controller: _nomEtablissementController,
                                    label: lang.translate('establishment_name_label'),
                                    hint: lang.translate('ehpad_sun_hint'),
                                    isIPad: isIPad,
                                    lang: lang,
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Type d'établissement (Dropdown)
                                  _buildDropdownField(
                                    label: lang.translate('establishment_type_label'),
                                    hint: lang.translate('select_type_hint'),
                                    value: _selectedTypeEtablissement,
                                    items: _typesEtablissementKeys,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTypeEtablissement = value;
                                      });
                                    },
                                    isIPad: isIPad,
                                    lang: lang,
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Adresse complète
                                  _buildTextField(
                                    controller: _adresseController,
                                    label: lang.translate('full_address_label'),
                                    hint: lang.translate('address_hint'),
                                    isIPad: isIPad,
                                    lang: lang,
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Code postal et Ville côte à côte
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: _buildTextField(
                                          controller: _codePostalController,
                                          label: lang.translate('postal_code_label'),
                                          hint: lang.translate('postal_code_hint'),
                                          keyboardType: TextInputType.number,
                                          isIPad: isIPad,
                                          lang: lang,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        flex: 5,
                                        child: _buildTextField(
                                          controller: _villeController,
                                          label: lang.translate('city_label'),
                                          hint: lang.translate('city_hint'),
                                          isIPad: isIPad,
                                          lang: lang,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Téléphone
                                  _buildTextField(
                                    controller: _telephoneController,
                                    label: lang.translate('phone_label'),
                                    hint: lang.translate('phone_hint'),
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    isIPad: isIPad,
                                    lang: lang,
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Capacité
                                  _buildTextField(
                                    controller: _capaciteController,
                                    label: lang.translate('capacity_label'),
                                    hint: lang.translate('capacity_hint'),
                                    keyboardType: TextInputType.number,
                                    isIPad: isIPad,
                                    lang: lang,
                                  ),
                                  
                                  SizedBox(height: 24.h),
                                  
                                  // Info box
                                  _buildInfoBox(isIPad, lang),
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
                            if (_formKey.currentState!.validate() && _selectedTypeEtablissement != null) {
                              // Navigation vers step 2
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InscriptionClientStep2Screen(
                                    step1Data: {
                                      'nomEtablissement': _nomEtablissementController.text,
                                      'typeEtablissement': _selectedTypeEtablissement,
                                      'adresse': _adresseController.text,
                                      'codePostal': _codePostalController.text,
                                      'ville': _villeController.text,
                                      'telephoneEtablissement': _telephoneController.text,
                                      'capacite': _capaciteController.text,
                                    },
                                  ),
                                ),
                              );
                            } else if (_selectedTypeEtablissement == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(lang.translate('select_type_err')),
                                  backgroundColor: Colors.red,
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
                  // Flèche retour et "Retour" à gauche, "Étape 1/5" à droite
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
                        // Étape 1/4 à droite
                        Text(
                          '${lang.translate('step')} 1/4',
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
                    child: SizedBox(
                      height: 4.h,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2.h),
                            ),
                          ),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.25,
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
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600], size: 20.sp) : null,
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
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isIPad,
    required LanguageProvider lang,
  }) {
    // Créer la liste avec l'option de sélection en premier
    final List<String> allItems = ['select_type_option', ...items];
    
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
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: getSourceSerifProStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
          ),
          decoration: InputDecoration(
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
          selectedItemBuilder: (BuildContext context) {
            return allItems.map<Widget>((String item) {
              return Text(
                item == 'select_type_option' ? '' : lang.translate(item),
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              );
            }).toList();
          },
          items: allItems.map((String item) {
            final bool isSelectOption = item == 'select_type_option';
            final bool isSelected = value == item;
            
            return DropdownMenuItem<String>(
              value: isSelectOption ? null : item,
              enabled: !isSelectOption,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                decoration: isSelectOption ? BoxDecoration(
                  color: Color(0xFF6399E5),
                  borderRadius: BorderRadius.circular(4),
                ) : null,
                child: Row(
                  children: [
                    if (isSelectOption) ...[
                      Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      lang.translate(item),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: isSelectOption ? Colors.white : Colors.white,
                        fontWeight: isSelectOption ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: Color(0xFF676765),
          borderRadius: BorderRadius.circular(8),
          menuMaxHeight: 250.h,
          isExpanded: true,
          style: getSourceSerifProStyle(
            fontSize: 14.sp,
            color: Colors.black87,
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return lang.translate('field_required_err');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInfoBox(bool isIPad, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _lightGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _primaryGreen,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: _primaryGreen,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              lang.translate('info_visible_pros'),
              style: getSourceSerifProStyle(
                fontSize: 13.sp,
                color: _primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

