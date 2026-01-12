class ApiConfig {
  // URL de base de votre API backend
  static const String baseUrl = 'https://api.ars-app.com/api/v1';
  
  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/user/profile';
  static const String missions = '/missions';
  static const String formations = '/formations';
  static const String documents = '/documents';
  static const String experiences = '/experiences';
  static const String payments = '/payments';
  
  // Timeout pour les requêtes
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers par défaut
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

