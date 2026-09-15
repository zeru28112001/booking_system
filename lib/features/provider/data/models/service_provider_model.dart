import '../../domain/entities/review.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/service_provider.dart';
import '../../domain/entities/staff.dart';
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
    super.isAvailable = true,
    super.isShop = false,
    super.isHomeService = false,
    super.latitude,
    super.longitude,
    super.services,
    super.reviews,
    super.staffList,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      categoryId: (json['category_id'] as String?) ??
          (json['categoryId'] as String?) ??
          (json['category'] is Map ? (json['category']['_id'] ?? json['category']['id'])?.toString() : json['category'] as String?) ??
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
      isAvailable: (json['is_available'] as bool?) ??
          (json['isAvailable'] as bool?) ??
          (json['is_open'] as bool?) ??
          (json['isOpen'] as bool?) ??
          true,
      isShop: (json['is_shop'] as bool?) ?? (json['isShop'] as bool?) ?? false,
      isHomeService: (json['is_home_service'] as bool?) ??
          (json['isHomeService'] as bool?) ??
          false,
      latitude: json['location']?['coordinates'] != null && (json['location']['coordinates'] as List).length >= 2
          ? (json['location']['coordinates'][1] as num).toDouble()
          : null,
      longitude: json['location']?['coordinates'] != null && (json['location']['coordinates'] as List).length >= 2
          ? (json['location']['coordinates'][0] as num).toDouble()
          : null,
      services: (json['services'] as List<dynamic>? ?? const [])
          .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>? ?? const [])
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      staffList: ((json['staff'] ?? json['staffList']) as List<dynamic>? ?? const [])
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
        if (latitude != null && longitude != null)
          'location': {
            'type': 'Point',
            'coordinates': [longitude, latitude],
          },
        'services': services.map((s) => (s is ServiceModel ? s.toJson() : s)).toList(),
        'reviews': reviews.map((r) => (r is ReviewModel ? r.toJson() : r)).toList(),
        'staff': staffList.map((st) => (st is StaffModel ? st.toJson() : st)).toList(),
      };

  @override
  ServiceProviderModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? tagline,
    double? rating,
    int? reviewCount,
    double? distanceKm,
    int? priceMin,
    int? priceMax,
    String? address,
    String? phone,
    bool? isOpen,
    bool? isAvailable,
    bool? isShop,
    bool? isHomeService,
    double? latitude,
    double? longitude,
    List<Service>? services,
    List<Review>? reviews,
    List<Staff>? staffList,
  }) {
    return ServiceProviderModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distanceKm: distanceKm ?? this.distanceKm,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isOpen: isOpen ?? this.isOpen,
      isAvailable: isAvailable ?? this.isAvailable,
      isShop: isShop ?? this.isShop,
      isHomeService: isHomeService ?? this.isHomeService,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      services: services ?? this.services,
      reviews: reviews ?? this.reviews,
      staffList: staffList ?? this.staffList,
    );
  }
}
