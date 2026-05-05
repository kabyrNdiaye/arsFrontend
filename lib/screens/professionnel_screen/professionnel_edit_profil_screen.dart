import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../utils/font_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class ProfessionnelEditProfilScreen extends StatefulWidget {
  const ProfessionnelEditProfilScreen({Key? key}) : super(key: key);

  @override
  _ProfessionnelEditProfilScreenState createState() => _ProfessionnelEditProfilScreenState();
}

class _ProfessionnelEditProfilScreenState extends State<ProfessionnelEditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  XFile? _imageFile;
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();
  
  final Color _primaryBlue = const Color(0xFF0059AB);

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = pickedFile;
          _webImageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${langProvider.translate('photo_pick_error') ?? 'Erreur lors de la sélection de l\'image'}: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final langProvider = Provider.of<LanguageProvider>(context, listen: false);
      
      dynamic photoData;
      if (_imageFile != null && _webImageBytes != null) {
        photoData = {
          'bytes': _webImageBytes,
          'name': _imageFile!.name,
        };
      }

      final success = await authProvider.updateProfile({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        if (photoData != null) 'photo_profil_path': photoData,
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(langProvider.translate('profile_updated_success') ?? 'Profil mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'La mise à jour du profil a échoué. Vérifiez vos informations et réessayez.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final isLoading = authProvider.isLoading;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryBlue,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(isLoading, langProvider),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: isLoading ? null : _pickImage,
                        child: Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 100.w,
                                height: 100.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _primaryBlue.withOpacity(0.2),
                                      width: 2),
                                  image: _imageFile != null
                                      ? DecorationImage(
                                          image: MemoryImage(_webImageBytes!),
                                          fit: BoxFit.cover,
                                        )
                                      : (authProvider.user?.photoProfil != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  authProvider.user!.photoProfil!),
                                              fit: BoxFit.cover,
                                            )
                                          : null),
                                ),
                                child: _imageFile == null &&
                                        authProvider.user?.photoProfil == null
                                    ? Icon(Icons.person,
                                        size: 50.w, color: _primaryBlue)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: _primaryBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Icon(Icons.camera_alt,
                                      size: 16.w, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      _buildTextField(
                        label: langProvider.translate('first_name') ?? 'Prénom',
                        controller: _firstNameController,
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        label: langProvider.translate('last_name') ?? 'Nom',
                        controller: _lastNameController,
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        label: langProvider.translate('email') ?? 'Email',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        label: langProvider.translate('phone') ?? 'Téléphone',
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 40.h),
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  langProvider.translate('save_changes'),
                                  style: getInterStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLoading, LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: _primaryBlue,
      ),
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
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    langProvider.translate('modify_profile') ?? 'Modifier le profil',
                    textAlign: TextAlign.center,
                    style: getInterStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                else
                  TextButton(
                    onPressed: _saveProfile,
                    child: Text(
                      langProvider.translate('save') ?? 'Enregistrer',
                      style: getInterStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getInterStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: getInterStyle(fontSize: 15.sp),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _primaryBlue.withOpacity(0.5), size: 20.sp),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryBlue),
            ),
          ),
        ),
      ],
    );
  }
}
