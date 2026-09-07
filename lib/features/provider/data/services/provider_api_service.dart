import '../../../../core/network/api_client.dart';
import '../models/service_provider_model.dart';

/// Handles all provider-discovery HTTP calls.
/// Returns typed models — no entities, no notifyListeners.
class ProviderApiService {
  const ProviderApiService({required this._apiClient});

  final ApiClient _apiClient;

  /// GET /categories/{categoryId}/providers
  Future<List<ServiceProviderModel>> getProvidersByCategory(
    String categoryId,
  ) async {
    final data = await _apiClient.get('/categories/$categoryId/providers');

    // ApiClient normalises an empty body to {}, so unwrap `{ data: [...] }`
    // and tolerate a bare JSON array.
    final List<dynamic> list = data is Map<String, dynamic>
        ? (data['data'] as List<dynamic>? ?? const [])
        : (data as List<dynamic>? ?? const []);

    return list
        .map((item) => ServiceProviderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// GET /providers/{providerId}
  Future<ServiceProviderModel> getProviderDetail(String providerId) async {
    final data =
        await _apiClient.get('/providers/$providerId') as Map<String, dynamic>;
    return ServiceProviderModel.fromJson(data);
  }
}
