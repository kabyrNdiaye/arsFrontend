import 'package:flutter/material.dart';
import '../../providers/language_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen_2.dart';

class InscriptionProfessionnelStep5Screen extends StatefulWidget {
  final String prenom;
  final String nom;
  final String email;
  final String telephone;
  final String dateNaissance;
  final String adresse;
  final String codePostal;
  final String ville;
  final String fonction; // Ajouté
  // final String? numeroSecuriteSociale; // Supprimé
  final String? diplome;
  final String? anneesExperience; // Peut être null si parsé depuis String
  final List<String> specialites;
  final dynamic photoProfilPath; // Modifié en dynamic
  final dynamic diplomePath; // List<PlatformFile>? ou PlatformFile?
  final dynamic certificatMedicalPath; // Modifié en dynamic
  final dynamic permisConduirePath; // Modifié en dynamic

  const InscriptionProfessionnelStep5Screen({
    Key? key,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.dateNaissance,
    required this.adresse,
    required this.codePostal,
    required this.ville,
    required this.fonction, // Ajouté
    // this.numeroSecuriteSociale, // Supprimé
    this.diplome,
    this.anneesExperience,
    required this.specialites,
    this.photoProfilPath,
    this.diplomePath,
    this.certificatMedicalPath,
    this.permisConduirePath,
  }) : super(key: key);

  @override
  _InscriptionProfessionnelStep5ScreenState createState() => _InscriptionProfessionnelStep5ScreenState();
}

