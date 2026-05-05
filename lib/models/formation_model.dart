class FormationModel {
  final int id;
  final String titre;
  final String typeFormation; // obligatoire, recommandée
  final String? lienFormation;
  final String? videoUrl; // clé YouTube
  final String? duree;
  final String? imageUrl;
  final int? professionnelId;
  final String statutValidation;
  final String? dateLimite;
  final String? createdAt;

  FormationModel({
    required this.id,
    required this.titre,
    required this.typeFormation,
    this.lienFormation,
    this.videoUrl,
    this.duree,
    this.imageUrl,
    this.professionnelId,
    this.statutValidation = 'A compléter',
    this.dateLimite,
    this.createdAt,
  });

  factory FormationModel.fromJson(Map<String, dynamic> json) {
    return FormationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      titre: json['titre'] ?? '',
      typeFormation: json['type_formation'] ?? 'recommandée',
      lienFormation: json['lien_formation']?.toString(),
      videoUrl: json['video_url']?.toString(),
      duree: json['duree']?.toString(),
      imageUrl: json['image_url']?.toString(),
      professionnelId: json['professionnel_id'] is int 
          ? json['professionnel_id'] 
          : int.tryParse(json['professionnel_id']?.toString() ?? ''),
      statutValidation: json['statutValidation'] ?? 'A compléter',
      dateLimite: json['dateLimite']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'type_formation': typeFormation,
      'lien_formation': lienFormation,
      'video_url': videoUrl,
      'duree': duree,
      'image_url': imageUrl,
      'professionnel_id': professionnelId,
      'statutValidation': statutValidation,
      'dateLimite': dateLimite,
    };
  }
}
