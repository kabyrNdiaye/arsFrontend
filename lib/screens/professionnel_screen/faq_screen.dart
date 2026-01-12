import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final Color _primaryGreen = const Color(0xFF4CA054);
  List<Map<String, dynamic>> _getTranslatedFaqs(LanguageProvider langProvider) {
    return [
      {
        'question': langProvider.translate('faq_q1'),
        'answer': langProvider.translate('faq_a1'),
        'isExpanded': false,
      },
      {
        'question': langProvider.translate('faq_q2'),
        'answer': langProvider.translate('faq_a2'),
        'isExpanded': false,
      },
      {
        'question': langProvider.translate('faq_q3'),
        'answer': langProvider.translate('faq_a3'),
        'isExpanded': false,
      },
      {
        'question': langProvider.translate('faq_q4'),
        'answer': langProvider.translate('faq_a4'),
        'isExpanded': false,
      },
      {
        'question': langProvider.translate('faq_q5'),
        'answer': langProvider.translate('faq_a5'),
        'isExpanded': false,
      },
      {
        'question': langProvider.translate('faq_q6'),
        'answer': langProvider.translate('faq_a6'),
        'isExpanded': false,
      },
    ];
  }

  late List<Map<String, dynamic>> _faqs;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final langProvider = Provider.of<LanguageProvider>(context);
      _faqs = _getTranslatedFaqs(langProvider);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    
    // Mettre à jour les FAQ si la langue change
    _faqs = _getTranslatedFaqs(langProvider);

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Header vert
            _buildHeader(context, langProvider),
            
            // Contenu
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _faqs.length,
                itemBuilder: (context, index) {
                  return _buildFAQItem(index);
                },
              ),
            ),
          ],
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
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 64.w),
                        child: Text(
                          langProvider.translate('faq_title'),
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

  Widget _buildFAQItem(int index) {
    final faq = _faqs[index];
    final isExpanded = faq['isExpanded'] as bool;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question
          GestureDetector(
            onTap: () {
              setState(() {
                _faqs[index]['isExpanded'] = !isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faq['question'],
                      style: getInterStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: _primaryGreen,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          
          // Réponse (visible si expanded)
          if (isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Text(
                faq['answer'],
                style: getInterStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


