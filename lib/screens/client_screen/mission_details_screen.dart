import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../../utils/download_pdf.dart';
import '../../utils/file_helper.dart';
import '../../models/mission_model.dart';
import '../../utils/font_helper.dart';
import 'mission_chat_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/mission_service.dart';

class MissionDetailsScreen extends StatefulWidget {
  final MissionModel mission;
  const MissionDetailsScreen({Key? key, required this.mission}) : super(key: key);

  @override
  State<MissionDetailsScreen> createState() => _MissionDetailsScreenState();
}

class _MissionDetailsScreenState extends State<MissionDetailsScreen> {
  MissionModel get mission => widget.mission;

  static const Color _primary = Color(0xFF0059AB);
  static const Color _bg = Color(0xFFF5F7FA);

  bool _isPaymentLoading = false;

  // ─── Paiement ────────────────────────────────────────────────────────────────
  Future<void> _payMission() async {
    setState(() => _isPaymentLoading = true);
    try {
      final result = await MissionService().createCheckout(mission.id);
      if (result['success'] == true && result['url'] != null) {
        final url = Uri.parse(result['url']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Erreur lors du paiement'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPaymentLoading = false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final lang = Provider.of<LanguageProvider>(context);

    final bool isAssigned = mission.professionnelNom != null &&
        mission.professionnelNom!.trim().isNotEmpty &&
        mission.professionnelNom != 'Non assigné' &&
        mission.professionnelNom != 'Thomas Martin';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildHeader(context, lang),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfessionnelCard(isAssigned, lang),
                    SizedBox(height: 12.h),
                    _buildInfoCard(lang),
                    SizedBox(height: 12.h),
                    _buildMenuSection(lang),
                    SizedBox(height: 12.h),
                    _buildResidentsRegimesCard(lang),
                    if (mission.commentaires?.isNotEmpty == true || mission.adminComments?.isNotEmpty == true) ...[
                      SizedBox(height: 12.h),
                      _buildNotesCard(lang),
                    ],
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildActionBar(context, lang),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, LanguageProvider lang) {
    final statusInfo = _getStatusInfo(mission.status, lang);

    return Container(
      width: double.infinity,
      color: _primary,
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trait horizontal (comme sur l'accueil)
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top > 0
                    ? MediaQuery.of(context).padding.top + 8.h
                    : 32.h,
                left: 12.w,
                right: 12.w,
              ),
              child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
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
                        Text('Retour', style: getInterStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Badge statut
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusInfo['label'].toUpperCase(),
                      style: getInterStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Nom structure
                  Text(
                    mission.structureName ?? 'Mission',
                    style: getInterStyle(fontSize: 22.sp, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  if (mission.structureAddress != null && mission.structureAddress!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.white70, size: 13.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(mission.structureAddress!,
                              style: getInterStyle(fontSize: 12.sp, color: Colors.white70),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
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

  // ─── Professionnel Card ───────────────────────────────────────────────────────
  Widget _buildProfessionnelCard(bool isAssigned, LanguageProvider lang) {
    return _buildCard(
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: isAssigned ? _primary.withOpacity(0.1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person_rounded, color: isAssigned ? _primary : Colors.grey[400], size: 26.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAssigned ? (lang.translate('qualified_expert') ?? 'Expert assigné') : (lang.translate('assignment') ?? 'Assignation'),
                  style: getInterStyle(fontSize: 11.sp, color: Colors.grey[500], fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 2.h),
                Text(
                  isAssigned ? mission.professionnelNom! : (lang.translate('selecting') ?? 'En cours de sélection...'),
                  style: getInterStyle(fontSize: 15.sp, color: Colors.black87, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (isAssigned)
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(color: Color(0xFFFFF8E1), shape: BoxShape.circle),
              child: Icon(Icons.verified_rounded, color: Colors.amber[700], size: 18.sp),
            ),
        ],
      ),
    );
  }

  // ─── Informations Card ────────────────────────────────────────────────────────
  Widget _buildInfoCard(LanguageProvider lang) {
    return _buildCard(
      title: 'Informations',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          if (mission.structureName != null)
            _buildInfoRow(lang.translate('structure_default') ?? 'Structure', mission.structureName!),
          if (mission.structureAddress != null)
            _buildInfoRow(lang.translate('address_hint') ?? 'Adresse', mission.structureAddress!),
          _buildInfoRow(lang.translate('real_status') ?? 'Statut', _translateStatus(mission.status, lang)),
          if (mission.typesRepas.isNotEmpty)
            _buildInfoRow(lang.translate('meal_types') ?? 'Types de repas',
                mission.typesRepas.map((m) => _translateMealType(m, lang)).join(', ')),
          if (mission.horaireMission != null)
            _buildInfoRow(lang.translate('start_time') ?? 'Heure début',
                '${DateFormat('dd/MM/yyyy').format(mission.horaireMission!)}  •  ${DateFormat('HH:mm').format(mission.horaireMission!)}'),
          if (mission.heureFin != null)
            _buildInfoRow(lang.translate('end_time') ?? 'Heure fin', mission.heureFin!),
          if (mission.dateFin != null)
            _buildInfoRow('Date fin', DateFormat('dd/MM/yyyy').format(mission.dateFin!)),
          _buildInfoRow(lang.translate('created_at') ?? 'Créé le', DateFormat('dd/MM/yyyy').format(mission.createdAt)),
          _buildInfoRow(lang.translate('created_by_admin') ?? 'Créé par admin',
              mission.estCreeParAdmin ? (lang.translate('yes') ?? 'Oui') : (lang.translate('no') ?? 'Non')),
          if (mission.remuneration != null && mission.remuneration!.isNotEmpty)
            _buildInfoRow('Rémunération', '${mission.remuneration} €'),
        ],
      ),
    );
  }

  // ─── Menu Section ─────────────────────────────────────────────────────────────
  Widget _buildMenuSection(LanguageProvider lang) {
    if (mission.repas.isEmpty) {
      return _buildCard(
        title: lang.translate('meal_planning') ?? 'Menu du jour',
        icon: Icons.restaurant_menu_rounded,
        child: Center(
          child: Text(lang.translate('not_defined') ?? 'Non défini',
              style: getInterStyle(fontSize: 13.sp, color: Colors.grey[400], fontStyle: FontStyle.italic)),
        ),
      );
    }
    return Column(
      children: mission.repas.map((repas) => _buildRepasCard(repas, lang)).toList(),
    );
  }

  Widget _buildRepasCard(RepasModel repas, LanguageProvider lang) {
    final components = [
      if (repas.getDisplayName('entree').isNotEmpty)
        MapEntry(lang.translate('starter_label') ?? 'Entrée', repas.getDisplayName('entree')),
      if (repas.getDisplayName('plat').isNotEmpty)
        MapEntry(lang.translate('dish_label') ?? 'Plat', repas.getDisplayName('plat')),
      if (repas.getDisplayName('accompagnement').isNotEmpty)
        MapEntry(lang.translate('side_label') ?? 'Accompagnement', repas.getDisplayName('accompagnement')),
      if (repas.getDisplayName('side').isNotEmpty && repas.getDisplayName('accompagnement').isEmpty)
        MapEntry(lang.translate('side_label') ?? 'Accompagnement', repas.getDisplayName('side')),
      if (repas.getDisplayName('dessert').isNotEmpty)
        MapEntry(lang.translate('dessert_label') ?? 'Dessert', repas.getDisplayName('dessert')),
      if (repas.getDisplayName('simple').isNotEmpty)
        MapEntry(lang.translate('meal_description') ?? 'Composition', repas.getDisplayName('simple')),
    ];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header repas
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Image.asset('assets/images/chef.png', width: 18.sp, height: 18.sp, errorBuilder: (_, __, ___) => Icon(Icons.restaurant, size: 18.sp, color: _primary)),
                SizedBox(width: 8.w),
                Text('MENU', style: getInterStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: Colors.black87)),
                SizedBox(width: 8.w),
                Text('—', style: getInterStyle(fontSize: 12.sp, color: Colors.grey[400])),
                SizedBox(width: 8.w),
                Text(
                  _translateMealType(repas.typeRepas, lang).toUpperCase(),
                  style: getInterStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: _primary),
                ),
              ],
            ),
          ),
          // Contenu
          Padding(
            padding: EdgeInsets.all(16.w),
            child: components.isEmpty
                ? Text(lang.translate('not_defined') ?? 'Non défini',
                    style: getInterStyle(fontSize: 13.sp, color: Colors.grey[400], fontStyle: FontStyle.italic))
                : Column(
                    children: components.map((entry) => _buildMenuRow(entry.key, entry.value)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: _primary, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: getInterStyle(fontSize: 10.sp, color: Colors.grey[500], fontWeight: FontWeight.w500)),
            SizedBox(height: 2.h),
            Text(value, style: getInterStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ─── Résidents & Régimes Card ─────────────────────────────────────────────────
  Widget _buildResidentsRegimesCard(LanguageProvider lang) {
    return _buildCard(
      title: 'Résidents & Régimes',
      icon: Icons.people_outline_rounded,
      child: Column(
        children: [
          // Stats
          Row(
            children: [
              Expanded(child: _buildStatBox(Icons.people_alt_outlined, '${mission.nbResidentsJour}', lang.translate('residents') ?? 'Résidents')),
              SizedBox(width: 10.w),
              Expanded(child: _buildStatBox(Icons.person_search_rounded, '${mission.nbChefs}', lang.translate('chefs') ?? 'Chefs')),
            ],
          ),
          // Textures
          if (mission.regimesSpecifiques.haches > 0 ||
              mission.regimesSpecifiques.mixes > 0 ||
              mission.regimesSpecifiques.moulines > 0) ...[
            SizedBox(height: 12.h),
            Divider(color: Colors.grey[100], thickness: 1),
            SizedBox(height: 10.h),
            Text('Textures', style: getInterStyle(fontSize: 11.sp, color: Colors.grey[500], fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(child: _buildTextureChip('Hachés', mission.regimesSpecifiques.haches)),
                SizedBox(width: 8.w),
                Expanded(child: _buildTextureChip('Mixés', mission.regimesSpecifiques.mixes)),
                SizedBox(width: 8.w),
                Expanded(child: _buildTextureChip('Moulinés', mission.regimesSpecifiques.moulines)),
              ],
            ),
          ],
          // Régimes spéciaux
          if (mission.regimesSpeciaux.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Divider(color: Colors.grey[100], thickness: 1),
            SizedBox(height: 10.h),
            Text(lang.translate('diet_preferences') ?? 'Régimes spéciaux',
                style: getInterStyle(fontSize: 11.sp, color: Colors.grey[500], fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: mission.regimesSpeciaux.map((diet) => _buildDietChip(_translateDiet(diet, lang))).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: _primary, size: 20.sp),
          SizedBox(height: 6.h),
          Text(value, style: getInterStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.black87)),
          Text(label, style: getInterStyle(fontSize: 10.sp, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildTextureChip(String label, int count) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        children: [
          Text('$count', style: getInterStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _primary)),
          Text(label, style: getInterStyle(fontSize: 10.sp, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildDietChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primary.withOpacity(0.15)),
      ),
      child: Text(label, style: getInterStyle(fontSize: 12.sp, color: _primary, fontWeight: FontWeight.w600)),
    );
  }

  // ─── Notes Card ───────────────────────────────────────────────────────────────
  Widget _buildNotesCard(LanguageProvider lang) {
    return _buildCard(
      title: lang.translate('mission_notes') ?? 'Notes',
      icon: Icons.notes_rounded,
      child: Column(
        children: [
          if (mission.commentaires?.isNotEmpty == true) ...[
            _buildNoteBlock(
              lang.translate('structure_request') ?? 'Demande structure',
              mission.commentaires!,
              const Color(0xFFFFF8E1),
              Colors.amber[800]!,
            ),
            if (mission.adminComments?.isNotEmpty == true) SizedBox(height: 10.h),
          ],
          if (mission.adminComments?.isNotEmpty == true)
            _buildNoteBlock(
              lang.translate('admin_instructions') ?? 'Instructions admin',
              mission.adminComments!,
              const Color(0xFFF3E8FF),
              Colors.purple[700]!,
            ),
        ],
      ),
    );
  }

  Widget _buildNoteBlock(String title, String text, Color bg, Color accent) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: getInterStyle(fontSize: 10.sp, color: accent, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          SizedBox(height: 6.h),
          Text(text, style: getInterStyle(fontSize: 13.sp, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }

  // ─── Barre d'actions ─────────────────────────────────────────────────────────
  Widget _buildActionBar(BuildContext context, LanguageProvider lang) {
    return Container(
      height: 64.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBarItem(Icons.chat_bubble_outline_rounded, lang.translate('chat') ?? 'Chat', true, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => MissionChatScreen(mission: mission)));
          }),
          _buildBarDivider(),
          _buildPayBarItem(context),
          _buildBarDivider(),
          _buildBarItem(Icons.picture_as_pdf_outlined, lang.translate('report') ?? 'PDF', false, () => _saveMissionPdf(context, lang)),
          _buildBarDivider(),
          _buildBarItem(Icons.share_outlined, lang.translate('share') ?? 'Partager', false, () => _shareMission(context, lang)),
        ],
      ),
    );
  }

  Widget _buildBarItem(IconData icon, String label, bool primary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primary ? _primary : Colors.grey[500], size: 20.sp),
            SizedBox(height: 3.h),
            Text(label, style: getInterStyle(fontSize: 10.sp, color: primary ? _primary : Colors.grey[500], fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPayBarItem(BuildContext context) {
    final bool hasRemuneration = mission.remuneration != null && mission.remuneration!.isNotEmpty;
    final Color color = hasRemuneration ? const Color(0xFF2E7D32) : Colors.grey[400]!;
    return GestureDetector(
      onTap: () {
        if (_isPaymentLoading) return;
        if (!hasRemuneration) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text("Montant non encore défini par l'admin."), backgroundColor: Colors.orange[700]),
          );
          return;
        }
        _payMission();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isPaymentLoading
                ? SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                : Icon(Icons.payments_outlined, color: color, size: 20.sp),
            SizedBox(height: 3.h),
            Text(
              hasRemuneration ? '${mission.remuneration} €' : 'Payer',
              style: getInterStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarDivider() => Container(height: 30.h, width: 1, color: Colors.grey[200]);

  // ─── Card wrapper ─────────────────────────────────────────────────────────────
  Widget _buildCard({Widget? child, String? title, IconData? icon}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: _primary, size: 16.sp),
                  SizedBox(width: 6.w),
                ],
                Text(title, style: getInterStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
              ],
            ),
            SizedBox(height: 14.h),
            Divider(color: Colors.grey[100], thickness: 1, height: 1),
            SizedBox(height: 14.h),
          ],
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(label, style: getInterStyle(fontSize: 12.sp, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: getInterStyle(fontSize: 13.sp, color: Colors.black87, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ─── Status helpers ───────────────────────────────────────────────────────────
  Map<String, dynamic> _getStatusInfo(String status, LanguageProvider lang) {
    final s = status.toLowerCase().trim();
    if (s == 'terminé' || s == 'terminée' || s == 'finished') {
      return {'label': lang.translate('finished') ?? 'Terminé', 'color': Colors.grey[600]!};
    } else if (s.contains('refus') || s.contains('annul')) {
      return {'label': lang.translate('refused') ?? 'Refusé', 'color': const Color(0xFFD32F2F)};
    } else if (s == 'en cours' || s == 'in_progress') {
      return {'label': lang.translate('in_progress') ?? 'En cours', 'color': const Color(0xFF2E7D32)};
    } else if (s.contains('confirm')) {
      return {'label': lang.translate('confirmed') ?? 'Confirmé', 'color': const Color(0xFF1565C0)};
    }
    return {'label': lang.translate('planned') ?? 'Planifié', 'color': _primary};
  }

  // ─── Translation helpers ──────────────────────────────────────────────────────
  String _translateMealType(String raw, LanguageProvider lang) {
    switch (raw.trim().toLowerCase()) {
      case 'lunch': case 'dejeuner': case 'déjeuner': return lang.translate('lunch') ?? 'Déjeuner';
      case 'dinner': case 'dîner': return lang.translate('dinner') ?? 'Dîner';
      case 'breakfast': case 'petit-déjeuner': return lang.translate('breakfast') ?? 'Petit-déjeuner';
      case 'snack': case 'goûter': return lang.translate('snack') ?? 'Goûter';
      case 'brunch': return lang.translate('brunch') ?? 'Brunch';
      case 'supper': case 'souper': return lang.translate('supper') ?? 'Souper';
      default: return _capitalize(raw.replaceAll('_', ' '));
    }
  }

  String _translateDiet(String raw, LanguageProvider lang) {
    switch (raw.trim().toLowerCase()) {
      case 'diabetic': case 'diabétique': return lang.translate('diabetic') ?? 'Diabétique';
      case 'no_salt': case 'sans sel': return lang.translate('no_salt') ?? 'Sans sel';
      case 'textures': return lang.translate('modified_textures') ?? 'Textures modifiées';
      case 'gluten_free': case 'sans gluten': return lang.translate('gluten_free') ?? 'Sans gluten';
      case 'vegan': case 'végane': case 'vegetarian': case 'végétarien': return lang.translate('vegetarian_diet') ?? 'Végétarien';
      case 'low_carb': return lang.translate('low_carb') ?? 'Faible en glucides';
      case 'low_fat': return lang.translate('low_fat') ?? 'Faible en graisses';
      default: return _capitalize(raw.replaceAll('_', ' '));
    }
  }

  String _translateStatus(String raw, LanguageProvider lang) {
    switch (raw.trim().toLowerCase()) {
      case 'en attente': case 'pending': return lang.translate('pending') ?? 'En attente';
      case 'en cours': case 'in_progress': return lang.translate('in_progress') ?? 'En cours';
      case 'terminé': case 'finished': return lang.translate('completed') ?? 'Terminé';
      case 'confirmé': case 'confirmed': return lang.translate('confirmed') ?? 'Confirmé';
      case 'refusé': case 'refused': return lang.translate('refused') ?? 'Refusé';
      default: return _capitalize(raw.replaceAll('_', ' '));
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join(' ');
  }

  // ─── PDF ──────────────────────────────────────────────────────────────────────
  Future<Uint8List> _generateMissionPdf(LanguageProvider lang) async {
    final pdfDoc = pw.Document();
    final List<pw.Widget> content = [];
    content.add(pw.Header(level: 0, text: 'Rapport de mission'));
    content.add(pw.Paragraph(text: 'Mission: ${mission.structureName ?? 'N/A'}'));
    if (mission.structureAddress != null) content.add(pw.Paragraph(text: 'Adresse: ${mission.structureAddress}'));
    if (mission.horaireMission != null) content.add(pw.Paragraph(text: 'Heure début: ${DateFormat('HH:mm').format(mission.horaireMission!)}'));
    if (mission.dateFin != null) content.add(pw.Paragraph(text: 'Date fin: ${DateFormat('dd/MM/yyyy').format(mission.dateFin!)}'));
    content.add(pw.Paragraph(text: 'Statut: ${_translateStatus(mission.status, lang)}'));
    content.add(pw.Paragraph(text: 'Résidents: ${mission.nbResidentsJour}'));
    if (mission.typesRepas.isNotEmpty) content.add(pw.Paragraph(text: 'Types repas: ${mission.typesRepas.map((m) => _translateMealType(m, lang)).join(', ')}'));
    if (mission.regimesSpeciaux.isNotEmpty) content.add(pw.Paragraph(text: 'Régimes: ${mission.regimesSpeciaux.map((d) => _translateDiet(d, lang)).join(', ')}'));
    if (mission.repas.isNotEmpty) {
      content.add(pw.Header(level: 1, text: 'Menu'));
      for (final r in mission.repas) {
        content.add(pw.Paragraph(text: _translateMealType(r.typeRepas, lang)));
        final e = r.getDisplayName('entree'); if (e.isNotEmpty) content.add(pw.Bullet(text: 'Entrée: $e'));
        final p = r.getDisplayName('plat'); if (p.isNotEmpty) content.add(pw.Bullet(text: 'Plat: $p'));
        final a = r.getDisplayName('accompagnement'); if (a.isNotEmpty) content.add(pw.Bullet(text: 'Accompagnement: $a'));
        final d = r.getDisplayName('dessert'); if (d.isNotEmpty) content.add(pw.Bullet(text: 'Dessert: $d'));
        final s = r.getDisplayName('simple'); if (s.isNotEmpty) content.add(pw.Bullet(text: 'Composition: $s'));
      }
    }
    if (mission.commentaires?.isNotEmpty == true) { content.add(pw.Header(level: 1, text: 'Commentaires')); content.add(pw.Paragraph(text: mission.commentaires!)); }
    if (mission.adminComments?.isNotEmpty == true) { content.add(pw.Header(level: 1, text: 'Consignes Admin')); content.add(pw.Paragraph(text: mission.adminComments!)); }
    if (mission.codeEntree?.isNotEmpty == true) content.add(pw.Paragraph(text: "Code entrée: ${mission.codeEntree}"));
    if (mission.codeCuisine?.isNotEmpty == true) content.add(pw.Paragraph(text: "Code cuisine: ${mission.codeCuisine}"));
    pdfDoc.addPage(pw.MultiPage(pageFormat: pdf.PdfPageFormat.a4, build: (_) => content));
    return pdfDoc.save();
  }

  Future<void> _saveMissionPdf(BuildContext context, LanguageProvider lang) async {
    try {
      final bytes = await _generateMissionPdf(lang);
      final fileName = 'mission_${mission.id}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      if (kIsWeb) { await downloadPdfWeb(bytes, fileName); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF téléchargé : $fileName'))); return; }
      final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final filePath = '${directory?.path}/$fileName';
      final file = createFile(filePath);
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF enregistré')));
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible d'ouvrir le PDF.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur PDF : $e')));
    }
  }

  // ─── Share ────────────────────────────────────────────────────────────────────
  void _shareMission(BuildContext context, LanguageProvider lang) {
    final sb = StringBuffer();
    sb.writeln('Mission: ${mission.structureName ?? 'N/A'}');
    if (mission.structureAddress != null) sb.writeln('Adresse: ${mission.structureAddress}');
    if (mission.horaireMission != null) sb.writeln('Heure début: ${DateFormat('HH:mm').format(mission.horaireMission!)}');
    if (mission.dateFin != null) sb.writeln('Date fin: ${DateFormat('dd/MM/yyyy').format(mission.dateFin!)}');
    sb.writeln('Statut: ${_translateStatus(mission.status, lang)}');
    sb.writeln('Résidents: ${mission.nbResidentsJour}');
    if (mission.typesRepas.isNotEmpty) sb.writeln('Types repas: ${mission.typesRepas.map((m) => _translateMealType(m, lang)).join(', ')}');
    if (mission.regimesSpeciaux.isNotEmpty) sb.writeln('Régimes: ${mission.regimesSpeciaux.map((d) => _translateDiet(d, lang)).join(', ')}');
    if (mission.repas.isNotEmpty) {
      sb.writeln('\nMenu:');
      for (final r in mission.repas) {
        sb.writeln('- ${_translateMealType(r.typeRepas, lang)}');
        final e = r.getDisplayName('entree'); if (e.isNotEmpty) sb.writeln('  Entrée: $e');
        final p = r.getDisplayName('plat'); if (p.isNotEmpty) sb.writeln('  Plat: $p');
        final a = r.getDisplayName('accompagnement'); if (a.isNotEmpty) sb.writeln('  Accompagnement: $a');
        final d = r.getDisplayName('dessert'); if (d.isNotEmpty) sb.writeln('  Dessert: $d');
        final s = r.getDisplayName('simple'); if (s.isNotEmpty) sb.writeln('  Composition: $s');
      }
    }
    if (mission.commentaires?.isNotEmpty == true) sb.writeln('\nCommentaires: ${mission.commentaires}');
    if (mission.adminComments?.isNotEmpty == true) sb.writeln('\nConsignes admin: ${mission.adminComments}');
    if (mission.codeEntree?.isNotEmpty == true) sb.writeln('\nCode entrée: ${mission.codeEntree}');
    if (mission.codeCuisine?.isNotEmpty == true) sb.writeln('Code cuisine: ${mission.codeCuisine}');
    sb.writeln('\nTéléchargez ARS App pour voir tous les détails.');
    Share.share(sb.toString(), subject: 'Détails de mission ARS');
  }
}
