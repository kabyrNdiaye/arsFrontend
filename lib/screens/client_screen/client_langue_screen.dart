import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class ClientLangueScreen extends StatefulWidget {
  const ClientLangueScreen({Key? key}) : super(key: key);

  @override
  _ClientLangueScreenState createState() => _ClientLangueScreenState();
}

class _ClientLangueScreenState extends State<ClientLangueScreen> {
  String _selectedLanguage = 'fr';
  
  // Couleur du thème client
  final Color _primaryGreen = Color(0xFF4CA054);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final langProvider = Provider.of<LanguageProvider>(context, listen: false);
      setState(() {
        _selectedLanguage = langProvider.currentLanguage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Couleur plus claire comme mockup
        body: Column(
          children: [
            // Header vert
            _buildHeader(context, langProvider),
            
            // Contenu
            Expanded(
              child: Padding(
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
                    children: [
                      _buildLanguageOption('Français', 'fr'),
                      Divider(height: 1, indent: 40.w, color: Colors.grey[100]),
                      _buildLanguageOption('Anglais', 'en'),
                      Divider(height: 1, indent: 40.w, color: Colors.grey[100]),
                      _buildLanguageOption('Espagnol', 'es'),
                      
                      const Spacer(),
                      
                      // Bouton Appliquer
                      _buildApplyButton(langProvider),
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

  Widget _buildHeader(BuildContext context, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryGreen,
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
                          'Retour',
                          style: getInterStyle(
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
                        padding: EdgeInsets.only(right: 64.w), // Pour équilibrer
                        child: Text(
                          langProvider.translate('language'),
                          style: getInterStyle(
                            fontSize: 20.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

  Widget _buildLanguageOption(String title, String value) {
    final bool isSelected = _selectedLanguage == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            // Radio button personnalisé
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _primaryGreen : const Color(0xFFBDBDBD),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primaryGreen,
                        ),
                      ),
                    )
                  : null,
            ),
            
            SizedBox(width: 16.w),
            
            // Titre
            Expanded(
              child: Text(
                title,
                style: getInterStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF333333),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(height: 1, color: Colors.grey[100]),
    );
  }

  Widget _buildApplyButton(LanguageProvider langProvider) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: () {
          langProvider.setLanguage(_selectedLanguage);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(langProvider.translate('language_changed')),
              backgroundColor: _primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          langProvider.translate('apply'),
          style: getInterStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

