class _InscriptionProfessionnelStep5ScreenState extends State<InscriptionProfessionnelStep5Screen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Vérification des critères du mot de passe
  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _isPasswordValid => _hasMinLength && _hasUppercase && _hasDigit;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isIPad = shortestSide >= 600 && shortestSide <= 1024;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(isIPad, lang),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isIPad ? 40.w : 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: isIPad ? 40.h : 30.h),
                            
                            // Icône cadenas
                            Container(
                              width: isIPad ? 80.w : 70.w,
                              height: isIPad ? 80.h : 70.h,
                              decoration: BoxDecoration(
                                color: Color(0xFFE3F2FD),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock,
                                color: Color(0xFF0059AB),
                                size: isIPad ? 40.sp : 35.sp,
                              ),
                            ),
                            
                            SizedBox(height: isIPad ? 24.h : 20.h),
                            
                            // Titre
                            Text(
                              lang.translate('secure_account_title'),
                              style: getSourceSerifProStyle(
                                fontSize: isIPad ? 22.sp : 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            // Sous-titre
                            Text(
                              lang.translate('create_strong_pw'),
                              style: getSourceSerifProStyle(
                                fontSize: isIPad ? 14.sp : 13.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: isIPad ? 40.h : 32.h),
                            
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Label Mot de passe
                                  Text(
                                    '${lang.translate('password')} *',
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  
                                  // Champ mot de passe
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      hintText: '••••••••••',
                                      hintStyle: getSourceSerifProStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[400],
                                      ),
                                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500], size: 20.sp),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: Colors.grey[500],
                                          size: 20.sp,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
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
                                        borderSide: BorderSide(color: Color(0xFF0059AB), width: 1.5),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                    ),
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return lang.translate('pw_required_err');
                                      }
                                      if (!_isPasswordValid) {
                                        return lang.translate('pw_criteria_err');
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  SizedBox(height: 16.h),
                                  
                                  // Critères du mot de passe
                                  _buildPasswordRequirement(lang.translate('at_least_8_chars'), _hasMinLength, lang),
                                  SizedBox(height: 6.h),
                                  _buildPasswordRequirement(lang.translate('one_uppercase'), _hasUppercase, lang),
                                  SizedBox(height: 6.h),
                                  _buildPasswordRequirement(lang.translate('one_digit'), _hasDigit, lang),
                                  
                                  SizedBox(height: 24.h),
                                  
                                  // Label Confirmer mot de passe
                                  Text(
                                    '${lang.translate('confirm_password')} *',
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  
                                  // Champ confirmation mot de passe
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    decoration: InputDecoration(
                                      hintText: '••••••••••',
                                      hintStyle: getSourceSerifProStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[400],
                                      ),
                                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500], size: 20.sp),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: Colors.grey[500],
                                          size: 20.sp,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword = !_obscureConfirmPassword;
                                          });
                                        },
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
                                        borderSide: BorderSide(color: Color(0xFF0059AB), width: 1.5),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                    ),
                                    style: getSourceSerifProStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return lang.translate('confirm_required_err');
                                      }
                                      if (value != _passwordController.text) {
                                        return lang.translate('pw_mismatch_err');
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  SizedBox(height: 28.h),
                                  
                                  // Checkbox conditions d'utilisation
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _acceptTerms = !_acceptTerms;
                                          });
                                        },
                                        child: Container(
                                          width: 22.w,
                                          height: 22.h,
                                          decoration: BoxDecoration(
                                            color: _acceptTerms ? Color(0xFF0059AB) : Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: _acceptTerms ? Color(0xFF0059AB) : Colors.grey[400]!,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: _acceptTerms
                                              ? Icon(
                                                  Icons.check,
                                                  size: 16.sp,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _acceptTerms = !_acceptTerms;
                                            });
                                          },
                                          child: RichText(
                                            text: TextSpan(
                                              style: getSourceSerifProStyle(
                                                fontSize: 13.sp,
                                                color: Colors.grey[700],
                                                height: 1.4,
                                              ),
                                              children: [
                                                TextSpan(text: lang.translate('i_accept_prefix')),
                                                TextSpan(
                                                  text: lang.translate('accept_terms'),
                                                  style: getSourceSerifProStyle(
                                                    fontSize: 13.sp,
                                                    color: Color(0xFF0059AB),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                TextSpan(text: lang.translate('and_the_privacy')),
                                                TextSpan(
                                                  text: lang.translate('privacy_policy'),
                                                  style: getSourceSerifProStyle(
                                                    fontSize: 13.sp,
                                                    color: Color(0xFF0059AB),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                TextSpan(text: lang.translate('of_ars_suffix')),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isIPad ? 30.h : 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Bouton Créer mon compte
                  Padding(
                    padding: EdgeInsets.all(isIPad ? 20.w : 16.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isIPad ? 360.w : 300.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _acceptTerms && !_isLoading ? () async {
                            if (_formKey.currentState!.validate()) {
                              await _register();
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0059AB),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            disabledForegroundColor: Colors.grey[600],
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 22.sp,
                                      color: _acceptTerms ? Colors.white : Colors.grey[600],
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      lang.translate('create_account_btn'),
                                      style: getSourceSerifProStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                        color: _acceptTerms ? Colors.white : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isIPad, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      height: 100.h,
      color: const Color(0xFF0059AB),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Trait horizontal en haut
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top > 0 ? 8.h : 32.h,
                left: 12.w,
                right: 12.w,
              ),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // Flèche retour et "Retour" à gauche, "Étape 5/5" à droite
                  Positioned(
                    bottom: 20.h,
                    left: 16.w,
                    right: 16.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Retour à gauche
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios, color: Colors.white, size: 18.sp),
                              SizedBox(width: 4.w),
                              Text(
                                lang.translate('back'),
                                style: getSourceSerifProStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Étape 5/5 à droite
                        Text(
                          '${lang.translate('step')} 5/5',
                          style: getSourceSerifProStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Barre de progression
                  Positioned(
                    bottom: 6.h,
                    left: 16.w,
                    right: 16.w,
                    child: Container(
                      height: 4.h,
                      child: Stack(
                        children: [
                          // Ligne de fond
                          Container(
                            width: double.infinity,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2.h),
                            ),
                          ),
                          // Ligne de progression (100%)
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 1.0,
                            child: Container(
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2.h),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildPasswordRequirement(String text, bool isMet, LanguageProvider lang) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMet ? Color(0xFF4CAF50) : Colors.grey[400],
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          text,
          style: getSourceSerifProStyle(
            fontSize: 12.sp,
            color: isMet ? Color(0xFF4CAF50) : Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Helper pour convertir la date française (JJ/MM/AAAA) en format API (AAAA-MM-JJ)
  String _formatDateForApi(String dateFr) {
    try {
      if (dateFr.isEmpty) return '';
      // Suppose format JJ/MM/AAAA
      final parts = dateFr.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      return dateFr; // Retourne tel quel si format non reconnu
    } catch (e) {
      return dateFr;
    }
  }

  // Helper pour convertir l'expérience texte en entier
  String _convertExperienceToInt(String? experience) {
    if (experience == null) return '0';
    if (experience == 'under_2_years') return '1';
    if (experience == '2_to_5_years') return '3';
    if (experience == '5_to_10_years') return '7';
    if (experience == 'over_10_years') return '11';
    return '0';
  }

  Future<void> _register() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Conversion des formats
      final formattedDate = _formatDateForApi(widget.dateNaissance);
      final numericExperience = _convertExperienceToInt(widget.anneesExperience);

      // Construire l'adresse complète
      final fullAddress = '${widget.adresse}, ${widget.codePostal} ${widget.ville}';

      final success = await authProvider.register(
        firstName: widget.prenom,
        lastName: widget.nom,
        email: widget.email,
        phone: widget.telephone,
        password: _passwordController.text,
        address: fullAddress,
        role: 'professionnel',
        fonction: widget.fonction, // Ajouté
        // Données spécifiques professionnel
        dateNaissance: formattedDate,
        codePostal: widget.codePostal,
        ville: widget.ville,
        diplome: widget.diplome,
        anneesExperience: numericExperience,
        specialites: widget.specialites, // Ajouté
        photoProfilPath: widget.photoProfilPath,
        diplomePaths: widget.diplomePath is List ? widget.diplomePath : (widget.diplomePath != null ? [widget.diplomePath] : null),
        certificatMedicalPath: widget.certificatMedicalPath,
        permisConduirePath: widget.permisConduirePath,
      );

      if (success && mounted) {
        // Déconnecter l'utilisateur pour forcer une connexion manuelle
        await authProvider.logout();

        // Afficher le dialogue de succès
        _showSuccessDialog();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? lang.translate('registration_error')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${lang.translate('error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text(lang.translate('registration_success')),
            ],
          ),
          content: Text(
            lang.translate('reg_success_pro_desc'),
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: Text(
                lang.translate('login_btn'),
                style: TextStyle(color: Color(0xFF0059AB), fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen2()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
