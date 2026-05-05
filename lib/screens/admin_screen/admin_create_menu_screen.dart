import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/font_helper.dart';
import '../../models/menu_model.dart';
import '../../models/recipe_model.dart';
import '../../services/menu_service.dart';
import '../../services/recipe_service.dart';

class AdminCreateMenuScreen extends StatefulWidget {
  final MenuModel? menuToEdit;
  const AdminCreateMenuScreen({Key? key, this.menuToEdit}) : super(key: key);

  @override
  _AdminCreateMenuScreenState createState() => _AdminCreateMenuScreenState();
}

class _AdminCreateMenuScreenState extends State<AdminCreateMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryPurple = const Color(0xFF7C39D3);
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  
  String _selectedType = 'Déjeuner';
  final List<String> _menuTypes = ['Petit-Déjeuner', 'Déjeuner', 'Goûter', 'Dîner'];
  
  // Selection of recipes per category
  Map<String, List<RecipeModel>> _selectedRecipes = {
    'entree': [],
    'plat': [],
    'accompagnement': [],
    'dessert': [],
    'proposition': [],
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menuToEdit?.nom ?? '');
    _descriptionController = TextEditingController(text: widget.menuToEdit?.description ?? '');
    
    if (widget.menuToEdit != null) {
      _selectedType = widget.menuToEdit!.type;
      _loadExistingRecipes();
    }
  }

  Future<void> _loadExistingRecipes() async {
    setState(() => _isLoading = true);
    try {
      final allRecipes = await RecipeService().getRecipes();
      
      Map<String, List<RecipeModel>> loadedRecipes = {
        'entree': [],
        'plat': [],
        'accompagnement': [],
        'dessert': [],
        'proposition': [],
      };

      widget.menuToEdit!.recipeIds.forEach((category, ids) {
        final categoryRecipes = allRecipes.where((r) => ids.contains(r.id)).toList();
        if (loadedRecipes.containsKey(category)) {
          loadedRecipes[category] = categoryRecipes;
        }
      });

      setState(() {
        _selectedRecipes = loadedRecipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading existing recipes: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openRecipePicker(String category) async {
    List<RecipeModel> allRecipes = await RecipeService().getRecipes();
    
    // Filtrer par catégorie si ce n'est pas une "proposition" générique
    List<RecipeModel> recipes = allRecipes;
    if (category != 'proposition') {
      recipes = allRecipes.where((r) => r.type?.toLowerCase() == category.toLowerCase()).toList();
    }
    
    final result = await showModalBottomSheet<RecipeModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Text('Sélectionner une recette ($category)', style: getSourceSerifProStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final r = recipes[index];
                    return ListTile(
                      title: Text(r.nom),
                      subtitle: Text(r.type ?? ''),
                      onTap: () => Navigator.pop(context, r),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedRecipes[category]!.add(result);
      });
    }
  }

  Future<void> _saveMenu() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final recipeIds = _selectedRecipes.map((k, v) => MapEntry(k, v.map((r) => r.id).toList()));
    
    final menu = MenuModel(
      id: widget.menuToEdit?.id ?? 0,
      nom: _nameController.text,
      type: _selectedType,
      description: _descriptionController.text,
      recipeIds: recipeIds,
      status: 'Validé',
      date: DateTime.now().toString(),
    );

    try {
      await MenuService().saveMenuTemplate(menu);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
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
                      _buildTextField(_nameController, 'Nom du menu template', Icons.title, validator: (v) => v!.isEmpty ? 'Requis' : null),
                      SizedBox(height: 12.h),
                      _buildDropdownField(),
                      SizedBox(height: 24.h),
                      if (_selectedType == 'Déjeuner' || _selectedType == 'Dîner') ...[
                        _buildCategorySection('Entrées', 'entree'),
                        _buildCategorySection('Plats', 'plat'),
                        _buildCategorySection('Accompagnements', 'accompagnement'),
                        _buildCategorySection('Desserts', 'dessert'),
                      ] else ...[
                        _buildCategorySection('Proposition', 'proposition'),
                      ],
                      SizedBox(height: 40.h),
                    ],
                  ),
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
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.menuToEdit != null ? 'Modifier le menu' : 'Nouveau menu template',
                  textAlign: TextAlign.center,
                  style: getSourceSerifProStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                )
              else
                TextButton(
                  onPressed: _saveMenu,
                  child: const Text('ENREGISTRER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20.sp),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          items: _menuTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
          onChanged: (val) => setState(() => _selectedType = val!),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, String category) {
    final recipes = _selectedRecipes[category]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: getSourceSerifProStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _primaryPurple)),
            IconButton(onPressed: () => _openRecipePicker(category), icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
          ],
        ),
        if (recipes.isEmpty)
          Padding(padding: EdgeInsets.only(left: 8.w, bottom: 8.h), child: Text('Aucune recette sélectionnée', style: TextStyle(fontSize: 12.sp, color: Colors.grey[400])))
        else
          ...recipes.asMap().entries.map((entry) => ListTile(
            title: Text(entry.value.nom, style: TextStyle(fontSize: 13.sp)),
            trailing: IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.red), onPressed: () => setState(() => recipes.removeAt(entry.key))),
          )).toList(),
        const Divider(),
      ],
    );
  }
}
