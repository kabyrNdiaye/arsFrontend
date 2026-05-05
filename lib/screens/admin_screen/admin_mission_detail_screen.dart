// Version: 1.0.1 - Force Refresh
import 'package:flutter/material.dart';
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
  final Color _primaryGreen = const Color(0xFF4CA054);
  final Color _accentGreen = const Color(0xFF2D6A4F);
  final Color _bgOffWhite = const Color(0xFFFBFDFA);
  final Color _textDark = const Color(0xFF1A1A1A);
  final Color _textMuted = const Color(0xFF7F8C8D);
  final Color _dividerColor = const Color(0xFFECF0F1);

  @override
  void initState() {
    super.initState();
    // Marquer les notifications liées à cette mission comme lues dès l'ouverture
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
        final missionProvider = Provider.of<MissionProvider>(context, listen: false);
        
        // 1. Marquer les notifications système (cloche)
        notifProvider.markAsReadByMissionId(widget.mission.id);
        
        // 2. Marquer les messages de chat (badge local)
        missionProvider.markMissionAsReadLocal(widget.mission.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildMinimalAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              _buildModernHeaderTitle(),
              SizedBox(height: 24.h),
              _buildQuickInfoBar(),
              SizedBox(height: 32.h),
              
              _buildMinimalSectionTitle("Menu de la mission"),
              SizedBox(height: 16.h),
              _buildStreamlinedMealCards(lang),
              SizedBox(height: 32.h),

              _buildMinimalSectionTitle("Détails Techniques"),
              SizedBox(height: 16.h),
              _buildTechnicalStats(),
              SizedBox(height: 32.h),

              _buildMinimalSectionTitle("Accès & Logistique"),
              SizedBox(height: 16.h),
              _buildAccesLogistique(lang),
              SizedBox(height: 32.h),

              if (widget.mission.regimesSpeciaux.isNotEmpty) ...[
                _buildMinimalSectionTitle("Régimes & Préférences"),
                SizedBox(height: 16.h),
                _buildMinimalDietList(),
                SizedBox(height: 32.h),
              ],

              if (widget.mission.adminComments?.isNotEmpty ?? false) ...[
                _buildMinimalSectionTitle("Notes Administrateur"),
                SizedBox(height: 16.h),
                _buildCleanNotes(),
              ],
              
              SizedBox(height: 48.h),
              _buildActionButtons(lang),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMinimalAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: _textDark, size: 24.sp),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildModernHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: widget.mission.status == 'terminé' ? Colors.grey[100] : _primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.mission.status.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: widget.mission.status == 'terminé' ? Colors.grey[600] : _primaryGreen,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Hero(
          tag: 'mission_title_${widget.mission.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              widget.mission.structureName ?? "Nouvelle Mission",
              style: getSourceSerifProStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: _textDark,
                height: 1.2,
              ),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "Yoff, 17000, DAKAR",
          style: TextStyle(fontSize: 13.sp, color: _textMuted, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildQuickInfoBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuickInfoItem(Icons.people_alt_outlined, "${widget.mission.nbResidentsJour}", "Résidents"),
          SizedBox(width: 12.w),
          _buildVerticalSeparator(),
          SizedBox(width: 12.w),
          _buildQuickInfoItem(Icons.person_search_rounded, "${widget.mission.nbChefs}", "Chefs"),
          SizedBox(width: 12.w),
          _buildVerticalSeparator(),
          SizedBox(width: 12.w),
          _buildQuickInfoItem(Icons.calendar_today_outlined, widget.mission.horaireMission != null ? DateFormat('dd MMM').format(widget.mission.horaireMission!) : '...', "Date Début"),
          SizedBox(width: 12.w),
          _buildVerticalSeparator(),
          SizedBox(width: 12.w),
          _buildQuickInfoItem(Icons.access_time_rounded, widget.mission.horaireMission != null ? DateFormat('HH:mm').format(widget.mission.horaireMission!) : '...', "Heure Début"),
          SizedBox(width: 12.w),
          _buildVerticalSeparator(),
          SizedBox(width: 12.w),
          _buildQuickInfoItem(Icons.event_outlined, widget.mission.dateFin != null ? DateFormat('dd MMM').format(widget.mission.dateFin!) : '...', "Date Fin"),
          SizedBox(width: 12.w),
          _buildVerticalSeparator(),
          SizedBox(width: 12.w),
          _buildQuickInfoItem(Icons.timer_off_outlined, widget.mission.heureFin ?? "...", "Clôture"),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(IconData icon, String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: _primaryGreen),
            SizedBox(width: 6.w),
            Text(label, style: TextStyle(fontSize: 10.sp, color: _textMuted, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 4.h),
        Text(val, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: _textDark)),
      ],
    );
  }

  Widget _buildVerticalSeparator() => Container(height: 24.h, width: 1, color: _dividerColor);

  Widget _buildMinimalSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: getSourceSerifProStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(child: Divider(color: _dividerColor, thickness: 1)),
      ],
    );
  }

  Widget _buildTechnicalStats() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _bgOffWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTechStat("Hachés", "${widget.mission.regimesSpecifiques.haches}"),
              _buildTechStat("Mixés", "${widget.mission.regimesSpecifiques.mixes}"),
              _buildTechStat("Moulinés", "${widget.mission.regimesSpecifiques.moulines ?? 0}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechStat(String lab, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lab, style: TextStyle(fontSize: 10.sp, color: _textMuted, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(val, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: _textDark)),
      ],
    );
  }

  Widget _buildStreamlinedMealCards(LanguageProvider lang) {
    final repas = widget.mission.repas;
    if (repas.isEmpty) return Center(child: Text("Aucun repas défini", style: TextStyle(color: _textMuted)));

    return Column(
      children: repas.map((r) => _buildMinimalMealItem(r, lang)).toList(),
    );
  }

  Widget _buildMinimalMealItem(RepasModel r, LanguageProvider lang) {
    String label = r.typeRepas;
    bool isSimple = label == 'breakfast' || label == 'snack';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dividerColor),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Icon(Icons.restaurant_menu_rounded, color: _primaryGreen, size: 18.sp),
        title: Text(lang.translate(label).toUpperCase(), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: _textDark, letterSpacing: 0.5)),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Column(
              children: [
                if (isSimple) _buildMinimalRecipeRow(lang.translate('meal_description'), r.getDisplayName('simple'), lang, r.simpleRecettes.isNotEmpty ? r.simpleRecettes : (r.simpleRecette != null ? [r.simpleRecette!] : [])),
                if (!isSimple) ...[
                  _buildMinimalRecipeRow(lang.translate('starter_label'), r.getDisplayName('entree'), lang, r.entreeRecettes.isNotEmpty ? r.entreeRecettes : (r.entreeRecette != null ? [r.entreeRecette!] : [])),
                  _buildMinimalRecipeRow(lang.translate('dish_label'), r.getDisplayName('plat'), lang, r.platRecettes.isNotEmpty ? r.platRecettes : (r.platRecette != null ? [r.platRecette!] : [])),
                  _buildMinimalRecipeRow(lang.translate('side_label'), r.getDisplayName('side'), lang, r.accompagnementRecettes.isNotEmpty ? r.accompagnementRecettes : (r.accompagnementRecette != null ? [r.accompagnementRecette!] : [])),
                  _buildMinimalRecipeRow(lang.translate('dessert_label'), r.getDisplayName('dessert'), lang, r.dessertRecettes.isNotEmpty ? r.dessertRecettes : (r.dessertRecette != null ? [r.dessertRecette!] : [])),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalRecipeRow(String type, String content, LanguageProvider lang, List<RecipeModel> recipes) {
    if (content.isEmpty) return const SizedBox.shrink();
    
    // Extraire tous les ingrédients des recettes associées
    List<String> allIngredients = [];
    for (var recipe in recipes) {
      if (recipe.ingredients != null) {
        for (var ing in recipe.ingredients!) {
          String nom = (ing['nom'] ?? ing['ingredient'] ?? '').toString();
          String qty = (ing['quantite'] ?? ing['amount'] ?? '').toString();
          if (nom.isNotEmpty) {
            allIngredients.add(qty.isNotEmpty ? "$nom ($qty)" : nom);
          }
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70.w,
            child: Text(type, style: TextStyle(fontSize: 10.sp, color: _textMuted, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _textDark)),
                SizedBox(height: 8.h),
                ...recipes.map((recipe) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recipe.tempsPreparation != null && recipe.tempsPreparation!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 12.sp, color: _primaryGreen),
                              SizedBox(width: 4.w),
                              Text(
                                "Temps : ${recipe.tempsPreparation}",
                                style: TextStyle(fontSize: 11.sp, color: _textMuted, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      if (recipe.description != null && recipe.description!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Text(
                            recipe.description!,
                            style: TextStyle(fontSize: 12.sp, color: _textDark, height: 1.4),
                          ),
                        ),
                      if (allIngredients.isNotEmpty)
                        Text(
                          "Ingrédients : ${allIngredients.join(', ')}",
                          style: TextStyle(fontSize: 11.sp, color: _primaryGreen, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                        ),
                      SizedBox(height: 12.h),
                    ],
                  );
                }).toList(),
                SizedBox(height: 4.h),
                InkWell(
                  onTap: () => _openCreateRecipeModal(content, type, lang),
                  child: Text("+ Associer recette", style: TextStyle(fontSize: 10.sp, color: _primaryGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalDietList() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: widget.mission.regimesSpeciaux.map((diet) {
        final dietLabels = {
          'standard': 'Standard',
          'textures': 'Textures modifiées',
          'no_salt': 'Sans sel',
          'diabetic': 'Diabétique',
          'vegetarian': 'Végétarien',
          'vegan': 'Végétalien',
          'gluten_free': 'Sans gluten',
          'light': 'Léger'
        };
        String label = dietLabels[diet] ?? diet;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _dividerColor),
          ),
          child: Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: _textDark)),
        );
      }).toList(),
    );
  }

  Widget _buildCleanNotes() {
    if (widget.mission.adminComments == null || widget.mission.adminComments!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        _buildInfoNote("Notes Admin Internes", widget.mission.adminComments!),
      ],
    );
  }

  Widget _buildInfoNote(String label, String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _bgOffWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: _textMuted, fontWeight: FontWeight.bold)),
          SizedBox(height: 6.h),
          Text(text, style: TextStyle(fontSize: 13.sp, color: _textDark, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildAccesLogistique(LanguageProvider lang) {
    return Column(
      children: [
        _buildCodeRow(lang.translate('entry_code') ?? "Code d'entrée", widget.mission.codeEntree ?? "..."),
        SizedBox(height: 12.h),
        _buildCodeRow(lang.translate('kitchen_code') ?? "Code cuisine", widget.mission.codeCuisine ?? "..."),
      ],
    );
  }

  Widget _buildCodeRow(String label, String code) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _bgOffWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10.sp, color: _textMuted, fontWeight: FontWeight.bold)),
              SizedBox(height: 4.h),
              Text(code, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: _textDark)),
            ],
          ),
          Icon(Icons.lock_outline_rounded, color: _primaryGreen.withOpacity(0.5), size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildActionButtons(LanguageProvider lang) {
    final Color primaryPurple = const Color(0xFF7C39D3);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () => _validateMission(context, lang, Provider.of<MissionProvider>(context, listen: false)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: primaryPurple.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  'Valider la Mission',
                  style: getSourceSerifProStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _validateMission(BuildContext context, LanguageProvider lang, MissionProvider missionProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: const Color(0xFF2E7D32), size: 24.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Valider la Mission',
                style: getSourceSerifProStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir valider cette mission ? Elle sera envoyée à tous les professionnels.',
          style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.translate('cancel'), style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final missionService = MissionService();
                await missionService.processMission(widget.mission.id, {
                  'statut': 'confirmé',
                });
                await missionProvider.fetchMissions();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8.w),
                          const Expanded(child: Text('Mission validée et envoyée aux professionnels !')),
                        ],
                      ),
                      backgroundColor: const Color(0xFF2E7D32),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  Navigator.pop(context); // Retour à la liste
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la validation : $e'),
                      backgroundColor: Colors.red[600],
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Valider',
              style: getSourceSerifProStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600),
            ),
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
            Text('Association de Recette', style: getSourceSerifProStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('Contenu : $suggestion', style: TextStyle(color: _textMuted, fontSize: 13.sp)),
            SizedBox(height: 24.h),
            _buildModalField("Nom de la recette", TextEditingController(text: suggestion)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Confirmer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, color: _textMuted, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: _bgOffWhite,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
      ],
    );
  }
}
