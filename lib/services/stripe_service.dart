import '../config/api_config.dart';
import 'api_service.dart';

class StripeService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> createConnectAccount() async {
    try {
      final response = await _apiService.post(ApiConfig.stripeAccount, {});
      return {
        'success': true,
        'url': response['url'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> checkOnboardingStatus() async {
    try {
      final response = await _apiService.get(ApiConfig.stripeStatus);
      return {
        'success': true,
        'complete': response['complete'] ?? false,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
