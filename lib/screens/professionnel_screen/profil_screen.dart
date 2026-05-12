import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/document_provider.dart';
import '../../services/document_service.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../shared/file_preview_screen.dart';
import '../../screens/auth/login_screen_2.dart';
import 'parametres_screen.dart';
import 'professionnel_edit_profil_screen.dart';
import 'professionnel_change_password_screen.dart';
import 'professionnel_edit_documents_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfilScreen extends StatefulWidget {
  final String? userName;
  final String? userRole;
  final List<String>? initialDocuments;

  const ProfilScreen({
    Key? key,
    this.userName,
    this.userRole,
    this.initialDocuments,
  }) : super(key: key);

  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DocumentProvider>(context, listen: false).fetchDocuments();
    });
  }

  List<Map<String, String?>> _getDocuments(LanguageProvider langProvider) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final docs = <Map<String, String?>>[];

    // Helper : extrait le nom de fichier depuis une URL pour la déduplication
    String _fileNameFromUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      return url.split('/').last.split('?').first.toLowerCase();
    }

    // Helper : ajoute un doc seulement s'il n'est pas déjà présent
    void addIfNew(String title, String? url) {
      if (url == null || url.isEmpty) return;
      final fileName = _fileNameFromUrl(url);
      final alreadyExists = docs.any((d) {
        if (d['url'] == url) return true;
        if (fileName.isNotEmpty && _fileNameFromUrl(d['url']) == fileName) return true;
        return false;
      });
      if (!alreadyExists) {
        docs.add({'title': title, 'url': url});
      }
    }

    // charger les documents depuis le Provider (qui contient les vrais DocumentItem)
    final docProvider = Provider.of<DocumentProvider>(context);
    final List<DocumentItem> apiDocs = docProvider.apiDocuments;

    if (apiDocs.isNotEmpty) {
      for (var d in apiDocs) {
        addIfNew(d.displayName, d.url);
      }
    } else {
      // Fallback sur user (legacy) ou placeholder
      addIfNew(langProvider.translate('cook_diploma') ?? 'Diplôme de cuisine', user?.diplomePath);
      addIfNew(langProvider.translate('medical_cert') ?? 'Certificat médical', user?.certificatMedical);
      addIfNew(langProvider.translate('driving_license') ?? 'Permis de conduire', user?.permiConduire);

      if (docs.isEmpty) {
        docs.addAll([
          {'title': langProvider.translate('cv') ?? 'Curriculum Vitae(CV)', 'url': null},
          {'title': langProvider.translate('id_card') ?? 'Carte d\'identité', 'url': null},
          {'title': langProvider.translate('cook_diploma') ?? 'Diplôme de cuisine', 'url': null},
        ]);
      }
    }

    return docs;
  }

  Future<void> _ajouterDocument(LanguageProvider langProvider) async {
    final docProvider = Provider.of<DocumentProvider>(context, listen: false);
    
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        withData: kIsWeb,
      );
 
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        setState(() => _isLoading = true);
        
        final success = await docProvider.uploadDocument(
          kIsWeb ? null : file.path,
          'autre',
          fileBytes: file.bytes,
          fileName: file.name,
        );
        
        setState(() => _isLoading = false);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${langProvider.translate('doc_added') ?? 'Document ajouté'} : ${file.name}'),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
            // On rafraîchit aussi le User pour être sûr
            Provider.of<AuthProvider>(context, listen: false).loadProfile();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: ${docProvider.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(langProvider.translate('doc_error') ?? 'Erreur lors de l\'ajout du document'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deconnexion() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen2()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0059AB),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Column(
          children: [
            _buildHeader(langProvider),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    _buildDocumentsSection(langProvider),
                    SizedBox(height: 16.h),
                    _buildParametresSection(langProvider),
                    SizedBox(height: 16.h),
                    _buildCompteSection(langProvider),
                    SizedBox(height: 16.h),
                    _buildDeconnexionButton(langProvider),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider langProvider) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF0059AB),
      ),
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
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
              child: Column(
                children: [
                  Container(
                    width: 90.w,
                    height: 90.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: user?.photoProfil != null
                          ? Image.network(
                              user!.photoProfil!,
                              width: 90.w,
                              height: 90.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderAvatar(),
                            )
                          : Image.asset(
                              'assets/images/icon_personne.png',
                              width: 90.w,
                              height: 90.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderAvatar(),
                            ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    user?.fullName ?? langProvider.translate('default_user') ?? 'Utilisateur',
                    style: getInterStyle(
                      fontSize: 22.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user?.email ?? langProvider.translate('default_role') ?? 'Email',
                    style: getInterStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
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

  Widget _buildDocumentsSection(LanguageProvider langProvider) {
    final docs = _getDocuments(langProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600; // tablette ou web

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            langProvider.translate('documents') ?? 'Documents',
            style: getInterStyle(
              fontSize: 15.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          if (isWide)
            // Grille 2 colonnes pour tablette / web
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 4.5,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                return _buildDocumentItem(doc['title']!, doc['url'], langProvider);
              },
            )
          else
            // Liste linéaire pour mobile
            ...docs.map((doc) => _buildDocumentItem(doc['title']!, doc['url'], langProvider)).toList(),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () => _ajouterDocument(langProvider),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Color(0xFF0059AB),
                    size: 18.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    langProvider.translate('add_document') ?? 'Ajouter un document',
                    style: getInterStyle(
                      fontSize: 13.sp,
                      color: Color(0xFF0059AB),
                      fontWeight: FontWeight.w500,
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


  Widget _buildDocumentItem(String title, String? url, LanguageProvider langProvider) {
    return GestureDetector(
      onTap: () {
        if (url != null && url.isNotEmpty) {
          // Détection robuste de l'extension
          final String cleanUrl = url.split('?').first;
          final String ext = cleanUrl.contains('.') ? cleanUrl.split('.').last.toLowerCase() : '';
          final String fileType = (ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'webp') ? 'image' : 'pdf';
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilePreviewScreen(
                fileUrl: url,
                fileName: title,
                fileType: fileType,
                authToken: ApiService().token,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(langProvider.translate('doc_not_uploaded') ?? 'Document non téléchargé'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: getInterStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParametresSection(LanguageProvider langProvider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ParametresScreen()),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                langProvider.translate('settings') ?? 'Paramètres',
                style: getInterStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompteSection(LanguageProvider langProvider) {
    const Color primaryBlue = Color(0xFF0059AB);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 8.h),
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
          _buildCompteItem(
            icon: Icons.person_outline,
            title: langProvider.translate('modify_info') ?? 'Modifier mes informations',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfessionnelEditProfilScreen()),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[100], indent: 56.w),
          _buildCompteItem(
            icon: Icons.description_outlined,
            title: 'Modifier mes documents',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessionnelEditDocumentsScreen(),
                ),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[100], indent: 56.w),
          _buildCompteItem(
            icon: Icons.lock_outline,
            title: langProvider.translate('change_password') ?? 'Changer mon mot de passe',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfessionnelChangePasswordScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompteItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    const Color primaryBlue = Color(0xFF0059AB);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryBlue, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: getInterStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeconnexionButton(LanguageProvider langProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: _deconnexion,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                color: Color(0xFFE53935),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                langProvider.translate('logout') ?? 'Se déconnecter',
                style: getInterStyle(
                  fontSize: 14.sp,
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: Colors.white,
      child: Icon(
        Icons.person_outline,
        size: 50.sp,
        color: const Color(0xFF90CAF9),
      ),
    );
  }
}
