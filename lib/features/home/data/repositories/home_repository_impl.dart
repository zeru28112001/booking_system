import '../../domain/entities/category.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/category_model.dart';
import '../services/home_api_service.dart';

/// Concrete implementation of HomeRepository.
/// Calls HomeApiService, returns entities.
///
/// Set [useMock] to true while the categories endpoint is unavailable.
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required this._homeApiService,
    this.useMock = false,
  });

  final HomeApiService _homeApiService;
  final bool useMock;

  // ── HomeRepository ────────────────────────────────────────────────────────

  @override
  Future<List<Category>> getCategories() async {
    if (useMock) return _mockCategories();
    return _homeApiService.getCategories();
  }

  // ── Mock responses ────────────────────────────────────────────────────────

  Future<List<Category>> _mockCategories() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate latency
    return const [
      CategoryModel(id: '1', name: 'Beauty & Salon', iconName: 'spa'),
      CategoryModel(id: '2', name: 'Home Cleaning', iconName: 'cleaning'),
      CategoryModel(id: '3', name: 'Plumbing', iconName: 'plumbing'),
      CategoryModel(id: '4', name: 'Electrical', iconName: 'electrical'),
      CategoryModel(id: '5', name: 'Tutoring', iconName: 'tutoring'),
    ];
  }
}
