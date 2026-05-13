class ApiConfig {
  // URL de base de votre API backend
  // LOCAL : http://127.0.0.1:8000/api
  // PROD  : https://arsbackend.onrender.com/api
  static const String _baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://127.0.0.1:8000/api');

  static String get baseUrl => _baseUrl;

  // Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String profile = '/profile'; // GET profile
  static const String updateProfileEndpoint = '/user'; // PUT profile
  static const String missions = '/missions';
  static const String formations = '/formations';
  static const String documents = '/documents';
  static const String myDocuments = '/my-documents'; // GET liste complète avec IDs
  static const String experiences = '/experiences';
  static const String payments = '/payments';
  static const String recipes = '/recettes';
  static const String professionals = '/professionals';
  static const String structures = '/structures';
  static const String adminStats = '/stats/admin';
  static const String structureStats = '/stats/structure';
  static const String stripeAccount = '/stripe/account';
  static const String stripeStatus = '/stripe/status';

  // Timeout pour les requêtes (Augmenté pour Render.com Free Tier)
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Headers par défaut
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
