import 'dart:convert';
import 'recipe_model.dart';

class MissionModel {
  final int id;
  final String status;
  final int nbResidentsJour;
  final List<String> typesRepas;
  final List<String> regimesSpeciaux;
  final List<RepasModel> repas;
  final DateTime? horaireMission;
  final DateTime? dateFin;
  final String? heureFin;
  final RegimesSpecifiques regimesSpecifiques;
  final Quantites quantites;
  final String? commentaires;
  final String? adminComments;
  final List<RecipeModel> recipes;
  final bool estCreeParAdmin;
  final DateTime createdAt;
  final int? professionnelId;
  final String? professionnelNom;
  final String? structureName;
  final String? structureAddress;
  final String? structurePhone;
  final int? structureId;
  final Map<String, dynamic>? lastMessage;
  final int unreadMessagesCount;
  final String? userStatus;
  final int nbChefs;
  final String? codeEntree;
  final String? codeCuisine;
  final Map<String, bool>? checklistJournee;

  MissionModel({
    required this.id,
    required this.status,
    required this.nbResidentsJour,
    this.nbChefs = 1,
    required this.typesRepas,
    required this.regimesSpeciaux,
    required this.repas,
    this.horaireMission,
    this.dateFin,
    this.heureFin,
    required this.regimesSpecifiques,
    required this.quantites,
    this.commentaires,
    this.adminComments,
    this.recipes = const [],
    required this.estCreeParAdmin,
    required this.createdAt,
    this.professionnelId,
    this.professionnelNom,
    this.structureName,
    this.structureAddress,
    this.structurePhone,
    this.structureId,
    this.lastMessage,
    this.unreadMessagesCount = 0,
    this.userStatus,
    this.codeEntree,
    this.codeCuisine,
    this.checklistJournee,
  });

  MissionModel copyWith({
    int? unreadMessagesCount,
    Map<String, dynamic>? lastMessage,
    String? status,
    String? codeEntree,
    String? codeCuisine,
    int? nbChefs,
    DateTime? dateFin,
    Map<String, bool>? checklistJournee,
  }) {
    return MissionModel(
      id: id,
      status: status ?? this.status,
      nbResidentsJour: nbResidentsJour,
      nbChefs: nbChefs ?? this.nbChefs,
      typesRepas: typesRepas,
      regimesSpeciaux: regimesSpeciaux,
      repas: repas,
      horaireMission: horaireMission,
      dateFin: dateFin ?? this.dateFin,
      heureFin: heureFin,
      regimesSpecifiques: regimesSpecifiques,
      quantites: quantites,
      commentaires: commentaires,
      adminComments: adminComments,
      recipes: recipes,
      estCreeParAdmin: estCreeParAdmin,
      createdAt: createdAt,
      professionnelId: professionnelId,
      professionnelNom: professionnelNom,
      structureName: structureName,
      structureAddress: structureAddress,
      structurePhone: structurePhone,
      structureId: structureId ?? this.structureId,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
      codeEntree: codeEntree ?? this.codeEntree,
      codeCuisine: codeCuisine ?? this.codeCuisine,
      checklistJournee: checklistJournee ?? this.checklistJournee,
    );
  }

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    // Extraire le nom et l'adresse de la structure depuis la relation
    String? structName;
    String? structAddr;
    String? structPhone;
    int? structId;
    if (json['structure'] != null && json['structure'] is Map) {
      structId = json['structure']['id'] != null ? int.tryParse(json['structure']['id'].toString()) : null;
      structName = json['structure']['nom_etablissement'] ?? json['structure']['name'];
      structPhone = json['structure']['telephone_etablissement'] ?? json['structure']['telephone'] ?? json['structure']['phone'];
      // Construire l'adresse complète depuis la structure
      final adresse = json['structure']['adresse'] ?? '';
      final codePostal = json['structure']['code_postal'] ?? '';
      final ville = json['structure']['ville'] ?? '';
      structAddr = [adresse, codePostal, ville].where((s) => s.toString().isNotEmpty).join(', ');
      if (structAddr.isEmpty) structAddr = null;
    }
    
