import '../../domain/entities/category.dart';

/// Data-layer DTO — extends Category and adds JSON (de)serialization.
/// Screens and providers never import this class.
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.iconName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] as String?) ?? '',
      iconName: (json['icon'] as String?) ?? (json['icon_name'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': iconName,
      };
}
