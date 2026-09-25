import '../../../../core/network/api_client.dart';
import '../models/service_provider_model.dart';

/// Handles all provider-discovery HTTP calls.
/// Returns typed models — no entities, no notifyListeners.
class ProviderApiService {
  const ProviderApiService({required this._apiClient});

  final ApiClient _apiClient;

  List<dynamic> _extractList(dynamic data) {
    if (data is Map<String, dynamic>) {
      final payload = data['data'] ?? data;
      if (payload is Map<String, dynamic> && payload.containsKey('items')) {
        return payload['items'] as List<dynamic>? ?? const [];
      }
      if (payload is List<dynamic>) return payload;
    }
    if (data is List<dynamic>) return data;
    return const [];
  }

  /// GET /providers?categoryId={categoryId}&lat={lat}&lng={lng}
  Future<List<ServiceProviderModel>> getProvidersByCategory(
    String categoryId, {
    double? lat,
    double? lng,
    int page = 1,
    int limit = 10,
  }) async {
    String url = '/providers?categoryId=$categoryId&page=$page&limit=$limit';
    if (lat != null && lng != null) {
      url += '&lat=$lat&lng=$lng';
    }
    final data = await _apiClient.get(url);

    final List<dynamic> list = _extractList(data);

    return list
        .map((item) => ServiceProviderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// GET /providers?q={query}&lat={lat}&lng={lng}
  Future<List<ServiceProviderModel>> searchProviders({
    String? query,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 10,
  }) async {
    String url = '/providers?';
    final params = <String>['page=$page', 'limit=$limit'];
    if (query != null && query.isNotEmpty) {
      params.add('q=${Uri.encodeComponent(query)}');
    }
    if (lat != null && lng != null) {
      params.add('lat=$lat');
      params.add('lng=$lng');
    }
    url += params.join('&');
    final data = await _apiClient.get(url);

    final List<dynamic> list = _extractList(data);

    return list
        .map((item) => ServiceProviderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// GET /providers/{providerId}
  Future<ServiceProviderModel> getProviderDetail(String providerId) async {
    final responseData =
        await _apiClient.get('/providers/$providerId') as Map<String, dynamic>;
    final data = (responseData['data'] as Map<String, dynamic>?) ?? responseData;
    return ServiceProviderModel.fromJson(data);
  }
}