    // Fallback: chercher le nom/adresse au niveau supérieur du JSON (pour les missions créées par l'admin)
    if (structName == null || structName.isEmpty) {
      structName = json['nom_etablissement']?.toString() ?? json['structure_name']?.toString();
    }
    if (structAddr == null || structAddr.isEmpty) {
      final adresse = json['adresse']?.toString() ?? '';
      final codePostal = json['code_postal']?.toString() ?? '';
      final ville = json['ville']?.toString() ?? '';
      final combined = [adresse, codePostal, ville].where((s) => s.isNotEmpty).join(', ');
      if (combined.isNotEmpty) structAddr = combined;
    }


    // helper local functions for parsing
    List<String> _parseStringList(dynamic data) {
      if (data == null) return [];
      if (data is List) return data.map((e) => e.toString()).toList();
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {
          // fall through
        }
        // maybe comma-separated
        return data.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    List<RepasModel> _parseRepasList(dynamic data) {
      if (data == null) return [];
      if (data is List) {
        return data.map((r) {
          if (r is Map) return RepasModel.fromJson(r as Map<String, dynamic>);
          // if string, attempt decode
          try {
            final m = jsonDecode(r.toString());
            if (m is Map) return RepasModel.fromJson(m.cast<String, dynamic>());
          } catch (_) {}
          return RepasModel(id:0,typeRepas:'',);
        }).toList();
      }
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is List) {
            return decoded.map((r) => RepasModel.fromJson((r as Map).cast<String, dynamic>())).toList();
          }
        } catch (_) {}
      }
      return [];
    }

    return MissionModel(
      id: json['id'] ?? 0,
      status: json['statut'] ?? 'en attente',
      nbResidentsJour: json['nb_residents_jour'] ?? 0,
      typesRepas: _parseStringList(json['types_repas']),
      regimesSpeciaux: _parseStringList(json['regimes_speciaux']),
      repas: _parseRepasList(json['repas']),
      horaireMission: json['horaire_mission'] != null ? DateTime.tryParse(json['horaire_mission'].toString()) : null,
      dateFin: json['date_fin'] != null ? DateTime.tryParse(json['date_fin'].toString()) : null,
      heureFin: json['heure_fin']?.toString(),
      regimesSpecifiques: RegimesSpecifiques.fromJson(json),
      quantites: Quantites.fromJson(json),
      commentaires: json['commentaires']?.toString(),
      adminComments: json['commentaires_admin']?.toString(),
      recipes: (json['recettes'] is List)
          ? (json['recettes'] as List).map((r) => RecipeModel.fromJson(r)).toList()
          : [],
      estCreeParAdmin: json['est_cree_par_admin'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      professionnelId: json['professionnel_id'] != null
          ? int.tryParse(json['professionnel_id'].toString())
          : (json['professionnel'] != null ? json['professionnel']['id'] : null),
      professionnelNom: json['professionnel'] != null ? json['professionnel']['name']?.toString() : null,
      structureName: structName,
      structureAddress: structAddr,
      structurePhone: structPhone,
      structureId: structId ?? (json['structure_id'] != null ? int.tryParse(json['structure_id'].toString()) : null),
      lastMessage: json['last_message'],
      unreadMessagesCount: json['unread_messages_count'] ?? 0,
      userStatus: json['user_status']?.toString(),
      nbChefs: json['nb_chefs'] ?? 1,
      codeEntree: json['code_entree']?.toString(),
      codeCuisine: json['code_cuisine']?.toString(),
      checklistJournee: json['checklist_journee'] != null 
          ? Map<String, bool>.from(json['checklist_journee']) 
          : null,
    );
  }

  // Helper pour obtenir le repas principal à afficher (évite la redondance)
  RepasModel? getMainRepas() {
    if (repas.isEmpty) return null;
    try {
      // Priorité au Déjeuner s'il existe
      return repas.firstWhere(
        (r) => r.typeRepas.toLowerCase().contains('déjeuner') || 
               r.typeRepas.toLowerCase().contains('dejeuner'),
      );
    } catch (_) {
      // Sinon on prend le premier repas disponible
      return repas.first;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'statut': status,
      'nb_residents_jour': nbResidentsJour,
      'nb_chefs': nbChefs,
      'types_repas': typesRepas,
      'regimes_speciaux': regimesSpeciaux,
      'repas': repas.map((r) => r.toJson()).toList(),
      'horaire_mission': horaireMission?.toIso8601String(),
      'date_fin': dateFin?.toIso8601String(),
      'heure_fin': heureFin,
      'nb_regimes_haches': regimesSpecifiques.haches,
      'nb_regimes_mixes': regimesSpecifiques.mixes,
      'nb_regimes_moulines': regimesSpecifiques.moulines,
      'quantite_viande': quantites.viande,
      'quantite_riz': quantites.riz,
      'quantite_legumes': quantites.legumes,
      'commentaires': commentaires,
      'commentaires_admin': adminComments,
      'est_cree_par_admin': estCreeParAdmin,
      'created_at': createdAt.toIso8601String(),
      'code_entree': codeEntree,
      'code_cuisine': codeCuisine,
      'checklist_journee': checklistJournee,
    };
  }
}

