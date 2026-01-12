import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';

class PolitiqueScreen extends StatefulWidget {
  const PolitiqueScreen({Key? key}) : super(key: key);

  @override
  State<PolitiqueScreen> createState() => _PolitiqueScreenState();
}

class _PolitiqueScreenState extends State<PolitiqueScreen> {
  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header vert
            _buildHeader(context),
            
            // Contenu
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        'Collecte des données',
                        'Nous collectons uniquement les données nécessaires au bon fonctionnement de nos services :\n\n'
                        '• Informations d\'identification (nom, prénom, email)\n'
                        '• Coordonnées de l\'établissement\n'
                        '• Données relatives aux missions\n'
                        '• Historique des prestations',
                      ),
                      _buildDivider(),
                      _buildSection(
                        'Utilisation des données',
                        'Vos données sont utilisées pour :\n\n'
                        '• Assurer la gestion des missions de restauration\n'
                        '• Améliorer nos services\n'
                        '• Vous contacter concernant votre compte\n'
                        '• Respecter nos obligations légales',
                      ),
                      _buildDivider(),
                      _buildSection(
                        'Protection des données',
                        'Nous mettons en œuvre des mesures de sécurité appropriées pour protéger vos données :\n\n'
                        '• Chiffrement des données sensibles\n'
                        '• Accès restreint aux données personnelles\n'
                        '• Sauvegarde régulière des données\n'
                        '• Mise à jour des systèmes de sécurité',
                      ),
                      _buildDivider(),
                      _buildSection(
                        'Vos droits',
                        'Conformément au RGPD, vous disposez des droits suivants :\n\n'
                        '• Droit d\'accès à vos données\n'
                        '• Droit de rectification\n'
                        '• Droit à l\'effacement\n'
                        '• Droit à la portabilité\n'
                        '• Droit d\'opposition',
                      ),
                      _buildDivider(),
                      _buildSection(
                        'Contact',
                        'Pour toute question concernant notre politique de confidentialité ou pour exercer vos droits, contactez-nous à :\n\n'
                        'Email : privacy@ars-app.fr\n'
                        'Adresse : 45 Avenue de la République, 75011 Paris',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryGreen,
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          children: [
            // Trait horizontal en haut
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
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              child: Row(
                children: [
                  // Bouton Retour
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
                  
                  // Titre centré
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 64.w), // Pour compenser
                        child: Text(
                          'Politique de confidentialité',
                          textAlign: TextAlign.center,
                          style: getInterStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: getInterStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: _primaryGreen,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          content,
          style: getInterStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Divider(height: 1, color: Colors.grey[100]),
    );
  }
}


