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
    this.isShop = false,
    this.isHomeService = false,
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

  /// True if shop model (multiple staff), false if solo pro.
  final bool isShop;

  /// True if home/on-site service (e.g. cleaning), false if customer visits salon/shop.
  final bool isHomeService;

  /// Populated only by detail fetches; empty in list summaries.
  final List<Service> services;
  final List<Review> reviews;
  final List<Staff> staffList;

  @override
  String toString() => 'ServiceProvider(id: $id, name: $name)';
}
