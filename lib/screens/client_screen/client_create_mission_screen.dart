import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mission_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../models/recipe_model.dart';
import '../../utils/font_helper.dart';
import '../../providers/notification_provider.dart';
import 'dart:async';

class ClientCreateMissionScreen extends StatefulWidget {
  final VoidCallback? onMissionCreated;

  const ClientCreateMissionScreen({Key? key, this.onMissionCreated}) : super(key: key);

  @override
  _ClientCreateMissionScreenState createState() => _ClientCreateMissionScreenState();
}

class _ClientCreateMissionScreenState extends State<ClientCreateMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryGreen = const Color(0xFF4CA054);
  // bool _isSubmitted = false; // Supprimé au profit du reset de formulaire

  // Form data
  final TextEditingController _residentsController = TextEditingController();
  final List<String> _selectedMeals = [];
  final List<String> _selectedDiets = [];
  
  // Storage for selected recipes: {meal_type: {category: [recipe_ids]}}
  final Map<String, Map<String, List<int>>> _selectedRecipeIds = {};
  // Storage for selected recipe names for UI display
  final Map<String, Map<String, List<String>>> _selectedRecipeNames = {};

  DateTime? _selectedDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedTime;
  TimeOfDay? _selectedEndTime;
  final TextEditingController _chefsController = TextEditingController(text: '1');
  final TextEditingController _commentsController = TextEditingController(); 
  final TextEditingController _entryCodeController = TextEditingController(); 
  final TextEditingController _kitchenCodeController = TextEditingController(); 
  
  // Controllers for meal descriptions/manual entry
  final Map<String, Map<String, TextEditingController>> _menuControllers = {}; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false).fetchRecipes();
    });
  }

  @override
  void dispose() {
    _residentsController.dispose();
    _chefsController.dispose();
    _commentsController.dispose(); 
    _entryCodeController.dispose();
    _kitchenCodeController.dispose();
    _menuControllers.forEach((meal, categories) {
      categories.forEach((category, controller) {
        controller.dispose();
      });
    });
    super.dispose();
  }

  void _initMenuData(String mealType) {
    if (!_selectedRecipeIds.containsKey(mealType)) {
      if (mealType == 'breakfast' || mealType == 'snack') {
        _selectedRecipeIds[mealType] = {
          'description_simple': [],
        };
        _selectedRecipeNames[mealType] = {
          'description_simple': [],
        };
      } else {
        _selectedRecipeIds[mealType] = {
          'entree': [],
          'plat': [],
          'accompagnement': [],
          'dessert': [],
        };
        _selectedRecipeNames[mealType] = {
          'entree': [],
          'plat': [],
          'accompagnement': [],
          'dessert': [],
        };
      }
    }
  }

  void _initMenuControllers(String mealType) {
    if (!_menuControllers.containsKey(mealType)) {
      if (mealType == 'breakfast' || mealType == 'snack') {
        _menuControllers[mealType] = {
          'description_simple': TextEditingController(),
        };
      } else {
        _menuControllers[mealType] = {
          'entree': TextEditingController(),
          'plat': TextEditingController(),
          'accompagnement': TextEditingController(),
          'dessert': TextEditingController(),
        };
      }
    }
  }

  void _resetForm() {
    setState(() {
      _residentsController.clear();
      _selectedRecipeIds.forEach((key, map) {
        map.updateAll((k, v) => []);
      });
      _selectedRecipeNames.forEach((key, map) {
        map.updateAll((k, v) => []);
      });
      _chefsController.text = '1';
      _commentsController.clear();
      _entryCodeController.clear();
      _kitchenCodeController.clear();
      _selectedMeals.clear();
      _selectedDiets.clear();
      _selectedDate = null; 
      _selectedEndDate = null;
      _selectedTime = null; 
      _selectedEndTime = null; 
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedEndDate == null || _selectedTime == null) { 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Provider.of<LanguageProvider>(context, listen: false).translate('select_dates')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(Provider.of<LanguageProvider>(context, listen: false).translate('mission_confirm_title')), 
          content: Text(Provider.of<LanguageProvider>(context, listen: false).translate('mission_confirm_text')), 
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Provider.of<LanguageProvider>(context, listen: false).translate('cancel'), style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final missionProvider = Provider.of<MissionProvider>(context, listen: false);
                final lang = Provider.of<LanguageProvider>(context, listen: false);

                if (authProvider.user?.structureId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lang.translate('error_identify_structure'))),
                  );
                  return;
                }

                // Agrégation des repas pour le nouveau format relationnel
                final List<Map<String, dynamic>> repasData = [];
                for (var meal in _selectedMeals) {
                  if (_menuControllers.containsKey(meal)) {
                    final ctrls = _menuControllers[meal]!;
                    final recipeIds = _selectedRecipeIds[meal]!;
                    if (meal == 'breakfast' || meal == 'snack') {
                      repasData.add({
                        'type_repas': meal,
                        'description_simple': ctrls['description_simple']!.text,
                        'simple_recette_ids': recipeIds['description_simple'],
                      });
                    } else {
                      repasData.add({
                        'type_repas': meal,
                        'entree': ctrls['entree']!.text,
                        'plat': ctrls['plat']!.text,
                        'accompagnement': ctrls['accompagnement']!.text,
                        'dessert': ctrls['dessert']!.text,
                        'entree_recette_ids': recipeIds['entree'],
                        'plat_recette_ids': recipeIds['plat'],
                        'accompagnement_recette_ids': recipeIds['accompagnement'],
                        'dessert_recette_ids': recipeIds['dessert'],
                      });
                    }
                  }
                }

                // Préparation des données pour le backend
                final String dateMission = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
                final String dateFin = "${_selectedEndDate!.year}-${_selectedEndDate!.month.toString().padLeft(2, '0')}-${_selectedEndDate!.day.toString().padLeft(2, '0')}";
                final String heureMission = "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";
                final String heureFin = _selectedEndTime != null
                    ? "${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}"
                    : "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

                final missionData = {
                  'structure_id': authProvider.user!.structureId,
                  'nb_residents_jour': int.tryParse(_residentsController.text) ?? 0,
                  'types_repas': _selectedMeals,
                  'regimes_speciaux': _selectedDiets,
                  'repas': repasData,
                  'date_mission': dateMission,
                  'heure_mission': heureMission,
                  'date_fin': dateFin,
                  'heure_fin': heureFin,
                  'nb_chefs': int.tryParse(_chefsController.text) ?? 1,
                  'commentaires': _commentsController.text,
                  'code_entree': _entryCodeController.text,
                  'code_cuisine': _kitchenCodeController.text,
                };

                final newMission = await missionProvider.createMission(missionData);

                if (newMission != null) {
                  _resetForm();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(lang.translate('mission_sent_success')),
                      backgroundColor: Colors.green,
                    ),
                  );
                  missionProvider.fetchMissions();
                  widget.onMissionCreated?.call();
                } else {
                  final errMsg = missionProvider.error ?? '';
                  String displayMsg;
                  if (errMsg.contains('422') || errMsg.contains('validation')) {
                    displayMsg = 'Certaines informations sont incorrectes ou manquantes. Vérifiez le formulaire.';
                  } else if (errMsg.contains('401') || errMsg.contains('403')) {
                    displayMsg = 'Session expirée. Veuillez vous reconnecter.';
                  } else if (errMsg.contains('500')) {
                    displayMsg = 'Une erreur serveur s\'est produite. Réessayez dans quelques instants.';
                  } else if (errMsg.isNotEmpty) {
                    displayMsg = errMsg;
                  } else {
                    displayMsg = 'La mission n\'a pas pu être créée. Vérifiez votre connexion et réessayez.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(displayMsg),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
              child: Text(Provider.of<LanguageProvider>(context, listen: false).translate('confirm'), style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final userName = user?.fullName ?? '';
    final etablissementName = user?.nomEtablissement ?? lang.translate('structure_default');
    final fonction = user?.fonction ?? lang.translate('director');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header identique aux autres onglets
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                child: Column(
                  children: [
                    // Trait horizontal sous la barre de statut
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top > 0
                            ? 8.h
                            : 32.h,
                        bottom: 16.h,
                      ),
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icône structure (maison)
                        Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: _primaryGreen, width: 2),
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Image.asset(
                                'assets/images/icon_structure.png',
                                width: 44.w,
                                height: 44.h,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.home_work_outlined, color: _primaryGreen, size: 28.sp);
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        // Nom établissement + utilisateur + badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                etablissementName,
                                style: getSourceSerifProStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                userName,
                                style: getSourceSerifProStyle(fontSize: 15.sp, color: Colors.white),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6ABF6E),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  fonction,
                                  style: getSourceSerifProStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Cloche notification
                        Consumer2<NotificationProvider, MissionProvider>(
                          builder: (context, notifProvider, missionProvider, child) {
                            final int totalUnread = missionProvider.totalUnreadMessagesCount + missionProvider.newMissionsCount;
                            
                            return GestureDetector(
                              onTap: () {
                                // Navigation désactivée - Indicateur uniquement
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 30.sp,
                                  ),
                                  if (totalUnread > 0)
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child: Container(
                                        width: 20.w,
                                        height: 20.h,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            totalUnread > 9 ? '9+' : totalUnread.toString(),
                                            style: getSourceSerifProStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // 3 cartes stats
                    Consumer<MissionProvider>(
                      builder: (context, missionProvider, child) {
                        final stats = missionProvider.structureStats;
                        return Row(
                          children: [
                            Expanded(child: _buildStatCard('${stats['total_missions'] ?? '--'}', lang.translate('missions'))),
                            SizedBox(width: 12.w),
                            Expanded(child: _buildStatCard('${stats['total_residents'] ?? '--'}', lang.translate('residents'))),
                            SizedBox(width: 12.w),
                            Expanded(child: _buildStatCard('${stats['total_chefs'] ?? '--'}', lang.translate('chefs'))),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Formulaire
        Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: _buildForm(lang),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFF6ABF6E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(value,
              style: getSourceSerifProStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center),
          SizedBox(height: 2.h),
          Text(label,
              style: getSourceSerifProStyle(fontSize: 11.sp, fontWeight: FontWeight.w400, color: Colors.white),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildForm(LanguageProvider lang) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(lang.translate('access_logistics')),
          Row(
            children: [
              Expanded(child: _buildTextFormField(controller: _entryCodeController, hint: lang.translate('entry_code'))),
              SizedBox(width: 10.w),
              Expanded(child: _buildTextFormField(controller: _kitchenCodeController, hint: lang.translate('kitchen_code'))),
            ],
          ),
          SizedBox(height: 25.h),

          _buildSectionTitle(lang.translate('chefs_count')),
          _buildTextFormField(
            controller: _chefsController, 
            hint: lang.translate('chefs_required'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 25.h),

          _buildSectionTitle(lang.translate('avg_residents_day')),
          _buildResidentsField(lang),
          SizedBox(height: 25.h),

          _buildSectionTitle(lang.translate('meal_types')),
          _buildMealTypeGrid(lang),
          SizedBox(height: 15.h),

          // Menu dynamique par type de repas
          ..._selectedMeals.map((mealType) => _buildDynamicMenuSection(mealType, lang)).toList(),
          
          if (_selectedMeals.isNotEmpty) SizedBox(height: 10.h),

          _buildSectionTitle(lang.translate('special_diets')),
          _buildDietList(lang),
          SizedBox(height: 25.h),

          _buildSectionTitle(lang.translate('mission_schedule')),
          // Début
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildDateTimePicker(
                  label: _selectedDate == null ? lang.translate('date') : "${lang.translate('start_label')}: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() {
                         _selectedDate = date;
                         if (_selectedEndDate == null) _selectedEndDate = date;
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 1,
                child: _buildDateTimePicker(
                  label: _selectedTime == null ? lang.translate('schedule_start') ?? lang.translate('start_label') : _selectedTime!.format(context),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null) setState(() => _selectedTime = time);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(height: 10.h),
          // Fin
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildDateTimePicker(
                  label: _selectedEndDate == null ? lang.translate('date_fin') ?? lang.translate('end_label') : "${lang.translate('end_label')}: ${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}",
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: _selectedDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) setState(() => _selectedEndDate = date);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 1,
                child: _buildDateTimePicker(
                  label: _selectedEndTime == null ? lang.translate('schedule_end') ?? lang.translate('end_label') : _selectedEndTime!.format(context),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null) setState(() => _selectedEndTime = time);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),

          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                lang.translate('send_mission').toUpperCase(),
                style: getSourceSerifProStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildDynamicMenuSection(String mealType, LanguageProvider lang) {
    _initMenuData(mealType);
    _initMenuControllers(mealType);
    final controllers = _menuControllers[mealType]!;
    
    String label = mealType;
    if (mealType == 'breakfast') label = lang.translate('breakfast');
    if (mealType == 'lunch') label = lang.translate('lunch');
    if (mealType == 'snack') label = lang.translate('snack');
    if (mealType == 'dinner') label = lang.translate('dinner');

    final isSimple = mealType == 'breakfast' || mealType == 'snack';

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: getSourceSerifProStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: _primaryGreen,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 18.h),
          if (isSimple) ...[
            _buildRecipeDropdown(mealType, 'description_simple', lang.translate('meal_description'), lang),
            SizedBox(height: 12.h),
            _buildTextFormField(
              controller: controllers['description_simple']!, 
              hint: lang.translate('meal_description'),
              maxLines: 3,
            ),
          ] else ...[
            _buildRecipeDropdown(mealType, 'entree', lang.translate('starter_label'), lang),
            SizedBox(height: 8.h),
            _buildTextFormField(controller: controllers['entree']!, hint: lang.translate('starter_label')),
            SizedBox(height: 18.h),
            
            _buildRecipeDropdown(mealType, 'plat', lang.translate('dish_label'), lang),
            SizedBox(height: 8.h),
            _buildTextFormField(controller: controllers['plat']!, hint: lang.translate('dish_label')),
            SizedBox(height: 18.h),

            _buildRecipeDropdown(mealType, 'accompagnement', lang.translate('side_label'), lang),
            SizedBox(height: 8.h),
            _buildTextFormField(controller: controllers['accompagnement']!, hint: lang.translate('side_label')),
            SizedBox(height: 18.h),

            _buildRecipeDropdown(mealType, 'dessert', lang.translate('dessert_label'), lang),
            SizedBox(height: 8.h),
            _buildTextFormField(controller: controllers['dessert']!, hint: lang.translate('dessert_label')),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeDropdown(String mealType, String category, String label, LanguageProvider lang) {
    List<int> selectedIds = _selectedRecipeIds[mealType]?[category] ?? [];
    List<String> selectedNames = _selectedRecipeNames[mealType]?[category] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${lang.translate('recipe_management')} ($label)",
          style: getSourceSerifProStyle(fontSize: 11.sp, color: Colors.grey[600], fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: () => _showRecipeSearchDialog(mealType, category, label, lang),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 20.sp, color: _primaryGreen),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    lang.translate('search_mission_hint'),
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp, 
                      color: Colors.grey[400]
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
        if (selectedNames.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: List.generate(selectedNames.length, (index) {
              return Chip(
                label: Text(
                  selectedNames[index],
                  style: getSourceSerifProStyle(fontSize: 12.sp, color: Colors.white),
                ),
                backgroundColor: _primaryGreen,
                deleteIcon: Icon(Icons.close, size: 14.sp, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    _selectedRecipeIds[mealType]![category]!.removeAt(index);
                    _selectedRecipeNames[mealType]![category]!.removeAt(index);
                  });
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            }),
          ),
        ],
      ],
    );
  }

  void _showRecipeSearchDialog(String mealType, String category, String label, LanguageProvider lang) {
    String recipeType = '';
    if (category == 'entree') recipeType = 'entree';
    if (category == 'plat') recipeType = 'plat';
    if (category == 'accompagnement') recipeType = 'accompagnement';
    if (category == 'dessert') recipeType = 'dessert';

    // Pré-charger les recettes AVANT d'ouvrir le dialog pour éviter le clignotement
    // On charge TOUTES les recettes (sans filtre restrictif) pour afficher des suggestions
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
          mealType: mealType,
          category: category,
          label: label,
          recipeType: recipeType,
          lang: lang,
          primaryGreen: _primaryGreen,
          initialSelectedIds: _selectedRecipeIds[mealType]![category]!,
          onRecipesSelected: (selectedRecipes) {
            setState(() {
              for (var recipe in selectedRecipes) {
                if (!_selectedRecipeIds[mealType]![category]!.contains(recipe.id)) {
                  _selectedRecipeIds[mealType]![category]!.add(recipe.id);
                  _selectedRecipeNames[mealType]![category]!.add(recipe.nom);
                }
              }
            });
          },
          onClear: () {
            setState(() {
              _selectedRecipeIds[mealType]![category] = [];
              _selectedRecipeNames[mealType]![category] = [];
              _menuControllers[mealType]![category]!.clear();
            });
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
      child: Text(
        title,
        style: getSourceSerifProStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: getSourceSerifProStyle(fontSize: 15.sp, color: Colors.black87),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[400]),
        hintText: hint,
        hintStyle: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[300]),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryGreen.withOpacity(0.3), width: 1),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value) {
    final isSelected = _selectedMeals.contains(value);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedMeals.add(value);
            _initMenuControllers(value);
          }
          else _selectedMeals.remove(value);
        });
      },
      selectedColor: _primaryGreen.withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? _primaryGreen : Colors.black87),
    );
  }

  Widget _buildDietList(LanguageProvider lang) {
    return Column(
      children: [
        _buildDietButton(lang.translate('modified_textures'), 'textures'),
        SizedBox(height: 10.h),
        _buildDietButton(lang.translate('no_salt'), 'no_salt'),
        SizedBox(height: 10.h),
        _buildDietButton(lang.translate('diabetic'), 'diabetic'),
        SizedBox(height: 10.h),
        _buildDietButton(lang.translate('gluten_free'), 'gluten_free'),
        SizedBox(height: 10.h),
        _buildDietButton(lang.translate('vegetarian_diet'), 'vegetarian'),
      ],
    );
  }

  Widget _buildDietButton(String label, String value) {
    final isSelected = _selectedDiets.contains(value);
    final Color selectedBlue = const Color(0xFFE3F2FD);
    final Color selectedBorderBlue = const Color(0xFF1976D2);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) _selectedDiets.remove(value);
          else _selectedDiets.add(value);
        });
      },
      child: Stack(
        children: [
          if (!isSelected)
            Container(
              height: 52.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1.0),
              ),
              child: Text(
                label,
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
          if (isSelected)
            Container(
              height: 52.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: selectedBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selectedBorderBlue, width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: selectedBorderBlue,
                    ),
                  ),
                  Icon(
                    Icons.check_circle_outline,
                    color: selectedBorderBlue,
                    size: 22.sp,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: getSourceSerifProStyle(
            fontSize: 13.sp, 
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSmallNumberField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: getSourceSerifProStyle(fontSize: 10.sp, color: Colors.grey[600])),
        SizedBox(height: 4.h),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
        ),
      ],
    );
  }

  // --- Nouveaux Widgets pour la refonte UI ---

  Widget _buildResidentsField(LanguageProvider lang) {
    return TextFormField(
      controller: _residentsController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.left,
      style: getSourceSerifProStyle(fontSize: 16.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: '100',
        hintStyle: getSourceSerifProStyle(fontSize: 16.sp, color: Colors.grey[300]),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryGreen, width: 1),
        ),
      ),
      validator: (v) => null, // Résidents optionnel
    );
  }

  Widget _buildMealTypeGrid(LanguageProvider lang) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMealButton(lang.translate('breakfast'), 'breakfast')),
            SizedBox(width: 12.w),
            Expanded(child: _buildMealButton(lang.translate('lunch'), 'lunch')),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildMealButton(lang.translate('snack'), 'snack')),
            SizedBox(width: 12.w),
            Expanded(child: _buildMealButton(lang.translate('dinner'), 'dinner')),
          ],
        ),
      ],
    );
  }

  Widget _buildMealButton(String label, String value) {
    final isSelected = _selectedMeals.contains(value);
    final Color selectedBlue = const Color(0xFFE3F2FD);
    final Color selectedBorderBlue = const Color(0xFF1976D2);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedMeals.remove(value);
          } else {
            _selectedMeals.add(value);
            _initMenuControllers(value);
          }
        });
      },
      child: Stack(
        children: [
          if (!isSelected)
            Container(
              height: 55.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1.0),
              ),
              child: Text(
                label,
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          if (isSelected)
            Container(
              height: 55.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectedBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selectedBorderBlue, width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: selectedBorderBlue, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: selectedBorderBlue,
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

// ─── Widget dédié au bottom sheet de recherche de recette ───────────────────
class _RecipeSearchSheet extends StatefulWidget {
  final String mealType;
  final String category;
  final String label;
  final String recipeType;
  final LanguageProvider lang;
  final Color primaryGreen;
  final List<int> initialSelectedIds;
  final void Function(List<RecipeModel> selectedRecipes) onRecipesSelected;
  final VoidCallback onClear;

  const _RecipeSearchSheet({
    required this.mealType,
    required this.category,
    required this.label,
    required this.recipeType,
    required this.lang,
    required this.primaryGreen,
    required this.initialSelectedIds,
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
  final List<int> _localSelectedIds = [];

  @override
  void initState() {
    super.initState();
    _localSelectedIds.addAll(widget.initialSelectedIds);
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
    final lang = widget.lang;
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipes = recipeProvider.recipes;
    // En mode suggestions (pas de recherche), on affiche max 4 résultats
    final displayRecipes = _searchQuery.isEmpty
        ? recipes.take(4).toList()
        : recipes;

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
                // Barre drag
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lang.translate(widget.mealType) ?? widget.mealType.toUpperCase(),
                            style: TextStyle(color: widget.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12.sp, letterSpacing: 1.2),
                          ),
                        ],
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
                    hintText: lang.translate('keywords_hint'),
                    prefixIcon: Icon(Icons.search, color: widget.primaryGreen),
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
                                  ? lang.translate('no_recipe_available')
                                  : "${lang.translate('no_result_for')} \"$_searchQuery\"",
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
                                  ? "${lang.translate('suggestions_for')} ${lang.translate(widget.mealType)}"
                                  : "${displayRecipes.length} ${lang.translate('results')}",
                              style: getSourceSerifProStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: widget.primaryGreen),
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                              itemCount: displayRecipes.length,
                              separatorBuilder: (_, __) => Divider(height: 16.h, color: Colors.grey[100]),
                              itemBuilder: (context, index) {
                                final recipe = displayRecipes[index];
                                final isSelected = _localSelectedIds.contains(recipe.id);
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(recipe.nom, style: getSourceSerifProStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: isSelected ? widget.primaryGreen : Colors.black87)),
                                  subtitle: recipe.description != null && recipe.description!.isNotEmpty
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 4.h),
                                          child: Text(
                                            recipe.description!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 12.sp, color: isSelected ? widget.primaryGreen.withOpacity(0.7) : Colors.grey[600]),
                                          ),
                                        )
                                      : null,
                                  leading: Container(
                                    width: 40.w,
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      color: isSelected ? widget.primaryGreen.withOpacity(0.1) : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isSelected ? Icons.check_circle : Icons.restaurant,
                                      color: isSelected ? widget.primaryGreen : Colors.grey[400],
                                      size: 20.sp,
                                    ),
                                  ),
                                  trailing: isSelected 
                                    ? Icon(Icons.remove_circle_outline, color: Colors.red[300], size: 22.sp)
                                    : Icon(Icons.add_circle_outline, color: widget.primaryGreen, size: 22.sp),
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _localSelectedIds.remove(recipe.id);
                                        _localSelectedRecipes.removeWhere((r) => r.id == recipe.id);
                                      } else {
                                        _localSelectedIds.add(recipe.id);
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
                      lang.translate('cancel').toUpperCase(),
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
                      backgroundColor: widget.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    child: Text(
                      "${lang.translate('confirm')} (${_localSelectedIds.length})".toUpperCase(),
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