class RepasModel {
  final int id;
  final String typeRepas;
  final String? entree;
  final String? plat;
  final String? accompagnement;
  final String? dessert;
  final String? descriptionSimple;
  
  // Single selection (legacy)
  final RecipeModel? entreeRecette;
  final RecipeModel? platRecette;
  final RecipeModel? accompagnementRecette;
  final RecipeModel? dessertRecette;
  final RecipeModel? simpleRecette;

  // Multiple selection (new collections)
  final List<RecipeModel> entreeRecettes;
  final List<RecipeModel> platRecettes;
  final List<RecipeModel> accompagnementRecettes;
  final List<RecipeModel> dessertRecettes;
  final List<RecipeModel> simpleRecettes;

  RepasModel({
    required this.id,
    required this.typeRepas,
    this.entree,
    this.plat,
    this.accompagnement,
    this.dessert,
    this.descriptionSimple,
    this.entreeRecette,
    this.platRecette,
    this.accompagnementRecette,
    this.dessertRecette,
    this.simpleRecette,
    this.entreeRecettes = const [],
    this.platRecettes = const [],
    this.accompagnementRecettes = const [],
    this.dessertRecettes = const [],
    this.simpleRecettes = const [],
  });

  factory RepasModel.fromJson(Map<String, dynamic> json) {
    List<RecipeModel> _parseRecipes(dynamic data) {
      if (data == null || data is! List) return [];
      return data.map((r) => RecipeModel.fromJson(r)).toList();
    }

    return RepasModel(
      id: json['id'] ?? 0,
      typeRepas: json['type_repas'] ?? '',
      entree: json['entree']?.toString(),
      plat: json['plat']?.toString(),
      accompagnement: json['accompagnement']?.toString(),
      dessert: json['dessert']?.toString(),
      descriptionSimple: json['description_simple']?.toString(),
      
      // Singular fields
      entreeRecette: json['entree_recette'] != null ? RecipeModel.fromJson(json['entree_recette']) : null,
      platRecette: json['plat_recette'] != null ? RecipeModel.fromJson(json['plat_recette']) : null,
      accompagnementRecette: json['accompagnement_recette'] != null ? RecipeModel.fromJson(json['accompagnement_recette']) : null,
      dessertRecette: json['dessert_recette'] != null ? RecipeModel.fromJson(json['dessert_recette']) : null,
      simpleRecette: json['simple_recette'] != null ? RecipeModel.fromJson(json['simple_recette']) : null,

      // Plural fields
      entreeRecettes: _parseRecipes(json['entree_recettes']),
      platRecettes: _parseRecipes(json['plat_recettes']),
      accompagnementRecettes: _parseRecipes(json['accompagnement_recettes']),
      dessertRecettes: _parseRecipes(json['dessert_recettes']),
      simpleRecettes: _parseRecipes(json['simple_recettes']),
    );
  }

