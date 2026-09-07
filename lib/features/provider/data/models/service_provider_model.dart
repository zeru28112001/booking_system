import '../../domain/entities/service_provider.dart';
import 'review_model.dart';
import 'service_model.dart';
import 'staff_model.dart';

/// Data-layer DTO — extends ServiceProvider and adds JSON (de)serialization.
/// Screens and providers never import this class.
class ServiceProviderModel extends ServiceProvider {
  const ServiceProviderModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.tagline,
    required super.rating,
    required super.reviewCount,
    required super.distanceKm,
    required super.priceMin,
    required super.priceMax,
    required super.address,
    required super.phone,
    required super.isOpen,
    super.isShop = false,
    super.isHomeService = false,
    super.services,
    super.reviews,
    super.staffList,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: (json['id'] ?? '').toString(),
      categoryId: (json['category_id'] as String?) ??
          (json['categoryId'] as String?) ??
          '',
      name: (json['name'] as String?) ?? '',
      tagline: (json['tagline'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ??
          (json['reviewCount'] as num?)?.toInt() ??
          0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ??
          (json['distanceKm'] as num?)?.toDouble() ??
          0,
      priceMin: (json['price_min'] as num?)?.toInt() ??
          (json['priceMin'] as num?)?.toInt() ??
          0,
      priceMax: (json['price_max'] as num?)?.toInt() ??
          (json['priceMax'] as num?)?.toInt() ??
          0,
      address: (json['address'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      isOpen: (json['is_open'] as bool?) ?? (json['isOpen'] as bool?) ?? true,
      isShop: (json['is_shop'] as bool?) ?? (json['isShop'] as bool?) ?? false,
      isHomeService: (json['is_home_service'] as bool?) ??
          (json['isHomeService'] as bool?) ??
          false,
      services: (json['services'] as List<dynamic>? ?? const [])
          .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>? ?? const [])
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      staffList: (json['staff'] as List<dynamic>? ?? const [])
          .map((item) => StaffModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'tagline': tagline,
        'rating': rating,
        'review_count': reviewCount,
        'distance_km': distanceKm,
        'price_min': priceMin,
        'price_max': priceMax,
        'address': address,
        'phone': phone,
        'is_open': isOpen,
        'is_shop': isShop,
        'is_home_service': isHomeService,
        'services': services.map((s) => (s as ServiceModel).toJson()).toList(),
        'reviews': reviews.map((r) => (r as ReviewModel).toJson()).toList(),
        'staff': staffList.map((st) => (st as StaffModel).toJson()).toList(),
      };
}
