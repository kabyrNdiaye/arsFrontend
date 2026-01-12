import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/font_helper.dart';

class ClientAideSupportScreen extends StatelessWidget {
  const ClientAideSupportScreen({Key? key}) : super(key: key);

  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  children: [
                    _buildSupportCard(
                      context: context,
                      icon: FontAwesomeIcons.circleQuestion,
                      title: 'FAQ',
                      subtitle: 'Trouvez des réponses á vos questions fréquentes',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const _ClientFaqScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildSupportCard(
                      context: context,
                      icon: FontAwesomeIcons.commentDots,
                      title: 'Contactez-nous',
                      subtitle: 'Envoyez-nous un message via notre formulaire',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const _ClientContactScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildSupportCard(
                      context: context,
                      icon: FontAwesomeIcons.envelope,
                      title: 'Support par Email',
                      subtitle: 'Envoyez un email à notre équipe de support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const _ClientEmailSupportScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildSupportCard(
                      context: context,
                      icon: FontAwesomeIcons.phone,
                      title: 'Support Téléphonique',
                      subtitle: 'Appelez notre ligne d\'assistance dédiée',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const _ClientSupportTelScreen()),
                        );
                      },
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: _primaryGreen),
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
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
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
                  ),
                  Text(
                    'Aide & Support',
                    style: getInterStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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

  Widget _buildSupportCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                FaIcon(
                  icon,
                  color: _primaryGreen,
                  size: 26.sp,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: getInterStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: getInterStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF757575),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFFBDBDBD),
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }
}

class _ClientFaqScreen extends StatelessWidget {
  const _ClientFaqScreen({Key? key}) : super(key: key);
  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context, 'FAQ'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _buildFaqItem('Comment créer une mission ?', 'Pour créer une mission, rendez-vous dans la section "Missions" et cliquez sur le bouton "+". Remplissez les informations requises et validez.'),
                  _buildFaqItem('Comment modifier mes informations ?', 'Accédez à votre profil via l\'onglet "Profil" et cliquez sur "Modifier". Vous pourrez alors mettre à jour vos informations.'),
                  _buildFaqItem('Comment contacter un professionnel ?', 'Une fois la mission confirmée, vous pourrez accéder aux coordonnées du professionnel depuis les détails de la mission.'),
                  _buildFaqItem('Comment annuler une mission ?', 'Rendez-vous dans les détails de la mission et cliquez sur "Annuler". Attention, des conditions d\'annulation peuvent s\'appliquer.'),
                  _buildFaqItem('Comment laisser un avis ?', 'Après chaque mission terminée, vous recevrez une notification pour évaluer le professionnel. Vous pouvez également le faire depuis l\'historique.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      color: _primaryGreen,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top + 8.h : 32.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(children: [Icon(Icons.arrow_back, color: Colors.white, size: 20.sp), SizedBox(width: 4.w), Text('Retour', style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.white))]),
                ),
                Expanded(child: Center(child: Text(title, style: getSourceSerifProStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)))),
                SizedBox(width: 60.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: getSourceSerifProStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
      iconColor: _primaryGreen,
      collapsedIconColor: Colors.grey,
      children: [
        Padding(padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h), child: Text(answer, style: getSourceSerifProStyle(fontSize: 13.sp, color: Colors.grey[600], height: 1.5))),
      ],
    );
  }
}

class _ClientContactScreen extends StatelessWidget {
  const _ClientContactScreen({Key? key}) : super(key: key);
  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context, 'Contactez-nous'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Envoyez-nous un message', style: getSourceSerifProStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 20.h),
                    _buildTextField('Sujet'),
                    SizedBox(height: 16.h),
                    _buildTextField('Message', maxLines: 5),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Message envoyé !'), backgroundColor: _primaryGreen));
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('Envoyer', style: getSourceSerifProStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w600)),
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

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      color: _primaryGreen,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top + 8.h : 32.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(children: [Icon(Icons.arrow_back, color: Colors.white, size: 20.sp), SizedBox(width: 4.w), Text('Retour', style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.white))]),
                ),
                Expanded(child: Center(child: Text(title, style: getSourceSerifProStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)))),
                SizedBox(width: 60.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.h),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Entrez votre ${label.toLowerCase()}',
            hintStyle: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[400]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: const Color(0xFF4CA054), width: 2)),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
      ],
    );
  }
}

class _ClientEmailSupportScreen extends StatelessWidget {
  const _ClientEmailSupportScreen({Key? key}) : super(key: key);
  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context, 'Support par Email'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Icon(Icons.email, color: _primaryGreen, size: 48.sp),
                          SizedBox(height: 16.h),
                          Text('support@ars.com', style: getSourceSerifProStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                          SizedBox(height: 8.h),
                          Text('Notre équipe vous répondra sous 24h', style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[600]), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text('Conseils pour votre email', style: getSourceSerifProStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 16.h),
                    _buildTip('Précisez le sujet de votre demande'),
                    _buildTip('Incluez votre numéro de compte'),
                    _buildTip('Décrivez le problème en détail'),
                    _buildTip('Joignez des captures d\'écran si nécessaire'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      color: _primaryGreen,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top + 8.h : 32.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(children: [Icon(Icons.arrow_back, color: Colors.white, size: 20.sp), SizedBox(width: 4.w), Text('Retour', style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.white))]),
                ),
                Expanded(child: Center(child: Text(title, style: getSourceSerifProStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)))),
                SizedBox(width: 60.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(padding: EdgeInsets.only(bottom: 12.h), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.check_circle, color: _primaryGreen, size: 20.sp), SizedBox(width: 12.w), Expanded(child: Text(text, style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.black87)))]));
  }
}

class _ClientSupportTelScreen extends StatelessWidget {
  const _ClientSupportTelScreen({Key? key}) : super(key: key);
  final Color _primaryGreen = const Color(0xFF4CA054);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(context, 'Support téléphonique'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Icon(Icons.phone, color: _primaryGreen, size: 48.sp),
                          SizedBox(height: 16.h),
                          Text('+33 1 23 45 67 89', style: getSourceSerifProStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
                          SizedBox(height: 8.h),
                          Text('Ligne d\'assistance dédiée', style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text('Horaires d\'ouverture', style: getSourceSerifProStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 16.h),
                    _buildHoraire('Lundi - Vendredi', '8h00 - 20h00'),
                    _buildHoraire('Samedi', '9h00 - 18h00'),
                    _buildHoraire('Dimanche', 'Fermé'),
                    SizedBox(height: 24.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange[200]!)),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[700], size: 20.sp),
                          SizedBox(width: 12.w),
                          Expanded(child: Text('En cas d\'urgence en dehors des horaires, envoyez un email à urgence@ars-app.fr', style: getSourceSerifProStyle(fontSize: 12.sp, color: Colors.orange[800]))),
                        ],
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

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      color: _primaryGreen,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top + 8.h : 32.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(children: [Icon(Icons.arrow_back, color: Colors.white, size: 20.sp), SizedBox(width: 4.w), Text('Retour', style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.white))]),
                ),
                Expanded(child: Center(child: Text(title, style: getSourceSerifProStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)))),
                SizedBox(width: 60.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoraire(String jour, String horaire) {
    return Padding(padding: EdgeInsets.only(bottom: 12.h), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(jour, style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.black87)), Text(horaire, style: getSourceSerifProStyle(fontSize: 14.sp, color: horaire == 'Fermé' ? Colors.red : _primaryGreen, fontWeight: FontWeight.w600))]));
  }
}
