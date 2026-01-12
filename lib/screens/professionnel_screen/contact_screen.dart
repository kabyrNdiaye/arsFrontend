import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _sujetController = TextEditingController();
  final _messageController = TextEditingController();

  final Color _primaryGreen = const Color(0xFF4CA054);
  String? _selectedCategorie;
  
  List<String> _getTranslatedCategories(LanguageProvider langProvider) {
    return [
      langProvider.translate('gen_question'),
      langProvider.translate('tech_prob'),
      langProvider.translate('mission'),
      langProvider.translate('billing'),
      langProvider.translate('other'),
    ];
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _sujetController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _envoyerMessage(LanguageProvider langProvider) {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('message_sent')),
          backgroundColor: _primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    
    final categories = _getTranslatedCategories(langProvider);
    if (_selectedCategorie == null || !categories.contains(_selectedCategorie)) {
      _selectedCategorie = categories[0];
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Header vert
            _buildHeader(context, langProvider),
            
            // Formulaire
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: _primaryGreen.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _primaryGreen.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: _primaryGreen, size: 20.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                langProvider.translate('fill_form'),
                                style: getInterStyle(
                                  fontSize: 13.sp,
                                  color: _primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 32.h),
                      
                      _buildLabel(langProvider.translate('full_name')),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _nomController,
                        hint: langProvider.translate('name_hint'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return langProvider.translate('error_name');
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 20.h),
                      
                      _buildLabel(langProvider.translate('email')),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _emailController,
                        hint: langProvider.translate('email_hint'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return langProvider.translate('error_email');
                          }
                          if (!value.contains('@')) {
                            return langProvider.translate('error_email_invalid');
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 20.h),
                      
                      _buildLabel(langProvider.translate('category')),
                      SizedBox(height: 8.h),
                      _buildDropdown(categories),
                      
                      SizedBox(height: 20.h),
                      
                      _buildLabel(langProvider.translate('subject')),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _sujetController,
                        hint: langProvider.translate('subject_hint'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return langProvider.translate('error_subject');
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 20.h),
                      
                      _buildLabel(langProvider.translate('message')),
                      SizedBox(height: 8.h),
                      _buildTextArea(langProvider),
                      
                      SizedBox(height: 40.h),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: () => _envoyerMessage(langProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            langProvider.translate('send_message'),
                            style: getInterStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
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
                          langProvider.translate('contact_title'),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: getInterStyle(
        fontSize: 14.sp,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: getInterStyle(
          fontSize: 14.sp,
          color: Colors.grey[400],
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      style: getInterStyle(
        fontSize: 14.sp,
        color: Colors.black87,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildDropdown(List<String> categories) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategorie,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          items: categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(
                category,
                style: getInterStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategorie = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextArea(LanguageProvider langProvider) {
    return TextFormField(
      controller: _messageController,
      maxLines: 5,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return langProvider.translate('error_message');
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: langProvider.translate('message_hint'),
        hintStyle: getInterStyle(
          fontSize: 14.sp,
          color: Colors.grey[400],
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.all(16.w),
      ),
      style: getInterStyle(
        fontSize: 14.sp,
        color: Colors.black87,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}


