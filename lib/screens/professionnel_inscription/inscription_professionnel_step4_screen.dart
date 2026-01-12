import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/font_helper.dart';
import 'inscription_professionnel_step5_screen.dart';

class InscriptionProfessionnelStep4Screen extends StatefulWidget {
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

  const InscriptionProfessionnelStep4Screen({
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
  _InscriptionProfessionnelStep4ScreenState createState() => _InscriptionProfessionnelStep4ScreenState();
}

class _InscriptionProfessionnelStep4ScreenState extends State<InscriptionProfessionnelStep4Screen> {
  String? _photoProfil;
  List<String> _diplomes = [];
  String? _certificatMedical;
  String? _permisConduire;

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
                            // Icône dossier
                            Container(
                              width: isIPad ? 80.w : 70.w,
                              height: isIPad ? 80.h : 70.h,
                              decoration: BoxDecoration(
                                color: Color(0xFFE0F7FA),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/icon_dossier.png',
                                  width: isIPad ? 80.w : 70.w,
                                  height: isIPad ? 80.h : 70.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.description_outlined,
                                      color: Color(0xFF0059AB),
                                      size: isIPad ? 40.sp : 35.sp,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: isIPad ? 24.h : 20.h),
                            Text(
                              'Documents requis',
                              style: getSourceSerifProStyle(
                                fontSize: isIPad ? 22.sp : 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Chargez vos documents professionnels',
                              style: getSourceSerifProStyle(
                                fontSize: isIPad ? 14.sp : 13.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20.h),
                            
                            // Note info box
                            Center(
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 340.w),
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Color(0xFF0059AB),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Note : ',
                                      style: getSourceSerifProStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0059AB),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Vous pourrez ajouter ces documents plus tard depuis votre profil si vous ne les avez pas maintenant',
                                        style: getSourceSerifProStyle(
                                          fontSize: 12.sp,
                                          color: Color(0xFF0059AB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 24.h),
                            
                            // Photo de profil
                            _buildDocumentUpload(
                              title: 'Photo de profil',
                              subtitle: 'Format JPG ou PNG',
                              icon: Icons.camera_alt_outlined,
                              iconPath: 'assets/images/icon_photo.png',
                              buttonText: 'Ajouter une photo',
                              fileName: _photoProfil,
                              isRequired: false,
                              onTap: () => _pickFile('photo'),
                              onRemove: () {
                                setState(() {
                                  _photoProfil = null;
                                });
                              },
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            // Diplômes de cuisine
                            _buildDocumentUpload(
                              title: 'Diplômes de cuisine',
                              subtitle: 'CAP, BEP, BAC, PRO, etc',
                              icon: Icons.upload_file_outlined,
                              iconPath: 'assets/images/icon_trelechargement.png',
                              buttonText: 'Ajouter vos diplômes',
                              fileNames: _diplomes,
                              isRequired: false,
                              isMultiple: true,
                              onTap: () => _pickFile('diplomes'),
                              onRemoveMultiple: (index) {
                                setState(() {
                                  _diplomes.removeAt(index);
                                });
                              },
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            // Certificat médical (obligatoire)
                            _buildDocumentUpload(
                              title: 'Certificat médical',
                              subtitle: 'Obligatoire pour valider votre compte',
                              icon: Icons.medical_services_outlined,
                              iconPath: 'assets/images/icon_certificat.png',
                              buttonText: 'Ajouter le certificat',
                              fileName: _certificatMedical,
                              isRequired: true,
                              customWidth: null,
                              customHeight: 70.h,
                              customIconSize: 24.w,
                              onTap: () => _pickFile('certificat'),
                              onRemove: () {
                                setState(() {
                                  _certificatMedical = null;
                                });
                              },
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            // Permis de conduire
                            _buildDocumentUpload(
                              title: 'Permis de conduire',
                              subtitle: 'Recommandé pour plus de missions',
                              icon: Icons.credit_card_outlined,
                              iconPath: 'assets/images/icon_permis.png',
                              buttonText: 'Ajouter le permis',
                              fileName: _permisConduire,
                              isRequired: false,
                              customWidth: null,
                              customHeight: 70.h,
                              customIconSize: 24.w,
                              onTap: () => _pickFile('permis'),
                              onRemove: () {
                                setState(() {
                                  _permisConduire = null;
                                });
                              },
                            ),
                            
                            SizedBox(height: isIPad ? 30.h : 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bouton Continuer
                  Padding(
                    padding: EdgeInsets.all(isIPad ? 20.w : 16.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isIPad ? 360.w : 300.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InscriptionProfessionnelStep5Screen(
                                  prenom: widget.prenom,
                                  nom: widget.nom,
                                  email: widget.email,
                                  telephone: widget.telephone,
                                  dateNaissance: widget.dateNaissance,
                                  adresse: widget.adresse,
                                  codePostal: widget.codePostal,
                                  ville: widget.ville,
                                  fonction: widget.fonction,
                                  anneesExperience: widget.anneesExperience,
                                  specialites: widget.specialites,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0059AB),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continuer',
                                style: getSourceSerifProStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.white),
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
                  // Flèche retour et "Retour" à gauche, "Étape 4/5" à droite
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
                        // Étape 4/5 à droite
                        Text(
                          'Étape 4/5',
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
                          // Ligne de progression (80%)
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.8,
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

  Widget _buildDocumentUpload({
    required String title,
    required String subtitle,
    required IconData icon,
    String? iconPath,
    required String buttonText,
    String? fileName,
    List<String>? fileNames,
    required bool isRequired,
    bool isMultiple = false,
    double? customWidth,
    double? customHeight,
    double? customIconSize,
    required VoidCallback onTap,
    VoidCallback? onRemove,
    Function(int)? onRemoveMultiple,
  }) {
    final hasFile = fileName != null || (fileNames != null && fileNames.isNotEmpty);
    final iconSize = customIconSize ?? 48.w;
    
    return Column(
      crossAxisAlignment: customWidth != null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Titre
        Row(
          mainAxisAlignment: customWidth != null ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: getSourceSerifProStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        
        // Zone d'upload
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
              constraints: customHeight != null ? BoxConstraints(minHeight: customHeight) : null,
              padding: EdgeInsets.symmetric(
                horizontal: 16.w, 
                vertical: customHeight != null ? 12.h : 20.h
              ),
              alignment: customIconSize != null ? Alignment.centerLeft : null,
              decoration: BoxDecoration(
                color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFile ? Color(0xFF0059AB) : Colors.grey[300]!,
                width: hasFile ? 2 : 1,
              ),
              ),
              child: customIconSize != null
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icône à gauche
                        Container(
                          width: 18.w,
                          height: 24.h,
                          alignment: Alignment.center,
                          child: iconPath != null
                              ? Image.asset(
                                  iconPath,
                                  fit: BoxFit.contain,
                                  color: Colors.grey[700],
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      icon,
                                      color: Colors.grey[700],
                                      size: 18.sp,
                                    );
                                  },
                                )
                              : Icon(
                                  icon,
                                  color: Colors.grey[700],
                                  size: 18.sp,
                                ),
                        ),
                        SizedBox(width: 12.w),
                        // Contenu à droite
                        Expanded(
                          child: !hasFile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      buttonText,
                                      style: getSourceSerifProStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      subtitle,
                                      style: getSourceSerifProStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                )
                            : fileName != null
                                ? Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.insert_drive_file, size: 14.sp, color: Color(0xFF0059AB)),
                                        SizedBox(width: 4.w),
                                        Flexible(
                                          child: Text(
                                            fileName,
                                            style: getSourceSerifProStyle(
                                              fontSize: 11.sp,
                                              color: Color(0xFF0059AB),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        GestureDetector(
                                          onTap: onRemove,
                                          child: Icon(Icons.close, size: 14.sp, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink(),
                        ),
                      ],
                    )
                  : Column(
                    children: [
                      if (!hasFile) ...[
                        // État vide - afficher bouton d'ajout
                        Container(
                          width: iconSize,
                          height: iconSize,
                          child: iconPath != null
                              ? Padding(
                                  padding: EdgeInsets.all(8.w),
                                  child: Image.asset(
                                    iconPath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        icon,
                                        color: Colors.grey[500],
                                        size: 24.sp,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  icon,
                                  color: Colors.grey[500],
                                  size: 24.sp,
                                ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          buttonText,
                          style: getSourceSerifProStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: getSourceSerifProStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ] else ...[
                        if (isMultiple && fileNames != null) ...[
                          // État avec fichiers multiples
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: fileNames.asMap().entries.map((entry) {
                              return Container(
                                constraints: BoxConstraints(maxWidth: 250.w),
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.insert_drive_file, size: 16.sp, color: Color(0xFF0059AB)),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                      child: Text(
                                        entry.value,
                                        style: getSourceSerifProStyle(
                                          fontSize: 12.sp,
                                          color: Color(0xFF0059AB),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    GestureDetector(
                                      onTap: () => onRemoveMultiple?.call(entry.key),
                                      child: Icon(Icons.close, size: 16.sp, color: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '+ Ajouter un autre fichier',
                            style: getSourceSerifProStyle(
                              fontSize: 12.sp,
                              color: Color(0xFF0059AB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else if (fileName != null) ...[
                          // État avec un fichier
                          Container(
                            constraints: BoxConstraints(maxWidth: 280.w),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.insert_drive_file, size: 18.sp, color: Color(0xFF0059AB)),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    fileName,
                                    style: getSourceSerifProStyle(
                                      fontSize: 13.sp,
                                      color: Color(0xFF0059AB),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: onRemove,
                                  child: Icon(Icons.close, size: 18.sp, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: type == 'photo' 
            ? ['jpg', 'jpeg', 'png'] 
            : ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: type == 'diplomes',
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          switch (type) {
            case 'photo':
              _photoProfil = result.files.first.name;
              break;
            case 'diplomes':
              for (var file in result.files) {
                _diplomes.add(file.name);
              }
              break;
            case 'certificat':
              _certificatMedical = result.files.first.name;
              break;
            case 'permis':
              _permisConduire = result.files.first.name;
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection du fichier: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
