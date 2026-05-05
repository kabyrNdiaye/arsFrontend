import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/font_helper.dart';
import 'login_screen_2.dart';
import 'reset_password_screen.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      final authService = AuthService();
      final result = await authService.forgotPassword(_emailController.text.trim());
      
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        setState(() {
          _emailSent = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de l\'envoi de l\'email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    
    double maxWidth;
    if (isDesktop) {
      maxWidth = 500;
    } else if (isTablet) {
      maxWidth = 550;
    } else {
      maxWidth = double.infinity;
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 40.h),
                          
                          // Icône de cadenas
                          Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: Color(0xFF0059AB).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              size: 40.sp,
                              color: Color(0xFF0059AB),
                            ),
                          ),
                          
                          SizedBox(height: 30.h),
                          
                          // Titre
                          Text(
                            langProvider.translate('forgot_password'),
                            style: getSourceSerifProStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: 16.h),
                          
                          // Description
                          if (!_emailSent)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Text(
                                langProvider.translate('forgot_password_desc'),
                                style: getSourceSerifProStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          
                          if (_emailSent)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE2FBE9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Color(0xFF4CA054),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: const Color(0xFF4CA054),
                                          size: 24.sp,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            langProvider.translate('email_sent_title'),
                                            style: getSourceSerifProStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF4CA054),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    '${langProvider.translate('email_sent_desc1')} ${_emailController.text}',
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    langProvider.translate('email_sent_desc2'),
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          
                          SizedBox(height: 40.h),
                          
                          if (!_emailSent) ...[
                            // Champ Email
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 400.w),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: langProvider.translate('email'),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF0059AB), width: 2),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                ),
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
                            ),
                            
                            SizedBox(height: 30.h),
                            
                            // Bouton Envoyer
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 400.w),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleResetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF0059AB),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20.h,
                                          width: 20.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          langProvider.translate('send_link'),
                                          style: getSourceSerifProStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                          
                          if (_emailSent) ...[
                            SizedBox(height: 20.h),
                            
                             // Bouton Retour à la connexion
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 400.w),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResetPasswordScreen(
                                          email: _emailController.text.trim(),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF0059AB),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Saisir le code',
                                    style: getSourceSerifProStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 12.h),

                            // Bouton Retour à la connexion
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 400.w),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginScreen2()),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    side: BorderSide(color: Color(0xFF0059AB)),
                                  ),
                                  child: Text(
                                    langProvider.translate('back_to_login'),
                                    style: getSourceSerifProStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0059AB),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            // Lien pour renvoyer l'email
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _emailSent = false;
                                });
                              },
                              child: Text(
                                langProvider.translate('resend_email'),
                                style: getSourceSerifProStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF0059AB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}








