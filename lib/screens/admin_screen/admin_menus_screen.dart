import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/font_helper.dart';
import '../../services/menu_service.dart';
import '../../models/menu_model.dart';
import 'admin_create_menu_screen.dart';
import 'admin_menu_detail_screen.dart';

class AdminMenusScreen extends StatefulWidget {
  const AdminMenusScreen({Key? key}) : super(key: key);

  @override
  _AdminMenusScreenState createState() => _AdminMenusScreenState();
}

class _AdminMenusScreenState extends State<AdminMenusScreen> {
  final Color _primaryPurple = const Color(0xFF7C39D3);
  final MenuService _menuService = MenuService();
  List<MenuModel> _menus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenus();
  }

  Future<void> _fetchMenus() async {
    setState(() => _isLoading = true);
    try {
      final menus = await _menuService.getMenuTemplates();
      setState(() {
        _menus = menus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Erreur menus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
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
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_menus.isEmpty)
              Expanded(child: Center(child: Text(lang.translate('no_menu_yet') == 'no_menu_yet' ? 'Aucun menu enregistré' : lang.translate('no_menu_yet'))))
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _menus.length,
                  itemBuilder: (context, index) {
                    final menu = _menus[index];
                    return _buildMenuCard(menu, lang);
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
          // Trait horizontal standard
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
          // Titre et Action
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  lang.translate('menu_management'),
                  textAlign: TextAlign.center,
                  style: getSourceSerifProStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminCreateMenuScreen()),
                  );
                  if (result == true) _fetchMenus();
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Barre de recherche
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
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


  Widget _buildMenuCard(MenuModel menu, LanguageProvider lang) {
    int recipesCount = menu.recipeIds.values.fold(0, (sum, list) => sum + list.length);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  menu.nom,
                  style: getSourceSerifProStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
              ),
              _buildStatusBadge(menu.status, lang),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.restaurant_menu, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text("$recipesCount recettes", style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              SizedBox(width: 16.w),
              Icon(Icons.person_outline, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(menu.creator, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            ],
          ),
          if (menu.diets.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 6.w,
              children: menu.diets.map((diet) => _buildDietBadge(diet)).toList(),
            ),
          ],
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () async {
                   final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Supprimer le menu'),
                      content: Text('Voulez-vous vraiment supprimer "${menu.nom}" ?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULER')),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true), 
                          child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _menuService.deleteMenuTemplate(menu.id);
                    _fetchMenus();
                  }
                }, 
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20)
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                   final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminCreateMenuScreen(menuToEdit: menu)),
                  );
                  if (result == true) _fetchMenus();
                },
                child: Text(lang.translate('edit'), style: TextStyle(color: _primaryPurple)),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminMenuDetailScreen(menu: menu)),
                  );
                },
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

  Widget _buildStatusBadge(String status, LanguageProvider lang) {
    Color color = Colors.grey;
    if (status == 'Validé') color = Colors.green;
    if (status == 'Brouillon') color = Colors.orange;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10.sp)),
    );
  }

  Widget _buildDietBadge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: Colors.blue[700], fontSize: 10.sp)),
    );
  }
}
