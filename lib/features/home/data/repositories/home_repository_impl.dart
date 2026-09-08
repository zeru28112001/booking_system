import '../../../admin_portal/data/models/promo_banner_model.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/home_repository.dart';
import '../services/home_api_service.dart';

/// Concrete implementation of HomeRepository.
/// Calls HomeApiService, returns entities.
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required this.homeApiService,
  });

  final HomeApiService homeApiService;

  // ── HomeRepository ────────────────────────────────────────────────────────

  @override
  Future<List<Category>> getCategories() async {
    return homeApiService.getCategories();
  }

  @override
  Future<List<PromoBannerModel>> getBanners() async {
    return homeApiService.getBanners();
  }
}
