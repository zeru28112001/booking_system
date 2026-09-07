import '../../domain/entities/provider_profile.dart';

class ProviderProfileModel extends ProviderProfile {
  const ProviderProfileModel({
    required super.id,
    required super.shopName,
    required super.categoryName,
    required super.description,
    required super.address,
    required super.phone,
    required super.isAvailable,
    required super.verificationStatus,
    required super.rating,
    required super.reviewCount,
    required super.imageUrl,
    super.rejectionReason,
  });

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    return ProviderProfileModel(
      id: json['id'] as String? ?? '',
      shopName: json['shop_name'] as String? ?? json['shopName'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? json['categoryName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? json['isAvailable'] as bool? ?? true,
      verificationStatus: json['verification_status'] as String? ?? json['verificationStatus'] as String? ?? 'verified',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: json['review_count'] as int? ?? json['reviewCount'] as int? ?? 12,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      rejectionReason: json['rejection_reason'] as String? ?? json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_name': shopName,
      'category_name': categoryName,
      'description': description,
      'address': address,
      'phone': phone,
      'is_available': isAvailable,
      'verification_status': verificationStatus,
      'rating': rating,
      'review_count': reviewCount,
      'image_url': imageUrl,
      'rejection_reason': rejectionReason,
    };
  }

  ProviderProfileModel copyWith({
    String? id,
    String? shopName,
    String? categoryName,
    String? description,
    String? address,
    String? phone,
    bool? isAvailable,
    String? verificationStatus,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? rejectionReason,
  }) {
    return ProviderProfileModel(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isAvailable: isAvailable ?? this.isAvailable,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
