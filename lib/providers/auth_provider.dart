import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Connexion classique (retourne bool)
  Future<bool> login(String email, String password) async {
    final result = await loginWithCode(email, password);
    return result['success'] == true;
  }

  // Connexion avancée (retourne le code d'erreur complet pour gérer pending_validation)
  Future<Map<String, dynamic>> loginWithCode(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.loginWithCode(email, password);

      _isLoading = false;

      if (result['success'] == true) {
        _user = result['user'];
        _errorMessage = null;
        await TokenService.save(result['token']);
        notifyListeners();
        return {'success': true};
      } else {
        _errorMessage = result['message'] ?? 'Erreur de connexion';
        notifyListeners();
        return {
          'success': false,
          'code': result['code'],
          'message': result['message'],
          'role': result['role'],
        };
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  // Inscription
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? address,
    String? role,
    // Champs spécifiques CLIENT
    String? nomEtablissement,
    String? typeEtablissement,
    String? codePostal,
    String? ville,
    String? capacite,
    String? fonction,
    String? telephoneEtablissement,
    dynamic contratPrestationPath, // Modifié en dynamic
    dynamic planLocauxPath, // Modifié en dynamic
    dynamic reglementInterieurPath, // Modifié en dynamic
    // Champs spécifiques PROFESSIONNEL
    String? dateNaissance,
    String? diplome,
    String? anneesExperience,
    List<String>? specialites,
    dynamic photoProfilPath, // Modifié en dynamic
    List<dynamic>? diplomePaths, // Modifié pour accepter une liste
    dynamic certificatMedicalPath, // Modifié en dynamic
    dynamic permisConduirePath, // Modifié en dynamic
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
      address: address,
      role: role,
      nomEtablissement: nomEtablissement,
      typeEtablissement: typeEtablissement,
      codePostal: codePostal,
      ville: ville,
      capacite: capacite,
      fonction: fonction,
      telephoneEtablissement: telephoneEtablissement,
      contratPrestationPath: contratPrestationPath,
      planLocauxPath: planLocauxPath,
      reglementInterieurPath: reglementInterieurPath,
      dateNaissance: dateNaissance,
      diplome: diplome,
      anneesExperience: anneesExperience,
      specialites: specialites,
      photoProfilPath: photoProfilPath,
      diplomePaths: diplomePaths,
      certificatMedicalPath: certificatMedicalPath,
      permisConduirePath: permisConduirePath,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _user = result['user'];
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      if (result['errors'] != null) {
        // Concaténer les erreurs de validation
        final errors = result['errors'] as Map<String, dynamic>;
        final messages = errors.values.map((e) => (e as List).join(', ')).join('\n');
        _errorMessage = messages;
      } else {
        _errorMessage = result['message'] ?? 'Erreur lors de l\'inscription';
      }
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _authService.logout();
    await TokenService.clear();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Charger le profil
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();                  

    _user = await _authService.getProfile();
    
    _isLoading = false;
    notifyListeners();
  }

  // Mettre à jour le profil
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.updateProfile(data);

    _isLoading = false;

    if (result['success'] == true) {
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Erreur lors de la mise à jour';
      notifyListeners();
      return false;
    }
  }

  // Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

