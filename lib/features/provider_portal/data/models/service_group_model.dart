import '../../domain/entities/service_group.dart';

class ServiceGroupModel extends ServiceGroup {
  const ServiceGroupModel({
    required super.id,
    required super.providerId,
    required super.name,
    super.description = '',
    super.iconName = 'category',
    super.sortOrder = 0,
    super.isActive = true,
  });

  factory ServiceGroupModel.fromJson(Map<String, dynamic> json) {
    return ServiceGroupModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      providerId: (json['providerId'] ?? json['provider_id'] ?? '').toString(),
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      iconName: (json['iconName'] as String?) ?? (json['icon_name'] as String?) ?? 'category',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: (json['isActive'] as bool?) ?? (json['is_active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'name': name,
        'description': description,
        'iconName': iconName,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };

  @override
  ServiceGroupModel copyWith({
    String? id,
    String? providerId,
    String? name,
    String? description,
    String? iconName,
    int? sortOrder,
    bool? isActive,
  }) {
    return ServiceGroupModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
