class MenuModel {
  final int id;
  final String nom;
  final String type; // Déjeuner, Dîner, Petit-Déjeuner, Goûter
  final String description;
  final Map<String, List<int>> recipeIds; // slot_name -> list of recipe_ids
  final List<String> diets;
  final String status;
  final String creator;
  final String date;

  MenuModel({
    required this.id,
    required this.nom,
    required this.type,
    this.description = '',
    required this.recipeIds,
    this.diets = const [],
    this.status = 'Brouillon',
    this.creator = 'Admin',
    this.date = '',
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    Map<String, List<int>> recipeIds = {};
    
    if (json['recettes'] != null) {
      for (var r in json['recettes']) {
        if (r['pivot'] != null && r['pivot']['category'] != null) {
          String cat = r['pivot']['category'];
          int id = r['id'];
          recipeIds.putIfAbsent(cat, () => []).add(id);
        }
      }
    } else if (json['recipe_ids'] != null) {
      final rawRecipeIds = json['recipe_ids'] as Map<String, dynamic>;
      rawRecipeIds.forEach((key, value) {
        recipeIds[key] = List<int>.from(value);
      });
    }

    return MenuModel(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      type: json['type'] ?? 'Déjeuner',
      description: json['description'] ?? '',
      recipeIds: recipeIds,
      diets: json['diets'] != null ? List<String>.from(json['diets']) : [],
      status: json['status'] ?? 'Brouillon',
      creator: json['creator'] ?? (json['creator_id'] != null ? 'User ${json['creator_id']}' : 'Admin'),
      date: json['updated_at'] ?? json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'type': type,
      'description': description,
      'recipe_ids': recipeIds,
      'diets': diets,
      'status': status,
      'creator': creator,
      'date': date,
    };
  }
}
