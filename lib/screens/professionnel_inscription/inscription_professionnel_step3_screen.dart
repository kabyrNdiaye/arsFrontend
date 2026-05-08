import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'inscription_professionnel_step4_screen.dart';

class InscriptionProfessionnelStep3Screen extends StatefulWidget {
  final String prenom;
  final String nom;
  final String email;
  final String telephone;
  final String dateNaissance;
  final String adresse;
  final String codePostal;
  final String ville;

  const InscriptionProfessionnelStep3Screen({
    Key? key,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.dateNaissance,
    required this.adresse,
    required this.codePostal,
    required this.ville,
  }) : super(key: key);

  @override
  _InscriptionProfessionnelStep3ScreenState createState() => _InscriptionProfessionnelStep3ScreenState();
}

class _InscriptionProfessionnelStep3ScreenState extends State<InscriptionProfessionnelStep3Screen> {
  String? _selectedFonction;
  String? _selectedExperience;
  final List<String> _selectedSpecialites = [];
  final _formKey = GlobalKey<FormState>();

  // Liste des fonctions principales
  final List<String> _fonctions = [
    'cook',
    'head_chef',
    'pastry_chef',
    'kitchen_commis',
    'kitchen_helper',
  ];

  // Liste des années d'expérience
  final List<String> _anneesExperience = [
    'under_2_years',
    '2_to_5_years',
    '5_to_10_years',
    'over_10_years',
  ];

  // Liste des spécialités
  final List<String> _specialites = [
    'traditional_cuisine',
    'dietary_cuisine',
    'modified_textures',
    'pastry',
    'bakery',
  ];

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(isIPad, lang),
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
                            // Icône cadeau
                            Container(
                              width: isIPad ? 80.w : 70.w,
                              height: isIPad ? 80.h : 70.h,
                              decoration: BoxDecoration(
                                color: Color(0xFFE0F7FA),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/icon_cadeau.png',
                                  width: isIPad ? 80.w : 70.w,
                                  height: isIPad ? 80.h : 70.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.card_giftcard_outlined,
                                      color: Color(0xFF0059AB),
                                      size: isIPad ? 40.sp : 35.sp,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: isIPad ? 24.h : 20.h),
                            Text(
                              lang.translate('professional_experience'),
                              style: getSourceSerifProStyle(
                                fontSize: isIPad ? 22.sp : 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              lang.translate('tell_us_path'),
                              style: getSourceSerifProStyle(
                                fontSize: isIPad ? 14.sp : 13.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isIPad ? 40.h : 32.h),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Fonction principale - Dropdown
                                  Text(
                                    lang.translate('main_function_req'),
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  _buildCustomDropdown(
                                    value: _selectedFonction,
                                    hint: lang.translate('select_function'),
                                    items: _fonctions,
                                    lang: lang,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedFonction = value;
                                      });
                                    },
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Années d'expérience - Dropdown
                                  Text(
                                    lang.translate('years_experience_req'),
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  _buildCustomDropdown(
                                    value: _selectedExperience,
                                    hint: lang.translate('select'),
                                    items: _anneesExperience,
                                    lang: lang,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedExperience = value;
                                      });
                                    },
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Spécialités - Multi-select checkboxes
                                  Text(
                                    lang.translate('specialties_req'),
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    lang.translate('select_expertise_domains'),
                                    style: getSourceSerifProStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  
                                  // Liste des spécialités avec checkboxes
                                  ..._specialites.map((specialite) {
                                    final isSelected = _selectedSpecialites.contains(specialite);
                                    return _buildSpecialiteItem(
                                      specialite: specialite,
                                      isSelected: isSelected,
                                      lang: lang,
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedSpecialites.remove(specialite);
                                          } else {
                                            _selectedSpecialites.add(specialite);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                            SizedBox(height: isIPad ? 30.h : 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bouton Continuer
                  Padding(
                    padding: EdgeInsets.all(isIPad ? 20.w : 16.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isIPad ? 360.w : 300.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canContinue() ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InscriptionProfessionnelStep4Screen(
                                  prenom: widget.prenom,
                                  nom: widget.nom,
                                  email: widget.email,
                                  telephone: widget.telephone,
                                  dateNaissance: widget.dateNaissance,
                                  adresse: widget.adresse,
                                  codePostal: widget.codePostal,
                                  ville: widget.ville,
                                  fonction: _selectedFonction!,
                                  anneesExperience: _selectedExperience!,
                                  specialites: _selectedSpecialites,
                                ),
                              ),
                            );
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0059AB),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            disabledForegroundColor: Colors.grey[600],
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
                                  color: _canContinue() ? Colors.white : Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16.sp,
                                color: _canContinue() ? Colors.white : Colors.grey[600],
                              ),
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

  bool _canContinue() {
    return _selectedFonction != null && 
           _selectedExperience != null && 
           _selectedSpecialites.isNotEmpty;
  }

  Widget _buildHeader(bool isIPad, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      height: 100.h,
      color: const Color(0xFF0059AB),
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
                  // Flèche retour et "Retour" à gauche, "Étape 3/5" à droite
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
                        // Étape 3/5 à droite
                        Text(
                          '${lang.translate('step')} 3/5',
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
                          // Ligne de progression (60%)
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.6,
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

  Widget _buildCustomDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    required LanguageProvider lang,
  }) {
    // Calculer la largeur disponible (écran - padding horizontal)
    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownWidth = screenWidth - 48.w; // 24.w padding de chaque côté
    
    return PopupMenuButton<String>(
      onSelected: (String selectedValue) {
        onChanged(selectedValue);
      },
      offset: Offset(0, 0), // S'ouvre exactement sur le champ
      position: PopupMenuPosition.over, // Overlay sur le champ
      constraints: BoxConstraints(
        minWidth: dropdownWidth,
        maxWidth: dropdownWidth,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Color(0xFF676765),
      itemBuilder: (BuildContext context) {
        return [
          // Premier item: "Sélectionnez votre fonction" en bleu #6399E5
          PopupMenuItem<String>(
            enabled: false,
            height: 52.h, // Même hauteur que le champ
            padding: EdgeInsets.zero,
            child: Container(
              width: dropdownWidth,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Color(0xFF6399E5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.white, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    hint,
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Liste des options
          ...items.map((item) {
            final isSelected = value == item;
            return PopupMenuItem<String>(
              value: item,
              height: 44.h,
              padding: EdgeInsets.zero,
              child: Container(
                width: dropdownWidth,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF6399E5) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    if (isSelected)
                      Icon(Icons.check, color: Colors.white, size: 18.sp)
                    else
                      SizedBox(width: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      lang.translate(item),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ];
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value != null ? Color(0xFF0059AB) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null ? lang.translate(value) : hint,
              style: getSourceSerifProStyle(
                fontSize: 14.sp,
                color: value != null ? Colors.black87 : Colors.grey[400],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialiteItem({
    required String specialite,
    required bool isSelected,
    required VoidCallback onTap,
    required LanguageProvider lang,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6399E5).withOpacity(0.15) : Colors.white, // #6399E5 avec opacité
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Color(0xFF6399E5) : Colors.grey[300]!, // #6399E5 quand sélectionné
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang.translate(specialite),
              style: getSourceSerifProStyle(
                fontSize: 14.sp,
                color: Colors.black, // Toujours noir
                fontWeight: FontWeight.bold, // Toujours en gras
              ),
            ),
            if (isSelected)
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Color(0xFF6399E5), // #6399E5
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
