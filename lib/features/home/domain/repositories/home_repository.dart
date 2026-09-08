import '../../../admin_portal/data/models/promo_banner_model.dart';
import '../entities/category.dart';

/// Abstract home repository contract.
/// Providers depend only on this interface, never on the impl.
abstract class HomeRepository {
  /// Fetch the service categories shown on the Home grid.
  Future<List<Category>> getCategories();

  /// Fetch the active promo banners shown on the Home carousel.
  Future<List<PromoBannerModel>> getBanners();
}
