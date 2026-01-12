import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';
import '../auth/login_screen22.dart';
import 'inscription_professionnel_step2_screen.dart';

class InscriptionProfessionnelStep1Screen extends StatefulWidget {
  @override
  _InscriptionProfessionnelStep1ScreenState createState() => _InscriptionProfessionnelStep1ScreenState();
}

class _InscriptionProfessionnelStep1ScreenState extends State<InscriptionProfessionnelStep1Screen> {
  final TextEditingController _prenomController = TextEditingController(text: 'Jean');
  final TextEditingController _nomController = TextEditingController(text: 'Dupont');
  final TextEditingController _emailController = TextEditingController(text: 'jean.dupont@email.com');
  final TextEditingController _telephoneController = TextEditingController(text: '06 12 34 56 78');
  final _formKey = GlobalKey<FormState>();
  
  final FocusNode _prenomFocus = FocusNode();
  final FocusNode _nomFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _telephoneFocus = FocusNode();
  
  bool _prenomCleared = false;
  bool _nomCleared = false;
  bool _emailCleared = false;
  bool _telephoneCleared = false;
  
  bool get isIPad => MediaQuery.of(context).size.width >= 600;

  @override
  void initState() {
    super.initState();
    _prenomFocus.addListener(() {
      if (_prenomFocus.hasFocus && !_prenomCleared && _prenomController.text.isNotEmpty) {
        _prenomController.clear();
        _prenomCleared = true;
      }
    });
    _nomFocus.addListener(() {
      if (_nomFocus.hasFocus && !_nomCleared && _nomController.text.isNotEmpty) {
        _nomController.clear();
        _nomCleared = true;
      }
    });
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus && !_emailCleared && _emailController.text.isNotEmpty) {
        _emailController.clear();
        _emailCleared = true;
      }
    });
    _telephoneFocus.addListener(() {
      if (_telephoneFocus.hasFocus && !_telephoneCleared && _telephoneController.text.isNotEmpty) {
        _telephoneController.clear();
        _telephoneCleared = true;
      }
    });
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _prenomFocus.dispose();
    _nomFocus.dispose();
    _emailFocus.dispose();
    _telephoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    
    // Configurer la barre de statut pour qu'elle soit visible avec texte blanc
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0059AB),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
          _buildHeader(),
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
                            Container(
                              width: isIPad ? 80.w : 70.w,
                              height: isIPad ? 80.h : 70.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F7FA),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/icon_person.png',
                                  width: isIPad ? 80.w : 70.w,
                                  height: isIPad ? 80.h : 70.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person_outline,
                                      color: const Color(0xFF0059AB),
                                      size: isIPad ? 40.sp : 35.sp,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: isIPad ? 24.h : 20.h),
                            Text(
                              'Informations personnelles',
                              style: getSourceSerifProStyle(
                                fontSize: isIPad ? 22.sp : 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Commencez par vous en dire plus sur vous',
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
                                children: [
                                  _buildTextField(
                                    controller: _prenomController,
                                    focusNode: _prenomFocus,
                                    label: 'Prénom *',
                                    hint: 'Prénom',
                                    isIPad: isIPad,
                                  ),
                                  SizedBox(height: 20.h),
                                  _buildTextField(
                                    controller: _nomController,
                                    focusNode: _nomFocus,
                                    label: 'Nom *',
                                    hint: 'Nom',
                                    isIPad: isIPad,
                                  ),
                                  SizedBox(height: 20.h),
                                  _buildTextField(
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    label: 'Email *',
                                    hint: 'Email',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    isIPad: isIPad,
                                  ),
                                  SizedBox(height: 20.h),
                                  _buildTextField(
                                    controller: _telephoneController,
                                    focusNode: _telephoneFocus,
                                    label: 'Téléphone *',
                                    hint: 'Téléphone',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    isIPad: isIPad,
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
                                  builder: (context) => InscriptionProfessionnelStep2Screen(
                                    prenom: _prenomController.text,
                                    nom: _nomController.text,
                                    email: _emailController.text,
                                    telephone: _telephoneController.text,
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
                                'Continuer',
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

  Widget _buildHeader() {
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
                                'Retour',
                                style: getSourceSerifProStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Étape 1/5 à droite
                        Text(
                          'Étape 1/5',
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
                          // Ligne de progression (20%)
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.2,
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
    FocusNode? focusNode,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    required bool isIPad,
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
          focusNode: focusNode,
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
              return 'Ce champ est obligatoire';
            }
            if (label.contains('Email') && !value.contains('@')) {
              return 'Email invalide';
            }
            return null;
          },
        ),
      ],
    );
  }
}

