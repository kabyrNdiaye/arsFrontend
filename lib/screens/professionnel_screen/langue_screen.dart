import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class LangueScreen extends StatefulWidget {
  const LangueScreen({Key? key}) : super(key: key);

  @override
  State<LangueScreen> createState() => _LangueScreenState();
}

class _LangueScreenState extends State<LangueScreen> {
  late String _selectedLangueCode;

  final List<Map<String, String>> _langues = [
    {'code': 'fr', 'name': 'Français'},
    {'code': 'en', 'name': 'Anglais'},
    {'code': 'es', 'name': 'Espagnol'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLangueCode = 'fr'; // Valeur par défaut temporaire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final langProvider = Provider.of<LanguageProvider>(context, listen: false);
        setState(() {
          _selectedLangueCode = langProvider.currentLanguage;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    final Color primaryGreen = const Color(0xFF4CA054);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header vert
            _buildHeader(context, langProvider, primaryGreen),
            
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
                      _buildLangueItem(_langues[0], true, primaryGreen),
                      Divider(height: 1, indent: 40.w, color: Colors.grey[100]),
                      _buildLangueItem(_langues[1], false, primaryGreen),
                      Divider(height: 1, indent: 40.w, color: Colors.grey[100]),
                      _buildLangueItem(_langues[2], false, primaryGreen),
                      
                      const Spacer(),
                      
                      // Bouton Appliquer
                      _buildApplyButton(langProvider, primaryGreen),
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

  Widget _buildHeader(BuildContext context, LanguageProvider langProvider, Color primaryColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
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
                        padding: EdgeInsets.only(right: 64.w), // Pour équilibrer le bouton retour
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

  Widget _buildLangueItem(Map<String, String> langue, bool isLast, Color primaryColor) {
    bool isSelected = _selectedLangueCode == langue['code'];
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLangueCode = langue['code']!;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey[400]!,
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
                          color: primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            
            SizedBox(width: 16.w),
            
            // Nom de la langue
            Text(
              langue['name']!,
              style: getInterStyle(
                fontSize: 16.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton(LanguageProvider langProvider, Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () {
          langProvider.setLanguage(_selectedLangueCode);
          String languageName = _langues
              .firstWhere((l) => l['code'] == _selectedLangueCode)['name']!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${langProvider.translate('language_changed')} $languageName'),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          langProvider.translate('apply'),
          style: getInterStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
