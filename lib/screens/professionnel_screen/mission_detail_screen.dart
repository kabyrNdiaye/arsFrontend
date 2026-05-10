import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';
import '../../models/mission_model.dart';
import '../../providers/language_provider.dart';
import '../../services/mission_service.dart';
import '../../models/recipe_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/mission_provider.dart';
import '../../providers/notification_provider.dart';

class MissionDetailScreen extends StatefulWidget {
  final MissionModel mission;

  const MissionDetailScreen({
    Key? key,
    required this.mission,
  }) : super(key: key);

  @override
  _MissionDetailScreenState createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  final MissionService _missionService = MissionService();
  bool _isAccepting = false;
  bool _isCancelling = false;
  final Set<String> _expandedRecipes = {};
  bool _isFinishing = false;

  // Checklist état
  Map<String, bool> checklist = {
    'Ouverture': false,
    'Frigos': false,
    'Préparation': false,
    'Textures': false,
    'Dressage': false,
    'Nettoyage': false,
    'Signature': false,
  };

  @override
  void initState() {
    super.initState();
    if (widget.mission.checklistJournee != null && widget.mission.checklistJournee!.isNotEmpty) {
      checklist.addAll(widget.mission.checklistJournee!);
    }
    
    // Marquer les notifications liées à cette mission comme lues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).markAsReadByMissionId(widget.mission.id);
    });
  }

  String _monthName(int month) {
    const names = [
      '',
      'Jan', 'Fév', 'Mars', 'Avr', 'Mai', 'Juin',
      'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return (month >= 1 && month <= 12) ? names[month] : '';
  }

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
            _buildHeader(Provider.of<LanguageProvider>(context)),
            
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                  SizedBox(height: 16.h),
                  
                  // La section Informations générales de la mission a été retirée à la demande de l'utilisateur
                  
                  // Section Accès & Logistique
                  _buildAccesLogistique(),
                  
                  SizedBox(height: 16.h),
                  
                  // Section Menu du jour
                  _buildMenuDuJour(Provider.of<LanguageProvider>(context)),
                  
                  SizedBox(height: 16.h),
                  
                  // Section Quantités calculées
                  _buildQuantitesCalculees(),
                  
                  SizedBox(height: 16.h),
                  
                  // Section Checklist journée
                  _buildChecklistJournee(),
                  
                  // Section Notes Administrateur
                  if (widget.mission.adminComments != null && widget.mission.adminComments!.isNotEmpty)
                    _buildAdminNotes(),
                  
                  SizedBox(height: 24.h),
                  
                  // Boutons d'action
                  _buildActionButtons(Provider.of<LanguageProvider>(context)),
                  
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
                          langProvider.translate('back'),
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
                    widget.mission.structureName ?? langProvider.translate('not_defined'),
                    style: getInterStyle(
                      fontSize: 20.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Les informations de date et du professionnel ont été retirées à la demande de l'utilisateur
                  
                  // Adresse
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.white70, size: 16.sp),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          widget.mission.structureAddress ?? '',
                          style: getInterStyle(
                            fontSize: 13.sp,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                        '${widget.mission.horaireMission?.hour.toString().padLeft(2, '0')}:${widget.mission.horaireMission?.minute.toString().padLeft(2, '0')} - ${widget.mission.heureFin ?? "..."}',
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

  Widget _buildGeneralInfoSection(MissionModel mission, LanguageProvider lang) {
    String translateList(List<String> items) {
      return items
          .map((e) {
            final key = e.toLowerCase().replaceAll(' ', '_');
            return lang.translate(key) ?? e;
          })
          .toList()
          .join(', ');
    }

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
            lang.translate('mission_general_info') ?? 'Informations générales',
            style: getInterStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(lang.translate('avg_residents_day'), mission.nbResidentsJour.toString()),
          if (mission.typesRepas.isNotEmpty)
            _buildInfoRow(lang.translate('meal_types'), translateList(mission.typesRepas)),
          if (mission.regimesSpeciaux.isNotEmpty)
            _buildInfoRow(lang.translate('special_diets'), translateList(mission.regimesSpeciaux)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String? label, String? value) {
    if (label == null || label.isEmpty || value == null || value.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label :',
              style: getInterStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: getInterStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccesLogistique() {
    final lang = Provider.of<LanguageProvider>(context);
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
                lang.translate('access_logistics') ?? 'Accès & Logistique',
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
          _buildCodeRow(lang.translate('entry_code'), widget.mission.codeEntree ?? '...'),
          
          SizedBox(height: 12.h),
          
          // Code cuisine
          _buildCodeRow(lang.translate('kitchen_code'), widget.mission.codeCuisine ?? '...'),
          
          SizedBox(height: 16.h),
          
          // Bouton appeler
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final phone = widget.mission.structurePhone;
                if (phone != null && phone.isNotEmpty) {
                  final Uri launchUri = Uri(
                    scheme: 'tel',
                    path: phone,
                  );
                  if (await canLaunchUrl(launchUri)) {
                    await launchUrl(launchUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossible de lancer l\'appel')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Numéro de téléphone non disponible')),
                  );
                }
              },
              icon: Icon(Icons.phone_outlined, size: 18.sp, color: Color(0xFF0059AB)),
              label: Text(
                lang.translate('call_contact') ?? 'Appeler le contact',
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
                  content: Text(Provider.of<LanguageProvider>(context, listen: false).translate('code_copied')),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF0059AB),
                ),
              );
            },
            icon: Icon(Icons.copy_outlined, size: 16.sp),
            label: Text(
              Provider.of<LanguageProvider>(context, listen: false).translate('copy'),
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

  Widget _buildMenuDuJour(LanguageProvider lang) {
    final repas = widget.mission.repas;
    if (repas.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ...repas.asMap().entries.map((entry) {
        final idx = entry.key;
        final r = entry.value;
        bool isSimple = r.typeRepas == 'breakfast' || r.typeRepas == 'snack';
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
              // Titre du repas (Déjeuner, Dîner, etc.)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/chef.png', width: 18.sp, height: 18.sp),
                      SizedBox(width: 10.w),
                      Text(
                        'MENU',
                        style: getInterStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${widget.mission.repas.length > 1 ? 'Repas ${idx + 1} - ' : ''}${lang.translate(r.typeRepas).toUpperCase()}',
                    style: getInterStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0059AB),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              if (isSimple)
                _buildMenuItemWithBorder(lang.translate('meal_description'), r.getDisplayName('simple'), r.simpleRecettes.isNotEmpty ? r.simpleRecettes : (r.simpleRecette != null ? [r.simpleRecette!] : []))
              else ...[
                if (r.getDisplayName('entree').isNotEmpty)
                  _buildMenuItemWithBorder(lang.translate('starter_label'), r.getDisplayName('entree'), r.entreeRecettes.isNotEmpty ? r.entreeRecettes : (r.entreeRecette != null ? [r.entreeRecette!] : [])),
                if (r.getDisplayName('entree').isNotEmpty) SizedBox(height: 10.h),
                
                if (r.getDisplayName('plat').isNotEmpty)
                  _buildMenuItemWithBorder(lang.translate('dish_label'), r.getDisplayName('plat'), r.platRecettes.isNotEmpty ? r.platRecettes : (r.platRecette != null ? [r.platRecette!] : [])),
                if (r.getDisplayName('plat').isNotEmpty) SizedBox(height: 10.h),
                
                if (r.getDisplayName('side').isNotEmpty)
                  _buildMenuItemWithBorder(lang.translate('side_label'), r.getDisplayName('side'), r.accompagnementRecettes.isNotEmpty ? r.accompagnementRecettes : (r.accompagnementRecette != null ? [r.accompagnementRecette!] : [])),
                if (r.getDisplayName('side').isNotEmpty) SizedBox(height: 10.h),
                
                if (r.getDisplayName('dessert').isNotEmpty)
                  _buildMenuItemWithBorder(lang.translate('dessert_label'), r.getDisplayName('dessert'), r.dessertRecettes.isNotEmpty ? r.dessertRecettes : (r.dessertRecette != null ? [r.dessertRecette!] : [])),
              ],
            ],
          ),
        );
      }).toList(),
      ],
    );
  }



  Widget _buildMenuItemWithBorder(String category, String name, List<RecipeModel> recipes) {
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

    bool isExpanded = _expandedRecipes.contains(name);

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
            
            
            if (_expandedRecipes.contains(name)) ...[
              SizedBox(height: 12.h),
              // Détails des recettes
              ...recipes.map((recipe) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipes.length > 1)
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Text(recipe.nom, style: getInterStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ),
                    
                    if (recipe.tempsPreparation != null && recipe.tempsPreparation!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 14.sp, color: Color(0xFF0059AB)),
                            SizedBox(width: 4.w),
                            Text(
                              "Temps : ${recipe.tempsPreparation}",
                              style: getInterStyle(fontSize: 12.sp, color: Colors.grey[700], fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      
                    if (recipe.description != null && recipe.description!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          recipe.description!,
                          style: getInterStyle(fontSize: 13.sp, color: Colors.black87, height: 1.4),
                        ),
                      ),

                    if (allIngredients.isNotEmpty)
                      Text(
                        "Ingrédients : ${allIngredients.join(', ')}",
                        style: getInterStyle(
                          fontSize: 12.sp,
                          color: Color(0xFF0059AB),
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    SizedBox(height: 12.h),
                  ],
                );
              }).toList(),
            ],
            SizedBox(height: 8.h),
            if (allIngredients.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedRecipes.remove(name);
                    } else {
                      _expandedRecipes.add(name);
                    }
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpanded 
                          ? (Provider.of<LanguageProvider>(context, listen: false).translate('hide_recipe') ?? 'Masquer les ingrédients')
                          : (Provider.of<LanguageProvider>(context, listen: false).translate('view_recipe') ?? 'Voir la recette'),
                      style: getInterStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF0085FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 16.sp, color: Color(0xFF0085FF)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitesCalculees() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
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
            lang.translate('calculated_quantities') ?? 'Quantités calculées',
            style: getInterStyle(
              fontSize: 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Box avec résidents et chefs
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
                _buildResidentRow(lang.translate('residents') ?? 'Résidents', '${widget.mission.nbResidentsJour}', isHighlighted: true),
                SizedBox(height: 8.h),
                _buildResidentRow(lang.translate('chefs_needed') ?? 'Chefs requis', '${widget.mission.nbChefs}', isHighlighted: true),
                
                // Ajout de la répartition par texture
                if (widget.mission.regimesSpecifiques.haches > 0 || 
                    widget.mission.regimesSpecifiques.mixes > 0 || 
                    widget.mission.regimesSpecifiques.moulines > 0) ...[
                  Divider(height: 20.h, color: Color(0xFF0059AB).withOpacity(0.1)),
                  Text('Répartition par texture :', style: getInterStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Color(0xFF0059AB))),
                  SizedBox(height: 8.h),
                  _buildResidentRow('Hachés', '${widget.mission.regimesSpecifiques.haches}'),
                  _buildResidentRow('Mixés', '${widget.mission.regimesSpecifiques.mixes}'),
                  _buildResidentRow('Moulinés', '${widget.mission.regimesSpecifiques.moulines}'),
                ],
              ],
            ),
          ),
          
          // Section supprimée: Viande, Légumes, Riz/Féc.
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
    final lang = Provider.of<LanguageProvider>(context, listen: false);
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
            lang.translate('daily_checklist') ?? 'Checklist journée',
            style: getInterStyle(
              fontSize: 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Liste des tâches
          ...checklist.entries.map((entry) {
            final key = entry.key.toLowerCase() == 'ouverture' ? 'opening' : 
                        entry.key.toLowerCase() == 'frigos' ? 'fridges' :
                        entry.key.toLowerCase() == 'préparation' ? 'preparation' :
                        entry.key.toLowerCase() == 'textures' ? 'textures' :
                        entry.key.toLowerCase() == 'dressage' ? 'plating' :
                        entry.key.toLowerCase() == 'nettoyage' ? 'cleaning' :
                        entry.key.toLowerCase() == 'signature' ? 'signature' : entry.key;
            return _buildChecklistItem(lang.translate(key) ?? entry.key, entry.value, entry.key);
          }),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String label, bool isChecked, String originalKey) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: GestureDetector(
        onTap: () async {
          setState(() {
            checklist[originalKey] = !isChecked;
          });
          try {
            await _missionService.updateChecklist(widget.mission.id, checklist);
          } catch (e) {
            debugPrint('Erreur lors de la mise à jour de la checklist: $e');
          }
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

  Widget _buildAdminNotes() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0xFFFFF9C4), // Jaune clair pour une note
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
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
          Row(
            children: [
              Icon(Icons.event_note, color: Colors.orange[800], size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                lang.translate('admin_notes') ?? 'Notes Administrateur',
                style: getInterStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            widget.mission.adminComments!,
            style: getInterStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishMission() async {
    // Vérifier que toute la checklist est cochée
    bool allChecked = checklist.values.every((value) => value == true);
    if (!allChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez cocher tous les éléments de la checklist avant de terminer la mission'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isFinishing = true);
    try {
      await _missionService.finishMission(widget.mission.id);
      if (mounted) {
        setState(() => _isFinishing = false);
        _showFeedbackDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFinishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showFeedbackDialog() {
    double rating = 5.0;
    final TextEditingController commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 48.sp),
              SizedBox(height: 12.h),
              Text("Mission Terminée !", style: getInterStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Votre avis nous intéresse. Comment s'est passée votre mission ?", 
                textAlign: TextAlign.center,
                style: getInterStyle(fontSize: 14.sp, color: Colors.grey[700])),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 32.sp,
                    ),
                    onPressed: () {
                      setDialogState(() => rating = index + 1.0);
                    },
                  );
                }),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Un commentaire ? (Optionnel)",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  setDialogState(() => isSubmitting = true);
                  try {
                    final String content = "⭐ FEEDBACK: [Note: $rating/5] ${commentController.text.trim()}";
                    await _missionService.sendChatMessage(widget.mission.id, content, type: 'feedback');
                    
                    if (mounted) {
                      Navigator.pop(context); // Fermer dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Merci pour votre retour !"), backgroundColor: Colors.green),
                      );
                      Navigator.pop(context, true); // Quitter le détail de mission
                    }
                  } catch (e) {
                    if (mounted) {
                      setDialogState(() => isSubmitting = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erreur lors de l'envoi : $e")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0059AB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Envoyer mon avis", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context, true), // Quitter sans envoyer mais avec refresh
                child: Text("Passer pour l'instant", style: TextStyle(color: Colors.grey[600])),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(LanguageProvider langProvider) {
    final String? userStatus = widget.mission.userStatus;
    final bool isActuallyAssignedToMe = widget.mission.professionnelId != null && userStatus == 'confirmé';
    final bool isAssignedToOther = widget.mission.professionnelId != null && userStatus != 'confirmé';
    final bool isRefused = userStatus == 'refusé';
    final missionProvider = Provider.of<MissionProvider>(context);
    final bool hasOngoing = missionProvider.hasOngoingMission;

    if (userStatus == 'refusé') {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            langProvider.translate('you_refused_mission'),
            style: getInterStyle(fontSize: 15.sp, color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    // DEBUG: Print mission and user status
    debugPrint('🔍 [DEBUG] _buildActionButtons:');
    debugPrint('   - mission.status: ${widget.mission.status}');
    debugPrint('   - mission.userStatus: ${widget.mission.userStatus}');
    debugPrint('   - mission.professionnelId: ${widget.mission.professionnelId}');
    debugPrint('   - isRefused: $isRefused');
    debugPrint('   - isAssignedToOther: $isAssignedToOther');
    debugPrint('   - isActuallyAssignedToMe: $isActuallyAssignedToMe');

    if (isRefused) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            langProvider.translate('you_refused_mission'),
            style: getInterStyle(fontSize: 15.sp, color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    if (isAssignedToOther) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            langProvider.translate('already_assigned_other'),
            style: getInterStyle(fontSize: 15.sp, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    // Affiche les boutons d'acceptation/refus SEULEMENT si la mission n'est pas déjà acceptée
    if (widget.mission.status == 'en attente' && userStatus != 'confirmé') {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isAccepting ? null : _rejectMission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    langProvider.translate('refuse'),
                    style: getInterStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: (_isAccepting || (hasOngoing && widget.mission.status.toLowerCase() != 'en cours')) 
                      ? null 
                      : _acceptMission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (hasOngoing && widget.mission.status.toLowerCase() != 'en cours') 
                        ? Colors.grey 
                        : Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isAccepting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : (hasOngoing && widget.mission.status.toLowerCase() != 'en cours')
                          ? Text(
                              'Mission en cours...',
                              style: getInterStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              langProvider.translate('accept'),
                              style: getInterStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.mission.status == 'terminé') {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'Cette mission est terminée',
            style: getInterStyle(fontSize: 15.sp, color: Colors.green, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    // Affiche les boutons uniquement si la mission est acceptée par le professionnel
    if (!isActuallyAssignedToMe) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            langProvider.translate('mission_not_accepted_yet') ?? 'Vous devez accepter la mission avant de pouvoir accéder à ces actions.',
            style: getInterStyle(fontSize: 15.sp, color: Colors.grey, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Bouton Annuler la mission (orange)
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: _isCancelling ? null : () => _showCancellationDialog(langProvider),
                icon: _isCancelling
                    ? SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(Icons.cancel_outlined, size: 20.sp),
                label: Text(
                  'Annuler la mission',
                  style: getInterStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Bouton Signaler un incident (rouge)
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: () => _showIncidentDialog(langProvider),
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
                  langProvider.translate('report_incident'),
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
            

            
            SizedBox(height: 20.h),
            
            // Bouton Terminer la mission (vert)
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: _isFinishing ? null : _finishMission,
                icon: _isFinishing 
                  ? SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Icon(Icons.check_circle_outline, size: 20.sp),
                label: Text(
                  langProvider.translate('finish_mission') ?? 'Terminer la mission',
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
      ),
    );
  }

  void _showCancellationDialog(LanguageProvider lang) {
    final TextEditingController motifController = TextEditingController();
    String? errorText;

    // Calculer si < 24h
    final bool isLate = widget.mission.horaireMission != null &&
        widget.mission.horaireMission!.difference(DateTime.now()).inHours < 24;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B35), size: 40.sp),
              SizedBox(height: 8.h),
              Text(
                'Annuler la mission',
                style: getInterStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Règle 24h
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700], size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'L\'annulation doit être effectuée au moins 24h avant la mission.',
                          style: getInterStyle(fontSize: 13.sp, color: Colors.orange[900]!, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Avertissement bannissement (renforcé si < 24h)
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isLate ? Color(0xFFFFEBEE) : Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.gavel, color: Colors.red[700], size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          isLate
                              ? '⚠️ ANNULATION TARDIVE : Vous annulez à moins de 24h. Cela peut entraîner une suspension ou un bannissement de l\'application.'
                              : 'Toute annulation sans motif valable ou annulation répétée peut entraîner un bannissement de l\'application.',
                          style: getInterStyle(
                            fontSize: 13.sp,
                            color: Colors.red[800]!,
                            fontWeight: isLate ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Champ motif
                Text(
                  'Motif d\'annulation *',
                  style: getInterStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: motifController,
                  maxLines: 4,
                  maxLength: 500,
                  onChanged: (_) {
                    if (errorText != null) setDialogState(() => errorText = null);
                  },
                  decoration: InputDecoration(
                    hintText: 'Expliquez la raison de l\'annulation (minimum 10 caractères)...',
                    hintStyle: getInterStyle(fontSize: 12.sp, color: Colors.grey),
                    errorText: errorText,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFFF6B35)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Bouton retour
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text('Retour', style: getInterStyle(fontSize: 14.sp, color: Colors.grey[700]!)),
              ),
            ),
            SizedBox(height: 8.h),
            // Bouton confirmer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final motif = motifController.text.trim();
                  if (motif.length < 10) {
                    setDialogState(() => errorText = 'Le motif doit contenir au moins 10 caractères.');
                    return;
                  }
                  Navigator.pop(context);
                  _cancelMission(motif, isLate);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'Confirmer l\'annulation',
                  style: getInterStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelMission(String motif, bool isLate) async {
    setState(() => _isCancelling = true);
    try {
      await _missionService.cancelMission(widget.mission.id, motif);
      if (mounted) {
        setState(() => _isCancelling = false);
        // Snackbar avec avertissement renforcé si tardif
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLate
                  ? '⚠️ Mission annulée. L\'admin a été notifié. Attention : annulation tardive.'
                  : 'Mission annulée. L\'administrateur a été notifié.',
            ),
            backgroundColor: isLate ? Colors.orange[800] : Colors.green[700],
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, true); // Retour avec refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showIncidentDialog(LanguageProvider lang) {
    String selectedType = 'Matériel';
    final TextEditingController descriptionController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10.w),
              Text("Signaler un incident", style: getInterStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Type d'incident", style: getInterStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: ['Matériel', 'Retard', 'Santé', 'Cuisine', 'Autre'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedType = val);
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text("Description", style: getInterStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Décrivez le problème...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: isSending ? null : () async {
                if (descriptionController.text.trim().isEmpty) return;
                
                setDialogState(() => isSending = true);
                try {
                  final String content = "🚨 INCIDENT: [$selectedType] ${descriptionController.text.trim()}";
                  await _missionService.sendChatMessage(widget.mission.id, content, type: 'incident');
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Incident signalé à l'administration"), backgroundColor: Colors.orange),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    setDialogState(() => isSending = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erreur lors de l'envoi : $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isSending 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text("Envoyer", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptMission() async {
    setState(() => _isAccepting = true);
    try {
      await _missionService.acceptMission(widget.mission.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Provider.of<LanguageProvider>(context, listen: false).translate('mission_accepted_msg')),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context, true); // Le true indique qu'une mise à jour est nécessaire
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${Provider.of<LanguageProvider>(context, listen: false).translate('error')} : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  Future<void> _rejectMission() async {
    setState(() => _isAccepting = true);
    try {
      await _missionService.rejectMission(widget.mission.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Provider.of<LanguageProvider>(context, listen: false).translate('mission_refused')),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${Provider.of<LanguageProvider>(context, listen: false).translate('error')} : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }
}