  // Helper pour obtenir le nom affiché (soit le texte libre, soit les noms des recettes séparés par des virgules)
  String getDisplayName(String category) {
    List<RecipeModel> list;
    String? fallback;

    switch (category) {
      case 'entree':
        list = entreeRecettes.isNotEmpty ? entreeRecettes : (entreeRecette != null ? [entreeRecette!] : []);
        fallback = entree;
        break;
      case 'plat':
        list = platRecettes.isNotEmpty ? platRecettes : (platRecette != null ? [platRecette!] : []);
        fallback = plat;
        break;
      case 'accompagnement':
      case 'side':
        list = accompagnementRecettes.isNotEmpty ? accompagnementRecettes : (accompagnementRecette != null ? [accompagnementRecette!] : []);
        fallback = accompagnement;
        break;
      case 'dessert':
        list = dessertRecettes.isNotEmpty ? dessertRecettes : (dessertRecette != null ? [dessertRecette!] : []);
        fallback = dessert;
        break;
      case 'simple':
        list = simpleRecettes.isNotEmpty ? simpleRecettes : (simpleRecette != null ? [simpleRecette!] : []);
        fallback = descriptionSimple;
        break;
      default:
        return '';
    }

    if (list.isNotEmpty) {
      return list.map((r) => r.nom).join(', ');
    }
    return fallback ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_repas': typeRepas,
      'entree': entree,
      'plat': plat,
      'accompagnement': accompagnement,
      'dessert': dessert,
      'description_simple': descriptionSimple,
      'entree_recette': entreeRecette?.toJson(),
      'plat_recette': platRecette?.toJson(),
      'accompagnement_recette': accompagnementRecette?.toJson(),
      'dessert_recette': dessertRecette?.toJson(),
      'simple_recette': simpleRecette?.toJson(),
      'entree_recettes': entreeRecettes.map((r) => r.toJson()).toList(),
      'plat_recettes': platRecettes.map((r) => r.toJson()).toList(),
      'accompagnement_recettes': accompagnementRecettes.map((r) => r.toJson()).toList(),
      'dessert_recettes': dessertRecettes.map((r) => r.toJson()).toList(),
      'simple_recettes': simpleRecettes.map((r) => r.toJson()).toList(),
    };
  }
}

class RegimesSpecifiques {
  final int haches;
  final int mixes;
  final int moulines;

  RegimesSpecifiques({this.haches = 0, this.mixes = 0, this.moulines = 0});

  factory RegimesSpecifiques.fromJson(Map<String, dynamic> json) {
    return RegimesSpecifiques(
      haches: json['nb_regimes_haches'] ?? 0,
      mixes: json['nb_regimes_mixes'] ?? 0,
      moulines: json['nb_regimes_moulines'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nb_regimes_haches': haches,
      'nb_regimes_mixes': mixes,
      'nb_regimes_moulines': moulines,
    };
  }
}

class Quantites {
  final double? viande;
  final double? riz;
  final double? legumes;

  Quantites({this.viande, this.riz, this.legumes});

  factory Quantites.fromJson(Map<String, dynamic> json) {
    return Quantites(
      viande: json['quantite_viande'] != null ? double.tryParse(json['quantite_viande'].toString()) : null,
      riz: json['quantite_riz'] != null ? double.tryParse(json['quantite_riz'].toString()) : null,
      legumes: json['quantite_legumes'] != null ? double.tryParse(json['quantite_legumes'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantite_viande': viande,
      'quantite_riz': riz,
      'quantite_legumes': legumes,
    };
  }
}
