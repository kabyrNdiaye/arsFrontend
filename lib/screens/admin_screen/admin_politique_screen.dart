import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class AdminPolitiqueScreen extends StatefulWidget {
  const AdminPolitiqueScreen({Key? key}) : super(key: key);

  @override
  State<AdminPolitiqueScreen> createState() => _AdminPolitiqueScreenState();
}

class _AdminPolitiqueScreenState extends State<AdminPolitiqueScreen> {
  final Color _primaryPurple = const Color(0xFF7C39D3);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header violet
            _buildHeader(context, langProvider, _primaryPurple),
            
            // Contenu
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Container(
                  width: double.infinity,
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
                      _buildSection(
                        langProvider.translate('data_collection'),
                        langProvider.translate('data_collection_content'),
                      ),
                      _buildDivider(),
                      _buildSection(
                        langProvider.translate('data_usage'),
                        langProvider.translate('data_usage_content'),
                      ),
                      _buildDivider(),
                      _buildSection(
                        langProvider.translate('data_protection'),
                        langProvider.translate('data_protection_content'),
                      ),
                      _buildDivider(),
                      _buildSection(
                        langProvider.translate('your_rights'),
                        langProvider.translate('your_rights_content'),
                      ),
                      _buildDivider(),
                      _buildSection(
                        langProvider.translate('contact'),
                        '${langProvider.translate('privacy_contact_hint') ?? 'Pour toute question concernant notre politique de confidentialité, contactez-nous à :'}\n\n'
                        'Email : privacy@ars-app.fr\n'
                        'Adresse : 45 Avenue de la République, 75011 Paris',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildHeader(BuildContext context, LanguageProvider langProvider, Color primaryPurple) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryPurple,
      ),
      child: SafeArea(
        bottom: false,
        top: false,
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
              child: Row(
                children: [
                  // Bouton Retour
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                        SizedBox(width: 4.w),
                        Text(
                          langProvider.translate('back'),
                          style: getSourceSerifProStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Titre centré
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 64.w), // Pour compenser
                        child: Text(
                          langProvider.translate('privacy'),
                          textAlign: TextAlign.center,
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
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

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: getSourceSerifProStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: _primaryPurple,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          content,
          style: getSourceSerifProStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Divider(height: 1, color: Colors.grey[100]),
    );
  }
}
















