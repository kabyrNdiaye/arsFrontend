import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class SupportEmailScreen extends StatelessWidget {
  const SupportEmailScreen({Key? key}) : super(key: key);

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
                      
                      // Icône email
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: _primaryGreen.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.envelope,
                            color: _primaryGreen,
                            size: 32.sp,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      Text(
                        'Support par Email',
                        style: getInterStyle(
                          fontSize: 20.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      Text(
                        'Notre équipe de support est disponible pour répondre à toutes vos questions.',
                        textAlign: TextAlign.center,
                        style: getInterStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      SizedBox(height: 32.h),
                      
                      // Adresse email principale
                      _buildEmailCard(
                        context: context,
                        title: 'Support Général',
                        email: 'support@ars.com',
                        description: 'Pour toutes vos questions générales',
                        icon: FontAwesomeIcons.headset,
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Adresse email technique
                      _buildEmailCard(
                        context: context,
                        title: 'Support Technique',
                        email: 'technique@ars.com',
                        description: 'Problèmes techniques et bugs',
                        icon: FontAwesomeIcons.wrench,
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Adresse email facturation
                      _buildEmailCard(
                        context: context,
                        title: 'Facturation',
                        email: 'facturation@ars.com',
                        description: 'Questions sur les paiements',
                        icon: FontAwesomeIcons.fileInvoiceDollar,
                      ),
                      
                      SizedBox(height: 32.h),
                      
                      // Info délai de réponse
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: Colors.orange[800],
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Délai de réponse',
                                    style: getInterStyle(
                                      fontSize: 14.sp,
                                      color: Colors.orange[900],
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Nous répondons généralement sous 24 à 48 heures ouvrées.',
                                    style: getInterStyle(
                                      fontSize: 12.sp,
                                      color: Colors.orange[800],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 32.h),
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
                          'Support par Email',
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

  Widget _buildEmailCard({
    required BuildContext context,
    required String title,
    required String email,
    required String description,
    required FaIconData icon,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: _primaryGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(
                icon,
                color: _primaryGreen,
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
                  email,
                  style: getInterStyle(
                    fontSize: 14.sp,
                    color: _primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: getInterStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: email));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Email copié : $email'),
                  backgroundColor: _primaryGreen,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
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
    );
  }
}


