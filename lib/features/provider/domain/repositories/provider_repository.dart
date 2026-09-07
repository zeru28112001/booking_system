import '../entities/service_provider.dart';

/// Abstract provider-discovery repository contract.
/// Providers depend only on this interface, never on the impl.
abstract class ProviderRepository {
  /// Providers offering services in [categoryId], in recommended order.
  Future<List<ServiceProvider>> getProvidersByCategory(String categoryId);

  /// Full provider incl. services + reviews. Throws NotFoundException if absent.
  Future<ServiceProvider> getProviderDetail(String providerId);
}
