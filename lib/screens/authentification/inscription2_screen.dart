import 'package:flutter/material.dart';
import '../../utils/font_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../auth/register_screen.dart';
import 'inscription3_screen.dart';

class Inscription2Screen extends StatefulWidget {
  @override
  _Inscription2ScreenState createState() => _Inscription2ScreenState();
}

class _Inscription2ScreenState extends State<Inscription2Screen> {
  List<String> _carteIdentite = ['ma-carte.pdf'];
  List<String> _cv = ['mon-cv.pdf'];
  List<String> _diplomes = ['mon-cfee.pdf', 'mon-bfem.pdf', 'mon-de.pdf'];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Header avec "Retour", flèche retour et logo ARS
            Container(
              width: double.infinity,
              height: 100.h,
              color: Colors.white,
              child: Stack(
                children: [
                  // Row avec flèche retour et texte "Retour" - aligné avec le centre du logo
                  Positioned(
                    left: 0,
                    top: 35.h + (64.h / 2) - 20.h, // Centre du logo moins la moitié de la hauteur du bouton
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          // Flèche retour
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          // Texte "Retour"
                          Text(
                            langProvider.translate('back'),
                            style: getSourceSerifProStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000000),
                              height: 1.0,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Logo positionné selon les paramètres (Left: 278px, Top: 35px)
                  Positioned(
                    left: 278.w,
                    top: 35.h,
                    child: Image.asset(
                      'assets/images/logo2.png',
                      width: 85.w,
                      height: 64.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 32.h, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre principal
                    Text(
                      langProvider.translate('documents_title'),
                      style: getSourceSerifProStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000000),
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Sous-titre
                    Text(
                      langProvider.translate('documents_subtitle'),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6C7278),
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Champ Carte d'identité
                    _buildDocumentField(
                      label: langProvider.translate('id_card'),
                      files: _carteIdentite,
                      langProvider: langProvider,
                      onRemove: (index) {
                        setState(() {
                          _carteIdentite.removeAt(index);
                        });
                      },
                      onUpload: () async {
                        await _pickFile(_carteIdentite, langProvider: langProvider, allowMultiple: false);
                      },
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Champ CV
                    _buildDocumentField(
                      label: langProvider.translate('cv'),
                      files: _cv,
                      langProvider: langProvider,
                      onRemove: (index) {
                        setState(() {
                          _cv.removeAt(index);
                        });
                      },
                      onUpload: () async {
                        await _pickFile(_cv, langProvider: langProvider, allowMultiple: false);
                      },
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Champ Diplômes
                    _buildDocumentField(
                      label: langProvider.translate('diplomas'),
                      files: _diplomes,
                      langProvider: langProvider,
                      onRemove: (index) {
                        setState(() {
                          _diplomes.removeAt(index);
                        });
                      },
                      onUpload: () async {
                        await _pickFile(_diplomes, langProvider: langProvider, allowMultiple: true);
                      },
                      isMultiple: true,
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Bouton SUIVANT - juste après le formulaire
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16.h),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigation vers la page inscription3
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Inscription3Screen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0059AB),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          langProvider.translate('next'),
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
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
      ),
    );
  }

  Widget _buildDocumentField({
    required String label,
    required List<String> files,
    required Function(int) onRemove,
    required VoidCallback onUpload,
    required LanguageProvider langProvider,
    bool isMultiple = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: _buildLabelWithRedAsterisk(label),
            style: getSourceSerifProStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFF6C7278)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Zone de fichiers
              Expanded(
                child: files.isEmpty
                    ? Text(
                        langProvider.translate('no_file'),
                        style: getSourceSerifProStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[400],
                        ),
                      )
                    : Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: files.asMap().entries.map((entry) {
                          int index = entry.key;
                          String file = entry.value;
                          return _buildFileChip(
                            fileName: file,
                            onRemove: () => onRemove(index),
                          );
                        }).toList(),
                      ),
              ),
              SizedBox(width: 8.w),
              // Icône d'upload
              GestureDetector(
                onTap: onUpload,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.upload,
                    color: Colors.black,
                    size: 24.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileChip({
    required String fileName,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            fileName,
            style: getSourceSerifProStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF000000),
              height: 1.0, // Line height: 100%
              letterSpacing: 0,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14.sp,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildLabelWithRedAsterisk(String label) {
    List<TextSpan> spans = [];
    int asteriskIndex = label.indexOf('*');
    
    if (asteriskIndex != -1) {
      // Texte avant l'astérisque
      spans.add(TextSpan(text: label.substring(0, asteriskIndex)));
      // Astérisque en rouge
      spans.add(TextSpan(
        text: '*',
        style: getSourceSerifProStyle(color: Colors.red),
      ));
      // Texte après l'astérisque (s'il y en a)
      if (asteriskIndex < label.length - 1) {
        spans.add(TextSpan(text: label.substring(asteriskIndex + 1)));
      }
    } else {
      // Pas d'astérisque, texte normal
      spans.add(TextSpan(text: label));
    }
    
    return spans;
  }

  Future<void> _pickFile(List<String> fileList, {required LanguageProvider langProvider, bool allowMultiple = false}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: allowMultiple,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          if (allowMultiple) {
            // Pour les diplômes, ajouter tous les fichiers
            for (var file in result.files) {
              fileList.add(file.name);
            }
          } else {
            // Pour carte d'identité et CV, remplacer le fichier existant
            fileList.clear();
            fileList.add(result.files.first.name);
          }
        });
      }
    } catch (e) {
      // Afficher un message d'erreur si nécessaire
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${langProvider.translate('error_file_pick')} $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

