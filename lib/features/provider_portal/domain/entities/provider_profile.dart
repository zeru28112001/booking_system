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
    required this.verificationStatus, // 'pending' | 'verified' | 'rejected'
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.rejectionReason,
  });

  final String id;
  final String shopName;
  final String categoryName;
  final String description;
  final String address;
  final String phone;
  final bool isAvailable;
  final String verificationStatus;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String? rejectionReason;
}
