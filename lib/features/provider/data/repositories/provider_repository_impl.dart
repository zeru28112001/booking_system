import '../../../../core/error/app_exception.dart';
import '../../domain/entities/service_provider.dart';
import '../../domain/repositories/provider_repository.dart';
import '../mock/provider_mock_data.dart';
import '../services/provider_api_service.dart';

/// Concrete implementation of ProviderRepository.
/// Calls ProviderApiService, returns entities.
///
/// Set [useMock] to true while the provider endpoints are unavailable.
class ProviderRepositoryImpl implements ProviderRepository {
  ProviderRepositoryImpl({
    required this._providerApiService,
    this.useMock = false,
  });

  final ProviderApiService _providerApiService;
  final bool useMock;

  // ── ProviderRepository ────────────────────────────────────────────────────

  @override
  Future<List<ServiceProvider>> getProvidersByCategory(String categoryId) async {
    if (useMock) return _mockProvidersByCategory(categoryId);
    return _providerApiService.getProvidersByCategory(categoryId);
  }

  @override
  Future<ServiceProvider> getProviderDetail(String providerId) async {
    if (useMock) return _mockProviderDetail(providerId);
    return _providerApiService.getProviderDetail(providerId);
  }

  // ── Mock responses ────────────────────────────────────────────────────────

  Future<List<ServiceProvider>> _mockProvidersByCategory(String categoryId) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate latency
    return ProviderMockData.all
        .where((provider) => provider.categoryId == categoryId)
        .toList();
  }

  Future<ServiceProvider> _mockProviderDetail(String providerId) async {
    await Future.delayed(const Duration(seconds: 1));
    for (final provider in ProviderMockData.all) {
      if (provider.id == providerId) return provider;
    }
    throw const NotFoundException('Provider not found.');
  }
}
