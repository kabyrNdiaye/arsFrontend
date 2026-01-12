import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/font_helper.dart';

class MissionDetailScreen extends StatefulWidget {
  final String etablissement;
  final String adresse;
  final String horaires;

  const MissionDetailScreen({
    Key? key,
    this.etablissement = 'EHPAD Les Jardins',
    this.adresse = '12 Rue de la Santé, Paris 75014',
    this.horaires = '7h30 - 16h00',
  }) : super(key: key);

  @override
  _MissionDetailScreenState createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  // Checklist état
  Map<String, bool> checklist = {
    'Ouverture': true,
    'Frigos': true,
    'Préparation': false,
    'Textures': false,
    'Dressage': false,
    'Nettoyage': false,
    'Signature': false,
  };

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0059AB), // Même couleur que le header
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Column(
          children: [
            // Header bleu
            _buildHeader(),
            
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                  SizedBox(height: 16.h),
                  
                  // Section Accès & Logistique
                  _buildAccesLogistique(),
                  
                  SizedBox(height: 16.h),
                  
                  // Section Menu du jour
                  _buildMenuDuJour(),
                  
                  SizedBox(height: 16.h),
                  
                  // Section Quantités calculées
                  _buildQuantitesCalculees(),
                  
                  SizedBox(height: 16.h),
                  
                  // Section Checklist journée
                  _buildChecklistJournee(),
                  
                  SizedBox(height: 24.h),
                  
                  // Boutons d'action
                  _buildActionButtons(),
                  
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

  Widget _buildHeader() {
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
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bouton retour
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'Retour',
                          style: getInterStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Nom établissement
                  Text(
                    widget.etablissement,
                    style: getInterStyle(
                      fontSize: 20.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Adresse
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.white70, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        widget.adresse,
                        style: getInterStyle(
                          fontSize: 13.sp,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Horaires
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined, color: Colors.white70, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        widget.horaires,
                        style: getInterStyle(
                          fontSize: 13.sp,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccesLogistique() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec icône
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Color(0xFF0059AB), size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                'Accès & Logistique',
                style: getInterStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Code entrée
          _buildCodeRow('Code entrée', 'A1234'),
          
          SizedBox(height: 12.h),
          
          // Code cuisine
          _buildCodeRow('Code cuisine', 'A1234'),
          
          SizedBox(height: 16.h),
          
          // Bouton appeler
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Action appeler
              },
              icon: Icon(Icons.phone_outlined, size: 18.sp, color: Color(0xFF0059AB)),
              label: Text(
                'Appeler le contact',
                style: getInterStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0059AB),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF0F6FE),
                foregroundColor: Color(0xFF0059AB),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeRow(String label, String code) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: getInterStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                code,
                style: getInterStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Code copié !'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF0059AB),
                ),
              );
            },
            icon: Icon(Icons.copy_outlined, size: 16.sp),
            label: Text(
              'Copier',
              style: getInterStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0059AB),
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF0059AB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuDuJour() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec icône toque de chef
          Row(
            children: [
              // Icône toque de chef
              Image.asset(
                'assets/images/chef.png',
                width: 24.w,
                height: 24.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 24.w,
                    height: 24.h,
                    child: CustomPaint(
                      painter: ChefHatPainter(color: Color(0xFF0059AB)),
                    ),
                  );
                },
              ),
              SizedBox(width: 10.w),
              Text(
                'Menu du jour',
                style: getInterStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // Entrée
          _buildMenuItemWithBorder('Entrée', 'Salade de tomates'),
          
          SizedBox(height: 12.h),
          
          // Plat
          _buildMenuItemWithBorder('Plat', 'Poulet rôti'),
          
          SizedBox(height: 12.h),
          
          // Accompagnement
          _buildMenuItemWithBorder('Accompagnement', 'Riz pilaf'),
          
          SizedBox(height: 12.h),
          
          // Dessert
          _buildMenuItemWithBorder('Dessert', 'Compote de pommes'),
        ],
      ),
    );
  }

  // Icône toque de chef personnalisée
  Widget _buildChefHatIcon() {
    return Container(
      width: 24.w,
      height: 24.h,
      child: CustomPaint(
        painter: ChefHatPainter(color: Color(0xFF0059AB)),
      ),
    );
  }

  Widget _buildMenuItemWithBorder(String category, String name) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: Color(0xFF0085FF), width: 3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: getInterStyle(
                fontSize: 11.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              name,
              style: getInterStyle(
                fontSize: 15.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () {
                // Navigation vers la recette
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Voir la recette',
                    style: getInterStyle(
                      fontSize: 12.sp,
                      color: Color(0xFF0085FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(Icons.chevron_right, size: 16.sp, color: Color(0xFF0085FF)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitesCalculees() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantités calculées',
            style: getInterStyle(
              fontSize: 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Box avec résidents
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFFF0F6FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResidentRow('Résidents', '100', isHighlighted: true),
                SizedBox(height: 4.h),
                _buildResidentRow('Haché', '12'),
                SizedBox(height: 4.h),
                _buildResidentRow('Mixé', '5'),
                SizedBox(height: 4.h),
                _buildResidentRow('Mouliné', '3'),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Quantités ingrédients
          _buildQuantityRow('Viande', '3,5 kg'),
          Divider(height: 16.h, color: Colors.grey[200]),
          _buildQuantityRow('Riz', '2 kg'),
          Divider(height: 16.h, color: Colors.grey[200]),
          _buildQuantityRow('Légumes', '1,7 kg'),
        ],
      ),
    );
  }

  Widget _buildResidentRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: getInterStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: getInterStyle(
            fontSize: 13.sp,
            color: isHighlighted ? Color(0xFF0059AB) : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityRow(String ingredient, String quantity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          ingredient,
          style: getInterStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w400,
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              quantity,
              style: getInterStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistJournee() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checklist journée',
            style: getInterStyle(
              fontSize: 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Liste des tâches
          ...checklist.entries.map((entry) => _buildChecklistItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String label, bool isChecked) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: GestureDetector(
        onTap: () {
          setState(() {
            checklist[label] = !checklist[label]!;
          });
        },
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: isChecked ? Color(0xFF0059AB) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? Color(0xFF0059AB) : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                  : null,
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: getInterStyle(
                fontSize: 14.sp,
                color: isChecked ? Colors.grey[400] : Colors.black87,
                fontWeight: FontWeight.w400,
              ).copyWith(
                decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Bouton Signaler un incident (rouge)
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: () {
                // Action signaler incident
              },
              icon: Image.asset(
                'assets/images/icon_incident.png',
                width: 20.w,
                height: 20.h,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.warning_amber_outlined, size: 20.sp, color: Colors.white);
                },
              ),
              label: Text(
                'Signaler un incident',
                style: getInterStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Bouton Terminer la mission (vert)
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: () {
                // Action terminer mission
              },
              icon: Icon(Icons.check_circle_outline, size: 20.sp),
              label: Text(
                'Terminer la mission',
                style: getInterStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter pour dessiner l'icône toque de chef
class ChefHatPainter extends CustomPainter {
  final Color color;
  
  ChefHatPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final w = size.width;
    final h = size.height;
    
    final path = Path();
    
    // Partie haute de la toque (forme arrondie comme un nuage)
    // Commencer en bas à gauche
    path.moveTo(w * 0.18, h * 0.72);
    
    // Monter sur le côté gauche
    path.lineTo(w * 0.18, h * 0.45);
    
    // Arc gauche de la toque
    path.quadraticBezierTo(w * 0.18, h * 0.22, w * 0.35, h * 0.18);
    
    // Arc central haut
    path.quadraticBezierTo(w * 0.5, h * 0.08, w * 0.65, h * 0.18);
    
    // Arc droit de la toque
    path.quadraticBezierTo(w * 0.82, h * 0.22, w * 0.82, h * 0.45);
    
    // Descendre sur le côté droit
    path.lineTo(w * 0.82, h * 0.72);
    
    canvas.drawPath(path, paint);
    
    // Bandeau du bas (rectangle arrondi)
    final bandPath = Path();
    bandPath.moveTo(w * 0.15, h * 0.72);
    bandPath.lineTo(w * 0.85, h * 0.72);
    bandPath.lineTo(w * 0.85, h * 0.88);
    bandPath.quadraticBezierTo(w * 0.85, h * 0.95, w * 0.78, h * 0.95);
    bandPath.lineTo(w * 0.22, h * 0.95);
    bandPath.quadraticBezierTo(w * 0.15, h * 0.95, w * 0.15, h * 0.88);
    bandPath.close();
    
    canvas.drawPath(bandPath, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
