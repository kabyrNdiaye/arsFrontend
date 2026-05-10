import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import 'package:provider/provider.dart';

class ClientAideSupportScreen extends StatelessWidget {
  const ClientAideSupportScreen({Key? key}) : super(key: key);

  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const _ClientFaqScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildSupportCard(
                      context: context,
                      icon: FontAwesomeIcons.commentDots,
                      title: langProvider.translate('contact_title'),
                      subtitle: langProvider.translate('contact_subtitle'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const _ClientContactScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildSupportCard(
                      context: context,
                      icon: FontAwesomeIcons.envelope,
                      title: langProvider.translate('email_support_title'),
                      subtitle: langProvider.translate('email_support_subtitle'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const _ClientEmailSupportScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildSupportCard(
                      context: context,
                      icon: FontAwesomeIcons.phone,
                      title: langProvider.translate('phone_support_title'),
                      subtitle: langProvider.translate('phone_support_subtitle'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const _ClientSupportTelScreen()),
                        );
                      },
                    ),
                  ],
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
    required FaIconData icon,
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
                  color: _primaryGreen,
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

class _ClientFaqScreen extends StatelessWidget {
  const _ClientFaqScreen({Key? key}) : super(key: key);
  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context, langProvider.translate('faq_title'), langProvider),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _buildFaqItem(langProvider.translate('faq_q1'), langProvider.translate('faq_a1')),
                  _buildFaqItem(langProvider.translate('faq_q2'), langProvider.translate('faq_a2')),
                  _buildFaqItem(langProvider.translate('faq_q3'), langProvider.translate('faq_a3')),
                  _buildFaqItem(langProvider.translate('faq_q4'), langProvider.translate('faq_a4')),
                  _buildFaqItem(langProvider.translate('faq_q5'), langProvider.translate('faq_a5')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      color: _primaryGreen,
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
                  child: Row(children: [Icon(Icons.arrow_back, color: Colors.white, size: 20.sp), SizedBox(width: 4.w), Text(langProvider.translate('back'), style: getInterStyle(fontSize: 14.sp, color: Colors.white))]),
                ),
                Expanded(child: Center(child: Text(title, style: getInterStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)))),
                SizedBox(width: 60.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: getInterStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
      iconColor: _primaryGreen,
      collapsedIconColor: Colors.grey,
      children: [
        Padding(padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h), child: Text(answer, style: getInterStyle(fontSize: 13.sp, color: Colors.grey[600], height: 1.5))),
      ],
    );
  }
}

class _ClientContactScreen extends StatelessWidget {
  const _ClientContactScreen({Key? key}) : super(key: key);
  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context, langProvider.translate('contact_title'), langProvider),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(langProvider.translate('contact_us_msg'), style: getInterStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 20.h),
                    _buildTextField(langProvider.translate('subject_label'), langProvider),
                    SizedBox(height: 16.h),
                    _buildTextField(langProvider.translate('message_label'), langProvider, maxLines: 5),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(langProvider.translate('message_sent')), backgroundColor: _primaryGreen));
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text(langProvider.translate('send'), style: getInterStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      color: _primaryGreen,
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
                  child: Row(children: [Icon(Icons.arrow_back, color: Colors.white, size: 20.sp), SizedBox(width: 4.w), Text(langProvider.translate('back'), style: getInterStyle(fontSize: 14.sp, color: Colors.white))]),
                ),
                Expanded(child: Center(child: Text(title, style: getInterStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)))),
                SizedBox(width: 60.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, LanguageProvider langProvider, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: getInterStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.h),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: '${langProvider.translate('enter_your')} ${label.toLowerCase()}',
            hintStyle: getInterStyle(fontSize: 14.sp, color: Colors.grey[400]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: const Color(0xFF4CA054), width: 2)),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
      ],
    );
  }
}

class _ClientEmailSupportScreen extends StatelessWidget {
  const _ClientEmailSupportScreen({Key? key}) : super(key: key);
  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context, langProvider.translate('email_support_title'), langProvider),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Icon(Icons.email, color: _primaryGreen, size: 48.sp),
                          SizedBox(height: 16.h),
                          Text('support@ars.com', style: getInterStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                          SizedBox(height: 8.h),
                          Text(langProvider.translate('email_support_desc'), style: getInterStyle(fontSize: 14.sp, color: Colors.grey[600]), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(langProvider.translate('email_tips_title'), style: getInterStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 16.h),
                    _buildTip(langProvider.translate('tip1')),
                    _buildTip(langProvider.translate('tip2')),
                    _buildTip(langProvider.translate('tip3')),
                    _buildTip(langProvider.translate('tip4')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      color: _primaryGreen,
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
                  child: Row(children: [Icon(Icons.arrow_back, color: Colors.white, size: 20.sp), SizedBox(width: 4.w), Text(langProvider.translate('back'), style: getInterStyle(fontSize: 14.sp, color: Colors.white))]),
                ),
                Expanded(child: Center(child: Text(title, style: getInterStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)))),
                SizedBox(width: 60.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(padding: EdgeInsets.only(bottom: 12.h), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.check_circle, color: _primaryGreen, size: 20.sp), SizedBox(width: 12.w), Expanded(child: Text(text, style: getInterStyle(fontSize: 14.sp, color: Colors.black87)))]));
  }
}

class _ClientSupportTelScreen extends StatelessWidget {
  const _ClientSupportTelScreen({Key? key}) : super(key: key);
  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context, langProvider.translate('phone_support_title'), langProvider),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Icon(Icons.phone, color: _primaryGreen, size: 48.sp),
                          SizedBox(height: 16.h),
                          Text('+33 1 23 45 67 89', style: getInterStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                          SizedBox(height: 8.h),
                          Text(langProvider.translate('phone_support_subtitle'), style: getInterStyle(fontSize: 14.sp, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(langProvider.translate('opening_hours'), style: getInterStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 16.h),
                    _buildHoraire('Lundi - Vendredi', '8h00 - 20h00', langProvider),
                    _buildHoraire('Samedi', '9h00 - 18h00', langProvider),
                    _buildHoraire('Dimanche', langProvider.translate('closed'), langProvider),
                    SizedBox(height: 24.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange[200]!)),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[700], size: 20.sp),
                          SizedBox(width: 12.w),
                          Expanded(child: Text(langProvider.translate('emergency_notice'), style: getInterStyle(fontSize: 12.sp, color: Colors.orange[800]))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      color: _primaryGreen,
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
                  child: Row(children: [Icon(Icons.arrow_back, color: Colors.white, size: 20.sp), SizedBox(width: 4.w), Text(langProvider.translate('back'), style: getInterStyle(fontSize: 14.sp, color: Colors.white))]),
                ),
                Expanded(child: Center(child: Text(title, style: getInterStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)))),
                SizedBox(width: 60.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoraire(String jour, String horaire, LanguageProvider langProvider) {
    return Padding(padding: EdgeInsets.only(bottom: 12.h), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(jour, style: getInterStyle(fontSize: 14.sp, color: Colors.black87)), Text(horaire, style: getInterStyle(fontSize: 14.sp, color: horaire == langProvider.translate('closed') ? Colors.red : _primaryGreen, fontWeight: FontWeight.w600))]));
  }
}
