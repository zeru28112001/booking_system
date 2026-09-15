import 'review.dart';
import 'service.dart';
import 'staff.dart';

/// Domain entity — a business or pro offering services in one category.
/// No JSON logic here. No HTTP imports.
class ServiceProvider {
  const ServiceProvider({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.tagline,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.priceMin,
    required this.priceMax,
    required this.address,
    required this.phone,
    required this.isOpen,
    this.isAvailable = true,
    this.isShop = false,
    this.isHomeService = false,
    this.latitude,
    this.longitude,
    this.services = const [],
    this.reviews = const [],
    this.staffList = const [],
  });

  final String id;
  final String categoryId;
  final String name;
  final String tagline;

  /// 0–5 average rating.
  final double rating;
  final int reviewCount;
  final double distanceKm;

  /// Price range in MMK across all services.
  final int priceMin;
  final int priceMax;

  final String address;
  final String phone;
  final bool isOpen;
  final bool isAvailable;

  /// True if shop model (multiple staff), false if solo pro.
  final bool isShop;

  /// True if home/on-site service (e.g. cleaning), false if customer visits salon/shop.
  final bool isHomeService;

  final double? latitude;
  final double? longitude;

  /// Populated only by detail fetches; empty in list summaries.
  final List<Service> services;
  final List<Review> reviews;
  final List<Staff> staffList;

  ServiceProvider copyWith({
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
    return ServiceProvider(
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

  @override
  String toString() => 'ServiceProvider(id: $id, name: $name)';
}
