import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'inscription_professionnel_step3_screen.dart';

class InscriptionProfessionnelStep2Screen extends StatefulWidget {
  final String prenom;
  final String nom;
  final String email;
  final String telephone;

  const InscriptionProfessionnelStep2Screen({
    Key? key,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.telephone,
  }) : super(key: key);

  @override
  _InscriptionProfessionnelStep2ScreenState createState() => _InscriptionProfessionnelStep2ScreenState();
}

class _InscriptionProfessionnelStep2ScreenState extends State<InscriptionProfessionnelStep2Screen> {
  final TextEditingController _dateNaissanceController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController(text: '12 Rue de la République');
  final TextEditingController _codePostalController = TextEditingController(text: '75001');
  final TextEditingController _villeController = TextEditingController(text: 'Paris');
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  
  final FocusNode _adresseFocus = FocusNode();
  final FocusNode _codePostalFocus = FocusNode();
  final FocusNode _villeFocus = FocusNode();
  
  bool _adresseCleared = false;
  bool _codePostalCleared = false;
  bool _villeCleared = false;

  @override
  void initState() {
    super.initState();
    _adresseFocus.addListener(() {
      if (_adresseFocus.hasFocus && !_adresseCleared && _adresseController.text.isNotEmpty) {
        _adresseController.clear();
        _adresseCleared = true;
      }
    });
    _codePostalFocus.addListener(() {
      if (_codePostalFocus.hasFocus && !_codePostalCleared && _codePostalController.text.isNotEmpty) {
        _codePostalController.clear();
        _codePostalCleared = true;
      }
    });
    _villeFocus.addListener(() {
      if (_villeFocus.hasFocus && !_villeCleared && _villeController.text.isNotEmpty) {
        _villeController.clear();
        _villeCleared = true;
      }
    });
  }

  @override
  void dispose() {
    _dateNaissanceController.dispose();
    _adresseController.dispose();
    _codePostalController.dispose();
    _villeController.dispose();
    _adresseFocus.dispose();
    _codePostalFocus.dispose();
    _villeFocus.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF0059AB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateNaissanceController.text = 
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

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
                            // Icône adresse
                            Container(
                              width: isIPad ? 80.w : 70.w,
                              height: isIPad ? 80.h : 70.h,
                              decoration: BoxDecoration(
                                color: Color(0xFFE0F7FA),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/icon_adresse (1).png',
                                  width: isIPad ? 80.w : 70.w,
                                  height: isIPad ? 80.h : 70.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.location_on_outlined,
                                      color: Color(0xFF0059AB),
                                      size: isIPad ? 40.sp : 35.sp,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: isIPad ? 24.h : 20.h),
                            Text(
                              lang.translate('your_address'),
                              style: getSourceSerifProStyle(
                                fontSize: isIPad ? 22.sp : 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              lang.translate('where_are_you_based'),
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
                                  // Date de naissance
                                  Text(
                                    lang.translate('birth_date_req'),
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: AbsorbPointer(
                                      child: TextFormField(
                                        controller: _dateNaissanceController,
                                        decoration: InputDecoration(
                                          hintText: lang.translate('birth_date_hint'),
                                          hintStyle: getSourceSerifProStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[400],
                                          ),
                                          prefixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey[600], size: 20.sp),
                                          suffixIcon: Icon(Icons.calendar_month, color: Colors.grey[600], size: 20.sp),
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
                                            borderSide: BorderSide(color: Color(0xFF0059AB), width: 2),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                        ),
                                        style: getSourceSerifProStyle(
                                          fontSize: 14.sp,
                                          color: Colors.black87,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                              return lang.translate('birth_date_required_err');
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Adresse complète
                                  Text(
                                    lang.translate('full_address_req'),
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextFormField(
                                    controller: _adresseController,
                                    focusNode: _adresseFocus,
                                    decoration: InputDecoration(
                                      hintText: lang.translate('address_hint'),
                                      hintStyle: getSourceSerifProStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[400],
                                      ),
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
                                        borderSide: BorderSide(color: Color(0xFF0059AB), width: 2),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                    ),
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return lang.translate('address_required_err');
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // Code postal et Ville côte à côte
                                  Row(
                                    children: [
                                      // Code postal
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lang.translate('postal_code_req'),
                                              style: getSourceSerifProStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            TextFormField(
                                              controller: _codePostalController,
                                              focusNode: _codePostalFocus,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                hintText: lang.translate('postal_code_hint'),
                                                hintStyle: getSourceSerifProStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey[400],
                                                ),
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
                                                  borderSide: BorderSide(color: Color(0xFF0059AB), width: 2),
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
                                        ),
                                      ),
                                      
                                      SizedBox(width: 16.w),
                                      
                                      // Ville
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lang.translate('city_req'),
                                              style: getSourceSerifProStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            TextFormField(
                                              controller: _villeController,
                                              focusNode: _villeFocus,
                                              decoration: InputDecoration(
                                                hintText: lang.translate('city_hint'),
                                                hintStyle: getSourceSerifProStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey[400],
                                                ),
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
                                                  borderSide: BorderSide(color: Color(0xFF0059AB), width: 2),
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
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isIPad ? 30.h : 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(isIPad ? 20.w : 16.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isIPad ? 360.w : 300.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InscriptionProfessionnelStep3Screen(
                                    prenom: widget.prenom,
                                    nom: widget.nom,
                                    email: widget.email,
                                    telephone: widget.telephone,
                                    dateNaissance: _dateNaissanceController.text,
                                    adresse: _adresseController.text,
                                    codePostal: _codePostalController.text,
                                    ville: _villeController.text,
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0059AB),
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
                        // Étape 2/5 à droite
                        Text(
                          '${lang.translate('step')} 2/5',
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
                            widthFactor: 0.4,
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
}
