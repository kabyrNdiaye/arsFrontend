// Version: 1.0.1 - Alignment with Edit Form
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itea_app/utils/font_helper.dart';
import 'package:itea_app/models/mission_model.dart';
import 'package:itea_app/models/recipe_model.dart';
import 'package:itea_app/services/mission_service.dart';
import 'package:itea_app/services/recipe_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:itea_app/providers/mission_provider.dart';
import 'package:itea_app/providers/language_provider.dart';
import 'package:itea_app/widgets/petal_success_animation.dart';
import 'package:itea_app/models/user_model.dart';
import 'package:itea_app/services/auth_service.dart';
import '../../widgets/template_selector_sheet.dart';
import 'package:itea_app/services/menu_service.dart';
import 'package:itea_app/models/menu_model.dart';
import 'dart:async';
import 'package:itea_app/providers/recipe_provider.dart';
class AdminCreateMissionScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onMissionCreated;

  const AdminCreateMissionScreen({
    Key? key,
    this.onMissionCreated,
  }) : super(key: key);

  @override
  _AdminCreateMissionScreenState createState() => _AdminCreateMissionScreenState();
}

class _AdminCreateMissionScreenState extends State<AdminCreateMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryPurple = const Color(0xFF7C39D3);
  bool _isLoading = false;
  bool _isSuccess = false;
  
  // Structures state
  List<User> _structures = [];
  bool _isStructuresLoading = true;
  User? _selectedStructure;

  // Contrôleurs de base
  late TextEditingController _establishmentController;
  late TextEditingController _addressController;

  // Contrôleurs mission
  late TextEditingController _residentsController;
  late TextEditingController _chefsController;
  
  // Dynamic Map of controllers: {meal_type: {category: controller}}
  final Map<String, Map<String, TextEditingController>> _menuControllers = {};
  
  late TextEditingController _commentsController;
  late TextEditingController _entryCodeController;
  late TextEditingController _kitchenCodeController;
  late TextEditingController _hachesController;
  late TextEditingController _mixesController;
  late TextEditingController _moulinesController;

  DateTime? _selectedDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedTime;
  TimeOfDay? _selectedEndTime;
  List<String> _selectedMeals = [];
  List<String> _selectedDiets = [];
  
  // Recipe matching state
  final Map<String, List<RecipeModel>> _selectedRecipes = {
    'starter': [],
    'dish': [],
    'side': [],
    'dessert': [],
  };

  String _selectedStatus = 'En cours';
  final List<String> _statusOptions = ['En cours', 'Confirmée', 'Réfusé'];

  @override
  void initState() {
    super.initState();
    _establishmentController = TextEditingController();
    _addressController = TextEditingController();
    _residentsController = TextEditingController(text: '0');
    _chefsController = TextEditingController(text: '1');
    _commentsController = TextEditingController();
    _entryCodeController = TextEditingController();
    _kitchenCodeController = TextEditingController();
    _hachesController = TextEditingController(text: '0');
    _mixesController = TextEditingController(text: '0');
    _moulinesController = TextEditingController(text: '0');
    _loadStructures();
  }

  Future<void> _loadStructures() async {
    setState(() => _isStructuresLoading = true);
    try {
      final structures = await AuthService().getStructures();
      setState(() {
        _structures = structures;
        _isStructuresLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isStructuresLoading = false);
      }
    }
  }

  void _initMenuControllers(String mealType) {
    if (!_menuControllers.containsKey(mealType)) {
      _menuControllers[mealType] = {
        'entree': TextEditingController(),
        'plat': TextEditingController(),
        'accompagnement': TextEditingController(),
        'dessert': TextEditingController(),
      };
    }
  }

  @override
  void dispose() {
    _establishmentController.dispose();
    _addressController.dispose();
    _residentsController.dispose();
    _menuControllers.values.forEach((catMap) {
      catMap.values.forEach((ctrl) => ctrl.dispose());
    });
    _chefsController.dispose();
    _commentsController.dispose();
    _entryCodeController.dispose();
    _kitchenCodeController.dispose();
    _hachesController.dispose();
    _mixesController.dispose();
    _moulinesController.dispose();
    super.dispose();
  }

  // === UI Helpers Identical to Edit screen ===

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16.h,
                decoration: BoxDecoration(
                  color: _primaryPurple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(icon, color: _primaryPurple.withOpacity(0.7), size: 18.sp),
              SizedBox(width: 10.w),
              Text(
                title,
                style: getSourceSerifProStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEditableTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    final bool isFilled = controller.text.isNotEmpty;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: getSourceSerifProStyle(fontSize: 13.sp, color: isFilled ? _primaryPurple.withOpacity(0.6) : Colors.grey[400], fontWeight: FontWeight.w500),
        filled: true,
        fillColor: isFilled ? _primaryPurple.withOpacity(0.05) : const Color(0xFFF9FAFB),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: isFilled ? BorderSide(color: _primaryPurple.withOpacity(0.3), width: 1) : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: isFilled ? BorderSide(color: _primaryPurple.withOpacity(0.3), width: 1) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryPurple.withOpacity(0.5), width: 1.5),
        ),
      ),
      validator: (val) => (val == null || val.isEmpty) ? 'Champ requis' : null,
    );
  }

  Widget _buildSmallNumberField(TextEditingController controller, String label) {
    final bool isFilled = controller.text.isNotEmpty && controller.text != '0';
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isFilled ? _primaryPurple.withOpacity(0.05) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isFilled ? _primaryPurple.withOpacity(0.3) : Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: isFilled ? _primaryPurple : Colors.grey[500], fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          SizedBox(height: 6.h),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() {}),
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: isFilled ? _primaryPurple : Colors.black87),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker({required IconData icon, required String label, required VoidCallback onTap, bool isFilled = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isFilled ? _primaryPurple.withOpacity(0.05) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: isFilled ? Border.all(color: _primaryPurple.withOpacity(0.3), width: 1) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: getSourceSerifProStyle(fontSize: 12.sp, color: isFilled ? _primaryPurple : Colors.black87, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, size: 14.sp, color: isFilled ? _primaryPurple : Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeTextField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: EdgeInsets.all(16.w),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primaryPurple.withOpacity(0.3), width: 1),
        ),
      ),
    );
  }

  Widget _buildMealMenuSection(String mealType) {
    _initMenuControllers(mealType);
    final controllers = _menuControllers[mealType]!;
    
    String label = mealType;
    IconData icon = Icons.restaurant;
    Color color = _primaryPurple;

    final lang = Provider.of<LanguageProvider>(context, listen: false);

    if (mealType == 'breakfast') {
      label = lang.translate('breakfast');
      icon = Icons.coffee_rounded;
      color = const Color(0xFFE65100);
    } else if (mealType == 'lunch') {
      label = lang.translate('lunch');
      icon = Icons.restaurant_rounded;
      color = const Color(0xFF009814);
    } else if (mealType == 'snack') {
      label = lang.translate('snack');
      icon = Icons.bakery_dining_rounded;
      color = const Color(0xFFC2185B);
    } else if (mealType == 'dinner') {
      label = lang.translate('dinner');
      icon = Icons.nightlight_round;
      color = const Color(0xFF0059AB);
    }

    bool isSimpleMeal = mealType == 'breakfast' || mealType == 'snack';

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18.sp, color: color),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: getSourceSerifProStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _openMenuTemplateSelector(mealType),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 12.sp, color: color),
                        SizedBox(width: 4.w),
                        Text(
                          'Template',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                if (isSimpleMeal)
                  _buildMenuBlockWithRecipes('Contenu du repas', controllers['plat']!, 'dish')
                else ...[
                  _buildMenuBlockWithRecipes(lang.translate('starter_label'), controllers['entree']!, 'starter'),
                  SizedBox(height: 16.h),
                  _buildMenuBlockWithRecipes(lang.translate('dish_label'), controllers['plat']!, 'dish'),
                  SizedBox(height: 16.h),
                  _buildMenuBlockWithRecipes(lang.translate('side_label'), controllers['accompagnement']!, 'side'),
                  SizedBox(height: 16.h),
                  _buildMenuBlockWithRecipes(lang.translate('dessert_label'), controllers['dessert']!, 'dessert'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBlockWithRecipes(String label, TextEditingController controller, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: getSourceSerifProStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.black87)),
            InkWell(
              onTap: () => _openCreateRecipeModal(controller.text, label),
              child: Text('+ Nouvelle recette', style: getSourceSerifProStyle(color: _primaryPurple, fontWeight: FontWeight.bold, fontSize: 11.sp)),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          style: getSourceSerifProStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Description du plat...',
            hintStyle: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryPurple.withOpacity(0.3), width: 1)),
          ),
        ),
        if (_selectedRecipes[type]!.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _selectedRecipes[type]!.map<Widget>((RecipeModel r) => Container(
              constraints: BoxConstraints(maxWidth: 0.8.sw),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _primaryPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primaryPurple.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu_rounded, size: 12.sp, color: _primaryPurple),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      r.nom,
                      style: TextStyle(fontSize: 12.sp, color: _primaryPurple, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  GestureDetector(
                    onTap: () => setState(() => _selectedRecipes[type]!.removeWhere((RecipeModel x) => x.id == r.id)),
                    child: Icon(Icons.close_rounded, size: 14.sp, color: _primaryPurple.withOpacity(0.5)),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => _openSearchRecipeModal(type),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 14.sp, color: _primaryPurple),
              SizedBox(width: 4.w),
              Text('Associer une recette existante',
                  style: TextStyle(
                      color: _primaryPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                      decoration: TextDecoration.underline)),
            ],
          ),
        ),
      ],
    );
  }

  // === Menu Template Selector ===
  void _openMenuTemplateSelector(String mealType) async {
    String templateType = '';
    if (mealType == 'breakfast') templateType = 'Petit-Déjeuner';
    if (mealType == 'lunch') templateType = 'Déjeuner';
    if (mealType == 'snack') templateType = 'Goûter';
    if (mealType == 'dinner') templateType = 'Dîner';

    Color color = _primaryPurple;
    if (mealType == 'breakfast') color = const Color(0xFFE65100);
    if (mealType == 'lunch') color = const Color(0xFF009814);
    if (mealType == 'snack') color = const Color(0xFFC2185B);
    if (mealType == 'dinner') color = const Color(0xFF0059AB);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TemplateSelectorSheet(
        mealType: mealType,
        templateType: templateType,
        primaryColor: color,
        onSelected: (template) => _applyTemplate(mealType, template),
      ),
    );
  }

  void _applyTemplate(String mealType, MenuModel template) async {
    setState(() => _isLoading = true);
    try {
      // Pour appliquer le template, nous avons besoin des RecipeModels réels.
      // Nous allons les récupérer par leurs IDs.
      final allRecipes = await RecipeService().getRecipes();
      
      _initMenuControllers(mealType);
      final controllers = _menuControllers[mealType]!;

      // Mapping des catégories
      Map<String, String> categoryMapping = {
        'entree': 'starter',
        'plat': 'dish',
        'accompagnement': 'side',
        'dessert': 'dessert',
        'proposition': 'dish',
      };

      setState(() {
        template.recipeIds.forEach((templateCat, ids) {
          String missionCat = categoryMapping[templateCat] ?? 'dish';
          
          final categoryRecipes = allRecipes.where((r) => ids.contains(r.id)).toList();
          
          // On ajoute les recettes au set des recettes sélectionnées
          for (var r in categoryRecipes) {
            if (!_selectedRecipes[missionCat]!.any((x) => x.id == r.id)) {
              _selectedRecipes[missionCat]!.add(r);
            }
          }

          // On met à jour aussi la description textuelle si elle est vide
          if (controllers.containsKey(templateCat) && controllers[templateCat]!.text.isEmpty) {
             controllers[templateCat]!.text = categoryRecipes.map((r) => r.nom).join(', ');
          }
        });
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template appliqué avec succès !')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'application du template: $e')),
      );
    }
  }

  // === Recipe Search Modal ===
  void _openSearchRecipeModal(String type) {
    String recipeType = '';
    if (type == 'starter') recipeType = 'entree';
    if (type == 'dish') recipeType = 'plat';
    if (type == 'side') recipeType = 'accompagnement';
    if (type == 'dessert') recipeType = 'dessert';

    final lang = Provider.of<LanguageProvider>(context, listen: false);

    // Pré-charger les recettes AVANT d'ouvrir le dialog 
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipeProvider.fetchRecipes(
      type: recipeType.isNotEmpty ? recipeType : null,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return _RecipeSearchSheet(
          type: type,
          recipeType: recipeType,
          lang: lang,
          primaryPurple: _primaryPurple,
          initialSelectedRecipes: _selectedRecipes[type]!,
          onRecipesSelected: (selectedRecipes) {
            setState(() {
              for (var recipe in selectedRecipes) {
                if (!_selectedRecipes[type]!.any((r) => r.id == recipe.id)) {
                  _selectedRecipes[type]!.add(recipe);
                }
              }
            });
          },
          onClear: () {
            setState(() => _selectedRecipes[type]!.clear());
          },
        );
      },
    );
  }

  // === Modal logic for Recipes ===
  void _openCreateRecipeModal(String suggestion, String typeLabel) {
    TextEditingController nameController = TextEditingController(text: suggestion);
    TextEditingController descController = TextEditingController(text: suggestion);
    TextEditingController timeController = TextEditingController();
    
    List<Map<String, TextEditingController>> ingredientsControllers = [
      {'nom': TextEditingController(), 'quantite': TextEditingController(text: "1"), 'prix': TextEditingController(text: "0")},
    ];
    
    final List<String> regimeOptions = ['Standard', 'Sans sel', 'Diabétique', 'Végétarien', 'Végétalien', 'Sans gluten', 'Léger'];
    final List<String> textureOptions = ['Normal', 'Haché', 'Mixé', 'Mouliné'];

    Map<String, TextEditingController> regimeControllers = {
      for (var r in regimeOptions) r: TextEditingController(text: "0")
    };
    Map<String, TextEditingController> textureControllers = {
      for (var t in textureOptions) t: TextEditingController(text: "0")
    };
    
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 0.85.sh,
          padding: EdgeInsets.all(20.w),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              SizedBox(height: 10.h),
              Text('Nouvelle recette : $typeLabel', style: getSourceSerifProStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
              SizedBox(height: 16.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModalField('Nom de la recette *', nameController),
                      SizedBox(height: 12.h),
                      _buildModalField('Description', descController, maxLines: 2),
                      SizedBox(height: 16.h),
                      Text('Ingrédients', style: getSourceSerifProStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                      SizedBox(height: 8.h),
                      ...ingredientsControllers.asMap().entries.map((entry) {
                        int i = entry.key;
                        var ctrl = entry.value;
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: _buildModalField('Nom', ctrl['nom']!)),
                              SizedBox(width: 8.w),
                              Expanded(flex: 1, child: _buildModalField('Qté', ctrl['quantite']!, keyboardType: TextInputType.number)),
                              SizedBox(width: 8.w),
                              Expanded(flex: 1, child: _buildModalField('Prix (€)', ctrl['prix']!, keyboardType: TextInputType.number)),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red[300], size: 20.sp),
                                onPressed: () => setModalState(() => ingredientsControllers.removeAt(i))
                              )
                            ],
                          ),
                        );
                      }).toList(),
                      TextButton.icon(
                        icon: Icon(Icons.add_circle_outline, color: _primaryPurple),
                        label: Text('Ajouter un ingrédient', style: getSourceSerifProStyle(color: _primaryPurple, fontWeight: FontWeight.bold)),
                        onPressed: () => setModalState(() {
                          ingredientsControllers.add({'nom': TextEditingController(), 'quantite': TextEditingController(text: "1"), 'prix': TextEditingController(text: "0")});
                        }),
                      ),
                      SizedBox(height: 12.h),
                      _buildModalField('Temps de préparation (ex: 30 min)', timeController),
                      SizedBox(height: 24.h),
                      
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Text('Régimes compatibles (Quantités)', style: getSourceSerifProStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.black)),
                      ),
                      Divider(height: 1.h),
                      SizedBox(height: 12.h),
                      ...regimeOptions.map((regime) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            Expanded(child: Text(regime, style: getSourceSerifProStyle(fontSize: 14.sp))),
                            SizedBox(
                              width: 80.w,
                              child: _buildModalField('', regimeControllers[regime]!, keyboardType: TextInputType.number),
                            ),
                          ],
                        ),
                      )).toList(),
                      
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Text('Textures adaptées (Quantités)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.black)),
                      ),
                      Divider(height: 1.h),
                      SizedBox(height: 12.h),
                      ...textureOptions.map((texture) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            Expanded(child: Text(texture, style: getSourceSerifProStyle(fontSize: 14.sp))),
                            SizedBox(
                              width: 80.w,
                              child: _buildModalField('', textureControllers[texture]!, keyboardType: TextInputType.number),
                            ),
                          ],
                        ),
                      )).toList(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (nameController.text.isEmpty) return;
                    setModalState(() => isSaving = true);
                    try {
                      final typeKey = typeLabel.toLowerCase().contains('entrée') ? 'starter' : 
                                       typeLabel.toLowerCase().contains('plat') ? 'dish' :
                                       typeLabel.toLowerCase().contains('accompagnement') ? 'side' : 'dessert';
                      final typeBackend = typeLabel.toLowerCase().contains('entrée') ? 'entree' : 
                                       typeLabel.toLowerCase().contains('plat') ? 'plat' :
                                       typeLabel.toLowerCase().contains('accompagnement') ? 'accompagnement' : 'dessert';

                      // Préparer la liste JSON des ingrédients
                      List<Map<String, dynamic>> ingredientsData = [];
                      for(var ctrl in ingredientsControllers) {
                        if (ctrl['nom']!.text.isNotEmpty) {
                          double q = double.tryParse(ctrl['quantite']!.text.replaceAll(',', '.')) ?? 1;
                          double p = double.tryParse(ctrl['prix']!.text.replaceAll(',', '.')) ?? 0;
                          ingredientsData.add({
                            'nom': ctrl['nom']!.text,
                            'quantite': q,
                            'prix': p
                          });
                        }
                      }

                      // Préparer les Maps pour régimes et textures
                      Map<String, double> regimesMap = {};
                      regimeControllers.forEach((key, ctrl) {
                        double val = double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0;
                        if (val > 0) regimesMap[key] = val;
                      });

                      Map<String, double> texturesMap = {};
                      textureControllers.forEach((key, ctrl) {
                        double val = double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0;
                        if (val > 0) texturesMap[key] = val;
                      });

                      final newRecipe = await RecipeService().createRecipe({
                        'nom': nameController.text,
                        'type': typeBackend,
                        'description': descController.text,
                        'ingredients': ingredientsData,
                        'temps_preparation': timeController.text,
                        'regimes': regimesMap,
                        'textures': texturesMap,
                      });
                      
                      setState(() {
                        if (!_selectedRecipes[typeKey]!.any((r) => r.id == newRecipe.id)) {
                          _selectedRecipes[typeKey]!.add(newRecipe);
                        }
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      setModalState(() => isSaving = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: isSaving ? const CircularProgressIndicator(color: Colors.white) : Text('Créer et associer', style: getSourceSerifProStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalField(String label, TextEditingController controller, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: getSourceSerifProStyle(fontSize: 13.sp, color: Colors.black87, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: _primaryPurple)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildSummaryCard(),
                        SizedBox(height: 10.h),
                         _buildInfoCard(
                           title: 'Structure',
                           icon: Icons.apartment_rounded,
                           children: [
                             _buildStructureSelector(),
                           ],
                         ),
                        SizedBox(height: 24.h),
                        _buildInfoCard(
                          title: 'Résidents',
                          icon: Icons.people_outline,
                          children: [
                            _buildEditableTextField(_residentsController, 'Nombre de résidents par jour', Icons.people_outline, keyboardType: TextInputType.number),
                            SizedBox(height: 16.h),
                            Text('Répartition par texture :', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(child: _buildSmallNumberField(_hachesController, 'HACHÉS')),
                                SizedBox(width: 8.w),
                                Expanded(child: _buildSmallNumberField(_mixesController, 'MIXÉS')),
                                SizedBox(width: 8.w),
                                Expanded(child: _buildSmallNumberField(_moulinesController, 'MOULINÉS')),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        _buildInfoCard(
                          title: 'Types de repas',
                          icon: Icons.restaurant_menu_rounded,
                          children: [
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: ['breakfast', 'lunch', 'snack', 'dinner'].map((mealStr) {
                                final isSelected = _selectedMeals.contains(mealStr);
                                String lbl = mealStr == 'breakfast' ? 'Petit Déjeuner' : mealStr == 'lunch' ? 'Déjeuner' : mealStr == 'snack' ? 'Goûter' : 'Dîner';
                                return FilterChip(
                                  label: Text(lbl, style: getSourceSerifProStyle(fontSize: 12.sp, color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    setState(() {
                                      if (val) {
                                        _selectedMeals.add(mealStr);
                                        _initMenuControllers(mealStr);
                                      } else {
                                        _selectedMeals.remove(mealStr);
                                        _menuControllers.remove(mealStr);
                                      }
                                    });
                                  },
                                  selectedColor: _primaryPurple,
                                  checkmarkColor: Colors.white,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[200]!)),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 16.h),
                            ..._selectedMeals.map((meal) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _buildMealMenuSection(meal),
                            )).toList(),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        _buildInfoCard(
                          title: 'Régimes spéciaux',
                          icon: Icons.health_and_safety_outlined,
                          children: [
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: {
                                'standard': 'Standard',
                                'textures': 'Textures modifiées',
                                'no_salt': 'Sans sel',
                                'diabetic': 'Diabétique',
                                'vegetarian': 'Végétarien',
                                'vegan': 'Végétalien',
                                'gluten_free': 'Sans gluten',
                                'light': 'Léger'
                              }.entries.map((entry) {
                                final dietKey = entry.key;
                                final dietLabel = entry.value;
                                final isSelected = _selectedDiets.contains(dietKey);
                                return FilterChip(
                                  label: Text(dietLabel, style: getSourceSerifProStyle(fontSize: 12.sp, color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    setState(() {
                                      if (val) _selectedDiets.add(dietKey);
                                      else _selectedDiets.remove(dietKey);
                                    });
                                  },
                                  selectedColor: _primaryPurple,
                                  checkmarkColor: Colors.white,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[200]!)),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        _buildInfoCard(
                          title: 'Planning horaire',
                          icon: Icons.event_note_rounded,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateTimePicker(
                                    icon: Icons.calendar_today_rounded,
                                    isFilled: _selectedDate != null,
                                    label: _selectedDate == null ? 'Date début' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                    onTap: () async {
                                      final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now().add(const Duration(days: 365)));
                                      if (date != null) setState(() { 
                                        _selectedDate = date;
                                        if (_selectedEndDate == null) _selectedEndDate = date;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildDateTimePicker(
                                    icon: Icons.calendar_today_rounded,
                                    isFilled: _selectedEndDate != null,
                                    label: _selectedEndDate == null ? 'Date fin' : DateFormat('dd/MM/yyyy').format(_selectedEndDate!),
                                    onTap: () async {
                                      final date = await showDatePicker(context: context, initialDate: _selectedEndDate ?? _selectedDate ?? DateTime.now(), firstDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now().add(const Duration(days: 365)));
                                      if (date != null) setState(() => _selectedEndDate = date);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateTimePicker(
                                    icon: Icons.access_time_rounded,
                                    isFilled: _selectedTime != null,
                                    label: _selectedTime == null ? 'Arrivée' : _selectedTime!.format(context),
                                    onTap: () async {
                                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                      if (time != null) setState(() => _selectedTime = time);
                                    },
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildDateTimePicker(
                                    icon: Icons.access_time_rounded,
                                    isFilled: _selectedEndTime != null,
                                    label: _selectedEndTime == null ? 'Clôture' : _selectedEndTime!.format(context),
                                    onTap: () async {
                                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                      if (time != null) setState(() => _selectedEndTime = time);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        _buildInfoCard(
                          title: 'Accès & Logistique',
                          icon: Icons.vpn_key_outlined,
                          children: [
                            _buildEditableTextField(_entryCodeController, "Code d'entrée", Icons.key_outlined),
                            SizedBox(height: 16.h),
                            _buildEditableTextField(_kitchenCodeController, 'Code cuisine', Icons.lock_outline_rounded),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        _buildInfoCard(
                          title: 'Besoins en personnel',
                          icon: Icons.person_add_alt_1_outlined,
                          children: [
                            _buildEditableTextField(_chefsController, 'Nombre de chefs requis', Icons.person_add_alt_1_outlined, keyboardType: TextInputType.number),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        _buildInfoCard(
                          title: 'Notes & Instructions',
                          icon: Icons.description_outlined,
                          children: [
                            _buildLargeTextField(_commentsController, 'Ajouter des précisions...'),
                          ],
                        ),
                        SizedBox(height: 40.h),
                        _buildSubmitButton(),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isSuccess)
            Container(
              color: Colors.black26,
              child: Center(
                child: PetalSuccessAnimation(
                  onComplete: () => Navigator.pop(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: _primaryPurple,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 20.h),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                Expanded(
                  child: Text(
                    'Créer une mission',
                    textAlign: TextAlign.center,
                    style: getSourceSerifProStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(width: 48.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryPurple, _primaryPurple.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              Icons.calendar_month_outlined, 
              _selectedDate != null ? DateFormat('dd MMM').format(_selectedDate!) : '--',
              'Date'
            ),
            VerticalDivider(color: Colors.white24, thickness: 1, indent: 5, endIndent: 5),
            _buildSummaryItem(
              Icons.people_outline_rounded, 
              _residentsController.text.isEmpty ? '0' : _residentsController.text,
              'Résidents'
            ),
            VerticalDivider(color: Colors.white24, thickness: 1, indent: 5, endIndent: 5),
            _buildSummaryItem(
              Icons.restaurant_outlined, 
              _selectedMeals.length.toString(),
              'Repas'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18.sp),
        SizedBox(height: 4.h),
        Text(value, style: getSourceSerifProStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
        Text(label, style: getSourceSerifProStyle(color: Colors.white60, fontSize: 10.sp)),
      ],
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          SizedBox(height: 2.h),
          Text(
            controller.text, 
            style: TextStyle(fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStructureSelector() {
    return InkWell(
      onTap: _isStructuresLoading ? null : _showStructureSelectionDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Établissement', style: TextStyle(fontSize: 11.sp, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                  SizedBox(height: 2.h),
                  Text(
                    _establishmentController.text.isEmpty ? 'Sélectionner une structure' : _establishmentController.text,
                    style: TextStyle(
                      fontSize: 14.sp, 
                      color: _establishmentController.text.isEmpty ? Colors.grey[400] : Colors.black87, 
                      fontWeight: FontWeight.w600
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (_isStructuresLoading)
              SizedBox(width: 16.w, height: 16.w, child: CircularProgressIndicator(strokeWidth: 2, color: _primaryPurple))
            else
              Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _showStructureSelectionDialog() {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredStructures = _structures.where((s) {
            final name = (s.nomEtablissement ?? '').toLowerCase();
            final city = (s.ville ?? '').toLowerCase();
            final query = searchQuery.toLowerCase();
            return name.contains(query) || city.contains(query);
          }).toList();

          return Container(
            height: 0.7.sh,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                  child: Text('Choisir une structure', style: getSourceSerifProStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: TextField(
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom ou ville...',
                      prefixIcon: Icon(Icons.search, color: _primaryPurple),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredStructures.isEmpty 
                    ? Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Text('Aucune structure trouvée', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                      ))
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: filteredStructures.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100]),
                        itemBuilder: (context, index) {
                          final structure = filteredStructures[index];
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                            leading: CircleAvatar(
                              backgroundColor: _primaryPurple.withOpacity(0.1),
                              child: Icon(Icons.business, color: _primaryPurple, size: 20.sp),
                            ),
                            title: Text(structure.nomEtablissement ?? 'Sans nom', style: getSourceSerifProStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                            subtitle: Text('${structure.typeEtablissement ?? ''} • ${structure.ville ?? ''}', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                            onTap: () {
                              _onStructureSelected(structure);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _onStructureSelected(User structure) {
    setState(() {
      _selectedStructure = structure;
      _establishmentController.text = structure.nomEtablissement ?? '';
      _addressController.text = structure.adresse ?? '';
      
      // Optionnel: On peut aussi pré-remplir la capacité si c'est pertinent
      if (structure.capacite != null && structure.capacite!.isNotEmpty) {
        _residentsController.text = structure.capacite!;
      }
    });
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [_primaryPurple, const Color(0xFF6A26C0)]),
        boxShadow: [BoxShadow(color: _primaryPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreateMission,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('CRÉER LA MISSION', style: getSourceSerifProStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2)),
      ),
    );
  }

  Future<void> _handleCreateMission() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // Collecter tous les IDs de recettes
      List<int> recipeIds = [];
      _selectedRecipes.forEach((key, list) {
        for (var recipe in list) {
          recipeIds.add(recipe.id);
        }
      });

      // Agrégation des repas pour le format relationnel
      final List<Map<String, dynamic>> repasData = [];
      for (var meal in _selectedMeals) {
        if (_menuControllers.containsKey(meal)) {
          final ctrls = _menuControllers[meal]!;
          if (meal == 'breakfast' || meal == 'snack') {
            repasData.add({
              'type_repas': meal,
              'description_simple': ctrls['plat']!.text,
              'simple_recette_ids': _selectedRecipes['dish']!.map((r) => r.id).toList(),
            });
          } else {
            repasData.add({
              'type_repas': meal,
              'entree': ctrls['entree']!.text,
              'plat': ctrls['plat']!.text,
              'accompagnement': ctrls['accompagnement']!.text,
              'dessert': ctrls['dessert']!.text,
              'entree_recette_ids': _selectedRecipes['starter']!.map((r) => r.id).toList(),
              'plat_recette_ids': _selectedRecipes['dish']!.map((r) => r.id).toList(),
              'accompagnement_recette_ids': _selectedRecipes['side']!.map((r) => r.id).toList(),
              'dessert_recette_ids': _selectedRecipes['dessert']!.map((r) => r.id).toList(),
            });
          }
        }
      }

      final Map<String, dynamic> createData = {
        'structure_id': _selectedStructure?.id != null ? int.tryParse(_selectedStructure!.id.toString()) : null,
        'establishment': _establishmentController.text,
        'address': _addressController.text,
        'nb_residents_jour': int.tryParse(_residentsController.text) ?? 0,
        'types_repas': _selectedMeals,
        'regimes_speciaux': _selectedDiets,
        'repas': repasData,
        'nb_chefs': int.tryParse(_chefsController.text) ?? 1,
        'commentaires': _commentsController.text,
        'commentaires_admin': _commentsController.text,
        'code_entree': _entryCodeController.text,
        'code_cuisine': _kitchenCodeController.text,
        'nb_regimes_haches': int.tryParse(_hachesController.text) ?? 0,
        'nb_regimes_mixes': int.tryParse(_mixesController.text) ?? 0,
        'nb_regimes_moulines': int.tryParse(_moulinesController.text) ?? 0,
        'recettes_ids': recipeIds,
        'status': 'En cours',
      };

      if (_selectedDate != null && _selectedTime != null) {
        final dateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
        final timeStr = "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";
        createData['date_mission'] = dateStr;
        createData['heure_mission'] = timeStr;
      }

      if (_selectedEndDate != null) {
        final dateFinStr = "${_selectedEndDate!.year}-${_selectedEndDate!.month.toString().padLeft(2, '0')}-${_selectedEndDate!.day.toString().padLeft(2, '0')}";
        createData['date_fin'] = dateFinStr;
      }

      if (_selectedEndTime != null) {
        createData['heure_fin'] = "${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}";
      }

      final missionProvider = Provider.of<MissionProvider>(context, listen: false);
      final newMission = await missionProvider.createMission(createData);

      if (newMission != null) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        if (widget.onMissionCreated != null) {
          widget.onMissionCreated!({
            ...createData,
            'id': newMission.id,
          });
        }
      } else {
        throw Exception(missionProvider.error ?? 'Erreur lors de la création');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }
}

// ─── Widget dédié au bottom sheet de recherche de recette ───────────────────
class _RecipeSearchSheet extends StatefulWidget {
  final String type;
  final String recipeType;
  final LanguageProvider lang;
  final Color primaryPurple;
  final List<RecipeModel> initialSelectedRecipes;
  final void Function(List<RecipeModel> selectedRecipes) onRecipesSelected;
  final VoidCallback onClear;

  const _RecipeSearchSheet({
    required this.type,
    required this.recipeType,
    required this.lang,
    required this.primaryPurple,
    required this.initialSelectedRecipes,
    required this.onRecipesSelected,
    required this.onClear,
  });

  @override
  _RecipeSearchSheetState createState() => _RecipeSearchSheetState();
}

class _RecipeSearchSheetState extends State<_RecipeSearchSheet> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final List<RecipeModel> _localSelectedRecipes = [];

  @override
  void initState() {
    super.initState();
    _localSelectedRecipes.addAll(widget.initialSelectedRecipes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      Provider.of<RecipeProvider>(context, listen: false).fetchRecipes(
        type: widget.recipeType.isNotEmpty ? widget.recipeType : null,
        search: value.isEmpty ? null : value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipes = recipeProvider.recipes;
    // En mode suggestions (pas de recherche), on affiche max 4 résultats
    final displayRecipes = _searchQuery.isEmpty ? recipes.take(4).toList() : recipes;

    // Déterminer le titre localisé de la catégorie (ex: 'Plat', 'Dessert')
    String titleValue = '';
    if (widget.type == 'starter') titleValue = 'Entrée';
    if (widget.type == 'dish') titleValue = 'Plat';
    if (widget.type == 'side') titleValue = 'Accompagnement';
    if (widget.type == 'dessert') titleValue = 'Dessert';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // ── En-tête ──
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 15.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titleValue.toUpperCase(),
                        style: TextStyle(color: widget.primaryPurple, fontWeight: FontWeight.bold, fontSize: 12.sp, letterSpacing: 1.2),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: "Mots-clés (ex: Poulet, Riz...)",
                    prefixIcon: Icon(Icons.search, color: widget.primaryPurple),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[100],
                    suffixIcon: recipeProvider.isLoading
                        ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                        : (_searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 20.sp),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                })
                            : null),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ],
            ),
          ),

          // ── Corps : suggestions ou résultats ──
          Expanded(
            child: recipeProvider.isLoading && recipes.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : displayRecipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu, size: 60.sp, color: Colors.grey[200]),
                            SizedBox(height: 15.h),
                            Text(
                              _searchQuery.isEmpty
                                  ? "Aucune recette disponible\npour cette catégorie."
                                  : "Aucun résultat pour \"$_searchQuery\"",
                              textAlign: TextAlign.center,
                              style: getSourceSerifProStyle(color: Colors.grey[400], fontSize: 16.sp),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
                            child: Text(
                              _searchQuery.isEmpty
                                  ? "Suggestions pour $titleValue"
                                  : "${displayRecipes.length} résultat(s)",
                              style: getSourceSerifProStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: widget.primaryPurple),
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                              itemCount: displayRecipes.length,
                              separatorBuilder: (_, __) => Divider(height: 16.h, color: Colors.grey[100]),
                              itemBuilder: (context, index) {
                                final recipe = displayRecipes[index];
                                final isSelected = _localSelectedRecipes.any((r) => r.id == recipe.id);
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(recipe.nom, style: getSourceSerifProStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: isSelected ? widget.primaryPurple : Colors.black87)),
                                  subtitle: recipe.description != null && recipe.description!.isNotEmpty
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 4.h),
                                          child: Text(
                                            recipe.description!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 12.sp, color: isSelected ? widget.primaryPurple.withOpacity(0.7) : Colors.grey[600]),
                                          ),
                                        )
                                      : null,
                                  leading: Container(
                                    width: 40.w,
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      color: isSelected ? widget.primaryPurple.withOpacity(0.1) : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isSelected ? Icons.check_circle : Icons.restaurant,
                                      color: isSelected ? widget.primaryPurple : Colors.grey[400],
                                      size: 20.sp,
                                    ),
                                  ),
                                  trailing: isSelected 
                                    ? Icon(Icons.remove_circle_outline, color: Colors.red[300], size: 22.sp)
                                    : Icon(Icons.add_circle_outline, color: widget.primaryPurple, size: 22.sp),
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _localSelectedRecipes.removeWhere((r) => r.id == recipe.id);
                                      } else {
                                        _localSelectedRecipes.add(recipe);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),

          // ── Bouton Valider / Effacer ──
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      "ANNULER",
                      style: getSourceSerifProStyle(color: Colors.grey[600], fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onRecipesSelected(_localSelectedRecipes);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    child: Text(
                      "Valider (${_localSelectedRecipes.length})".toUpperCase(),
                      style: getSourceSerifProStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
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
}
