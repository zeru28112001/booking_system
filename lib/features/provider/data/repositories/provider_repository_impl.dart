import '../../domain/entities/service_provider.dart';
import '../../domain/repositories/provider_repository.dart';
import '../services/provider_api_service.dart';

/// Concrete implementation of ProviderRepository.
/// Calls ProviderApiService, returns entities.
class ProviderRepositoryImpl implements ProviderRepository {
  ProviderRepositoryImpl({
    required this.providerApiService,
  });

  final ProviderApiService providerApiService;

  // ── ProviderRepository ────────────────────────────────────────────────────

  @override
  Future<List<ServiceProvider>> getProvidersByCategory(
    String categoryId, {
    double? lat,
    double? lng,
    int page = 1,
    int limit = 10,
  }) async {
    final models = await providerApiService.getProvidersByCategory(
      categoryId,
      lat: lat,
      lng: lng,
      page: page,
      limit: limit,
    );
    return models;
  }

  @override
  Future<List<ServiceProvider>> searchProviders({
    String? query,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 10,
  }) async {
    final models = await providerApiService.searchProviders(
      query: query,
      lat: lat,
      lng: lng,
      page: page,
      limit: limit,
    );
    return models;
  }

  @override
  Future<ServiceProvider> getProviderDetail(String providerId) async {
    return providerApiService.getProviderDetail(providerId);
  }
}
