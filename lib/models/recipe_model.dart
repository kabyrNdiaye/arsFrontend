import 'dart:convert';

class RecipeModel {
  final int id;
  final String nom;
  final String? type;
  final String? description;
  final List<Map<String, dynamic>>? ingredients;
  final String? tempsPreparation;
  final int? menuId;
  final Map<String, dynamic> regimes;
  final Map<String, dynamic> textures;
  final List<String> mealTypes;
  final int nbRegimesHaches;
  final int nbRegimesMixes;
  final int nbRegimesMoulines;

  RecipeModel({
    required this.id,
    required this.nom,
    this.type,
    this.description,
    this.ingredients,
    this.tempsPreparation,
    this.menuId,
    this.regimes = const {},
    this.textures = const {},
    this.mealTypes = const [],
    this.nbRegimesHaches = 0,
    this.nbRegimesMixes = 0,
    this.nbRegimesMoulines = 0,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      type: json['type']?.toString(),
      description: json['description']?.toString(),
      ingredients: json['ingredients'] != null 
          ? (json['ingredients'] as List).map((i) => {
              'nom': i['nom']?.toString() ?? '',
              'quantite': i['quantite']?.toString() ?? '',
              'prix': i['prix'] != null ? (double.tryParse(i['prix'].toString()) ?? 0.0) : 0.0,
            }).toList()
          : null,
      tempsPreparation: json['temps_preparation']?.toString(),
      menuId: json['menu_id'],
      regimes: _parseMapOrList(json['regimes']),
      textures: _parseMapOrList(json['textures']),
      mealTypes: _parseStringList(json['meal_types']),
      nbRegimesHaches: json['nb_regimes_haches'] ?? 0,
      nbRegimesMixes: json['nb_regimes_mixes'] ?? 0,
      nbRegimesMoulines: json['nb_regimes_moulines'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'type': type,
      'description': description,
      'ingredients': ingredients,
      'temps_preparation': tempsPreparation,
      'menu_id': menuId,
      'regimes': regimes,
      'textures': textures,
      'meal_types': mealTypes,
      'nb_regimes_haches': nbRegimesHaches,
      'nb_regimes_mixes': nbRegimesMixes,
      'nb_regimes_moulines': nbRegimesMoulines,
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map<String>((e) => e.toString()).toList();
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map<String>((e) => e.toString()).toList();
        }
      } catch (_) {}
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  static Map<String, dynamic> _parseMapOrList(dynamic data) {
    if (data == null) return {};
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List) {
      Map<String, dynamic> map = {};
      for (var item in data) {
        if (item != null) map[item.toString()] = 1;
      }
      return map;
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return _parseMapOrList(decoded);
      } catch (_) {}
    }
    return {};
  }

  RecipeModel copyWith({
    int? id,
    String? nom,
    String? type,
    String? description,
    List<Map<String, dynamic>>? ingredients,
    String? tempsPreparation,
    int? menuId,
    Map<String, dynamic>? regimes,
    Map<String, dynamic>? textures,
    List<String>? mealTypes,
    int? nbRegimesHaches,
    int? nbRegimesMixes,
    int? nbRegimesMoulines,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      tempsPreparation: tempsPreparation ?? this.tempsPreparation,
      menuId: menuId ?? this.menuId,
      regimes: regimes ?? this.regimes,
      textures: textures ?? this.textures,
      mealTypes: mealTypes ?? this.mealTypes,
      nbRegimesHaches: nbRegimesHaches ?? this.nbRegimesHaches,
      nbRegimesMixes: nbRegimesMixes ?? this.nbRegimesMixes,
      nbRegimesMoulines: nbRegimesMoulines ?? this.nbRegimesMoulines,
    );
  }
}
