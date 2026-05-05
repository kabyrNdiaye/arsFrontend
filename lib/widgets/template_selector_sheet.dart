import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/menu_model.dart';
import '../services/menu_service.dart';
import '../utils/font_helper.dart';

/// Bottom sheet de sélection de template avec recherche + pagination
class TemplateSelectorSheet extends StatefulWidget {
  final String mealType;
  final String templateType; // ex: "Déjeuner"
  final Color primaryColor;
  final void Function(MenuModel template) onSelected;

  const TemplateSelectorSheet({
    Key? key,
    required this.mealType,
    required this.templateType,
    required this.primaryColor,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<TemplateSelectorSheet> createState() => _TemplateSelectorSheetState();
}

class _TemplateSelectorSheetState extends State<TemplateSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  final MenuService _menuService = MenuService();

  List<MenuModel> _templates = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load({int page = 1}) async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await _menuService.getMenuTemplatesPaginated(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        page: page,
      );

      // Filtre souple par type de repas
      List<MenuModel> menus = result['menus'] as List<MenuModel>;
      if (widget.templateType.isNotEmpty) {
        menus = menus.where((m) =>
            m.type.toLowerCase().contains(widget.templateType.toLowerCase()) ||
            widget.templateType.toLowerCase().contains(m.type.toLowerCase())).toList();
      }

      setState(() {
        _templates = menus;
        _currentPage = result['current_page'] as int;
        _lastPage = result['last_page'] as int;
        _total = result['total'] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _load(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.restaurant_menu, color: widget.primaryColor, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choisir un template',
                        style: getSourceSerifProStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.templateType,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: widget.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
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
          ),

          // Barre de recherche
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher un template...',
                hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20.sp),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18.sp, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          _load(page: 1);
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.primaryColor, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),

          Divider(height: 1, color: Colors.grey[100]),

          // Contenu
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: widget.primaryColor))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[300], size: 40.sp),
                            SizedBox(height: 8.h),
                            Text('Erreur de chargement', style: TextStyle(color: Colors.grey[600])),
                            TextButton(
                              onPressed: () => _load(page: _currentPage),
                              child: Text('Réessayer', style: TextStyle(color: widget.primaryColor)),
                            ),
                          ],
                        ),
                      )
                    : _templates.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, color: Colors.grey[300], size: 48.sp),
                                SizedBox(height: 12.h),
                                Text(
                                  'Aucun template trouvé',
                                  style: getSourceSerifProStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    'pour "${_searchController.text}"',
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            itemCount: _templates.length,
                            separatorBuilder: (_, __) => SizedBox(height: 8.h),
                            itemBuilder: (context, index) {
                              final template = _templates[index];
                              return _buildTemplateCard(template);
                            },
                          ),
          ),

          // Pagination
          if (!_isLoading && _templates.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[100]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Précédent
                  _buildPageButton(
                    icon: Icons.chevron_left,
                    label: 'Préc.',
                    enabled: _currentPage > 1,
                    onTap: () => _load(page: _currentPage - 1),
                  ),

                  // Info page
                  Text(
                    'Page $_currentPage / $_lastPage  •  $_total résultat${_total > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                  ),

                  // Suivant
                  _buildPageButton(
                    icon: Icons.chevron_right,
                    label: 'Suiv.',
                    enabled: _currentPage < _lastPage,
                    onTap: () => _load(page: _currentPage + 1),
                    iconRight: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(MenuModel template) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        widget.onSelected(template);
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: widget.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.restaurant_menu, color: widget.primaryColor, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.nom,
                    style: getSourceSerifProStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          template.type,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: widget.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${template.recipeIds.length} catégorie${template.recipeIds.length > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool iconRight = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: enabled ? widget.primaryColor.withOpacity(0.08) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: iconRight
              ? [
                  Text(label, style: TextStyle(fontSize: 12.sp, color: enabled ? widget.primaryColor : Colors.grey[400], fontWeight: FontWeight.w600)),
                  SizedBox(width: 2.w),
                  Icon(icon, size: 16.sp, color: enabled ? widget.primaryColor : Colors.grey[400]),
                ]
              : [
                  Icon(icon, size: 16.sp, color: enabled ? widget.primaryColor : Colors.grey[400]),
                  SizedBox(width: 2.w),
                  Text(label, style: TextStyle(fontSize: 12.sp, color: enabled ? widget.primaryColor : Colors.grey[400], fontWeight: FontWeight.w600)),
                ],
        ),
      ),
    );
  }
}
