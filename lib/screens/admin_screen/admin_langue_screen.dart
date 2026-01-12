import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class AdminLangueScreen extends StatefulWidget {
  const AdminLangueScreen({Key? key}) : super(key: key);

  @override
  _AdminLangueScreenState createState() => _AdminLangueScreenState();
}

class _AdminLangueScreenState extends State<AdminLangueScreen> {
  late String _selectedLangueCode;
  final Color _primaryPurple = const Color(0xFF7C39D3);

  final List<Map<String, String>> _langues = [
    {'code': 'fr', 'name': 'Français'},
    {'code': 'en', 'name': 'Anglais'},
    {'code': 'es', 'name': 'Espagnol'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLangueCode = 'fr';
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
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header violet
          _buildHeader(langProvider),
          
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
                    _buildLanguageItem(_langues[0], _selectedLangueCode == 'fr'),
                    Divider(height: 1, indent: 40.w, color: Colors.grey[100]),
                    _buildLanguageItem(_langues[1], _selectedLangueCode == 'en'),
                    Divider(height: 1, indent: 40.w, color: Colors.grey[100]),
                    _buildLanguageItem(_langues[2], _selectedLangueCode == 'es'),
                    
                    const Spacer(),
                    
                    // Bouton Appliquer
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: () {
                          langProvider.setLanguage(_selectedLangueCode);
                          String languageName = _langues
                              .firstWhere((l) => l['code'] == _selectedLangueCode)['name']!;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${langProvider.translate('language_changed')} $languageName'),
                              backgroundColor: _primaryPurple,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryPurple,
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

  Widget _buildHeader(LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryPurple,
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

  Widget _buildLanguageItem(Map<String, String> langue, bool isSelected) {
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
            // Radio button personnalisé
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _primaryPurple : const Color(0xFFBDBDBD),
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
                          color: _primaryPurple,
                        ),
                      ),
                    )
                  : null,
            ),
            
            SizedBox(width: 16.w),
            
            Text(
              langue['name']!,
              style: getInterStyle(
                fontSize: 16.sp,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
