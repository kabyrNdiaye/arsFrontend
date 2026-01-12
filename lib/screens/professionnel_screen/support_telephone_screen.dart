import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class SupportTelephoneScreen extends StatelessWidget {
  const SupportTelephoneScreen({Key? key}) : super(key: key);

  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Header vert
            _buildHeader(context),
            
            // Contenu
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 12.h),
                      
                      // Icône téléphone
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: _primaryGreen.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.phone,
                            color: _primaryGreen,
                            size: 32.sp,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      Text(
                        'Support Téléphonique',
                        style: getInterStyle(
                          fontSize: 20.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      Text(
                        'Notre équipe est disponible pour vous aider par téléphone.',
                        textAlign: TextAlign.center,
                        style: getInterStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      SizedBox(height: 32.h),
                      
                      // Numéro principal
                      _buildPhoneCard(
                        context: context,
                        title: 'Ligne Principale',
                        phone: '+33 1 23 45 67 89',
                        description: 'Support général et assistance',
                        icon: FontAwesomeIcons.headset,
                        isMain: true,
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Urgences
                      _buildPhoneCard(
                        context: context,
                        title: 'Urgences Mission',
                        phone: '+33 1 23 45 67 90',
                        description: 'Problèmes urgents pendant une mission',
                        icon: FontAwesomeIcons.triangleExclamation,
                        isMain: false,
                      ),
                      
                      SizedBox(height: 32.h),
                      
                      // Horaires d'ouverture
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: _primaryGreen,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'Horaires d\'ouverture',
                                  style: getInterStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildHoraireItem('Lundi - Vendredi', '8h00 - 19h00'),
                            SizedBox(height: 12.h),
                            _buildHoraireItem('Samedi', '9h00 - 17h00'),
                            SizedBox(height: 12.h),
                            _buildHoraireItem('Dimanche', 'Fermé'),
                            SizedBox(height: 20.h),
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF4CAF50),
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Ligne urgences disponible 24h/24 pendant les missions',
                                      style: getInterStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 48.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: _primaryGreen),
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
              child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              child: Row(
                children: [
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
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 64.w),
                        child: Text(
                          'Support Téléphonique',
                          style: getInterStyle(
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

  Widget _buildPhoneCard({
    required BuildContext context,
    required String title,
    required String phone,
    required String description,
    required IconData icon,
    required bool isMain,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMain ? Border.all(color: _primaryGreen, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: isMain ? _primaryGreen : _primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: isMain ? Colors.white : _primaryGreen,
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: getInterStyle(
                        fontSize: 15.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      phone,
                      style: getInterStyle(
                        fontSize: 16.sp,
                        color: _primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Appel vers $phone...'),
                        backgroundColor: _primaryGreen,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: Colors.white, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Appeler',
                          style: getInterStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: phone));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Numéro copié : $phone'),
                      backgroundColor: _primaryGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Icon(
                    Icons.copy,
                    color: _primaryGreen,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoraireItem(String jour, String horaire) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          jour,
          style: getInterStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          horaire,
          style: getInterStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}


