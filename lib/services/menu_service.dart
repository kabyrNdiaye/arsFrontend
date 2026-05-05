import 'package:flutter/foundation.dart';
import '../models/menu_model.dart';
import 'api_service.dart';

class MenuService {
  final ApiService _api = ApiService();

  // Récupérer tous les templates de menus avec recherche et pagination
  Future<Map<String, dynamic>> getMenuTemplatesPaginated({
    String? search,
    int page = 1,
    int perPage = 5,
  }) async {
    try {
      String endpoint = '/menus?page=$page&per_page=$perPage';
      if (search != null && search.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(search)}';
      }
      final response = await _api.get(endpoint);
      debugPrint('MenuService.getMenuTemplatesPaginated: $response');

      final List<dynamic> data = response['data'] ?? [];
      final List<MenuModel> menus = data.map((m) => MenuModel.fromJson(m)).toList();

      return {
        'menus': menus,
        'total': response['total'] ?? menus.length,
        'current_page': response['current_page'] ?? 1,
        'last_page': response['last_page'] ?? 1,
      };
    } catch (e) {
      debugPrint('Erreur getMenuTemplatesPaginated: $e');
      rethrow;
    }
  }

  // Récupérer tous les templates de menus
  Future<List<MenuModel>> getMenuTemplates() async {
    try {
      final response = await _api.get('/menus');
      debugPrint('MenuService.getMenuTemplates response: $response');
      // Accepter plusieurs formats de réponse
      if (response['success'] == true || response['data'] != null) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((m) => MenuModel.fromJson(m)).toList();
      }
      // Si la réponse est directement une liste
      if (response is List) {
        return (response as List).map((m) => MenuModel.fromJson(m)).toList();
      }
      debugPrint('MenuService: format inattendu: $response');
      return [];
    } catch (e) {
      debugPrint('Erreur lors de la récupération des menus: $e');
      rethrow;
    }
  }

  // Créer ou mettre à jour un template
  Future<void> saveMenuTemplate(MenuModel menu) async {
    try {
      final data = menu.toJson();
      
      if (menu.id == 0) {
        await _api.post('/menus', data);
      } else {
        await _api.put('/menus/${menu.id}', data);
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde du menu: $e');
      rethrow;
    }
  }

  // Supprimer un template
  Future<void> deleteMenuTemplate(int id) async {
    try {
      await _api.delete('/menus/$id');
    } catch (e) {
      print('Erreur lors de la suppression du menu: $e');
      rethrow;
    }
  }
}
