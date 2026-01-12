import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/auth_provider.dart';
import '../professionnel_screen/professionnel_home_screen.dart';

class InscriptionProfessionnelStep5Screen extends StatefulWidget {
  final String prenom;
  final String nom;
  final String email;
  final String telephone;
  final String dateNaissance;
  final String adresse;
  final String codePostal;
  final String ville;
  final String fonction;
  final String anneesExperience;
  final List<String> specialites;

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
    required this.fonction,
    required this.anneesExperience,
    required this.specialites,
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
    ScreenUtil.init(context, designSize: Size(375, 812));
    
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
          _buildHeader(isIPad),
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
                              'Sécuriser votre compte',
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
                              'Créez un mot de passe fort',
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
                                    'Mot de passe *',
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
                                        return 'Le mot de passe est obligatoire';
                                      }
                                      if (!_isPasswordValid) {
                                        return 'Le mot de passe ne respecte pas les critères';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  SizedBox(height: 16.h),
                                  
                                  // Critères du mot de passe
                                  _buildPasswordRequirement('Au moins 8 caractères', _hasMinLength),
                                  SizedBox(height: 6.h),
                                  _buildPasswordRequirement('Une majuscule', _hasUppercase),
                                  SizedBox(height: 6.h),
                                  _buildPasswordRequirement('Un chiffre', _hasDigit),
                                  
                                  SizedBox(height: 24.h),
                                  
                                  // Label Confirmer mot de passe
                                  Text(
                                    'Confirmer le mot de passe *',
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
                                        return 'La confirmation est obligatoire';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Les mots de passe ne correspondent pas';
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
                                                TextSpan(text: "J'accepte les "),
                                                TextSpan(
                                                  text: "conditions d'utilisation",
                                                  style: getSourceSerifProStyle(
                                                    fontSize: 13.sp,
                                                    color: Color(0xFF0059AB),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                TextSpan(text: " et la "),
                                                TextSpan(
                                                  text: "politique de confidentialité",
                                                  style: getSourceSerifProStyle(
                                                    fontSize: 13.sp,
                                                    color: Color(0xFF0059AB),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                TextSpan(text: " d'ARS"),
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
                                      'Créer mon compte',
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

  Widget _buildHeader(bool isIPad) {
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
                                'Retour',
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
                          'Étape 5/5',
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

  Widget _buildPasswordRequirement(String text, bool isMet) {
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

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        firstName: widget.prenom,
        lastName: widget.nom,
        email: widget.email,
        phone: widget.telephone,
        password: _passwordController.text,
        address: '${widget.adresse}, ${widget.codePostal} ${widget.ville}',
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Compte créé avec succès !'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ProfessionnelHomeScreen(
              userName: '${widget.prenom} ${widget.nom}',
            ),
          ),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erreur lors de la création du compte'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
