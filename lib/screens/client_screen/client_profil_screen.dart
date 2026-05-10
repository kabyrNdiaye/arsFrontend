import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import '../auth/login_screen_2.dart';
import 'client_parametres_screen.dart';

class ClientProfilScreen extends StatefulWidget {
  final String? userName;
  final String? userRole;
  final String? etablissementName;
  // Documents uploadés durant l'inscription (passés en paramètre)
  final List<String>? initialDocuments;

  const ClientProfilScreen({
    Key? key,
    this.userName,
    this.userRole,
    this.etablissementName,
    this.initialDocuments,
  }) : super(key: key);

  @override
  _ClientProfilScreenState createState() => _ClientProfilScreenState();
}

class _ClientProfilScreenState extends State<ClientProfilScreen> {
  // Liste des documents (initialisée avec les documents de l'inscription)
  late List<String> _documents;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final langProvider = Provider.of<LanguageProvider>(context);
    // Initialiser avec les documents de l'inscription ou des données par défaut pour client
    _documents = widget.initialDocuments ?? [
      langProvider.translate('service_contract'),
      langProvider.translate('premises_plan'),
      langProvider.translate('internal_rules'),
    ];
  }

  // Fonction pour ajouter un document
  Future<void> _ajouterDocument() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final langProvider = Provider.of<LanguageProvider>(context, listen: false);
        setState(() {
          _documents.add(result.files.first.name);
        });
        
        // Afficher un message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(langProvider.translate('document_added')),
            backgroundColor: Color(0xFF4CA054),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      final langProvider = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('error_adding_document')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fonction de déconnexion
  void _deconnexion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen2()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF4CA054), // Vert pour le client
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Column(
          children: [
            // Header vert avec avatar
            _buildHeader(langProvider),
            
            // Contenu
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    
                    // Section Documents
                    _buildDocumentsSection(langProvider),
                    
                    SizedBox(height: 16.h),
                    
                    // Section Paramètres
                    _buildParametresSection(langProvider),
                    
                    SizedBox(height: 16.h),
                    
                    // Bouton Déconnexion
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF4CA054), // Vert pour le client
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          children: [
            // Trait horizontal en haut, juste sous la barre de statut
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
                  // Avatar
                  Container(
                    width: 90.w,
                    height: 90.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/icon_person.png',
                        width: 90.w,
                        height: 90.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white,
                            child: Icon(
                              Icons.person_outline,
                              size: 50.sp,
                              color: Color(0xFF4CA054),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Nom
                  Text(
                    widget.userName ?? 'Marie Dubois',
                    style: getInterStyle(
                      fontSize: 22.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Rôle et établissement
                  Text(
                    widget.userRole ?? langProvider.translate('directeur'),
                    style: getInterStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  if (widget.etablissementName != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      widget.etablissementName!,
                      style: getInterStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(LanguageProvider langProvider) {
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
            langProvider.translate('documents'),
            style: getInterStyle(
              fontSize: 15.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          // Liste des documents
          ..._documents.map((doc) => _buildDocumentItem(doc, langProvider)).toList(),
          
          SizedBox(height: 8.h),
          
          // Bouton Ajouter un document
          GestureDetector(
            onTap: _ajouterDocument,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9), // Vert clair
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Color(0xFF4CA054),
                    size: 18.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    langProvider.translate('add_document'),
                    style: getInterStyle(
                      fontSize: 13.sp,
                      color: Color(0xFF4CA054),
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

  Widget _buildDocumentItem(String title, LanguageProvider langProvider) {
    return GestureDetector(
      onTap: () {
        // Action voir document
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(langProvider.translate('opening') + ' "$title"'),
            duration: Duration(seconds: 1),
          ),
        );
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
            MaterialPageRoute(builder: (context) => ClientParametresScreen()),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                langProvider.translate('settings'),
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

  Widget _buildDeconnexionButton(LanguageProvider langProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: _deconnexion, // Déconnexion directe
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
                langProvider.translate('logout'),
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
}
