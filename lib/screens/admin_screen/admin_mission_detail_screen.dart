// Version: 2.0.0 - Unified Design
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:itea_app/utils/font_helper.dart';
import 'package:itea_app/models/mission_model.dart';
import 'package:itea_app/providers/language_provider.dart';
import 'package:itea_app/screens/admin_screen/admin_edit_mission_screen.dart';
import 'package:itea_app/screens/admin_screen/admin_mission_chat_screen.dart';
import 'package:itea_app/models/recipe_model.dart';
import 'package:itea_app/services/mission_service.dart';
import 'package:itea_app/providers/mission_provider.dart';
import 'package:itea_app/providers/notification_provider.dart';

class AdminMissionDetailScreen extends StatefulWidget {
  final MissionModel mission;
  final Function(MissionModel)? onMissionUpdated;
  final Function()? onMissionDeleted;

  const AdminMissionDetailScreen({
    Key? key,
    required this.mission,
    this.onMissionUpdated,
    this.onMissionDeleted,
  }) : super(key: key);

  @override
  _AdminMissionDetailScreenState createState() => _AdminMissionDetailScreenState();
}

class _AdminMissionDetailScreenState extends State<AdminMissionDetailScreen> {
  static const Color _primary = Color(0xFF0059AB);
  static const Color _bg = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<NotificationProvider>(context, listen: false).markAsReadByMissionId(widget.mission.id);
        Provider.of<MissionProvider>(context, listen: false).markMissionAsReadLocal(widget.mission.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final lang = Provider.of<LanguageProvider>(context);

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
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfessionnelCard(lang),
                    SizedBox(height: 12.h),
                    _buildInfoCard(lang),
                    SizedBox(height: 12.h),
                    _buildMenuSection(lang),
                    SizedBox(height: 12.h),
                    _buildResidentsRegimesCard(lang),
                    SizedBox(height: 12.h),
                    _buildCodesCard(lang),
                    if (widget.mission.adminComments?.isNotEmpty == true) ...[
                      SizedBox(height: 12.h),
                      _buildNotesCard(lang),
                    ],
                    SizedBox(height: 20.h),
                    _buildActionButtons(lang),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, LanguageProvider lang) {
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
                  // Retour + actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      Row(
                        children: [
                          _buildHeaderAction(Icons.chat_bubble_outline_rounded, () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => AdminMissionChatScreen(mission: widget.mission),
                            ));
                          }),
                          SizedBox(width: 6.w),
                          _buildHeaderAction(Icons.edit_outlined, () async {
                            final updated = await Navigator.push<MissionModel>(
                              context,
                              MaterialPageRoute(builder: (_) => AdminEditMissionScreen(mission: widget.mission.toJson())),
                            );
                            if (updated != null && widget.onMissionUpdated != null) {
                              widget.onMissionUpdated!(updated);
                            }
                          }),
                        ],
                      ),
                    ],
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
                      widget.mission.status.toUpperCase(),
                      style: getInterStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Nom structure
                  Text(
                    widget.mission.structureName ?? 'Mission',
                    style: getInterStyle(fontSize: 22.sp, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  if (widget.mission.structureAddress != null && widget.mission.structureAddress!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.white70, size: 13.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(widget.mission.structureAddress!,
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

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }

  // ─── Professionnel Card ───────────────────────────────────────────────────────
  Widget _buildProfessionnelCard(LanguageProvider lang) {
    final bool isAssigned = widget.mission.professionnelNom != null &&
        widget.mission.professionnelNom!.trim().isNotEmpty;
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
                  isAssigned ? 'Professionnel assigné' : 'Assignation',
                  style: getInterStyle(fontSize: 11.sp, color: Colors.grey[500], fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 2.h),
                Text(
                  isAssigned ? widget.mission.professionnelNom! : 'En cours de sélection...',
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
      title: 'Informations générales',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          if (widget.mission.structureName != null)
            _buildInfoRow('Structure', widget.mission.structureName!),
          if (widget.mission.structureAddress != null)
            _buildInfoRow('Adresse', widget.mission.structureAddress!),
          _buildInfoRow('Statut', widget.mission.status),
          if (widget.mission.typesRepas.isNotEmpty)
            _buildInfoRow('Types de repas', widget.mission.typesRepas.map((t) => lang.translate(t) ?? t).join(', ')),
          if (widget.mission.horaireMission != null)
            _buildInfoRow('Heure début', DateFormat('HH:mm').format(widget.mission.horaireMission!)),
          if (widget.mission.heureFin != null)
            _buildInfoRow('Heure fin', widget.mission.heureFin!),
          if (widget.mission.dateFin != null)
            _buildInfoRow('Date fin', DateFormat('dd/MM/yyyy').format(widget.mission.dateFin!)),
          _buildInfoRow('Créé le', DateFormat('dd/MM/yyyy').format(widget.mission.createdAt)),
          _buildInfoRow('Par admin', widget.mission.estCreeParAdmin ? 'Oui' : 'Non'),
          if (widget.mission.remuneration != null && widget.mission.remuneration!.isNotEmpty)
            _buildInfoRow('Rémunération', '${widget.mission.remuneration} €'),
        ],
      ),
    );
  }

  // ─── Menu Section ─────────────────────────────────────────────────────────────
  Widget _buildMenuSection(LanguageProvider lang) {
    if (widget.mission.repas.isEmpty) {
      return _buildCard(
        title: 'Menu de la mission',
        icon: Icons.restaurant_menu_rounded,
        child: Center(
          child: Text('Aucun repas défini', style: getInterStyle(fontSize: 13.sp, color: Colors.grey[400], fontStyle: FontStyle.italic)),
        ),
      );
    }
    return Column(
      children: widget.mission.repas.map((r) => _buildRepasCard(r, lang)).toList(),
    );
  }

  Widget _buildRepasCard(RepasModel r, LanguageProvider lang) {
    final bool isSimple = r.typeRepas == 'breakfast' || r.typeRepas == 'snack';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: _primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.restaurant_menu_rounded, color: _primary, size: 16.sp),
        ),
        title: Text(
          (lang.translate(r.typeRepas) ?? r.typeRepas).toUpperCase(),
          style: getInterStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: 0.3),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Column(
              children: [
                if (isSimple)
                  _buildAdminMenuRow(lang.translate('meal_description') ?? 'Composition', r.getDisplayName('simple'), lang,
                      r.simpleRecettes.isNotEmpty ? r.simpleRecettes : (r.simpleRecette != null ? [r.simpleRecette!] : []))
                else ...[
                  _buildAdminMenuRow(lang.translate('starter_label') ?? 'Entrée', r.getDisplayName('entree'), lang,
                      r.entreeRecettes.isNotEmpty ? r.entreeRecettes : (r.entreeRecette != null ? [r.entreeRecette!] : [])),
                  _buildAdminMenuRow(lang.translate('dish_label') ?? 'Plat', r.getDisplayName('plat'), lang,
                      r.platRecettes.isNotEmpty ? r.platRecettes : (r.platRecette != null ? [r.platRecette!] : [])),
                  _buildAdminMenuRow(lang.translate('side_label') ?? 'Accompagnement', r.getDisplayName('side'), lang,
                      r.accompagnementRecettes.isNotEmpty ? r.accompagnementRecettes : (r.accompagnementRecette != null ? [r.accompagnementRecette!] : [])),
                  _buildAdminMenuRow(lang.translate('dessert_label') ?? 'Dessert', r.getDisplayName('dessert'), lang,
                      r.dessertRecettes.isNotEmpty ? r.dessertRecettes : (r.dessertRecette != null ? [r.dessertRecette!] : [])),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenuRow(String type, String content, LanguageProvider lang, List<RecipeModel> recipes) {
    if (content.isEmpty) return const SizedBox.shrink();

    List<String> allIngredients = [];
    for (var recipe in recipes) {
      if (recipe.ingredients != null) {
        for (var ing in recipe.ingredients!) {
          final nom = (ing['nom'] ?? ing['ingredient'] ?? '').toString();
          final qty = (ing['quantite'] ?? ing['amount'] ?? '').toString();
          if (nom.isNotEmpty) allIngredients.add(qty.isNotEmpty ? "$nom ($qty)" : nom);
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(top: 12.h),
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
            Text(type, style: getInterStyle(fontSize: 10.sp, color: Colors.grey[500], fontWeight: FontWeight.w500)),
            SizedBox(height: 3.h),
            Text(content, style: getInterStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w600)),
            ...recipes.map((recipe) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.tempsPreparation != null && recipe.tempsPreparation!.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Row(children: [
                    Icon(Icons.timer_outlined, size: 11.sp, color: _primary),
                    SizedBox(width: 4.w),
                    Text("Temps : ${recipe.tempsPreparation}", style: getInterStyle(fontSize: 11.sp, color: Colors.grey[600])),
                  ]),
                ],
                if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(recipe.description!, style: getInterStyle(fontSize: 12.sp, color: Colors.black87, height: 1.4)),
                ],
                if (allIngredients.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text("Ingrédients : ${allIngredients.join(', ')}",
                      style: getInterStyle(fontSize: 11.sp, color: _primary, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
                ],
              ],
            )).toList(),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => _openCreateRecipeModal(content, type, lang),
              child: Text('+ Associer recette', style: getInterStyle(fontSize: 11.sp, color: _primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Résidents & Régimes ──────────────────────────────────────────────────────
  Widget _buildResidentsRegimesCard(LanguageProvider lang) {
    return _buildCard(
      title: 'Résidents & Régimes',
      icon: Icons.people_outline_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatBox(Icons.people_alt_outlined, '${widget.mission.nbResidentsJour}', 'Résidents')),
              SizedBox(width: 10.w),
              Expanded(child: _buildStatBox(Icons.person_search_rounded, '${widget.mission.nbChefs}', 'Chefs')),
            ],
          ),
          if (widget.mission.regimesSpecifiques.haches > 0 ||
              widget.mission.regimesSpecifiques.mixes > 0 ||
              widget.mission.regimesSpecifiques.moulines > 0) ...[
            SizedBox(height: 12.h),
            Divider(color: Colors.grey[100], thickness: 1),
            SizedBox(height: 10.h),
            Text('Textures', style: getInterStyle(fontSize: 11.sp, color: Colors.grey[500], fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(child: _buildTextureChip('Hachés', widget.mission.regimesSpecifiques.haches)),
                SizedBox(width: 8.w),
                Expanded(child: _buildTextureChip('Mixés', widget.mission.regimesSpecifiques.mixes)),
                SizedBox(width: 8.w),
                Expanded(child: _buildTextureChip('Moulinés', widget.mission.regimesSpecifiques.moulines)),
              ],
            ),
          ],
          if (widget.mission.regimesSpeciaux.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Divider(color: Colors.grey[100], thickness: 1),
            SizedBox(height: 10.h),
            Text('Régimes spéciaux', style: getInterStyle(fontSize: 11.sp, color: Colors.grey[500], fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: widget.mission.regimesSpeciaux.map((diet) {
                const labels = {'textures': 'Textures modifiées', 'no_salt': 'Sans sel', 'diabetic': 'Diabétique', 'vegetarian': 'Végétarien', 'gluten_free': 'Sans gluten'};
                return _buildDietChip(labels[diet] ?? diet);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(color: _primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
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

  // ─── Codes d'accès Card ───────────────────────────────────────────────────────
  Widget _buildCodesCard(LanguageProvider lang) {
    return _buildCard(
      title: "Codes d'accès",
      icon: Icons.lock_outline_rounded,
      child: Column(
        children: [
          _buildCodeRow(lang.translate('entry_code') ?? "Code d'entrée", widget.mission.codeEntree ?? '...'),
          SizedBox(height: 10.h),
          _buildCodeRow(lang.translate('kitchen_code') ?? 'Code cuisine', widget.mission.codeCuisine ?? '...'),
        ],
      ),
    );
  }

  Widget _buildCodeRow(String label, String code) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: getInterStyle(fontSize: 10.sp, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              SizedBox(height: 3.h),
              Text(code, style: getInterStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.black87)),
            ],
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Code copié !'), backgroundColor: _primary, duration: const Duration(seconds: 1)),
              );
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: _primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.copy_outlined, color: _primary, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Notes Card ───────────────────────────────────────────────────────────────
  Widget _buildNotesCard(LanguageProvider lang) {
    return _buildCard(
      title: 'Notes administrateur',
      icon: Icons.notes_rounded,
      child: _buildNoteBlock('Notes internes', widget.mission.adminComments!, const Color(0xFFFFF8E1), Colors.amber[800]!),
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

  // ─── Action Buttons ───────────────────────────────────────────────────────────
  Widget _buildActionButtons(LanguageProvider lang) {
    final bool isTermine = widget.mission.status.toLowerCase() == 'terminé' ||
        widget.mission.status.toLowerCase() == 'terminée';
    return Column(
      children: [
        if (!isTermine)
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () => _validateMission(context, lang, Provider.of<MissionProvider>(context, listen: false)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C39D3),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 20.sp),
                  SizedBox(width: 10.w),
                  Text('Valider la Mission', style: getInterStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        if (isTermine && widget.mission.professionnelId != null) ...[
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () => _triggerPayment(context, lang),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payments_outlined, size: 20.sp),
                  SizedBox(width: 10.w),
                  Text('Déclencher le paiement', style: getInterStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────────
  void _triggerPayment(BuildContext context, LanguageProvider lang) {
    final remuneration = widget.mission.remuneration;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.payments_outlined, color: const Color(0xFF2E7D32), size: 24.sp),
          SizedBox(width: 8.w),
          Text('Déclencher le paiement', style: getInterStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ]),
        content: Text(
          remuneration != null
              ? 'Déclencher le paiement de $remuneration € vers ${widget.mission.professionnelNom ?? "le professionnel"} via Stripe ?'
              : 'Déclencher le paiement vers ${widget.mission.professionnelNom ?? "le professionnel"} via Stripe ?',
          style: getInterStyle(fontSize: 14.sp, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.translate('cancel') ?? 'Annuler', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await MissionService().payMission(widget.mission.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Expanded(child: Text('Paiement déclenché avec succès !'))]),
                    backgroundColor: const Color(0xFF2E7D32),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red[600]));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Confirmer', style: getInterStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _validateMission(BuildContext context, LanguageProvider lang, MissionProvider missionProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.check_circle_outline, color: const Color(0xFF2E7D32), size: 24.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text('Valider la Mission', style: getInterStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))),
        ]),
        content: Text(
          'Êtes-vous sûr de vouloir valider cette mission ? Elle sera envoyée à tous les professionnels.',
          style: getInterStyle(fontSize: 14.sp, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.translate('cancel') ?? 'Annuler', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await MissionService().processMission(widget.mission.id, {'statut': 'confirmé'});
                await missionProvider.fetchMissions();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Expanded(child: Text('Mission validée et envoyée aux professionnels !'))]),
                    backgroundColor: const Color(0xFF2E7D32),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red[600]));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Valider', style: getInterStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _openCreateRecipeModal(String suggestion, String typeLabel, LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 0.7.sh,
        padding: EdgeInsets.all(24.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Association de Recette', style: getInterStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('Contenu : $suggestion', style: getInterStyle(fontSize: 13.sp, color: Colors.grey[500])),
            SizedBox(height: 24.h),
            Text('Nom de la recette', style: getInterStyle(fontSize: 12.sp, color: Colors.grey[500], fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            TextField(
              controller: TextEditingController(text: suggestion),
              decoration: InputDecoration(
                filled: true,
                fillColor: _bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Confirmer', style: getInterStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Map<String, dynamic> _getStatusInfo(String status) {
    final s = status.toLowerCase().trim();
    if (s == 'terminé' || s == 'terminée') return {'color': Colors.grey[600]!};
    if (s.contains('refus') || s.contains('annul')) return {'color': const Color(0xFFD32F2F)};
    if (s == 'en cours') return {'color': const Color(0xFF2E7D32)};
    if (s.contains('confirm')) return {'color': const Color(0xFF1565C0)};
    return {'color': _primary};
  }
}
