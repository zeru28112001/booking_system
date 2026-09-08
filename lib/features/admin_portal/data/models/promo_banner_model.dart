class PromoBannerModel {
  const PromoBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.iconName = 'local_offer',
    this.imageUrl,
    this.targetCategoryId,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final String? imageUrl;
  final String? targetCategoryId;
  final bool isActive;
  final int sortOrder;

  factory PromoBannerModel.fromJson(Map<String, dynamic> json) {
    return PromoBannerModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      iconName: json['iconName'] as String? ?? json['icon_name'] as String? ?? 'local_offer',
      imageUrl: json['imageUrl'] as String?,
      targetCategoryId: json['targetCategoryId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'subtitle': subtitle,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'targetCategoryId': targetCategoryId,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  PromoBannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? iconName,
    String? imageUrl,
    String? targetCategoryId,
    bool? isActive,
    int? sortOrder,
  }) {
    return PromoBannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconName: iconName ?? this.iconName,
      imageUrl: imageUrl ?? this.imageUrl,
      targetCategoryId: targetCategoryId ?? this.targetCategoryId,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
