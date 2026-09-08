class ServiceGroup {
  const ServiceGroup({
    required this.id,
    required this.providerId,
    required this.name,
    this.description = '',
    this.iconName = 'category',
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String providerId;
  final String name;
  final String description;
  final String iconName;
  final int sortOrder;
  final bool isActive;

  ServiceGroup copyWith({
    String? id,
    String? providerId,
    String? name,
    String? description,
    String? iconName,
    int? sortOrder,
    bool? isActive,
  }) {
    return ServiceGroup(
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
