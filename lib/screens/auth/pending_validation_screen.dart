import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import 'login_screen_2.dart';

class PendingValidationScreen extends StatelessWidget {
  final bool isRefused;
  final String userRole;

  const PendingValidationScreen({
    Key? key,
    this.isRefused = false,
    this.userRole = 'professionnel',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icône principale
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: isRefused
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFF3E5F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRefused
                      ? Icons.cancel_outlined
                      : Icons.access_time_rounded,
                  size: 52.sp,
                  color: isRefused
                      ? const Color(0xFFE65100)
                      : const Color(0xFF7C39D3),
                ),
              ),
              SizedBox(height: 32.h),

              // Titre
              Text(
                isRefused ? langProvider.translate('registration_refused') : langProvider.translate('pending_validation'),
                style: getSourceSerifProStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              // Description
              Text(
                isRefused
                    ? langProvider.translate('registration_refused_desc')
                    : langProvider.translate('registration_pending_desc'),
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),

              // Informations supplémentaires (uniquement si en attente)
              if (!isRefused) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.check_circle_outline,
                        langProvider.translate('account_created_success'),
                        const Color(0xFF4CAF50),
                      ),
                      SizedBox(height: 12.h),
                      _buildInfoRow(
                        Icons.description_outlined,
                        langProvider.translate('documents_submitted'),
                        const Color(0xFF7C39D3),
                      ),
                      SizedBox(height: 12.h),
                      _buildInfoRow(
                        Icons.admin_panel_settings_outlined,
                        langProvider.translate('pending_admin_validation'),
                        const Color(0xFFFFA000),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
              ],

              // Bouton retour à la connexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginScreen2()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C39D3),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    langProvider.translate('back_to_login'),
                    style: getSourceSerifProStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Contact support
              GestureDetector(
                onTap: () {},
                child: Text(
                  langProvider.translate('need_help_contact'),
                  style: getSourceSerifProStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF7C39D3),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: color),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: getSourceSerifProStyle(
              fontSize: 13.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
