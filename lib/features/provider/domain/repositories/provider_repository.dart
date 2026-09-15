import '../entities/service_provider.dart';

/// Abstract provider-discovery repository contract.
/// Providers depend only on this interface, never on the impl.
abstract class ProviderRepository {
  /// Providers offering services in [categoryId], in recommended order.
  Future<List<ServiceProvider>> getProvidersByCategory(
    String categoryId, {
    double? lat,
    double? lng,
    int page = 1,
    int limit = 10,
  });

  Future<List<ServiceProvider>> searchProviders({
    String? query,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 10,
  });

  /// Full provider incl. services + reviews. Throws NotFoundException if absent.
  Future<ServiceProvider> getProviderDetail(String providerId);
}
