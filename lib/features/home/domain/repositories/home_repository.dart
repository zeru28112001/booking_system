import '../entities/category.dart';

/// Abstract home repository contract.
/// Providers depend only on this interface, never on the impl.
abstract class HomeRepository {
  /// Fetch the service categories shown on the Home grid.
  Future<List<Category>> getCategories();
}
