/// Domain entity representing a Provider's business profile.
class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.shopName,
    required this.categoryName,
    required this.description,
    required this.address,
    required this.phone,
    required this.isAvailable,
    this.isShop = false,
    this.isHomeService = false,
    required this.verificationStatus, // 'pending' | 'verified' | 'rejected'
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.rejectionReason,
    this.latitude,
    this.longitude,
    this.hasPendingApproval = false,
  });

  final String id;
  final String shopName;
  final String categoryName;
  final String description;
  final String address;
  final String phone;
  final bool isAvailable;
  final bool isShop;
  final bool isHomeService;
  final String verificationStatus;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String? rejectionReason;
  final double? latitude;
  final double? longitude;
  final bool hasPendingApproval;
}
