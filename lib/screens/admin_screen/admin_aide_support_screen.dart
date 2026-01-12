import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class AdminAideSupportScreen extends StatelessWidget {
  const AdminAideSupportScreen({Key? key}) : super(key: key);

  final Color _primaryPurple = const Color(0xFF7C39D3);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context, langProvider),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  children: [
                    _buildSupportCard(
                      context: context,
                      icon: FontAwesomeIcons.circleQuestion,
                      title: langProvider.translate('faq_title'),
                      subtitle: langProvider.translate('faq_subtitle'),
                      onTap: () {
                        // Action FAQ
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildSupportCard(
                      context: context,
                      icon: FontAwesomeIcons.commentDots,
                      title: langProvider.translate('contact_title'),
                      subtitle: langProvider.translate('contact_subtitle'),
                      onTap: () {
                        // Action Contact
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildSupportCard(
                      context: context,
                      icon: FontAwesomeIcons.envelope,
                      title: langProvider.translate('email_support_title'),
                      subtitle: langProvider.translate('email_support_subtitle'),
                      onTap: () {
                        // Action Email
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildSupportCard(
                      context: context,
                      icon: FontAwesomeIcons.phone,
                      title: langProvider.translate('phone_support_title'),
                      subtitle: langProvider.translate('phone_support_subtitle'),
                      onTap: () {
                        // Action Téléphone
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildHeader(BuildContext context, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: _primaryPurple),
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
                  Text(
                    langProvider.translate('help_support'),
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

  Widget _buildSupportCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                FaIcon(
                  icon,
                  color: _primaryPurple,
                  size: 26.sp,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: getInterStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: getInterStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF757575),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFFBDBDBD),
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
