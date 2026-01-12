import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';
import '../auth/register_screen.dart';
import 'inscription2_screen.dart';

class Inscription1Screen extends StatefulWidget {
  @override
  _Inscription1ScreenState createState() => _Inscription1ScreenState();
}

class _Inscription1ScreenState extends State<Inscription1Screen> {
  final TextEditingController _prenomController = TextEditingController(text: 'Joe');
  final TextEditingController _nomController = TextEditingController(text: 'Doué');
  final TextEditingController _adresseController = TextEditingController(text: 'Av. des Champs-Élysées');
  final TextEditingController _emailController = TextEditingController(text: 'joe.doue@gmail.com');
  final TextEditingController _telephoneController = TextEditingController(text: '+33 7 89 44 55 02');

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _adresseController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Header avec "Connexion", flèche retour et logo ARS
            Container(
              width: double.infinity,
              height: 100.h,
              color: Colors.white,
              child: Stack(
                children: [
                  // Row avec flèche retour et titre - aligné avec le centre du logo
                  Positioned(
                    left: 0,
                    top: 35.h + (64.h / 2) - 20.h, // Centre du logo moins la moitié de la hauteur du bouton
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          // Flèche retour
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterScreen()),
                              );
                            },
                          ),
                          // Titre "Connexion"
                          Text(
                            langProvider.translate('login_back'),
                            style: getSourceSerifProStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000000),
                              height: 1.0, // Line height: 100%
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Logo positionné selon les paramètres (Left: 278px, Top: 35px)
                  Positioned(
                    left: 278.w,
                    top: 35.h,
                    child: Image.asset(
                      'assets/images/logo2.png',
                      width: 85.w,
                      height: 64.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 32.h, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre principal
                    Text(
                      langProvider.translate('who_are_you'),
                      style: getSourceSerifProStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000000),
                        height: 1.0, // Line height: 100%
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Sous-titre
                    Text(
                      langProvider.translate('who_are_you_desc'),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6C7278),
                        height: 1.0, // Line height: 100%
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Champs Prénom et Nom côte à côte
                    Row(
                      children: [
                        // Prénom
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                langProvider.translate('first_name'),
                                style: getSourceSerifProStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: _prenomController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF0059AB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                ),
                                style: getSourceSerifProStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(width: 16.w),
                        
                        // Nom
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                langProvider.translate('last_name'),
                                style: getSourceSerifProStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: _nomController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF0059AB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                ),
                                style: getSourceSerifProStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Champ Adresse Complète
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          langProvider.translate('full_address'),
                          style: getSourceSerifProStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: _adresseController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF0059AB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          ),
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Champ Email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          langProvider.translate('email'),
                          style: getSourceSerifProStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF0059AB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          ),
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Champ Numéro de téléphone
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          langProvider.translate('phone_number'),
                          style: getSourceSerifProStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: _telephoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF0059AB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          ),
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    
                    // Bouton SUIVANT - directement après le formulaire
                    Container(
                      width: double.infinity,
                      height: 48.h,
                      margin: EdgeInsets.only(top: 20.h, bottom: 16.h),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigation vers la page Inscription2
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Inscription2Screen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0059AB),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(double.infinity, 48.h),
                        ),
                        child: Text(
                          langProvider.translate('next'),
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
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
}

