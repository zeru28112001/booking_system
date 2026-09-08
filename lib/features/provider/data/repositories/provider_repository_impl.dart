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
  Future<List<ServiceProvider>> getProvidersByCategory(String categoryId) async {
    return providerApiService.getProvidersByCategory(categoryId);
  }

  @override
  Future<ServiceProvider> getProviderDetail(String providerId) async {
    return providerApiService.getProviderDetail(providerId);
  }
}
