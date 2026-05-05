import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/font_helper.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import 'admin_create_recipe_screen.dart';

class AdminRecipesScreen extends StatefulWidget {
  const AdminRecipesScreen({Key? key}) : super(key: key);

  @override
  _AdminRecipesScreenState createState() => _AdminRecipesScreenState();
}

class _AdminRecipesScreenState extends State<AdminRecipesScreen> {
  final Color _primaryPurple = const Color(0xFF7C39D3);
  
  List<RecipeModel> _recipes = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final recipes = await RecipeService().getRecipes();
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors du chargement des recettes";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    // Filter recipes based on search and selected type
    final filteredRecipes = _recipes.where((recipe) {
      final query = _searchQuery.toLowerCase();
      final titleMatch = recipe.nom.toLowerCase().contains(query);
      final descMatch = (recipe.description ?? '').toLowerCase().contains(query);
      
      bool typeMatch = true;
      if (_selectedType != null) {
        typeMatch = recipe.type?.toLowerCase() == _selectedType;
      }
      
      return (titleMatch || descMatch) && typeMatch;
    }).toList();
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            _buildHeader(lang),
            _buildFilters(lang),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                  : filteredRecipes.isEmpty 
                    ? Center(child: Text("Aucune recette trouvée", style: TextStyle(color: Colors.grey[600])))
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
                          return _buildRecipeCard(recipe, lang);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LanguageProvider lang) {
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
                  lang.translate('recipe_management'),
                  textAlign: TextAlign.center,
                  style: getSourceSerifProStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchRecipes,
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminCreateRecipeScreen()),
                  );
                  if (result == true) _fetchRecipes();
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: lang.translate('search'),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14.sp),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.white70, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(LanguageProvider lang) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 12.h),
      color: Colors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterBadge(
              lang.translate('starter') == 'starter' ? 'Entrée' : lang.translate('starter'),
              'entree',
              _selectedType == 'entree',
            ),
            _buildFilterBadge(
              lang.translate('main_course') == 'main_course' ? 'Plat' : lang.translate('main_course'),
              'plat',
              _selectedType == 'plat',
            ),
            _buildFilterBadge(
              lang.translate('side_dish') == 'side_dish' ? 'Accompagnement' : lang.translate('side_dish'),
              'accompagnement',
              _selectedType == 'accompagnement',
            ),
            _buildFilterBadge(
              lang.translate('dessert') == 'dessert' ? 'Dessert' : lang.translate('dessert'),
              'dessert',
              _selectedType == 'dessert',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBadge(String label, String type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedType == type) {
            _selectedType = null;
          } else {
            _selectedType = type;
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? _primaryPurple : Colors.white,
          border: Border.all(color: isSelected ? _primaryPurple : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected 
            ? [BoxShadow(color: _primaryPurple.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
            : null,
        ),
        child: Text(
          label, 
          style: TextStyle(
            fontSize: 11.sp, 
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe, LanguageProvider lang) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.nom,
            style: getSourceSerifProStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          SizedBox(height: 4.h),
          if (recipe.description != null && recipe.description!.isNotEmpty) 
            Text(
              recipe.description!,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(recipe.tempsPreparation ?? '30 min', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              SizedBox(width: 16.w),
              Icon(Icons.restaurant, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(recipe.type ?? 'Non défini', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            ],
          ),
          
          if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.list_alt_rounded, size: 14.sp, color: _primaryPurple),
                SizedBox(width: 6.w),
                Text("Ingrédients:", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            SizedBox(height: 6.h),
            ...recipe.ingredients!.map((ing) => Padding(
              padding: EdgeInsets.only(left: 20.w, bottom: 4.h),
              child: Text(
                "• ${ing['nom']} (${ing['quantite']}) - ${(ing['prix'] ?? 0)}€",
                style: TextStyle(fontSize: 13.sp, color: Colors.black87, height: 1.4),
              ),
            )).toList(),
          ],

          if (recipe.regimes.isNotEmpty || recipe.textures.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text("Régimes & Textures:", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                ...recipe.regimes.entries.map((entry) => _buildDietBadge("${entry.key}${entry.value != 1 ? ' (${entry.value})' : ''}", Colors.green)),
                ...recipe.textures.entries.map((entry) => _buildDietBadge("${entry.key}${entry.value != 1 ? ' (${entry.value})' : ''}", Colors.orange)),
              ]
            ),
          ],
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => AdminCreateRecipeScreen(recipeToEdit: recipe.copyWith(id: 0)))
                );
              }, icon: Icon(Icons.copy, size: 20.sp, color: Colors.grey)),
              IconButton(onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Supprimer la recette'),
                      content: Text('Voulez-vous vraiment supprimer "${recipe.nom}" ?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULER')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await RecipeService().deleteRecipe(recipe.id);
                      _fetchRecipes();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
                    }
                  }
              }, icon: Icon(Icons.delete_outline, size: 20.sp, color: Colors.red[300])),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => AdminCreateRecipeScreen(recipeToEdit: recipe))
                  );
                  if (result == true) _fetchRecipes();
                },
                child: Text(lang.translate('edit'), style: TextStyle(color: _primaryPurple)),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: () => _showRecipeDetails(recipe),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(lang.translate('see')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.nom,
                            style: getSourceSerifProStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: _primaryPurple,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            recipe.type?.toUpperCase() ?? 'RECETTE',
                            style: TextStyle(
                              color: _primaryPurple,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 18.sp, color: Colors.grey[600]),
                        SizedBox(width: 6.w),
                        Text(
                          recipe.tempsPreparation ?? '30 min',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      Text(
                        "Description / Instructions",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        recipe.description!,
                        style: TextStyle(fontSize: 15.sp, color: Colors.black87, height: 1.5),
                      ),
                    ],
                    if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      Text(
                        "Ingrédients",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12.h),
                      ...recipe.ingredients!.map((ing) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 18.sp, color: _primaryPurple),
                            SizedBox(width: 10.w),
                            Expanded(child: Text(ing['nom'] ?? '', style: TextStyle(fontSize: 14.sp))),
                            Text(
                              ing['quantite'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                            ),
                            if (ing['prix'] != null)
                              Text(" (${ing['prix']}€)", style: TextStyle(color: Colors.grey[600], fontSize: 13.sp)),
                          ],
                        ),
                      )).toList(),
                    ],
                    if (recipe.regimes.isNotEmpty || recipe.textures.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      Text(
                        "Régimes & Textures",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          ...recipe.regimes.entries.map((entry) => _buildDietBadge("${entry.key}${entry.value != 1 ? ' (${entry.value})' : ''}", Colors.green)),
                          ...recipe.textures.entries.map((entry) => _buildDietBadge("${entry.key}${entry.value != 1 ? ' (${entry.value})' : ''}", Colors.orange)),
                        ]
                      ),
                    ],
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietBadge(String label, MaterialColor baseColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(color: baseColor.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: baseColor[700], fontSize: 10.sp)),
    );
  }
}
