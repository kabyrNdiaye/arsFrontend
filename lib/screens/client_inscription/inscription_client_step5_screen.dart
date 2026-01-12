import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/font_helper.dart';

class InscriptionClientStep5Screen extends StatefulWidget {
  final Map<String, dynamic>? previousData;
  
  const InscriptionClientStep5Screen({Key? key, this.previousData}) : super(key: key);
  
  @override
  _InscriptionClientStep5ScreenState createState() => _InscriptionClientStep5ScreenState();
}

class _InscriptionClientStep5ScreenState extends State<InscriptionClientStep5Screen> {
  // Couleur verte principale
  final Color _primaryGreen = Color(0xFF4CA054);
  final Color _lightGreen = Color(0xFFE8F5E9);

  // Documents
  String? _contratPrestation;
  String? _planLocaux;
  String? _reglementInterieur;

  // Checkboxes
  bool _acceptConditions = false;
  bool _acceptNewsletter = false;

  Future<void> _pickDocument(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          switch (type) {
            case 'contrat':
              _contratPrestation = result.files.single.name;
              break;
            case 'plan':
              _planLocaux = result.files.single.name;
              break;
            case 'reglement':
              _reglementInterieur = result.files.single.name;
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection du fichier')),
      );
    }
  }

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
          _buildHeader(),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isIPad ? 40.h : 30.h),
                            
                            // Icône maison centrée
                            Center(
                              child: Container(
                                width: isIPad ? 80.w : 70.w,
                                height: isIPad ? 80.h : 70.h,
                                decoration: BoxDecoration(
                                  color: _lightGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/icon_client.png',
                                    color: _primaryGreen,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: isIPad ? 24.h : 20.h),
                            
                            // Titre centré
                            Center(
                              child: Text(
                                'Finalisation',
                                style: getSourceSerifProStyle(
                                  fontSize: isIPad ? 22.sp : 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            // Sous-titre centré
                            Center(
                              child: Text(
                                'Documents et validation',
                                style: getSourceSerifProStyle(
                                  fontSize: isIPad ? 14.sp : 13.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            SizedBox(height: isIPad ? 32.h : 24.h),
                            
                            // Section Documents
                            _buildDocumentsSection(isIPad),
                            
                            SizedBox(height: 24.h),
                            
                            // Section Conditions générales
                            _buildConditionsSection(isIPad),
                            
                            SizedBox(height: 24.h),
                            
                            // Info box "Prêt à valider"
                            _buildReadyBox(isIPad),
                            
                            SizedBox(height: isIPad ? 50.h : 40.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Bouton Continuer
                  Padding(
                    padding: EdgeInsets.all(isIPad ? 24.w : 20.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isIPad ? 400.w : 350.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _acceptConditions ? () {
                            _showSuccessDialog();
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            disabledForegroundColor: Colors.grey[500],
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
                                  color: _acceptConditions ? Colors.white : Colors.grey[500],
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.arrow_forward_ios, 
                                size: 16.sp, 
                                color: _acceptConditions ? Colors.white : Colors.grey[500],
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 100.h,
      color: _primaryGreen,
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
                  // Barre de progression (100%)
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

  Widget _buildDocumentsSection(bool isIPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: _primaryGreen,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
            Text(
              'Documents (optionnel)',
              style: getSourceSerifProStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildDocumentItem(
            title: 'Contrat de prestation',
            subtitle: 'PDF, max 10 MB',
            fileName: _contratPrestation,
            onTap: () => _pickDocument('contrat'),
          ),
          SizedBox(height: 12.h),
          _buildDocumentItem(
            title: 'Plan des locaux',
            subtitle: 'PDF, max 10 MB',
            fileName: _planLocaux,
            onTap: () => _pickDocument('plan'),
          ),
          SizedBox(height: 12.h),
          _buildDocumentItem(
            title: 'Règlement intérieur',
            subtitle: 'PDF, max 10 MB',
            fileName: _reglementInterieur,
            onTap: () => _pickDocument('reglement'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required String subtitle,
    String? fileName,
    required VoidCallback onTap,
  }) {
    final bool hasFile = fileName != null;
    
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: Colors.black,
          strokeWidth: 2,
          dashWidth: 6,
          dashSpace: 4,
          borderRadius: 10,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: hasFile ? _lightGreen : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Icône document
              Icon(
                Icons.description_outlined,
                color: Colors.grey[400],
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasFile ? fileName! : title,
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: getSourceSerifProStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Icône upload
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: hasFile ? _primaryGreen : _lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasFile ? Icons.check : Icons.upload_outlined,
                  color: hasFile ? Colors.white : _primaryGreen,
                  size: 22.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionsSection(bool isIPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conditions générales',
            style: getSourceSerifProStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _acceptConditions = !_acceptConditions;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: _acceptConditions ? _primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _acceptConditions ? _primaryGreen : Colors.grey[400]!,
                      width: 1.5,
                    ),
                  ),
                  child: _acceptConditions
                      ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: getSourceSerifProStyle(
                        fontSize: 13.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(text: 'J\'accepte les '),
                        TextSpan(
                          text: 'conditions d\'utilisation',
                          style: getSourceSerifProStyle(
                            fontSize: 13.sp,
                            color: _primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _acceptNewsletter = !_acceptNewsletter;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: _acceptNewsletter ? _primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _acceptNewsletter ? _primaryGreen : Colors.grey[400]!,
                      width: 1.5,
                    ),
                  ),
                  child: _acceptNewsletter
                      ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Je souhaite recevoir les actualités par email',
                    style: getSourceSerifProStyle(
                      fontSize: 13.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
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

  Widget _buildReadyBox(bool isIPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _primaryGreen, width: 2),
            ),
            child: Icon(
              Icons.check,
              color: _primaryGreen,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prêt à valider !',
                  style: getSourceSerifProStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Votre inscription sera examinée par notre équipe. Vous recevrez un email de confirmation dans les 24h.',
                  style: getSourceSerifProStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: _primaryGreen,
                  size: 50.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Inscription réussie !',
                style: getSourceSerifProStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Votre demande d\'inscription a été envoyée avec succès. Vous recevrez un email de confirmation.',
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Retour à l\'accueil',
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom Painter pour les bordures pointillées
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.borderRadius = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final length = dashWidth;
        if (distance + length > metric.length) {
          dashPath.addPath(
            metric.extractPath(distance, metric.length),
            Offset.zero,
          );
        } else {
          dashPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
