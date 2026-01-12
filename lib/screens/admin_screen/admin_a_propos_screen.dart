import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class AdminAProposScreen extends StatelessWidget {
  const AdminAProposScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    final Color _primaryPurple = Color(0xFF7C39D3);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header violet
            _buildHeader(context, langProvider, _primaryPurple),
            // Contenu
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20.h),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      // Logo ARS dans un cercle violet clair
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFF3E5F5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/ARS.png',
                            height: 80.h,
                            width: 80.w,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                'ARS',
                                style: getSourceSerifProStyle(
                                  fontSize: 36.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryPurple,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      // Section Notre Mission
                      _buildSectionCard(
                        langProvider.translate('our_mission'),
                        langProvider.translate('mission_content'),
                      ),
                      SizedBox(height: 16.h),
                      // Section Contact
                      _buildSectionCard(
                        langProvider.translate('contact'),
                        null,
                        contactInfo: [
                          {'icon': Icons.email_outlined, 'text': 'support@ars.com'},
                          {'icon': Icons.language, 'text': 'www.ars.com'},
                          {'icon': Icons.location_on, 'text': '123 Rue de l\'innovation, 750001 Paris, France'},
                        ],
                      ),
                      SizedBox(height: 16.h),
                      // Section Mentions Légales
                      _buildSectionCard(
                        langProvider.translate('legal_mentions'),
                        langProvider.translate('legal_content'),
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

  Widget _buildHeader(BuildContext context, LanguageProvider langProvider, Color primaryPurple) {
    return Container(
      decoration: BoxDecoration(
        color: primaryPurple,
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
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        langProvider.translate('back'),
                        style: getSourceSerifProStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  langProvider.translate('about'),
                  style: getSourceSerifProStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                SizedBox(width: 80.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String? content, {List<Map<String, dynamic>>? contactInfo}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getSourceSerifProStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          if (content != null)
            Text(
              content,
              style: getSourceSerifProStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          if (contactInfo != null)
            ...contactInfo.map((info) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Icon(
                    info['icon'] as IconData,
                    color: Color(0xFF7C39D3),
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      info['text'] as String,
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }
}

