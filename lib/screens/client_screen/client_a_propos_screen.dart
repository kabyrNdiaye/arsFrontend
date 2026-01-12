import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';

class ClientAProposScreen extends StatelessWidget {
  const ClientAProposScreen({Key? key}) : super(key: key);

  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA), // Fond gris très clair
        body: Column(
          children: [
            // Header vert
            _buildHeader(context),
          
          // Contenu
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo ARS dans un cercle vert
                  Container(
                    width: 140.w,
                    height: 140.w,
                    decoration: BoxDecoration(
                      color: _primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/ARS.png',
                        width: 90.w,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'ARS',
                            style: getSourceSerifProStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Carte Notre Mission
                  _buildSectionCard(
                    title: 'Notre Mission',
                    content: 'La mission ARS consiste à assurer la préparation, l\'organisation et la réalisation des services de restauration au sein des établissements partenaires, dans le respect strict des normes d\'hygiène, de sécurité et de qualité. Elle garantit la mise en place des menus, l\'adaptation des textures, la gestion des quantités en fonction des résidents, ainsi que la coordination avec les équipes sur site.',
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Carte Contact
                  _buildContactCard(),
                  
                  SizedBox(height: 16.h),
                  
                  // Carte Mentions Légales
                  _buildSectionCard(
                    title: 'Mentions Légales',
                    content: 'Les missions réalisées dans le cadre de la plateforme ARS respectent les obligations légales en vigueur, notamment les normes d\'hygiène (HACCP), de sécurité alimentaire et de protection des personnes accueillies. Les informations fournies aux professionnels, les procédures opérationnelles ainsi que les données collectées sont strictement conformes aux exigences réglementaires imposées par l\'Agence Régionale de Santé et les autorités compétentes.',
                  ),
                  
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryGreen,
      ),
      child: Column(
        children: [
          // Trait horizontal en haut
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top + 8.h : 32.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Stack(
              alignment: Alignment.center,
              children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Retour',
                        style: getSourceSerifProStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                Text(
                  'A propos de ARS',
                  style: getSourceSerifProStyle(
                    fontSize: 18.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getSourceSerifProStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: getSourceSerifProStyle(
              fontSize: 13.sp,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact',
            style: getSourceSerifProStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20.h),
          _buildContactRow(Icons.mail_outline, 'support@ars.com'),
          SizedBox(height: 16.h),
          _buildContactRow(Icons.public, 'www.ars.com'),
          SizedBox(height: 16.h),
          _buildContactRow(
            Icons.location_on_outlined, 
            '123 Rue de l\'innovation, 750001 Paris , France'
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primaryGreen.withOpacity(0.8), size: 22.sp),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            text,
            style: getSourceSerifProStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
