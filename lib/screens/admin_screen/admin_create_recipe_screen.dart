import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/font_helper.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';

class AdminCreateRecipeScreen extends StatefulWidget {
  final RecipeModel? recipeToEdit;
  const AdminCreateRecipeScreen({Key? key, this.recipeToEdit}) : super(key: key);

  @override
  _AdminCreateRecipeScreenState createState() => _AdminCreateRecipeScreenState();
}

class _AdminCreateRecipeScreenState extends State<AdminCreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryPurple = const Color(0xFF7C39D3);
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _timeController;
  late TextEditingController _hachesCountController;
  late TextEditingController _mixesCountController;
  late TextEditingController _moulinesCountController;
  
  String _selectedType = 'plat';
  final Map<String, String> _recipeTypes = {
    'entree': 'Entrée',
    'plat': 'Plat',
    'accompagnement': 'Accompagnement',
    'dessert': 'Dessert',
  };
  
  Map<String, bool> _mealTypes = {
    'breakfast': false,
    'lunch': false,
    'snack': false,
    'dinner': false,
  };
  
  List<Map<String, dynamic>> _ingredients = [];
  Map<String, bool> _regimes = {
    'Standard': true,
    'Sans sel': false,
    'Diabétique': false,
    'Sans porc': false,
    'Végétarien': false,
  };
  Map<String, bool> _textures = {
    'Normal': true,
    'Haché': false,
    'Mixé': false,
    'Mouliné': false,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipeToEdit?.nom ?? '');
    _descriptionController = TextEditingController(text: widget.recipeToEdit?.description ?? '');
    _timeController = TextEditingController(text: widget.recipeToEdit?.tempsPreparation ?? '30 min');
    _hachesCountController = TextEditingController(text: (widget.recipeToEdit?.nbRegimesHaches ?? 0).toString());
    _mixesCountController = TextEditingController(text: (widget.recipeToEdit?.nbRegimesMixes ?? 0).toString());
    _moulinesCountController = TextEditingController(text: (widget.recipeToEdit?.nbRegimesMoulines ?? 0).toString());
    
    if (widget.recipeToEdit != null) {
      final storedType = widget.recipeToEdit!.type?.toLowerCase() ?? '';
      _selectedType = _recipeTypes.containsKey(storedType) ? storedType : 'plat';
      _ingredients = List<Map<String, dynamic>>.from(widget.recipeToEdit!.ingredients ?? []);
      widget.recipeToEdit!.regimes.forEach((key, value) {
        if (_regimes.containsKey(key)) _regimes[key] = true;
      });
      widget.recipeToEdit!.textures.forEach((key, value) {
        if (_textures.containsKey(key)) _textures[key] = true;
      });
      // Load meal types
      for (var mt in widget.recipeToEdit!.mealTypes) {
        if (_mealTypes.containsKey(mt)) _mealTypes[mt] = true;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _hachesCountController.dispose();
    _mixesCountController.dispose();
    _moulinesCountController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add({'nom': '', 'quantite': '', 'prix': 0.0});
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final recipeData = {
      'nom': _nameController.text,
      'type': _selectedType,
      'description': _descriptionController.text,
      'temps_preparation': _timeController.text,
      'ingredients': _ingredients,
      'regimes': _regimes.entries.where((e) => e.value).map((e) => e.key).toList(),
      'textures': _textures.entries.where((e) => e.value).map((e) => e.key).toList(),
      'meal_types': _mealTypes.entries.where((e) => e.value).map((e) => e.key).toList(),
      'nb_regimes_haches': int.tryParse(_hachesCountController.text) ?? 0,
      'nb_regimes_mixes': int.tryParse(_mixesCountController.text) ?? 0,
      'nb_regimes_moulines': int.tryParse(_moulinesCountController.text) ?? 0,
    };

    try {
      if (widget.recipeToEdit != null) {
        await RecipeService().updateRecipe(widget.recipeToEdit!.id, recipeData);
      } else {
        await RecipeService().createRecipe(recipeData);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              _buildSectionTitle('Informations générales'),
              _buildTextField(_nameController, 'Nom de la recette', Icons.restaurant, validator: (v) => v!.isEmpty ? 'Requis' : null),
              SizedBox(height: 12.h),
              _buildDropdownField(),
              SizedBox(height: 12.h),
              _buildTextField(_timeController, 'Temps de préparation', Icons.timer),
              SizedBox(height: 12.h),
              _buildTextField(_descriptionController, 'Description / Instructions', Icons.description, maxLines: 3),
              
              SizedBox(height: 24.h),
              _buildSectionTitle('Ingrédients'),
              ..._ingredients.asMap().entries.map((entry) => _buildIngredientRow(entry.key, entry.value)).toList(),
              SizedBox(height: 8.h),
              OutlinedButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un ingrédient'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryPurple,
                  side: BorderSide(color: _primaryPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              
              SizedBox(height: 24.h),
              _buildSectionTitle('Compatibilité Régimes'),
              _buildCheckboxGrid(_regimes),
              
              SizedBox(height: 24.h),
              _buildSectionTitle('Compatibilité Textures'),
              _buildCheckboxGrid(_textures),
              
              SizedBox(height: 24.h),
              _buildSectionTitle('Types de Repas'),
              _buildMealTypesGrid(_mealTypes, lang),

              SizedBox(height: 24.h),
              _buildSectionTitle('Quantités par Texture'),
              _buildTextureCountsSection(),
              
              SizedBox(height: 40.h),
            ],
          ),
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
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 40.h,
            left: 12.w,
            right: 12.w,
          ),
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                widget.recipeToEdit != null ? 'Modifier la recette' : 'Nouvelle recette',
                textAlign: TextAlign.center,
                style: getSourceSerifProStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else
              TextButton(
                onPressed: _saveRecipe,
                child: const Text('ENREGISTRER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildTextureCountsSection() {
  return Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Column(
      children: [
        _buildCountRow('Haché', _hachesCountController, Icons.restaurant_menu),
        SizedBox(height: 12.h),
        _buildCountRow('Mixé', _mixesCountController, Icons.blender),
        SizedBox(height: 12.h),
        _buildCountRow('Mouliné', _moulinesCountController, Icons.set_meal),
      ],
    ),
  );
}

Widget _buildCountRow(String label, TextEditingController controller, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 20.sp, color: _primaryPurple.withOpacity(0.7)),
      SizedBox(width: 12.w),
      Expanded(child: Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500))),
      Container(
        width: 80.w,
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    ],
  );
}

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: getSourceSerifProStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryPurple),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20.sp),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryPurple)),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          items: _recipeTypes.entries
              .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
              .toList(),
          onChanged: (val) => setState(() => _selectedType = val!),
        ),
      ),
    );
  }

  Widget _buildIngredientRow(int index, Map<String, dynamic> ingredient) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSmallTextField(
                  initialValue: ingredient['nom']?.toString(),
                  hint: 'Nom de l\'ingrédient',
                  onChanged: (val) => ingredient['nom'] = val,
                  icon: Icons.shopping_basket_outlined,
                ),
              ),
              IconButton(
                onPressed: () => _removeIngredient(index),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildSmallTextField(
                  initialValue: ingredient['quantite']?.toString(),
                  hint: 'Quantité (ex: 500g)',
                  onChanged: (val) => ingredient['quantite'] = val,
                  icon: Icons.scale_outlined,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildSmallTextField(
                  initialValue: ingredient['prix']?.toString(),
                  hint: 'Prix (€)',
                  onChanged: (val) => ingredient['prix'] = double.tryParse(val.replaceAll(',', '.')) ?? 0.0,
                  icon: Icons.euro_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTextField({
    required String? initialValue, 
    required String hint, 
    required Function(String) onChanged, 
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 13.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
        prefixIcon: icon != null ? Icon(icon, size: 16.sp, color: Colors.grey[400]) : null,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primaryPurple)),
      ),
    );
  }

  Widget _buildCheckboxGrid(Map<String, bool> items) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.keys.map((key) {
        return FilterChip(
          label: Text(key),
          selected: items[key]!,
          onSelected: (val) => setState(() => items[key] = val),
          selectedColor: _primaryPurple.withOpacity(0.1),
          checkmarkColor: _primaryPurple,
          labelStyle: TextStyle(
            color: items[key]! ? _primaryPurple : Colors.grey[700],
            fontSize: 12.sp,
            fontWeight: items[key]! ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }

  Widget _buildMealTypesGrid(Map<String, bool> items, LanguageProvider lang) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.keys.map((key) {
        final label = lang.translate(key);
        return FilterChip(
          label: Text(label),
          selected: items[key]!,
          onSelected: (val) => setState(() => items[key] = val),
          selectedColor: _primaryPurple.withOpacity(0.1),
          checkmarkColor: _primaryPurple,
          labelStyle: TextStyle(
            color: items[key]! ? _primaryPurple : Colors.grey[700],
            fontSize: 12.sp,
            fontWeight: items[key]! ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }
}
