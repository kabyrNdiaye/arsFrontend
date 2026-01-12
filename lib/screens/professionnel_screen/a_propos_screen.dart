import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class AProposScreen extends StatelessWidget {
  const AProposScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    const Color primaryBlue = Color(0xFF0059AB);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: primaryBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: Column(
          children: [
            // Header bleu
            _buildHeader(context, langProvider, primaryBlue),
            
            // Contenu
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 32.h),
                    
                    // Logo ARS dans un cercle violet clair
                    Center(
                      child: Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE3F2FD),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo2.png',
                            height: 60.h,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                'ARS',
                                style: getInterStyle(
                                  fontSize: 40.sp,
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // Section Notre Mission
                    _buildSection(
                      title: langProvider.translate('our_mission'),
                      content: langProvider.translate('mission_content'),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Section Contact
                    _buildContactSection(langProvider, primaryBlue),
                    
                    SizedBox(height: 20.h),
                    
                    // Section Mentions Légales
                    _buildSection(
                      title: langProvider.translate('legal_mentions'),
                      content: langProvider.translate('legal_content'),
                    ),
                    
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LanguageProvider langProvider, Color primaryBlue) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryBlue,
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          children: [
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
                  // Bouton Retour
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
                            langProvider.translate('back'),
                            style: getInterStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Titre centré
                  Text(
                    langProvider.translate('about'),
                    style: getInterStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            style: getInterStyle(
              fontSize: 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: getInterStyle(
              fontSize: 13.sp,
              color: Colors.black87.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(LanguageProvider langProvider, Color primaryBlue) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            langProvider.translate('contact'),
            style: getInterStyle(
              fontSize: 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 20.h),
          
          _buildContactItem(
            icon: Icons.email_outlined,
            text: 'support@ars.com',
            primaryBlue: primaryBlue,
          ),
          SizedBox(height: 16.h),
          
          _buildContactItem(
            icon: Icons.language_rounded,
            text: 'www.ars.com',
            primaryBlue: primaryBlue,
          ),
          SizedBox(height: 16.h),
          
          _buildContactItem(
            icon: Icons.location_on_outlined,
            text: '123 Rue de l\'innovation, 750001 Paris , France',
            primaryBlue: primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    required Color primaryBlue,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: primaryBlue,
          size: 22.sp,
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            text,
            style: getInterStyle(
              fontSize: 14.sp,
              color: Colors.black87.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

