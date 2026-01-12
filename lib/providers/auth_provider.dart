import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email, password);

    _isLoading = false;

    if (result['success'] == true) {
      _user = result['user'];
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Erreur de connexion';
      notifyListeners();
      return false;
    }
  }

  // Inscription
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      address: address,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _user = result['user'];
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Erreur lors de l\'inscription';
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _authService.logout();
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

