import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/menu_model.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import '../../utils/font_helper.dart';

class AdminMenuDetailScreen extends StatefulWidget {
  final MenuModel menu;
  const AdminMenuDetailScreen({Key? key, required this.menu}) : super(key: key);

  @override
  _AdminMenuDetailScreenState createState() => _AdminMenuDetailScreenState();
}

class _AdminMenuDetailScreenState extends State<AdminMenuDetailScreen> {
  final Color _primaryPurple = const Color(0xFF7C39D3);
  bool _isLoading = true;
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
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
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

      widget.menu.recipeIds.forEach((category, ids) {
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
      debugPrint('Error loading recipes: $e');
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
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(),
                        SizedBox(height: 24.h),
                        if (widget.menu.type == 'Déjeuner' || widget.menu.type == 'Dîner') ...[
                          _buildCategoryTitle('Entrées'),
                          _buildRecipeList('entree'),
                          _buildCategoryTitle('Plats'),
                          _buildRecipeList('plat'),
                          _buildCategoryTitle('Accompagnements'),
                          _buildRecipeList('accompagnement'),
                          _buildCategoryTitle('Desserts'),
                          _buildRecipeList('dessert'),
                        ] else ...[
                          _buildCategoryTitle('Propositions'),
                          _buildRecipeList('proposition'),
                        ],
                      ],
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
                  'Détail du menu',
                  textAlign: TextAlign.center,
                  style: getSourceSerifProStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Pour équilibrer l'IconButton de gauche
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.menu.nom, style: getSourceSerifProStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.restaurant, size: 16.sp, color: _primaryPurple),
              SizedBox(width: 8.w),
              Text(widget.menu.type, style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
              const Spacer(),
              _buildStatusBadge(widget.menu.status),
            ],
          ),
          if (widget.menu.description.isNotEmpty) ...[
            Divider(height: 24.h),
            Text(widget.menu.description, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600], height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 24.h),
      child: Text(title, style: getSourceSerifProStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _primaryPurple)),
    );
  }

  Widget _buildRecipeList(String category) {
    final recipes = _selectedRecipes[category] ?? [];
    if (recipes.isEmpty) {
      return Text('Aucune recette sélectionnée', style: TextStyle(fontSize: 13.sp, color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: recipes.map((r) => _buildRecipeItem(r)).toList(),
    );
  }

  Widget _buildRecipeItem(RecipeModel recipe) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.fastfood_outlined, size: 20.sp, color: _primaryPurple.withOpacity(0.7)),
          SizedBox(width: 12.w),
          Expanded(child: Text(recipe.nom, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'Validé') color = Colors.green;
    if (status == 'Brouillon') color = Colors.orange;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10.sp)),
    );
  }
}
