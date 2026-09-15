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
    super.isShop = false,
    super.isHomeService = false,
    required super.verificationStatus,
    required super.rating,
    required super.reviewCount,
    required super.imageUrl,
    super.rejectionReason,
    super.latitude,
    super.longitude,
    super.hasPendingApproval = false,
  });

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    return ProviderProfileModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      shopName: json['shopName'] as String? ?? json['shop_name'] as String? ?? json['name'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? json['category_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? json['isAvailable'] as bool? ?? true,
      isShop: (json['is_shop'] as bool?) ?? (json['isShop'] as bool?) ?? false,
      isHomeService: (json['is_home_service'] as bool?) ?? (json['isHomeService'] as bool?) ?? false,
      verificationStatus: json['verification_status'] as String? ?? json['verificationStatus'] as String? ?? 'verified',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: json['review_count'] as int? ?? json['reviewCount'] as int? ?? 12,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      rejectionReason: json['rejection_reason'] as String? ?? json['rejectionReason'] as String?,
      latitude: json['location']?['coordinates'] != null && (json['location']['coordinates'] as List).length >= 2
          ? (json['location']['coordinates'][1] as num).toDouble()
          : null,
      longitude: json['location']?['coordinates'] != null && (json['location']['coordinates'] as List).length >= 2
          ? (json['location']['coordinates'][0] as num).toDouble()
          : null,
      hasPendingApproval: (json['hasPendingApproval'] as bool?) ?? (json['has_pending_approval'] as bool?) ?? false,
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
      'isShop': isShop,
      'isHomeService': isHomeService,
      'is_shop': isShop,
      'is_home_service': isHomeService,
      'verification_status': verificationStatus,
      'rating': rating,
      'review_count': reviewCount,
      'image_url': imageUrl,
      'rejection_reason': rejectionReason,
      'hasPendingApproval': hasPendingApproval,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
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
    bool? isShop,
    bool? isHomeService,
    String? verificationStatus,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? rejectionReason,
    double? latitude,
    double? longitude,
    bool? hasPendingApproval,
  }) {
    return ProviderProfileModel(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isAvailable: isAvailable ?? this.isAvailable,
      isShop: isShop ?? this.isShop,
      isHomeService: isHomeService ?? this.isHomeService,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hasPendingApproval: hasPendingApproval ?? this.hasPendingApproval,
    );
  }
}
