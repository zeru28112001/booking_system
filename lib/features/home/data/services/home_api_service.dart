import '../../../../core/network/api_client.dart';
import '../../../admin_portal/data/models/promo_banner_model.dart';
import '../models/category_model.dart';

/// Handles all home HTTP calls.
/// Returns typed models — no entities, no notifyListeners.
class HomeApiService {
  const HomeApiService({required this._apiClient});

  final ApiClient _apiClient;

  /// GET /settings/public — no auth required, checks isMaintenanceMode
  Future<Map<String, dynamic>> getPublicSettings() async {
    try {
      final data = await _apiClient.get('/settings/public');
      return data is Map<String, dynamic> ? data : {};
    } catch (_) {
      return {};
    }
  }

  /// GET /categories
  Future<List<CategoryModel>> getCategories() async {
    final data = await _apiClient.get('/categories');

    // ApiClient normalises an empty body to {}, so unwrap `{ data: [...] }`
    // and tolerate a bare JSON array.
    final List<dynamic> list = data is Map<String, dynamic>
        ? (data['data'] as List<dynamic>? ?? const [])
        : (data as List<dynamic>? ?? const []);

    return list
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// GET /banners
  Future<List<PromoBannerModel>> getBanners() async {
    final data = await _apiClient.get('/banners');

    final List<dynamic> list = data is Map<String, dynamic>
        ? (data['data'] as List<dynamic>? ?? const [])
        : (data as List<dynamic>? ?? const []);

    return list
        .map((item) => PromoBannerModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
