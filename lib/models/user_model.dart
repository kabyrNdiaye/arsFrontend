import '../config/api_config.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? address;
  final String? profileImage;
  final String? role;
  final DateTime? createdAt;

  final String? nomEtablissement;
  final String? typeEtablissement;
  final String? capacite;
  final String? fonction;
  final String? codePostal;
  final String? ville;
  final String? telephoneEtablissement;

  final int? structureId;
  final int? professionnelId;
  final String? stripeAccountId;
  final bool? stripeOnboardingComplete;

  final String? contratPrestationPath;
  final String? planLocauxPath;
  final String? reglementInterieurPath;

  final String? fonctionPrincipale;
  final Map<String, dynamic>? currentMission;
  final String? statutValidation;
  final List<String>? specialites;
  final int? anneesExperience;
  final String? dateNaissance;
  final String? photoProfil;
  final String? diplomePath;
  final String? certificatMedical;
  final String? permiConduire;
  final String? contratPrestation;
  final String? planLocaux;
  final String? reglementInterieur;
  final Map<String, String>? rawDocuments;
  final String? telephone;
  final String? adresse;
  final Map<String, dynamic>? stats;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.address,
    this.profileImage,
    this.role,
    this.createdAt,
    this.nomEtablissement,
    this.typeEtablissement,
    this.capacite,
    this.fonction,
    this.codePostal,
    this.ville,
    this.contratPrestationPath,
    this.planLocauxPath,
    this.reglementInterieurPath,
    this.structureId,
    this.professionnelId,
    this.stripeAccountId,
    this.stripeOnboardingComplete,
    this.fonctionPrincipale,
    this.currentMission,
    this.statutValidation,
    this.specialites,
    this.anneesExperience,
    this.dateNaissance,
    this.photoProfil,
    this.diplomePath,
    this.certificatMedical,
    this.permiConduire,
    this.contratPrestation,
    this.planLocaux,
    this.reglementInterieur,
    this.adresse,
    this.telephone,
    this.telephoneEtablissement,
    this.stats,
    this.rawDocuments,
  });

  /// Construit l'URL publique d'un fichier.
  /// Le backend retourne des URLs absolues via /api/media/ — on les utilise telles quelles.
  /// Pour les chemins relatifs, on construit /api/media/...
  static String? sanitizeUrl(dynamic url) {
    if (url == null || url.toString().isEmpty) return null;
    final String s = url.toString().trim();

    // URL absolue → retourner telle quelle (le backend renvoie déjà la bonne URL)
    if (s.startsWith('http://') || s.startsWith('https://')) {
      if (s.contains('onrender.com')) {
        return s.replaceFirst('http://', 'https://');
      }
      return s;
    }

    // Chemin relatif → construire avec /api/media/
    final String base = ApiConfig.baseUrl; // ex: http://127.0.0.1:8000/api

    String clean = s.startsWith('/') ? s.substring(1) : s;

    // Retirer le préfixe storage/ si présent
    if (clean.startsWith('storage/')) {
      clean = clean.replaceFirst('storage/', '');
    }

    return '$base/media/$clean';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['role'] == 'professionnel') {
      debugLog('=== RAW BACKEND VALUES (${json['prenom']}) ===');
      debugLog('diplome_path RAW       : ${json['diplome_path']}');
      debugLog('certificat_medical RAW : ${json['certificat_medical_path']}');
      debugLog('permis_conduire RAW    : ${json['permis_conduire_path']}');
      debugLog('photo_profil RAW       : ${json['photo_profil_path']}');
      debugLog('diplome URL            : ${sanitizeUrl(_firstDocumentValue(json['diplome_path']))}');
      debugLog('certificat URL         : ${sanitizeUrl(_firstDocumentValue(json['certificat_medical_path']))}');
      debugLog('permis URL             : ${sanitizeUrl(_firstDocumentValue(json['permis_conduire_path']))}');
      debugLog('==============================================');
    }

    String firstName = json['prenom'] ?? json['firstName'] ?? '';
    String lastName = json['nom'] ?? json['lastName'] ?? '';

    if (firstName.isEmpty && lastName.isEmpty && json['name'] != null) {
      final nameParts = json['name'].toString().split(' ');
      if (nameParts.isNotEmpty) {
        firstName = nameParts[0];
        lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      }
    }

    final pro = User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: firstName,
      lastName: lastName,
      phone: json['telephone'] ?? json['phone'] ?? '',
      address: json['adresse'] ?? json['address'],
      profileImage: sanitizeUrl(json['photo_profil_path'] ?? json['profileImage']),
      role: json['role'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      nomEtablissement: json['nom_etablissement'],
      typeEtablissement: json['type_etablissement'],
      capacite: json['capacite']?.toString(),
      fonction: json['fonction'],
      codePostal: json['code_postal'],
      ville: json['ville'],
      contratPrestationPath: sanitizeUrl(json['contrat_prestation_path']),
      planLocauxPath: sanitizeUrl(json['plan_locaux_path']),
      reglementInterieurPath: sanitizeUrl(json['reglement_interieur_path']),
      structureId: json['structure_id'] != null ? int.tryParse(json['structure_id'].toString()) : null,
      professionnelId: json['professionnel_id'] != null ? int.tryParse(json['professionnel_id'].toString()) : null,
      stripeAccountId: json['stripe_account_id'],
      stripeOnboardingComplete: json['stripe_onboarding_complete'] == true || json['stripe_onboarding_complete'] == 1 || json['stripe_onboarding_complete'] == '1',
      fonctionPrincipale: json['fonction_principale'],
      currentMission: json['current_mission'],
      statutValidation: json['statut_validation'],
      specialites: json['specialites'] is List ? List<String>.from(json['specialites']) : null,
      anneesExperience: json['annees_experience'] is int
          ? json['annees_experience']
          : int.tryParse(json['annees_experience']?.toString() ?? ''),
      dateNaissance: json['date_naissance'],
      photoProfil: sanitizeUrl(json['photo_profil_path']),
      diplomePath: sanitizeUrl(_firstDocumentValue(json['diplome_path'])),
      certificatMedical: sanitizeUrl(_firstDocumentValue(json['certificat_medical_path'])),
      permiConduire: sanitizeUrl(_firstDocumentValue(json['permis_conduire_path'])),
      contratPrestation: sanitizeUrl(_firstDocumentValue(json['contrat_prestation_path'])),
      planLocaux: sanitizeUrl(_firstDocumentValue(json['plan_locaux_path'])),
      reglementInterieur: sanitizeUrl(_firstDocumentValue(json['reglement_interieur_path'])),
      telephone: json['telephone'] ?? json['phone'],
      adresse: json['adresse'] ?? json['address'],
      telephoneEtablissement: json['telephone_etablissement'],
      stats: json['stats'],
      rawDocuments: _extractAllDocuments(json),
    );

    // Peupler les champs nommés depuis rawDocuments si vides
    final docs = pro.rawDocuments ?? {};
    return pro.copyWith(
      diplomePath: pro.diplomePath ?? _findDoc(docs, ['diplome']),
      certificatMedical: pro.certificatMedical ?? _findDoc(docs, ['medical']),
      permiConduire: pro.permiConduire ?? _findDoc(docs, ['permis']),
      contratPrestation: pro.contratPrestation ?? _findDoc(docs, ['contrat']),
      planLocaux: pro.planLocaux ?? _findDoc(docs, ['plan_locaux']),
      reglementInterieur: pro.reglementInterieur ?? _findDoc(docs, ['reglement']),
    );
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    String? role,
    DateTime? createdAt,
    String? nomEtablissement,
    String? typeEtablissement,
    String? capacite,
    String? fonction,
    String? codePostal,
    String? ville,
    int? structureId,
    int? professionnelId,
    String? stripeAccountId,
    bool? stripeOnboardingComplete,
    String? contratPrestationPath,
    String? planLocauxPath,
    String? reglementInterieurPath,
    String? fonctionPrincipale,
    Map<String, dynamic>? currentMission,
    String? statutValidation,
    List<String>? specialites,
    int? anneesExperience,
    String? dateNaissance,
    String? photoProfil,
    String? diplomePath,
    String? certificatMedical,
    String? permiConduire,
    String? contratPrestation,
    String? planLocaux,
    String? reglementInterieur,
    Map<String, String>? rawDocuments,
    String? telephone,
    String? adresse,
    Map<String, dynamic>? stats,
    String? telephoneEtablissement,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      nomEtablissement: nomEtablissement ?? this.nomEtablissement,
      typeEtablissement: typeEtablissement ?? this.typeEtablissement,
      capacite: capacite ?? this.capacite,
      fonction: fonction ?? this.fonction,
      codePostal: codePostal ?? this.codePostal,
      ville: ville ?? this.ville,
      structureId: structureId ?? this.structureId,
      professionnelId: professionnelId ?? this.professionnelId,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      stripeOnboardingComplete: stripeOnboardingComplete ?? this.stripeOnboardingComplete,
      contratPrestationPath: contratPrestationPath ?? this.contratPrestationPath,
      planLocauxPath: planLocauxPath ?? this.planLocauxPath,
      reglementInterieurPath: reglementInterieurPath ?? this.reglementInterieurPath,
      fonctionPrincipale: fonctionPrincipale ?? this.fonctionPrincipale,
      currentMission: currentMission ?? this.currentMission,
      statutValidation: statutValidation ?? this.statutValidation,
      specialites: specialites ?? this.specialites,
      anneesExperience: anneesExperience ?? this.anneesExperience,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      photoProfil: photoProfil ?? this.photoProfil,
      diplomePath: diplomePath ?? this.diplomePath,
      certificatMedical: certificatMedical ?? this.certificatMedical,
      permiConduire: permiConduire ?? this.permiConduire,
      contratPrestation: contratPrestation ?? this.contratPrestation,
      planLocaux: planLocaux ?? this.planLocaux,
      reglementInterieur: reglementInterieur ?? this.reglementInterieur,
      rawDocuments: rawDocuments ?? this.rawDocuments,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      stats: stats ?? this.stats,
      telephoneEtablissement: telephoneEtablissement ?? this.telephoneEtablissement,
    );
  }

  static String? _findDoc(Map<String, String> docs, List<String> targets) {
    String normalize(String s) {
      return s.toLowerCase()
          .replaceAll('é', 'e').replaceAll('è', 'e').replaceAll('ê', 'e')
          .replaceAll('à', 'a').replaceAll('â', 'a')
          .replaceAll('î', 'i').replaceAll('ï', 'i')
          .replaceAll('ô', 'o').replaceAll('û', 'u')
          .replaceAll('ç', 'c');
    }

    for (var k in docs.keys) {
      final nk = normalize(k);
      for (var t in targets) {
        if (nk.contains(normalize(t))) return docs[k];
      }
    }
    return null;
  }

  static void debugLog(String msg) {
    assert(() {
      // ignore: avoid_print
      print(msg);
      return true;
    }());
  }

  static dynamic _firstDocumentValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List && value.isNotEmpty) return value.first.toString();
    return null;
  }

  static Map<String, String> _extractAllDocuments(Map<String, dynamic> json) {
    final Map<String, String> docs = {};

    const technicalKeys = {
      'id', 'nom', 'cheminFichier', 'type', 'statut', 'created_at', 'updated_at',
      'user_id', 'documentable_id', 'documentable_type', 'password', 'email_verified_at',
    };

    // 1. D'abord, extraire explicitement depuis le tableau 'documents' structuré (API v3/v4)
    if (json['documents'] is List) {
      for (var doc in json['documents']) {
        if (doc is Map<String, dynamic>) {
          final nom = doc['nom']?.toString() ?? 'document';
          final url = doc['url']?.toString();
          if (url != null && url.isNotEmpty && !technicalKeys.contains(nom)) {
            final sanitized = sanitizeUrl(url);
            if (sanitized != null) {
              docs[nom] = sanitized;
            }
          }
        }
      }
    }

    // 2. Ensuite, scanner pour récupérer d'autres champs orphelins (ex: diplome_path en top level)
    void checkValue(String key, dynamic value) {
      if (value == null || value is! String || value.isEmpty) return;
      if (technicalKeys.contains(key)) return;
      
      // La photo de profil apparaîtra de toute façon avec un label propre dans buildDocumentsSection 
      // si on l'inclut, mais pour la rétrocompatibilité du parseur on la garde.
      
      final val = value.toString();
      if (_looksLikeDocumentUrl(val)) {
        final sanitized = sanitizeUrl(val);
        if (sanitized != null && !docs.containsValue(sanitized)) {
          // Éviter d'écraser un document correctement nommé par "url" ou "cheminFichier"
          if (!docs.containsKey(key) && key != 'url' && key != 'cheminFichier') {
             docs[key] = sanitized;
          }
        }
      }
    }

    void scan(Map<String, dynamic> map) {
      map.forEach((key, value) {
        if (key == 'documents') return; // Déjà traité
        
        if (value is Map<String, dynamic>) {
          scan(value);
        } else if (value is List) {
          for (var i = 0; i < value.length; i++) {
            if (value[i] is Map<String, dynamic>) {
              scan(value[i]);
            } else {
              checkValue('${key}_$i', value[i]);
            }
          }
        } else {
          checkValue(key, value);
        }
      });
    }

    scan(json);
    return docs;
  }

  static bool _looksLikeDocumentUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('/storage/') ||
        lowerUrl.contains('/api/media/') ||
        lowerUrl.startsWith('http') ||
        lowerUrl.endsWith('.pdf') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.doc') ||
        lowerUrl.endsWith('.docx');
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      if (address != null) 'adresse': address,
      if (nomEtablissement != null) 'nom_etablissement': nomEtablissement,
      if (typeEtablissement != null) 'type_etablissement': typeEtablissement,
      if (capacite != null) 'capacite': capacite,
      if (fonction != null) 'fonction': fonction,
      if (codePostal != null) 'code_postal': codePostal,
      if (ville != null) 'ville': ville,
      if (telephoneEtablissement != null) 'telephone_etablissement': telephoneEtablissement,
      if (contratPrestationPath != null) 'contrat_prestation_path': contratPrestationPath,
      if (planLocauxPath != null) 'plan_locaux_path': planLocauxPath,
      if (reglementInterieurPath != null) 'reglement_interieur_path': reglementInterieurPath,
    };
  }

  String get name => '$firstName $lastName';
  String get fullName => '$firstName $lastName';

  String get fullAddress {
    String addr = address ?? '';
    if (codePostal != null || ville != null) {
      if (addr.isNotEmpty) addr += ', ';
      addr += '${codePostal ?? ''} ${ville ?? ''}'.trim();
    }
    return addr.isEmpty ? 'Adresse non renseignée' : addr;
  }

  /// Traductions des clés techniques pour les fonctions et spécialités
  static const Map<String, String> _functionLabels = {
    'cook': 'Cuisinier',
    'head_chef': 'Chef cuisinier',
    'pastry_chef': 'Chef pâtissier',
    'kitchen_commis': 'Commis de cuisine',
    'kitchen_helper': 'Aide cuisinier',
    'traditional_cuisine': 'Cuisine traditionnelle',
    'dietary_cuisine': 'Cuisine diététique',
    'modified_textures': 'Textures modifiées',
    'pastry': 'Pâtisserie',
    'bakery': 'Boulangerie',
  };

  /// Traduit une clé technique en label français
  static String translateKey(String key) {
    return _functionLabels[key] ?? key;
  }

  String get displayFunction {
    if (fonctionPrincipale != null && fonctionPrincipale!.trim().isNotEmpty) {
      return translateKey(fonctionPrincipale!.trim());
    }
    if (fonction != null && fonction!.trim().isNotEmpty) {
      return translateKey(fonction!.trim());
    }
    if (specialites != null && specialites!.isNotEmpty) {
      return translateKey(specialites!.first.trim());
    }
    return role == 'professionnel' ? 'Professionnel' : 'Utilisateur';
  }
}
